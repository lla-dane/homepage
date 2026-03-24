---
date: 2021-02-24T00:00:00Z
tags: [tech, paper, distributed-systems, bgp, internet, routing]
title: 31st DistSys Reading Group - BGP 1

---

We decided to turn our interest to BGP which we will devote 3 sessions to. In
today's session - the first one - we introduced BGP, looked at the convergence
problem, as well as the solution suggested in the paper below.

[Gao, Lixin, and Jennifer Rexford. "Stable Internet routing without global
coordination." IEEE/ACM Transactions on networking 9.6 (2001):
681-692.](https://www.cs.princeton.edu/~jrex/papers/sigmetrics00.long.pdf)

To play around with BGP as well as general Internet routing:

- Check out [Ripe Stat](https://stat.ripe.net/), e.g. the BGB activity for your
  IP prefix.

- Most ISPs provide a /Looking Glass/ service, allowing you to see how a packet
  would travel from any of the ISP's switches to a chosen destination. See
  [Hurricane Electrics' /Looking Glass/](https://lg.he.net/).


