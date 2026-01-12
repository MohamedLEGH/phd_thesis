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

== Metrics
In a peer-to-peer network, the state of the network at a given instant can be represented as a graph, and we can compute various metrics on this graph to characterize its structure. Calculating these metrics is crucial to understand the network's properties, monitor its evolution over time, and compare different protocols. Metrics provide insights into connectivity, resilience, efficiency, and overall behavior of the network. Commonly used metrics include the indegree and outdegree distributions, the network diameter, the average path length, and the clustering coefficient, among others.

The *indegree* and *outdegree* distributions are fundamental metrics that describe how connections are distributed among nodes. The outdegree distribution corresponds to the number of outgoing connections each node maintains, which in most peer-to-peer protocols reflects the size of each node's partial view. Consequently, the outdegree is often uniform across nodes and remains stable over time. In contrast, the indegree distribution represents the number of incoming connections a node receives and can vary significantly, especially in networks with dynamic topologies or evolving hubs. Monitoring the indegree distribution over time provides valuable insights into how the network adapts, which nodes are highly connected, and how load or influence is distributed.
#definition(title: "Indegree and Outdegree Distributions")[
  The *indegree (resp. outdegree) distribution* of a network represents the probability distribution of the number of incoming (resp. outgoing) connections of nodes over the entire network. In other words, it characterizes how the connections are spread among the nodes.
  
  - For a network following a random graph distribution (Erdős–Rényi model), the degree distribution follows
    $P(k) = binom(n-1,k) p^k (1-p)^(n-1-k)$.
  - For a network following a scale-free distribution (Barabási–Albert model), the degree distribution follows
    $P(k) = C k^(-gamma)$, where $gamma$ is the power-law exponent and $C$ is a normalization constant.
] <def:degree-distribution>

The *clustering coefficient* is a fundamental metric in network analysis, as it measures the tendency of nodes to form tightly connected groups. Intuitively, it quantifies how likely it is that the neighbors of a node are also connected to each other. In random graphs, the clustering coefficient tends to be low because connections are made independently, whereas networks with hubs or communities usually exhibit a higher clustering coefficient. This metric provides insight into the local cohesiveness of the network and can reveal the presence of clusters or modular structures.

#definition(title: "Clustering Coefficient")[
The clustering coefficient 
$C_i$ of a node $i$ is defined as the ratio between the number of edges connecting its neighbors and the total number of possible edges between them:
$ C_i = (2e_i)/(k_(i)(k_i - 1)) $
Where:
- $e_i$ is the number of edges between the neighbors of node $i$ (i.e., the number of closed triangles including node $i$)
- $k_i$ is the degree of node $i$, representing the total number of connections of that node.

$ C = 1/n sum_(i=1)^(n) C_i $
]

The *average path length* of a network is an important metric that characterizes how efficiently information can be transmitted across the network. It corresponds to the mean of the shortest path lengths between all pairs of nodes. A small average path length indicates that any node can be reached from any other node in a relatively small number of steps, which is typical in small-world or scale-free networks. Conversely, in networks with long chains or sparse connectivity, the average path length tends to be larger.

#definition(title: "Average Path Length")[
The average path length $a$ of a network is defined as the mean of the shortest path lengths $d(s,t)$ between all pairs of distinct nodes $s$ and $t$ in the network:
// s,t in V, s eq.not t

$ a = sum_(s,t in V, s eq.not t) d(s,t)/(n(n-1)) $

Where:
- $V$ is the set of nodes in the network, with $|V| = n$
- $d(s,t)$ is the length of the shortest path between nodes $s$ and $t$.
]

The *diameter* of a graph is a measure of the longest distance between any two vertices (nodes) in the graph, measured in terms of the number of edges. In other words, the diameter of a graph is the maximum shortest path between any pair of nodes in the network.

While the average path length provides a basic measure of information dissemination efficiency in algorithms, it may overlook disparities in dissemination speed across different nodes within the network. An algorithm could potentially have a favorable average path length but still exhibit uneven dissemination speeds among nodes due to varying distances. Calculating the network's diameter, however, offers a more comprehensive assessment.

#definition(title: "Diameter")[
The diameter of a network $G$ is the length of the longest shortest path between any pair of nodes in the network:

$
"diam"(G) = max_(u,v in V) d(u, v)
$

Where:
- $V$ is the set of nodes in the network
- $d(u,v)$ is the length of the shortest path between nodes $u$ and $v$.
]

