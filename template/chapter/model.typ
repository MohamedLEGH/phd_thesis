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

Having established the formal vocabulary of graph theory --- vertices,
edges, paths, distances, and degree --- we now turn to the study of
specific network models. The following section surveys the principal
graph structures and generative models encountered in the peer-to-peer
and distributed systems literature, ranging from deterministic
topologies defined by explicit construction rules to random models
whose structure emerges from probabilistic processes.

=== Common network topologies

Network topology refers to the structural organization of a network:
the way nodes are interconnected and how links are arranged between
them. Different topologies lead to fundamentally different properties
in terms of connectivity, robustness, routing efficiency, and
scalability. In the context of overlay networks, topologies are not
viewed as static structures but as reference models describing the
possible shapes of snapshot graphs $G(t)$ induced by peer-to-peer
protocols over time.

Network topologies can be broadly divided into two categories.
*Deterministic topologies* are defined by explicit construction rules
that fully determine the presence of each edge from the position or
role of nodes --- stars, rings, trees, grids, and meshes fall into
this category. *Random topologies* are generated according to
probabilistic rules, and include classical random graphs as well as
more advanced models such as small-world networks, power-law
networks, and stochastic block models.

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
==== Multi-star

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
  caption: [A multi-star topology, with 2 servers and 3 clients. Each client is connected to each server.],
) <multi-star-topology>

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
node((-0.8,1.2), name: "5", radius: 2em)
edge( "-", stroke: 1pt)
node((-0.8,0.3), name: "6", radius: 2em)
edge(label("1"),"-", stroke: 1pt)

}),
  caption: [A ring topology, with 6 nodes.],
) <ring>

==== Grid / Lattice

A grid (or lattice) network topology arranges nodes in a regular
$d$-dimensional structure, where each node is connected only to its
immediate neighbors along each dimension. In a $d$-dimensional
lattice, each interior node has exactly $2d$ neighbors: two per
dimension, corresponding to its left and right neighbors along each
axis. The most common case encountered in practice is the
two-dimensional grid, where each interior node has exactly four
neighbors, while boundary and corner nodes have three and two
neighbors respectively.

It is worth noting that the one-dimensional grid corresponds exactly
to the ring topology discussed earlier, where each node is connected
to exactly two neighbors forming a closed cycle. At the other
extreme, the *hypercube* is a $d$-dimensional grid over $N = 2^d$
nodes, in which each node has exactly $d = log_2 N$ neighbors. This
topology offers a favorable trade-off between degree and diameter:
the diameter grows as $O(log N)$, significantly better than the
two-dimensional grid while maintaining a moderate and uniform degree.

The local nature of connections in grid topologies comes at the cost
of communication efficiency. The diameter of a two-dimensional
$n times n$ grid grows as $O(n) = O(sqrt(N))$, meaning that messages
may need to traverse many hops to reach distant nodes. Information
dissemination and aggregation processes are therefore significantly
slower than in mesh or scale-free topologies.

#figure(
  diagram(
    node-fill: green.lighten(60%),
    node-stroke: 1pt,
    spacing: 18mm,
    {
      // Row 0
      node((0,0), name: "n00", radius: 1.2em)
      edge(label("n10"), "-", stroke: 1pt)
      edge(label("n01"), "-", stroke: 1pt)
      node((1,0), name: "n10", radius: 1.2em)
      edge(label("n20"), "-", stroke: 1pt)
      edge(label("n11"), "-", stroke: 1pt)
      node((2,0), name: "n20", radius: 1.2em)
      edge(label("n30"), "-", stroke: 1pt)
      edge(label("n21"), "-", stroke: 1pt)
      node((3,0), name: "n30", radius: 1.2em)
      edge(label("n40"), "-", stroke: 1pt)
      edge(label("n31"), "-", stroke: 1pt)
      node((4,0), name: "n40", radius: 1.2em)
      edge(label("n50"), "-", stroke: 1pt)
      edge(label("n41"), "-", stroke: 1pt)
      node((5,0), name: "n50", radius: 1.2em)
      edge(label("n51"), "-", stroke: 1pt)

      // Row 1
      node((0,1), name: "n01", radius: 1.2em)
      edge(label("n11"), "-", stroke: 1pt)
      edge(label("n02"), "-", stroke: 1pt)
      node((1,1), name: "n11", radius: 1.2em)
      edge(label("n21"), "-", stroke: 1pt)
      edge(label("n12"), "-", stroke: 1pt)
      node((2,1), name: "n21", radius: 1.2em)
      edge(label("n31"), "-", stroke: 1pt)
      edge(label("n22"), "-", stroke: 1pt)
      node((3,1), name: "n31", radius: 1.2em)
      edge(label("n41"), "-", stroke: 1pt)
      edge(label("n32"), "-", stroke: 1pt)
      node((4,1), name: "n41", radius: 1.2em)
      edge(label("n51"), "-", stroke: 1pt)
      edge(label("n42"), "-", stroke: 1pt)
      node((5,1), name: "n51", radius: 1.2em)
      edge(label("n52"), "-", stroke: 1pt)

      // Row 2
      node((0,2), name: "n02", radius: 1.2em)
      edge(label("n12"), "-", stroke: 1pt)
      node((1,2), name: "n12", radius: 1.2em)
      edge(label("n22"), "-", stroke: 1pt)
      node((2,2), name: "n22", radius: 1.2em)
      edge(label("n32"), "-", stroke: 1pt)
      node((3,2), name: "n32", radius: 1.2em)
      edge(label("n42"), "-", stroke: 1pt)
      node((4,2), name: "n42", radius: 1.2em)
      edge(label("n52"), "-", stroke: 1pt)
      node((5,2), name: "n52", radius: 1.2em)
    }
  ),
  caption: [A $6 times 3$ two-dimensional grid network.],
) <fig:grid-network>
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

// #definition(title: "Erdős–Rényi Random Graph G(n, m)")[
//   Let $n in NN$ be the number of vertices and $m in NN$ the number of edges.
//   An Erdős–Rényi random graph $G(n, m)$ is a random graph
//   $G = (V, E)$ where:
//   - $V = {1, 2, ..., n}$;
//   - $E$ is chosen uniformly at random among all subsets of
//     ${ {i, j} | i, j in V, i != j }$
//     such that $|E| = m$.
// ] <def:Erdos-Renyi-Gnm>

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

==== Power-law and scale-free networks

The Erdős–Rényi and Watts–Strogatz models are useful approximations,
but many real-world networks are more complex than simple random
graphs. In particular, they are commonly described as *scale-free*
networks @barabasi1999emergence: their structural properties remain
invariant across scales, meaning that the same organizational patterns
can be observed regardless of the network size, with no characteristic
degree scale dominating the topology.

In practice, scale-free behavior is most often associated with degree
distributions that follow a *power-law*. While the notions of
scale-free and power-law are not strictly equivalent, the latter
provides a precise mathematical framework to characterize the absence
of a characteristic scale in the degree distribution.

#definition(title: "Power-law network")[
Let $G = (V, E)$ be a graph with $|V| = N$. Let $K$ be the random
variable denoting the degree of a node chosen uniformly at random
from $V$. The network is said to be power-law if
$
P(K = k) ~ k^(-gamma)
$
where $gamma > 1$ is the power-law exponent.
]

A defining characteristic of power-law networks is their heavy-tailed
degree distribution: most nodes have small degree, while a small but
non-negligible fraction --- commonly referred to as *hubs* --- exhibit
very large degree. This structural heterogeneity sharply contrasts
with Erdős–Rényi graphs, whose degree distribution is binomial.
Empirical studies of real-world systems, including peer-to-peer
overlays, communication networks, and social graphs, frequently report
power-law exponents in the range $2 < gamma < 3$ @barabasi1999emergence,
a regime in which the average degree remains finite while the variance
diverges in the limit of large network size.

This structural heterogeneity has direct consequences for information
dissemination. Hubs act as communication shortcuts, significantly
reducing the average path length and facilitating rapid message
exchange. As a consequence, broadcast, gossip, and aggregation
processes may converge faster than in more homogeneous topologies.
Many scale-free networks also exhibit the *ultra-small world* property
@cohen2003scale: while the diameter of classical random graphs
typically scales as $log N$, scale-free networks may display diameters
scaling as $log log N$, further accelerating information spreading.

A classical generative model for scale-free networks is the
Barabási--Albert (BA) model @barabasi1999emergence, which produces
power-law degree distributions through *preferential attachment*: when
a new node joins the network, it connects to existing nodes with
probability proportional to their current degree,
$
Pi(i) = k_i / (sum_j k_j),
$
where $k_i$ is the degree of node $i$. Starting from a small initial
network of $m_0$ nodes and adding one node with $m <= m_0$ edges at
each step, this rich-get-richer mechanism naturally leads to the
emergence of hubs and a power-law degree distribution, reproducing
the structural properties observed in many real-world networks.

#figure(
diagram({
  node((1,0), name: "ServerRoot", radius: 1em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Server1"), "-", stroke: 1pt)
  edge(label("Server2"), "-", stroke: 1pt)
  edge(label("Server3"), "-", stroke: 1pt)
  edge(label("Client6"), "-", stroke: 1pt)

  node((-1,1.5), name: "Server1", radius: 1em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client1"), "-", stroke: 1pt)
  edge(label("Client2"), "-", stroke: 1pt)
  edge(label("Client3"), "-", stroke: 1pt)

  node((0.5,1.5), name: "Server2", radius: 1em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client4"), "-", stroke: 1pt)
  edge(label("Client5"), "-", stroke: 1pt)

  node((2,1.5), name: "Server3", radius: 1em, stroke: 1pt, fill: green.lighten(60%))  
  edge(label("Client7"), "-", stroke: 1pt)
  edge(label("Client8"), "-", stroke: 1pt)
  edge(label("Client9"), "-", stroke: 1pt)

  node((-3,2.8), name: "Client1", radius: 1em, stroke: 1pt, fill: green.lighten(60%))

  node((-2,2.8), name: "Client2", radius: 1em, stroke: 1pt, fill: green.lighten(60%))

  node((-1.2,2.8), name: "Client3", radius: 1em, stroke: 1pt, fill: green.lighten(60%))

  node((-0.5,2.8), name: "Client4", radius: 1em, stroke: 1pt, fill: green.lighten(60%))

  node((0.2,2.8), name: "Client5", radius: 1em, stroke: 1pt, fill: green.lighten(60%))
  
  node((1,2.8), name: "Client6", radius: 1em, stroke: 1pt, fill: green.lighten(60%))

  node((1.8,2.8), name: "Client7", radius: 1em, stroke: 1pt, fill: green.lighten(60%))
  
  node((2.5,2.8), name: "Client8", radius: 1em, stroke: 1pt, fill: green.lighten(60%))

  node((3.5,2.8), name: "Client9", radius: 1em, stroke: 1pt, fill: green.lighten(60%))

}),
  caption: [Example of a scale-free network],
) <fig:scale-free-example>

==== Stochastic block model
While power-law and scale-free models capture degree heterogeneity,
they do not explicitly account for community structure --- the
tendency of nodes to form densely connected groups with sparser
connections between them. Stochastic Block Models (SBM)
@holland1983stochastic address this limitation by providing a
generative framework in which nodes are partitioned into communities
(or blocks), and the probability of a link between two nodes depends
solely on the communities to which they belong. This allows the
generation of networks that appear random globally but exhibit strong
local structure, with explicit control over the number and size of
communities as well as intra- and inter-community connection
probabilities. SBM generalizes the Erdős–Rényi random graph, which
corresponds to the special case of a single block, and is
particularly well suited to model overlays organized around hubs or
clusters of nodes sharing common interests. Because it is
probabilistic, multiple network instances can be generated from the
same parameters, making it a valuable tool for benchmarking community
detection algorithms and studying networks with varying modularity.

#definition(title: "Stochastic Block Model")[
  A Stochastic Block Model (SBM) is a generative model for random graphs with community structure. 
  Consider a graph $G = (V, E)$ with $N$ nodes, and let the nodes be partitioned into $K$ disjoint blocks (or communities) $C_1, C_2, dots, C_K$.
  The probability of an edge between two nodes depends only on the blocks to which they belong.
  
  Formally, let $B in [0,1]^{K times K}$ be a matrix of connection probabilities between blocks, where $B_{"ab"}$ is the probability that a node in block $C_a$ connects to a node in block $C_b$. Then, for each pair of nodes $(i,j)$:
  
  - If node $i in C_a$ and node $j in C_b$, the edge $(i,j)$ exists independently with probability $B_(a b)$:
      $P((i,j) in E) = B_(a b)$.
  
  Special cases include:
  - *Intra-block probabilities*: $B_(a a)$, the probability of connection between nodes within the same community.
  - *Inter-block probabilities*: $B_(a b)$, $a eq.not b$, the probability of connection between nodes of different communities.
  
  SBM generalizes the Erdős–Rényi random graph, which corresponds to the case $K=1$.
] <def:sbm>

The topologies surveyed above --- from deterministic structures such
as meshes, stars, and rings, to probabilistic models such as random
graphs, small-world networks, power-law networks, and stochastic
block models --- provide a rich vocabulary for characterizing the
structural properties of peer-to-peer overlays. Having established
this repertoire, we now turn to the formal modeling of overlay
networks as graphs, and introduce the abstractions that will be used
throughout this manuscript to reason about connectivity, communication,
and protocol execution.

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

// === Emergent Behaviour
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

=== Dynamic Network
// The execution model described above directly induces a dynamic evolution of the peer-to-peer network. 

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

==== Crash Failures

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

==== Byzantine Failures

In contrast to crash failures, a Byzantine node remains active but no longer follows the prescribed protocol. Instead, it behaves according to an arbitrary (Byzantine) strategy.

Byzantine behaviors can take many forms, including sending incorrect, inconsistent, or misleading messages, selectively responding to certain nodes, or attempting to disrupt the protocol execution. The common characteristic of Byzantine nodes is that they act maliciously, with the goal of corrupting the protocol execution or degrading the overall behavior of the peer-to-peer network.

Byzantine failures are modeled using the *Byzantine Synchronous Message-Passing model*, denoted *BSMP ⟨n, t⟩ [∅]* (following @raynal2018fault), where:

- *n* is the total number of nodes in the system,
- *t* is the maximum number of Byzantine nodes,
- [∅] indicates that no additional assumptions (such as authentication, signatures, or trusted components) are made beyond synchrony and reliable communication.

Unless stated otherwise, Byzantine nodes are assumed to have full control over their local state and outgoing messages, while still being subject to the constraints of the underlying communication network.

// == Time Assumptions


// Regarding time and node synchronization, we distinguish two execution models.

// In the first model, nodes are fully asynchronous. Each node executes independently and may send messages at arbitrary times, without any form of global synchronization. There is no notion of a shared clock or execution step, and nodes progress according to their own local pace.

// In the second model, nodes execute their actions according to a global notion of time, structured into discrete steps called cycles. In this setting, all nodes conceptually perform their actions once per cycle. Two variants of this model can be considered. In the first variant, nodes execute sequentially within a cycle: each node performs its actions one after another, and a cycle is completed once all nodes have finished their execution. While this assumption is not realistic in practical systems, it greatly simplifies modeling and simulation. In the second variant, all nodes execute simultaneously and instantaneously within each cycle. This assumption is also unrealistic in practice, but is commonly adopted to facilitate theoretical analysis and simulation.

// - Nodes execute asynchronously and do not share a global clock.



// == Metrics
// In an overlay network, the state of the system at a given instant can be represented as a graph snapshot of the underlying time-varying graph. Various metrics can then be computed on this graph in order to characterize the structure of the network, monitor its evolution over time, and compare different protocols.

// Metrics provide insights into connectivity, resilience, efficiency, and overall behavior of the network. In the context of time-varying graphs, these metrics can be computed either on a single snapshot $G(t)$ or observed as time-dependent quantities $m(t) = m(G(t))$ that evolve as the network topology changes.

// Commonly used metrics include the indegree and outdegree distributions, the clustering coefficient, the average path length, and the network diameter.

// The *indegree* and *outdegree* distributions are fundamental metrics that describe how connections are distributed among nodes at a given time.

// In a time-varying graph $G = (V, E, T)$, these distributions are computed on a snapshot $G(t) = (V(t), E(t))$ of the network. The outdegree of a node corresponds to the number of outgoing edges it maintains at time $t$, which in most peer-to-peer protocols reflects the size of the node's partial view. As a result, the outdegree is often bounded and relatively stable over time.

// In contrast, the indegree represents the number of incoming edges a node receives and may vary significantly across nodes. Monitoring the indegree distribution over time provides valuable insights into how the network adapts, which nodes become highly connected, and whether hubs or imbalances emerge.
// #definition(title: "Indegree and Outdegree Distributions")[
// The *indegree (resp. outdegree) distribution* of a network at time $t$ is the probability distribution of the number of incoming (resp. outgoing) edges of nodes in the graph snapshot $G(t)$.

// - For a network following a random graph distribution (Erdős–Rényi model), the degree distribution follows:
//   $P(k) = binom(n-1, k) p^k (1-p)^(n-1-k)$.

// - For a network following a scale-free distribution (Barabási–Albert model), the degree distribution follows:
//   $P(k) = C k^(-gamma)$,
//   where $gamma$ is the power-law exponent and $C$ is a normalization constant.
// ] <def:degree-distribution>

// The *clustering coefficient* measures the tendency of nodes to form tightly connected groups. It quantifies how likely it is that the neighbors of a node are also connected to each other.

// In a dynamic peer-to-peer network, the clustering coefficient can be computed at each time step on the snapshot $G(t)$, yielding a time-dependent metric that reflects the local cohesiveness of the network as it evolves. This metric is particularly useful for identifying the emergence of clusters or community structures.

// #definition(title: "Clustering Coefficient")[
// The clustering coefficient $C_i(t)$ of a node $i$ at time $t$ is defined as:
// $ C_i(t) = (2 e_i(t)) / (k_i(t)(k_i(t) - 1)) $

// Where:
// - $e_i(t)$ is the number of edges between the neighbors of node $i$ in $G(t)$,
// - $k_i(t)$ is the degree of node $i$ at time $t$.

// The average clustering coefficient of the network at time $t$ is:
// $ C(t) = 1 /(|V(t)|) sum_(i in V(t)) C_i(t) $
// ]

// The *average path length* characterizes the efficiency of information dissemination in the network. It corresponds to the mean of the shortest path lengths between all pairs of nodes.

// In time-varying graphs, the average path length is computed on each snapshot $G(t)$, allowing the observation of its evolution over time. A decreasing average path length may indicate improved connectivity or the emergence of highly connected nodes.

// #definition(title: "Average Path Length")[
// The average path length $a(t)$ of the network at time $t$ is defined as:
// $ a(t) = sum_(s, t' in V(t), s eq.not t') d(s, t') / (|V(t)| (|V(t)| - 1)) $

// Where:
// - $d(s, t')$ is the length of the shortest path between nodes $s$ and $t'$ in $G(t)$.
// ]

// // The *diameter* of a graph is a measure of the longest distance between any two vertices (nodes) in the graph, measured in terms of the number of edges. In other words, the diameter of a graph is the maximum shortest path between any pair of nodes in the network.

// // While the average path length provides a basic measure of information dissemination efficiency in algorithms, it may overlook disparities in dissemination speed across different nodes within the network. An algorithm could potentially have a favorable average path length but still exhibit uneven dissemination speeds among nodes due to varying distances. Calculating the network's diameter, however, offers a more comprehensive assessment.

// // #definition(title: "Diameter")[
// // The diameter of a network at time $t$ is defined as the length of the longest shortest path between any pair of nodes in the snapshot $G(t)$:

// // $
// // "diam"(G(t)) = max_(u, v in V(t)) d(u, v)
// // $

// // Where:
// // - $V(t)$ is the set of nodes in the network at time $t$.
// // - $d(u,v)$ is the length of the shortest path between nodes $u$ and $v$.
// // ]

// Beyond local and global structural metrics, connectivity properties play a central role in the analysis of peer-to-peer networks.  Connectivity metrics computed on $G(t)$ allow us to characterize whether the network remains operational, how information can propagate, and how resilient the topology is to node failures or churn.


// // #definition(title: "Weakly and Strongly Connected Components")[
// // Let $G(t) = (V(t), E(t))$ be a directed graph representing a snapshot of a peer-to-peer network at time $t$.

// // - A *strongly connected component (SCC)* is a maximal subset of nodes $C subset.eq V(t)$ such that for every pair of nodes $u, v in C$, there exists a directed path from $u$ to $v$ and from $v$ to $u$.

// // - A *weakly connected component (WCC)* is a maximal subset of nodes $C subset.eq V(t)$ such that the underlying undirected graph obtained by ignoring edge directions is connected.

// // The set of weakly or strongly connected components induces a partition of the vertex set $V(t)$. The number of such components characterizes the fragmentation level of the network at time $t$.
// // ] <def:connectivity>

// In typical operating conditions, peer-to-peer protocols aim to maintain a connected topology, and the snapshot graph $G(t)$ usually consists of a single weakly connected component. To assess the robustness of the network, we study how connectivity degrades under node removals.

// Starting from a connected snapshot, nodes are removed uniformly at random, one by one, simulating failures or departures. After each removal, we recompute the number of weakly and strongly connected components. The evolution of these quantities provides a quantitative measure of the network’s resilience: a topology is considered robust if it remains weakly connected, or fragments slowly, despite node failures.

// This analysis allows us to compare protocols in terms of fault tolerance and structural stability, independently of their specific message-passing behavior.



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
