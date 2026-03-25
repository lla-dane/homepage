---
date: 2026-02-02T00:00:00Z
tags: ["libp2p", "tls", "protocol", "p2p", "opensource"]
title: Introduced AutoTLS in libp2p(-py)
---

Extended the TLS security module in libp2p(-py) to fetch CA authorized TLS certificates using the [libp2p Auto-TLS client specification](https://github.com/libp2p/specs/blob/master/tls/autotls-client.md), rather than using self-signed ones.

This will enable protocol execution via web-transport and browsers for libp2p(-py).

PR: https://github.com/libp2p/py-libp2p/pull/1072

