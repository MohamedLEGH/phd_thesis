#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/lovelace:0.3.0": *

#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
// #import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

= Model <chap:model>

== Notations
TODO

== System Model

// === Nodes
=== Peer to Peer Network

A peer-to-peer system is composed of a set $N$ of peers, also referred to as nodes, that communicate by exchanging messages over a network without relying on any central authority. Messages may represent control information, data items, or application-level payloads, and are assumed to have finite length and arbitrary content.

#definition(title: "Peer to Peer system")[
We use the definition from the book *Peer-to-Peer systems and applications* @wehrle2005peer. A Peer-to-Peer system consists of computing elements that are:
  1. connected by a network,
  2. addressable in a unique way, and
  3. share a common communication protocol.
All computing elements, synonymously called nodes or peers, have comparable
roles and share responsibility and costs for resources.]

#example[The BitTorrent network.]

A peer-to-peer network is typically implemented as a virtual network, also called an overlay network, on top of a physical network. A clear distinction must therefore be made between the physical network, such as the Internet, and the overlay network. Each node in the overlay network is hosted on a node of the physical network, but the reverse is not necessarily true. Moreover, two neighbouring nodes in the overlay network are not necessarily neighbours in the physical network. An overlay network can itself be implemented on top of another overlay network. For example, the Lightning Network @poon2016bitcoin operates as an overlay on top of the Bitcoin network, which itself relies on the Internet protocol stack.


// A node models an autonomous computational entity, such as a software process running on a physical or virtual machine, that participates in the peer-to-peer system. Each node may simultaneously act as a client, a server, or both, and is responsible for maintaining a local state, executing protocol logic, and interacting with other nodes according to the communication rules of the system. In this manuscript, the term _node_ is used consistently to refer to such entities, regardless of their physical implementation or functional role within the system.
// Formally, we define a node as follows.
Having defined the peer-to-peer system at a global level, we now formalize the notion of a node, which constitutes the basic computational entity of the system.
#definition(title: "Node")[A node (also called a participant, agent, or peer) is a process that runs on a computing device.
A node has:
1. a memory (a local state)
2. a unique address (network or logical identifier)
3. some computing power
4. the ability to communicate with other nodes by sending messages.
// 4. the ability to communicate with other nodes by sending messages using the underlying communication network.
]
#example[
In the BitTorrent protocol, a machine running a BitTorrent client constitutes a node in the peer-to-peer network. The node is identified by its IP address and a PeerID, and communication relies on the underlying TCP/IP network.]

We assume that:
- All nodes are assumed to be identical in terms of capabilities, in particular regarding computing power and access to the underlying communication network. We deliberately abstract away any form of node heterogeneity, as our primary focus is on the interactions induced by the protocol rather than on resource disparities between nodes.

- The address of a node carries no semantic information about its capabilities, role, or properties, and has no influence on the behavior of the protocol. It is solely used as a unique identifier to enable message routing. Consequently, we abstract node addresses as random but unique values in the range $[0, N-1]$, where $N$ denotes the size of the network.

- Each node _n_ has a list of addresses of other nodes in the network in its local state. This list is called the *partial view*  or the *neighbours* of _n_. We consider that participants have an unbounded memory, although the size of their partial view is bounded by the constant $c$, with $c << N$, and $N$ the size of the network.

- It is necessary to know the address of a node in order to send it a message. Thus, each node communicates only with its direct *neighbours* in the peer-to-peer network.

- When a node receives a message, it can respond to that message even if that node is not in the list of its *neighbours*. This is because we assume that it receives the address of the sender (along with the message).

- Each node executes the same *protocol*.

#definition(title: "Peer-to-Peer Protocol")[Following the definition of distributed protocols from "Introduction to reliable and secure distributed programming" @cachin2011introduction, we define a peer-to-peer protocol as follows:
A peer-to-peer protocol is a distributed algorithm executed by each node in the network that specifies:
1. the local state maintained by a node,
2. the set of messages that can be exchanged between nodes,
3. the rules governing message generation, transmission, and handling
4. the local state transitions performed by a node upon internal events or message reception.

The protocol is executed independently by all nodes. Each node follows the same protocol specification, but may exhibit different behaviors depending on its local state, its partial view of the network, and the messages it receives.
]

=== Execution Model

We assume that each peer-to-peer protocol executed by a node is composed of two main components: an initialization function and a main protocol function.

The initialization function is executed once when a node joins the system. During this phase, the node initializes its local state, including in particular its partial view of the network, i.e., its list of neighbors.

After initialization, the node executes the main protocol logic in the form of an infinite loop. This reflects the fact that peer-to-peer protocols are typically designed to run continuously and do not have a predefined termination condition.

We assume that each iteration of the protocol loop is executed atomically: a node cannot be interrupted in the middle of a protocol cycle, and no two executions of the protocol logic overlap on the same node.

If, during its execution, a node contacts another node, the contacted node processes the incoming request using a background execution thread. The internal scheduling of protocol execution and background message handling is abstracted away. The handling of incoming requests is also assumed to be atomic, and responses are generated and returned instantaneously.

=== Network Primitives

We abstract the underlying physical network, as peer-to-peer algorithms do not directly operate on physical networking mechanisms. We assume that the underlying network provides basic communication primitives required by the overlay network.

In particular, we assume that:
1. the underlying network is connected, i.e., any node can eventually reach any other node,
2. nodes can send messages to other nodes, and messages are routed to their intended destination.

// We assume a reliable communication network: messages are neither lost nor corrupted. 
// Message delivery is asynchronous, with arbitrary but finite delays. 
We abstract away message transmission by assuming that the underlying network is *reliable*. In particular, message delivery is assumed to be instantaneous, and messages are neither lost nor corrupted. Under this abstraction, peer-to-peer algorithms do not need to explicitly account for network-level delays or failures.

=== Time Assumptions


Regarding time and node synchronization, we distinguish two execution models.

In the first model, nodes are fully asynchronous. Each node executes independently and may send messages at arbitrary times, without any form of global synchronization. There is no notion of a shared clock or execution step, and nodes progress according to their own local pace.

In the second model, nodes execute their actions according to a global notion of time, structured into discrete steps called cycles. In this setting, all nodes conceptually perform their actions once per cycle. Two variants of this model can be considered. In the first variant, nodes execute sequentially within a cycle: each node performs its actions one after another, and a cycle is completed once all nodes have finished their execution. While this assumption is not realistic in practical systems, it greatly simplifies modeling and simulation. In the second variant, all nodes execute simultaneously and instantaneously within each cycle. This assumption is also unrealistic in practice, but is commonly adopted to facilitate theoretical analysis and simulation.

// - Nodes execute asynchronously and do not share a global clock.

// === Failure Models

// - Nodes may fail by crashing. A node may crash due to hardware failure, software failure, or network disconnection. Regardless of the cause, the effect is the same: a crashed node cannot send or receive messages, nor can it perform any local computation.

=== Failure Models

We distinguish two main classes of failures in peer-to-peer systems: crash failures and Byzantine failures.

==== Crash Failures

A node may experience a crash failure due to various causes, such as hardware faults, software errors, or permanent network disconnection. From the perspective of the system model, the specific cause of the failure is irrelevant, as the observable effect is always the same.

When a node crashes, it permanently stops executing the protocol. As a consequence, a crashed node no longer updates its local state, does not send messages, and cannot receive or process incoming messages. Any attempt by another node to contact a crashed node results in the absence of a response. We assume that crash failures are permanent: a crashed node never recovers and never rejoins the system. Peer-to-peer protocols must explicitly account for crash failures in order to avoid undesirable behaviors such as deadlocks, where a node waits indefinitely for a response from a failed node.

==== Byzantine Failures

In contrast to crash failures, a Byzantine node remains active but no longer follows the prescribed protocol. Instead, it behaves according to an arbitrary (Byzantine) strategy.

Byzantine behaviors can take many forms, including sending incorrect, inconsistent, or misleading messages, selectively responding to certain nodes, or attempting to disrupt the protocol execution. The common characteristic of Byzantine nodes is that they act maliciously, with the goal of corrupting the protocol execution or degrading the overall behavior of the peer-to-peer network.

Unless stated otherwise, Byzantine nodes are assumed to have full control over their local state and outgoing messages, while still being subject to the constraints of the underlying communication network.
