---
date: 2020-02-18T00:00:00Z
tags: [tech, paper, distributed-systems]
title: 23rd Distributed Systems Paper Club

---

At the end of the previous session one of us suggested to dive into congestion
control algorithms. This has found a greater echo, thus the 23rd session covered
congestion control algorithms in general and TCP's Reno as well as TCP's Tahoe
in particular.

This weeks reading was:

1. Chapter 13 "TCP Reno and Congestion Management" from the comprehensive online
   book "An Introduction to Computer Networks" [1] from the Loyola University
   Chicago.

2. RFC #5166 "Metrics for the Evaluation of Congestion Control Mechanisms" [2]

Chapter 13 [1] gives a great introduction to *knee* and *cliff*,
*round-trip-time*, the optimal congestion window of /round-trip-time/ with no
load multiplied with the bandwidth, ... of a TCP connection. I doubt I could
summarize it any better than the online book does.

I have never considered the fact that a network cable could have a
non-negligible capacity until I read:

> On a 5,000 km fiber-optic link with a bandwidth of 10 Gbps, the round-trip
> transit capacity would be about 60 MB, or 60,000 1kB packets. [1]

We played through a sample scenario building up to a congested connection from
*A* to *B* via router *R*, keeping track of the packets send, the inflight
packets, the congestion-window size and the packets within *R*'s queue at each
time *t*. This is definitely worth doing for both TCP *Reno* as well as well as
*Tahoe* showing the benefits of its *fast retransmit* feature.

We finished with a quick introduction to IP's ECN [3] and its interworking with
TCP. Next up we will talk about the congestion control algorithms CoDel [4] and
BBR.


---

## References

[1] http://intronetworks.cs.luc.edu/current/html/reno.html

[2] https://tools.ietf.org/html/rfc5166

[3] https://en.wikipedia.org/wiki/Explicit_Congestion_Notification

[4] https://en.wikipedia.org/wiki/CoDel
