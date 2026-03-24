---
date: 2020-04-06T00:00:00Z
tags: [tech, paper, distributed-systems, networking, congestion-control]
title: 24th DistSys Reading Group - BBR Congestion-Based Congestion Control

---


After a bit of a break due to current pandemic we decided to carry on and
continue our meetings as virtual calls. Ignoring the usual initial hiccups and
the missing whiteboard the medium worked well for us.

Topic and reading of this session was the ACM Queue article [*BBR:
Congestion-Based Congestion
Control*](https://queue.acm.org/detail.cfm?id=3022184) [1], as well as the
Dropbox article [*Evaluating BBRv2 on the Dropbox Edge
Network*](https://dropbox.tech/infrastructure/evaluating-bbrv2-on-the-dropbox-edge-network)
[2].

We started off with a quick recap of the previous session covering why we need
congestion control, how one can view a multi-hop connection as a single hop
connection with a single bottleneck and most importantly the fact that the
Internet is the largest distributed system that most of the time "just works"
due to congestion control.

The key takeaways are best understood through figure 1 of the ACM Queue article
[1]. A TCP connection can be in 3 states:

![Figure 1 ACM queue
article](https://dl.acm.org/cms/attachment/cd17ded0-a420-417e-a362-bce7964cea23/vanjacobson1.png)

- A connection starts off in the *app limited* stage where increasing the amount
  of inflight packets does not increase the round-trip-time.

- Once one surpases the *bandwidth delay product* one enters the *bandwidth
  limited* stage. With each additional packet inflight, the round-trip-time
  increases, given that the buffer length at the bottleneck grows.

- With reaching the limit of the buffer one enters the *buffer limited* stage.
  At this point packets are dropped and eventually packet loss is detected on
  the sender side.

Loss-based congestion control algorithms, as their name implies, operate based
on loss detection, thus they only act once going from *bandwidth limited* to
*buffer limited*. The key take-away and the novelty of BBR is that it does not
operate based on loss-detection, but rather on perceived round-trip-time and
bottleneck-bandwidth. With this mechanism BBR promises to operate closer to the
optimal - the *bandwidth delay product* - preventing packet-loss in the first
place instead of operating based on it.

For people wanting to dive deeper here is a list of resources mentioned during
the session:

- The IETF draft.

  https://tools.ietf.org/html/draft-cardwell-iccrg-bbr-congestion-control-00

- BBR uses ACKs to estimate round-trip-time and bandwidth. On Wifi ACKs can be
  aggregated, thus distorting these measurements. The below link shows the
  corresponding kernel patch tackling this issue.

  https://lore.kernel.org/netdev/20190123200454.260121-3-priyarjha@google.com/#t

- Following up on the concerns above there is a PacketPushers podcast covering
  the topic.

  https://packetpushers.net/podcast/heavy-networking-489-is-bbr-too-unfair-an-algorithm-for-the-internet/

- While BBR might work well for the connection itself, it is quite aggressive
  and thus can have an impact on loss-based congestion control algorithms like
  Rino. The following paper provides more details in section 4.C.2.

  https://www.net.in.tum.de/fileadmin/bibtex/publications/papers/IFIP-Networking-2018-TCP-BBR.pdf

For the next session we will stay within the realm of networking and talk about
packet scheduling and queuing in Linux and how one can implement QoS (Quality of
Service).


---


## References

[1] Cardwell, Neal, et al. "BBR: Congestion-based congestion control." Queue
14.5 (2016): 20-53.

https://queue.acm.org/detail.cfm?id=3022184

[2]
https://dropbox.tech/infrastructure/evaluating-bbrv2-on-the-dropbox-edge-network
