---
date: 2020-09-08T00:00:00Z
tags: [tech, paper, distributed-systems, consensus, blockchain, byzantine]
title: 28th DistSys Reading Group - Hotstuff

---

With the 28th session we jumped into the space of byzantine fault tolerant
consensus protocols. We covered fault tolerant consensus with various Paxos
variants in the past, but this session was the first one looking into how to
solve the [byzantine generals
problem](https://en.wikipedia.org/wiki/Byzantine_fault).

Instead of using PBFT [1] as a first paper we went with Hotstuff [2] instead.
The reasoning behind this choice was (a) Hotstuff presenting a somewhat easy
up-to-date consensus algorithm and (b) that it provides a framework enabling one
to compare other algorithms (e.g. PBFT) in the space.

For those interested in learning more, I recommend to read the Hotstuff paper
[2] as well as watch the three talks by one of the authors Ittai Abraham.

- [ZK-TLV 0x09 - Ittai Abraham - The Bitcoin Breakthrough in the less of
  Distributed Computing (Part 1)](https://youtu.be/IUwsxssViqc)

- [ZK-TLV 0x09 - Ittai Abraham - State Machine Replication from traditional to
  modern (Part 2)](https://youtu.be/-RcYagFNyLU)

- [ZK-TLV 0x09 - Ittai Abraham - The HotStuff approach to BFT (Part
  3)](https://youtu.be/ONobI3X70Rc)

And finally here are the slides used in the reading group session.

https://hackmd.io/9QRReh_5RKmELVHZTE9HQA?view

---


## References

[1] Castro, Miguel, and Barbara Liskov. "Practical Byzantine
fault tolerance." OSDI. Vol. 99. No. 1999. 1999.

[2] Yin, Maofan, et al. "Hotstuff: Bft consensus in the lens of
blockchain." arXiv preprint arXiv:1803.05069 (2018).
