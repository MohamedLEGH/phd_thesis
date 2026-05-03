#import "@preview/cetz:0.4.2"

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/lovelace:0.3.0": *

#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
// #import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion


= Model <chap:model>

The peer-to-peer literature encompasses a wide variety of systems, protocols, and
architectures, ranging from structured overlays and to highly dynamic gossip-based protocols. These systems differ in their objectives,
their communication patterns, and their assumptions, but despite this diversity, most peer-to-peer systems rely on a common set of fundamental
principles.

In order to reason about such systems in a systematic way, it is necessary to go beyond
individual protocol descriptions and introduce a unified formal model. The purpose of
this chapter is to define such a model, capturing the essential components and dynamics
shared by a broad class of peer-to-peer systems, while abstracting away implementation-specific details.

This formalization serves two main objectives. First, it provides a common framework for
comparing different peer-to-peer protocols on a principled basis, independently of their
concrete realization. Second, it enables the rigorous analysis of system properties such
as performance, efficiency, robustness, and convergence.

The model introduced in this chapter forms the foundation for the rest of the manuscript.
It will be used to describe execution assumptions, network dynamics, evaluation metrics, and to support both analytical arguments and experimental results presented in the following chapters.

We adopt a bottom-up approach, starting from the node as the fundamental building block of the system, then modeling the peer-to-peer network formed by their interactions, and finally analyzing the emergent phenomena that arise at the network level.
The definitions and abstractions introduced in this chapter follow the general principles of distributed system modeling as presented in _Introduction to Reliable and Secure Distributed Programming_ @cachin2011introduction.

== Node
Nodes constitute the fundamental components of the system. Each node acts as an autonomous entity that executes local computations, maintains an internal state, and interacts with other nodes through the peer-to-peer network. In the literature on distributed systems and peer-to-peer networks, nodes are commonly referred to using different terms such as _processors_, _peers_, or _agents_, depending on the modeling perspective and application domain. In this work, we use the term node to emphasize its generality and to remain independent of any specific implementation or execution environment.

#definition(title: "Node")[
A node (also referred to as a participant, agent, or peer) is an abstract computational entity.

A node is characterized by:
1. a memory, representing its local state, assumed to be arbitrarily large for modeling purposes;
2. computational capabilities, abstracted from physical limitations and assumed to be unbounded.
] <def:node-entity>

#example[
A machine running a BitTorrent client constitutes a node in the BitTorrent system.]

// #definition(title: "Node")[A node (also called a participant, agent, or peer) is a process that runs on a computing device.
// A node has:
// 1. a memory (a local state)
// 2. a unique address (network or logical identifier)
// 3. some computing power
// 4. the ability to communicate with other nodes by sending messages.
// ]
// #example[
// In the BitTorrent protocol, a machine running a BitTorrent client constitutes a node in the peer-to-peer network. The node is identified by its IP address and a PeerID, and communication relies on the underlying TCP/IP network.]
We deliberately abstract away any form of node heterogeneity, as our primary focus is on the interactions induced by the protocol rather than on resource disparities between nodes.

#assumption()[
All nodes are identical in terms of memory or computational capabilities]

A node is executed according to an abstract execution model that captures its behavior independently of any implementation details.
In this model, a node is viewed as a state machine that evolves over time by executing local computations.

Starting from an initial state, the node repeatedly executes a local computation based solely on its current state (i.e., its local memory), and transitions to a new state.
This execution model abstracts away timing, concurrency, and hardware constraints, and focuses exclusively on how local states evolve as a result of computation.

#definition(title: "Node Execution Model")[
A node is modeled as a state machine defined by the tuple  
$(S, s_0, delta)$, where:

- $S$ is the set of all possible local states of the node;
- $s_0 in S$ is the initial state;
- $delta : S arrow.r S$ is a state transition function.

At each execution step, the node applies the transition function $delta$ to its current state $s in S$, producing a new state $s' = delta(s)$.
] <def:node-system>

== Network
In a distributed system, nodes do not operate in isolation but interact with each other through a network.
The network provides the structural substrate that enables communication, coordination, and information exchange between nodes.

In our model, the network captures how nodes are interconnected and how interactions between them are made possible, independently of the specific communication mechanisms or protocols.
By introducing the network abstraction, we move from the behavior of an individual node to the collective behavior of a set of interacting nodes, which is a fundamental step toward understanding the dynamics of peer-to-peer systems.

=== Network Assumptions
A peer-to-peer network is typically implemented as a virtual network, also called an overlay network, on top of a physical network. A clear distinction must therefore be made between the physical network, such as the Internet, and the overlay network. Each node in the overlay network is hosted on a node of the physical network, but the reverse is not necessarily true. Moreover, two neighbouring nodes in the overlay network are not necessarily neighbours in the physical network. An overlay network can itself be implemented on top of another overlay network. For example, the Lightning Network @poon2016bitcoin operates as an overlay on top of the Bitcoin network, which itself relies on the Internet protocol stack.

We abstract the underlying physical network, as peer-to-peer algorithms do not directly operate on physical networking mechanisms. We assume that the underlying network provides basic communication primitives required by the overlay network.

In particular, we assume that:
1. the underlying network is connected, i.e., any node can eventually reach any other node,
2. nodes can send messages to other nodes, and messages are routed to their intended destination.

We abstract away message transmission by assuming that the underlying network is *reliable*. In particular, message delivery is assumed to be instantaneous, and messages are neither lost nor corrupted. Under this abstraction, peer-to-peer algorithms do not need to explicitly account for network-level delays or failures.

These assumptions allow us to focus on the design and analysis of the overlay network and the associated peer-to-peer protocols, independently of the underlying physical infrastructure.

=== Graph Terminology

To model the overlay network, we rely on graph theory, which provides a natural and well-established framework for representing interactions between nodes in a peer-to-peer system. Graph-based models allow us to reason about network structure, connectivity, and information propagation without explicitly accounting for low-level networking or hardware-specific characteristics.

By abstracting the overlay as a graph, nodes are represented as vertices and communication relationships as edges. This abstraction enables a clear and generic analysis of network properties and dynamics, independently of the underlying physical infrastructure.

// Depending on the nature of the connections, a network can be modeled as either undirected or directed: bidirectional connections (e.g., TCP connections) are naturally represented by undirected edges, while unidirectional connections (e.g., UDP connections) are better captured by directed edges. In overlay networks, edges do not correspond to direct physical connections, but rather to a node's virtual view of the network—that is, the subset of nodes that each node is aware of.

In the following, we introduce the standard definitions and notations from graph
theory that will be used throughout this manuscript. These definitions are classical and widely used in the literature on distributed
systems @diestel2016graph @peleg2000distributed.

#definition(title: "Undirected Graph")[
An undirected graph is an ordered pair $G = (V, E)$:
  - $V$, a set of vertices (also called nodes or points);
  - $E subset.eq {{x, y} bar.v x, y in V, x eq.not y}$, a set of edges (also called links or lines), which are unordered pairs of vertices (that is, an edge is associated with two distinct vertices).
] <def:graph>

#figure(
diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0),"", name: "1", radius: 1em)
edge()
edge(label("3"))
node((1,0),"", name: "2", radius: 1em)
edge()
node((1,1),"", name: "3", radius: 1em)
}),
caption: [Example of an undirected graph with three vertices and three edges.]
)

#definition(title: "Directed Graph")[
 A directed graph or digraph is a graph in which edges have orientations. A directed graph is an ordered pair $G = (V, E)$:
  - $V$, a set of vertices (also called nodes or points);
  - $E subset.eq {(x, y) bar.v (x, y) in V², x eq.not y}$, a set of edges (also called directed edges, directed links, directed lines, arrows or arcs) which are ordered pairs of vertices (that is, an edge is associated with two distinct vertices).
  
] <def:digraph>

#figure(  
diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0),"", name: "1", radius: 1em)
edge("->")
edge(label("3"), "->")
node((1,0),"", name: "2", radius: 1em)
edge("->")
node((1,1),"", name: "3", radius: 1em)
}),
caption: [Example of a directed graph with three vertices and three directed edges.]
)


#definition(title: "Path")[
Let $G = (V, E)$ be a graph.
A *path* from a vertex $u in V$ to a vertex $v in V$ is a finite sequence of
vertices $(v_0, v_1, ..., v_k)$ such that:
- $v_0 = u$ and $v_k = v$,
- for all $i in {0, ..., k-1}$, $(v_i, v_(i+1)) in E$.

The *length* of a path is defined as the number of edges it contains, i.e., $k$.
]

#definition(title: "Connected Components")[
Let $G = (V, E)$ be an undirected graph.

- A *connected component* is a maximal subset of nodes $C subset.eq V$ such that for every pair of nodes $u, v in C$, there exists a path connecting $u$ and $v$.

The set of connected components induces a partition of the vertex set $V$. The number of connected components characterizes the fragmentation of the graph.
]

#definition(title: "Strongly and Weakly Connected Components")[
Let $G = (V, E)$ be a directed graph.

- A *strongly connected component (SCC)* is a maximal subset of nodes $C subset.eq V$ such that for every pair of nodes $u, v in C$, there exists a directed path from $u$ to $v$ and from $v$ to $u$.

- A *weakly connected component (WCC)* is a maximal subset of nodes $C subset.eq V$ such that the underlying undirected graph obtained by ignoring edge directions is connected.
]

#definition(title: "Distance")[
Let $G = (V, E)$ be a graph.  
For any two vertices $u, v in V$, the distance between $u$ and $v$, denoted by
$"dist"_G (u, v)$, is defined as the length of a shortest path between $u$
and $v$ in $G$.

If no path exists between $u$ and $v$, the distance is defined as
$"dist"_G (u, v) = +infinity$.

This definition naturally extends to sets of vertices.  
For two subsets $U, W subset.eq V$, the distance between $U$ and $W$ is defined as
$
"dist"_G (U, W) = min { "dist"_G (u, w) | u in U, w in W }
$
]

#definition(title: "Distance (in a directed graph)")[
  Let $G = (V, E)$ be a directed graph.
  A *directed path* from a vertex $u in V$ to a vertex $v in V$
  is a sequence of vertices $(u = v_0, v_1, dots, v_k = v)$
  such that $(v_i, v_(i+1)) in E$ for all $0 <= i < k$.

  The distance from $u$ to $v$, denoted by $"dist"_G (u, v)$,
  is defined as the minimum length (number of edges) of any directed path
  from $u$ to $v$ that *respects the orientation of the edges*.
  If no such directed path exists, we set $"dist"_G (u, v) = +infinity$.

  In general, the distance in a directed graph is *not symmetric*:
  $"dist"_G (u, v)$ may differ from $"dist"_G (v, u)$,
  and one of them may be finite while the other is infinite.
]

#definition(title: "Average Path Length")[
Let $G = (V, E)$ be a graph.

The *average path length* of the network, denoted by $a(G)$, is defined as:
$
a(G) =
sum_(u, v in V, u eq.not v)
("dist"_G (u, v))
/
(|V| (|V| - 1))
$
] <def:averagepathlength>

#definition(title: "Diameter")[
  Let $G = (V, E)$ be a graph.
  The *diameter* of $G$, denoted by $"diam"(G)$, is defined as the maximum
  distance between any pair of vertices in $V$:

  $
  "diam"(G) = max_(u, v in V) "dist"_G (u, v)
  $
] <def:diameter>

#definition(title: "Neighborhood")[
Let $G = (V, E)$ be an undirected graph and let $v in V$ be a vertex.

The *neighborhood* of $v$, denoted $"neigh"_G (v)$, is the set of vertices that are
adjacent to $v$, that is, vertices connected to $v$ by an edge.

Equivalently, the neighborhood of $v$ can be defined as the set of vertices at
distance exactly one from $v$:
$
"neigh"_G (v) = { u in V | (u, v) in E } = { u in V | "dist"_G(u, v) = 1 }.
$
]


#definition(title: "Successors and Predecessors (Directed Graphs)")[
Let $G = (V, E)$ be a directed graph and let $v in V$ be a vertex.

- The *successors* of $v$, denoted $"succ"_G (v)$, is the set of vertices that
can be reached from $v$ by a single directed edge:
$
"succ"_G (v) = { u in V | (v, u) in E }.
$

- The *predecessors* of $v$, denoted $"pred"_G (v)$, is the set of vertices that
have a directed edge toward $v$:
$
"pred"_G (v) = { u in V | (u, v) in E }.
$

Equivalently, these sets correspond to vertices at directed distance one from
or to $v$, respectively.
]

#definition(title: "Degree")[
Let $G = (V, E)$ be an undirected graph and let $v in V$ be a vertex.

The *degree* of vertex $v$ in graph $G$, denoted by $"degree"_G (v)$, is defined as
the number of vertices adjacent to $v$, or equivalently, the size of its neighborhood:
$
"degree"_G (v) = |"neigh"_G (v)|
$
] <def:degree>

#definition(title: "In-degree and Out-degree")[
Let $G = (V, E)$ be a directed graph and let $v in V$ be a vertex.

The *out-degree* of $v$ in $G$, denoted by $"outdegree"_G (v)$, is the number of successors of $v$:
$
"outdegree"_G (v) = |"succ"_G (v)|
$

The *in-degree* of $v$ in $G$, denoted by $"indegree"_G (v)$, is the number of predecessors of $v$:
$
"indegree"_G (v) = |"pred"_G (v)|
$
] <def:inoutdegree>

#definition(title: "k-Neighborhood")[
Let $G = (V, E)$ be an undirected graph and let $v in V$ be a vertex.  

The *k-neighborhood* of $v$ in $G$, denoted $"neigh"_G^k (v)$, is the set of vertices at distance exactly $k$ from $v$:
$
"neigh"_G^k (v) = { u in V | "dist"_G (v, u) = k }
$
]

#definition(title: "k-Successors and k-Predecessors (Directed Graphs)")[
Let $G = (V, E)$ be a directed graph and let $v in V$ be a vertex.

- The *k-successors* of $v$, denoted $"succ"_G^k (v)$, is the set of vertices reachable from $v$ by a directed path of length exactly $k$:
$
"succ"_G^k (v) = { u in V | "dist"_G (v, u) = k }
$

- The *k-predecessors* of $v$, denoted $"pred"_G^k (v)$, is the set of vertices from which $v$ can be reached by a directed path of length exactly $k$:
$
"pred"_G^k (v) = { u in V | "dist"_G (u, v) = k }
$
]

#definition(title: "Clustering Coefficient")[
Let $G = (V, E)$ be a graph. For any vertex $v in V$ with $"degree"_G (v) >= 2$,
the local clustering coefficient of $v$, denoted $C(v)$, is defined as the fraction
of pairs of neighbours of $v$ that are themselves connected:

$
C(v) = frac(|{ {u, w} in E | u in "neigh"_G (v), w in "neigh"_G (v) }|, binom("degree"_G (v), 2))
$

For vertices with $"degree"_G (v) < 2$, the clustering coefficient is conventionally
set to $C(v) = 0$.

The global clustering coefficient of $G$, denoted $C(G)$, is defined as the average
local clustering coefficient over all vertices:

$
C(G) = frac(1, |V|) sum_(v in V) C(v)
$

The global clustering coefficient takes values in $[0, 1]$, where $C(G) = 0$ indicates
that no two neighbours of any node are connected, and $C(G) = 1$ indicates that every
neighbourhood forms a complete subgraph.
] <def:clusteringcoef>

Having established the formal vocabulary of graph theory --- vertices,
edges, paths, distances, degree and clustering coefficient --- we now turn to the study of
specific network models. The following section surveys the principal
graph structures and generative models encountered in the peer-to-peer
and distributed systems literature, ranging from deterministic
topologies defined by explicit construction rules to random models
whose structure emerges from probabilistic processes.

=== Overlay Network Modeling

With the basic concepts of graph theory in place, we can now formalize the representation of an overlay network.  
In our model, the overlay network is abstracted as a graph $G = (V, E)$, where each vertex represents a participant (node) in the system, and edges represent the communication links between nodes.

Each system node is thus associated with a vertex in the graph, and its unique address serves as the identifier of that vertex. This correspondence allows us to leverage graph-theoretic notions to describe and analyze the network's structure and connectivity.

#definition(title: "Node Address")[
Each node in the system is assigned a unique address, also referred to as its identifier.  
Node addresses are drawn from the finite set  
$S = {0, dots, N-1}$,  
where $N$ denotes the total number of nodes in the network.  
This assignment ensures that every node can be uniquely identified within the system.
]

#assumption[The address of a node carries no semantic information about its capabilities, role, or properties, and has no influence on the behavior of the node.]

==== Communication Channels

In a peer-to-peer system, nodes interact by sending messages to one another.  
We abstract away the technical details of message transmission, such as bandwidth limits, latency, or packet loss. Instead, we introduce the notion of a *communication channel* as a conceptual link that allows a node to deliver messages to another node.

Channels can be *bidirectional*, similar to a TCP connection, where messages can flow in both directions, or *unidirectional*, similar to a UDP link, where messages flow in a single direction. In our model, a channel exists simply if a node can send a message to another node.  

#definition(title: "Bidirectional Communication Channel")[
A bidirectional communication channel between two nodes $u$ and $v$ allows both nodes to send messages to each other.  
In the graph representation of the network, a bidirectional channel corresponds to an undirected edge $\{u, v\} in E$ connecting the two vertices associated with the nodes.
]

#definition(title: "Unidirectional Communication Channel")[
A unidirectional communication channel from node $u$ to node $v$ allows $u$ to send messages to $v$, but not necessarily the other way around.  
In the graph representation, a unidirectional channel corresponds to a directed edge $(u, v) in E$ from the vertex representing $u$ to the vertex representing $v$.
]

==== Partial View

In large-scale peer-to-peer networks, it is unrealistic for a node to maintain knowledge of all other nodes in the system.  
Instead, each node maintains a *partial view*, which is a subset of nodes it is aware of and can communicate with.  
This partial view is stored in the node's local state as a list of node addresses.  

Although we consider that nodes have unbounded memory for abstraction purposes, the size of the partial view is bounded by a constant $c$, with $c << N$, where $N$ is the total number of nodes in the network.  
In the graph representation of the network, the partial view of a node corresponds to its *neighborhood*, i.e., the set of nodes connected to it by edges.

#definition(title: "Partial View")[
The *partial view* of a node $v$, denoted $P(v)$, is the set of nodes that $v$ maintains in its local state and can send messages to, where $P(v) subset.eq V$ is a subset of all nodes in the network.

- The size of the partial view is bounded: $|P(v)| <= c$, where $c$ is a constant much smaller than $N$, the total number of nodes.  
- In the network graph $G = (V, E)$ with undirected channels:  
  $
  P(v) = "neigh"_G(v)
  $
] <def:partial-view>

#remark[
For directed channels, the partial view corresponds to the set of successors of $v$:  
$
P(v) = "succ"_G(v)
$  
i.e., nodes to which $v$ can send messages. A node does not necessarily maintain a list of its predecessors, only its successors.
]

// - Each node _n_ has a list of addresses of other nodes in the network in its local state. This list is called the *partial view*  or the *neighbours* of _n_. We consider that participants have an unbounded memory, although the size of their partial view is bounded by the constant $c$, with $c << N$, and $N$ the size of the network.

#assumption()[
It is assumed that a node must know the address of another node in order to send it a message.  
Consequently, each node communicates only with its neighbours at distance 1 in the overlay network.
]

#assumption(title: "Directed Channel Reply")[
In the case of a directed communication channel, a node can respond to a received message
even if the sender is not in its partial view (successors).  
This is because each message carries the address of the sender.
]



// == Peer-to-Peer System Model
// A peer-to-peer system is composed of a set $N$ of peers, also referred to as nodes, that communicate by exchanging messages over a network without relying on any central authority. Messages may represent control information, data items, or application-level payloads, and are assumed to have finite length and arbitrary content.

// #definition(title: "Peer to Peer system")[
// We use the definition from the book *Peer-to-Peer systems and applications* @wehrle2005peer. A Peer-to-Peer system consists of computing elements that are:
//   1. connected by a network,
//   2. addressable in a unique way, and
//   3. share a common communication protocol.
// All computing elements, synonymously called nodes or peers, have comparable
// roles and share responsibility and costs for resources.] <def:p2p-system>

// #example[The BitTorrent network.]

==== Protocol

In a distributed system, each node executes a *protocol* that governs its behavior and interactions with other nodes.  
In this work, we do not consider protocols at the underlying physical or network layers (e.g., routing, congestion control, or transport mechanisms). Instead, we assume that nodes can exchange messages through abstract communication channels, as introduced earlier.

At the overlay level, all nodes execute the same protocol. This protocol defines how nodes process incoming messages, update their local state, and decide when and to whom messages are sent. It therefore captures the collective logic of the peer-to-peer system and determines how global network properties emerge from local interactions.

#definition(title: "Peer-to-Peer Protocol")[
A peer-to-peer protocol is a distributed algorithm executed by each node in the network that specifies:
1. the local state maintained by a node,
2. the set of messages that can be exchanged between nodes,
3. the rules governing message generation, transmission, and handling
4. the local state transitions performed by a node upon internal events or message reception.
] <def:p2p-protocol>

The protocol is executed independently by all nodes. Each node follows the same protocol specification, but may exhibit different behaviors depending on its local state, its partial view of the network, and the messages it receives. In our abstract model, we do not consider how the protocol is concretely implemented (e.g., programming language, runtime environment, or communication framework).  
We focus solely on the *pseudocode* of the protocol, which specifies the rules governing state transitions and message exchanges.

This definition is consistent with the execution model introduced earlier, where a node is modeled as a state machine.  
In this framework, the peer-to-peer protocol corresponds to the state transition function executed by each node.  
Given the current local state of a node and the occurrence of an event (e.g., message reception or internal trigger), the protocol determines the next local state and the set of messages to be emitted. Thus, we assume that for a given local state and a given event, all nodes react deterministically and in exactly the same way.

In addition to their local state, nodes share a common knowledge of a set of *global parameters* defined by the protocol.  
These parameters are identical for all nodes and remain constant throughout the execution of the system.  
They capture configuration choices of the protocol, such as bounds on local resources or structural constraints, and ensure that all nodes operate under the same assumptions.  
For instance, the maximum size of a node’s partial view is a global parameter known to all nodes.

#definition(title: "Global Protocol Parameter")[
A *global protocol parameter* is a constant value that is known to all nodes in the system and shared across the entire network.

Formally, let $P$ denote the set of global parameters of a protocol.  
Each parameter $p in P$ has a fixed value that is identical for all nodes and does not depend on the local state of any node.
]

#remark[The pseudocode of the protocol itself can be viewed as a global parameter of the system.]

We assume that each peer-to-peer protocol executed by a node is composed of two main components: an initialization function and a main protocol function.

The initialization function is executed once when a node joins the system. During this phase, the node initializes its local state, including in particular its partial view of the network, i.e., its list of neighbors.

After initialization, the node executes the main protocol logic in the form of an infinite loop. This reflects the fact that peer-to-peer protocols are typically designed to run continuously and do not have a predefined termination condition.

We assume that each iteration of the protocol loop is executed atomically: a node cannot be interrupted in the middle of a protocol cycle, and no two executions of the protocol logic overlap on the same node.

If, during its execution, a node contacts another node, the contacted node processes the incoming request using a background execution thread. The internal scheduling of protocol execution and background message handling is abstracted away. The handling of incoming requests is also assumed to be atomic, and responses are generated and returned instantaneously.

== System

Having defined the behavior of individual nodes and the structure of the overlay network, we can now formalize the system as a whole.

At any given time, the state of the peer-to-peer system is entirely determined by the collection of local states of all nodes.
In other words, the *global state* of the system corresponds to the concatenation of the local states maintained by each node.

#definition(title: "Global State")[
Let $V$ be the set of nodes in the system.

The *global state* of the system is defined as the tuple:
$
S_"global" = (s_v)_(v in V)
$
where $s_v in S_v$ is the current local state of node $v$, as defined in @def:node-system.
] <def:global-system>

=== Synchronization

When modeling the evolution of a distributed system, it is necessary to specify how nodes progress from one state to another.  
Since the system consists of multiple autonomous agents, this raises the question of synchronization between nodes.

In our model, we abstract away from synchronization issues at the physical or network layers.  
We assume that message transmission is instantaneous and reliable, i.e., messages are neither delayed nor lost.  
As a consequence, we do not consider timing, buffering, or failures at the communication level.

At the overlay level, however, synchronization still plays a conceptual role.  
In real-world peer-to-peer systems, nodes operate fully asynchronously: there is no global clock, and each node evolves at its own pace based on local events and message arrivals.  
While this behavior accurately reflects practical systems, it makes mathematical analysis and simulation significantly more complex.

To enable a tractable and precise formalization, we introduce an abstract notion of time based on *protocol steps* and *protocol cycles*.  
These notions do not represent real time, but rather logical execution units that allow us to reason about the global evolution of the system in a structured manner.

#definition(title: "Protocol Step")[
A *protocol step* is defined as a single execution of the protocol pseudocode by one node.

During a protocol step, a node:
1. processes an internal event or a received message,
2. applies the protocol's state transition rules,
3. updates its local state, and
4. possibly emits messages to other nodes.
]

#assumption[
We assume that each protocol step takes the same amount of time, regardless of the node executing it or the updates performed during the step.

In this model, we abstract away from execution time and computational cost.
]

#definition(title: "Protocol Cycle")[
A *protocol cycle* is defined as a logical execution round in which every node in the network executes exactly one protocol step.

Formally, a protocol cycle consists of a sequence of protocol steps such that each node in $V$ executes the protocol once.
] <def:protocol-cycle>

Regarding the execution of a protocol cycle, we distinguish between two possible execution models.

In the *synchronous cycle model*, all nodes execute their protocol step simultaneously.  
Each node computes its state transition using its local state and the messages produced during the previous cycle.  
All state updates and message emissions take effect only at the end of the cycle.  
This model corresponds to a fully synchronous execution, where cycles act as global logical barriers.

In the *sequential cycle model*, nodes execute their protocol steps one after another within a cycle, following a random order.  
Each node updates its local state immediately upon execution and may emit messages that can be observed by nodes executing later in the same cycle.  
As a result, the state of the system may evolve during the cycle itself.

=== Self Organization

Beyond local execution semantics, many peer-to-peer protocols are designed to achieve 
specific objectives at the level of the system as a whole. While each node executes the 
protocol independently and relies solely on local information, the collective behavior 
of the system may exhibit coordinated dynamics that serve a common goal. Typical examples include decentralized aggregation protocols, 
where nodes collaboratively compute global statistics such as the average, sum, or 
maximum of locally held values, as well as classical coordination tasks such as leader 
election or consensus.

These protocols are often characterized by a notion of convergence: starting from an 
arbitrary initial global state, the system is expected to evolve toward a stable or 
desirable global configuration that satisfies the protocol’s objective. This convergence 
is achieved without centralized control and emerges from repeated local interactions 
between nodes constrained by the evolving network topology.

#definition(title: "Global Objective")[
A peer-to-peer protocol is said to pursue a global objective if there exists a set 
of desirable global states $S^*$ such that the protocol aims to drive the system toward 
this set through local interactions.
] <def:global-objective>

#definition(title: "Convergence")[
The protocol is said to converge if, for any initial global state $S(0)$, the sequence 
of global states $S(t)_(t >= 0)$ produced by the protocol satisfies:
$
exists T >= 0 "such as" forall t >= T, S(t) in S^*
$ 

Convergence may be exact or approximate, and may hold deterministically or with high 
probability, depending on the assumptions made on the protocol execution and the 
network dynamics.
] <def:convergence>

=== Randomness

Our system model is fundamentally deterministic: nodes execute protocol logic based on local state and received messages, without access to external sources of entropy or true random oracles. This design choice ensures reproducibility of executions, simplifies formal reasoning about protocol correctness, and avoids reliance on potentially biased or manipulable randomness sources in adversarial environments.

However, certain protocol mechanisms benefit from behaviors that *appear* random. To support such use cases without introducing non-determinism, we allow nodes to locally instantiate a pseudo-random number generator (PRNG, see @def:prng) when the protocol specification explicitly requires randomized choices.

#definition(title: "Pseudo-Random Number Generator")[
Let $λ in NN$ be a security parameter.

A pseudo-random number generator (PRNG) is a deterministic algorithm

$
G : {0,1}^λ -> {0,1}^*
$

such that:

- (Determinism) For any seed $s in {0,1}^λ$, the output $G(s)$ is uniquely determined.
  In particular, two executions of $G$ on the same seed produce the same output.

- (Pseudo-randomness) When the seed $s$ is sampled uniformly at random from
  ${0,1}^λ$, the output $G(s)$ is computationally indistinguishable from
  a truly random bitstring of the same length.
] <def:prng>


=== Dynamic Network

So far, we have considered the overlay network as a static structure on which nodes execute a protocol over time.  
However, in many peer-to-peer systems, the network topology itself evolves as the system runs. As nodes repeatedly execute the protocol, both the local views of nodes and the global network topology may change over time.
Thus a first level of dynamicity arises from the protocol execution itself. After each execution of the protocol loop, a node may update its partial view of the network, for instance by adding, removing, or replacing neighbors. As a consequence, the set of outgoing edges of a node in the overlay graph may change from one protocol cycle to another. At this level of dynamicity, the set of nodes remains constant, and only the edge set of the graph evolves over time.

==== Churn

A second level of dynamicity is introduced by churn @stutzbach2006understanding, that is, the dynamic arrival and departure of nodes in the system. We model churn as a temporally localized phenomenon rather than a permanent one. Specifically, churn occurs during a predefined period spanning several protocol cycles.

During a protocol cycle affected by churn, a given fraction of nodes is selected uniformly at random and disconnected from the network, similarly to permanent crash failures. These nodes are assumed to leave the system definitively and never rejoin. Within the same cycle, an equal number of new nodes joins the network. Each joining node executes the initialization function and subsequently participates in the protocol execution as a regular node.

After the churn period ends, no further nodes join or leave the system. The protocol continues to execute on a fixed set of nodes, allowing the network to evolve solely under the effect of the protocol logic. This post-churn phase is used to observe whether, and under which conditions, the system is able to recover from the instability induced by churn and converge back to a stable configuration.

This modeling choice reflects the fact that continuous churn keeps the system in a permanently unstable state. By separating churn phases from stabilization phases, we can explicitly study the resilience and self-healing properties of the peer-to-peer protocol.

In our model, such dynamics are captured by allowing the network graph $G = (V, E)$ to vary across protocol cycles.  
Both sources of dynamicity—updates of local views driven by protocol execution, and the addition/removal of nodes due to churn—contribute to changes in the network topology over time.  
Consequently, the overlay network can be naturally represented as a *time-varying graph* (or temporal graph), which formalizes the evolving set of nodes and edges as a function of time, as discussed in the literature @holme2012temporal.  
This representation allows us to treat the structure of the overlay network as part of the system state, fully integrating network dynamics into the global evolution of the system.

// In our model, such dynamics are captured by allowing the network graph $G = (V, E)$ to vary across protocol cycles, and thus the representation of our overlay is a time-varying graph (or temporal graph), as defined in the literature @holme2012temporal.
// As a result, the structure of the overlay network becomes part of the system state and participates in the global evolution of the system.

#definition(title: "Time-Varying Graph with churn")[
A time-varying graph is a tuple $G = (V, E, T)$ where:
- $T$ is a time domain, which is discrete;
- $V(t)$ is the set of vertices present at time $t in T$;
- $E(t) subset.eq {{x, y} | x, y in V(t), x eq.not y}$ is the set of edges present at time $t$.

The graph $G(t) = (V(t), E(t))$ represents the network topology at time $t$. The evolution of the graph over time captures the appearance and disappearance of vertices and edges.
] <def:tvg>

== Failure Models 

In the previous sections, we have formalized the behavior of nodes, the evolution of the overlay network, and the dynamics of protocol execution in terms of steps and cycles.
Having established this abstract execution framework, we now consider the possibility that nodes may fail during the system evolution.
Node failures are an important source of perturbation in peer-to-peer systems and can affect both local computations and global network dynamics.

In this work, we explicitly situate our analysis within standard fault models from distributed computing, in order to precisely characterize the assumptions under which the protocol operates. We adopt the terminology and notational conventions introduced by Raynal in *Fault-Tolerant Message-Passing Distributed Systems: An Algorithmic Approach* @raynal2018fault.

We distinguish two main classes of failures in peer-to-peer systems: crash failures and Byzantine failures.

=== Crash Failures

A *crash failure* occurs when a node permanently stops executing the protocol. This may result from hardware faults, software errors, or permanent network disconnection. From the perspective of our abstract model, the specific cause is irrelevant; what matters is the observable effect: a crashed node ceases all activity.

We assume that crash failures are modeled using the *Crash-prone Synchronous Message-Passing model*, denoted *CSMP ⟨n, t⟩ [∅]* (following @raynal2018fault), where:

- *n* is the total number of nodes in the system,
- *t* is the maximum number of nodes that may crash during execution,
- [∅] indicates that no additional failure detectors or oracles are assumed.

Under this model, the system is synchronous, communication is reliable, and nodes may only fail by crashing.

When a node crashes:

1. it no longer updates its local state,
2. it cannot send messages,
3. it cannot receive or process incoming messages.

Any attempt by another node to contact a crashed node results in the absence of a response.
We assume that crash failures are permanent: once a node crashes, it never recovers and never rejoins the system.
In our model, a node can only crash at the beginning of a protocol cycle, never in the middle of a cycle. This assumption simplifies the analysis by ensuring that protocol steps and cycles remain atomic.

#assumption[
A node can detect that one of its neighbors has crashed if the neighbor does not respond to a message.
Since message transmission is assumed to be instantaneous and reliable, the absence of an immediate response is interpreted as a crash.
]

=== Byzantine Failures

In contrast to crash failures, a Byzantine node remains active but no longer follows the prescribed protocol. Instead, it behaves according to an arbitrary (Byzantine) strategy.

Byzantine behaviors can take many forms, including sending incorrect, inconsistent, or misleading messages, selectively responding to certain nodes, or attempting to disrupt the protocol execution. The common characteristic of Byzantine nodes is that they act maliciously, with the goal of corrupting the protocol execution or degrading the overall behavior of the peer-to-peer network.

Byzantine failures are modeled using the *Byzantine Synchronous Message-Passing model*, denoted *BSMP ⟨n, t⟩ [∅]* (following @raynal2018fault), where:

- *n* is the total number of nodes in the system,
- *t* is the maximum number of Byzantine nodes,
- [∅] indicates that no additional assumptions (such as authentication, signatures, or trusted components) are made beyond synchrony and reliable communication.

Unless stated otherwise, Byzantine nodes are assumed to have full control over their local state and outgoing messages, while still being subject to the constraints of the underlying communication network.

== Conclusion

In this chapter, we have introduced a formal framework for modeling peer-to-peer systems.  
Starting from the node as the fundamental computational entity, we modeled each participant as a state machine executing a common protocol and interacting with others through abstract communication channels.

We then represented the overlay network as a graph, whose vertices correspond to nodes and whose edges capture communication relationships.  
By introducing partial views, protocol steps, protocol cycles, and synchronization models, we provided a structured execution model that enables precise reasoning about the global evolution of the system.  
This framework was further extended to dynamic settings, where the overlay topology evolves over time due to protocol-driven neighbor updates and churn, naturally leading to a representation in terms of time-varying (temporal) graphs.

Within this abstraction, global system behavior emerges from repeated local interactions, allowing us to reason about properties such as self-organization, convergence, resilience, and fault tolerance in a principled manner.  
Modeling failures explicitly, and in particular crash failures, further grounds the framework in realistic peer-to-peer settings while preserving analytical tractability.

Having established this unified and abstract modeling framework—where a peer-to-peer system is viewed as a temporal graph whose nodes are state machines—we are now in a position to present our contribution.  
In the following chapter, we introduce a novel peer-to-peer protocol for unstructured networks.  
This protocol leverages the local execution model described above to induce desirable global properties, and exhibits innovative features in terms of organization, robustness, and emergent behavior.
