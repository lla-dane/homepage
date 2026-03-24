---
date: 2020-01-24T00:00:00Z
tags: [tech, paper, distributed-systems, epidemic, gossip, protocol]
title: 21st Distributed Systems Paper Club

---

We started the new year with a session on *epidemic* / *gossip* protocols. To
decide what to read I compiled the following list of papers that I either
enjoyed reading in the past, or that were recommended to me. The *Swim (Scalable
failure detection and membership protocol)* paper won the poll.

> Das, Abhinandan, Indranil Gupta, and Ashish Motivala. "Swim: Scalable
> weakly-consistent infection-style process group membership protocol."
> Proceedings International Conference on Dependable Systems and Networks. IEEE,
> 2002.
>
> https://www.cs.cornell.edu/projects/Quicksilver/public_pdfs/SWIM.pdf

I have first gotten into touch with *Swim* through [Hashicorp's
Memberlist](https://github.com/hashicorp/memberlist), given that it is the
underlying protocol implementation of [Prometheus
Alertmanager's](https://github.com/prometheus/alertmanager/) high availability
architecture, which I was maintaining in the past. The implementation in itself
is not based on *Swim* but *Lifeguard*, a follow up paper published by Hashicorp
[2].

Trying to summarize a couple of discussions of the session, we first talked
about the general use cases of group membership protocols (e.g. Multicast,
gossip, databases, pub/sub or gaming) and the trade offs one has to make within
such protocols (e.g. latency vs. message load, decentralization vs. complexity,
false negative vs. false positive rate).

Quickly we digressed talking about possible improvements e.g. leveraging vector
clocks or inverted bloom filters to implement pull based membership updates,
instead of push-based updates, alternative architectures, weighting information
density higher than message load overhead, e.g. by forming multiple connected
graphs between nodes (see Microsoft's Pingmesh [1]).

Given that we have talked a bunch about CRDTs in the past, there is always a
mandatory *How would we implement this as a CRDT* discussion, ending up as
*Whether the TCP packet sequence number would be a valid CRDT* (majority tended
towards 'yes').

At first I was a bit surprised by the stats the paper publishes on high failures
raids on 10 % packet loss. Given that *Swim* involves roundtrips within certain
protocol steps these failure rates accumulate thus 10% packet loss within a
local-area-network is quite significant and a valid excuse for SWIM not to build
full membership groups. To quickly recover from such scenarios it might be worth
introducing an additional anti-entropy process to do periodic full-state syncs
between nodes like done in Hashicorp's advanced *SWIM* - *Lifeguard* [2].


### Alternative Papers



#### Combining the resilience of gossip networks with the efficiency of tree-based broadcast.

Leitao, Joao, Jose Pereira, and Luis Rodrigues. "Epidemic broadcast trees." 2007
26th IEEE International Symposium on Reliable Distributed Systems (SRDS 2007).
IEEE, 2007.

https://www.gsd.inesc-id.pt/~ler/docencia/rcs1617/papers/srds07.pdf


#### Proximity aware tree based multicast.

Tang, Chunqiang, Rong N. Chang, and Christopher Ward. "GoCast: Gossip-enhanced
overlay multicast for fast and dependable group communication." 2005
International Conference on Dependable Systems and Networks (DSN'05). IEEE,
2005.

http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.75.4811&rep=rep1&type=pdf


#### Paper laying the foundation of epidemic (gossip) communication in 1988.

Demers, Alan, et al. "Epidemic algorithms for replicated database maintenance."
ACM SIGOPS Operating Systems Review 22.1 (1988): 8-32.

http://bitsavers.informatik.uni-stuttgart.de/pdf/xerox/parc/techReports/CSL-89-1_Epidemic_Algorithms_for_Replicated_Database_Maintenance.pdf



#### Reducing network bandwidth through efficient set reconciliation in
peer-to-peer networks.

Ozisik, A. Pinar, et al. "Graphene: efficient interactive set reconciliation
applied to blockchain propagation." Proceedings of the ACM Special Interest
Group on Data Communication. ACM, 2019.

https://people.cs.umass.edu/~gbiss/graphene.sigcomm.pdf


#### Algorithm to maintain reliable partial views in gossip networks.

Leitao, Joao, José Pereira, and Luis Rodrigues. "HyParView: A membership
protocol for reliable gossip-based broadcast." 37th Annual IEEE/IFIP
International Conference on Dependable Systems and Networks (DSN'07). IEEE,
2007.

http://asc.di.fct.unl.pt/~jleitao/pdf/dsn07-leitao.pdf


---

## References


[1] Guo, Chuanxiong, et al. "Pingmesh: A large-scale system for data center
network latency measurement and analysis." ACM SIGCOMM Computer Communication
Review. Vol. 45. No. 4. ACM, 2015.

https://www.microsoft.com/en-us/research/wp-content/uploads/2016/11/pingmesh_sigcomm2015.pdf


[2] Dadgar, Armon, James Phillips, and Jon Currey. "Lifeguard: Swim-ing with
situational awareness." CoRR (2017).

https://www.researchgate.net/profile/Jon_Currey/publication/318205535_Lifeguard_SWIM-ing_with_Situational_Awareness/links/59a46993aca272a6461bc263/Lifeguard-SWIM-ing-with-Situational-Awareness.pdf



