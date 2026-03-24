---
date: 2020-03-28T00:00:00Z
tags: [tech, paper, lock-free, multithreaded, concurrent]
title:  Elimination back-off stack

---

Reading *The Art of Multiprocessor Programming* [1] I came across the
*Elimination Back-off Stack* [2] datastructure introduced in 2004 by Danny
Hendler, Nir Shavit, and Lena Yerushalmi. It promises to be a **parallel**
lock-free stack.

How can a stack allow parallel operations without going through a single
serialization point, e.g. a Mutex or an Atomic? Let's dive into it.

## A lock-free stack

A lock-free stack, also often referred to as a Treiber stack [3] due to Kent
Treiber, operates on top of a lock-free linked list. The entry point of the
stack is an atomic pointer which is either pointing to the node on the very top
of the stack or is `null` in case of an empty stack.

```Rust
pub struct Stack<T> {
    head: Atomic<Node<T>>,
}
```

Each node on the stack contains its `data` as well as an atomic `next` pointer which is
either `null` in the case where it is the last node of the stack (bottom plate)
or a pointer to the next node.

```Rust
struct Node<T> {
    data: ManuallyDrop<T>,
    next: Atomic<Node<T>>,
}
```

### Push and pop operation

A `push` operation creates a new `Node`, reads the current `head`, sets the
`next` pointer of its new node to `head` and then tries to `compare_and_set`
`head` to point to its new node. It loops until the final `compare_and_set`
succeeds. A `pop` operation reads the current `head`. If the stack is empty
`head` will be `null` thus `pop` can return. If the stack is not empty `head`
will point to the first node. It reads that node and tries to `compare_and_set`
`head` to point to the second node instead of the first one, again looping until
the `compare_and_set` succeeds. On success it returns the `data` field of the
first node.

``` markdown
Empty stack:

+----+
|head| --> null
+----+

Non-empty stack:

+----+     +----+     +----+     +----+
|head| --> |next| --> |next| --> |next| --> null
+----+     |data|     |data|     |data|
           +----+     +----+     +----+
```

### Performance

The lock-free stack implementation above linearizes concurrent access through a
single atomic `head` pointer on which `push` and `pop` operations loop trying to
`compare_and_set` it. This single sequential execution point introduces
contention when multiple threads try to `push` or `pop` at *the same time* thus
making the entire stack implementation scale poorly. One can use exponential
back-off by having a thread wait for a bit on `compare_and_set` failure before
retrying.

*Can we do better?*


## A lock-free elimination back-off stack

A lock-free elimination back-off stack wraps a lock-free Treiber stack, but
instead of simply exponentially backing off on `compare_and_set` failures, it
uses something called an elimination array to back-off in space instead of time.


### Elimination Array

The stack datastructure allows two operations: `push` and `pop`. A `push`
followed by a `pop` leaves a given stack in the same state as it was before the
two operations. Thus the two operations *cancel out*. An elimination array is a
fixed size array where each slot enables a thread executing a `push` operation
to hand its item over to a thread executing a `pop` operation *canceling* the
two out. A reasonable size for the elimination array would be the amount of
threads operating on the datastructure.


``` markdown
Initial state

+----+     +----+     +----+     +----+
|head| --> |next| --> |next| --> |next| --> null
+----+     |abcd|     |efgh|     |ijkl|
           +----+     +----+     +----+

After push operation

+----+     +----+     +----+     +----+     +----+
|head| --> |next| --> |next| --> |next| --> |next| --> null
+----+     |push|     |abcd|     |efgh|     |ijkl|
           +----+     +----+     +----+     +----+

After pop operation == initial state

+----+     +----+     +----+     +----+
|head| --> |next| --> |next| --> |next| --> null
+----+     |abcd|     |efgh|     |ijkl|
           +----+     +----+     +----+
```

Both `push` and `pop` try to succeed on the lock-free stack first. On contention
an operation's `compare_and_set` is likely to fail. Instead of backing-off by
waiting a bit and retrying on the stack, an operation would try to exchange with
its counterpart on the elimination array instead.

```rust
pub struct EliminationArray<T> {
    exchangers: Vec<Exchanger<T>>,
}

pub struct Exchanger<T> {
    item: Atomic<Item<T>>,
}

enum Item<T> {
    Empty,
    Waiting(ManuallyDrop<T>),
    Busy,
}
```

In order for a `push` operation to exchange its `data` with a `pop` operation,
the `push` operation first selects an `Exchanger` within the elimination array
at random. It then checks the `item` field of the `Exchanger`.

- If it is **`Empty`** the `Exchanger` is currently not in use. Thus it can
  `compare_and_set` it to `Waiting` with the `data` it wants to exchange. Next
  it loops until a corresponding `pop` operation sets the `Item` to `Busy`
  signaling a successful exchange. As a final step the `push` operation cleans
  up after itself by setting the `Exchanger` back to `Empty` for future
  exchanges to happen.

- If it is **`Waiting`** the `Exchanger` is currently in use by another `push`
  operation waiting for a `pop` operation. Our `push` operation should try
  another `Exchanger` within the elimination array instead.

- If it is **`Busy`** the `Exchanger` is currently in use by another `push`
  operation that already exchanged its `data` with a `pop` operation but has not
  yet done the final step. Our `push` operation should again try another
  `Exchanger`.

In order for a `pop` operation to eliminate with a `push` operation and receive
its `data` it picks, just like a `push` operation, an `Exchanger` within the
elimination array at random. It then checks the `item` field of that
`Exchanger`.

- If it is **`Empty`** the `Exchanger` is currently not in use. Instead of
  waiting for a `push` operation the `pop` operation tries another `Exchanger`
  within the elimination array.

- If it is **`Waiting`** a `push` operation is currently waiting for a `pop`
  operation. Thus the `pop` operation can try to `compare_and_set` the `Item` to
  `Busy`. On success it is done and returns the `data` on failure it tries
  another `Exchanger` within the elimination array.

- If it is **`Busy`** a `push` operation successfully exchanged with another
  `pop` operation and is just missing to do its final step. In that case our
  `pop` operation should try another `Exchanger` within the elimination array.

### Backing-off in space instead of time

Steps of `push` and `pop` operations can fail on the elimination array due to
too much contention or no contention. An example for the former would be a `pop`
operation failing to `compare_and_set` an `Item` from `Waiting` to `Busy` due to
another `pop` operation getting there first. On such contention one could
back-off by exponentially waiting a bit. Instead operations on the elimination
array back-off in space and not time. Backing-off in space instead of time
enables the elimination back-off stack to be used by multiple operations in
parallel. They do so by increasing the amount of `Exchanger`s they consider when
randomly selecting one from the elimination array.

> Backing-off in space instead of time enables the elimination back-off stack to
> be used by multiple operations in **parallel**.

For example at first a `pop` operation that failed on the lock-free stack
selects one out of the two first exchangers of the elimination array. If it
fails on that `Exchanger` due to contention it selects one out of the four first
exchangers of the elimination array.

### Liveness

To ensure a `push` operation does not starve waiting for a `pop` operation, or a
`pop` operation unsuccessfully looking for a `push` operation on different
`Exchanger`s, they should first of all decrease the amount of `Exchanger`s they
consider out of all the `Exchanger`s when witnessing missing contention. Second
of all operations should eventually try the lock-free stack again, given that
with low contention they will likely succeed on it directly.


## Conclusion

Combining a lock-free stack with an elimination array results in a *lock-free*
*linearizable* and *parallel* stack. *Linearizable* as `push` and `pop`
operations appear to take effect instantaneously for all threads at some moment
between their invocation and response. *Parallel* due to the fact that multiple
`push` and `pop` operations can *cancel* each other out on the elimination
array.



---

## References


[1] Herlihy, Maurice, and Nir Shavit. The art of multiprocessor programming.
Morgan Kaufmann, 2011.

[2] Hendler, Danny, Nir Shavit, and Lena Yerushalmi. "A scalable lock-free stack
algorithm." Proceedings of the sixteenth annual ACM symposium on Parallelism in
algorithms and architectures. 2004.

[3] Treiber, R. Kent. Systems programming: Coping with parallelism. New York:
International Business Machines Incorporated, Thomas J. Watson Research Center,
1986.
