#import "@preview/cetz:0.4.2"

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

== Peer-to-Peer System Model
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

// === Graph Theory
In order to study overlay networks, it is useful to adopt a mathematical representation that allows formalizing and comparing their properties. Graph theory provides a natural framework for this purpose. A network can be represented as a graph, where nodes correspond to servers or users, and edges represent connections between them. Depending on the nature of the connections, a network can be modeled as either undirected or directed: bidirectional connections (e.g., TCP connections) are naturally represented by undirected edges, while unidirectional connections (e.g., UDP connections) are better captured by directed edges. In overlay networks, edges do not correspond to direct physical connections, but rather to a node's virtual view of the network—that is, the subset of nodes that each node is aware of.
#definition(title: "Undirected Graph")[
  We take the definition from the book Graph Theory by Reinhard Diestel @diestel2016graph. An undirected graph is an ordered pair $G = (V, E)$:
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
  Again we take the definition from @diestel2016graph. A directed graph or digraph is a graph in which edges have orientations. A directed graph is an ordered pair $G = (V, E)$:
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

=== Emergent Behaviour

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

=== Churn
The execution model described above directly induces a dynamic evolution of the peer-to-peer network. As nodes repeatedly execute the protocol, both the local views of nodes and the global network topology may change over time.
Thus a first level of dynamicity arises from the protocol execution itself. After each execution of the protocol loop, a node may update its partial view of the network, for instance by adding, removing, or replacing neighbors. As a consequence, the set of outgoing edges of a node in the overlay graph may change from one protocol cycle to another. At this level of dynamicity, the set of nodes remains constant, and only the edge set of the graph evolves over time.

A second level of dynamicity is introduced by churn, that is, the dynamic arrival and departure of nodes in the system. We model churn as a temporally localized phenomenon rather than a permanent one. Specifically, churn occurs during a predefined period spanning several protocol cycles.

During a protocol cycle affected by churn, a given fraction of nodes is selected uniformly at random and disconnected from the network, similarly to permanent crash failures. These nodes are assumed to leave the system definitively and never rejoin. Within the same cycle, an equal number of new nodes joins the network. Each joining node executes the initialization function and subsequently participates in the protocol execution as a regular node.

After the churn period ends, no further nodes join or leave the system. The protocol continues to execute on a fixed set of nodes, allowing the network to evolve solely under the effect of the protocol logic. This post-churn phase is used to observe whether, and under which conditions, the system is able to recover from the instability induced by churn and converge back to a stable configuration.

This modeling choice reflects the fact that continuous churn keeps the system in a permanently unstable state. By separating churn phases from stabilization phases, we can explicitly study the resilience and self-healing properties of the peer-to-peer protocol.

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

=== Topology Models
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


== Machine Learning
Before discussing *federated learning* and *decentralized learning*, it is essential to first establish a clear understanding of classical *machine learning*. 
In this section, we provide the fundamental definitions and concepts of machine learning, which form the basis for more advanced distributed learning paradigms. 
// We introduce the notions of *machine learning models*, *parameters and weights*, *datasets*, *loss functions*, and *optimization procedures*, which will serve as a foundation for subsequent discussions on federated and decentralized learning frameworks.

#definition(title: "Machine Learning (Tom Mitchell, 1997)" )[
Following Tom Mitchell @learning1997tom, a *machine learning* system can be formally defined as :

"A computer program is said to *learn* from experience $E$ with respect
to some class of tasks $T$ and performance measure $P$, if its performance at tasks in
$T$, as measured by $P$, improves with experience $E$."

Formally, we denote:
- $E$: the experience or data that the system uses to learn;
- $T$: the class of tasks the system is intended to perform;
- $P$: the performance measure used to evaluate success on tasks in $T$.

This definition highlights that learning is the process by which a system improves its ability to perform a task through exposure to data or experience.
] <def:ml-mitchell>

Machine learning algorithms are typically categorized into three main types: 
*supervised learning*, *unsupervised learning*, and *reinforcement learning*. 
Supervised learning involves learning a mapping from input data to known outputs, 
unsupervised learning aims to discover patterns or structure in data without labeled outputs, 
and reinforcement learning focuses on learning optimal decision-making policies through repeated interaction with an environment, guided by a reward signal that evaluates the agent’s actions.

In the context of this thesis, our primary focus is on *supervised learning*, 
as it provides the foundation for the federated and decentralized learning approaches 
studied in the following chapters.


#definition(title: "Supervised Learning")[
  We take the definition from the book "Deep Learning" @Goodfellow-et-al-2016:

  Supervised learning involves observing several examples of a random vector 
  $x$ and an associated value or vector $y$, and learning to predict $y$ from 
  $x$, usually by estimating the conditional probability $p(y mid x)$.

  Formally, given a dataset of $N$ examples:
  $
    D = {(x_1, y_1), (x_2, y_2), dots, (x_N, y_N)},
  $
  the goal of supervised learning is to find a function $f_theta(x)$ parameterized 
  by $theta$ that approximates the mapping from $x$ to $y$, typically by minimizing 
  a loss function $L(f_theta(x), y)$ over the dataset.
] <def:supervized-ml>

#definition(title: "Loss Function")[
  In supervised learning, a *loss function* (or cost function) 
  quantifies the difference between the predicted output of a model 
  $f_theta(x)$ and the true output $y$. It provides a measure of 
  how well the model performs on a given example or dataset.

  Formally, for a single example $(x, y)$, the loss function $L$ is
  $
    L(f_theta(x), y) in RR_{>= 0},
  $
  where smaller values indicate better predictions.

  Examples of loss functions:
  - *Mean Squared Error (MSE)*: $L(f_theta(x), y) = ||f_theta(x) - y||^2$.
  - *Cross-Entropy Loss*: $L(f_theta(x), y) = -sum_i y_i log f_theta(x)_i$.

  The overall goal of supervised learning is to find parameters $theta$ 
  that minimize the expected loss over the dataset.
] <def:loss-function>

In supervised learning, prediction tasks can broadly be categorized into two types: *regression* and *classification*. 
Regression problems aim to predict a continuous value, while classification problems aim to assign an input to one of a discrete set of classes. 
In this thesis, we focus on *classification problems*, specifically *binary classification* (two possible classes) 
and *multinomial classification* (more than two classes).

#definition(title: "Binary Classification")[
Binary classification refers to the supervised learning task where each input $x$ is associated with a label $y$ 
that can take only two possible values, typically denoted $y in {0,1}$. 
The goal is to learn a function $f_theta(x)$ that outputs a predicted label $hat(y)$ that approximates the true label $y$. 

Formally, given a dataset:
$D = {(x_1, y_1), (x_2, y_2), ..., (x_N, y_N)},$
where $y_i in {0,1}$, the objective is to find 
$theta^* = "argmin"_theta sum_(i=1)^N L(f_theta(x_i), y_i),$ 
where $L$ is a loss function measuring the discrepancy between predicted and true labels.
] <def:binary-classification>

#definition(title: "Multinomial Classification")[
Multinomial classification generalizes binary classification to the case where each label $y$ 
can take one of $K > 2$ possible classes: $y in {1,2,...,K}$. 
The goal is to learn a function $f_theta(x)$ that outputs either a class label $hat(y)$ or a probability distribution over the $K$ classes.

Formally, given a dataset:
$D = {(x_1, y_1), (x_2, y_2), ..., (x_N, y_N)},$
where $y_i in {1,...,K}$, the objective is to find 
$theta^* = "argmin"_theta sum_(i=1)^(N) L(f_theta(x_i), y_i),$
with $L$ a suitable loss function for multi-class prediction.
] <def:multinomial-classification>

In supervised learning, once a loss function $L(f_theta(x), y)$ has been defined, the next step is to find a way to minimize this loss. 
Minimizing the loss corresponds to improving the model's performance on the task, that is, making its predictions closer to the true labels. 
This is achieved using an *optimization algorithm*. While many optimization algorithms exist, 
the most widely used in practice is *gradient descent* @cauchy1847methode and its variants, due to its simplicity and efficiency in handling large datasets.

Gradient descent iteratively updates the parameters of the model in the direction of the negative gradient of the loss function. This procedure requires that the loss function be *differentiable*, so that the gradient exists, and ideally have a *continuous gradient* to ensure stable updates. If the function is *convex*, then gradient descent is guaranteed to converge to the global minimum. However, in most machine learning applications, the loss function is *non-convex*, meaning that gradient descent may only reach a local minimum. Despite the lack of theoretical guarantees for reaching the global minimum, in practice gradient descent and its variants often yield very good results.

#definition(title: "Gradient Descent")[
Gradient descent is an iterative optimization algorithm used to minimize a differentiable function, such as a loss function in machine learning. 
The idea is to update the model parameters $theta$ in the direction opposite to the gradient of the loss function with respect to these parameters:

$theta_(t+1) = theta_t - eta * nabla_theta L(theta_t),$

where:
- $theta_t$ are the parameters at iteration $t$,
- $eta > 0$ is the learning rate controlling the step size,
- $nabla_theta L(theta_t)$ is the gradient of the loss function with respect to $theta$ evaluated at iteration $t$.

By repeatedly applying this update rule, the algorithm moves towards a local minimum of the loss function, thereby improving the model's performance.

The algorithm is typically stopped when one of the following conditions is met:
1. The absolute difference between successive loss values is smaller than a predefined threshold:
   $|L(theta_(t+1)) - L(theta_t)| < epsilon, "with" epsilon > 0$,
   in which case we consider that the algorithm has *converged*.
2. A maximum number of iterations $T_(max)$ is reached. In this case, the algorithm stops and the loss value at the final iteration is used.

] <def:gradient-descent>

In machine learning, it is common to divide the available dataset into a *training set* and a *test set* to prevent overfitting. 
The model is trained on the training set, which means that the parameters $theta$ of the function are updated to minimize the loss function $L(theta)$. 
The test set is used only to evaluate the model's performance on unseen data, which provides an estimate of its generalization ability. 

During training, the loss on the training set should decrease. However, if the loss on the test set starts to increase while the training loss continues to decrease, it indicates that the model is overfitting: it has learned to memorize the training data rather than capturing general patterns. 
This methodology ensures that the model achieves good predictive performance not only on the data it has seen but also on new, unseen data.

=== Machine Learning Models

==== Linear Regression

Linear regression is one of the simplest and most widely used models in machine learning. 
It is a type of supervised learning model used to predict a continuous output variable $y$ 
from one or more input features $x$. The model assumes a linear relationship between the input 
variables and the output, making it easy to interpret and efficient to train. 

Linear regression is often used as a baseline model before trying more complex algorithms, 
and it also serves as a foundation for understanding more advanced models such as generalized 
linear models and neural networks.

#definition(title: "Linear Regression")[
A linear regression model predicts a continuous output $y in RR$ from an input 
feature vector $x in RR^d$ using an affine function:

$
hat(y) = f_theta(x) = w^T x + b,
$

where:
- $w in RR^d$ is the weight vector,
- $b in RR$ is the bias term,
- $theta = (w, b)$ denotes the set of model parameters.

Given a training dataset 
$
D = {(x_1, y_1), ..., (x_N, y_N)},
$
the parameters $theta$ are learned by minimizing the mean squared error (MSE):

$
L(theta) = 1/N sum_(n=1)^N (y_n - f_theta(x_n))^2.
$
] <def:linear-regression>

==== Logistic Regression

Logistic regression is a supervised learning model used for classification tasks, 
rather than predicting continuous values. It is particularly suited for binary 
classification problems, where the goal is to predict whether an instance belongs 
to one of two classes. Unlike linear regression, logistic regression outputs 
a probability value between 0 and 1, which can then be thresholded to assign a class label.

The model is based on a linear combination of input features, transformed by 
the logistic (sigmoid) function, allowing it to model the probability of class membership.

#definition(title: "Logistic Regression")[
Logistic regression is a supervised learning model for binary classification. 
It estimates the probability that an input $x in RR^d$ belongs to the positive class:

$
p(y = 1 | x; theta) = sigma(w^T x + b),
$

where:
- $sigma(z) = 1 / (1 + exp(-z))$ is the sigmoid function,
- $theta = (w, b)$ are the model parameters.

The parameters are learned by minimizing the binary cross-entropy loss:

$
L(theta) = - 1/N sum_(n=1)^N [y_n log(hat(y_n)) + (1 - y_n) log(1 - hat(y_n))].
$
] <def:logistic-regression>

==== Multinomial Logistic Regression

While binary logistic regression predicts the probability of an instance 
belonging to one of two classes, multinomial logistic regression generalizes 
this approach to problems with $K > 2$ classes. In this case, the model outputs 
a probability distribution over all possible classes for each input instance. 
The probabilities are obtained using the softmax function, which ensures they 
sum to 1.

Multinomial logistic regression is widely used for multi-class classification 
tasks such as handwritten digit recognition, text categorization, or image labeling.

#definition(title: "Multinomial Logistic Regression")[
For a classification problem with $K$ classes, multinomial logistic regression 
models the conditional class probabilities using the softmax function.

Let:
- $x in RR^d$ be an input vector,
- $W in RR^(K times d)$ be the weight matrix,
- $b in RR^K$ be the bias vector.

The probability of class $k$ is given by:

$
p(y = k | x; theta) =
(exp((W x + b)_k))/(
sum_(j=1)^K exp((W x + b)_j)
),
$

where:
- $(W x + b)_k$ denotes the $k$-th component of the score vector,
- $theta = (W, b)$ are the model parameters.

The model is trained by minimizing the categorical cross-entropy loss:

$
L(theta) =
- 1/N sum_(n=1)^N sum_(k=1)^K y_("nk") log(p(y_n = k | x_n; theta)).
$
] <def:multinomial-logistic>

==== Neural Networks and Multi-Layer Perceptrons

The models introduced so far, such as linear and logistic regression, rely on a linear decision function of the form $f_theta(x) = theta^T x + b$. 
While these models are simple, efficient, and well understood, their expressive power is fundamentally limited: they can only represent linear decision boundaries in the input space.

Artificial neural networks extend these models by composing multiple linear transformations with nonlinear activation functions. 
The simplest neural network, known as the *single-layer perceptron*, consists of a single linear unit followed by a nonlinear activation function. 
Although this model already allows for binary classification, it remains limited to linearly separable problems.

To overcome this limitation, neural networks introduce *hidden layers*, leading to the so-called *Multi-Layer Perceptrons (MLPs)*. 
An MLP is a feedforward neural network composed of several layers of perceptrons, where each layer applies an affine transformation followed by a nonlinear activation. 
By stacking multiple such layers, MLPs are able to learn complex, nonlinear mappings between inputs and outputs.

This layered structure allows neural networks to progressively transform the input representation into higher-level features, making them powerful models for a wide range of tasks, including classification, regression, and function approximation.

#definition(title: "Multi-Layer Perceptron (MLP)")[
A Multi-Layer Perceptron (MLP) is a feedforward neural network composed of a finite sequence of layers, where each layer applies an affine transformation followed by a nonlinear activation function.

Let $x in R^{d_0}$ be an input vector. An MLP with $L$ layers defines a sequence of hidden representations $(h^(1), h^(2), ..., h^(L))$ as follows:

$
h^(0) = x,
$

$
h^(l) = phi^(l)(W^(l) h^(l-1) + b^(l)), quad l = 1, dots, L,
$

where:
- $W^(l) in R^{d_l times d_(l-1)}$ is the weight matrix of layer $l$,
- $b^(l) in R^{d_l}$ is the bias vector of layer $l$,
- $phi^(l): R^{d_l} -> R^{d_l}$ is a (possibly nonlinear) activation function applied element-wise,
- $h^(l) in R^{d_l}$ is the output of layer $l$.

The final output of the network is given by:

$
f_theta(x) = h^(L),
$

where $theta = {W^(1), b^(1), dots, W^(L), b^(L)}$ denotes the set of all trainable parameters of the network.

Depending on the learning task, the output layer may use a specific activation function, such as the identity function for regression or the softmax function for multi-class classification.
] <def:mlp>

=== Online Learning
In the previous sections, we described supervised learning models under the 
classical assumption that the entire training dataset is available in advance 
and that model parameters are optimized offline, what is commonly referred to as centralised learning, see @def:centralizedl-learning. However, in many real-world 
settings, data is generated sequentially over time, possibly in large volumes 
or under resource constraints, making repeated retraining impractical.

#definition(title: "Centralized Learning")[
Centralized learning refers to a learning paradigm in which all training data are 
collected and stored at a single location, and the learning process is performed 
using the complete dataset.

Formally, given a dataset $D = {(x_1, y_1), dots, (x_N, y_N)}$, a centralized learning 
algorithm assumes full access to all samples in $D$ during training and optimizes 
a model $f_theta$ by minimizing a loss function over the entire dataset.

In practice, training is often carried out using mini-batches for computational 
efficiency, particularly to leverage GPU or accelerator architectures. However, 
this does not alter the fundamental assumption of centralized learning, which 
requires that all data be available to the learner, either in advance or on demand.

As a consequence, centralized learning typically relies on a single machine or a 
tightly coupled computing cluster with sufficient computational and memory 
resources to process the full dataset. This paradigm therefore imposes strong 
constraints on data availability, scalability, and data locality.
] <def:centralizedl-learning>

Online learning addresses this limitation by allowing a model to be updated 
incrementally as new data becomes available. Instead of learning from a fixed 
dataset, the model continuously adapts to a stream of observations, enabling 
learning in dynamic, non-stationary, or distributed environments. This paradigm 
is particularly relevant in decentralized systems, streaming applications, 
and large-scale learning scenarios, which are central to the context of this 
thesis.

#definition(title: "Online Learning")[
Online learning is a learning paradigm in which model parameters are updated 
sequentially as data arrives, rather than being trained once on a fixed dataset.

At each time step $t$, the learning algorithm receives an input $x_t$, produces 
a prediction $hat(y)_t$, and then observes the true label $y_t$. Based on this 
feedback, the model parameters $theta_t$ are updated using an online optimization 
rule, typically of the form:

$
theta_(t+1) = theta_t - eta_t * nabla_theta L(f_(theta_t)(x_t), y_t)
$

where:
- $theta_t$ denotes the model parameters at time $t$,
- $eta_t > 0$ is a possibly time-dependent learning rate,
- $L$ is a loss function measuring the prediction error.

The objective of online learning is to minimize the cumulative loss over time, 
often expressed as:

$
sum_(t=1)^T L(f_(theta_t)(x_t), y_t)
$

while adapting efficiently to new data and potential changes in the data 
distribution.
] <def:online-learning>

=== Ensemble Learning
Beyond individual learning models, an important paradigm in machine learning 
consists in combining multiple models in order to improve predictive performance. 
This approach, known as ensemble learning, is based on the observation that 
multiple imperfect or weak models can collectively yield a more accurate and 
robust predictor than any single model alone.

Ensemble methods are particularly effective at reducing variance, improving 
generalization, and increasing robustness to noise or model misspecification. 
They play a central role in modern machine learning and are especially relevant 
in distributed and decentralized settings, where multiple models may be trained 
independently and later combined.
#definition(title: "Ensemble Learning")[
Ensemble learning is a learning paradigm in which a set of models 
${f_1, f_2, dots, f_M}$, often referred to as weak learners, are combined to form 
a single predictor $f_"ens"$ with improved performance.

A common form of ensemble model is a weighted aggregation of individual predictors:

$
f_"ens"(x) = sum_(m=1)^M alpha_m f_m(x),
$

where:
- $f_m$ denotes the prediction of model $m$,
- $alpha_m in R$ is a weight associated with model $m$.

For linear models, such as linear or logistic regression, this aggregation is 
equivalent to a single model of the same class, with parameters equal to the 
weighted sum of the individual parameters. In this case, the aggregation is 
order-independent and preserves linearity.

For nonlinear models, such as neural networks, the aggregation generally does not 
admit an equivalent representation within the same hypothesis class. The 
interaction between nonlinear decision functions may lead to more complex 
behaviors, and the resulting ensemble cannot, in general, be reduced to a single 
model.

Despite the lack of general theoretical guarantees for nonlinear ensembles, 
ensemble learning has been shown empirically to significantly improve predictive 
performance in a wide range of applications.
] <def:ensemble-learning>

=== Distributed Learning
While ensemble learning focuses on combining multiple models to improve predictive 
performance, it typically assumes that models are trained independently and that 
their aggregation is performed in a centralized manner. More generally, most 
classical machine learning algorithms rely on a centralized learning paradigm, in 
which all data and computation are collected and processed at a single location.

However, the increasing scale of data, computational requirements, and the 
emergence of decentralized systems have motivated the development of distributed 
learning approaches. In distributed learning, data, computation, or decision-making 
are spread across multiple nodes, which collaboratively contribute to the training 
process while operating under communication, synchronization, and resource 
constraints.

==== Data parallelism

Data parallelism is one of the most common forms of distributed learning and aims 
at accelerating training by distributing the data across multiple computing nodes. 
In this paradigm, the training dataset is partitioned into disjoint subsets, each 
assigned to a different worker, while all workers maintain a replica of the same 
model.

During training, each worker performs local updates of the model parameters using 
its own data partition, typically by computing gradients on mini-batches. These 
local updates are then aggregated, for instance by averaging the gradients or the 
model parameters, to produce a global model that is shared among all workers. This 
process is repeated iteratively until convergence.

Data parallelism preserves the centralized learning objective, as the model is 
effectively trained on the entire dataset, but distributes the computational load 
across multiple nodes. While this approach improves scalability and training speed, 
it still relies on frequent synchronization and communication between workers, and 
assumes a coordinated training process under a common optimization objective.

==== Model parallelism

Model parallelism is a form of distributed learning in which the model itself, rather 
than the data, is partitioned across multiple computing nodes. This approach is 
particularly useful when the model is too large to fit into the memory of a single 
device, as is often the case for deep neural networks with a large number of 
parameters.

In a model-parallel setting, each worker is responsible for computing and storing 
only a subset of the model parameters. During training, forward and backward passes 
are executed collaboratively: intermediate activations and gradients must be 
communicated between workers to propagate information through the model. As a 
result, model parallelism introduces fine-grained dependencies and requires careful 
coordination and synchronization among nodes.

While model parallelism enables the training of very large models that would be 
infeasible on a single machine, it typically incurs higher communication overhead 
than data parallelism and is more sensitive to latency. In practice, large-scale 
systems often combine model parallelism and data parallelism to balance memory 
constraints, computational efficiency, and communication costs.

==== Multi-agent reinforcement learning

Multi-Agent Reinforcement Learning (MARL) extends the reinforcement learning framework 
to settings involving multiple agents that learn and act simultaneously within a 
shared environment. In this paradigm, each agent aims to learn a policy that maximizes 
its expected cumulative reward, while the dynamics of the environment are influenced 
by the actions of all agents.

Unlike supervised learning, where learning is driven by labeled datasets, MARL relies 
on interaction, exploration, and reward signals. As a result, it falls outside the 
scope of this thesis, which primarily focuses on supervised learning and its 
distributed variants. Nevertheless, MARL is closely related to distributed learning 
in that it involves multiple autonomous learners whose behaviors jointly shape the 
learning process.

In most MARL formulations, agents are assumed to operate within a common environment 
and to observe either the same global state or partial views of that state. The 
presence of multiple learning agents introduces additional challenges, such as 
non-stationarity of the environment from the perspective of each agent, coordination 
and competition among agents, and the need for scalable learning algorithms.

Despite these challenges, MARL has proven effective in a variety of domains, including 
robotics, game theory, and distributed control, and remains an active area of research 
in distributed and decentralized learning systems.

==== Transfer Learning & Fine-Tuning

Transfer learning refers to a learning paradigm in which knowledge acquired from one 
task or domain is reused to improve learning performance on a different, but related, 
task or domain. Unlike distributed learning, transfer learning does not primarily aim 
at scaling computation or data across multiple machines. Instead, it focuses on 
reusing previously learned representations to reduce training cost, improve 
generalization, or enable learning when labeled data is scarce.

In a typical transfer learning setup, a model is first trained on a source dataset, 
often large and generic, to solve a source task. This pretraining phase allows the 
model to learn general-purpose representations. The pretrained model is then reused 
for a target task, which may involve a dataset that is smaller, noisier, or drawn from 
a different distribution. The source and target tasks may differ in terms of data 
modalities, label spaces, or objectives, but are assumed to share some underlying 
structure.

Fine-tuning is a specific instantiation of transfer learning. In fine-tuning, the 
pretrained model is further trained on the target dataset by continuing the 
optimization process, typically with a smaller learning rate. Depending on the 
application, fine-tuning may involve updating all model parameters or only a subset 
of them, such as the final layers of a neural network.

The key difference between transfer learning and fine-tuning lies in their scope. 
Transfer learning is a broad concept that encompasses any strategy that leverages 
knowledge from a source task, including feature extraction, representation reuse, and 
model initialization. Fine-tuning, by contrast, refers specifically to the adaptation 
of model parameters through additional training on the target task.

While transfer learning and fine-tuning are not distributed learning techniques per 
se, they are often complementary to distributed and federated learning systems. For 
instance, a global model may be pretrained in a centralized manner and later adapted 
locally on different nodes using fine-tuning, thereby combining representation reuse 
with decentralized data.

== Decentralized Learning

Decentralized learning naturally emerges at the intersection of peer-to-peer systems 
and machine learning. From a distributed systems perspective, it can be seen as a 
direct extension of decentralized computation: instead of collaboratively computing 
a single numerical value or global statistic, each node maintains a local machine 
learning model and a local dataset, and participates in the learning process through 
peer-to-peer interactions.

From a machine learning perspective, decentralized learning can be viewed as a 
generalization of distributed learning. Unlike classical distributed learning settings, 
where data are moved or aggregated to enable centralized computation, decentralized 
learning operates under the constraint that data remain local to each node. Learning 
is therefore achieved by moving models—or model updates—across nodes, rather than 
moving the data themselves.

Decentralized learning also shares strong conceptual links with online learning and 
ensemble learning. It resembles online learning in the sense that model updates are 
often performed sequentially, based on data from one node at a time. At the same time, 
it relates to ensemble learning, as multiple locally trained models are repeatedly 
combined or aggregated to form improved models. Through this iterative exchange and 
fusion of models, decentralized learning enables a collection of autonomous nodes to 
collectively optimize a learning objective.

==== Horizontal vs Vertical Learning

Decentralized learning approaches can be broadly categorized into two main settings, 
commonly referred to as horizontal and vertical learning, depending on how data are 
partitioned across nodes.

In horizontal decentralized learning, all nodes share the same feature space but 
operate on different subsets of data instances. Each node trains a local model on its 
own dataset, and learning proceeds by combining these local models. Model aggregation 
is typically performed parameter-wise, for example by averaging or weighted averaging 
corresponding parameters across nodes. This setting is particularly well suited to 
peer-to-peer and federated environments, where data are naturally distributed across 
participants but follow a common schema.

In contrast, vertical decentralized learning assumes that nodes observe the same set 
of data instances but with different feature subsets. In this case, no single node has 
access to the full feature vector of an instance. Learning therefore requires combining 
partial models or representations, often through the concatenation of parameters or 
intermediate feature embeddings. Vertical learning generally involves stronger 
coordination constraints and more complex communication patterns.

In this thesis, we focus on *horizontal decentralized learning*, which is by far the most common setting in the literature and aligns naturally with peer-to-peer systems where nodes independently collect data but operate under a shared model structure.

=== Assumptions

In order to focus on the algorithmic and theoretical aspects of decentralized learning, 
we make the following simplifying assumptions throughout this work.

- *Computational capabilities*:  
  Each node has sufficient computational resources to train its local machine learning model.  
  Moreover, all nodes are assumed to have identical computing power.

- *Storage capacity*:  
  Each node has enough local storage to hold its entire local dataset as well as any auxiliary 
  information required by the learning and communication protocols.

- *Computation time*:  
  The time required to perform local model updates (e.g., training or aggregation) is assumed 
  to be negligible. Local computations are therefore considered instantaneous.

- *Communication latency*:  
  The time required to transmit a model or model parameters between nodes is assumed to be 
  instantaneous.

- *Network bandwidth*:  
  Network bandwidth limitations are not considered. We assume an infinite bandwidth, such that 
  model transmissions do not incur congestion or queuing delays.

These assumptions allow us to abstract away system-level constraints and isolate the behavior 
of decentralized learning protocols from hardware and network effects.

=== Model of the learning system

To formally horizontal decentralized learning, we introduce the following notation. 
Let there be $N$ nodes in the network, each holding a local dataset $D_i$, where all datasets 
share the same feature space but contain different data instances. Each node trains a local 
model parameterized by $theta_i$ on its dataset $D_i$. 

The goal of horizontal decentralized learning is to obtain a global model that leverages 
all the distributed datasets without centralizing the raw data. This is typically achieved 
by aggregating the local models across nodes.

#definition(title: "Decentralized Learning System (Global View)")[
A horizontal decentralized learning system is modeled as a distributed dynamical system evolving 
over a time-varying directed graph $G = (V, E, T)$, where each node $v in V(t)$ corresponds to a computational 
agent holding a local dataset and a machine learning model.

Each node $v$ is modeled as a state machine with the following components:

- *Local state space* $S_v$ containing:
  - Local machine learning parameters $theta_v$,
  - Local machine learning dataset $D_v$, divided between a train set and a test set,
  - Cache containing the list of neighbors in the network,
  - Any local protocol state for P2P communication.

- *Initial state* $s_v^0$ representing the node's state at joining the system.

- *Transition function* mapping the current local state and incoming events 
  (messages or internal updates) to a new local state and a set of outgoing messages. 
  This function may involve:
  - Local model training on the node's dataset,
  - Aggregation of models received from neighbors,
  - Updates to the node's local P2P protocol state.

The *global state* of the system at time $t$ is:

$
S(t) = (s_v(t))_(v in V(t))
$

aggregating the local states of all nodes present in the network.

The *global parameters* of the system include:
- The machine learning algorithm and its hyperparameters,
- The aggregation model (e.g., weighted averaging, local vs global aggregation),
- P2P protocol parameters (e.g., neighbor selection, message scheduling),
- Any global objective or convergence criteria.

The *evolution* of the system results from the composition of all local state machines 
and the temporal evolution of the underlying time-varying graph, which constrains the 
possible communications between nodes. The P2P layer may operate independently of the ML layer, 
or it may be coupled such that the network topology depends on local ML parameters (e.g., nodes with similar models 
tend to communicate more frequently).

From this perspective, the decentralized learning system can be viewed as a large, 
distributed state machine whose global behavior emerges from the interaction of local 
ML updates and P2P communication between nodes.
] <def:decentralized-global>

While the decentralized learning system described above specifies the structural and dynamical 
organization of the network, it does not by itself characterize the quality of the learning 
process it induces. In contrast to purely topological protocols, whose objective is to reach 
a target overlay structure, decentralized learning protocols aim at collectively optimizing 
a machine learning objective through local computations and peer-to-peer interactions.

Since no central entity has access to all data or model parameters, the notion of convergence 
must be defined at the level of the system as a whole, based on the aggregate performance of 
the local models. This requires introducing a global performance criterion that reflects the 
learning quality achieved by the network, such as the average loss or prediction accuracy 
across nodes, and comparing it to a suitable reference, e.g., centralized training or an 
idealized optimum.

We therefore define machine learning convergence in decentralized networks as the ability of 
the protocol to drive the collection of local models, starting from arbitrary initializations, 
toward a regime where their collective performance satisfies a prescribed global criterion.


#definition(title: "Machine Learning Convergence in Decentralized Networks")[
A decentralized learning protocol is said to achieve *machine learning convergence* if, 
starting from any initial set of local models ${M_v(0)}_(v in V)$ with randomly initialized parameters, 
the sequence of local models ${M_v(t)}_(v in V, t >= 0)$ produced by the protocol satisfies a global performance criterion.

Formally, let $L_v(t)$ denote the loss of node $v$ at time $t$ evaluated on its local dataset, 
and define the average loss across all nodes as:
$
macron(L)(t) = 1/(|V|) sum_(v in V) L_v(t).
$

The protocol is said to converge if there exists a time $T >= 0$ such that:
$
forall t >= T, quad macron(L)(t) <= L^* + epsilon,
$
where $L^*$ is a reference loss, e.g., the loss obtained by centralized training on all data, 
and $epsilon > 0$ is a small tolerance parameter.

Alternatively, convergence can be defined in terms of other global performance metrics 
(e.g., accuracy, F1-score, or AUC) by replacing the average loss with the corresponding metric 
evaluated across all nodes.

Convergence may hold deterministically or in expectation, depending on the assumptions 
made on the protocol execution, the learning algorithm, and the statistical properties 
of the local datasets.
] <def:ml-convergence>

=== Aggregation
// Formally, given a set of models 
// $\{theta_v\}_(v in V)$, aggregation produces an updated model:
// $
// theta = 1/(|V|) sum_(v in V) theta_v
// $
As introduced in the previous section, decentralized learning protocols aim to achieve 
machine learning convergence through purely local computations and peer-to-peer interactions. 
However, in most practical settings, the amount of data available at a single node is not 
sufficient to train a model that achieves a low loss or high predictive performance. 
Consequently, collaboration between nodes is required in order to leverage the information 
contained in the distributed datasets.

Aggregation plays a central role in horizontal decentralized learning by enabling nodes to 
combine information learned locally into a shared representation. Rather than exchanging raw 
data, nodes periodically exchange model-related information and aggregate it to improve their 
local models.

Several aggregation strategies have been proposed in the literature. In this work, we focus on 
the simplest and most widely used approach: *Average SGD*, which consists in computing the 
arithmetic mean of the model parameters across multiple nodes.

#definition(title: "Average Stochastic Gradient Descent (Average SGD)")[
Let $N$ nodes participate in a decentralized learning process. Each node $i in {1, dots, N}$ 
holds a local dataset $D_i$ and maintains a local model parameterized by 
$theta_i(t) in RR^d$ at iteration $t$.

At each local iteration, node $i$ performs a stochastic gradient descent update on its 
local objective function $L_i(theta)$:

$
theta_i(t+1) = theta_i(t) - eta_t nabla L_i(theta_i(t); xi_i(t)),
$

where $eta_t > 0$ is the learning rate and $xi_i(t)$ is a mini-batch sampled from $D_i$.

After a synchronization step, the local models are aggregated by computing their arithmetic mean:
$
theta^(t+1) = 1/N sum_(i=1)^N theta_i(t+1).
$

The aggregated model $theta^(t+1)$ is then broadcast back to all nodes, which reset their local 
models accordingly:
$
forall i, quad theta_i(t+1) := theta^(t+1).
$

This procedure is repeated iteratively. Under standard assumptions such as convexity or smoothness 
of the loss function and IID data distribution across nodes, Average SGD converges to the same 
optimum as centralized SGD.
] <def:average-sgd>


An alternative approach consists in aggregating gradients rather than model parameters. In this 
case, nodes exchange local gradient updates, which are averaged and applied to a shared model. 
While gradient-based aggregation can offer finer control over the optimization process, we 
restrict our study to parameter-based aggregation for simplicity and clarity.

Aggregation can be interleaved with local training in different ways. One option is to first 
perform local training and then aggregate the resulting models. Another option is to aggregate 
models before performing further local training. In practice, both strategies are commonly used 
and often lead to similar convergence behavior under standard assumptions.

Another important design choice concerns the aggregation frequency. Nodes may aggregate their 
models at every learning cycle, or perform several local training steps before participating in 
an aggregation round. This trade-off impacts communication cost, convergence speed, and model 
stability.

Finally, the statistical properties of the local datasets play a crucial role. When local data 
are independently and identically distributed (IID), average SGD is known to perform well and 
often achieves convergence comparable to centralized training. Since this thesis primarily 
focuses on understanding the interaction between aggregation and decentralized network dynamics, 
we restrict our analysis to the IID data setting.

=== Aggregation Strategies

Decentralized and federated learning systems rely critically on aggregation mechanisms to combine information learned locally at different nodes into a coherent global outcome. While local training enables scalability and data locality, individual nodes typically possess only a limited and potentially biased view of the overall data distribution. As a consequence, aggregation plays a central role in enabling convergence toward a model that reflects the collective knowledge of the network.

Aggregation strategies differ not only in the mathematical operators they employ, but also—more fundamentally—in the network structures and communication patterns they assume. The choice of topology, ranging from centralized star-shaped architectures to fully decentralized peer-to-peer overlays, directly impacts convergence speed, robustness to failures, scalability, and resilience to churn. Understanding these trade-offs is therefore essential for the design and analysis of decentralized learning protocols.

Here, we look at the main aggregation strategies encountered in the literature, organized according to their underlying network topologies and coordination mechanisms. We progressively move from centralized and hierarchical approaches, such as Federated Learning and its multi-server extensions, to fully decentralized schemes based on gossip and local interactions.

We focus on aggregation strategies defined by network topology and communication patterns. Orthogonal aspects such as robust aggregation rules, privacy mechanisms, or incentive schemes are not discussed.

==== Federated Learning
Federated Learning (FL) is a decentralized learning paradigm in which multiple clients collaboratively train a shared machine learning model. Each client performs local training and only communicates model updates (e.g., parameters or gradients) to a coordinating entity, commonly referred to as the server.

The concept was introduced to address privacy, bandwidth, and data ownership constraints, particularly in large-scale systems such as mobile devices and edge computing environments. The seminal work by McMahan et al. @mcmahan2017communication formalized this setting and introduced the Federated Averaging (FedAvg) algorithm, which generalizes average SGD by allowing multiple local optimization steps between communication rounds.

From a network perspective, Federated Learning relies on a star-shaped topology: a single central server communicates with a set of clients, collects their local model updates, aggregates them, and broadcasts the resulting global model back to all participants. While this architecture enables efficient coordination and simplifies convergence analysis, it also introduces a strong centralization point.

As a result, although Federated Learning avoids centralizing data, it does not fully eliminate central control. The server is assumed to be reliable and trusted. If the server fails, becomes unavailable, or behaves in a Byzantine manner, the entire learning process may be compromised.

#figure(
pseudocode-list(booktabs: true)[
  - number of clients: *N*
  - local datasets: ${D_1, dots, D_N}$
  - learning rate: *eta*
  - number of communication rounds: *T*
  - local training steps per round: *E*
  - aggregation weights: ${w_1, dots, w_N}$

  - initial global model: $theta^(0)$

  + *for* $t = 0$ *to* $T - 1$
    + server broadcasts $theta^(t)$ to selected clients
    + *for each* client $i$ *in parallel*
      + $theta_i^(t,0) arrow.l theta^(t)$
      + *for* $e = 1$ *to* $E$
        + sample minibatch $B_i subset D_i$
        + $theta_i^(t,e) arrow.l theta_i^(t,e-1) - eta * nabla_theta L(theta_i^(t,e-1); B_i)$
      + $theta_i^(t+1) arrow.l theta_i^(t,E)$
      + send $(theta_i^(t+1))$ to server
    + server aggregates models:
      + $theta^(t+1) arrow.l sum_(i=1)^N w_i * theta_i^(t+1)$
  ],
  caption: [Federated Learning with Federated Averaging (FedAvg).],
) <algo:federated-learning>

==== Multi-Star Federated Learning

Multi-Star Federated Learning extends the classical federated learning paradigm by 
replacing the single central server with multiple coordinating servers. Each server 
acts as a local aggregation point for a subset of clients, forming multiple star-shaped 
subnetworks that may operate in parallel. This architecture is motivated by scalability, 
fault tolerance, and geographical distribution, and is commonly encountered in large-scale 
industrial deployments where a single server would become a performance bottleneck.

In a multi-star setting, clients are typically assigned to one or more servers, and 
perform local training in the same way as in standard federated learning. Each server 
collects the updated models from its associated clients and performs a local aggregation, 
for instance using Federated Averaging. Compared to the single-star topology, this reduces 
communication load and latency, and allows the system to scale to a much larger number of 
clients.

However, the presence of multiple servers raises fundamental design questions regarding 
global consistency and convergence. In particular, servers must be synchronized in order to prevent model drift between different regions of the network. Several synchronization 
strategies can be considered:

- *Server-level aggregation*: servers periodically exchange their aggregated models and perform a second-level aggregation.

- *Client-to-multiple-servers*: clients may send their local models to multiple servers, 
  increasing redundancy and robustness at the cost of higher communication overhead.

From a topological perspective, Multi-Star Federated Learning corresponds to a multi-star architecture. While it removes the single point of failure of classical federated learning, each server still represents a critical coordination node for its associated clients. If a server fails or behaves in a Byzantine manner, the learning process of its local star can be compromised, and inconsistencies may propagate to other servers during synchronization.

==== Hierarchical Federated Learning

Hierarchical Federated Learning generalizes the multi-star architecture by organizing 
servers into a tree-shaped topology, forming a hierarchy of aggregation levels. At the 
lowest level, clients perform local training and send their model updates to intermediate 
servers, which act as local aggregators. These intermediate servers then forward partially 
aggregated models upward in the hierarchy, until a final aggregation is performed at a 
root server.

From a graph-theoretic perspective, this architecture corresponds to a hierarchical or 
tree topology, where each internal node performs aggregation over the models received from 
its children. This hierarchical structure enables scalable learning over very large 
populations of clients by distributing the aggregation workload across multiple levels, 
thereby significantly reducing communication and computational pressure on the root server.

Hierarchical aggregation also reduces communication costs by limiting the number of model 
updates transmitted over long-distance or high-latency links. Instead of all clients 
communicating directly with a central server, only aggregated representations propagate 
upward in the tree. This makes hierarchical federated learning particularly attractive for 
geographically distributed systems and edge–cloud architectures.

Despite these scalability benefits, hierarchical federated learning remains fundamentally 
centralized and inherits several limitations from tree-based topologies. In particular, 
the structure is typically rigid, with predefined parent–child relationships. Failures of 
intermediate aggregation nodes can disconnect entire subtrees, temporarily preventing a 
large number of clients from contributing to the global model. Similarly, failures or 
Byzantine behavior at higher levels of the hierarchy may corrupt or block the learning 
process for all downstream nodes.

==== Blockchain-Based Federated Learning

Blockchain-based Federated Learning aims at combining federated learning with distributed 
ledger technologies in order to remove the reliance on a single trusted coordinator. A large 
body of recent literature explores this direction, motivated by the promise of decentralization, 
auditability, and trust minimization.

Several architectural strategies have been proposed. In a first approach, each participant 
submits its local model update to a smart contract deployed on the blockchain. Once a sufficient 
number of updates has been received, the smart contract performs the aggregation and publishes 
the resulting global model. In this setting, the blockchain acts as a decentralized coordinator 
that enforces participation rules and aggregation logic.

An alternative approach relies on the block validation process. Instead of performing aggregation 
on-chain, the block validator designates a node, or a small group of nodes, as aggregators for a 
given round. Participants then send their local models to the selected aggregator, which computes 
the aggregated model and disseminates it to the network. The blockchain is used only to record 
the selection process and ensure accountability.

While these approaches introduce a degree of decentralization, they also inherit significant 
limitations from blockchain technology. First, blockchain systems require consensus on an exact 
global state, whereas machine learning optimization only aims at converging toward a sufficiently 
low loss. Enforcing strict consensus at every learning round introduces substantial overhead 
without providing proportional benefits to the learning process.

Second, storing model parameters directly on-chain is often impractical due to storage constraints 
and associated costs, especially for large models. As a result, most practical implementations 
resort to off-chain storage or aggregation, which reintroduces trust assumptions and partially 
undermines the decentralization objective.

Moreover, when aggregation is performed by a single node or a small committee selected by the 
block validator, the system becomes vulnerable to centralization risks. The correctness of the 
learning process then depends on the honesty and availability of the designated aggregators, 
which contradicts the original motivation for using a blockchain.

From a topological perspective, blockchain-based federated learning typically corresponds to a 
fully connected interaction model when smart contracts are used, as all participants are assumed 
to be globally identifiable. When off-chain aggregators are employed, the resulting structure 
resembles a star topology, with the aggregator acting as a temporary central node.

Although the idea of combining blockchain and federated learning is conceptually appealing, it 
remains challenging to deploy in practice. The high communication latency, storage overhead, 
and consensus costs of blockchain systems are poorly aligned with the iterative and approximate 
nature of distributed machine learning. As a result, blockchain-based federated learning often 
introduces more complexity than it removes, especially when scalability and efficiency are 
primary concerns.

==== Gossip Learning

Gossip Learning is a fully decentralized learning paradigm in which nodes exchange models 
through randomized peer-to-peer interactions. At each communication round, a node selects 
one of its neighbors uniformly at random and sends its current local model to that neighbor. 
There is no central coordinator and no notion of a global aggregation phase.

Upon receiving a model from a neighbor, a node performs a local aggregation between the 
received model and its own local model, typically by computing a weighted or uniform average 
of their parameters. The resulting aggregated model is then refined by performing one or 
several local learning steps using the node’s private dataset. This interaction pattern is 
repeated asynchronously across the network, leading to a gradual diffusion of information.

Several variants of gossip learning exist. In the most common formulation, aggregation is 
performed before the local learning step. An alternative variant applies a local learning 
update independently to both models before merging them, which can improve robustness in 
non-IID data settings. Another extreme variant removes aggregation altogether: the local 
model is simply replaced by the received model. In this case, models effectively perform 
random walks over the network, and learning corresponds to successive local updates applied 
along these trajectories.

Gossip learning is typically deployed over random graph topologies, where the randomized 
communication pattern ensures sufficient mixing properties. Aggregation remains strictly 
local, and no global model is ever explicitly computed. Nevertheless, under suitable 
assumptions on the learning rate, loss function, and network connectivity, the local models 
are known to converge toward a common global solution. This convergence, however, is 
significantly slower than in Federated Learning due to the absence of coordinated global 
synchronization and the limited bandwidth of local interactions.

Despite its slower convergence, gossip learning offers strong advantages in terms of system 
robustness. The absence of any central entity makes the scheme inherently resilient to node 
failures, network partitions, and churn. Nodes can join or leave the system dynamically 
without disrupting the learning process, provided the underlying communication graph remains 
connected on average. These properties make gossip learning particularly attractive for 
large-scale, dynamic, and failure-prone environments where centralized or hierarchical 
approaches are impractical.
#align(center,
grid(columns: 2,
[#figure(
pseudocode-list(
  booktabs: true,
  title: [Gossip Learning (main thread)],
)[
  - ML model: *model*
  - List of neighbors : *cache*
  // + model $arrow.l$ initModel()
  + *loop*
    + Wait for *Δ* time units
    + peer $arrow.l$ selectRandom(cache)
    + send(peer, model)
], caption: [Gossip Learning]
) <algo:gossip-learning>
],
[#figure(
pseudocode-list(
  booktabs: true,
  title: [Gossip Learning (background thread)],
)[
  - ML model: *model*
  - local dataset: *data*
  + *loop*
    + peer_model $arrow.l$ receive()
    + model $arrow.l$ merge(model, peer_model)
    + model.update(data)
], caption: [Gossip Learning (background thread)]
) <algo:gossip-learning-background>
])
)

==== Gossip Broadcast Learning

Gossip Broadcast Learning is a decentralized learning scheme in which each node exchanges 
its local model with all of its neighbors at every communication round. Contrary to classical 
gossip learning, where interactions are pairwise and asynchronous, this approach requires 
each node to wait for the models of all its neighbors before performing aggregation. As a 
result, the learning process is inherently synchronous.

At each round, a node broadcasts its current model to all adjacent nodes and collects the 
models received from its neighborhood. Once all expected models have been received, the node 
computes an aggregation, typically by averaging the parameters of its own model with those of 
its neighbors. The aggregated model is then updated using a local learning step on the node’s 
private dataset. This process is repeated synchronously across the network.

Gossip Broadcast Learning can be deployed over various network topologies. On random graphs, 
it preserves some of the decentralization benefits of gossip learning while accelerating 
convergence thanks to richer local aggregation. On a fully connected topology, where every 
node is connected to all others, the scheme becomes equivalent to a global aggregation 
performed in a fully decentralized manner.

However, the increased degree of connectivity comes at a significant cost. The communication 
and aggregation overhead grows linearly with the number of neighbors, making the approach 
poorly scalable for high-degree nodes. In fully connected networks, the communication cost 
per round becomes prohibitive as the number of nodes increases. Furthermore, the synchronous 
nature of the protocol makes it sensitive to stragglers and node failures, as a single slow 
or unavailable neighbor can delay the entire aggregation step.

While Gossip Broadcast Learning offers faster convergence than pairwise gossip schemes, it 
sacrifices robustness and scalability. This trade-off highlights the inherent tension between 
rich aggregation, decentralization, and fault tolerance, and motivates the exploration of 
adaptive or hierarchical aggregation strategies that balance these competing objectives.

==== Decentralized Learning on Ring Topology

Decentralized learning can also be implemented over a ring topology, although this approach 
is relatively uncommon in the machine learning literature. In a ring-based system, each node 
maintains connections with exactly two neighbors, typically referred to as its left and right neighbors, forming a closed cycle. This topology is simple, deterministic, and requires each node to store only a constant number of connections, which makes it attractive from a 
maintenance and routing perspective.

Several aggregation strategies can be employed in a ring topology. A first approach consists 
in *local neighborhood aggregation*, where each node periodically exchanges model parameters 
or updates with its immediate neighbors and aggregates them, for instance by averaging its 
own model with those received from the left and right neighbors.

A second strategy relies on *model circulation*. In this approach, a single model is passed sequentially from node to node along the ring. Each node locally updates the received model using its own dataset before forwarding it to the next neighbor. 
After a full traversal of the ring, the model has effectively been trained on the data of all 
nodes, in a manner reminiscent of incremental or online learning. 
Despite its conceptual simplicity, decentralized learning on a ring topology suffers from 
significant limitations. Information propagation is inherently slow, as updates must traverse 
the ring sequentially, leading to convergence times that grow linearly with the number of 
nodes. Moreover, the rigid structure of the ring makes the system particularly vulnerable to 
failures and churn. The failure of a single node or link may break the ring and disconnect the 
network unless additional repair mechanisms are employed. Frequent joins and leaves further 
complicate the maintenance of the ring structure and may disrupt the learning process.

// explain each aggregation model and like them to the corresponding topology
// Federated Learning
// Hierarchical Federated Learning
// Blockchain based Federated Learning
// Gossip Learning
// Gossip Learning All to All

#figure(
table(
  columns: (1fr, 1fr),
  inset: 10pt,
  align: horizon,

  table.header(
    [*Aggregation strategy*], [*Associated topology*],
  ),

  [Federated Learning],
  [Star (single central server)],

  [Multi-Star Federated Learning],
  [Multiple stars],

  [Hierarchical Federated Learning],
  [Tree / hierarchical topology],

  [Blockchain-Based Federated Learning],
  [Complete graph or star],

  [Gossip Learning],
  [Random graph],

  [Gossip Broadcast Learning],
  [Random graph or complete graph],

  [Ring-Based Decentralized Learning],
  [Ring],
),  caption: [Aggregation strategies and their associated network topologies.],
) <tab:aggregation-strategies-topology>


=== Failure Models
// privacy attacks
// byzantine attacks (backdoor and poisoning)

== Metrics
=== On the Overlay Level
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

The *diameter* of a graph is a measure of the longest distance between any two vertices (nodes) in the graph, measured in terms of the number of edges. In other words, the diameter of a graph is the maximum shortest path between any pair of nodes in the network.

While the average path length provides a basic measure of information dissemination efficiency in algorithms, it may overlook disparities in dissemination speed across different nodes within the network. An algorithm could potentially have a favorable average path length but still exhibit uneven dissemination speeds among nodes due to varying distances. Calculating the network's diameter, however, offers a more comprehensive assessment.

#definition(title: "Diameter")[
The diameter of a network at time $t$ is defined as the length of the longest shortest path between any pair of nodes in the snapshot $G(t)$:

$
"diam"(G(t)) = max_(u, v in V(t)) d(u, v)
$

Where:
- $V(t)$ is the set of nodes in the network at time $t$.
- $d(u,v)$ is the length of the shortest path between nodes $u$ and $v$.
]

Beyond local and global structural metrics, connectivity properties play a central role in the analysis of peer-to-peer networks.  Connectivity metrics computed on $G(t)$ allow us to characterize whether the network remains operational, how information can propagate, and how resilient the topology is to node failures or churn.


#definition(title: "Weakly and Strongly Connected Components")[
Let $G(t) = (V(t), E(t))$ be a directed graph representing a snapshot of a peer-to-peer network at time $t$.

- A *strongly connected component (SCC)* is a maximal subset of nodes $C subset.eq V(t)$ such that for every pair of nodes $u, v \in C$, there exists a directed path from $u$ to $v$ and from $v$ to $u$.

- A *weakly connected component (WCC)* is a maximal subset of nodes $C subset.eq V(t)$ such that the underlying undirected graph obtained by ignoring edge directions is connected.

The set of weakly or strongly connected components induces a partition of the vertex set $V(t)$. The number of such components characterizes the fragmentation level of the network at time $t$.
] <def:connectivity>

In typical operating conditions, peer-to-peer protocols aim to maintain a connected topology, and the snapshot graph $G(t)$ usually consists of a single weakly connected component. To assess the robustness of the network, we study how connectivity degrades under node removals.

Starting from a connected snapshot, nodes are removed uniformly at random, one by one, simulating failures or departures. After each removal, we recompute the number of weakly and strongly connected components. The evolution of these quantities provides a quantitative measure of the network’s resilience: a topology is considered robust if it remains weakly connected, or fragments slowly, despite node failures.

This analysis allows us to compare protocols in terms of fault tolerance and structural stability, independently of their specific message-passing behavior.

=== On the Machine-Learning Level

== Conclusion

#figure(
cetz.canvas({
  import cetz.draw: *
  // Dimensions
  let w = 4
  let h = 2  
  let spacing = 2

  // Couleurs
  let colors = (
    rgb(70%, 70%, 70%),    // light grey
    rgb(75%, 90%, 75%),   // green
    rgb(75%, 85%, 95%),   // blue
    rgb(85%, 75%, 90%),   // violet
  )

 
  // Arrow labels
  let labels = (
    "Network Layer",
    "Overlay Layer",
    "Aggregation Layer",
    "Application Layer",
  )
  for i in range(4) {
    rect((0, i*spacing), (w, h + (i*spacing)), name: "rect_"+str(i), fill: colors.at(i)) 
  
    content("rect_"+str(i), labels.at(i))  
  }
}), caption: [Architecture]
) <fig:system-architecture>
