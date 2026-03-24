---
date: 2024-07-18T00:00:00Z
title: Improve Floresta's testing - Part 1
---

> This blog covers the progress of my Summer of Bitcoin project till mid-evaluation:  
> Improve the testing environment of Floresta.

# Floresta ?

Floresta a lightweight Bitcoin full node implementation written in Rust. powered by [Utreexo](https://eprint.iacr.org/2019/611) a novel dynamic accumulator designed for the Bitcoin UTXO set, with an integrated [Electrum](https://thebitcoinmanual.com/articles/btc-electrum-server/) server.

At the beginning Floresta only had some basic functional and unit testing, far from ideal. My job is to build a robust testing infrastructure, improving the quality and assurance of the software.

# My progress :

<iframe src="https://giphy.com/embed/GoyHSQzWVhN4Cvi0ko" width="480" height="269" class="giphy-embed"></iframe>

> All my related PRs for Floresta:
> 
> *   [https://github.com/vinteumorg/Floresta/pull/168](https://github.com/vinteumorg/Floresta/pull/168)
>     
> *   [https://github.com/vinteumorg/Floresta/pull/179](https://github.com/vinteumorg/Floresta/pull/179)
>     
> *   [https://github.com/vinteumorg/Floresta/pull/182](https://github.com/vinteumorg/Floresta/pull/182)
>     
> *   [https://github.com/vinteumorg/Floresta/pull/180](https://github.com/vinteumorg/Floresta/pull/180)
>     

Floresta is composed of two parts :-

*   **libfloresta:** It is a set of reusable components that can be used to build Bitcoin applications.
    
*   **florestad:** Built on top of libfloresta to provide a full node implementation, inncluding a watch-only wallet and Electrum server.
    

## Tools installation:

I first started off with installing the **Tarpaulin,** a code coverage tool specifically designed for Rust projects. It offers developers a way to measure how much of their codebase is being exercised by tests.

```markdown
// Installation 
cargo install cargo-tarpaulin

// This command will execute all your tests and report the code coverage percentage 
cargo tarpaulin 

// To generate a detailed report in HTML or XML formats, use: 
cargo tarpaulin --out Html
cargo tarpaulin --out Xml
```

> Checkout the initial test-coverage report by **cargo tarpaulin** of Floresta here: [https://lla-dane.github.io/floresta-tests.github.io/](https://lla-dane.github.io/floresta-tests.github.io/)

## Exploring the codebase:

I started exploring the codebase with **libfloresta,** which has 5 major modules:

*   **floresta-chain:** Updates the blockchain state for our node.
    
*   **floresta-cli:** A CLI utility to interact with the node.
    
*   **floresta-electrum:** The Electrum protocol implementation for interating with the node.
    
*   **floresta-watch-only:** A watch-only wallet that can track details for some particular addresses in the blockchain.
    
*   **floresta-wire:** This library communicates with the Bitcoin network, learning about new blocks and transactions.
    

### Floresta-chain :

It was first time reading and understanding those advanced programming techniques combined with the bitcoin protocol, it took a little bit extra time then expected, but I soon caught up.

The main functionality for blockchain management is implemented in **chain\_state.rs.** Initially it only had unit tests for:

*   accepting mainnet and signet headers
    
*   reorg blockchain in case of forks
    
*   calculate the next work(pow) required
    

I added the following tests:

*   pushing signet headers in the blockchain without validating them.
    
*   reindexing the chain.
    
*   invalidate a random block in the middle of the blockchain.
    
*   get block headers by height and hash from the database
    

While going through the chain-management logic, I didn't understand how the Utreexo accumulator logic was integrated with the chain, but it soon cleared up when I ran **utrrexod** on my local system, and got to see the **udata** components in the **UtreexoBlock**s which was processed in Floresta.

```rust
// A typical UtreexoBlock looked like this
// A block plus some udata
#[derive(PartialEq, Eq, Clone, Debug)]
pub struct UtreexoBlock {
    // An actual block
    pub block: Block,
    // The utreexo specific data
    pub udata: Option<UData>,
}
```

After this small contribution I moved on to understanding **floresta-watch-only.**

### Floresta-watch-only :

After reading floresta-chain, at first I went for floresta-wire but its complexity was still out of my reach so I took a step back.

As I discussed above this module acts as a watch-only wallet for tracking our intended script hashes in the blockchain, like transactions, UTXOs, balance, descriptors etc. related to those addresses.

It has two two of data storing techniques:

*   **kv\_database:** A key-value store-based database for the watch-only wallet using **kv** crate. The **KvDatabase** is meant to used for production.
    
    ```rust
    pub struct KvDatabase(Store, Bucket<'static, String, Vec<u8>>);
    ```
    
*   **memory\_database:** An in-memory database to store address data. Being in-memory means this database is volatile, ans all data is lost after the database is dropped or the process is terminates.
    
    ```rust
    #[derive(Debug, Default)]
    pub struct MemoryDatabase {
        inner: RwLock<Inner>,
    }
    
    #[derive(Debug, Default)]
    struct Inner {
        addresses: HashMap<sha256::Hash, CachedAddress>,
        transactions: HashMap<Txid, CachedTransaction>,
        stats: Stats,
        height: u32,
        descriptors: Vec<String>,
    }
    ```
    
    This feature is not meant for production, but for the integrated testing framework.
    

**My contribution in floresta-watch-only:**

1.  **Memory database:**
    

*   Added tests for caching address hashes.
    
*   Modified tests for caching transaction by adding tests for helper functions that work around with caching a transaction.
    
*   Modified tests for processing blocks to monitor transactions related to our intended addresses by adding tests for helper functions that work around with processing a block.
    

**2) KvDatabase:**

*   Added tests for the basic functions used by the kv-database like getting, saving and updating stuff for our watch-only-wallet.
    

**Bug Fix:**

There was a potential bottleneck in the cache-transaction function. Previously the **balance** and **utxos** related to a **script\_hash** gets pushed again in the cache under some particular conditions, resulting the balance associated with that **script\_hash** becoming twice as much. So, this could have been disastrous.

I did the following changes.

This concluds my work with **floresta-watch-only.**

> For detailed info about this bug fix and the watch-only-wallet tests, refer to the related PR: [https://github.com/vinteumorg/Floresta/pull/1](https://github.com/vinteumorg/Floresta/pull/180)68

### Floresta-electrum:

<iframe src="https://giphy.com/embed/rdma0nDFZMR32" width="480" height="346" class="giphy-embed"></iframe>

I had most of the fun here, while exploring this module. As the name suggests this is the **Electrum protocol** implementation for the node.

The Electrum server is set up to communicate over the **TCP Stream,** so you can't go along and try to get the responses using **Postman,** or any similar services, it has to be over the **Tcp stream.**  
One way to do it is like this using the terminal:

```bash
echo '{"id": 5, "method": "server.banner", "jsonrpc": "2.0", "params": []}' | nc localhost 50001
```

Through the Electrum Server we interact with the watch-only wallet as discussed above.

**My contribution:**

The most important function for this testing environment is this function:

```rust
   async fn start_electrum(port: u16) {
        let e_addr = format!("0.0.0.0:{}", port);
        let wallet = get_test_cache();

        // Create test_chain_state
        let test_id = rand::random::<u32>();
        let chainstore = KvChainStore::new(format!("./data/{test_id}.floresta/")).unwrap();
        let chain =
            ChainState::<KvChainStore>::new(chainstore, Network::Signet, AssumeValidArg::Hardcoded);

        let headers = get_test_signet_headers();
        chain.push_headers(headers, 1).unwrap();
        let chain = Arc::new(chain);

        // Create test_node_interface
        let u_config = UtreexoNodeConfig {
            network: bitcoin::Network::Signet,
            pow_fraud_proofs: true,
            proxy: None,
            datadir: "/data".to_string(),
            fixed_peer: None,
            max_banscore: 50,
            compact_filters: false,
            max_outbound: 10,
            max_inflight: 20,
            assume_utreexo: None,
            backfill: false,
        };

        let chain_provider: UtreexoNode<RunningNode, Arc<ChainState<KvChainStore>>> =
            UtreexoNode::new(
                u_config,
                chain.clone(),
                Arc::new(async_std::sync::RwLock::new(Mempool::new())),
                None,
            );

        let node_interface = chain_provider.get_handle();

        let electrum_server: ElectrumServer<ChainState<KvChainStore>> = block_on(
            ElectrumServer::new(e_addr, wallet, chain, None, node_interface),
        )
        .unwrap();

        task::spawn(client_accept_loop(
            electrum_server.tcp_listener.clone(),
            electrum_server.message_transmitter.clone(),
        ));
        // Electrum main loop
        task::spawn(electrum_server.main_loop());
    }
```

This is a dummy simulation of a working **Electrum server** over a random port, with a dummy **chain-store database** to store the blockchain and a **watch-only wallet** to monitor the user's intended addresses.

After this, I just created tests for different features of electrum like this:

```rust
 #[async_std::test]
    async fn test_server_banner() {
        let port = rand::random::<u16>() % 1000 + 18443;
        start_electrum(port).await;

        let method = Value::String("server.banner".to_string());
        let mut request = generate_request(&mut vec![method]).to_string();
        request.push('\n');
        println!("{}", request);
        assert_eq!(send_request(request, port).await, "Welcome to Floresta's Electrum Server".to_string())
    }
```

This concludes my work with **floresta-electrum.**

> For detailed information check it out in the related PR:  
> [https://github.com/vinteumorg/Floresta/pull/180](https://github.com/vinteumorg/Floresta/pull/180)

### Floresta-wire:

Here comes the monster of them all. This is the most complex module of them all, using the features of all the remaining modules.

The Bitcoin wire protocol is fundamental to the operation of the Bitcoin network, enabling the distributed and decentralised verification of transactions. This protocol defines how nodes exchange information about transactions, blocks, and other data to maintain the decentralised blockchain.

It has composed of three bridge nodes namely:

*   **chain\_selector\_node:** This module connects with multiple peers and finds the best chain. We optimistically download all headers from one random peer, and then check with the others if they agree. If they have another chain for us, we download that chain, and pick whichever has more work.
    
    Most likely we'll only download one chain and all peers will agree with it. Then we can start downloading the actual blocks and validating them.
    
*   **sync\_node** : This node downloads and validates the blockchain.
    
*   **running\_node:** After the node caches-up with the network, we can start listening for new blocks, handling any request our user might make and keep our peers alive.
    

**My contribution with the chain\_selector node:**

The fundamental function related to this testing environment are these:

*   **create\_peer:** This simulates a running peer that responds to the **chain\_selector** node with any incoming requests like:
    
    *   **GetHeaders**
        
    *   **GetUtreexoState**
        
    *   **Shutdown**
        
    *   **GetBlock**
        

```rust
fn create_peer(
        headers: Vec<Header>,
        blocks: HashMap<BlockHash, UtreexoBlock>,
        filters: HashMap<BlockHash, Vec<u8>>,
        node_sender: Sender<NodeNotification>,
        sender: Sender<NodeRequest>,
        node_rcv: Receiver<NodeRequest>,
        peer_id: u32,
    ) -> LocalPeerView {
        let peer = TestPeer::new(node_sender, headers, blocks, filters, node_rcv, peer_id);
        task::spawn(peer.run());

        LocalPeerView {
            address: "127.0.0.1".parse().unwrap(),
            services: ServiceFlags::from(1 << 25),
            user_agent: "/utreexo:0.1.0/".to_string(),
            height: 0,
            state: PeerStatus::Ready,
            channel: sender,
            port: 8333,
            feeler: false,
            banscore: 0,
            address_id: 0,
            _last_message: Instant::now(),
        }
    }
```

*   **setup\_test:** This is the dummy simulation of a chain\_selector node, that syncs up with the provided running peers in the parameters.
    

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
        let datadir = format!("./data/{}.node_test", rand::random::<u32>());
        let chainstore = KvChainStore::new(datadir.clone()).unwrap();
        let mempool = Arc::new(RwLock::new(Mempool::new()));
        let chain = ChainState::new(chainstore, network, AssumeValidArg::Disabled);
        let chain = Arc::new(chain);

        let config = UtreexoNodeConfig {
            network: network.into(),
            pow_fraud_proofs,
            compact_filters: false,
            fixed_peer: None,
            max_banscore: 100,
            max_outbound: 8,
            max_inflight: 10,
            datadir: datadir.clone(),
            proxy: None,
            assume_utreexo: None,
            backfill: false,
        };

        let mut node = UtreexoNode::<ChainSelector, Arc<ChainState<KvChainStore>>>::new(
            config,
            chain.clone(),
            mempool,
            None,
        );

        for (i, peer) in peers.into_iter().enumerate() {
            let (sender, receiver) = async_std::channel::bounded(10);
            let peer = create_peer(
                peer.0,
                peer.1,
                peer.2,
                node.node_tx.clone(),
                sender.clone(),
                receiver,
                i as u32,
            );

            let _peer = peer.clone();

            node.peers.insert(i as u32, peer);
            node.peer_ids.push(i as u32);
            match node.peer_by_service.get_mut(&_peer.services) {
                Some(peer_vec) => peer_vec.push(i as u32),
                None => {
                    node.peer_by_service.insert(_peer.services, vec![i as u32]);
                    ()
                }
            }
        }

        let mut node = ManuallyDrop::new(Box::new(node));

        let kill_signal = Arc::new(RwLock::new(false));
        // FIXME: This doesn't look very safe, but we need to coerce a &mut reference of the node
        //        to live for the static lifetime, or it can't be spawn-ed by async-std::task
        let _node: &'static mut UtreexoNode<ChainSelector, Arc<ChainState<KvChainStore>>> =
            unsafe { std::mem::transmute(&mut **node) };

        future::timeout(Duration::from_secs(2), _node.run(kill_signal))
            .await
            .unwrap()
            .unwrap();

        chain
    }
```

After this I just created tests for different scenarios like:

*   accept one header
    
*   two\_peers with different tips
    
*   ten peers with different tips
    
*   two peers one lying
    
*   ten peers one honest
    

One of these tests looks like this:

```rust
 #[async_std::test]
    async fn ten_peers_different_tips() {
        let (mut headers, _, _, _) = get_essentials();
        let _headers = headers.clone();

        let mut peers = Vec::new();

        for _ in 0..10 {
            headers.pop();
            headers.pop();

            peers.push((headers.clone(), HashMap::new(), HashMap::new()))
        }

        let chain = setup_test(peers, false, floresta_chain::Network::Signet).await;

        assert_eq!(chain.get_best_block().unwrap().0, 2013);
        assert_eq!(
            chain.get_best_block().unwrap().1,
            _headers[2013].block_hash()
        );
    }
```

**Bug fix:**

1.  ***req\_headers:*** Extended the parameters of `request_headers` function, by mentioning the `peer_id` of the peer to which the `GetHeaders` req is being sent to.
    

Previously when `request_headers` function was called it was always sending req to `node.sync_peer`.

> PR related to this fix: [https://github.com/vinteumorg/Floresta/pull/1](https://github.com/vinteumorg/Floresta/pull/180)79

2.  ***find\_who\_is\_lying:*** Modified the declaration of `agree` bool in `find_who_is_lying` function.
    

> PR related to this fix: [https://github.com/vinteumorg/Floresta/pull/18](https://github.com/vinteumorg/Floresta/pull/180)2

This concludes my current work done with floresta-wire. I plan to do the same with **sync\_node** and **running\_node.**

> For detailed info about this, refer to the related PR:  
> [https://github.com/vinteumorg/Floresta/pull/180](https://github.com/vinteumorg/Floresta/pull/180)

# Future Milestones

*   Functional tests for **sync\_node** and **running\_node.**
    
*   Setting up **Grafana** and **Prometheus client** support for enchanced monitoring.
    
*   Documentation for a complete and extensible testing infrastructure.
    

# Conclusion

I had a lot of fun till now understanding Floresta's codebase and enhancing my coding skills in Rust.

Thank you for reading, hope you enjoyed it! I'll continue to update my progress via the series of blogs ;)

Follow me on [Twitter](https://x.com/lla_dane) | [Linkedln](https://www.linkedin.com/in/abhinav-agarwalla-a80425258/) for more development related tips and posts.

That's all for today! You have read this article till the end.
