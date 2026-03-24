---
date: 2020-05-18T00:00:00Z
tags: [tech, paper, distributed-systems, CPU, cache]
title: 26th DistSys Reading Group - Cache coherence

---

We have long been planning to cover the caching mechanisms in CPUs. As a shared
knowledge base for the discussions in this session we chose the following two
articles by Martin Thompson among other things known for his work on the [LMAX
Disruptor](https://lmax-exchange.github.io/disruptor/):

- [CPU Cache Flushing
  Fallacy](https://mechanical-sympathy.blogspot.com/2013/02/cpu-cache-flushing-fallacy.html)
  including a good overview over the different caches in modern Intel CPUs.

- [Write
  Combining](https://mechanical-sympathy.blogspot.com/2011/07/write-combining.html)
  exemplifying the advanced mechanisms one can find in today's CPUs and how one
  can make use of them.

Below I am listing a couple of take-aways of the session as well as further
learning resources:

- As a rule of thumb with each cache level the access latency quadruples (L1
  1ns, L2 3ns, L3 12ns, DRAM 65ns).

- Tyler wrote [two great
  tools](https://github.com/sled-rs/sled-rs.github.io/blob/master/hardware_timing/)
  to show different CPU optimizations and and the impact of synchronization
  on your hardware. Make sure you have a Rust environment set up. You can run
  each of them via `cargo run --bin <name> --release`.

    - `increment`: Comparing different ways (volatile, volatile + release fence,
      volatile + seqcst fence, seqcst CAS, ...) of incrementing a counter 500
      million times thus showing the impact of the cache coherence protocol e.g.
      load & store buffer flushes.

    - `write_combining`: Enabling one to see the write combining optimization in
      action described by Martin Thompson in the [blog
      post](https://mechanical-sympathy.blogspot.com/2011/07/write-combining.html)
      mentioned above. Looking at the latency jumps one can estimate the *line
      fill buffer* length of ones CPU.

- During the session Tyler often showed excerpts from the Intel manuals, in particular:

    - Chapter 8 and 11 from the [Software developers
      manual](https://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-software-developer-system-programming-manual-325384.html).
      It is worth taking a look at the memory ordering section in 8.2.2.

    - [Optimization reference
      manual](https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-optimization-manual.pdf)

- CPUs expose a lot of performance metrics. On Linux and with Intel Sandy bridge
  CPUs one can take a look at [the corresponding Kernel
  subsystem](https://www.kernel.org/doc/html/v4.12/admin-guide/pm/intel_pstate.html).
