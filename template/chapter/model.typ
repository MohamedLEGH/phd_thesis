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

The execution model described above directly induces a dynamic evolution of the peer-to-peer network. As nodes repeatedly execute the protocol, both the local views of nodes and the global network topology may change over time.
Thus a first level of dynamicity arises from the protocol execution itself. After each execution of the protocol loop, a node may update its partial view of the network, for instance by adding, removing, or replacing neighbors. As a consequence, the set of outgoing edges of a node in the overlay graph may change from one protocol cycle to another. At this level of dynamicity, the set of nodes remains constant, and only the edge set of the graph evolves over time.

=== Churn

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

== Machine Learning
Before discussing *federated learning* and *decentralized learning*, it is essential to first establish a clear understanding of classical *machine learning*. 
In this section, we provide the fundamental definitions and concepts of machine learning, which form the basis for more advanced distributed learning paradigms. 
// We introduce the notions of *machine learning models*, *parameters and weights*, *datasets*, *loss functions*, and *optimization procedures*, which will serve as a foundation for subsequent discussions on federated and decentralized learning frameworks.

#definition(title: "Machine Learning (Tom Mitchell, 1997)" )[
A *machine learning* system can be formally defined following Tom Mitchell @learning1997tom:

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
*supervised learning*, *unsupervised learning*, and *transfer learning*. 
Supervised learning involves learning a mapping from input data to known outputs, 
unsupervised learning aims to discover patterns or structure in data without labeled outputs, 
and transfer learning focuses on leveraging knowledge from one domain or task to improve 
performance on another. 

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

==== Linear Regression


Linear regression is one of the simplest and most widely used models in machine learning. 
It is a type of supervised learning model used to predict a continuous output variable $y$ 
from one or more input features $x$. The model assumes a linear relationship between the input 
variables and the output, making it easy to interpret and efficient to train. 

Linear regression is often used as a baseline model before trying more complex algorithms, 
and it also serves as a foundation for understanding more advanced models such as generalized 
linear models and neural networks.

#definition(title: "Linear Regression")[
A linear regression model predicts the output $y$ from input features $x = (x_1, x_2, ..., x_d)$ using a linear function:

$
hat(y) = f_theta(x) = theta_0 + theta_1 x_1 + theta_2 x_2 + ... + theta_d x_d = theta_0 + sum_{i=1}^d theta_i x_i
$

where:
- $theta = (theta_0, theta_1, ..., theta_d)$ are the model parameters (intercept and weights),
- $hat(y)$ is the predicted value for the input $x$.

The parameters $theta$ are estimated by minimizing the mean squared error (MSE) over the training dataset $D$:

$
L(theta) = 1/N sum_(n=1)^N (y_n - f_theta(x_n))^2
$
]

==== Logistic Regression

Logistic regression is a supervised learning model used for classification tasks, 
rather than predicting continuous values. It is particularly suited for binary 
classification problems, where the goal is to predict whether an instance belongs 
to one of two classes. Unlike linear regression, logistic regression outputs 
a probability value between 0 and 1, which can then be thresholded to assign a class label.

The model is based on a linear combination of input features, transformed by 
the logistic (sigmoid) function, allowing it to model the probability of class membership.

#definition(title: "Logistic Regression")[
A logistic regression model predicts the probability that an input $x = (x_1, x_2, ..., x_d)$ 
belongs to the positive class as:

$
p(y = 1 | x; theta) = sigma(f_theta(x)) = sigma(theta_0 + sum_(i=1)^d theta_i x_i)
$

where:
- $theta = (theta_0, theta_1, ..., theta_d)$ are the model parameters,
- $sigma(z) = 1 / (1 + exp(-z))$ is the sigmoid (logistic) function,
- $hat(y) = p(y=1 | x; theta)$ is the predicted probability of the positive class.

The parameters $theta$ are typically estimated by maximizing the likelihood of the training data, 
equivalently by minimizing the logistic loss (or cross-entropy loss):

$
L(theta) = - 1/N sum_(n=1)^N [y_n log(hat(y_n)) + (1 - y_n) log(1 - hat(y_n))]
$
]

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
Given an input vector $x = (x_1, x_2, ..., x_d)$ and $K$ possible classes, 
the probability that $x$ belongs to class $k$ is:

$
p(y = k | x; theta) = "softmax"_k(f_theta(x)) = (exp(f_(theta_k)(x)))/(sum_(j=1)^K exp(f_(theta_j)(x)))
$

where:
- $f_(theta_k)(x) = theta_("k0") + sum_(i=1)^d theta_("ki") x_i$ is the linear score for class $k$,
- $theta_k = (theta_("k0"), theta_("k1"), ..., theta_("kd"))$ are the parameters for class $k$,
- $"softmax"_k$ denotes the $k$-th component of the softmax output vector.

The parameters $theta = (theta_1, ..., theta_K)$ are typically learned by minimizing 
the cross-entropy loss over the training set:

$
L(theta) = - 1/N sum_(n=1)^N sum_(k=1)^K y_("nk") log(p(y_n = k | x_n; theta))
$

where $y_("nk") = 1$ if example $n$ belongs to class $k$, and $0$ otherwise.
]



== Aggregation

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
