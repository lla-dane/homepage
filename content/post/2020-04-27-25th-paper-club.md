---
date: 2020-04-27T00:00:00Z
tags: [tech, paper, distributed-systems, networking, queuing]
title: 25th DistSys Reading Group - Fair queuing

---

In the session today we covered Madhavapeddi Shreedhar and George Varghese paper
"*Efficient fair queuing using deficit round-robin*" [1]. While the session was
not so much about the relatively simple algorithmic details of
deficit-round-robin (still worth checking out) we talked about:

- Its benefits over basic FIFO queuing and thus its impact for congestion
  controlled traffic (tcp) compared to not congestion controlled traffic (udp).

- Its wide deployment still seen today.

- Its derivatives DRR+ and DRR++ being able to handle both best-effort as well
  as latency critical flows.


For those interested here are sources mentioned during the session:

- The insane amount of different queuing disciplines [a modern Linux kernel
  supports](https://github.com/torvalds/linux/tree/master/net/sched).

- The [random early detection
  (RED)](https://en.wikipedia.org/wiki/Random_early_detection) queuing
  discipline for routers (not keeping state per flow but) dropping packets
  before the buffer limit is reached in order to signal congestion to loss-based
  congestion control algorithms.

  


Next up we will talk about cache coherence protocols.


---


## References

[1] Shreedhar, Madhavapeddi, and George Varghese. "Efficient fair queuing using
deficit round-robin." IEEE/ACM Transactions on networking 4.3 (1996): 375-385.

https://www2.cs.duke.edu/courses/spring09/cps214/papers/drr.pdf
