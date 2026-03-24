---
title: Resume
author: Abhinav Agarwalla
---

## Experience

### Contributor to Libp2p(-py) networking stack

May 2025 - now

- 22 pull requests to [github.com/libp2p/py-libp2p](https://github.com/libp2p/py-libp2p) and [github.com/multiformats/py-multiaddr](https://github.com/multiformats/py-multiaddr).
- Alligned [`PeerStore`](https://github.com/libp2p/py-libp2p/pull/648) and [`record handling`](https://github.com/libp2p/py-libp2p/pull/890) with go-libp2p specifications, improving protocol correctness and interoperability.
- Introduce peer autenticity mechanisms, including [`Certified-Address-Book`](https://github.com/libp2p/py-libp2p/pull/753) and `signed-peer-records`, integrated across [`PubSub`](https://github.com/libp2p/py-libp2p/pull/889) and [`Kademlia DHT`](https://github.com/libp2p/py-libp2p/pull/815) message propagation.
- Expanded multiaddr protocol support in [`WebRTC, Noise`](https://github.com/multiformats/py-multiaddr/pull/97), [`garlic`](https://github.com/multiformats/py-multiaddr/pull/96), [`ipcidr`](https://github.com/multiformats/py-multiaddr/pull/95), [`http-path`](https://github.com/multiformats/py-multiaddr/pull/94), improving compatibility with mordern libp2p transports.
- Extended security and transport layers with Auto-TLS support, and PSK-based private networking (`pnet`). See [#1072](https://github.com/libp2p/py-libp2p/pull/1072) and [#1002](https://github.com/libp2p/py-libp2p/pull/1002).
- Introduce [`Prometheus metrics`](https://github.com/libp2p/py-libp2p/pull/1199) to the core services, improving network oberservability.

### Summer of Bitcoin Fellow - Floresta (Bitcoin Client)

May 2024 - August 2024

- Expanded the testing infra of [`Floresta`](https://github.com/getfloresta/Floresta), a lighweigt and embeddable Bitcoin client.
- Built tests for [`floresta-wire`](https://github.com/getfloresta/Floresta/pull/202) and [`sync-node`](https://github.com/getfloresta/Floresta/pull/200) including functional and stress tests for `p2p` and [`Electrum services`](https://github.com/getfloresta/Floresta/pull/168).
- Improved node reliability adn sync correcteness by fixing issues in [`chain-selection`](https://github.com/getfloresta/Floresta/pull/179) and [`peer-management`](https://github.com/getfloresta/Floresta/pull/203).
- Validated end-to-end behavior across `chain`, `watch-only wallets`, and `Electrum bridge` components.

## Projects

- Building an experimental p2p networking stack, [`rnet`](https://github.com/lla-dane/rnet), with core abstractions (`peer-identity`, `multiaddr`, `streams`) with `TCP` transport and `mplex`-style multiplexing, enabling concurrent protocol execution and end-to-end `Floodsub` message propagation.
- Built a [`p2p-federated-learning`](https://github.com/lla-dane/P2P-Federated-Learning) stack, combining `libp2p` networking with `Hedera` consensus and `Akave-O3` storage, enabling trustless coordination, incentives and secure dataset/model exchange without credential sharing.
- Built an agent-driven on-chain [`loyalty platform`](https://github.com/lla-dane/LoyaltyX) on `NEAR`, integrating AI-based user interaction with automated smart contract execution for program creation, reward tracking and redemption.
- Wrote an end-to-end [`bitcoin block contruction pipeline`]() in `rust` supporting full transaction validation (`P2PKH`, `P2SH`, `P2WPKH`, `P2WSH`), `merkle-tree` construction, and `PoW` mining, producing valid `~4M` weight blocks with optimized fee selection.


## Hackathons

- [**P2P-Federated-Learning**](https://github.com/lla-dane/P2P-Federated-Learning), a decentralized ML training network built with *libp2p*-based coordination, *Akave-O3* storage and on-chain incentives; [**won Akave/Filecoin track at ETHGlobal New Delhi (2025)**](https://ethglobal.com/showcase/p2p-fed-learning-ba4m0).
- [**Crowdnet**](https://github.com/karankoder/CrowdNet), a decentralized event hosting platform on *Vara blockchain* win on-chain coordinaction and user-interaction; [**won 1st place (Beginner Track), Gear Mega Hackathon (2025)**](https://x.com/lla_dane/status/1879907556778475966).
- [**LendingSapphire**](https://github.com/bhaveshg16/Lending-Sapphire), a privacy-preserving lending protocol using *Oasis confidential compute (ROFL)* for secure on/off-chain execution; [**won 2nd prize (Oasis Track), ETHGlobal Singapore (2024)**](https://ethglobal.com/showcase/lendingsapphire-jrbsc).
- [**InstaClaim**](https://github.com/asmit27rai/Instaclaim), an instant insurance claim system using *CDP AgentKit and Lit Protocol* for decentralized encryption; [**won pool prize (Lit Protocol), ETHIndia (2024)**](https://devfolio.co/projects/instaclaim-0bba).
- [**FairBET**](https://github.com/aaravm/FairBET), a decentralized security layer for gambling based platforms using *Nillion* blind computations to prevent result manipulation; [**won 2nd prize (Nillion Track), ETHOnline (2024)**](https://ethglobal.com/showcase/fairbet-ejims).

## Education

**Bachelor at IIT Varanasi** | 2022 - 2027

Bachelor of Technology (B.Tech) in Mathematics and Computing at Indian Institute of Technology, Varanasi.


