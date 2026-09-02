#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/lovelace:0.3.0": *

#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
#show: show-theorion

= Overlay Management in Peer to Peer Systems <chap:overlay>

Peer-to-peer systems have a long history, from early file-sharing networks such
as Napster and BitTorrent to anonymisation overlays such as Tor, and more
recently to blockchain-based infrastructures. What these systems share is a
common architectural principle: nodes communicate directly with one another
without relying on a central coordinator, forming a logical overlay network on
top of the physical Internet. A detailed account of this history and the
motivations behind peer-to-peer architectures is provided in @sec:p2p-history.

These applications — from file sharing to distributed computing and
decentralised finance — all rely on a common foundation: a logical overlay
network that governs how peers discover one another, exchange messages, and
maintain connectivity. Overlay management refers to the mechanisms used to
construct, maintain, and adapt this logical topology. In centralized approaches,
a single entity (or a small set of entities) is responsible for managing the
network structure, which naturally leads to star or multi-star topologies.
While such solutions are simple and efficient, they are not desirable in
peer-to-peer systems, where decentralization, fault tolerance, and the absence
of a single point of failure are key design goals. Consequently, overlay
management in peer-to-peer networks must be performed in a fully decentralized
manner.

This chapter builds upon the system model introduced in the previous chapter,
in which the peer-to-peer system is viewed as a set of autonomous nodes
interacting through a logical overlay network. In this model, the overlay
abstracts the underlying physical network and defines the effective
communication topology on which all higher-level distributed protocols operate.
An overlay management algorithm can therefore be understood as a decentralized
protocol whose primary objective is to ensure the creation, maintenance, and
adaptation of this logical topology. By continuously managing neighbor
relationships, such protocols must cope with the dynamic conditions inherent
to peer-to-peer systems, including node arrivals, departures, and failures,
while preserving desired structural properties of the overlay.

#definition(title: "Overlay Management")[
An overlay management algorithm is a fully decentralized protocol (see @def:p2p-protocol) whose goal is to construct, maintain, and adapt the logical topology of a peer-to-peer system. It governs how nodes establish and update their neighbor sets (also called their partial view, see @def:partial-view) in order to ensure connectivity, robustness to churn and failures, and structural properties required by higher-level distributed protocols.
]

== Metrics

Before surveying the existing overlay management protocols, we first establish
the quantitative criteria against which they will be evaluated. In order to
assess the effectiveness of an overlay management protocol, it is necessary to
define metrics that capture the structural and dynamical properties of the
resulting network. In an overlay network, the state of the system at a given instant can be represented as a graph snapshot of the underlying time-varying graph (as seen in @def:tvg). Various metrics can then be computed on this graph in order to characterize the structure of the network, monitor its evolution over time, and compare different protocols. Metrics provide insights into connectivity, resilience, efficiency, and overall behavior of the network. In the context of time-varying graphs, these metrics can be computed either on a single snapshot $G(t)$ or observed as time-dependent quantities $m(t) = m(G(t))$ that evolve as the network topology changes.
Commonly used metrics include the indegree and outdegree distributions, the clustering coefficient, the average path length, and the network diameter.

==== Degree Distribution

The *indegree* and *outdegree* distributions are fundamental metrics that describe how
connections are distributed among nodes at a given time. They are derived from the
notions of degree introduced in @def:degree and @def:inoutdegree. Formally, given a
directed overlay graph $G = (V, E)$ at time $t$, the outdegree distribution is the
distribution of $"outdegree"_G (v)$ over all $v in V$, while the indegree distribution
is the distribution of $"indegree"_G (v)$ over all $v in V$.

Degree distributions serve as a primary tool for characterising the topology produced
by an overlay management protocol. As the number of nodes may reach several thousands,
direct graph visualisation becomes impractical; degree distributions provide a compact
summary of the structural properties of the network. Moreover, deviations from the
expected distribution — such as an unexpected concentration of indegree on a small
subset of nodes — may signal undesired behaviour in the overlay protocol, such as load
imbalance or the unintended emergence of bottlenecks.

In the overlay model adopted in this thesis, the outdegree is constrained by design and
remains approximately constant, as it corresponds to the fixed size of the partial view
maintained by each node. Consequently, structural heterogeneity primarily appears in the
indegree distribution. In overlays that approximate random graphs, the indegree
distribution typically follows a binomial distribution. In contrast, in scale-free or
power-law overlays, the indegree distribution follows a power-law of the form
$P(k) tilde k^gamma$, leading to the emergence of highly connected nodes (hubs).

==== Clustering Coefficient

The clustering coefficient (see @def:clusteringcoef) measures the tendency of nodes to
form tightly connected groups, quantifying how likely it is that the neighbours of a
node are also connected to each other. In a dynamic peer-to-peer network, the clustering
coefficient can be computed at each time step on the snapshot $G(t)$, yielding a
time-dependent metric that reflects the local cohesiveness of the network as it evolves.
This metric is particularly useful for identifying the emergence of clusters or community
structures.

In the context of overlay management, monitoring the clustering coefficient provides
critical insights into the trade-offs between connectivity, routing efficiency, and
maintenance overhead. A low clustering coefficient typically indicates a topology
approaching a random graph, which favours uniform load distribution and short average
path lengths. Conversely, a high clustering coefficient suggests
denser, more locally interconnected structures that can enhance neighbourhood discovery and fault tolerance through redundant alternative paths, at the
cost of increased link maintenance overhead and potential routing bottlenecks.

==== Average Path Length

The average path length, formally defined in @def:averagepathlength, measures the mean shortest-path distance between all pairs of distinct nodes in the overlay graph.
In the context of time-varying overlays, this metric is computed at each time step on the current graph snapshot $G(t)$, yielding a time-dependent quantity $a(G(t))$ that reflects the evolution of the network's structural efficiency. A smaller average path length indicates a more efficient topology, as it implies that messages can traverse the network in fewer hops on average. Consequently, overlays with low average path length enable faster information dissemination, improved responsiveness, and better scalability.

Beyond raw routing efficiency, monitoring the average path length is crucial for assessing the robustness and adaptability of overlay management protocols under churn. A sudden increase in $a(G(t))$ often signals topological degradation, such as emerging bottlenecks, inadequate neighbor-replacement strategies, or early stages of network partitioning. Tracking this metric over time thus allows protocol designers to verify convergence toward theoretical routing guarantees and detect structural anomalies.

==== Diameter

The diameter of a graph, formally defined in @def:diameter, captures the maximum shortest-path distance between any pair of nodes in the overlay network.

Similarly to the average path length, the diameter is computed at each time step on the current snapshot $G(t)$, yielding a time-dependent quantity $"diam"(G(t))$ that reflects the worst-case communication distance in the network.

A small diameter is highly desirable, as it guarantees that even in the worst case, any node can reach another within a bounded number of hops. Overlays exhibiting small diameters provide strict upper bounds on message dissemination delay and improve robustness against network fragmentation. In contrast, a large or rapidly increasing diameter may signal structural inefficiencies, degraded connectivity, or early-stage partitioning.

In the context of overlay management, monitoring the diameter is essential for verifying worst-case routing guarantees and assessing the convergence speed of maintenance mechanisms under churn. While the average path length characterises typical communication latency, the diameter exposes tail-latency risks and worst-case bottlenecks that can critically impact time-sensitive applications, consensus protocols, or structured lookups. Together with the average path length, the diameter provides a complete picture of the overlay's latency distribution and structural resilience.

==== Metrics for Byzantine Resilience

Unlike crash failures, where topological and structural metrics (e.g., diameter, average path length, clustering coefficient, degree distribution) directly quantify network degradation, Byzantine failures do not admit a universal set of graph-theoretic indicators. Byzantine nodes can behave arbitrarily---sending malformed messages, lying about their state, or selectively connecting to honest peers---which means that standard overlay metrics may remain nominally stable while the protocol's correctness is silently compromised. Consequently, assessing Byzantine resilience requires metrics that are explicitly tied to the protocol's threat model, safety guarantees, and convergence properties.

In the context of overlay management, three complementary dimensions are typically monitored:

1. *Protocol Liveness and Convergence:* The most fundamental metric is whether the overlay protocol continues to operate and eventually reaches a stable, desired configuration despite the presence of Byzantine nodes. This can be quantified by tracking the time-to-convergence, the success rate of membership operations (joins, leaves, repairs), or the fraction of protocol cycles that complete without deadlocks or livelocks. A resilient system should maintain bounded convergence times and preserve its target topology invariants under adversarial conditions.

2. *Byzantine Infiltration in Partial Views:* Since Byzantine nodes aim to remain embedded in the network to influence routing, data aggregation, or consensus, monitoring their representation in honest nodes' partial views provides a direct measure of containment. Relevant indicators include the average proportion of Byzantine peers in $P(i)$ across honest nodes $i$, the maximum Byzantine degree observed in the overlay, or the eviction rate of suspicious neighbours by honest participants.

3. *Overhead of Resilience Mechanisms:* When Byzantine-tolerant countermeasures are deployed (e.g., redundant messaging, consistency checks, reputation systems, or secure neighbour selection), their impact on system efficiency must be quantified. Key metrics include the relative increase in convergence time compared to the benign baseline, the additional state or bandwidth consumed per node, and the algorithmic complexity introduced in message routing or view maintenance. An effective resilience strategy minimises this overhead while guaranteeing safety, reflecting the classic trade-off between security and performance in distributed systems.

In the remainder of this chapter, we will analyse the main overlay management protocols described in the literature, comparing them on the basis of the metrics defined above.

== Structured Networks

From an overlay management perspective, peer-to-peer networks can be broadly classified into structured and unstructured networks. This classification is determined by the protocol governing the construction and maintenance of the overlay, which constrains how nodes join, connect, and interact within the system.

In structured networks, each node is assigned a logical identifier, often derived from a hash function, and connections are established according to this identifier space. 
As a result, the network forms a well-defined topology that enables deterministic and efficient routing, typically with logarithmic complexity in the number of nodes.

When a node joins the network, it must follow the protocol rules to establish links only with a specific subset of authorized neighbors. 
For instance, in ring-based topologies, each node maintains connections with its immediate predecessor and successor, forming a logical ring. 
This structure guarantees that any node can be reached by traversing the ring in a finite number of hops.

Node departures, whether voluntary or due to failures, require the remaining nodes to reconfigure their connections in order to preserve the global topology. 
This maintenance process is essential to ensure the correctness of routing and data lookup operations, and is a defining characteristic of structured peer-to-peer systems.

Structured peer-to-peer networks are most commonly implemented through Distributed Hash Tables (DHTs), which provide a scalable and fully decentralized mechanism for data storage and retrieval. In a DHT, both nodes and data items are mapped to a shared logical identifier space, typically using consistent hashing#footnote[https://en.wikipedia.org/wiki/Consistent_hashing]. Each data item is assigned to a node responsible for a specific region of this space, enabling an even distribution of storage and lookup responsibilities across the network. A DHT can be viewed as a decentralized database. 
When a node searches for data, or more generally for a key associated with a value, that it does not store locally, it issues a request to the network. 
This request is forwarded from node to node according to the routing protocol until it reaches the node whose identifier is closest to the searched key in the logical identifier space. 
This node is responsible for the key and returns the requested data to the requester.

A defining property of structured peer-to-peer networks is their predictable routing complexity. DHT-based systems typically guarantee that lookup operations are completed in $O(log N)$ hops, where $N$ denotes the number of participating nodes. This logarithmic bound is achieved through carefully designed routing tables that allow each node to forward requests to peers that are progressively closer to the target identifier in the logical space. Such guarantees sharply contrast with unstructured networks, where resource discovery often relies on flooding or random walks, resulting in higher and less predictable communication overhead.

Among the seminal works on Distributed Hash Tables is Chord @stoica2001chord. 
Chord relies on consistent hashing to assign both nodes and keys to a shared identifier space, typically generated using a cryptographic hash function such as SHA-1. 
Nodes are logically organized in a ring topology, where each node is responsible for the keys whose identifiers fall between its predecessor and itself. In its simplest form, a ring-based organization would require up to $N$ hops to locate a key in a network of $N$ nodes. 
To address this limitation, Chord introduces a routing structure called the _finger table_. 
Each node maintains a finger table with $m$ entries, where the $i$-th entry points to the successor of $(n + 2^{i})$ in the identifier space, with $n$ denoting the identifier of the current node. These additional links provide shortcuts across the ring and allow lookup operations to be completed in $O(log N)$ hops with high probability.

Another well-known protocol for building structured peer-to-peer networks is Pastry @rowstron2001pastry. 
In Pastry, each node is assigned a random identifier, called a _nodeId_, from a large identifier space. 
Each node maintains several data structures to support efficient and robust routing, including a _routing table_ organized by shared identifier prefixes, a _leaf set_ containing nodes with numerically closest nodeIds, and a _neighborhood set_ composed of nodes that are close in terms of network proximity. When a node issues a request for a given key, the message is forwarded to nodes whose nodeIds share progressively longer prefixes with the key, until it reaches the node responsible for that key. 
This prefix-based routing strategy enables efficient lookup operations while exploiting network locality. Pastry is resilient to node failures, as it dynamically repairs its routing structures in response to node joins and departures.


Kademlia @maymounkov2002kademlia is a widely used DHT protocol, notably employed by BitTorrent. As in Pastry, each node in Kademlia is assigned a random identifier (nodeId) from a large identifier space. Kademlia defines a distance between identifiers using the XOR metric, which induces a logical tree-like structure over the identifier space. Each node maintains a routing table composed of multiple _k-buckets_, where each bucket stores up to $k$ node contacts whose identifiers fall within a specific range of XOR distances from the local node. When a node performs a lookup for a given key, it computes the XOR distance between the key and known node identifiers, and iteratively queries the nodes that are closest to the target key. This process is repeated until the node responsible for the key is reached. 
Kademlia supports parallel and iterative lookups, which improves robustness and resilience to node failures. 

Not all structured networks are based on DHTs. For example, Tiara @clouser2012tiara is a structured overlay network that maintains a deterministic topology based on skip lists and skip graphs. Unlike DHTs, Tiara does not rely on consistent hashing to map keys to nodes or objects; instead, nodes are totally ordered according to their identifiers and connected following strict structural rules. A skip list is a layered linked structure where each node maintains forward pointers at multiple levels, allowing searches to be performed in logarithmic time by progressively skipping over nodes. A skip graph generalizes this idea to a distributed setting by organizing nodes into multiple overlapping ordered lists, which improves fault tolerance and connectivity. Tiara combines these concepts with self-stabilization mechanisms, ensuring that the overlay converges deterministically to the desired structured topology even in the presence of transient faults or churn.

// While structured networks, and in particular Kademlia, have been widely adopted in peer-to-peer systems for their scalability and efficient lookup guarantees, they exhibit limitations in highly dynamic environments. 
// Under extreme churn, the continuous maintenance of routing tables, neighbor sets, and replicated data can introduce significant overhead and may temporarily compromise routing consistency. 
// These challenges have motivated the exploration of alternative designs based on unstructured peer-to-peer networks.

We now assess structured overlay protocols against the criteria that matter for
our objective: efficient and resilient decentralized learning.

*Do structured overlays achieve small diameter and fast information propagation?*
Yes — this is precisely their design objective. Protocols such as Chord, Kademlia,
and Pastry guarantee logarithmic diameter in the number of nodes, ensuring that
any message reaches any destination in $O(log N)$ hops. Information propagation
is therefore efficient by construction, and theoretical bounds are well established.

*Are they resilient to crash failures?*
Not robustly. Structured overlays maintain correctness only as long as the
fraction of failed nodes remains below a protocol-specific threshold. Beyond this
threshold, the structure itself breaks: routing tables become inconsistent,
lookups fail, and the overlay may partition. Even below the threshold, recovery
requires time to detect the failure and repair the affected connections, during
which the protocol's guarantees do not hold.

*Are they resilient to churn?*
Only under moderate churn rates. High churn — frequent and unpredictable node
arrivals and departures — prevents the overlay from ever reaching a stable
configuration. Maintenance traffic grows rapidly as the protocol attempts to
continuously repair a structure that is constantly being disrupted, and in
extreme cases the overhead of maintenance can dominate the available bandwidth.

*Are they resilient to Byzantine failures?*
This is a fundamental weakness of structured overlays. Because the rules
governing node placement and connection are public and deterministic, Byzantine
nodes can exploit this knowledge to position themselves strategically within the
topology — occupying critical routing positions, corrupting lookup results, or
systematically isolating honest nodes. The very structure that makes these
overlays efficient also makes them predictable and therefore exploitable by
adversaries.

*Is the maintenance overhead acceptable?*
It is significant. Building the initial structure requires a coordinated
bootstrapping phase. Every node join or departure triggers a sequence of
connection updates to preserve the structural invariants, generating overhead
that grows with the rate of topological change. In large and dynamic networks,
this overhead can become a limiting factor.

*Are structured overlays flexible and application-agnostic?*
No — this is perhaps their most fundamental limitation for our purposes.
Structured overlays are typically co-designed with a specific application,
such as distributed hash tables or key-value stores. The overlay structure
reflects the data model of the application, making it difficult to repurpose
for a different use case without redesigning the protocol. Furthermore, to
the best of our knowledge, no structured overlay protocol natively supports
the notion of hub nodes — nodes with elevated connectivity and aggregation
responsibility — which is the core mechanism we seek to introduce.

*Conclusion.* Structured overlays offer strong guarantees on diameter and
routing efficiency, but these come at the cost of fragility under failures
and churn, vulnerability to Byzantine adversaries, significant maintenance
overhead, and tight coupling to specific application semantics. For the
objective of this thesis — a resilient, efficient, and application-agnostic
decentralized learning framework — structured overlays are not the right
foundation. This motivates the study of unstructured overlay protocols,
which trade deterministic routing guarantees for greater robustness,
flexibility, and adaptability to dynamic environments.

== Unstructured Networks & Peer Sampling
Unlike structured systems, unstructured networks do not impose a predefined topology or DHT-based organization; instead, nodes establish and maintain connections in an ad-hoc fashion or rely on peer-sampling services to dynamically discover peers, favoring resilience and adaptability over deterministic lookup guarantees.

Because of the absence of a global structure, unstructured P2P networks rely on a set of fundamental services to ensure connectivity, information dissemination, and resource discovery.
A core component of such systems is the _peer sampling service_, whose role is to provide each node with a continuously refreshed, quasi-random subset of peers. This service is essential to preserve network connectivity, avoid topological bias, and prevent partitioning, especially in the presence of churn.

In addition to peer sampling, unstructured P2P networks typically require several complementary services. _Membership management_ mechanisms are used to handle node arrivals and departures, ensuring that local neighbor sets remain up-to-date. _Neighbor selection and topology management_ strategies may be employed to shape the overlay according to specific objectives, such as latency reduction or load balancing.
Furthermore, _information dissemination services_, often based on gossip or epidemic protocols, enable efficient broadcast, aggregation, and synchronization of state across the network. Finally, _resource discovery_ in unstructured networks generally relies on probabilistic techniques such as flooding, random walks, or gossip-based search, trading deterministic guarantees for scalability and resilience. Together, these services allow unstructured peer-to-peer networks to operate efficiently in highly dynamic and decentralized environments, making them particularly suitable for large-scale systems where strict structural maintenance would be costly or impractical. As part of our work, *we focus on the peer sampling service*, which constitutes a fundamental building block of unstructured peer-to-peer systems. 

A peer sampling service provides each node with addresses of other nodes in the network, thereby enabling communication and maintaining connectivity. Indeed, it is often impractical or impossible for a node to store the addresses of all other nodes in the network in memory, particularly in peer-to-peer networks, which can often contain several hundred thousand nodes. Furthermore, these nodes do not necessarily remain connected all the time, and the number of nodes in the network fluctuates constantly. Each node will therefore only maintain a limited number of addresses of other nodes in the network, known as the partial view or neighbor list of each node. There is therefore a need for a service that allows us to connect to other nodes in the network, particularly given the risk that all our neighbors may be disconnected and that we may thus find ourselves disconnected from the network due to a lack of neighbors with whom to communicate.
Typically, the objective of a peer sampling service is to supply node addresses that are as random and uniformly distributed as possible, so as to avoid structural bias and network partitioning.


// citer Anne Marie Kerrmarec, definition du peer sampling oracle

#definition(title: "Peer Sampling Oracle")[
An ideal peer sampling oracle is a random variable $S$ taking values in $V$, 
distributed according to a probability distribution $pi$ over $V$.

Each call to the oracle returns an independent sample drawn according to $pi$.
]

Conceptually, a peer sampling service exposes a minimal interface composed of two main functions.
An initialization function, _init()_, initializes the service at the node level, while a function _getPeer()_ returns the address of another node in the network.

Peer sampling services can be implemented in a centralized manner, where a central entity maintains knowledge of all participating nodes  and responds to sampling requests. In this case, the central entity acts as a sampling oracle, having global knowledge of the network state and being able to return node identifiers according to a prescribed probability distribution, typically uniform. While such an approach is simple, it suffers from scalability limitations and introduces a single point of failure.

Alternatively, peer sampling can be implemented in a fully decentralized way, where nodes continuously exchange and update peer information using only local interactions.
Decentralized peer sampling services are more scalable and allow the construction of fully decentralized peer-to-peer systems that don't need to rely on a centralized service.

Since the goal of a peer sampling service is to return a uniformly random node, the overlay graph induced by such a service naturally converges toward a random graph (see @sec:random-graph).

#definition(title: "Decentralized Peer Sampling Service")[
A decentralized peer sampling service is a randomized local function

$
S_u : "L"_u mapsto V
$

executed by each node $u in V$, where $"L"_u$ denotes the local state of $u$
(typically including its partial view).

The output of $S_u$ induces a probability distribution $hat(pi)_u$ over $V$
that approximates a target distribution $pi$.

Formally, for all $v in V$,

$
hat(pi)_u(v) approx pi(v).
$
] <def:decentralizedpeersampling>

Among the earliest decentralized protocols addressing membership management and peer sampling in large-scale distributed systems is Lightweight Probabilistic Broadcast (lpbcast), proposed by #cite(<eugster2003lightweight>, form:"prose"). Lpbcast is a gossip-based publish/subscribe protocol designed to disseminate membership information and application events in highly dynamic and unstructured peer-to-peer environments. In this protocol, each node periodically exchanges gossip messages with a subset of peers selected from its local partial view. These messages encapsulate subscriptions, unsubscriptions, and published events, allowing nodes to progressively build and maintain a probabilistic view of the system. To ensure bounded resource consumption, lpbcast relies on fixed-size buffers to store received messages. When these buffers become full, messages are discarded using a probabilistic eviction strategy, favoring the removal of stale or redundant information while preserving dissemination efficiency. Node joins are handled through subscription messages initially sent to a single node and subsequently propagated through gossip; with high probability, these messages eventually reach all active nodes. Unsubscriptions follow a similar dissemination process but include timestamps to prevent outdated leave information from persisting indefinitely in the network. A key aspect of lpbcast is its peer weighting mechanism, which assigns weights to known peers based on the frequency of received notifications. Peers with higher weights are more likely to be removed from local views, a strategy that promotes peer diversity and prevents topological convergence, thereby reducing the risk of network partitioning under churn. The protocol offers probabilistic delivery guarantees rather than deterministic reliability, trading strict consistency for improved scalability, fault tolerance, and adaptability to dynamic membership. The authors provide a theoretical analysis of message dissemination time and partition probability, demonstrating that lpbcast achieves rapid and reliable propagation with limited overhead. Experimental evaluation combines simulations with real-world deployments conducted on two local-area networks composed of 60 and 65 SUN Ultra 10 workstations, respectively, interconnected via Fast Ethernet. Experiments involving up to 125 concurrent processes, each publishing 40 events per gossip round, confirm the protocol’s ability to scale while maintaining acceptable latency and network load.

#cite(<montresor2003toward>, form:"prose") proposes an early conceptual framework for building distributed systems that are self-organizing, self-repairing, and resilient, drawing strong inspiration from complex adaptive systems and biological metaphors such as ant colonies. Rather than focusing on a single protocol, the authors advocate a system-level approach in which global behavior emerges from simple local interactions between autonomous agents. This vision is materialized through the Anthill project, whose objective is to provide a generic framework for the design and deployment of peer-to-peer applications built as swarms of agents. In Anthill, agents interact with and modify a shared environment, enabling adaptive behaviors such as dynamic reconfiguration, fault tolerance, and recovery from failures without centralized control. The framework also serves as an experimental platform for studying the fundamental properties of CAS-based peer-to-peer systems, allowing researchers to evaluate scalability, robustness, and performance under dynamic conditions such as churn. This work laid important conceptual foundations for later gossip- and epidemic-based protocols by emphasizing emergence, decentralization, and adaptability as first-class design principles in large-scale distributed systems.


Astrolabe, introduced by #cite(<van2003astrolabe>, form:"prose"), is a distributed information management system designed to support scalable monitoring, management, and data mining in large-scale distributed environments. Unlike fully decentralized peer-to-peer systems, Astrolabe relies on a hierarchical zoning architecture in which nodes are organized into nested zones forming a tree rooted at a global root zone. Each zone elects one or more designated routers responsible for aggregating and propagating information between hierarchical levels. While Astrolabe employs epidemic gossip protocols for information dissemination within and across zones, the presence of explicitly defined zones and routing roles makes the system fundamentally hierarchical rather than purely peer-to-peer. Within each zone, nodes periodically exchange state information using gossip, while inter-zone communication follows the hierarchy, with updates being propagated toward the least common ancestor zone and aggregated along the way. Each node maintains a peer list of logarithmic size relative to the system, ensuring scalability. Security is enforced through the use of public-key certificates, allowing authenticated communication and administrative control. Although Astrolabe avoids centralized servers, it is not fully decentralized: the hierarchical topology is manually configured, and system administrators are able to maintain a global view of the system state. The protocol was evaluated through simulations and experimentally deployed on the Emulab testbed with up to 126 agents running on 63 hosts, demonstrating the scalability and robustness of hierarchical gossip-based aggregation.

In contrast to hierarchical approaches, #cite(<ganesh2003peer>, form:"author") introduced SCAMP @ganesh2003peer, one of the first fully decentralized peer-to-peer membership protocols designed for large-scale gossip-based systems. SCAMP abandons the assumption that nodes have access to a global membership list or even to the total number of participants, assumptions that are unrealistic in the presence of churn. Instead, each node maintains a partial view of the network, whose size remains logarithmic in the number of nodes, ensuring scalability and robustness. SCAMP relies on epidemic dissemination to propagate membership information and guarantees, with high probability, the strong atomicity property, meaning that a broadcast message eventually reaches all nodes. More precisely, if each node gossips to $log(n) + k$ peers on average, the probability of complete dissemination converges asymptotically to $e^(-e^-k)$. Membership dynamics are handled through explicit join and leave procedures. When a node joins the system, its identifier is disseminated through controlled random walks, and recipient nodes probabilistically decide whether to include it in their partial view, allowing the overlay to self-balance without any global coordination. Each node maintains both a partial view, representing its outgoing neighbor references, and an in-view list, corresponding to incoming references from other nodes. This distinction is exploited during graceful departures: when a node leaves, it informs its neighbors, which replace its identifier using the entries contained in its in-view list, preserving the desired average degree of the overlay. To cope with failures and churn, SCAMP incorporates heartbeat-based failure detection, lease mechanisms that periodically expire neighbor relationships, and re-subscription procedures for isolated nodes. An indirection mechanism with decreasing tokens further prevents overload and contributes to maintaining balanced partial views.

Araneola @melamed2004araneola is a multicast system designed to provide scalable and reliable message dissemination in dynamic network environments. Unlike fully connected overlays, Araneola maintains a sparse undirected network in which each node has either K or K+1 neighbors, forming a K-connected graph that ensures resilience to node failures. Membership information is exchanged infrequently, primarily to integrate new nodes or perform maintenance, which reduces overhead and improves scalability. By carefully structuring the network and limiting the number of connections per node, Araneola achieves reliable multicast delivery while remaining efficient in highly dynamic conditions.

#cite(<stavrou2004lightweight>, form:"prose") introduced PROOFS  (P2P Randomized Overlays to Obviate Flash-crowd Symptoms), a lightweight protocol designed to cope with Internet flash crowds and sudden surges in demand for data in a network. PROOFS relies on the construction and continuous maintenance of a random overlay network through a shuffling mechanism, combined with a random-walk-based object lookup protocol. The authors provide theoretical guarantees showing that the resulting directed overlay exhibits strong resilience properties, including the ability to self-heal to avoid network partitions, ensuring eventual connectivity despite churn and failures. The shuffle operation consists of a periodic exchange of partial neighbor views between pairs of randomly selected peers: Each node stores a local peer list, called a *cache*, of fixed size $c$. Periodically, every $Delta$ time units, a node initiates a *shuffle operation* to refresh its view. The node first selects a random subset of $l$ peers from its cache and randomly chooses one peer $q$ from this subset as the shuffle partner. 
The chosen peer is removed from the subset, and the initiating node adds its own address to the subset. This subset is then sent to $q$. Upon receiving the shuffle request, $q$ replies with a randomly selected subset of its own cache. 
The initiating node removes its own address and any entries already in its cache from the received subset, preventing duplicates. 
Finally, the cache is updated by incorporating the remaining entries, maintaining the cache size $c$. Repeated execution of this exchange continuously reshapes the overlay into a random directed graph, which underlies the robustness and self-healing properties of PROOFS. In @PROOFS-algorithm we give the pseudocode of the protocol and in @PROOFS-example we give an example of a shuffling operation. In this example, the Node 1 sends addresses {itself, 2, 3} to Node 4. Node 4 sends back {5,6,8}. After this operation, Node 1 removes from its cache the addresses of nodes 2,3 and 4, thus removing its connection to these nodes, and replaces them with the addresses received from Node 4 (addresses 5,6 and 8). Node 4 does the same, removing the connections of nodes 5, 6, 8 and replacing them with the addresses 1, 2 and 3. After this operation, the overlay remains connected, but the neighbor relationships have been updated according to the shuffle: the connection between Node 1 and Node 4 is now directed from Node 4 to Node 1.

// an initiating node selects a subset of its current neighbors (including itself) and sends this subset to a randomly chosen peer, which replies with a subset of its own partial view. Both nodes then update their local views by removing the exchanged entries and incorporating the received ones, thereby preserving a bounded view size while continuously randomizing the overlay.

#figure(
pseudocode-list(booktabs: true)[
  - initial peer list: *cache*
  - cache size: *c*
  - shuffle length: *l*
  - node address: *p*
  + *loop*
    + wait($Delta$)
    + subset $arrow.l$ selectRandomSubset(cache, l)
    + cache.remove(subset)
    + q $arrow.l$ selectRandom(subset)
    + subset.remove(q)
    + subset.add(p)
    + send(q, subset)
    + $"subset"_q$ $arrow.l$ receive(q)
    + $"subset"_q$.remove(p)
    + $"subset"_q$.removeAll(cache)
    + cache.add($"subset"_q$)
  ],
  caption: [PROOFS algorithm.],
) <PROOFS-algorithm>


#figure(
  grid(
  columns: (1fr, 1fr),
diagram({
node((0,0.5), "7", stroke: 1pt, name: "7", radius: 0.5em)
edge("<|-")
node((0.6,0.5), "1", stroke: 1pt, name: "1", radius: 0.5em, fill: blue.lighten(60%))
edge(label("4"), "-|>")
edge(label("2"), "-|>")
edge(label("3"), "-|>")
node((1.4,-0.1), "2", stroke: 1pt, name: "2", radius: 0.5em)
node((0.6,1.2), "3", stroke: 1pt, name: "3", radius: 0.5em)
node((1.2,0.5), "4", stroke: 1pt, name: "4", radius: 0.5em, fill: green.lighten(60%))
edge(label("3"), "-|>")
edge(label("8"), "-|>")
edge(label("5"), "-|>")
edge(label("6"), "-|>")
node((2,-0.1), "5", stroke: 1pt, name: "5", radius: 0.5em)
node((2,1.2), "6", stroke: 1pt, name: "6", radius: 0.5em)
node((1.2,1.2), "8", stroke: 1pt, name: "8", radius: 0.5em)
}),
diagram({
node((0,0.5), "7", stroke: 1pt, name: "7", radius: 0.5em)
edge("<|-")
node((0.6,0.5), "1", stroke: 1pt, name: "1", radius: 0.5em, fill: blue.lighten(60%))
edge(label("5"), "-|>")
edge(label("8"), "-|>")
edge(label("6"), "-|>")
node((1.4,-0.1), "2", stroke: 1pt, name: "2", radius: 0.5em)
node((0.6,1.2), "3", stroke: 1pt, name: "3", radius: 0.5em)
node((1.2,0.5), "4", stroke: 1pt, name: "4", radius: 0.5em, fill: green.lighten(60%))
edge(label("1"), "-|>")
edge(label("3"), "-|>")
edge(label("2"), "-|>")
node((2,-0.1), "5", stroke: 1pt, name: "5", radius: 0.5em)
node((2,1.2), "6", stroke: 1pt, name: "6", radius: 0.5em)
node((1.2,1.2), "8", stroke: 1pt, name: "8", radius: 0.5em)
})
)
,
  caption: [Before and after a shuffling operation in the PROOFS protocol.],
) <PROOFS-example>

#cite(<jelasity2004peer>, form:"prose") proposed a generic framework for implementing gossip-based peer sampling services. The protocol relies on only two core functions: init() to initialize the service and getPeer() to retrieve a peer address. The authors analyze peer sampling protocols along three dimensions: (i) peer selection — random, head (most recently added), or tail (oldest node), (ii) view propagation — push, pull, or push-pull, and (iii) view selection — random, head, or tail. These dimensions yield 27 possible combinations, including lpbcast @eugster2003lightweight (rand, rand, push) and Newscast @jelasity2003newscast (rand, head, push-pull). A good peer sampling service should satisfy several properties: a uniform degree distribution to avoid hubs, a short average path length for scalability, and a moderate clustering coefficient to reduce message redundancy. Experimental results show that some combinations have limitations: (head, any, any) tends to create a highly clustered network, (any, tail, any) is poorly resilient under dynamic node joins and leaves, and (any, any, pull) converges to a star topology. In contrast, protocols (any, rand, pushpull) provide the closest approximation to a random topology in terms of average path length and clustering coefficient, while (rand, head, any) produces a degree distribution close to uniform. Overall, the resulting topologies exhibit small-world properties, ensuring both connectivity and resilience in unstructured networks.

In their extended work, #cite(<jelasity2007gossip>, form:"prose") proposed a refined gossip-based peer sampling protocol (based on Newscast) along with a framework for systematic evaluation. During each exchange, the active thread selects a peer from the local peer list, sends a buffer containing half of its freshest entries (and optionally its own address), receives a buffer from the remote peer if pull is enabled, and updates its peer list by combining entries from both buffers while removing duplicates and old items, maintaining a fixed cache size. In @Newscast-algorithm and @Newscast-algorithm-passive we provide the pseudocodes for the Newscast protocol. The protocol introduces two tunable parameters: H, the self-healing parameter controlling the removal of stale links, and S, the swap parameter prioritizing entries received from the remote peer. These parameters define a triangular design space with three archetypes: blind (H=0, S=0), maintaining the same subset; healer (H=c/2), keeping the freshest entries; and swapper (H=0, S=c/2), maximizing swaps. Experimental results show that a push-pull approach outperforms push-only or pull-only strategies, which are prone to partitioning or star-like topologies. Furthermore, robustness against churn is enhanced by dropping old entries in the peer list, although a tradeoff exists between load balancing and churn resilience.

  #grid(
  columns: (1fr, 1fr),
  [#figure(
pseudocode-list(booktabs: true)[
  - initial peer list: *cache*
  - cache size: *c*
  - node address: *p*
  - healing parameter: *H*
  - swapped parameter: *S*
  + *loop*
    + wait($Delta$)
    + n $arrow.l$ selectRandom(cache)
    + *if* push
      + buffer $arrow.l$ (address=p, age=0)
      + cache.permute()
      + buffer.append(cache.head(c/2-1))
      + send(buffer, n)
    + *else*
      + send(null, n)
    + *if* pull
      + $"buffer"_p$ $arrow.l$ receive(n)
      + cache $arrow.l$ cache.select(c, H, S, $"buffer"_p$)
      + cache.increaseAge()
  ],
  caption: [Newscast algorithm (active thread).],
) <Newscast-algorithm>
],
[#figure(
pseudocode-list(booktabs: true)[
  + *loop*
    + $"buffer"_p$ $arrow.l$ receive(n)
    + *if* pull
      + buffer $arrow.l$ (address=p, age=0)
      + cache.permute()
      + buffer.append(cache.head(c/2-1))
      + send(buffer, n)
    + cache $arrow.l$ cache.select(c, H, S, $"buffer"_p$)
    + cache.increaseAge()
  ],
  caption: [Newscast algorithm (passive thread).],
) <Newscast-algorithm-passive>
])

The paper *Correctness of a Gossip-Based Membership Protocol* @allavena2005correctness proposes a peer-sampling protocol in which each node executes the algorithm periodically and independently in an asynchronous manner. At each round, a node i first builds a list L1 by collecting the local views of f peers selected uniformly at random from its current peer list. In parallel, it constructs a second list L2 containing the identities of all nodes that have contacted i during the current round to request its peer list. The node then updates its peer list by randomly selecting k nodes from the union of L1 and L2, where a weighting parameter $omega$ biases the selection toward entries from L2 relative to L1. New nodes join the system by initially contacting a bootstrap server. The authors provide formal correctness proofs showing that the protocol has a very low probability of network partitioning and that, despite churn due to node joins and leaves, the overlay converges with high probability to a random graph topology.

Among the protocols that have contributed to the state of the art, we also have Cyclon @voulgaris2005cyclon. The paper that presents the Cyclon protocol defines a lightweight gossip-based membership protocol designed to maintain random unstructured overlays at low cost. The authors first recall the PROOFS protocol @stavrou2004lightweight, where peers periodically exchange subsets of their neighbor lists. CYCLON improves upon this approach by associating an age value with each neighbor entry and by always initiating the shuffle with the oldest known peer, which accelerates the removal of stale links and improves robustness under churn. Experimental results show that the resulting overlay converges to the properties of a random graph rather than a small-world topology: the average path length remains very small, while the clustering coefficient decreases exponentially as the network size grows. To support efficient node joins while preserving randomness, a new peer contacts an introducer node and sends c shuffle messages that perform random walks in the overlay. Each of the c nodes reached by these messages replies with one of its neighbors and replaces that neighbor with the address of the joining peer. This join procedure allows newcomers to rapidly acquire a random peer list without disrupting the overall randomness of the network.

Another interesting approach is #cite(<massoulie2006peer>, form:"prose"). The main contribution of the work is to show that random walk mechanisms can be used both to estimate global properties of the network and to obtain unbiased peer samples, without requiring global knowledge or structured overlays. The authors first propose the Random Tour method to estimate the size of a peer-to-peer network. In this approach, a counter is forwarded along a random walk and incremented at each visited node by a value proportional to $φ(i)/d(i)$, where $d(i)$ is the node degree and $φ(i)$ is a function of interest (the identity function when estimating network size). When the counter returns to the initiator, it is scaled by the initiator’s degree to obtain an unbiased estimate of the network size. The accuracy of this estimate is shown to depend on the spectral gap of the overlay graph, highlighting the importance of good expansion properties. The paper then introduces Sample and Collide, a second technique based on Continuous Time Random Walks (CTRW), whose key novelty is to provide unbiased peer sampling. In this method, a value T is propagated through the network and decremented at each hop by a random amount derived from an exponential distribution parameterized by the node degree. When T reaches zero, the current node reports its identifier to the initiator. By collecting multiple such samples and stopping when repeated samples occur, the initiator can estimate the network size using maximum likelihood estimation. Experimental results demonstrate that Sample and Collide is robust under churn, reinforcing the paper’s central message that random walk–based methods can be used for decentralized measurement and sampling in dynamic overlay networks.

In #cite(<terelius2018peer>, form:"prose"), the authors address the problem of efficiently disseminating a data stream from a small set of seed nodes to all other participants in a peer-to-peer network subject to churn. The authors propose a distributed protocol that incrementally constructs a so-called gradient topology, starting from an initially random overlay. In this topology, nodes are organized according to a utility function that captures their performance characteristics, such as bandwidth or forwarding capacity, with higher-utility nodes positioned closer to the seed nodes that act as data sources. Each node locally adapts its set of neighbors in order to maximize its own utility, which indirectly improves the global efficiency of data dissemination by favoring high-capacity paths near the sources. The paper provides a formal analysis of the protocol using Markov chain techniques, proving convergence toward the desired gradient graph, characterizing the expected convergence time, and showing that the topology can re-converge efficiently even in the presence of churn.

HyParView @leitao2007hyparview is a membership protocol designed to support reliable gossip-based broadcast in large and dynamic networks. Each node maintains two views: an active view consisting of established TCP connections used for message dissemination, and a passive view that contains additional nodes that can replace failed members of the active view. The passive view is maintained using a cyclic strategy, where each node periodically performs a shuffle operation with a randomly selected node to update and refresh its list. This dual-view structure allows HyParView to provide both reliability and resilience to node failures while keeping the network overhead low. HyParView is used as the membership protocol of some frameworks to build distributed networks, like Partisan @meiklejohn2019partisan.

X-BOT @leitao2009x is an evolution of the HyParView protocol, developed by the same authors, designed to optimize unstructured overlay networks while preserving resilience. Like HyParView, each node maintains an active and a passive view to support reliable gossip-based communication. The main innovation in X-BOT is the introduction of a local “oracle” that evaluates the quality of the node’s connections according to a given criterion, such as network latency or other performance metrics. Each node iteratively adjusts its connections to maximize the oracle’s score, using only local information, until the overlay topology is optimized. This approach allows X-BOT to adapt the network structure to improve efficiency and performance while retaining the fault tolerance and low overhead properties of the original HyParView protocol.

Readers who wish to explore gossip networks in more depth can refer to this survey @montresor2017gossip, which not only explains the mechanics of peer sampling in gossip systems but also addresses broader topics such as information dissemination, epidemic modeling, and aggregation techniques.

We now apply the same evaluative lens to unstructured overlay protocols,
assessing them against the criteria that matter for our objective.

A first group of protocols — including lpbcast @eugster2003lightweight and
Astrolabe @van2003astrolabe — must be set aside immediately: despite operating
in large-scale networks, they rely on hierarchical structures or centralized
oracles to coordinate membership and dissemination. This reintroduces exactly
the kind of control point we seek to eliminate, and they are therefore
incompatible with our decentralization objective.

The remaining protocols — SCAMP @ganesh2003peer, PROOFS @stavrou2004lightweight,
Cyclon @voulgaris2005cyclon, Newscast @jelasity2007gossip, HyParView
@leitao2007hyparview, and their variants — form the core of the gossip-based
and random-walk-based peer sampling literature. We now assess them on the same
criteria as structured overlays.

*Do gossip-based overlays achieve small diameter and fast information propagation?*
The diameter is reasonable — gossip protocols typically produce overlays with
small-world properties, where the average path length grows logarithmically with
the number of nodes. However, information propagation is inherently slow: without
any global aggregation phase, information spreads through successive pairwise
exchanges, and convergence requires many rounds. More fundamentally, the absence
of structure makes global aggregation structurally impossible — no node has
sufficient visibility over the network to orchestrate it, which means that the
slow dissemination is not merely a performance issue but a fundamental limitation
of the paradigm.

*Are they resilient to crash failures and churn?*
Yes — this is the primary strength of gossip-based overlays. Random $k$-out graph
topologies remain connected with high probability even when a large fraction of
nodes fail or leave the system. Protocols such as Cyclon and Newscast are
specifically designed to handle churn gracefully, continuously refreshing partial
views through periodic shuffles. The absence of structural invariants means there
is nothing to break when nodes depart unexpectedly.

*Are they resilient to Byzantine failures?*
No. In a gossip-based overlay, a Byzantine node can freely manipulate the partial
views of its neighbors by injecting false peer addresses, withholding entries, or
systematically biasing the sampling distribution. Because there is no mechanism
to verify the integrity of exchanged peer lists, Byzantine nodes can corrupt the
overlay topology silently and persistently, without any honest node being able to
detect the manipulation.

*Is the maintenance overhead acceptable?*
Yes — this is another advantage of gossip-based protocols. Maintenance consists
of periodic lightweight shuffle operations between pairs of nodes, with no global
coordination required. The overhead per node is bounded and does not grow with
network size, making these protocols highly scalable.

*Are gossip-based overlays flexible and application-agnostic?*
Yes. Unlike structured overlays, gossip-based peer sampling services expose a
minimal interface — typically just getPeer() — and impose no constraints on the
application layer. The same protocol can serve as the substrate for learning,
aggregation, broadcast, or any other distributed algorithm, without modification.

*Do they support hub election?*
No. Gossip-based protocols are explicitly designed to produce uniform degree
distributions, preventing the emergence of highly connected nodes. The absence of
degree heterogeneity is a deliberate design choice motivated by load balancing and
resilience, but it makes native hub election impossible within this framework.
Furthermore, the additional randomness introduced by the absence of structure
adds significant uncertainty to convergence speed, making it difficult to provide
meaningful bounds on dissemination time in practice.

*Conclusion on gossip-based overlays.* These protocols offer strong resilience,
low overhead, and good flexibility, but they fundamentally cannot support global
aggregation or hub election. The very properties that make them robust —
uniformity, randomness, absence of structure — are precisely what prevents them
from achieving the aggregation efficiency we seek.

All the previously discussed protocols primarily aim at constructing random k-out graph topologies, in which each node maintains approximately k outgoing links and the distribution of incoming degrees follows a binomial law centered around k. Such topologies are known for their strong resilience to node crashes and churn: even when a large fraction of nodes fail or leave the system, the overlay graph remains connected with high probability. However, this robustness comes at a cost in terms of performance. In particular, information dissemination may be suboptimal, and some nodes can experience relatively high incoming degrees, leading to increased load.
This naturally leads us to examine a distinct family of unstructured overlays:
*power-law and scale-free networks* (see @sec:power-law). These topologies deliberately introduce
degree heterogeneity, allowing some nodes to accumulate significantly more
connections than others. This heterogeneity is precisely the property that
underlies the notion of hubs --- nodes with elevated connectivity that can
serve as natural aggregation points. We therefore examine this family in more
detail, as it represents the closest existing approximation to the hub-based
overlay structure we aim to construct.

== Peer sampling in Power-law networks

Several peer sampling and overlay management protocols are explicitly designed to construct or maintain power-law topologies. Unlike the protocols discussed in the previous section, which produce random graphs as a natural byproduct of uniform peer sampling, these protocols actively engineer degree heterogeneity. This is typically achieved by biasing neighbor selection or rewiring mechanisms toward high-degree nodes, thereby shaping the overlay toward a target power-law degree distribution. The goal is to exploit the presence of hubs --- nodes that concentrate a disproportionate share of connections --- to improve efficiency, scalability, and information dissemination. Power-law and scale-free overlays represent the closest existing family of
protocols to our objective, and we therefore examined this literature in depth.

Gia @chawathe2003making is an unstructured peer-to-peer overlay designed to address the scalability limitations of early Gnutella-like systems by explicitly accounting for heterogeneity in node capacities. Unlike structured overlays or DHT-based systems, Gia preserves the flexibility and robustness of unstructured networks while introducing mechanisms that significantly improve query efficiency and load management. The system is built around the notion of supernodes, although this role is not statically assigned: instead, nodes with higher capacity naturally emerge as better connected and more central in the overlay. A key observation underlying Gia is that the effective capacity of a peer is multidimensional and depends on several factors, including processing power, disk access latency, and, most importantly, available network bandwidth. Traditional unstructured overlays treat all nodes uniformly, which leads to severe bottlenecks when low-capacity nodes become transit points for large volumes of queries. Gia addresses this issue through a combination of dynamic topology adaptation and explicit flow control. The topology adaptation protocol continuously reshapes the overlay so that most nodes remain within a small number of hops from high-capacity peers. Each node independently evaluates its local connectivity using a satisfaction metric S, defined as a value in the interval [0,1]. This metric captures how well a node’s current neighbors meet its performance expectations in terms of query handling and forwarding capacity. When a node’s satisfaction level is below one, it actively seeks better neighbors, typically favoring peers with higher advertised capacity. This process continues until the node reaches a stable configuration in which its satisfaction is maximized, leading to a topology where high-degree nodes are also those most capable of sustaining heavy query loads. To prevent overload and ensure fair utilization of resources, Gia introduces a token-based flow control mechanism. Nodes periodically distribute flow-control tokens to their neighbors, where each token authorizes the transmission of a single query. A node may only forward a query to a neighbor if it holds a valid token from that neighbor, effectively bounding the rate at which any node can receive queries. Token allocation is aligned with the node’s processing capacity: nodes issue tokens at a rate proportional to the number of queries they can handle. If a node experiences congestion, either due to excessive incoming queries or insufficient tokens from its neighbors, it temporarily queues excess queries and adapts by reducing its token distribution rate, thereby throttling incoming traffic. An important aspect of Gia’s design is the incentive mechanism for truthful capacity advertisement. Rather than distributing tokens uniformly among neighbors, nodes allocate tokens in proportion to their neighbors’ advertised capacities. As a result, nodes that declare higher capacity receive more tokens for issuing their own queries, directly benefiting from honest reporting. This feedback loop encourages high-capacity nodes to expose their true capabilities, reinforcing the formation of a topology where connectivity and load are aligned with available resources.

#cite(<montresor2004robust>, form:"prose") introduces SG-1, a gossip-based protocol designed to construct and maintain superpeer overlay networks in a fully decentralized and adaptive manner. The core idea is to let nodes periodically exchange local state information with randomly selected peers, including their role (client or superpeer) and their current load. Based solely on this local knowledge, nodes can autonomously change roles or reassign clients in order to balance load and reduce the overall number of superpeers. As a result, the system converges toward a configuration in which each client is attached to exactly one superpeer, superpeers are interconnected through an approximately random overlay, and the set of superpeers is close to minimal with respect to the aggregate capacity required to serve all clients. A key design choice of SG-1 is to build the superpeer topology as an additional overlay extracted from an existing connected network, rather than replacing the underlying topology. Any protocol capable of maintaining connectivity can be used for this base layer; in the paper, a gossip-based peer sampling protocol is employed to provide an approximately random connected graph. This layered approach significantly improves robustness, as it allows the system to recover even if a large fraction of superpeers fail simultaneously. In such cases, affected clients can temporarily promote themselves to superpeers, after which the gossip process gradually selects a new, balanced set of superpeers among the remaining nodes. The protocol is shown to be highly efficient, with a total message overhead that scales linearly with network size and without concentrating excessive load on any single node. Moreover, the time needed to reach a near-optimal superpeer configuration is constant with respect to the number of nodes, while convergence to an optimal configuration grows only logarithmically. Experimental results indicate fast convergence in practice and show that the resulting superpeer topology exhibits heterogeneous connectivity patterns resembling power-law networks, combining scalability with robustness under churn and failures.

Phenix @wouhaybi2004phenix is a peer sampling protocol designed to construct and maintain resilient, low-diameter peer-to-peer topologies while preserving scalability under churn and adversarial conditions. The protocol is motivated by the observation that low-diameter networks exhibit an average shortest-path length of $O(log n)$, enabling efficient information dissemination at scale. While unstructured peer-to-peer networks are generally resilient to churn and crashes, they often suffer from limited performance, whereas structured overlays provide better performance at the cost of reduced robustness. Phenix aims to reconcile these trade-offs by introducing heterogeneous connectivity patterns inspired by real-world networks. Unlike approaches based on homogeneous random graph topologies, Phenix explicitly constructs power-law degree distributions, where the probability that a node has degree $K$ follows $p(K) ~ K^(-γ)$. The parameter $γ$ controls the level of heterogeneity and is empirically close to 2.2 for the Internet topology. This results in the natural emergence of a small number of highly connected nodes, or hubs, which significantly reduce the network diameter and improve information dissemination. Importantly, Phenix is among the first peer-to-peer topology construction
protocols to explicitly consider resilience against targeted attacks that aim
to remove highly connected nodes in order to fragment the network. Phenix builds upon the principle of *preferential attachment*, according to which new nodes tend to establish links with nodes that are already highly connected. This mechanism, originally introduced in the seminal work of Barabási and Albert, provides a simple generative explanation for the emergence of power-law degree distributions in large-scale networks. By biasing attachment toward high-degree nodes, preferential attachment naturally amplifies degree heterogeneity and leads to the formation of hubs. In the context of overlay management, preferential attachment can be implemented in a decentralized manner by probabilistically favoring neighbors with higher degree during connection establishment. This local rule is sufficient to drive the global topology toward a power-law structure while preserving scalability.

When a node $i$ joins the network, it first obtains a list of peer addresses either by contacting a host cache server or by using a locally stored cache from a previous session. This list is then divided into two subsets: _random_nodes_ and _friends_nodes_. Node $i$ sends a ping message with a time-to-live (TTL) of $1$ to all nodes in the _friends_nodes_ set. Each of these nodes replies by sending its own neighbor list to node $i$ and forwards the ping message to its neighbors while decrementing the TTL and incrementing a hop counter. All nodes that receive this message, corresponding to friends-of-friends, temporarily store node $i$ in a list called $gamma$ for a duration $tau$, which serves as a protection mechanism against crawling attacks. Node $i$ aggregates all received neighbor lists into a set of _candidate_nodes_ and ranks them according to their frequency of occurrence. Nodes that appear most frequently are selected as _preferred_nodes_, reflecting their higher structural importance in the local topology. Node $i$ then establishes connections with nodes in both the _random_nodes_ and _preferred_nodes_ sets. When a node m receives a connection request from node $i$, it creates a backward connection to node $i$ only if node $i$ appears in its $gamma$ list and if the backward connection counter remains below a threshold that bounds the maximum number of backward connections as a function of the node’s incoming degree. This constraint prevents excessive hub formation while preserving the desired power-law structure. If node $i$ receives a backward connection from a node $m$, it removes $m$ from the _preferred_nodes_ list and adds it to a _highly_preferred_nodes_ list. The final peer view maintained by node $i$ thus consists of _random_nodes_, _preferred_nodes_, _highly_preferred_nodes_, and backward connections, collectively enforcing a heterogeneous topology with low diameter. In @Phenix-algorithm and @Phenix-background-algorithm, we give the pseudocode of the algorithm used when a node enters the network, constructing its cache with *random* and *preferred* nodes, and the pseudocode of the background thread. To protect the network from malicious behavior, Phenix incorporates several defensive mechanisms. Nodes attempting to crawl the network are detected and blacklisted. Backward connection lists are never shared, protecting highly connected nodes from being explicitly identified. Additionally, when a node detects that its number of connections has dropped below a predefined threshold, as may occur after a targeted attack, it enters a maintenance mode in which it temporarily favors the selection of preferred nodes over random nodes to rapidly restore connectivity. The protocol considers multiple adversarial strategies, including attackers that form tightly connected subgraphs to artificially increase their likelihood of becoming preferred nodes, as well as attackers that behave honestly before simultaneously disconnecting to induce network fragmentation. Simulation results show that Phenix significantly outperforms random topologies in terms of resilience: even with 30% malicious nodes, approximately 70% of the network remains connected after an attack. Phenix was implemented and evaluated on a real PlanetLab testbed composed of 81 nodes distributed across 43 sites in eight countries. Experimental results confirm the emergence of a heterogeneous degree distribution, with most nodes maintaining between three and four connections and a small number of nodes acting as hubs with significantly higher degrees, reaching up to 18 connections. When these highly connected nodes were deliberately shut down, the network recovered to a stable state in less than one second, demonstrating strong resilience to targeted failures.

#figure(
  pseudocode-list(booktabs: true)[
    - cache size: *c*
    - initial peer list: *cache*
    - initial backward list: *backward_peers* (empty)
    - number of preferential connections: *s*

    + $"G"_"random"$, $"G"_"friend"$ $arrow.l$ split(cache)
    + cache $arrow.l$ {}
    + cache.append($"G"_"random"$)
    + $"G"_"candidates"$ $arrow.l$ {}

    + *for* peer *in* $"G"_"friend"$
      + neighbor_list $arrow.l$ send(peer, CACHE_REQUEST)
      + $"G"_"candidates"$ $arrow.l$ $"G"_"candidates"$ $union$ neighbor_list

    + sort($"G"_"candidates"$)
    + $"G"_"preferred"$ $arrow.l$ $"G"_"candidates"$[0..(s-1)]

    + *for* peer *in* $"G"_"preferred"$
      + send(peer, CONNECTION_REQUEST)

    + cache.append($"G"_"preferred"$)
  ],
  caption: [Phenix algorithm (initialisation).],
) <Phenix-algorithm>

#figure(
  pseudocode-list(booktabs: true)[
    - cache size: *c*
    - peer list: *cache*
    - gamma list: *Γ*
    - initial backward list: *backward_peers* (empty)
    - number of preferential connections: *s* (fixed at $c/2$)
    - backward connection counter: *$c_m$* (initially 0)
    - backward connections constant: *γ* (fixed at 20)

    + *loop*
      + Γ.removeOldItems()
      + request, peer $arrow.l$ receive()

      + *if* request = CACHE_REQUEST
        + send(cache, peer)
        + *for* node *in* cache
          + send(node, PING_REQUEST)

      + *if* request == PING_REQUEST
        + Γ.add(peer)

      + *if* request == CONNECTION_REQUEST
        + $c_m$ $arrow.l$ $c_m$ + 1
        + *if* $c_m$ >= γ
          + backward_peers.add(peer)
          + $c_m$ $arrow.l$ $c_m$ - γ
  ],
  caption: [Phenix algorithm (background thread).],
) <Phenix-background-algorithm>

LLR @sasabe2006llr is a peer-to-peer network construction scheme designed to achieve low diameter, location awareness, and resilience. Nodes join the network individually, obtaining an initial peer list from a bootstrap server. Each node measures physical proximity to its peers using hop counts on the underlying Internet topology and selects the closest peers to form its neighbor set. A preferential attachment mechanism is then applied among these nearby nodes to strengthen connectivity. The protocol also includes a rewiring procedure, allowing nodes to replace distant connections with closer ones while maintaining the preferential connectivity. LLR is explicitly designed to handle churn and potential Byzantine behaviors, and its evaluation relies on topological data from real-world networks such as Abilene and Sprint. No simulation results are reported, but the design emphasizes physical proximity and robustness in dynamic network conditions.

#cite(<vishnumurthy2006heterogeneous>, form:"prose") addresses the construction of heterogeneous unstructured overlay networks and the efficient selection of random nodes within them. The authors propose practical algorithms that adapt the number of outgoing links a node establishes based on its capacity, allowing high-capacity nodes to maintain more connections and thus achieve heterogeneity in the network. New nodes joining the network require knowledge of at least one existing member, which can be facilitated by a well-known rendezvous node. A key contribution is the SwapLinks mechanism, designed to counteract the self-reinforcing effect where early or high-degree nodes accumulate disproportionately many incoming links. SwapLinks actively redistributes incoming links from high-degree nodes to lower-degree nodes, maintaining balance in the network. Additionally, the approach leverages biased random walks during the graph construction and node selection processes, ensuring that connectivity remains efficient while preserving resilience to churn. Simulations indicate that this methodology produces scalable and robust overlay networks suitable for dynamic environments.

#cite(<brocco2009bounded>, form:"prose") proposes a self-organized overlay construction algorithm that aims at achieving a bounded network diameter without relying on hubs. Inspired by biological systems, the approach uses lightweight agents, referred to as “ants”, which are periodically sent by nodes to explore the network and collect topological information. Based on the feedback brought by these ants, nodes locally adapt their connections in order to reduce the overall diameter while avoiding highly connected central nodes. Although the construction process is distributed in spirit, the algorithm assumes global knowledge of the network topology to guide optimization decisions, and it relies on a master entity to enforce certain disconnection operations. As a result, the system achieves low-diameter overlays with balanced degrees, but at the cost of stronger assumptions that limit its applicability in fully decentralized and purely peer-to-peer environments.

#cite(<guclu2008limited>, form:"prose") investigates how to construct scale-free overlay networks for unstructured peer-to-peer systems while explicitly limiting the emergence of hubs. The network is assumed to grow incrementally, with nodes joining one at a time, and nodes are assumed to know the total network size. The key idea is to preserve the benefits of scale-free topologies while enforcing a hard cut-off on node degree, thereby preventing any node from accumulating an excessive number of connections. This degree cap applies to peer connections and ensures a bounded level of heterogeneity. As a reference, the paper also considers the Configuration Model to generate random networks with a prescribed degree distribution, although this approach requires global knowledge and is therefore not directly applicable in decentralized settings. To overcome this limitation, the authors propose two distributed algorithms that rely only on local information. The first, Hop-and-Attempt Preferential Attachment, builds connections by iteratively selecting neighbors of neighbors: a joining node first connects to a random node, then probabilistically attempts to connect to one of its peers, and repeats this process until its peer list is filled or the degree constraints are met. The second approach, Discover-and-Attempt Preferential Attachment, leverages information from the underlying physical network to discover candidate peers and apply a similar preferential attachment mechanism. Both algorithms approximate scale-free degree distributions under bounded degree constraints.

#cite(<eum2009self>, form:"prose") proposed a self-organizing mechanism for constructing scale-free topologies in peer-to-peer networks, with the explicit goal of reconciling desirable structural properties of power-law graphs with the practical constraints of decentralized systems. Nodes are assumed to join the network incrementally, one after another, reflecting a realistic P2P setting. To enable the initial contact with the network, the authors assume the existence of a bootstrapping server whose sole role is to return identifiers of randomly selected peers already present in the overlay. This assumption is kept minimal and does not require the server to maintain or expose any global view of the topology. The proposed model is governed by two parameters that directly shape the resulting degree distribution. The first parameter, $m$, represents the number of links that a newly joining peer establishes upon arrival. The second parameter, $α$, controls the balance between random attachment and preferential attachment. More precisely, when a new peer seeks to establish a connection, the endpoint is chosen according to a mixed strategy: with probability $α$, the attachment is purely random, while with probability (1 − $α$), the attachment follows a preferential rule favoring already well-connected peers. By tuning $α$, the algorithm allows a fine-grained control over the resulting power-law exponent, enabling the construction of a wide range of scale-free topologies. A key contribution of this work lies in the fully decentralized realization of this mixed attachment process. Rather than requiring global knowledge of node degrees or network size, all decisions are delegated to existing peers. In practice, the joining peer $N$ first contacts the bootstrapping server to obtain the identifiers of $m$ randomly selected peers in the current overlay. For each such peer $D$, the joining node asks $D$ to suggest an attachment target. Peer $D$ then returns either its own identifier with probability $α$, or the identifier of one of its neighbors with probability (1 − $α$). The new peer finally connects to the peer whose identifier is returned. As a result, the preferential attachment effect emerges implicitly through local neighbor selection, without ever exposing degree information or global topology data to the joining node. This design choice has important robustness and security implications. Since the new peer does not observe the structure of the overlay and only follows connection decisions made by existing peers, the algorithm naturally limits the information available to a potentially malicious node. The authors argue that this property improves resilience against targeted attacks, as attackers cannot easily infer or exploit high-degree nodes. Moreover, the simplicity of the local rules makes the construction robust under churn: although node arrivals and departures slightly perturb the topology, the scale-free characteristics are largely preserved over time. Beyond topology construction, the paper evaluates the functional benefits of the resulting overlays. In particular, the authors demonstrate that the constructed scale-free networks improve search efficiency when using common P2P search mechanisms such as flooding and random walks. The presence of highly connected nodes accelerates query dissemination, while the adjustable attachment parameter $α$ mitigates the well-known drawback of classical scale-free networks, namely the excessive load placed on a very small number of hubs.

T-MAN @jelasity2009t is a gossip-based protocol designed for fast and fully decentralized construction of overlay network topologies that approximate a desired target structure. The core idea of the protocol is to view topology management as a distributed ranking problem: each node maintains a preference ordering over other nodes according to some application-defined distance or ranking function, and attempts to connect to those that rank highest with respect to this function. Unlike static overlays, T-MAN continuously refines the topology through gossip exchanges, allowing it to adapt to dynamic environments. In its most naive form, such a ranking problem could be solved by having each node broadcast its identifier to the entire network, collect the full list of nodes, and then locally sort them according to the ranking criterion. While this approach is conceptually simple, it is clearly not scalable. T-MAN replaces this global dissemination with an epidemic exchange of node descriptors, where each node periodically communicates with a small number of peers and incrementally improves its local view of the network. A key contribution of T-MAN is that it generalizes the notion of distance beyond simple metrics such as identifier proximity. The ranking function can encode arbitrary criteria, including physical proximity, node capacity, or application-specific attributes. Each node locally ranks the descriptors it knows and retains those corresponding to the most preferred peers. Through repeated gossip exchanges, high-quality descriptors propagate quickly through the system, leading to rapid convergence toward the target topology. The paper highlights an important design trade-off related to the choice of the ranking method. If the ranking is independent of the base node, meaning that all nodes use the same global ranking criterion, the protocol naturally induces a star-like or hub-centered topology. In this case, many nodes are attracted to the same high-ranking peers, which accelerates convergence because these central nodes are contacted frequently and can rapidly collect and redistribute high-quality descriptors.

VICINITY @voulgaris2013vicinity builds directly upon the principles introduced by T-MAN and can be seen as an explicit improvement of that approach, aimed at increasing robustness and convergence quality in dynamic environments. Like T-MAN, VICINITY addresses overlay topology construction as a distributed ranking problem, where each node seeks to connect to peers that are closest according to an application-defined distance function. The target topology thus emerges from local decisions driven by ranking and gossip-based exchanges. The main limitation identified in T-MAN is its strong determinism: nodes always try to optimize their neighborhood strictly according to the ranking function. While this leads to fast convergence, it can also cause premature convergence to suboptimal local structures, sensitivity to churn, and excessive load on highly ranked nodes. VICINITY mitigates these issues by explicitly introducing controlled randomness into the neighbor selection process, striking a balance between deterministic optimization and random exploration. To achieve this, VICINITY combines T-MAN-style ranking with mechanisms inspired by peer sampling protocols such as Cyclon. Each node maintains a neighborhood that is periodically refreshed using both structured exchanges and random peer samples. The use of Cyclon ensures that the overlay remains well mixed and that nodes continue to discover new peers, preventing the topology from becoming rigid or trapped in poor configurations. In addition, neighbor selection is performed in a round-robin fashion, which avoids repeatedly contacting the same peers and improves fairness in communication. A key insight of the paper is that optimal performance is obtained by carefully balancing determinism and randomness. Experimental results show that allocating roughly half of the neighbor selection to ranking-based choices and half to random choices yields the best trade-off between convergence speed, stability, and robustness. Too much determinism reproduces the weaknesses of T-MAN, while too much randomness slows convergence and degrades the quality of the final topology.

UMM @ripeanu2010search is a self-organizing group communication overlay that combines a random base overlay with dynamically constructed, source-specific multicast dissemination trees. The base overlay is initialized as a random graph and is continuously refined using a local “short–long” heuristic that distinguishes latency-optimized short tunnels from bandwidth-optimized long tunnels, replacing existing connections only when measurable improvements exceed a stability threshold. This lower layer is responsible for bootstrapping, membership management, fault recovery, and connectivity maintenance, and is designed to be independent from higher-level dissemination mechanisms. Multicast trees are then implicitly extracted from the base overlay: new sources initially flood the network, and participating nodes locally suppress redundant or low-quality paths based on observed duplicate traffic. Membership information is maintained through an epidemic gossip mechanism that uniformly spreads random peer identifiers and supports scalable joins without requiring global knowledge, although a bootstrap node is used in practice. The system explicitly targets churn, and experimental results show very high delivery ratios even under aggressive failure rates, indicating that the separation between a resilient random base overlay and adaptive dissemination structures yields both robustness and efficiency.

#cite(<bulut2013constructing>, form:"prose") addresses the problem of constructing *limited* scale-free overlays that closely follow a target power-law degree distribution while remaining practical and cost-efficient for peer-to-peer systems. The main contribution is the introduction of two parameterized growth algorithms, SRA and SDA, which allow the designer to explicitly control the desired scale-free exponent, thereby achieving a high adherence to scale-freeness without creating extreme hubs. Both approaches rely on incremental node addition and focus exclusively on link creation at join time, avoiding costly global rewiring operations. The Semi-Randomized Growth Algorithm (SRA) operates without global knowledge and uses randomized degree targets derived from the desired power-law distribution. A joining node samples target degree values, broadcasts a request, and connects to responding peers whose current degrees match these targets, relaxing the constraints toward nearby degree values when necessary. In contrast, the Semi-Deterministic Growth Algorithm (SDA) assumes knowledge of the total network size and deterministically computes the degree that each node should maintain to preserve the target distribution. Nodes advertising matching degrees respond to new peers, which then establish connections accordingly. While both algorithms can guarantee scale-free properties only for a bounded range of exponents and do not handle churn, they demonstrate that accurate and tunable power-law overlays can be constructed efficiently using join-time decisions alone.

#cite(<marza2015new>, form:"prose") proposes a hybrid overlay topology for peer-to-peer video streaming that explicitly combines insights from complex network theory with awareness of the underlying physical topology. Rather than relying solely on abstract graph properties, the approach introduces a position-based construction mechanism aimed at aligning the logical P2P overlay with physical proximity, thereby reducing communication costs and improving streaming efficiency. The authors argue that, since many real-world networks simultaneously exhibit scale-free and small-world properties, an overlay that integrates both characteristics is better suited to practical deployment than models that enforce only one of these properties. The topology construction starts from a minimal motif, a fully connected triangle, which represents an initial set of servers at a CDN-like level and is deliberately chosen such that the three nodes are physically far apart. New peers are then added incrementally and connect to their three closest neighbors, creating a recursive spatial partitioning of the network. Each new insertion subdivides the existing regions into smaller zones, leading to a hierarchical structure that reflects both physical location and logical connectivity. As the network grows, this iterative process yields an overlay that naturally combines clustering, short path lengths, and heterogeneous degree distribution. Experimental results indicate that this hybrid scale-free and small-world topology provides higher robustness to random failures and malicious attacks, outperforming classical small-world and scale-free overlays in terms of resilience while remaining well adapted to the requirements of video streaming applications.

#cite(<park2018distributed>, form:"prose") introduces a distributed algorithm for constructing scale-free networks through preferential rewiring, without requiring network growth. In this model, all nodes start with an inherent attractiveness reflecting their computational power or availability, and initially maintain only a single link. At each time step, nodes randomly sample a limited set of peers and attempt to establish a bidirectional connection with the most attractive candidate. If the candidate node accepts—by comparing the requesting node’s attractiveness with that of its existing neighbor—both nodes rewire their links, replacing connections to less attractive nodes. This iterative process drives the emergence of a power-law degree distribution with a scaling exponent of 2.5, as confirmed analytically and via Monte Carlo simulations. Notably, the resulting networks exhibit ultra-small diameters, scaling as $O(ln ln N)$ for $2 < gamma < 3$. The algorithm operates without churn, relying solely on local decisions and random sampling, yet efficiently produces highly heterogeneous, scale-free topologies that reflect intrinsic node attributes.

#cite(<diggans2021emergent>, form:"prose") investigate how constraints on node connectivity influence the emergence of hierarchical structures in networks. Building on the classical Barabási–Albert preferential attachment model @barabasi1999emergence, they introduce conductance-based limits on the number of connections a node can maintain. By systematically restricting link capacity, the study demonstrates that bottlenecks in connectivity naturally induce hierarchical organization, where high-degree nodes occupy central positions while lower-degree nodes are relegated to peripheral roles. This work highlights the interplay between local degree constraints and global network topology, showing that hierarchy can emerge as an intrinsic property of scale-free systems when structural limitations are enforced.

As seen, the diversity of approaches in the litterature is striking, but a careful reading reveals that most
protocols in this family fail to meet one or more of our requirements. We begin
by setting aside those that are incompatible with our constraints before
assessing the remaining ones.

Several protocols must be dismissed immediately. Gia @chawathe2003making and
SG-1 @montresor2004robust introduce the notion of superpeers, but in doing so
they break the symmetry of the overlay: not all nodes participate equally in the
protocol, and the distinction between clients and superpeers is either statically
assigned or requires a separate coordination layer. A second group of protocols
— including LLR @sasabe2006llr, and the
bootstrapping-dependent schemes of @eum2009self — rely on an external oracle
or bootstrap server not merely for initial contact but as a structural component
of the construction process, reintroducing a dependency that we seek to
eliminate. A third group — including Phenix @wouhaybi2004phenix — requires a continuous
influx of new nodes to sustain the scale-free structure: the power-law degree
distribution emerges from network growth, and the protocol has no mechanism
to maintain it in a stable or churning network where arrivals and departures
are balanced. Finally, several protocols explicitly work against the emergence
of hubs: @guclu2008limited enforces hard degree caps, @brocco2009bounded
actively avoids highly connected nodes, and @bulut2013constructing introduces
parameterized controls to limit hub formation. These protocols pursue a
different objective than ours and are therefore incompatible with our design.

What remains after these eliminations is a small set of protocols that are
genuinely decentralized, do not require continuous growth, and allow hubs to
emerge — notably T-MAN @jelasity2009t, VICINITY @voulgaris2013vicinity, and
the rewiring-based approach of @park2018distributed. We now assess them on
our standard criteria.

*Do scale-free overlays achieve small diameter and fast information propagation?*
Yes — this is their primary advantage over uniform gossip overlays. The presence
of highly connected hub nodes dramatically reduces the network diameter, enabling
faster information dissemination. Protocols such as @park2018distributed
analytically establish ultra-small diameters scaling as $O(ln ln N)$ for
appropriate power-law exponents. Hub nodes act as natural relay points,
accelerating the spread of information across the network.

*Are they resilient to crash failures and churn?*
Partially. Scale-free networks are well known to be resilient to random failures:
because most nodes have low degree, a randomly selected failing node is unlikely
to be a hub, and the network remains connected. However, they are highly
vulnerable to targeted failures: removing even a small fraction of the
highest-degree nodes can rapidly fragment the network. Under churn, maintaining
the power-law structure is non-trivial — protocols that rely on growth dynamics
lose their structural properties when the network stabilizes, and active
maintenance mechanisms such as those in VICINITY and T-MAN are needed to
preserve degree heterogeneity over time.

*Are they resilient to Byzantine failures?*
No — and the situation is arguably worse than in uniform gossip overlays.
Hub nodes, precisely because they are highly connected and central, represent
high-value targets for Byzantine adversaries. A Byzantine node that successfully
impersonates or corrupts a hub can disproportionately affect information
dissemination and aggregation across the entire network. Furthermore, protocols
based on preferential attachment are inherently susceptible to Sybil-style
attacks, where a malicious node artificially inflates its apparent degree or
attractiveness to become a hub.

*Is the maintenance overhead acceptable?*
It varies significantly across protocols. Growth-based approaches incur low
ongoing overhead but cannot maintain the topology under churn. Active
maintenance protocols such as T-MAN and VICINITY require continuous gossip
exchanges to preserve the target degree distribution, with overhead comparable
to standard gossip protocols. Rewiring-based approaches such as @park2018distributed
are lightweight but operate under the assumption of a stable membership.

*Are scale-free overlays flexible and application-agnostic?*
Partially. T-MAN and VICINITY are notably flexible: the ranking function that
drives topology construction is application-defined, allowing the same protocol
to target different structural objectives. However, this flexibility comes at
the cost of requiring the application to specify a meaningful distance or
ranking criterion, which is not always straightforward.

*Do they natively support hub election for aggregation?*
This is the critical point. While scale-free overlays do produce nodes with
elevated connectivity, this elevated connectivity is a passive structural
property — it is not coupled to any active role in the protocol. High-degree
nodes in a scale-free overlay are not aware of their status, do not volunteer
for aggregation duties, and are not explicitly used as aggregators by the
learning layer. The emergence of hubs in the topological sense does not
translate into a mechanism for structured aggregation. Furthermore, the
identity of hubs changes continuously as the topology evolves, making it
difficult for the learning layer to rely on them in a stable manner.

*Conclusion on scale-free overlays.* This family of protocols comes closest
to our objective among all existing approaches, and the intuition underlying
it — that degree heterogeneity can accelerate information dissemination — is
directly relevant to our work. However, none of the existing protocols
simultaneously achieves full decentralization, stability under churn, Byzantine
resilience, and explicit hub election with an active aggregation role. The
structural emergence of high-degree nodes is a necessary but not sufficient
condition for efficient decentralized learning: what is needed is a protocol
that not only produces hubs but actively elects them, assigns them a defined
aggregation responsibility, and maintains this structure robustly under
failures and adversarial conditions. To the best of our knowledge, no existing
peer sampling protocol achieves this combination. This gap defines the precise contribution of the Elevator protocol. Before
introducing it, however, we examine one remaining family of peer sampling
protocols that addresses a dimension not yet covered in our analysis:
Byzantine resilience. While none of the protocols surveyed so far provide
meaningful guarantees against adversarial participants, a dedicated line of
work has tackled this problem directly. Understanding its contributions and
limitations will complete our picture of the state of the art and further
motivate the design choices made in Elevator and Lift.

== Byzantine-Resilient protocols <sec:byzantine-resilient-protocols>

Byzantine attacks @byzantine refer to arbitrary and potentially malicious
behaviors by nodes in a distributed system. Unlike crash failures or omission
faults, Byzantine nodes may deviate from the protocol in unpredictable ways,
such as sending inconsistent messages to different peers, forging data, or
coordinating with other malicious nodes to subvert the system. These attacks
pose a significant threat to the robustness and correctness of distributed
protocols, especially in decentralized environments where trust assumptions
are minimal. In the context of peer sampling and hub selection protocols,
Byzantine nodes can manipulate their local views to influence the overlay
topology and gain disproportionate visibility. Designing protocols resilient
to such behaviors is therefore essential to maintain reliability, fairness,
and convergence guarantees under adversarial conditions.

As noted in the introduction to this chapter, Byzantine-resilient peer
sampling is a young and narrow research area. Because the number of
protocols is limited and their designs are closely derived from the gossip
protocols already described in detail above, we present them here more
concisely, focusing on their key contributions and differences rather than
their full algorithmic descriptions.

Among Byzantine fault-tolerant protocols, the Brahms protocol
@bortnikov2008brahms relies on a gossip-based peer sampling algorithm
resistant to flooding attacks, in which Byzantine nodes attempt to propagate
their identifiers widely to bias local views. Brahms achieves unbiased ID
sampling from potentially biased histories using min-wise independent
permutations. Similarly, @anceaume2021byzantine proposes a mechanism capable
of producing uniform ID samples while adapting to dynamic environments.
Basalt @basalt builds upon Brahms and introduces a ranking function to
determine cache updates. Secure Peer Sampling @jesi2010secure extends the
Newscast gossip protocol @jelasity2007gossip by incorporating cryptographic
keys, a certificate authority, and a hub-detection mechanism to mitigate
malicious behavior. SecureCyclon @antonov2023securecyclon, derived from
Cyclon @voulgaris2005cyclon, introduces additional security features enabling
nodes to detect and blacklist malicious participants that violate the peer
sampling protocol. Finally, AUPE @mukam2024aupe leverages trusted hardware
components (e.g., Intel SGX) to monitor and control the dissemination of
identifiers within the system.

Byzantine-resilient peer sampling represents a relatively young and narrow
research area. Rather than proposing fundamentally new overlay architectures,
the existing literature is predominantly focused on hardening existing gossip
protocols against adversarial participants. The set of protocols is small, and
most contributions follow a common pattern: take an established gossip-based
peer sampling protocol, identify a specific Byzantine attack vector, and
introduce a targeted countermeasure. We apply the same evaluative lens as
before, focusing only on the criteria where this family differs from standard
gossip-based overlays.

Before doing so, one protocol must be set aside. Phenix @wouhaybi2004phenix,
already discussed in the scale-free section, is the only protocol in this
family that targets a power-law topology while incorporating Byzantine
resilience mechanisms. However, as noted earlier, Phenix relies on continuous
node arrivals to sustain its scale-free structure, and its Byzantine defenses
are designed around this growth assumption. It therefore does not constitute
a viable foundation for a stable, churn-resilient, hub-based overlay.

The remaining protocols — Brahms @bortnikov2008brahms, Basalt @basalt,
Secure Peer Sampling @jesi2010secure, SecureCyclon @antonov2023securecyclon,
and AUPE @mukam2024aupe — all target random graph topologies and share the
same structural baseline as the gossip protocols from which they derive.
Their behaviour with respect to diameter, information propagation speed,
crash and churn resilience, flexibility, and hub election is therefore
identical to that of standard gossip overlays, as assessed in the previous
section. Only three criteria differ meaningfully.

*Are they resilient to Byzantine failures?*
Yes — this is their primary and defining contribution. Brahms
@bortnikov2008brahms resists flooding attacks using min-wise independent
permutations to produce unbiased samples from potentially biased histories.
SecureCyclon @antonov2023securecyclon introduces blacklisting mechanisms to
detect and exclude nodes that violate the protocol. Secure Peer Sampling
@jesi2010secure adds cryptographic verification to Newscast. However, the
Byzantine resilience guarantees remain protocol-specific and are not always
formally proven under realistic threat models. The field is young, and the
coverage of adversarial scenarios remains incomplete.

*Is the maintenance overhead acceptable?*
It is higher than for standard gossip protocols. Cryptographic operations,
certificate management, and identity verification all introduce additional
computation and communication per gossip round. AUPE @mukam2024aupe goes
further by relying on trusted hardware components such as Intel SGX, which
introduces a dependency on specific hardware.

*Is decentralization preserved?*
Not always. The reliance on certificate authorities in Secure Peer Sampling
@jesi2010secure and on trusted hardware in AUPE @mukam2024aupe reintroduces
centralized trust assumptions that partially undermine the decentralization
objective.

*Conclusion on Byzantine-resilient peer sampling.* This literature confirms
that Byzantine resilience in peer sampling is achievable, but at a cost — in
overhead, in complexity, and in some cases in decentralization. More
importantly, all existing protocols inherit the fundamental limitations of
the gossip paradigm: no global aggregation, no hub structure, and slow
information dissemination. The field remains young, with limited coverage
of adversarial scenarios and no protocol that simultaneously achieves
Byzantine resilience, hub election, and aggregation efficiency. 

This
completes our survey of the state of the art. The gap identified across
all three families — gossip, scale-free, and Byzantine-resilient — defines
the design space that Elevator and Lift are built to occupy, and to which
we now turn.

== Conclusion

The survey presented in this chapter reveals four complementary families of overlay management approaches: structured overlays providing deterministic routing, unstructured peer sampling protocols sustaining low-cost random-like graphs, power-law topologies leveraging controlled heterogeneity for efficient dissemination, and Byzantine-resilient mechanisms securing peer sampling against malicious behavior.

#figure(
  table(
    columns: (1.4fr, 0.7fr, 0.9fr, 0.8fr, 0.8fr, 0.8fr, 0.7fr, 0.7fr, 0.7fr, 0.7fr),
    inset: 5pt,
    align: horizon,
    table.header(
      text(size: 8pt)[*Family*],
      text(size: 8pt)[*Diameter*],
      text(size: 8pt)[*Dissemination*],
      text(size: 8pt)[*Crash \ resilience*],
      text(size: 8pt)[*Churn \ resilience*],
      text(size: 8pt)[*Byzantine \ resilience*],
      text(size: 8pt)[*Overhead*],
      text(size: 8pt)[*Decentralized*],
      text(size: 8pt)[*Flexible*],
      text(size: 8pt)[*Hub election*],
    ),
    text(size: 8pt)[Structured],
    text(size: 8pt)[Small], text(size: 8pt)[Fast], text(size: 8pt)[Weak], text(size: 8pt)[Weak], text(size: 8pt)[Weak], text(size: 8pt)[High], text(size: 8pt)[Yes], text(size: 8pt)[No], text(size: 8pt)[No],

    text(size: 8pt)[Hierarchical \ / Oracle],
    text(size: 8pt)[Small], text(size: 8pt)[Fast], text(size: 8pt)[Moderate], text(size: 8pt)[Moderate], text(size: 8pt)[Moderate], text(size: 8pt)[Moderate], text(size: 8pt)[No], text(size: 8pt)[No], text(size: 8pt)[No],

    text(size: 8pt)[Gossip \ / Random walk],
    text(size: 8pt)[Small], text(size: 8pt)[Slow], text(size: 8pt)[Strong], text(size: 8pt)[Strong], text(size: 8pt)[Weak], text(size: 8pt)[Low], text(size: 8pt)[Yes], text(size: 8pt)[Yes], text(size: 8pt)[No],

    text(size: 8pt)[Power-law \ / Scale-free],
    text(size: 8pt)[Small], text(size: 8pt)[Fast], text(size: 8pt)[Moderate], text(size: 8pt)[Weak], text(size: 8pt)[Weak], text(size: 8pt)[Moderate], text(size: 8pt)[Partial], text(size: 8pt)[Partial], text(size: 8pt)[No],

    text(size: 8pt)[Byzantine-resilient \ gossip],
    text(size: 8pt)[Small], text(size: 8pt)[Slow], text(size: 8pt)[Strong], text(size: 8pt)[Strong], text(size: 8pt)[Strong], text(size: 8pt)[High], text(size: 8pt)[Partial], text(size: 8pt)[Yes], text(size: 8pt)[No],
  ),
  caption: [Comparison of overlay protocol families against the criteria
  relevant to decentralized learning. No existing family simultaneously
  achieves small diameter, fast dissemination, strong resilience, low
  overhead, full decentralization, and hub election.],
) <tab:overlay-comparison>

@tab:overlay-comparison summarizes the findings of this survey across the criteria most relevant to decentralized learning. As the table illustrates, each family of protocols offers a distinct trade-off: structured overlays achieve small diameter and fast dissemination but lack resilience and flexibility; gossip-based protocols are robust and fully decentralized but suffer from slow dissemination and high overhead under Byzantine conditions; power-law topologies improve dissemination efficiency but remain fragile under churn and provide no Byzantine guarantees; and Byzantine-resilient gossip protocols offer strong security at the cost of increased overhead and partial decentralization. Crucially, no existing family simultaneously satisfies all the criteria we require --- in particular, none supports hub election while maintaining full decentralization, strong resilience, and low overhead.

Beyond this core gap, the design of next-generation decentralized overlays raises several additional open challenges, including fairness and incentive alignment, physical-topology awareness, secure bootstrapping, and resource efficiency on edge devices. These questions, while important, fall outside the scope of this thesis. Our work focuses specifically on the challenge identified throughout this chapter: the absence of a fully decentralized mechanism for controlled hub election and formation. The contribution presented in @chap:elevator addresses this precise challenge by proposing a distributed protocol that steers the overlay toward a target number of hubs, guarantees bounded recovery times after hub failures, and maintains stability under churn.