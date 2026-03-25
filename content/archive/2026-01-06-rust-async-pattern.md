---
date: 2026-01-06T00:00:00Z
tags: ["rust"]
title: Rust async pattern -- single owner IO
---

Ran into an issue while building my experimental [p2p stack]() in Rust -- multiple parts of the code wanted `&mut TcpStream`. Turned out the design was improper. What worked for me was creating a single IO task owning the socket, with everything else communication via `mpsc`. Cleaner ownership, fewer borrow issues, and easier to reason about.