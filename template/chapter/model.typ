#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/lovelace:0.3.0": *

#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
// #import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

= Model <chap:model>

== Notations

== System Model

// === Nodes

A peer-to-peer system is composed of a set $N$ of nodes, also referred to as peers, that communicate by exchanging messages over a network without relying on any central authority. Messages may represent control information, data items, or application-level payloads, and are assumed to have finite length and arbitrary content.

#definition(title: "Peer to Peer system")[
We use the definition from the book *Peer-to-Peer systems and applications* @wehrle2005peer. A Peer-to-Peer system consists of computing elements that are:
  1. connected by a network,
  2. addressable in a unique way, and
  3. share a common communication protocol.
All computing elements, synonymously called nodes or peers, have comparable
roles and share responsibility and costs for resources.]

// A node models an autonomous computational entity, such as a software process running on a physical or virtual machine, that participates in the peer-to-peer system. Each node may simultaneously act as a client, a server, or both, and is responsible for maintaining a local state, executing protocol logic, and interacting with other nodes according to the communication rules of the system. In this manuscript, the term _node_ is used consistently to refer to such entities, regardless of their physical implementation or functional role within the system.
Formally, we define a node as follows.

#definition(title: "Node")[A node (also called a participant, agent, or peer) is a process that runs on a computing device.
A node has:
1. a memory (a local state)
2. a unique address (network or logical identifier)
3. some computing power
4. the ability to communicate with other nodes by sending messages using the underlying communication network.
]

We assume that:
- Each node _n_ has a list of addresses of other nodes in the network in its local state. This list is called the partial view  or the neighbours of _n_. The size of this list is $c$, with $c << N$, and $N$ the size of the network.
- It is necessary to know the address of a node in order to send it a message. Thus, each node communicates only with its neighbours in the network.

- When a node receives a message, it can respond to that message even if that node is not in the list of its neighbours. This is because we assume that it receives the address of the sender (along with the message).

- Nodes execute asynchronously and do not share a global clock.

- Nodes may fail by crashing. A node may crash due to hardware failure, software failure, or network disconnection. Regardless of the cause, the effect is the same: a crashed node cannot send or receive messages, nor can it perform any local computation.
