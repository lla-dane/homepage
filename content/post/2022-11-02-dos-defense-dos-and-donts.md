---
date: 2023-02-05
title: Talk "DOS Defense - Do’s and Don’ts" @IPFS-Camp
tags: [tech, talk, libp2p]
---

I presented at IPFS Camp 2022 on mitigating Denial-of-Service attacks in
peer-to-peer networks. I discussed resource management strategies such as
enforcing backpressure and provided examples of coding pitfalls to avoid in Rust
and Go. You can find the recording and slides of my talk below.

{{< youtube jZrAnnFO-2c >}}

# Slides

## DOS

-   Denial-of-service attack
-   Hard in peer-to-peer as identities are cheap
-   Relevant for any scarce resource, e.g. CPU, memory(, file descriptors)

## Do's

-   Bound EVERYTHING
-   Once a bound is exceeded:
    -   Drop item (<del>good</del>)
    -   Enforce backpressure (good)

## Do's

### Backpressure

-   Slow consumer should slow down a fast producer
-   Can improve resource utilization
-   Can improve latency

## Don'ts

``` rust
// Decode the length prefix of a message.
let l = uvi::decode::usize(msg_len_prefix)?;
// Allocate a corresponding buffer.
let buffer = vec![0; l];
// Read message into buffer.
socket.read_exact(&mut buffer)?;
```

## Don'ts

``` go
for {
  // Receive a request.
  request := <- incomingRequests
  // Handle the request.
  go handleRequest(request)
}
```

## Don'ts

``` rust
loop {
  // Receive a request.
  let request = incoming_requests.next().await?;

  // Handle the request.
  spawn(async move {
      handle(request)
  });
}
```

## Don'ts

``` rust
loop {
  // Receive a request.
  let request = incoming_requests.next().await?;
  // Send the request somewhere else.
  request_channel.unbounded_send(request);
}
```

## Don'ts

``` rust
// Buffer of requests
let to_be_handled_later = Vec::new();

// ...

let request = incoming_requests.next().await?;
to_be_handled_later.push(request);
```


