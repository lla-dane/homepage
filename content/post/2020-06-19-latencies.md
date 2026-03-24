---
date: 2020-06-19T00:00:00Z
tags: [tech, CPU, cache, networking, performance]
title: Know your latencies

---

I find it helpful to know the orders of magnitude by which certain computer
operations differ. Certainly it is not worth the effort to pay attention to
every digit or learn these by heart, especially since they differ (slightly)
across systems, but having a basic understanding of what a tiny fraction of time
a CPU cycle occupies compared to sending a TCP packet is incredibly helpful
whenever reasoning about systems performance.

With the above in mind, below I am citing a list of metrics that proved useful
in the past.

*Keep in mind that these numbers represent estimates. They will most certainly
not match your machine's performance by the digit, but they will by the orders
of magnitude.*


| Operation                                 | Latency   | Source |
| ----------------------------------------- | --------- | ------ |
| **Nanoseconds**                           |           |        |
| CPU cycle                                 | 0.3 ns    | [1]    |
| Level 1 cache access                      | 0.9 ns    | [1]    |
| Level 2 cache access                      | 2.8 ns    | [1]    |
| Level 3 cache access                      | 12.9 ns   | [1]    |
| Mutex lock/unlock                         | 25 ns     | [2]    |
| Main memory access                        | 120 ns    | [1]    |
| **Microseconds**                          |           |        |
| Kernel context switch                     | 1-2 μs    | [4]    |
| Ping on localhost                         | 50 μs     | [1]    |
| Solid-state disk I/O                      | 50–150 μs | [1]    |
| Ping same subnet via 10 GBit              | 200 μs    | [1]    |
| **Milliseconds**                          |           |        |
| Rotational disk I/O                       | 1–10 ms   | [1]    |
| Ping same subnet via Wifi                 | 3 ms      | [1]    |
| Internet: San Francisco to New York       | 40 ms     | [1]    |
| Internet: San Francisco to United Kingdom | 81 ms     | [1]    |
| Internet: San Francisco to Australia      | 183 ms    | [1]    |


### Atomic operations

I have deliberately not included latencies for atomic operations here as those
heavily depend on the CPU architecture, the MESI state of the cache line,
whether it is shared across cores or even sockets, the bus speed, memory speed,
... I would like to refer those curious for more to the paper *"Everything You
Always Wanted to Know About Synchronization but Were Afraid to Ask"* [3].


---

### References

[1] Gregg, B. (2013). Systems performance: enterprise and the cloud. Pearson
Education.

[2] Dean, Jeff, and P. Norvig. "Latency numbers every programmer should know."
(2012). http://norvig.com/21-days.html#answers

[3] David, Tudor, Rachid Guerraoui, and Vasileios Trigonakis. "Everything you
always wanted to know about synchronization but were afraid to ask." Proceedings
of the Twenty-Fourth ACM Symposium on Operating Systems Principles. ACM, 2013.

[4]
https://eli.thegreenplace.net/2018/measuring-context-switching-and-memory-overheads-for-linux-threads/
