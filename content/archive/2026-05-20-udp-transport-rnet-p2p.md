---
title: "UDP transport layer for rnet-p2p"
tags: ["p2p", "rnet", "rust", "networking"]
date: 2026-05-20
---

Wrote a UDP transport layer for rnet-p2p -- connection management, handshake acknowlegements, and liveliness checks for dead peers (since no real time sockets in UDP).

Was fun.

*PR: https://github.com/lla-dane/rnet/pull/8*

*PS: rnet-p2p now moved here: https://github.com/rnet-stack/rnet-p2p*