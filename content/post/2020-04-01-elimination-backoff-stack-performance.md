---
date: 2020-04-01T00:00:00Z
tags: [tech, paper, lock-free, multithreaded, concurrent, rust, crossbeam]
title:  Elimination back-off stack performance

---

![All stacks from 1 thread to up to 128](/static/elimination-back-off-stack/lines.svg)

I recently stumbled upon the idea of an *Elimination Back-off Stack* promising
to be a **parallel**, linearizable and lock-free stack. In case you are not
familiar with it, I would suggest either reading my [previous
post](/blog/2020-03-28-elimination-backoff-stack/) or the corresponding paper
[1] itself. Being quite intrigued by the ideas of the above stack I wrote [my
own implementation](https://github.com/mxinden/elimination-backoff-stack/) in
Rust with a *little* help from
[crossbeam](https://github.com/crossbeam-rs/crossbeam).

In this post I will compare my implementation to other stack implementations.
In particular I want to dive into some performance characteristics and their
behavior in regards to the amount of threads (≤ 128) accessing the
datastructure.

The code of the implementation itself, as well as all benchmarking logic is
public at https://github.com/mxinden/elimination-backoff-stack/ .

**Take this with a grain of salt. This is a hobby project, thus in no way
sophisticated let alone ready for production.**


## Stacks of the day

### (1) Simplest stack in the world

A Rust [`Vec`](https://doc.rust-lang.org/std/vec/struct.Vec.html) implements
both `push` and `pop`, wrapping it in a `Mutex` for mutual exclusion and an
`Arc` for shared ownership makes it a *concurrent* stack. Let's see whether an
`Arc<Mutex<Vec<_>>>` outperforms any of the more sophisticated implementations
below. Rephrased: *At which point is lock-free programming worth the complexity
coming alongside with it?*

### (2) Plain lock-free Treiber stack

A lock-free stack, also often referred to as a [Treiber
stack](https://en.wikipedia.org/wiki/Treiber_stack) [2] due to Kent Treiber,
operates on top of a lock-free linked list. The entry point of the stack is an
atomic pointer which is either pointing to the node on the very top of the stack
or is `null` in case of an empty stack.

The stack linearizes concurrent access through that single atomic `head` pointer
on which `push` and `pop` operations loop trying to `compare_and_set` it. Let's
see how many threads it takes for that single serialization point (`head`) to
hurts performance.


### Elimination back-off stack

A lock-free elimination back-off stack wraps a lock-free Treiber stack, but
instead of simply exponentially backing off on `compare_and_set` failures, it
uses something called an elimination array to back-off in space instead of time.
Again for details please either read my [previous
post](/blog/2020-03-28-elimination-backoff-stack/) or the corresponding paper
[1] itself. I will be waiting here.


#### (3) Switching back and forth

Each operation failing on the lock-free Treiber stack will try to exchange its
value on the elimination array. A failure on the elimination array makes an
operation try the stack again. This goes back and forth until the operation
succeeds.


#### (4) Exponentially backing-off in space

If you are not familiar with the concept of backing-off in space instead of
time, please read the [corresponding
section](/blog/2020-03-28-elimination-backoff-stack/#backing-off-in-space-instead-of-time).
This elimination back-off stack variation keeps track of a *contention score*.
Whenever an operation fails on the stack or the elimination array due to
contention the score is increased by one. Whenever an operation fails due to
missing contention, e.g. as a `push` operation waiting for a `pop` operation to
exchange with, the *contention score* is subtracted by two.

An operation failing on the stack will try to exchange with the opposite
operation type on the elimination array. It will consider `2^contention_score`
exchangers of the elimination array. See how each operation considers
exponentially more exchangers the more contention it experiences? That is the
idea of *backing-off in space*.


## Benchmarking

The benchmark described has been executed on a dual-socket machine with an AMD
EPYC 7601 32-Core Processors making up a total of 128 hyper-threads. The
benchmark is using [criterion](https://github.com/bheisler/criterion.rs) as a
benchmark library. Each test run takes as parameters a stack implementation and
the amount of threads to test with. Each thread executes 1_000 operations
(`push` / `pop`) on the shared stack.

**Again, take these numbers with a grain of salt.** The benchmark above is
highly artificial. One would need to test this under some real-world load in
order to derive proper conclusions.


### A single thread

While pretty useless in itself for a concurrent datastructure, having decent
single-threaded performance is still a nice-to have. The clear winner, *who
would have thought*, is the `Arc<Mutex<Vec<_>>>` (1) with an average of `77.655
ns`. While some outliers took longer, all stayed below `100 ns`. Below you see a
graph depicting each result as well as the mean of the distribution.

![Single Thread - Stack (1)](/static/elimination-back-off-stack/vec_1.svg)


Just as a comparison the lock-free stacks (2), (3) and (4) all took somewhere
around `4.6768 us`. The similarities come at no suppries, given that a single
threaded elimination back-off stack is just a lock-free Treiber stack as there
is no contention.


### Introducing a little contention with 8 threads

Earlier I asked the question at what point the complexity introduced through
lock-free programming is worth the gain. Having 8 threads hammering at the same
datastructure is definitely beyond that point. While the `Arc<Mutex<Vec<_>>>`
(1) can offer a mean test execution time of `3.3933 ms`, the lock-free Treiber
stack (2) runs through the test at a mean of `2.4423 ms`. But one should not
just pay attention to averages. Looking at the best and worst cases depicted
below in the violin graph, the lock-free Treiber stack (2) outperforms all other
stacks by far. Just as a reminder, this is not the time per operation, but the
time it takes 8 threads to execute 1_000 operations each.

![Violin plot comparing the stacks with 8 threads](/static/elimination-back-off-stack/violin_8.svg)


### Operating under heavy load with 128 threads

While implementing and testing my elimination back-off stack (3) and (4) on my
local laptop with an i7-8550U I got constantly disappointed as I couldn't get it
to outperform a lock-free Treiber stack (2). This would imply that the whole
overhead and complexity of an elimination back-off stack (and at least one of my
weekends) would go down the drain. Turns out, things change if you just throw
more threads at it.

As we have noticed in the previous section the plain `Arc<Mutex<Vec<_>>>` (1)
falls behind once one operates with high contention. This has not changed now
that we are using 128 threads. The thing that we should definitely direct our
attention at though, is that the lock-free Treiber stack (2) and the elimination
back-off stack with exponential back-off in space (4) switched spots. (2)
executes a test run within an average of `106.11 ms`, while (4) gets through a
test in nearly halve the time with `57.118 ms`.

![Violin plot comparing the stacks with 128
threads](/static/elimination-back-off-stack/violin_128.svg)

Also the best and worst cases spread across a smaller range (see violin chat above).

### Summary

![All stacks from 1 thread to up to 128](/static/elimination-back-off-stack/lines.svg)





## Open questions (suggestions welcome)

- Testing, testing, testing. In particular my use of atomics, in addition any
  randomized linearization testing tools.

- Collecting more data to optimize my current static assumptions. E.g. how long
  should a `push` operation wait for a `pop` operation on an Exchanger.
  
- ...

- And of course the most important one: **Why would one use a stack with 128
  concurrent threads?**


---

## References


[1] Hendler, Danny, Nir Shavit, and Lena Yerushalmi. "A scalable lock-free stack
algorithm." Proceedings of the sixteenth annual ACM symposium on Parallelism in
algorithms and architectures. 2004.

[2] Treiber, R. Kent. Systems programming: Coping with parallelism. New York:
International Business Machines Incorporated, Thomas J. Watson Research Center,
1986.
