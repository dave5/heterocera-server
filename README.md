Hetrocera Server
================

Hetrocera Server is an implementation of an associative memory system. 
It is inspired by the concept of a [tuple space](http://en.wikipedia.org/wiki/Tuple_space) 
and by the work of [David Gelernter](http://en.wikipedia.org/wiki/David_Gelernter) 
(outlined in his book [Mirror Worlds](http://www.amazon.com/Mirror-Worlds-Software-Universe-Shoebox-How/dp/019507906X)).

Hetrocera Server is designed to enable easy communication in heterogeneous environments (e.g. Arduino applications and web applications).
This is done by treating the memory space as a web server - where address locations are URLs. Heterocera will handle single value, rich JSON structures and files. 

By reducing all interactions to http GET and POST action even simple platforms can record and retrieve data.

Usage
-----

Heterocera handles data in the following manner:

    [address_element1, address_element2, ... address_elementN] = data

A real world example might be data from a water meter:

    [sensor_id, data_stream_id, time] = data

    ["water_meter", "dce7ae54-3d46-1188-2ea4-d9ebc19ac26d", "1325206004"] = 400

This is combined with the standard READ, WRITE and TAKE actions allowed in a tuple space to generate URLs. 

* WRITE is used to save a value into the space. 
* READ is used to passively retrieve data. 
* TAKE retrieves data and deletes data from the space.

To WRITE into the space:

    http://localhost:4567/write/water_meter/dce7ae54-3d46-1188-2ea4-d9ebc19ac26d/1325206004?value=400

To READ:

    http://localhost:4567/read/water_meter/dce7ae54-3d46-1188-2ea4-d9ebc19ac26d/1325206004

To TAKE:

    http://localhost:4567/take/water_meter/dce7ae54-3d46-1188-2ea4-d9ebc19ac26d/1325206004

WRITE and TAKE operations require explicit addresses. READ operations will accept wild cards. 
The '*' character is used as a wild card. To continue the above example if you wanted to read all the stored values 
for the water meter over time:

    http://localhost:4567/read/water_meter/dce7ae54-3d46-1188-2ea4-d9ebc19ac26d/*
    
If you wanted to read all the values for all the data streams at a given time:

    http://localhost:4567/read/water_meter/*/1325206004     
  