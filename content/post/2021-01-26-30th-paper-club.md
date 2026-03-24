---
date: 2021-01-26T00:00:00Z
tags: [tech, paper, distributed-systems, time]
title: 30th DistSys Reading Group - NTP

---

What better way to start a new year than with a paper discussing how to change
time?

In the 30th session we discussed a paper which I think has much up its sleeves -
_Attacking the Network Time Protocol_. First off the paper gives us a good
introduction to the inner working of the network time protocol. Next up it
examines the broader ecosystem as well as why we need accurate time in the first
place. Once we established enough background, the paper dives into how one can
attack the protocol, starting off with on-path attacks all the way to some crazy
(creative) off-path attacks. Last but not least, the list of references at the
end is a small treasure trove.

Malhotra, Aanchal, et al. "Attacking the Network Time Protocol." NDSS. 2016.

https://eprint.iacr.org/2015/1020.pdf

You might have come across the work of one of the authors, [Sharon
Goldberg](https://www.cs.bu.edu/~goldbe/). In case you are looking for more
material I can recommend the recording of Sharon's talk ["On the Security of the
Network Time Protocol"](https://youtu.be/_m4rPgi-b90).

[Here are the notes](https://hackmd.io/@mxinden/rylWPpcyd) I used during the
session. You find numerous related references (various talks, bitcoin timing
attack, NTS, PTP, Roughtime, ...) in there.
