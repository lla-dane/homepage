---
date: 2023-02-05
title: Talk "Peer-to-peer Browser Connectivity" @FOSDEM
tags: [tech, talk, libp2p]
---

I presented an overview on _Peer-to-peer Browser Connectivity_ options in the network devroom at FOSDEM 2023.

> Connecting from the browser to a public server with a valid TLS certificate is easy. But what if the server has a self-signed certificate? What if it isn't public? What if it is another browser?
>
> This talk covers the intricacies of browser communication beyond the standard browser-to-server use-case. I will give an overview of the many protocols available and how they can be used in a peer-to-peer fashion without sacrificing authenticity, confidentiality or integrity. We will leverage the new WebTransport for secure communication to public servers with self-signed certificates and WebRTC for secure communication to other browsers, using hole puching, without the dependency on central infrastructure.

[Recording & slides](https://fosdem.org/2023/schedule/event/network_p2p_browser_connectivity/)
