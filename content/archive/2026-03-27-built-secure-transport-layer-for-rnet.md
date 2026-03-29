---
title: "Built a secure transport layer for my p2p stack"
tags: ["p2p", "rnet", "rust", "networking"]
date: 2026-03-27
---

Built a secure transport layer today for my p2p stack. 

Raw streams -> negotiated -> encrypted (Deffie Hellman + ChaCha20Poly1305). 

Feels good seeing the pieces come together.

PR: https://github.com/lla-dane/rnet/pull/2