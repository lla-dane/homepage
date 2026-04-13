---
title: "Ping RTT benchmarks b/w rnet and libp2p"
tags: ["p2p", "rnet", "rust", "networking", "libp2p"]
date: 2026-04-13
---

Did an RTT benchmark comparing my experimental p2p stack `rnet` vs libp2p

rnet → ~220–300μs
rust-libp2p → ~130–250μs
py-libp2p → ~300–400μs

Same machine, loopback
libp2p: TCP + Noise + Yamux
rnet: TCP + custom security (Deffie-Hellman based key-exchange) + Mplex

rnet lagging behind by ~60μs implementation overhead from rust-libp2p

_rnet: https://github.com/lla-dane/rnet/_