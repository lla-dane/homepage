---
date: 2019-10-27T00:00:00Z
tags: [tech, paper, distributed-systems]
title: 19th Distributed Systems Paper Club

---

I have been organizing a distributed systems paper reading group in Berlin for
the last year. We meet every other week discussing a paper in the distributed
systems space. This could be anything from *Chandy–Lamport's algorithm for
global distributed snapshots* [1] to things like *conflict free replicated
datatypes* [2]. The event is open for anyone interested. I only ask people to
come prepared.

In the last meeting (19th) we covered distributed hash tables. They play a
crucial role in e.g. decentralized file sharing networks for example as
directory services, simple key-value stores, or peer-to-peer membership
management protocols.

Given its simplicity and wide spread industry adoption we chose to cover the
distributed hash table *Kademlia* [3]. I doubt I would do a better job
explaining the concepts then the paper does, thus I recommend giving the paper
itself a read.

Libp2p [4], a peer-to-peer networking library, implements the *Kademlia* paper
with a couple of extensions. Multiple maintainers of the project attended the
meeting sharing insights on implementation challenges like the suggested routing
table optimizations.


For the next meeting we might stay within the Kademlia realm and look at
different follow up papers covering its security aspects in byzantine
environments [5] [6].

---

[1] Chandy, K. Mani, and Leslie Lamport. "Distributed snapshots: Determining
global states of distributed systems." ACM Transactions on Computer Systems
(TOCS) 3.1 (1985): 63-75.

[2] Shapiro, Marc, et al. "A comprehensive study of convergent and commutative
replicated data types." (2011).

[3] Maymounkov, Petar, and David Mazieres. : A peer-to-peer information system
based on the xor metric." International Workshop on Peer-to-Peer Systems.
Springer, Berlin, Heidelberg, 2002.

[4] https://github.com/libp2p/rust-libp2p/

[5] Baumgart, Ingmar, and Sebastian Mies. "S/kademlia: A practicable approach
towards secure key-based routing." 2007 International Conference on Parallel and
Distributed Systems. IEEE, 2007.

[6] Marcus, Yuval, Ethan Heilman, and Sharon Goldberg. "Low-Resource Eclipse
Attacks on Ethereum's Peer-to-Peer Network." IACR Cryptology ePrint Archive 2018
(2018): 236.
