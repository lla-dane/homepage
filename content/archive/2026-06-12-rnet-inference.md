---
title: "P2P swarm-inference engine over SLMs"
tags: ["p2p", "rnet", "rust", "networking"]
date: 2026-06-12
---

built a p2p swarm inference engine over SLMs.

- users broadcast a prompt
- nodes join dynamically as executors (generators) or verifiers (score)
- peer-ranked consensus
- highest avg response wins

Used  floodsub as the pubsub router over my own rnet-p2p stack.

similar space to what @fortytwonetwork is doing at scale.

*Repo - https://github.com/rnet-stack/rnet-inference*