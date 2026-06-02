---
title: "MPC randomess generator on top of rnet-p2p"
tags: ["p2p", "rnet", "rust", "networking"]
date: 2026-05-20
---

Built a decentralized random number generator using multiparty-computation(MPC) on top of my own p2p stack, *[rnet-p2p](https://github.com/rnet-stack/rnet-p2p)*, over the weekend.

no trusted authority, no single point of bias, as long as 1 peer is honest, the output is unpredicatable.

commit -> reveal -> reduce

*Repo: https://github.com/rnet-stack/rnet-drand*