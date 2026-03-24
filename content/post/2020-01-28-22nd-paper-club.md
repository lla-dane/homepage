---
date: 2020-01-28T00:00:00Z
tags: [tech, paper, distributed-systems]
title: 22nd Distributed Systems Paper Club

---

In the 22nd session we took a look at `io_uring` - a new Kernel interface for
asynchronous I/O. Tyler, who is currently implementing an `io_uring` library in
Rust [4] for his database sled [7] guided us through the concepts as well as a
bunch of source code.

Tyler started off introducing the status quo of I/O interfaces within the Linux
Kernel like read, pread and preadv, jumped over to asynchronous I/O like aio and
eventually helped us develop a sense of what the perfect asynchronous I/O
interface of the future could look like. For alll of this he used Jens Axboe's
slides from a Kernel Recipes 2019 talk [1].

From there on we covered the high level structure of the new kernel interface.
We looked into io_uring's usage of two ring buffers for user-kernel space
communication and the needed synchronization primitives on the two data
structures (with the trick of one side having write access to the head and read
access to the tail and one side write access to the tail and read access to the
head). I would recommend watching Jens Axboe's talk in case you want to learn
more [1].

Diving deeper into different modes of io_uring we discussed its relevance within
a time of more and more CPU security vulnerabilities being discovered. Given
that mitigations have an impact on system call speed [2], one appreciates a I/O
interface that (in the best case) can do zero-sys-call I/O.

From there on we covered different projects adopting or looking into io_uring
for their I/O workloads, e.g. ScyllaDB, RocksDB, Golang [5] and of course Sled.
We looked into Rio, Tylers `io_uring` library [4] and how it leverages Rust's
lifetime checker (all happening at compile time) to make sure resources shared
with the kernel (filedescriptors, buffers) are not freed before the
corresponding system call completed (e.g. see [6] with its lifetime bounds).

A general resource worth sharing mentioned during the session is Mark
Callaghan's blog around database internals [3].

While last time we had the bright idea of TCP sequence numbers actually just
being CRDTs, the best quote of this session might be user space programs just
being DSLs on top of sys calls, eventually mostly replaced by BPF.


---

## References

[1]
https://www.slideshare.net/ennael/kernel-recipes-2019-faster-io-through-iouring

https://www.youtube.com/watch?v=-5T4Cjw46ys

[2]
http://www.brendangregg.com/blog/2018-02-09/kpti-kaiser-meltdown-performance.html

[3] https://smalldatum.blogspot.com/

[4] https://github.com/spacejam/rio

[5] https://github.com/golang/go/issues/31908

[6]
https://github.com/spacejam/rio/blob/df2237dfbccf552d56b71369c1da009c7f4934eb/src/io_uring/uring.rs#L110

[7] https://github.com/spacejam/sled
