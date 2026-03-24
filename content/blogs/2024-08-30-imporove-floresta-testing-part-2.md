---
date: 2024-08-30T00:00:00Z
title: Improve Floresta's testing - Part 2
---

> This blog covers the progress of my Summer of Bitcoin porject - Improve Floresta's testing

# Floresta ?

Floresta a lightweight Bitcoin full node implementation written in Rust. powered by [**Utreexo**](https://eprint.iacr.org/2019/611) a novel dynamic accumulator designed for the Bitcoin UTXO set, with an integrated [**Electrum**](https://thebitcoinmanual.com/articles/btc-electrum-server/) server.

# My progress :

> All my related PRs after mid-evaluation:
> 
> *   [https://github.com/vinteumorg/Floresta/pull/200](https://github.com/vinteumorg/Floresta/pull/200)
>     
> *   [https://github.com/vinteumorg/Floresta/pull/202](https://github.com/vinteumorg/Floresta/pull/202)
>     
> *   [https://github.com/vinteumorg/Floresta/pull/203](https://github.com/vinteumorg/Floresta/pull/203)
>     
> *   [https://github.com/vinteumorg/Floresta/pull/214](https://github.com/vinteumorg/Floresta/pull/214)
>     

## Floresta-wire :

As I discussed before in my previous blog about my progress, I discussed about 3 node instances, that make up Floresta's node infrastructure:

*   **chain\_selector\_node:** Its job is to connect with multiple peers and decide the best chain in the network, on which we will build upon.
    
*   **sync\_node:** After chain selector decides the best chain, the sync node downloads and validates them
    
*   running\_nod: After the node caches-up with the network, we can start listening for new blocks, handling any request our user might make and keep our peers alive.
    

**After mid-evaluation my contribution was majorly around sync-node and running-node.**

### Test-Utils:

Since the basic functionality for setting up the simulation node, is about mostly same for the 3 nodes, setting up a common test utilities module seemed right.

It has all the basic functions to set up testing for the p2p-wire like:

*   Setting up the peers
    
*   Fetching different types of Signet and Regtest block data from the test\_data directories.
    
*   Serializing the fetched data into an abstract form which would be accepted in the consensus.
    
*   The Peer-Messaging system for the NodeRequests, which would be same for all the nodes.
    

> PR related to this feature: [https://github.com/vinteumorg/Floresta/pull/202](https://github.com/vinteumorg/Floresta/pull/202)

### Sync-Node:

So now that we set up the test-utils, only thing left to set up a simulated sync-node is setting up a test\_node function:

Most of the things in this function is same for all the nodes, apart from these two things:

```rust
pub async fn setup_node(
        peers: Vec<(
            Vec<Header>,
            HashMap<BlockHash, UtreexoBlock>,
            HashMap<BlockHash, Vec<u8>>,
        )>,
        pow_fraud_proofs: bool,
        network: floresta_chain::Network,
    ) -> Arc<ChainState<KvChainStore<'static>>> {
        ...
        ...
        
        // Declaring the type of node we want to simulate.
        let mut node = UtreexoNode::<SyncNode, Arc<ChainState<KvChainStore>>>::new(
            config,
            chain.clone(),
            mempool,
            None,
        );
        ...
        ...

        // Setting up the &'static mut referance of the node.
        let _node: &'static mut UtreexoNode<SyncNode, Arc<ChainState<KvChainStore>>> =
            unsafe { std::mem::transmute(&mut **node) };

        timeout(Duration::from_secs(10), _node.run(kill_signal, |_| {}))
            .await
            .unwrap();
}
```

Did the following tests:

*   Syncing valid blocks
    
*   Test how it responds to a node sending a block without proof (this should ban the node)
    
*   Sending blocks out-of-order (it should handle them fine)
    
*   How it responds to a block with invalid proof (this should ban the node, but should **not** invalidate the block)
    

> PR related to this: [https://github.com/vinteumorg/Floresta/pull/200](https://github.com/vinteumorg/Floresta/pull/200)
> 
> While setting up this test, I found a disastrous bug.

### Bug Fix:

Suppose there is a lying peer and an honest peer, then all the blocks from which the invalid block was caught, should be requested again to the honest peer.

But previously the block requests to the lying peer got stuck in the inflight messages to the lying peer, even after the peer is banned. So we could never move forward to the next block.

Then I fixed it by, removing the inflight requests related to the lying peer and sending those to a rendom\_peer after the banniing.

> PR related to this fix: [https://github.com/vinteumorg/Floresta/pull/203](https://github.com/vinteumorg/Floresta/pull/203)

Seriously, I was stuck in the same error for about a day because of this bug. I feel fixing this bug and one before, were my most important contributions.

### Running-node:

Due to some address issues, I could not test the running node in the **Signet Network.** Instead I had to use **Regtest Network,** which I was avoiding as there is not a straight forward guide for how to use bitcoin-regtest in **Utreexod,** the full node which I was using to get raw **SIgnet Utreexo Blocks**.

So then after a lot of brain-racking, we figured out how to run regtest on utreexod with these two commands:

```bash
./utreexod --datadir=. --logdir=. --regtest --flatutreexoproofindex --miningaddr=<regetest-address>
```

```bash
./utreexoctl --regtest --datadir=. generate <num-blocks>
```

In this way we can generate `UtreexoBlocks` using utreexod. Sometimes --`flatutreexoproofindex` flag doesn't work, so we can also use --`utreexoproofofindex`.  
One of these two will absolutely work.

Now I can set up tests with peers sending the blockchain with forks, using regtest in all 3 node instances.

> This PR is still under development. PR related to this: [https://github.com/vinteumorg/Floresta/pull/214](https://github.com/vinteumorg/Floresta/pull/214)

# Future Idea:

Integration tests for the wire-protocol were fairly straightforward and clearly help fixing and finding bugs and vulnerabilities in the codebase.

I plan on implementing the following things in the codebase:

*   Prometheus and Grafana toolkit support for continuous monitoring.
    
*   Implementing regression and endurance tests and simulating Floresta in hardware limiting virtual environments.
    

# Learning:

*   Through this journey, I learned a lot about how to use version control in fairly advanced levels in open-source projects, getting involved with the community, and contributing to the projects.
    
*   The major learning for me was getting fairly proficient in Rust programming and programming in Bitcoin-architecture applications.
    

# Special Thanks

It was an awesome experience for me to work on this project. I learned a lot of new things, Davidson Souza helped me a lot whenever I got stuck.

I would also like to thank Adi Shankara and Summer of Bitcoin for this amazing learning experience. I was able to develop great skills and valuable experience. I look forward to contributing to the Bitcoin space.

# Conclusion

Thank you for reading, hope you enjoyed it. I'll continue to update my progress via the series of blogs ;)

Follow me on Twitter | Linkedln for more blockchain-development tips and posts.

That's all for today ! You have read the article till the end.
