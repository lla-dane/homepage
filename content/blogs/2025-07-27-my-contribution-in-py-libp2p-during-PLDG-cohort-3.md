---
date: 2025-07-27T00:00:00Z
title: Contributions in libp2p(-py) in PLDG Cohort-3
---

> Hey folks **👋**,  
> Over the past few months, I’ve been diving deep into the internals of py-libp2p - the python implementation of the libp2p networking stack. I joined in this project on PLDG cohort-3 mostly out of curiosity: what does it really take to make peer-to-peer systems talk to each other? Turns out… a fair bit.  
> This blog is a casual walkthrough of what I’ve have been working on — things like getting Python node to talk with Rust peers, cleaning up old TODOs in the codebase, and helping refactor core modules like the PeerStore. If you’re curious about open source, P2P protocols, or python networking internals, this should be an interesting read.  
> I’ll skip the heavy theory (for the most part) and just talk about the work, the weird bugs, what I learned, and where it’s all going. Let’s get into it.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1753620337100/67ca88bd-a18f-46cd-b99b-6346c72303aa.webp align="center")

# Introduction

Py-libp2p is the **Python implementation of the libp2p networking stack**, part of the broader libp2p ecosystem originally modularized out of IPFS to support peer-to-peer systems like Ethereum, Filecoin, and decentralized apps across languages like Go, Rust, JavaScript, and more.  
Designed to be modular and protocol-agnostic, libp2p abstracts transport (TCP), multiplexing, peer identification, security handshakes (Noise, TLS), and pub-sub mechanisms (Floodsub, Goosipsub) into reusable building blocks. Although still experimental, py-libp2p is steadily progressing toward feature parity with other mature implementations.

[https://github.com/libp2p/py-libp2p](https://github.com/libp2p/py-libp2p)  
[https://github.com/libp2p](https://github.com/libp2p)

# Background & Context

Originally libp2p was developed for **IPFS and Filecoin**, its now used across a range of protocols and projects. Most real-world deployment use the Go or Rust implementations of libp2p. But the python version — py-libp2p — plays a crucial role in bridging the ecosystem to Python-based tooling, prototyping, and intergration with other Python-native libraries. Its specially useful in research, rapid experimentation, and educational contexts.

[https://github.com/libp2p/rust-libp2p](https://github.com/libp2p/rust-libp2p)  
[https://github.com/libp2p/go-libp2p](https://github.com/libp2p/go-libp2p)

When I started contributing to py-libp2p, the project was in an interesting place. While it had the basic structure of a libp2p stack — transports, peerstore, protocols like ping and identify — it still lacked full compatibility with other languages implementations. There were various rough edges, partial implementations in the **PeerStore**, and TODOs that made it a long way from a production grade software or even in interop testing.  
At the same time, the libp2p ecosystem was putting more focus on **cross-language compatibility,** especially as more protocols aim to support mixed stacks (eg. a Rust node communicating with a Python client). Getting Python to “**speak libp2p**“ the same way Go or Rust does mean closing a bunch of gaps — both in code and in design alignment.  
That’s where my work started.

# Core Contribution Areas

## Advancing py-libp2p <-> rust-libp2p Interoperability

[https://github.com/libp2p/py-libp2p/pull/620](https://github.com/libp2p/py-libp2p/pull/620)  
[https://github.com/libp2p/py-libp2p/discussions/598#discussioncomment-13420717](https://github.com/libp2p/py-libp2p/discussions/598#discussioncomment-13420717)

One of my major contributions was working toward establishing successful **Ping interoperability between** **py-libp2p and rust-libp2p** implementations. This work was crucial for ensuring that Python-based libp2p applications can communicate seamlessly with Rust-based ones.

**Key achievements:**

*   **Ping Protocol Interoperability:** Successfully made ping interop happen between py-libp2p and rust-libp2p using Noise security and Yamux multiplexing.
    
*   **Protocol negotiation -** Select negotiation that were preventing successful cross-implementation communication.
    

**Technical challenges:**

*   **Stream Protocol Issues:** Initially, protocol negotiation was failing after security and muxer negotiation. The py-dialer could write `/multistream/1.0.0` but couldn’t read responses from rust nodes.
    
*   **Key encoding Compatibility:** Addressed mismatches in how cryptographic keys were being encoded/serialized between implementations in the **Noise** security module.
    

Ping Interop successful demo:

%[https://vimeo.com/1104887674?share=copy] 

## Systematic TODO and FIXME Resolution

One of the biggest contributions I made early on was just rolling up sleeves and going after a bunch of long-standing TODOs and FIXMEs scattered across the codebase. These weren’t just minor style fixes — many of them touched core parts of py-libp2p’s functionality, from protocol negotiation to stream handling to security logic.

Here are some of the key things I tackled:

### 🔄 Protocol Negotiation: Handling `ls` command before connection happens

PR: [https://github.com/libp2p/py-libp2p/pull/622](https://github.com/libp2p/py-libp2p/pull/622)

I added a support for the `ls` command in the multistream-select handshake logic (in `multiselect.py`). This lets a dialer ask the listener, *“Hey, what protocols do you support?“* — which is a standard part of libp2p’s connection upgrade flow, but was missing in the Python version. Without it, protocol negotiation with other implementations (like Rust and Go) was pretty fragile.

Screenshot:

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1753624416760/b4afa3aa-69f1-4d86-86af-c092f065d74b.png align="center")

### 🔐 Security Layer: Real Peer IDs Only

PR: [https://github.com/libp2p/py-libp2p/pull/6](https://github.com/libp2p/py-libp2p/pull/622)81

In the security handshake code `upgrade_security`, there was a sketchy placeholder that used a dummy peer ID `ID(b””)` when establishing inbound connections. I fixed that by making `peer_id` optional and explicitly handling the inbound/outbound case. This not only removed the FIXME but also cleaned up the semantics of the API

### ⚙️ Concurrency and Timeout

While digging through some of the more subtle runtime behavior in py-libp2p, I noticed a couple of rough edges around concurrency that could easily become major pain points, especially as the number of peers grows.

**🔒 Async Validator Throttling**  
PR: [https://github.com/libp2p/py-libp2p/pull/](https://github.com/libp2p/py-libp2p/pull/622)755

The validator subsystem, especially in the context of the DHT or identify porotocol, can end up running many validations concurrently — for example, when a node is receiving a high volume of peer records or signed data. There was not mechanism in place to cap how many async validators could run at once, which made it vulnerable to resource exhaustion, especially in tests that simulate high peer churn.

To fix this, I introduced a **semaphore-based throttle** that limits how many async validators can run at the same time. This makes the system far more predictable under load. Instead of hitting weird trio warnings or memory bloat, you now get backpressure — which is exactly what you want in a peer-to-peer system under stress.

The mechanism looked something like this:

```python
class PubSub:
    def __init__(self, max_concurrent_validators=MAX_CONCURRENT_VALIDATORS):
        self._validator_semaphore = trio.Semaphore(max_concurrent_validators)
    
    async def _run_async_validator(self, func, msg_forwarder, msg, results):
        async with self._validator_semaphore:
            result = await func(msg_forwarder, msg)
            results.append(result)
```

**⏱️ Timeout on Stream Closures**

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1753620384021/ec720b83-58c3-4b85-bc67-50a34dc6f139.gif align="center")

PR: [https://github.com/libp2p/py-libp2p/pull/6](https://github.com/libp2p/py-libp2p/pull/622)96

Another issue was with **stream closure logic**. In a few places, especially where streams were being shut down as part of connection teardown or during tests, there was no timeout — which meant that if anything hung internally (e.g. a stalled read or write), the whole operation could get stuck indefinitely. That’s brutal during testing, and worse in a live node.

So I added proper timeouts using `trio.fail_after(5)` during stream close and shutdown phases. It’s a small change, but it makes the system way more resilient. Now if a stream doesn’t cleanly shut down within a few seconds, the code doesn’t hang — it just fails fast and continues with cleanup.

*These kinds of changes are less flashy at the protocol-level work, but they’re critical for making the stack actually usable in the rea-world conditions. You don't want your node falling over bacause 200 peers showed up or because one stream forgot to say goodbye.*

## 🧠 Refactoring the PeerStore: Making py-libp2p Record-Aware

One of the most impactful chunks of work I did was around cleaning up and upgrading the `PeerStore` in py-libp2p. For context, the PeerStore is the core module responsible for storing information about known peers — things like their multiaddrs, public keys, supported protocols, metadata, etc.

But when I started, py-libp2p’s PeerStore was still pretty barebones. It didn’t handle signed peer records, didn’t respect sequence number for address updates, and wasn’t alligned with how other libp2p implementations (like Go or Rust) handle peer identity and trust. So I set out to fix that.

This work spanned across three PRs:

### **PeerStore Refactor** :- [https://github.com/libp2p/py-libp2p/pull/648](https://github.com/libp2p/py-libp2p/pull/648)

This PR was the groundwork. The existing `PeerStore` was messy — it let you blindly overwrite a peer’s multiaddrs with no regard for where that data came from, how recent it was, or whether it was trustworthy.  
I started by simplifying the address handling logic and cleaning up how multiaddrs were stored and retrieved. This helped eliminate weird edge cases where stale or empty address lists would override valid data.

**✅ What changed:**

*   **AddrBook, KeyBook, ProtocolBook, and MetadataBook interfaces** matching go-libp2p’s abstractions, enabling identical method names (e.g., `add_addrs()`, `get_pubkey()`, `put_metadata()`) and TTL semantics for stored data.
    
*   **Permanent vs. ephemeral TTLs** for peer addresses, so that bootstrap or recently connected peers behave exactly as in go-libp2p (permanent TTL = ∞, recently connected TTL = 10 min, temporary TTL = 2 min)
    
*   **AddrStream support**, enabling clients to consume a continuous stream of address updates for a given peer—crucial for services that need to react when a peer’s reachable addresses change.
    
    These reactivity empowers p2p applications (eg. pubsub routers, DHT clients) to maintain up-to-date peer views without manual polling.
    

### **Signed PeerRecord support to PeerStore:-** [https://github.com/libp2p/py-libp2p/pull/753](https://github.com/libp2p/py-libp2p/pull/753)

This was a big one. Here I added full support for libp2p’s PeerRecord format — which is a spec-compliant way to share peer addresses in a secure, verifiable format.

Now, instead of just storing raw multiaddrs, py-libp2p can accept an `Envelope`, verify the peer’s signature, extract the `PeerRecord`, and decide whether to accept or reject it based on the record’s sequence number.

**✅ What changed:**

*   Implemented the `PeerRecord` class the wrapper `Envelope` class.
    
*   Implemented the `Certified-Addr-Book` interface in the `PeerStore` class.
    
*   Sequence numbers are checked to ensure newer records override older ones
    
*   Invalid or replayed records are silently ignored
    
*   Stored `PeerRecord` data is cached and used when the peer info is requested again
    
*   A separate `async task` for **periodic cleanup** of the `PeerStore` data, to prevent exhaustion.
    

**💡 Why this mattered:**  
This brought py-libp2p in line with Rust, Go, and JS implementations. With this, a Python peer can now securely share its address information, and other peers can verify that info wasn’t spoofed or tampered with. This is a core requirement for Identify and DHT interop.

# Lessons learned

**Cross-Implementation Compatibility is Complex**. Working on interoperability between py-libp2p and rust-libp2p taught me that:

*   **Protocol details matter**: Small differences in implementation can break compatibility
    
*   **Error handling varies**: Different languages and frameworks handle errors differently, requiring careful alignment
    
*   **Testing is crucial**: Cross-implementation testing requires sophisticated test setups and coordination
    

**Technical Debt Management.** Systematically addressing TODOs and FIXMEs showed me:

*   **Incremental improvements**: Small, focused changes are more manageable than large refactors
    
*   **Breaking changes require care**: Even beneficial changes need proper versioning and communication
    
*   **Test coverage is essential**: Every change needs corresponding tests to prevent regressions
    

# Conclusion

Contributing to py-libp2p over these three months has been an incredibly rewarding experience. From debugging complex interoperability issues to implementing resource management systems, each contribution has helped make py-libp2p more robust and reliable.

The work on **py-libp2p ↔ rust-libp2p interoperability** represents a significant step forward for the broader libp2p ecosystem, enabling Python developers to build applications that can seamlessly communicate with Rust-based libp2p implementations. The systematic **TODO/FIXME resolution** effort has reduced technical debt and improved code quality across the project.

Looking ahead, py-libp2p has tremendous potential to become a fully-featured peer-to-peer networking stack for Python developers. The foundation is solid, and with continued community effort, it will undoubtedly play a crucial role in the decentralized web ecosystem.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1753620553897/b13d22a2-a34e-43e3-bf78-88b6efcf927c.webp align="center")