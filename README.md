# Heterocera Server

A [sinatra](http://www.sinatrarb.com/) based associative memory system by David ten Have.

## Introduction

Heterocera is an implementation of an associative memory system. 
It is inspired by the concept of a [tuple space](http://en.wikipedia.org/wiki/Tuple_space) 
and by the work of [David Gelernter](http://en.wikipedia.org/wiki/David_Gelernter) 
(outlined in his book [Mirror Worlds](http://www.amazon.com/Mirror-Worlds-Software-Universe-Shoebox-How/dp/019507906X)).

Heterocera is designed to enable easy communication in heterogeneous environments (e.g. Arduino applications and web applications).
This is done by treating the memory space as a web server - where address locations are URLs. Heterocera will handle single values, rich JSON structures and files. 

By reducing all interactions to HTTP GET and POST requests even simple platforms can record and retrieve data.

This is not meant to be a NoSQL system. It is designed to:

* simplify and decouple communications between a range of systems of varying capability
* enable sensor ecosystems

## Usage

Heterocera handles data in the following manner (note that the data element is optional):

    [address_element1, address_element2, ... address_elementN] = data

A real world example might be data from a water meter:

    [sensor_location, data_stream_id, time] = data

    ["upper_landing_strip", "water_tank_level", "1325206004"] = 400

This is combined with the standard READ, WRITE and TAKE actions allowed in a tuple space to generate URLs. 

* WRITE is used to save a value into the space. 
* READ is used to passively retrieve data. 
* TAKE retrieves data and deletes data from the space.

To **WRITE** into the space:

    http://localhost:4567/write/upper_landing_strip/water_tank_level/1325206004?value=400

To **READ** data from the space:

    http://localhost:4567/read/upper_landing_strip/water_tank_level/1325206004

To **TAKE** data from the space:

    http://localhost:4567/take/upper_landing_strip/water_tank_level/1325206004

WRITE and TAKE operations require explicit URLs. READ operations will accept wild cards in the URL. 
The '*' character is used as a wild card. To continue the above example if you wanted to read all the stored values 
for the water meter over time:

    http://localhost:4567/read/upper_landing_strip/water_tank_level/*
    
If you wanted to read all the values for all the data streams at a given time:

    http://localhost:4567/read/upper_landing_strip/*/1325206004     

## Data types

By default Heterocera returns data as JSON. So the following READ:

    http://localhost:4567/read/upper_landing_strip/water_tank_level/1325206004

returns:

    {
      "id": "a93120f9d1ac1b148e52d25e60306bd5",
      "value": "400",
      "created_at": "2011-12-30T14:30:57+13:00",
      "tags": [
        {
        "value": "upper_landing_strip",
        "order": 1
        },
        {
        "value": "water_tank_level",
        "order": 2
        },
        {
        "value": "1325206004",
        "order": 3
        }
      ]
    }

Heterocera supports:

* JSON (.json)
* XML (.xml)
* HTML (.html)
* GZip (.gz)
* Zip (.zip)

Alternative data formats are accessed by appending the relevant file extension. So the following READ:

    http://localhost:4567/read/upper_landing_strip/water_tank_level/1325206004.xml

returns:

    <tuples type="array">
      <tuple>
        <id>a93120f9d1ac1b148e52d25e60306bd5</id>
        <value>400</value>
        <created_at>2011-12-30 14:30:57 +1300</created_at>
        <tags>
          <tag>
            <value>upper_landing_strip</value>
            <order>1</order>
          </tag>
          <tag>
            <value>water_tank_level</value>
            <order>2</order>
          </tag>
          <tag>
            <value>1325206004</value>
            <order>3</order>
          </tag>
        </tags>
      </tuple>
    </tuples>

## System Chit-chat

All communication occurs over HTTP. TAKE and READ operations are GET only. WRITE operations can by executed using GET, POST and PUT.

WRITE operations rely on a 'value' parameter. If using a multi-part form is it possible upload a file into the space. To retrieve 
the file contents append READ operations with .gz (a tar gz archive) or .zip (zip archive) file extensions, any other extensions will display the file name in the 'value'
field. 

## Support Tools

### Ruby

There is a [ruby gem](https://github.com/dave5/heterocera-gem ) that can be used to communicate with a Heterocera Server.

## Installation

Clone and pray... sorry, will make this more slick in the next few days.

## Contribute

Yes please!
