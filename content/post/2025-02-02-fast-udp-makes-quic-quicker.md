---
date: 2025-02-02
title: Talk "Fast UDP makes QUIC quicker - optimizing Firefox’s HTTP3 IO stack" @FOSDEM
tags: [tech, talk, quic, firefox]
---

I presented my recent work on Firefox's HTTP3/QUIC stack in the Network Devroom at FOSDEM 2025.

> QUIC is a new transport protocol on top of UDP, transporting a large portion of the Internet traffic today. UDP I/O performance is crucial for QUIC implementations, where e.g. system call overhead can significantly impact throughput at high network speeds. To improve QUIC throughput, Firefox is switching to a modern UDP IO stack in Rust, using mechanisms like recvmmsg, and GRO across Linux, Windows, and Android.
>
> This talk gives a high level overview of Firefox’s HTTP3 / QUIC / UDP stack, followed by a deep dive into the various performance improvements landing in Firefox. Learn how we are making Firefox even faster and how you too can leverage these techniques to optimize your application.

[Slides and recording](https://fosdem.org/2025/schedule/event/fosdem-2025-5449-fast-udp-makes-quic-quicker-optimizing-firefox-s-http3-io-stack/)
