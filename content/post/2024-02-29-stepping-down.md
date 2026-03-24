---
date: 2024-02-29
title: Stepping down as a (rust-) libp2p maintainer
tags: [tech, libp2p]
---

I don't see myself making major contributions to (rust-) libp2p in the near future and thus I am stepping down as a maintainer.

As announced before, [I have left Protocol Labs in December 2023](https://github.com/libp2p/rust-libp2p/discussions/5007).
After a 2 month re-orientation break, I have decided to move on entirely.

My first commit was 5y ago, [a small bug fix in our address handling](https://github.com/libp2p/rust-libp2p/pull/1204).
Since then lots happened. A couple of milestones I was involved in:

- First major contribution was an [implementation of S-Kademlia's disjoint paths](https://discuss.libp2p.io/t/s-kademlia-lookups-over-disjoint-paths-in-rust-libp2p/571).
  While a good first project, it was never deployed on any of the larger networks.
  Attacking a DHT is [not that hard](https://arxiv.org/pdf/2307.12212.pdf), making it secure takes a lot more than this.
- Eventually we added what one would expect every p2p library to have - support for hole punching.
  That was a huge effort.
  We rolled our own relay protocol, a custom coordination protocol, an address discovery protocol, ...
  Long story short, [we invented lots of new wheels](https://blog.ipfs.tech/2022-01-20-libp2p-hole-punching/).
  Really, we should have started off of [ICE](https://en.wikipedia.org/wiki/Interactive_Connectivity_Establishment).
  E.g. instead of designing our custom address discovery protocol, we should have learned early on from STUN and its past mistakes.
  This stuff is hard.
- rust-libp2p was long missing a QUIC transport implementation.
  [Eventually](https://github.com/libp2p/rust-libp2p/issues/2883) we were able to deliver this based on the quinn project, which I am very happy about, bringing lots of performance improvements to rust-libp2p users.
- I managed the [specification and implementation of WebRTC in libp2p](https://github.com/libp2p/specs/issues/220).
  While a great match for a p2p library, unfortunately up until today, it has not seen larger adoption.
- A tiny fraction of IPFS today is powered by [a rust-libp2p based IPFS bootstrap node](https://blog.ipfs.tech/2023-rust-libp2p-based-ipfs-bootstrap-node/) handling ~35k connections on a medium-sized machine.
- A major portion of my time in 2023 went into an [automated performance setup for the many libp2p implementations](https://github.com/libp2p/test-plans/blob/master/perf/README.md).
  The outcome in my eyes is both [visually appealing](https://observablehq.com/@libp2p-workspace/performance-dashboard) and impactful from a performance perspective (see final item).
- We shipped many developer experience improvements, taming some of the complexity inherent to peer-to-peer networking e.g. the [`SwarmBuilder`](https://github.com/libp2p/rust-libp2p/pull/4120).
- Security is hard, especially on the internet, doubly so when in a peer-to-peer setting.
  A lot of our work went into security fixes, especially around DOS attacks.
  See e.g. a [major memory exhaustion attack](https://github.com/libp2p/rust-libp2p/security/advisories/GHSA-jvgw-gccv-q5p8) and [a talk](https://max-inden.de/post/2022-11-02-dos-defense-dos-and-donts/) inspired by this work.
- Talking about talks, I gave [several](https://max-inden.de/tags/talk/) on peer-to-peer networking and libp2p as well as helped organize related conferences, e.g. the FOSDEM networking devroom.
- As a final big contribution, the before mentioned automated performance benchmark setup enabled me to land a major improvement to libp2p's bandwidth performance.
  Implementing [stream receive window auto-tuning in the Rust Yamux implementation](https://github.com/libp2p/rust-yamux/pull/176) improved throughput on high bandwidth connections from 33 Mbit/s to 1.3 Gbit/s.

During my time the rust-libp2p maintainer team went from 4 down to 1, up to 2, 3, back to 4, and now down to 1.
I hope for another positive trend to follow.
I enjoyed working with every maintainer, the larger libp2p team and the [many contributors](https://github.com/libp2p/rust-libp2p/graphs/contributors).
Thank you!
**None** of the above listed work would have been possible without you.
**None** of it I could have achieved on my own.
In the greater picture of the libp2p project, this list is negligeable, but probably fun for me to look back at in a couple of years from now. (:wave: hi future Max.)

For more stats:
- https://ossinsight.io/analyze/mxinden
- https://ossinsight.io/analyze/libp2p/rust-libp2p
- https://next.ossinsight.io/analyze/libp2p

I will stay subscribed to the repository for now to answer questions.
I assume some historic background will be useful from time to time.
Feel free to tag me.
In case my skillset is needed for larger work items, I am available on a project basis as a freelancer.
Just send me a mail.

What is next?
Don't know yet.
Probably open source, strongly typed, pushing bytes over the Internet.
