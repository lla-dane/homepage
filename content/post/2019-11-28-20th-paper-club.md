---
date: 2019-11-28T00:00:00Z
tags: [tech, paper, distributed-systems]
title: 20th Distributed Systems Paper Club

---

Last Tuesday we meet again to discuss different attacks and possible
countermeasures for distributed hash tables. More in particular we looked at
Kademlia and its security extension S/Kademlia [1], possible eclipse attacks on
the Ethereum network [2], a novel approach of hiding its own connection buckets
as well as using an existing social graph as a network topology in the Whanau
paper[3], security extensions to the Chord DHT [4], as well as a larger study of
different security techniques for DHTs [5].

The attacks mentioned in the papers go from the simple *identity stealing*, to
the well known *eclipse* and related *adversarial routing* attacks, *sybil*
attacks, *denial of service* and *churn* attacks as well as attacks on the *data
storage*.

While the *identity stealing* attack is easy to solve with the help of
public-key cryptography, most of the others are based on the fact that in
peer-to-peer networks there is no global trusted authority granting access, thus
generating new identities is cheap and fast. When introducing a central
authority is not an option, one can make identity generation harder by
introducing crypto puzzles [1], binding identities to IP addresses [2] or depend
on reputation systems.

Within a Kademlia DHT, queries converge towards the same path when searching for
a node or value. With this in mind an attacker would need to only control some
nodes at the right place within the key spectrum to control answers to queries
for a certain key range. The S/Kademlia [1] paper suggests to enforce disjoint
lookup paths making those *adversarial routing* attacks less likely to succeed.

> The evaluation of S/Kademlia in the simulation frame-work OverSim has shown,
> that even with 20% of adversar-ial nodes still 99% of all lookups are
> successful if disjointpaths are used

<small>For more info, see [1] directly.</small>

A countermeasure against *data storage* attacks would be to enforce that a given
key would always need to correspond to the hash of its value. While this makes
targeted storage requests a lot harder, it defeats the use case of the DHT as a
lookup service where the key is a known string not based on the value.

Instead when issuing a storage request, one can: (1) use the hash of the key to
enforce a uniform distribution and (2) send the plaintext key along with the
request as an attestation for proper hashing, making the generation of keys
within a certain range a lot harder.

---

[1] Baumgart, Ingmar, and Sebastian Mies. "S/kademlia: A practicable approach
towards secure key-based routing." 2007 International Conference on Parallel and
Distributed Systems. IEEE, 2007.

[2] Marcus, Yuval, Ethan Heilman, and Sharon Goldberg. "Low-Resource Eclipse
Attacks on Ethereum's Peer-to-Peer Network." IACR Cryptology ePrint Archive 2018
(2018): 236.

[3] Lesniewski-Laas, Christopher, and M. Frans Kaashoek. "Whanau: A sybil-proof
distributed hash table." (2010).

[4] Fiat, Amos, Jared Saia, and Maxwell Young. "Making chord robust to byzantine
attacks." European Symposium on Algorithms. Springer, Berlin, Heidelberg, 2005.

[5] Urdaneta, Guido, Guillaume Pierre, and Maarten Van Steen. "A survey of DHT
security techniques." ACM Computing Surveys (CSUR) 43.2 (2011): 8.
