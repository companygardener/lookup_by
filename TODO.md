Roadmap
=======

* Pluggable backend (memcache, redis, etc.) to reduce memory usage, allow
  larger LRUs.
* Additional database support / tests
* Improve LRU algorithm
* Lookup by multiple fields, multi-column unique constraint

Soon
====
* Travis CI
* Gemnasium
* Require validations / constraints on lookup field (presence, uniqueness)
* Trap signal to output stats
* Populate LRU with counts grouped by an association
