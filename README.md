Hetrocera Server
================

Hetrocera Server is an implementation of an associative memory system or [tuple space](http://en.wikipedia.org/wiki/Tuple_space). It is inspired by the work of [David Gelernter](http://en.wikipedia.org/wiki/David_Gelernter).

Hetrocera Server is designed to enable easy communication in heterogeneous environments (e.g. Arduino applications and web applications).


Usage
-----

Heterocera treats tuples as an address + value:

  ["foo", "baa"] = data_to_be_stored

This is combined with the standard READ, WRITE and TAKE actions allowed in a tuple space to generate URLs. To WRITE into the space:

  http://localhost:4567/write/foo/baa?value=data_to_be_stored

To READ:

  http://localhost:4567/read/foo/baa

To TAKE:

  http://localhost:4567/take/guid_of_data_element
  