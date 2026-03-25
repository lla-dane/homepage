---
title: Build Logs
type: post
---

[**__Github__**](https://github.com/lla-dane) | [**__Linkedln__**](https://www.linkedin.com/in/abhinav-agarwalla-a80425258/) | [**__Twitter__**](https://x.com/lla_dane)

## Open Source: 

- [**__Libp2p(-py)__**](https://github.com/libp2p/py-libp2p): The Python implementation of the libp2p networking stack.
--

    **Pull Requests**: 
    - Prometheus metrics for libp2p protocols: [**#1199**](https://github.com/libp2p/py-libp2p/pull/1199)
    - Add TLS in the security options: [**#1085**](https://github.com/libp2p/py-libp2p/pull/1085)
    - Auto-TLS support for py-libp2p: [**#1072**](https://github.com/libp2p/py-libp2p/pull/1072)
    - Improve Floodsub in PubSub module: [**#1064**](https://github.com/libp2p/py-libp2p/pull/1064)
    - Add pnet support with PSK-based connection wrapping: [**#1002**](https://github.com/libp2p/py-libp2p/pull/1002)
    - libp2p-record module in reference with go-libp2p-record: [**#890**](https://github.com/libp2p/py-libp2p/pull/890)
    - Signed-Peer-Record support in Pubsub/Gossipsub message transfer: [**#889**](https://github.com/libp2p/py-libp2p/pull/889)
    - Signed-Peer-Record support in KAD-DHT message transfer mechanism: [**#815**](https://github.com/libp2p/py-libp2p/pull/815)
    - TODO: throttle on async validators: [**#755**](https://github.com/libp2p/py-libp2p/pull/755)
    - Introduce Certified-Address-Book interface for Peer-Store: [**#753**](https://github.com/libp2p/py-libp2p/pull/753)
    - Added tests for identify push concurrency cap under high peer load: [**#708**](https://github.com/libp2p/py-libp2p/pull/708) 
    - fix added negotiate timeout to MuxerMultistream: [**#696**](https://github.com/libp2p/py-libp2p/pull/696)
    - fix removed dummy ID(b) from upgrade_security for inbound connections: [**#681**](https://github.com/libp2p/py-libp2p/pull/681)
    - Updated examples to automatically use random port: [**#661**](https://github.com/libp2p/py-libp2p/pull/661)
    - Matching **py-libp2p <-> go-libp2p** PeerStore Implementation: [**#648**](https://github.com/libp2p/py-libp2p/pull/648)
    - TODO: Handle ls command in multiselect.py: [**#622**](https://github.com/libp2p/py-libp2p/pull/622)
    - TODO: Parse listen_addrs to set transport in build_swarm: [**#616**](https://github.com/libp2p/py-libp2p/pull/616)
	
---
- [**__py-multiaddr__**](https://github.com/multiformats/py-multiaddr): Multiaddr implementation for libp2p(-py)
--

  **Pull Requests**:
    - Add SNI, NOISE, CERTHASH, WEBRTC, WEBRTC-DIRECT in py-multiaddr: [**#97**](https://github.com/multiformats/py-multiaddr/pull/97)
    - Add garlic64 and garlic32 encoding in py-multiaddr: [**#96**](https://github.com/multiformats/py-multiaddr/pull/96)
    - Add ipcidr protocol in reference with go-multiaddr: [**#95**](https://github.com/multiformats/py-multiaddr/pull/95)
    - Add http-path protocol in reference with go-multiaddr: [**#94**](https://github.com/multiformats/py-multiaddr/pull/94)
    - Added memory protocol: [**#92**](https://github.com/multiformats/py-multiaddr/pull/92)

---
- [**__Floresta__**](https://github.com/getfloresta/Floresta) :- A lightweight and embeddable Bitcoin client, built for sovereignty.
--

    **Pull requests**: 
    - bug fix: remove inflights of banned peers: [**__#203__**](https://github.com/getfloresta/Floresta/pull/203)
    - Functional tests for floresta-wire/sync-node: [**__#200__**](https://github.com/getfloresta/Floresta/pull/200)
    - Bug fix: chain_selector: [**__#182__**](https://github.com/getfloresta/Floresta/pull/182)
    - Functional and unit tests for floresta-/* chain, watch-only and electrum: [**__#168__**](https://github.com/getfloresta/Floresta/pull/168)
    - Potential bug fix in floresta-wire/chain_selector.rs: [**__#179__**](https://github.com/getfloresta/Floresta/pull/179)

---
## Projects: 


1. [**__rnet__**](https://github.com/lla-dane/rnet): An experimental p2p networking stack for understanding rust and internal p2p mechanics.

    - Defined core P2P abstractions for peer identity, multiaddrs, connections, and stream-based protocol execution.
    - Implemented TCP transport and mplex-style stream multiplexing with concurrent logical streams.
    - Developed core protocols like floodsub with end-to-end peer-subscriptions, message propagation and deduplication.
    - Applied low-level async Rust patterns to manage IO, stream lifecycles, and protocol execution safely.

    *Repo: https://github.com/lla-dane/rnet*
---

2. [**__P2P-Federated-Learning__**](https://github.com/lla-dane/P2P-Federated-Learning):- A p2p federated learning stack built with **py-libp2p, Akave-O3 and Hedera hashgraph**.

	- P2P network was built using py-libp2p for discovery, pubsub, and job coordination.
	- Hedera smart contracts + Consensus Service were used for trustless payments and training state auditing.
	- Decentralized dataset/model transfer was done with Akave-O3 presigned URLs (no credential sharing).
	- An incentive flow is designed where compute providers train locally and earn verifiable rewards.
	
    *Repo: https://github.com/lla-dane/P2P-Federated-Learning*

---

3. [**__LoyaltyX__**](https://github.com/lla-dane/LoyaltyX):- An agentic AI-driven decentralized loyalty program platform on the Near blockchain.
	- Businesses register unique loyalty programs onchain via the LoyaltyX chatbot.
	- Customers can earn, track and redeem loyalty points onchain by interacting with the Al Agent.
	- Al-agent backend process user requests and executes the required onchian transactions.
	
    *Repo: https://github.com/lla-dane/LoyaltyX*

---

4. [**__Tx-Validator__**](https://github.com/lla-dane/Tx-Validator):- A Bitcoin transaction validation and block mining script from scratch in Rust.
	- Developed end-to-end Bitcoin block mining pipeline: tx-validation, merkle construction and PoW block header mining.
	- Implemented signature verification scripts for legacy and SegWit transaction types (P2PKH, P2SH, P2WPKH, P2WSH).
	- Prioritized transactions using fee/weight ratio for optimal block composition.
	- Constructed final block (~4M weight, ~21.6M sats fees, 4.4K txs) meeting target difficulty and Bitcoin serialization rules.
	
    *Repo: https://github.com/lla-dane/Tx-Validator*

---

## Hackathon Wins:
- **__P2P-Federated-Learning__**: A p2p federated learning platform build using py-libp2p, Akave O3 and Hedera Hashgraph. Won the Akave track (Filecoin bounty) at ETHGlobal NewDelhi'25.
	- *Showcase: https://ethglobal.com/showcase/p2p-fed-learning-ba4m0*
	- *Repo: https://github.com/lla-dane/P2P-Federated-Learning*

---
	
- **__Crowdnet__**: A decentralized event hosting plaform on the Vara Blockchain. Won the 1st prize in the beginner track in the Gear Mega Hackathon'25. 
	- *Twitter post: https://x.com/lla_dane/status/1879907556778475966*
	- *Repo: https://github.com/karankoder/CrowdNet*

---
	
- __**LendingSapphire**__: A private lending plaform leveraging on-chain and off-chain confedentiality leveraging Oasis's ROFL secure execution environments. Won a 2nd prize in the Oasis bounty at ETHGlobal Singapore'24.
	- *Showcase: https://ethglobal.com/showcase/lendingsapphire-jrbsc*
	- *Repo: https://github.com/bhaveshg16/Lending-Sapphire*

---
	
-  __**FairBET**__: A security layer based on nillion's lind computation to mitigate malicious final result modifications, in online betting plaforms like Roulette, built over a decentralised roulette plaform. Won a 2nd prize in the Nillion Bounty at ETHOnline'24.
	- *Showcase: https://ethglobal.com/showcase/fairbet-ejims*
	- *Repo: https://github.com/aaravm/FairBET*

---
	
-  **__InstaClaim__**: An instant insurance claim platform using CDP Agent kit + Lit Protocol (for decentralized encrypt/decrypt). Won a pool prize in the Lit Protocol bounty it ETHIndia'24.
	- *Showcase: https://devfolio.co/projects/instaclaim-0bba*
	- *Repo: https://github.com/asmit27rai/Instaclaim*

--- 
	
## Dev Blogs: 
at *https://soishell.hashnode.dev/*

-  [**__Contributions to py-libp2p as a part of PLDG Cohort-3__**](https://soishell.hashnode.dev/what-i-built-in-py-libp2p-during-pldg-cohort-3): A curated documentation on the various protocols I contributed on for 3 months in py-libp2p p2p networking library as a part of Protocol-Labs-DEV-Guild (PLDG) Cohort-3.

---

- [**__Building a Covert LAN: Dockerized Wireguard VPN Gateway for Private Container Access__**](https://soishell.hashnode.dev/building-a-covert-lan-dockerized-wireguard-vpn-gateway-for-private-container-access): Established a secure, private network by integrating Wireguard VPN with Docker container services to ensure exclusive access through encrypted VPN connections.

---

- [**__Automated Firewall Management using Docker and Cron__**](https://soishell.hashnode.dev/automated-firewall-management): Simulating automated firewall configuration using Docker, cron jobs, and UFW to ensure consistent security policies across multiple server roles.

---

- [**__Implementing Blind Computations using Nillion Protocol__**](https://soishell.hashnode.dev/implementing-blind-computations-using-nillion-protocol): A comprehensive guide on how to implement blind computations (computing on encrypted variables without ever decrypting them) using Nillion protocol.

---

- [**__Improve Floresta's testing: Part 2 | Summer of Bitcoin '24__**](https://soishell.hashnode.dev/improve-florestas-testing-part-2-summer-of-bitcoin-24): This blog covers the progress of my Summer of Bitcoin porject - Improve Floresta's testing. 

---

- [**__Improve Floresta's testing: Part 1 | Summer of Bitcoin '24__**](https://soishell.hashnode.dev/improve-floresta-testing-part1): This blog covers the progress of my Summer of Bitcoin project till mid-evaluation; Improve the testing environment of Floresta.