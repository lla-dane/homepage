---
date: 2021-03-07T00:00:00Z
tags: [tech, networking, TCP, congestion-control]
title: Optimizing Yamux Flow Control - Sending Window Update Frames Early
---

Below is a summary of our efforts to optimize flow control in the [Rust Yamux
implementation](https://github.com/paritytech/yamux). While not a novel
approach, I still find the end result worth sharing thus my forum post.

https://discuss.libp2p.io/t/optimizing-yamux-flow-control-sending-window-update-frames-early/843
