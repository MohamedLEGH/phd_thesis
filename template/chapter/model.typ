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
their communication patterns, and their assumptions.
Despite this diversity, most peer-to-peer systems rely on a common set of fundamental
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

== Node
Nodes constitute the fundamental components of the system. Each node acts as an autonomous entity that executes local computations, maintains an internal state, and interacts with other nodes through the peer-to-peer network. In the literature on distributed systems and peer-to-peer networks, nodes are commonly referred to using different terms such as _processors_, _peers_, or _agents_, depending on the modeling perspective and application domain. In this work, we use the term node to emphasize its generality and to remain independent of any specific implementation or execution environment.

#definition(title: "Node")[
A node (also referred to as a participant, agent, or peer) is an abstract computational entity.

A node is characterized by:
1. a memory, representing its local state, assumed to be arbitrarily large for modeling purposes;
2. computational capabilities, abstracted from physical limitations and assumed to be unbounded.
]
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
]

== Network
In a distributed system, nodes do not operate in isolation but interact with each other through a network.
The network provides the structural substrate that enables communication, coordination, and information exchange between nodes.

In our model, the network captures how nodes are interconnected and how interactions between them are made possible, independently of the specific communication mechanisms or protocols.
By introducing the network abstraction, we move from the behavior of an individual node to the collective behavior of a set of interacting nodes, which is a fundamental step toward understanding the dynamics of peer-to-peer systems.

=== Network Assumptions

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

#example[
  An undirected graph with three vertices and three edges. 
]
#diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0),"", name: "1", radius: 1em)
edge()
edge(label("3"))
node((1,0),"", name: "2", radius: 1em)
edge()
node((1,1),"", name: "3", radius: 1em)
})

#definition(title: "Directed Graph")[
 A directed graph or digraph is a graph in which edges have orientations. A directed graph is an ordered pair $G = (V, E)$:
  - $V$, a set of vertices (also called nodes or points);
  - $E subset.eq {(x, y) bar.v (x, y) in V², x eq.not y}$, a set of edges (also called directed edges, directed links, directed lines, arrows or arcs) which are ordered pairs of vertices (that is, an edge is associated with two distinct vertices).
  
] <def:digraph>

#example[
  A directed graph with three vertices and three directed edges. 
]
#diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0),"", name: "1", radius: 1em)
edge("->")
edge(label("3"), "->")
node((1,0),"", name: "2", radius: 1em)
edge("->")
node((1,1),"", name: "3", radius: 1em)
})

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
]

#definition(title: "Diameter")[
  Let $G = (V, E)$ be a graph.
  The *diameter* of $G$, denoted by $"diam"(G)$, is defined as the maximum
  distance between any pair of vertices in $V$:

  $
  "diam"(G) = max_(u, v in V) "dist"_G (u, v)
  $
]

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
]

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
]

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



// other metrics

// // === Graph Theory
// In order to study overlay networks, it is useful to adopt a mathematical representation that allows formalizing and comparing their properties. Graph theory provides a natural framework for this purpose. A network can be represented as a graph, where nodes correspond to servers or users, and edges represent connections between them. 

==== Standard Graph Structures
In network analysis, certain graph topologies frequently appear due to their structural properties. These standard structures serve as fundamental models for understanding connectivity, routing, and aggregation behavior in distributed systems.  
Each topology has distinct characteristics that can influence how information propagates, how resilient the network is to failures, and how algorithms perform. Below, we summarize some of the most commonly studied graph structures along with their defining properties.


#figure(
table(
  columns: (1fr, 2fr),
  inset: 10pt,
  align: horizon,

  table.header(
    [*Graph Structure*], [*Description*],
  ),

  [Complete Graph],
  [Every node is connected to every other node, representing maximal connectivity.],

  [Star Graph],
  [A central node is connected to all the other nodes.],

  [Ring Graph],
  [Nodes form a closed loop, each connected to two neighbors.],

  [Grid / Lattice Graph],
  [Nodes arranged in a 2D or multi-dimensional grid, each node connected to its immediate neighbors.],

  [Tree Graph],
  [Hierarchical structure with parent-child relationships, no cycles.],

  [Random Graph],
  [Edges between nodes are placed randomly according to some probability distribution.],

  [Bipartite Graph],
  [Nodes are divided into two disjoint sets, with edges only between sets.],

), caption: [Standard graph structures and their main characteristics.],
) <tab:standard-graph-structures>


// === Network components
=== Overlay Network Modeling

Having introduced the fundamental mathematical concepts from graph theory, we can now formalize the representation of an overlay network. In our model, the network is abstracted as a graph $G = (V, E)$, where nodes correspond to the participants of the system and edges capture the communication links between them. 
// This formalization allows us to rigorously describe the structure of the network, analyze connectivity and neighborhood relationships, and apply the previously defined metrics such as distance, degree, and connected components. By doing so, we provide a unified framework to reason about overlay networks independently of the underlying physical infrastructure.

We now relate the nodes of the system to the graph representation of the network. Each system node corresponds to a vertex in the graph $G = (V, E)$. The unique address of a node serves as the identifier of the corresponding graph vertex.

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
]

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
A peer-to-peer system is composed of a set $N$ of peers, also referred to as nodes, that communicate by exchanging messages over a network without relying on any central authority. Messages may represent control information, data items, or application-level payloads, and are assumed to have finite length and arbitrary content.

#definition(title: "Peer to Peer system")[
We use the definition from the book *Peer-to-Peer systems and applications* @wehrle2005peer. A Peer-to-Peer system consists of computing elements that are:
  1. connected by a network,
  2. addressable in a unique way, and
  3. share a common communication protocol.
All computing elements, synonymously called nodes or peers, have comparable
roles and share responsibility and costs for resources.] <def:p2p-system>

#example[The BitTorrent network.]

A peer-to-peer network is typically implemented as a virtual network, also called an overlay network, on top of a physical network. A clear distinction must therefore be made between the physical network, such as the Internet, and the overlay network. Each node in the overlay network is hosted on a node of the physical network, but the reverse is not necessarily true. Moreover, two neighbouring nodes in the overlay network are not necessarily neighbours in the physical network. An overlay network can itself be implemented on top of another overlay network. For example, the Lightning Network @poon2016bitcoin operates as an overlay on top of the Bitcoin network, which itself relies on the Internet protocol stack.


// === Dynamicity
// churn
// === Time-Varying Graphs

Many real-world distributed systems are inherently dynamic: communication links may appear or disappear over time, and participating entities may join or leave the system. To capture such dynamics, static graph models are insufficient. Time-varying graphs (TVGs) extend classical graph theory by explicitly modeling the temporal evolution of vertices and edges.

Time-varying graphs are particularly well suited for modeling peer-to-peer systems, where the network topology is not fixed. In such systems, the set of nodes and the set of communication links evolve over time due to two main factors. First, the peer-to-peer protocol itself may actively modify the overlay topology, for instance by adding, removing, or replacing neighbors as part of its maintenance or optimization mechanisms. Second, the system is subject to churn, where nodes may join or leave the network dynamically, which directly affects both the vertex set and the edge set.

#definition(title: "Time-Varying Graph")[
A time-varying graph is a tuple $G = (V, E, T)$ where:
- $T$ is a time domain, which may be discrete or continuous;
- $V(t)$ is the set of vertices present at time $t in T$;
- $E(t) subset.eq {{x, y} | x, y in V(t), x eq.not y}$ is the set of edges present at time $t$.

The graph $G(t) = (V(t), E(t))$ represents the network topology at time $t$. The evolution of the graph over time captures the appearance and disappearance of vertices and edges.
] <def:tvg>

We model peer-to-peer networks as time-varying graphs, where the evolution of the graph reflects both protocol-driven topology changes and node churn.

#definition(title: "Peer-to-Peer Network")[
A peer-to-peer (P2P) network is modeled as a time-varying directed graph $G = (V, E, T)$, where the dynamics of the graph capture both node churn and protocol-driven topology evolution.

At any time $t in T$:
- the vertex set $V(t)$ represents the nodes (or peers) currently participating in the network;
- the edge set $E(t) subset.eq V(t) times V(t)$ represents the directed communication links between nodes at time $t$.

The graph allows self-loops, i.e., edges of the form $(x, x)$. However, multiple edges between the same ordered pair of vertices are not allowed.

The cardinality of $V(t)$ may vary over time due to peer arrivals and departures, a phenomenon commonly referred to as _churn_. Similarly, the edge set $E(t)$ evolves as peers establish or terminate connections according to the peer-to-peer protocol.

A directed edge $(x, y) in E(t)$ indicates that peer $x$ can send messages directly to peer $y$ at time $t$. The resulting graph $G(t) = (V(t), E(t))$ represents the instantaneous overlay topology of the peer-to-peer network.
] <def:p2p>

// === Peer to Peer Network



// A node models an autonomous computational entity, such as a software process running on a physical or virtual machine, that participates in the peer-to-peer system. Each node may simultaneously act as a client, a server, or both, and is responsible for maintaining a local state, executing protocol logic, and interacting with other nodes according to the communication rules of the system. In this manuscript, the term _node_ is used consistently to refer to such entities, regardless of their physical implementation or functional role within the system.
// Formally, we define a node as follows.
Having defined the notion of a peer-to-peer network, we now formalize the notion of a node, which constitutes the basic computational entity of the system.
- Each node executes the same *protocol*.

#definition(title: "Peer-to-Peer Protocol")[Following the definition of distributed protocols from "Introduction to reliable and secure distributed programming" @cachin2011introduction, we define a peer-to-peer protocol as follows:
A peer-to-peer protocol is a distributed algorithm executed by each node in the network that specifies:
1. the local state maintained by a node,
2. the set of messages that can be exchanged between nodes,
3. the rules governing message generation, transmission, and handling
4. the local state transitions performed by a node upon internal events or message reception.

The protocol is executed independently by all nodes. Each node follows the same protocol specification, but may exhibit different behaviors depending on its local state, its partial view of the network, and the messages it receives.
]

== Execution Model

We assume that each peer-to-peer protocol executed by a node is composed of two main components: an initialization function and a main protocol function.

The initialization function is executed once when a node joins the system. During this phase, the node initializes its local state, including in particular its partial view of the network, i.e., its list of neighbors.

After initialization, the node executes the main protocol logic in the form of an infinite loop. This reflects the fact that peer-to-peer protocols are typically designed to run continuously and do not have a predefined termination condition.

We assume that each iteration of the protocol loop is executed atomically: a node cannot be interrupted in the middle of a protocol cycle, and no two executions of the protocol logic overlap on the same node.

If, during its execution, a node contacts another node, the contacted node processes the incoming request using a background execution thread. The internal scheduling of protocol execution and background message handling is abstracted away. The handling of incoming requests is also assumed to be atomic, and responses are generated and returned instantaneously.

Having defined the local behavior of nodes and the structure of the underlying peer-to-peer network, we now introduce a global view of the system. This perspective allows us to reason about the collective dynamics induced by the interaction of individual nodes over a time-varying communication topology.

#definition(title: "Peer-to-Peer System (Global View)")[
A peer-to-peer system is modeled as a distributed dynamical system evolving over a time-varying directed graph $G = (V, E, T)$.

Each node $v in V(t)$ is modeled as a state machine, characterized by:
- a local state space $S_v$,
- an initial state $s_v^0$,
- a transition function that maps the current local state and incoming events (messages or internal actions) to a new local state and a set of outgoing messages.

The global state of the peer-to-peer system at time $t$ is given by the tuple
$S(t) = (s_v(t))_{v in V(t)}$,
which aggregates the local states of all nodes currently present in the system.

The evolution of the system results from the  composition of the local state machines, combined with the temporal evolution of the underlying time-varying graph, which constrains possible communications between nodes.

From this perspective, the peer-to-peer system can be viewed as a large, distributed state machine whose global behavior emerges from the interaction of local protocols executed by individual nodes.
] <def:p2p-global>

== Emergent Behaviour

Beyond local execution semantics, many peer-to-peer protocols are designed to achieve 
specific objectives at the level of the system as a whole. While each node executes the 
protocol independently and relies solely on local information, the collective behavior 
of the system may exhibit coordinated dynamics that serve a common goal.

In some protocols, nodes pursue purely local objectives, and no explicit global 
coordination is required. In others, however, the protocol is designed so that the 
interaction of nodes leads to the emergence of a global property or the computation of 
a system-wide function. Typical examples include decentralized aggregation protocols, 
where nodes collaboratively compute global statistics such as the average, sum, or 
maximum of locally held values, as well as classical coordination tasks such as leader 
election or consensus.

These protocols are often characterized by a notion of convergence: starting from an 
arbitrary initial global state, the system is expected to evolve toward a stable or 
desirable global configuration that satisfies the protocol’s objective. This convergence 
is achieved without centralized control and emerges from repeated local interactions 
between nodes constrained by the evolving network topology.


#definition(title: "Global Objective and Convergence")[
A peer-to-peer protocol is said to pursue a global objective if there exists a set 
of desirable global states $S^*$ such that the protocol aims to drive the system toward 
this set through local interactions.

The protocol is said to converge if, for any initial global state $S(0)$, the sequence 
of global states $S(t)_(t >= 0)$ produced by the protocol satisfies:
$
exists T >= 0 "such as" forall t >= T, S(t) in S^*
$ 

Convergence may be exact or approximate, and may hold deterministically or with high 
probability, depending on the assumptions made on the protocol execution and the 
network dynamics.
] <def:convergence>

== Churn
The execution model described above directly induces a dynamic evolution of the peer-to-peer network. As nodes repeatedly execute the protocol, both the local views of nodes and the global network topology may change over time.
Thus a first level of dynamicity arises from the protocol execution itself. After each execution of the protocol loop, a node may update its partial view of the network, for instance by adding, removing, or replacing neighbors. As a consequence, the set of outgoing edges of a node in the overlay graph may change from one protocol cycle to another. At this level of dynamicity, the set of nodes remains constant, and only the edge set of the graph evolves over time.

A second level of dynamicity is introduced by churn, that is, the dynamic arrival and departure of nodes in the system. We model churn as a temporally localized phenomenon rather than a permanent one. Specifically, churn occurs during a predefined period spanning several protocol cycles.

During a protocol cycle affected by churn, a given fraction of nodes is selected uniformly at random and disconnected from the network, similarly to permanent crash failures. These nodes are assumed to leave the system definitively and never rejoin. Within the same cycle, an equal number of new nodes joins the network. Each joining node executes the initialization function and subsequently participates in the protocol execution as a regular node.

After the churn period ends, no further nodes join or leave the system. The protocol continues to execute on a fixed set of nodes, allowing the network to evolve solely under the effect of the protocol logic. This post-churn phase is used to observe whether, and under which conditions, the system is able to recover from the instability induced by churn and converge back to a stable configuration.

This modeling choice reflects the fact that continuous churn keeps the system in a permanently unstable state. By separating churn phases from stabilization phases, we can explicitly study the resilience and self-healing properties of the peer-to-peer protocol.

// === Failure Models

// - Nodes may fail by crashing. A node may crash due to hardware failure, software failure, or network disconnection. Regardless of the cause, the effect is the same: a crashed node cannot send or receive messages, nor can it perform any local computation.

== Failure Models

We distinguish two main classes of failures in peer-to-peer systems: crash failures and Byzantine failures.

==== Crash Failures

A node may experience a crash failure due to various causes, such as hardware faults, software errors, or permanent network disconnection. From the perspective of the system model, the specific cause of the failure is irrelevant, as the observable effect is always the same.

When a node crashes, it permanently stops executing the protocol. As a consequence, a crashed node no longer updates its local state, does not send messages, and cannot receive or process incoming messages. Any attempt by another node to contact a crashed node results in the absence of a response. We assume that crash failures are permanent: a crashed node never recovers and never rejoins the system. Peer-to-peer protocols must explicitly account for crash failures in order to avoid undesirable behaviors such as deadlocks, where a node waits indefinitely for a response from a failed node.

==== Byzantine Failures

In contrast to crash failures, a Byzantine node remains active but no longer follows the prescribed protocol. Instead, it behaves according to an arbitrary (Byzantine) strategy.

Byzantine behaviors can take many forms, including sending incorrect, inconsistent, or misleading messages, selectively responding to certain nodes, or attempting to disrupt the protocol execution. The common characteristic of Byzantine nodes is that they act maliciously, with the goal of corrupting the protocol execution or degrading the overall behavior of the peer-to-peer network.

Unless stated otherwise, Byzantine nodes are assumed to have full control over their local state and outgoing messages, while still being subject to the constraints of the underlying communication network.


== Time Assumptions


Regarding time and node synchronization, we distinguish two execution models.

In the first model, nodes are fully asynchronous. Each node executes independently and may send messages at arbitrary times, without any form of global synchronization. There is no notion of a shared clock or execution step, and nodes progress according to their own local pace.

In the second model, nodes execute their actions according to a global notion of time, structured into discrete steps called cycles. In this setting, all nodes conceptually perform their actions once per cycle. Two variants of this model can be considered. In the first variant, nodes execute sequentially within a cycle: each node performs its actions one after another, and a cycle is completed once all nodes have finished their execution. While this assumption is not realistic in practical systems, it greatly simplifies modeling and simulation. In the second variant, all nodes execute simultaneously and instantaneously within each cycle. This assumption is also unrealistic in practice, but is commonly adopted to facilitate theoretical analysis and simulation.

// - Nodes execute asynchronously and do not share a global clock.

== Topology Models
Network topology refers to the structural organization of a network, that is, the way nodes are interconnected and how links are arranged between them. In the context of overlay networks, topology is naturally described through the shape of the underlying graph, where nodes represent participants and edges represent logical connections. Different topologies lead to fundamentally different properties in terms of connectivity, robustness, routing efficiency, and scalability. Broadly, network topologies can be divided into two categories: deterministic and random. Deterministic topologies are defined by explicit construction rules that impose a fixed structure on the graph, such as stars, rings, trees, or meshes, where the presence of an edge is fully determined by the position or role of each node. In contrast, random topologies are generated according to probabilistic rules, where edges are created based on random processes or statistical constraints rather than fixed patterns. This category includes classical random graphs, as well as more advanced models from complex network theory such as small-world networks, power-law networks, and stochastic block models, which introduce community structure through probabilistic connection patterns. Random topologies are particularly relevant for modeling large-scale and dynamic peer-to-peer systems, where global coordination is impractical and network structure often emerges from local interactions. In this chapter, network topologies are not viewed as static structures, but as reference models describing the possible shapes of snapshot graphs $G(t)$ induced by peer-to-peer protocols over time.

==== Mesh
A mesh network topology corresponds to a complete graph, in which every node is directly connected to every other node in the network. This topology offers optimal communication properties, as any node can reach any other node in a single hop, resulting in a graph diameter equal to one and minimal latency for message dissemination. Such full connectivity also provides high redundancy, making the network inherently robust to individual link failures. However, these advantages come at a prohibitive cost in large-scale systems. Each node must maintain a connection with all other nodes, leading to a quadratic growth in the number of links and significant overhead in terms of bandwidth, memory, and connection management. Moreover, a mesh topology requires each node to know the complete list of participants in the network, which is impractical or impossible in dynamic environments where nodes frequently join and leave. As a result, mesh networks are inherently static and do not scale well, limiting their applicability to small, tightly controlled systems rather than large peer-to-peer or highly dynamic overlay networks.

#figure(diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0), name: "1", radius: 2em)
edge(label("2"), "-", stroke: 1pt)
edge(label("3"), "-", stroke: 1pt)
edge(label("4"), "-", stroke: 1pt)
node((1,1), name: "2", radius: 2em)
edge(label("3"), "-", stroke: 1pt)
edge(label("4"), "-", stroke: 1pt)
node((0, 1), name: "3", radius: 2em)
edge(label("4"), "-", stroke: 1pt)
node((1,0), name: "4", radius: 2em)
}),
  caption: [A mesh network with 4 nodes.],
) <mesh-network>

==== Star
A star network topology corresponds, from a graph-theoretic perspective, to a graph in which all nodes are connected to a single central node, often referred to as the hub. This topology naturally maps to a client–server architecture, where the central node acts as a server and all other nodes act as clients. Communication between any two clients must pass through the central node, which results in a graph diameter equal to two and enables fast message exchanges with low hop count. The simplicity of this topology makes it easy to deploy, manage, and control, and clients only need to maintain a single connection to participate in the network. However, the central node constitutes a critical bottleneck, as it must handle all communications and can become overloaded as the network grows. More importantly, it represents a single point of failure: if the server crashes, is disconnected, or is compromised, the entire network becomes unavailable.
#figure(
diagram({
  node((1,0), name: "Server", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client1"), "-", stroke: 1pt)
  edge(label("Client2"), "-", stroke: 1pt)
  edge(label("Client3"), "-", stroke: 1pt)

  node((0,1.5), name: "Client1", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((1,1.5), name: "Client2", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((2,1.5), name: "Client3", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))  
}),
  caption: [A star topology.],
) <star-topology>
==== Multi stars
A multi-star topology can be seen as an extension of the star topology in which several central nodes coexist, each forming a local star with a subset of clients. From a graph-theoretic point of view, this corresponds to a collection of star subgraphs that may or may not be interconnected. This topology is widely used in cloud systems, for instance in distributed databases where a primary server is supported by one or more replica servers that can take over in case of failure or overload. Multi-star architectures are also common in geographically distributed systems, where services are replicated across multiple regions to reduce latency and provide better quality of service to users worldwide. Several variants of multi-star topologies exist: in some designs, clients are connected to all available servers, while in others each client is connected to a single server at a time; similarly, servers may be fully interconnected, partially connected, or completely isolated from each other. Compared to a single-star topology, multi-star networks improve scalability, fault tolerance, and availability, but they still rely on centralized components at the level of each star. As a result, they remain more structured and less decentralized than peer-to-peer topologies, and require coordination mechanisms for load balancing, leader election, or consistency among servers.
#figure(
diagram({
  node((0,0), name: "Server 1", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client1"), "-", stroke: 1pt)
  edge(label("Client2"), "-", stroke: 1pt)
  edge(label("Client3"), "-", stroke: 1pt)
  node((2,0), name: "Server 2", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client1"), "-", stroke: 1pt)
  edge(label("Client2"), "-", stroke: 1pt)
  edge(label("Client3"), "-", stroke: 1pt)

  node((0,1.5), name: "Client1", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((1,1.5), name: "Client2", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((2,1.5), name: "Client3", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))  
}),
  caption: [A mult-stars topology, with 2 servers and 3 clients. Each client is connected to each server.],
) <star-topology>

==== Ring
A ring topology corresponds to a graph in which each node maintains exactly two connections, typically referred to as its left and right neighbors, forming a closed cycle. From a graph-theoretic perspective, this structure is a simple cycle graph. Ring topologies require coordination mechanisms between nodes, as well-defined rules are needed to handle the addition or removal of one or more nodes without breaking the ring and disconnecting the network. In particular, join and leave operations must ensure that neighbor relationships are consistently updated to preserve connectivity. The diameter of a ring network grows linearly with the number of nodes, i.e., it is proportional to $N$, which leads to potentially high communication latency as information may need to traverse many intermediate nodes. To mitigate this limitation, many ring-based systems introduce additional long-range links, often inspired by skip lists, allowing nodes to bypass large portions of the ring and significantly reduce routing and propagation times. Such enhancements improve efficiency while preserving the simplicity and locality properties of the underlying ring structure.
#figure(
diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0), name: "1", radius: 2em)
edge( "-", stroke: 1pt)
node((0.8,0.3), name: "2", radius: 2em)
edge( "-", stroke: 1pt)
node((0.8,1.2), name: "3", radius: 2em)
edge( "-", stroke: 1pt)
node((0,1.5), name: "4", radius: 2em)
edge( "-", stroke: 1pt)
node((-0.8,1.2), name: "6", radius: 2em)
edge( "-", stroke: 1pt)
node((-0.8,0.3), name: "6", radius: 2em)
edge(label("1"),"-", stroke: 1pt)

}),
  caption: [A ring topology, with 6 nodes.],
) <ring>

==== Hierarchical
A hierarchical network topology corresponds to a graph structured as a tree, where nodes are organized into different levels with parent–child relationships. This topology is commonly used in large-scale systems such as the Domain Name System (DNS), which relies on a hierarchical structure of authorities, ranging from root servers at the top level to top-level domain servers and authoritative name servers below. Compared to a star topology, hierarchical networks scale more effectively, as intermediate nodes distribute and absorb part of the workload, reducing the burden on any single central node. However, this topology remains largely static and is inherently fragile to failures. If an intermediate node fails, all its descendants become disconnected from the rest of the network, and a failure at the root level can impact the entire system. As a result, hierarchical topologies often require additional mechanisms such as redundancy, replication, or failover strategies to improve fault tolerance and availability.
#figure(
diagram({
  node((1,0), name: "ServerRoot", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Server1"), "-", stroke: 1pt)
  edge(label("Server2"), "-", stroke: 1pt)
  edge(label("Server3"), "-", stroke: 1pt)

  node((0,1.5), name: "Server1", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client1"), "-", stroke: 1pt)
  edge(label("Client2"), "-", stroke: 1pt)

  node((1,1.5), name: "Server2", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client3"), "-", stroke: 1pt)

  node((2,1.5), name: "Server3", radius: 2em, stroke: 1pt, fill: green.lighten(60%))  
  edge(label("Client4"), "-", stroke: 1pt)

  node((-1,2.8), name: "Client1", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((0,2.8), name: "Client2", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((1,2.8), name: "Client3", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((2,2.8), name: "Client4", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

}),
  caption: [A hierarchical (or tree) topology, with 2 levels, the root server and the intermediate servers.],
) <tree-topology>

==== Random network
In contrast to the deterministic topologies presented above, real-world networks are often not explicitly organized but instead emerge in a largely random manner. Social networks, for instance, are formed through independent and uncoordinated interactions between individuals, leading to structures that are difficult to predict or control globally. To model such systems, random network models have been widely studied, among which the Erdős–Rényi random graph @erdHos1959evolution is the most classical and intuitive. In this model, edges are created at random, either by fixing the probability of connection between any pair of nodes or by fixing the expected number of connections per node. Despite the apparent lack of structure, random graphs exhibit several desirable properties. When the average degree k is greater than a small constant (typically slightly above 2), the probability that the graph is connected rapidly approaches one as the network size grows. Moreover, the diameter of the graph remains relatively small, scaling logarithmically with the number of nodes, which ensures efficient information propagation. In the directed case, k usually denotes the out-degree of each node, while the in-degree follows a binomial distribution centered around k. These properties make random graphs attractive as baseline models for large-scale decentralized systems, even though they do not capture heterogeneity or hub formation observed in many real networks.

#figure(
diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0), name: "1", radius: 2em)
edge(label("5"), "->", stroke: 1pt)
edge(label("2"), "->", stroke: 1pt)
node((0.3,1), name: "2", radius: 2em)
edge(label("5"), "->", stroke: 1pt)
edge(label("3"), "->", stroke: 1pt)
node((1,1.5), name: "3", radius: 2em)
edge(label("5"), "->", stroke: 1pt)
edge(label("2"), "->", stroke: 1pt)
node((1.8,1), name: "4", radius: 2em)
edge(label("1"), "->", stroke: 1pt)
edge(label("5"), "->", stroke: 1pt)
node((1.8,0), name: "5", radius: 2em)
edge(label("1"), "->", stroke: 1pt)
edge(label("4"), "->", stroke: 1pt)
}),
  caption: [A random directed graph, $k=2$, with $k$ the outdegree of each node.],
) <random-graph>

#definition(title: "Erdős–Rényi Random Graph G(n, p)")[
  Let $n in NN$ be the number of vertices and $p in [0, 1]$.
  An Erdős–Rényi random graph $G(n, p)$ is defined as a random graph
  $G = (V, E)$ where:
  - $V = {1, 2, ..., n}$ is the set of vertices;
  - for every unordered pair ${i, j} subset V$ with $i != j$,
    the edge ${i, j}$ is included in $E$ independently with probability $p$:
    $
    forall i != j, quad Pr({i, j} in E) = p.
    $
] <def:Erdos-Renyi-Gnp>

#definition(title: "Erdős–Rényi Random Graph G(n, m)")[
  Let $n in NN$ be the number of vertices and $m in NN$ the number of edges.
  An Erdős–Rényi random graph $G(n, m)$ is a random graph
  $G = (V, E)$ where:
  - $V = {1, 2, ..., n}$;
  - $E$ is chosen uniformly at random among all subsets of
    ${ {i, j} | i, j in V, i != j }$
    such that $|E| = m$.
] <def:Erdos-Renyi-Gnm>

#definition(title: "Directed Random Graph with Fixed Outdegree")[
  Let $n in NN$ be the number of nodes and $k in NN$ such that $k < n$.
  A directed random graph $G = (V, E)$ with fixed outdegree $k$ is defined as follows:
  - $V = {1, 2, ..., n}$;
  - for each node $i in V$, exactly $k$ outgoing edges are created;
  - the $k$ distinct destination nodes are selected uniformly at random
    from $V$, without replacement.
  
  Formally, for each node $i$, the set of outgoing neighbors
  $N_"out"(i)$ satisfies:
  $
  |N_"out"(i)| = k,
  $
  and each subset of size $k$ of $V$ is equally likely.
] <def:Directed-Random-Graph>

==== Small world

Small-world networks provide a more realistic representation of many real-world networks compared to classical random graphs. In such networks, the neighbors of a node are often also neighbors of each other, reflecting the common social phenomenon that “friends of my friends are also friends.” This property results in a high clustering coefficient, which contrasts with the Erdős–Rényi random graph, where clustering is typically very low. The Watts–Strogatz model @watts1998strogatz formalizes this concept by starting from a regular lattice and randomly rewiring a fraction of edges. These random long-range connections create shortcuts between distant parts of the network, significantly reducing the graph diameter while preserving local clusters. This combination of high clustering and small diameter makes small-world networks highly relevant for modeling social networks, communication systems, and peer-to-peer overlays, where local connectivity and fast information propagation are both crucial.

#definition(title: "Watts-Strogatz Small-World Network")[
  A Watts-Strogatz small-world network is generated by the following procedure:
  1. Start with a regular ring lattice with $N$ nodes, each connected to $K$ nearest neighbors ($K/2$ on each side).
  2. For each edge $(i,j)$, rewire it with probability $p$:
     - Remove the edge $(i,j)$.
     - Connect node $i$ to a randomly chosen node $k$ (excluding $i$ and avoiding duplicate edges).
  3. Repeat for all edges.
  
  Parameters:
  - $N$: number of nodes in the network.
  - $K$: initial number of neighbors per node (must be even).
  - $p$: rewiring probability, controlling the randomness of the network.
  
  Properties:
  - High clustering coefficient compared to random graphs.
  - Small average shortest-path length due to long-range shortcuts.
] <def:watts-strogatz>

#figure(
diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0), name: "1", radius: 2em)
edge(label("2"), "->", stroke: 1pt)
edge(label("3"), "->", stroke: 1pt)
edge(label("5"), "->", stroke: 1pt)
node((0.3,1), name: "2", radius: 2em)
edge(label("1"), "->", stroke: 1pt)
edge(label("3"), "->", stroke: 1pt)
node((1,1.5), name: "3", radius: 2em)
edge(label("1"), "->", stroke: 1pt)
node((1.8,1), name: "4", radius: 2em)
edge(label("5"), "->", stroke: 1pt)
node((1.8,0), name: "5", radius: 2em)
edge(label("1"), "->", stroke: 1pt)
edge(label("6"), "->", stroke: 1pt)
node((3,0.4), name: "6", radius: 2em)
edge(label("4"), "->", stroke: 1pt)
}),
  caption: [A directed small world network, with 2 clusters (left and right).],
) <watts-strogatz-example>

==== Power-law
The Erdős–Rényi and Watts–Strogatz models are interesting and can be used to model certain networks, but many real networks are more complex than simple random networks. In fact, real networks are heterogeneous, with hubs, i.e., nodes with many connections. Scale-free networks are a class of networks in which the degree distribution follows a power-law, meaning that most nodes have few connections while a small number of nodes, called hubs, have a very large number of connections. This property is observed in many real-world networks, such as the Internet, social networks, and citation networks. Scale-free networks also exhibit a self-similar or fractal topology: as the number of nodes increases, the overall structure of the network remains similar, and its statistical properties are preserved. This scalability is one reason why many real networks naturally adopt a scale-free topology. The Barabási–Albert (BA) model @barabasi1999emergence introduced a generative mechanism for scale-free networks based on growth and preferential attachment: starting from a small initial network, new nodes are added one by one and each new node connects to existing nodes with a probability proportional to their degree. This process leads to the emergence of hubs and a degree distribution with a typical power-law exponent around γ ≈ 3. Scale-free networks generally have a small diameter, which allows for efficient communication between nodes. However, the presence of hubs also introduces a vulnerability: the failure of one or more hubs can significantly degrade the connectivity of the network. Unlike classical random graphs, scale-free networks are highly heterogeneous, with a few highly connected nodes dominating the network structure, while most nodes have relatively few connections. Variants of the BA model have been proposed to limit the maximum degree of nodes, add constraints on connectivity, or increase resilience to failures.

#definition(title: "Scale-Free Network")[
  A scale-free network is a network whose degree distribution follows a power law: $P(k) tilde.basic k^{-gamma}$, where $P(k)$ is the probability that a node has degree $k$ and $gamma$ is a positive constant typically between 2 and 3. Most nodes have few connections, while a few nodes, called hubs, have many connections.

  One classical generative model is the Barabási–Albert (BA) model:
  1. Start with a small initial network of $m_0$ nodes.
  2. At each time step, add a new node with $m <= m_0$ edges.
  3. Each new edge connects to an existing node \(i\) with probability proportional to its degree:
  
    $Pi(i) = k_i/(sum_j k_j)$,
  
  where $k_i$ is the degree of node $i$. This preferential attachment process leads to the emergence of hubs and a power-law degree distribution.
] <def:scale-free-network>

#figure(
diagram({
  node((1,0), name: "ServerRoot", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Server1"), "-", stroke: 1pt)
  edge(label("Server2"), "-", stroke: 1pt)
  edge(label("Server3"), "-", stroke: 1pt)
  edge(label("Client6"), "-", stroke: 1pt)

  node((-1,1.5), name: "Server1", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client1"), "-", stroke: 1pt)
  edge(label("Client2"), "-", stroke: 1pt)
  edge(label("Client3"), "-", stroke: 1pt)

  node((0.5,1.5), name: "Server2", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client4"), "-", stroke: 1pt)
  edge(label("Client5"), "-", stroke: 1pt)

  node((2,1.5), name: "Server3", radius: 2em, stroke: 1pt, fill: green.lighten(60%))  
  edge(label("Client7"), "-", stroke: 1pt)
  edge(label("Client8"), "-", stroke: 1pt)
  edge(label("Client9"), "-", stroke: 1pt)

  node((-3,2.8), name: "Client1", radius: 2em, stroke: 1pt, fill: green.lighten(60%))

  node((-2,2.8), name: "Client2", radius: 2em, stroke: 1pt, fill: green.lighten(60%))

  node((-1.2,2.8), name: "Client3", radius: 2em, stroke: 1pt, fill: green.lighten(60%))

  node((-0.5,2.8), name: "Client4", radius: 2em, stroke: 1pt, fill: green.lighten(60%))

  node((0.2,2.8), name: "Client5", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  
  node((1,2.8), name: "Client6", radius: 2em, stroke: 1pt, fill: green.lighten(60%))

  node((1.8,2.8), name: "Client7", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  
  node((2.5,2.8), name: "Client8", radius: 2em, stroke: 1pt, fill: green.lighten(60%))

  node((3.5,2.8), name: "Client9", radius: 2em, stroke: 1pt, fill: green.lighten(60%))

}),
  caption: [A scale free network.],
) <scale-free-schema>

==== Stochastic block model
In real-world networks, randomness often coexists with community structures. Stochastic Block Models (SBM) @holland1983stochastic are a generalization of the classical Erdős–Rényi random graph and provide a flexible framework to model such networks. In an SBM, nodes are partitioned into communities (or blocks), and the probability of a link between two nodes depends on the communities to which they belong. This allows the generation of networks that appear random globally but exhibit strong local structures, highlighting the presence of communities. The model allows explicit control over the number and size of communities, as well as the intra- and inter-community connection probabilities, enabling the study of networks with varying modularity. Moreover, because SBM is probabilistic, multiple network instances can be generated from the same parameters, making it a powerful tool for benchmarking community detection algorithms and exploring structural properties of complex networks.

#definition(title: "Stochastic Block Model")[
  A Stochastic Block Model (SBM) is a generative model for random graphs with community structure. 
  Consider a graph $G = (V, E)$ with $N$ nodes, and let the nodes be partitioned into $K$ disjoint blocks (or communities) $C_1, C_2, dots, C_K$.
  The probability of an edge between two nodes depends only on the blocks to which they belong.
  
  Formally, let $B in [0,1]^{K times K}$ be a matrix of connection probabilities between blocks, where $B_{"ab"}$ is the probability that a node in block $C_a$ connects to a node in block $C_b$. Then, for each pair of nodes $(i,j)$:
  
  - If node $i in C_a$ and node $j in C_b$, the edge $(i,j)$ exists independently with probability $B_{"ab"}$:
      $P((i,j) in E) = B_{"ab"}$.
  
  Special cases include:
  - *Intra-block probabilities*: $B_{"aa"}$, the probability of connection between nodes within the same community.
  - *Inter-block probabilities*: $B_{"ab"}$, $a eq.not b$, the probability of connection between nodes of different communities.
  
  SBM generalizes the Erdős–Rényi random graph, which corresponds to the case $K=1$.
] <def:sbm>

After introducing various network topologies, whether deterministic or random, it is natural 
to consider the ability of peer-to-peer protocols to *reach* or *maintain* these structures. 
In a dynamic system where nodes may join, leave, or update their connections, the observed 
topology at time $t$, represented by the graph $G(t)$, can deviate from the ideal configurations 
presented above. The notion of *topology convergence* formalizes this idea: a protocol is said 
to converge if, starting from any initial topology, it drives the network toward a set of 
desired topologies. These target topologies may be strictly deterministic, such as a ring or 
a fully connected graph, or probabilistic, such as a random graph or a small-world network. 
This formalization provides a rigorous framework to analyze and compare the effectiveness of 
protocols in creating, stabilizing, or preserving different network structures in dynamic, 
distributed environments.

#definition(title: "Topology Convergence in Peer-to-Peer Networks")[
A peer-to-peer protocol is said to achieve *topology convergence* if there exists a set of 
desired network topologies $G^*$ such that, starting from any initial topology 
$G(0)$, the sequence of overlay graphs $G(t)_(t >= 0)$ produced by the protocol satisfies:

$
exists T >= 0 "such as" forall t >= T, G(t) in G^*.
$

The desired topology may be:

- *Deterministic*, e.g., a ring, a fully connected graph, or a structured DHT, in which 
  case convergence requires that the protocol reorganizes the overlay exactly into this structure.

- *Random*, e.g., an Erdős–Rényi or other random graph model, in which case convergence 
  is defined in a statistical sense: the degree distribution, clustering coefficient, or 
  other network metrics of $G(t)$ should approximate those of a graph sampled from the target 
  random model.

Convergence may hold deterministically or with high probability depending on the assumptions 
made on the protocol execution, and the rules for neighbor selection.
] <def:topology-convergence>


== Metrics
In an overlay network, the state of the system at a given instant can be represented as a graph snapshot of the underlying time-varying graph. Various metrics can then be computed on this graph in order to characterize the structure of the network, monitor its evolution over time, and compare different protocols.

Metrics provide insights into connectivity, resilience, efficiency, and overall behavior of the network. In the context of time-varying graphs, these metrics can be computed either on a single snapshot $G(t)$ or observed as time-dependent quantities $m(t) = m(G(t))$ that evolve as the network topology changes.

Commonly used metrics include the indegree and outdegree distributions, the clustering coefficient, the average path length, and the network diameter.

The *indegree* and *outdegree* distributions are fundamental metrics that describe how connections are distributed among nodes at a given time.

In a time-varying graph $G = (V, E, T)$, these distributions are computed on a snapshot $G(t) = (V(t), E(t))$ of the network. The outdegree of a node corresponds to the number of outgoing edges it maintains at time $t$, which in most peer-to-peer protocols reflects the size of the node's partial view. As a result, the outdegree is often bounded and relatively stable over time.

In contrast, the indegree represents the number of incoming edges a node receives and may vary significantly across nodes. Monitoring the indegree distribution over time provides valuable insights into how the network adapts, which nodes become highly connected, and whether hubs or imbalances emerge.
#definition(title: "Indegree and Outdegree Distributions")[
The *indegree (resp. outdegree) distribution* of a network at time $t$ is the probability distribution of the number of incoming (resp. outgoing) edges of nodes in the graph snapshot $G(t)$.

- For a network following a random graph distribution (Erdős–Rényi model), the degree distribution follows:
  $P(k) = binom(n-1, k) p^k (1-p)^(n-1-k)$.

- For a network following a scale-free distribution (Barabási–Albert model), the degree distribution follows:
  $P(k) = C k^(-gamma)$,
  where $gamma$ is the power-law exponent and $C$ is a normalization constant.
] <def:degree-distribution>

The *clustering coefficient* measures the tendency of nodes to form tightly connected groups. It quantifies how likely it is that the neighbors of a node are also connected to each other.

In a dynamic peer-to-peer network, the clustering coefficient can be computed at each time step on the snapshot $G(t)$, yielding a time-dependent metric that reflects the local cohesiveness of the network as it evolves. This metric is particularly useful for identifying the emergence of clusters or community structures.

#definition(title: "Clustering Coefficient")[
The clustering coefficient $C_i(t)$ of a node $i$ at time $t$ is defined as:
$ C_i(t) = (2 e_i(t)) / (k_i(t)(k_i(t) - 1)) $

Where:
- $e_i(t)$ is the number of edges between the neighbors of node $i$ in $G(t)$,
- $k_i(t)$ is the degree of node $i$ at time $t$.

The average clustering coefficient of the network at time $t$ is:
$ C(t) = 1 /(|V(t)|) sum_(i in V(t)) C_i(t) $
]

The *average path length* characterizes the efficiency of information dissemination in the network. It corresponds to the mean of the shortest path lengths between all pairs of nodes.

In time-varying graphs, the average path length is computed on each snapshot $G(t)$, allowing the observation of its evolution over time. A decreasing average path length may indicate improved connectivity or the emergence of highly connected nodes.

#definition(title: "Average Path Length")[
The average path length $a(t)$ of the network at time $t$ is defined as:
$ a(t) = sum_(s, t' in V(t), s eq.not t') d(s, t') / (|V(t)| (|V(t)| - 1)) $

Where:
- $d(s, t')$ is the length of the shortest path between nodes $s$ and $t'$ in $G(t)$.
]

// The *diameter* of a graph is a measure of the longest distance between any two vertices (nodes) in the graph, measured in terms of the number of edges. In other words, the diameter of a graph is the maximum shortest path between any pair of nodes in the network.

// While the average path length provides a basic measure of information dissemination efficiency in algorithms, it may overlook disparities in dissemination speed across different nodes within the network. An algorithm could potentially have a favorable average path length but still exhibit uneven dissemination speeds among nodes due to varying distances. Calculating the network's diameter, however, offers a more comprehensive assessment.

// #definition(title: "Diameter")[
// The diameter of a network at time $t$ is defined as the length of the longest shortest path between any pair of nodes in the snapshot $G(t)$:

// $
// "diam"(G(t)) = max_(u, v in V(t)) d(u, v)
// $

// Where:
// - $V(t)$ is the set of nodes in the network at time $t$.
// - $d(u,v)$ is the length of the shortest path between nodes $u$ and $v$.
// ]

Beyond local and global structural metrics, connectivity properties play a central role in the analysis of peer-to-peer networks.  Connectivity metrics computed on $G(t)$ allow us to characterize whether the network remains operational, how information can propagate, and how resilient the topology is to node failures or churn.


// #definition(title: "Weakly and Strongly Connected Components")[
// Let $G(t) = (V(t), E(t))$ be a directed graph representing a snapshot of a peer-to-peer network at time $t$.

// - A *strongly connected component (SCC)* is a maximal subset of nodes $C subset.eq V(t)$ such that for every pair of nodes $u, v in C$, there exists a directed path from $u$ to $v$ and from $v$ to $u$.

// - A *weakly connected component (WCC)* is a maximal subset of nodes $C subset.eq V(t)$ such that the underlying undirected graph obtained by ignoring edge directions is connected.

// The set of weakly or strongly connected components induces a partition of the vertex set $V(t)$. The number of such components characterizes the fragmentation level of the network at time $t$.
// ] <def:connectivity>

In typical operating conditions, peer-to-peer protocols aim to maintain a connected topology, and the snapshot graph $G(t)$ usually consists of a single weakly connected component. To assess the robustness of the network, we study how connectivity degrades under node removals.

Starting from a connected snapshot, nodes are removed uniformly at random, one by one, simulating failures or departures. After each removal, we recompute the number of weakly and strongly connected components. The evolution of these quantities provides a quantitative measure of the network’s resilience: a topology is considered robust if it remains weakly connected, or fragments slowly, despite node failures.

This analysis allows us to compare protocols in terms of fault tolerance and structural stability, independently of their specific message-passing behavior.



// == Conclusion

// In this chapter, we have presented a comprehensive model of a decentralized learning system, 
// structured in multiple layers, as illustrated in Figure <fig:system-architecture>. 

// The system is organized into four main layers:

// - *Network Layer*: represents the underlying physical or logical network. In our study, 
//   we do not model the network in detail; we only make high-level assumptions regarding 
//   connectivity, latency, and node availability.

// - *Overlay Layer*: implements the peer-to-peer system on top of the network. This layer 
//   defines the topology and dynamics of the overlay, such as neighbor selection, churn, 
//   and connectivity maintenance.

// - *Aggregation Layer*: defines the logic of model aggregation. It abstracts the communication 
//   and combination of local model updates according to various aggregation strategies, 
//   including centralized, hierarchical, gossip-based, or blockchain-mediated approaches.

// - *Application Layer*: hosts the machine learning models themselves, such as logistic 
//   regression, and orchestrates local training, evaluation, and metrics computation.

// By separating the system into these layers, we ensure that the model is adaptable both 
// to different underlying network conditions and to various machine learning models. 
// This modular design allows us to study the impact of aggregation strategies and overlay 
// topologies on learning performance independently from the specific ML algorithms or 
// network technologies.

// Overall, this layered architecture provides a clear framework for analyzing decentralized 
// learning systems, highlighting the interactions between network assumptions, overlay design, 
// aggregation logic, and machine learning objectives.

// #figure(
// cetz.canvas({
//   import cetz.draw: *
//   // Dimensions
//   let w = 4
//   let h = 2  
//   let spacing = 2

//   // Couleurs
//   let colors = (
//     rgb(70%, 70%, 70%),    // light grey
//     rgb(75%, 90%, 75%),   // green
//     rgb(75%, 85%, 95%),   // blue
//     rgb(85%, 75%, 90%),   // violet
//   )

 
//   // Arrow labels
//   let labels = (
//     "Network Layer",
//     "Overlay Layer",
//     "Aggregation Layer",
//     "Application Layer",
//   )
//   for i in range(4) {
//     rect((0, i*spacing), (w, h + (i*spacing)), name: "rect_"+str(i), fill: colors.at(i)) 
  
//     content("rect_"+str(i), labels.at(i))  
//   }
// }), caption: [Architecture]
// ) <fig:system-architecture>
