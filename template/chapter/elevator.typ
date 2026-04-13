// aggrandir les figures

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/lovelace:0.3.0": *

#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
#show: show-theorion


// = Hub Sampling <chap:elevator>
= Emergent Peer-to-Peer Multi-Hub Topology <chap:elevator>

// In this paper we propose and evaluate an innovative algorithm that enables the creation of Peer-to-Peer network overlays characterized by emergent multi-hubs. This approach generates overlays that balance between the randomness of a graph and the structure of a star network, resulting in networks that not only feature prominent hubs but also exhibit strong resilience to failures. By leveraging principles of preferential attachment and random attachment, our method allows hubs to form spontaneously, offering a decentralized and fault-tolerant solution ideal for applications requiring both low network diameter and high robustness. The protocol is entirely decentralized, operates asynchronously, and depends exclusively on local information. Nodes organically evolve into hubs and remain indistinguishable from other nodes (except in terms of the number of incoming links). The quantity of hubs that emerge can be predetermined by the application as a network parameter.

// Peer-to-peer networks, Peer sampling service, Hub sampling, Resilient networks, System design, Algorithms, Simulations.

== Introduction
The growing usage of decentralized systems such as blockchain @nakamoto2008bitcoin and federated learning @mcmahan2017communication in recent years has sparked considerable interest in peer-to-peer (P2P) communication protocols. While existing P2P protocols have demonstrated significant utility across various applications, emerging demands for enhanced performance, scalability, and robustness necessitate the development of innovative solutions.

Peer-to-peer (P2P) protocols have undergone extensive research and development to facilitate efficient decentralized communication among networked devices. Foundational P2P protocols like Napster @carlsson2001rise, Gnutella @frankel2003gnutella, and BitTorrent @cohen2003incentives paved the way for distributed file sharing and content distribution across the Internet. Typically, P2P overlay networks are categorized as either structured (e.g. CAN @ratnasamy2001scalable, Chord @stoica2001chord, or Kademlia @maymounkov2002kademlia) or unstructured (e.g. Gnutella @frankel2003gnutella). More comprehensive details about peer-to-peer overlays can be found in recent surveys @malatras2015state, @naik2020next. 

Structured overlays come with a maintenance cost @malatras2015state, and are more susceptible to Byzantine attacks (that is, attacks performed by the peers themselves) @naik2020next and churn @malatras2015state (that is, the unexpected departure and arrival process of the peers). 
Unstructured networks exhibit advantages in resilience to node failures and adaptability to shifting network conditions @jelasity2007gossip, rendering them well-suited for dynamic and heterogeneous environments when compared to their structured counterparts. Their shortcomings are that the quality of services built on top of the network is difficult to assess. 

Peers within an unstructured overlay maintain a dynamic set of neighbors, often discovered through mechanisms like peer sampling @jelasity2007gossip, which enables nodes to gather and exchange information about other nodes in the network, and thus dictates the network topology.
Existing peer sampling algorithms in the literature yield two types of topologies (random and power-law) that demonstrate favorable networking characteristics. Random graphs are built from gossip peer sampling algorithms and are known to be resilient to churn @jelasity2007gossip. 
Power-law (or scale-free) networks are built from algorithms that use the concept of preferential attachment and are known to have ultra-small diameter @cohen2003scale, which helps scalability. 
However, when considering the specific use case of federated learning, certain limitations emerge: _(i)_ gossip learning, based on gossip peer sampling, exhibits a slower convergence rate compared to centralized federated learning methodologies @hegedHus2021decentralized, and _(ii)_ while power-law topologies theoretically offer improved convergence efficiency, prior research has predominantly focused on constructing networks adhering strictly to power-law distributions @xie2008scale, @bulut2013constructing, implementing algorithms to restrict the proliferation of hubs @guclu2008limited, @eum2009self (that is, peers that are extremely well connected), or leveraging other metrics to construct node connections, like the distance in terms of Internet hops @sasabe2006llr or an initial attractiveness @park2018distributed. 

Yet, for federated learning, the presence of hubs is advantageous, as these hubs facilitate rapid relay of machine learning models across the network, accelerating convergence rates. Nonetheless, conventional approaches relying on predefined hubs (e.g., super-peer-based topologies) are susceptible to attacks targeting static and well-defined hub nodes @montresor2004robust.

Hence, there exists a pressing need for a protocol that fosters the organic emergence of hubs within networks. The service outlined in this chapter is designed precisely for this purpose, allowing selected nodes to naturally ascend to hub status through a process we term "hub sampling". 

By enabling nodes to organically assume the role of hubs, our protocol aims to strike a balance between leveraging the efficiency of hub-based networks for applications like federated learning, while mitigating vulnerabilities associated with static hub designations.

Our primary goal is to develop a protocol (called Elevator) that autonomously promotes nodes to act as hubs within unstructured peer-to-peer networks. To achieve this goal, we hybridize two fundamental concepts: 
_preferential attachment_, and _random attachment_.
By integrating these two concepts, our protocol promotes a balanced network structure, where hubs emerge organically based on connectivity patterns and yet adapt to dynamic network changes. 
This approach not only fosters robustness against failures and disruptions but also maintains a low network diameter, facilitating efficient communication and information propagation. The parameter _h_, representing the desired number of hubs, allows for flexibility and control over the network's topology, enabling tailored configurations to suit specific application requirements and network environments.
The rationale behind this initiative is rooted in the benefits of having hub nodes, particularly in applications such as federated learning, where efficient information dissemination is crucial. The existence of hubs facilitates faster network-wide communication compared to overlay networks structured in a random graph topology.
Before detailing the proposed protocol, we review the core principles of overlay management, as they constitute the conceptual framework upon which our approach is built.
// The structure of this article is organized as follows: Section~\ref{sec:2} presents the hub sampling service altogether with its properties, its programming interface (API), and its implementation, the \emph{Elevator algorithm}. Section~\ref{sec:3} presents a theoretical analysis of the properties of the algorithm. Section~\ref{sec:4} presents extensive simulations of Elevator, compared against three classical algorithms from the literature~\cite{jelasity2007gossip,stavrou2004lightweight,wouhaybi2004phenix}.

// == Related works
== Overlay Management

Overlay management refers to the mechanisms used to construct, maintain, and adapt the logical topology of an overlay network. In centralized approaches, a single entity (or a small set of entities) is responsible for managing the network structure, which naturally leads to star or multi-star topologies. While such solutions are simple and efficient, they are not desirable in peer-to-peer systems, where decentralization, fault tolerance, and the absence of a single point of failure are key design goals. Consequently, overlay management in peer-to-peer networks must be performed in a fully decentralized manner.

This chapter builds upon the system model introduced in the previous chapter, in which the peer-to-peer system is viewed as a set of autonomous nodes interacting through a logical overlay network. In this model, the overlay abstracts the underlying physical network and defines the effective communication topology on which all higher-level distributed protocols operate. An overlay management algorithm can therefore be understood as a decentralized protocol whose primary objective is to ensure the creation, maintenance, and adaptation of this logical topology. By continuously managing neighbor relationships, such protocols must cope with the dynamic conditions inherent to peer-to-peer systems, including node arrivals, departures, and failures, while preserving desired structural properties of the overlay.

#definition(title: "Overlay Management")[
An overlay management algorithm is a fully decentralized protocol (see @def:p2p-protocol) whose goal is to construct, maintain, and adapt the logical topology of a peer-to-peer system. It governs how nodes establish and update their neighbor sets (also called their partial view, see @def:partial-view) in order to ensure connectivity, robustness to churn and failures, and structural properties required by higher-level distributed protocols.
]

// Peer-to-peer networks can be broadly divided into two categories: structured and unstructured networks. This organization is dictated by a protocol that constrains how nodes join, connect, and interact within the system.
From an overlay management perspective, peer-to-peer networks can be broadly classified into structured and unstructured networks. This classification is determined by the protocol governing the construction and maintenance of the overlay, which constrains how nodes join, connect, and interact within the system.

=== Structured Networks
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

While structured networks, and in particular Kademlia, have been widely adopted in peer-to-peer systems for their scalability and efficient lookup guarantees, they exhibit limitations in highly dynamic environments. 
Under extreme churn, the continuous maintenance of routing tables, neighbor sets, and replicated data can introduce significant overhead and may temporarily compromise routing consistency. 
These challenges have motivated the exploration of alternative designs based on unstructured peer-to-peer networks. 

=== Unstructured Networks & Peer Sampling
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

Alternatively, peer sampling can be implemented in a fully decentralized way, where nodes continuously exchange and update peer information using only local interactions.
Decentralized peer sampling services are more scalable and allow the construction of fully decentralized peer-to-peer systems that don't need to rely on a centralized service.

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

In their extended work, #cite(<jelasity2007gossip>, form:"prose") proposed a refined gossip-based peer sampling protocol (called Newscast) along with a framework for systematic evaluation. During each exchange, the active thread selects a peer from the local peer list, sends a buffer containing half of its freshest entries (and optionally its own address), receives a buffer from the remote peer if pull is enabled, and updates its peer list by combining entries from both buffers while removing duplicates and old items, maintaining a fixed cache size. In @Newscast-algorithm and @Newscast-algorithm-passive we provide the pseudocodes for the Newscast protocol. The protocol introduces two tunable parameters: H, the self-healing parameter controlling the removal of stale links, and S, the swap parameter prioritizing entries received from the remote peer. These parameters define a triangular design space with three archetypes: blind (H=0, S=0), maintaining the same subset; healer (H=c/2), keeping the freshest entries; and swapper (H=0, S=c/2), maximizing swaps. Experimental results show that a push-pull approach outperforms push-only or pull-only strategies, which are prone to partitioning or star-like topologies. Furthermore, robustness against churn is enhanced by dropping old entries in the peer list, although a tradeoff exists between load balancing and churn resilience.

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

All the previously discussed protocols primarily aim at constructing random k-out graph topologies, in which each node maintains approximately k outgoing links and the distribution of incoming degrees follows a binomial law centered around k. Such topologies are known for their strong resilience to node crashes and churn: even when a large fraction of nodes fail or leave the system, the overlay graph remains connected with high probability. However, this robustness comes at a cost in terms of performance. In particular, information dissemination may be suboptimal, and some nodes can experience relatively high incoming degrees, leading to increased load. In contrast, alternative overlay structures introduce heterogeneity in the distribution of incoming degrees. These include power-law networks, where the degree distribution follows an exponential or heavy-tailed law, and scale-free networks, whose structure scales with the number of nodes in a self-similar manner. Although such topologies are generally less resilient to failures and churn, they often provide better performance for information dissemination, as highly connected nodes act as hubs that can rapidly spread information throughout the network.

=== Peer sampling in Power-law networks

Motivated by these properties, several peer sampling and overlay management algorithms are explicitly designed to create or maintain power-law–like topologies. Rather than relying solely on organic network growth, these protocols actively engineer degree heterogeneity in order to exploit the presence of hubs for improved efficiency, scalability, and robustness. This is typically achieved by biasing neighbor selection, attachment, or rewiring mechanisms toward high-degree nodes, thereby shaping the overlay toward a target power-law degree distribution.

Gia @chawathe2003making is an unstructured peer-to-peer overlay designed to address the scalability limitations of early Gnutella-like systems by explicitly accounting for heterogeneity in node capacities. Unlike structured overlays or DHT-based systems, Gia preserves the flexibility and robustness of unstructured networks while introducing mechanisms that significantly improve query efficiency and load management. The system is built around the notion of supernodes, although this role is not statically assigned: instead, nodes with higher capacity naturally emerge as better connected and more central in the overlay. A key observation underlying Gia is that the effective capacity of a peer is multidimensional and depends on several factors, including processing power, disk access latency, and, most importantly, available network bandwidth. Traditional unstructured overlays treat all nodes uniformly, which leads to severe bottlenecks when low-capacity nodes become transit points for large volumes of queries. Gia addresses this issue through a combination of dynamic topology adaptation and explicit flow control. The topology adaptation protocol continuously reshapes the overlay so that most nodes remain within a small number of hops from high-capacity peers. Each node independently evaluates its local connectivity using a satisfaction metric S, defined as a value in the interval [0,1]. This metric captures how well a node’s current neighbors meet its performance expectations in terms of query handling and forwarding capacity. When a node’s satisfaction level is below one, it actively seeks better neighbors, typically favoring peers with higher advertised capacity. This process continues until the node reaches a stable configuration in which its satisfaction is maximized, leading to a topology where high-degree nodes are also those most capable of sustaining heavy query loads. To prevent overload and ensure fair utilization of resources, Gia introduces a token-based flow control mechanism. Nodes periodically distribute flow-control tokens to their neighbors, where each token authorizes the transmission of a single query. A node may only forward a query to a neighbor if it holds a valid token from that neighbor, effectively bounding the rate at which any node can receive queries. Token allocation is aligned with the node’s processing capacity: nodes issue tokens at a rate proportional to the number of queries they can handle. If a node experiences congestion, either due to excessive incoming queries or insufficient tokens from its neighbors, it temporarily queues excess queries and adapts by reducing its token distribution rate, thereby throttling incoming traffic. An important aspect of Gia’s design is the incentive mechanism for truthful capacity advertisement. Rather than distributing tokens uniformly among neighbors, nodes allocate tokens in proportion to their neighbors’ advertised capacities. As a result, nodes that declare higher capacity receive more tokens for issuing their own queries, directly benefiting from honest reporting. This feedback loop encourages high-capacity nodes to expose their true capabilities, reinforcing the formation of a topology where connectivity and load are aligned with available resources.

#cite(<montresor2004robust>, form:"prose") introduces SG-1, a gossip-based protocol designed to construct and maintain superpeer overlay networks in a fully decentralized and adaptive manner. The core idea is to let nodes periodically exchange local state information with randomly selected peers, including their role (client or superpeer) and their current load. Based solely on this local knowledge, nodes can autonomously change roles or reassign clients in order to balance load and reduce the overall number of superpeers. As a result, the system converges toward a configuration in which each client is attached to exactly one superpeer, superpeers are interconnected through an approximately random overlay, and the set of superpeers is close to minimal with respect to the aggregate capacity required to serve all clients. A key design choice of SG-1 is to build the superpeer topology as an additional overlay extracted from an existing connected network, rather than replacing the underlying topology. Any protocol capable of maintaining connectivity can be used for this base layer; in the paper, a gossip-based peer sampling protocol is employed to provide an approximately random connected graph. This layered approach significantly improves robustness, as it allows the system to recover even if a large fraction of superpeers fail simultaneously. In such cases, affected clients can temporarily promote themselves to superpeers, after which the gossip process gradually selects a new, balanced set of superpeers among the remaining nodes. The protocol is shown to be highly efficient, with a total message overhead that scales linearly with network size and without concentrating excessive load on any single node. Moreover, the time needed to reach a near-optimal superpeer configuration is constant with respect to the number of nodes, while convergence to an optimal configuration grows only logarithmically. Experimental results indicate fast convergence in practice and show that the resulting superpeer topology exhibits heterogeneous connectivity patterns resembling power-law networks, combining scalability with robustness under churn and failures.

// Phenix
Phenix @wouhaybi2004phenix is a peer sampling protocol designed to construct and maintain resilient, low-diameter peer-to-peer topologies while preserving scalability under churn and adversarial conditions. The protocol is motivated by the observation that low-diameter networks exhibit an average shortest-path length of $O(log n)$, enabling efficient information dissemination at scale. While unstructured peer-to-peer networks are generally resilient to churn and crashes, they often suffer from limited performance, whereas structured overlays provide better performance at the cost of reduced robustness. Phenix aims to reconcile these trade-offs by introducing heterogeneous connectivity patterns inspired by real-world networks. Unlike approaches based on homogeneous random graph topologies, Phenix explicitly constructs power-law degree distributions, where the probability that a node has degree $K$ follows $p(K) ~ K^(-γ)$. The parameter $γ$ controls the level of heterogeneity and is empirically close to 2.2 for the Internet topology. This results in the natural emergence of a small number of highly connected nodes, or hubs, which significantly reduce the network diameter and improve information dissemination. Importantly, Phenix is among the first peer-to-peer topology construction protocols to explicitly consider resilience against targeted attacks that aim to remove highly connected nodes in order to fragment the network. Phenix builds upon the principle of *preferential attachment*, according to which new nodes tend to establish links with nodes that are already highly connected. This mechanism, originally introduced in the seminal work of Barabási and Albert, provides a simple generative explanation for the emergence of power-law degree distributions in large-scale networks. By biasing attachment toward high-degree nodes, preferential attachment naturally amplifies degree heterogeneity and leads to the formation of hubs. In the context of overlay management, preferential attachment can be implemented in a decentralized manner by probabilistically favoring neighbors with higher degree during connection establishment. This local rule is sufficient to drive the global topology toward a power-law structure while preserving scalability.

When a node i joins the network, it first obtains a list of peer addresses either by contacting a host cache server or by using a locally stored cache from a previous session. This list is then divided into two subsets: random_nodes and friends_nodes. Node i sends a ping message with a time-to-live (TTL) of 1 to all nodes in the friends_nodes set. Each of these nodes replies by sending its own neighbor list to node i and forwards the ping message to its neighbors while decrementing the TTL and incrementing a hop counter. All nodes that receive this message, corresponding to friends-of-friends, temporarily store node i in a list called gamma for a duration tau, which serves as a protection mechanism against crawling attacks. Node i aggregates all received neighbor lists into a set of candidate_nodes and ranks them according to their frequency of occurrence. Nodes that appear most frequently are selected as preferred_nodes, reflecting their higher structural importance in the local topology. Node i then establishes connections with nodes in both the random_nodes and preferred_nodes sets. When a node m receives a connection request from node i, it creates a backward connection to node i only if node i appears in its gamma list and if the backward connection counter remains below a threshold that bounds the maximum number of backward connections as a function of the node’s incoming degree. This constraint prevents excessive hub formation while preserving the desired power-law structure. If node i receives a backward connection from a node m, it removes m from the preferred_nodes list and adds it to a highly_preferred_nodes list. The final peer view maintained by node i thus consists of random_nodes, preferred_nodes, highly_preferred_nodes, and backward connections, collectively enforcing a heterogeneous topology with low diameter. In @Phenix-algorithm and @Phenix-background-algorithm, we give the pseudocode of the algorithm used when a node enters the network, constructing its cache with *random* and *preferred* nodes, and the pseudocode of the background thread. To protect the network from malicious behavior, Phenix incorporates several defensive mechanisms. Nodes attempting to crawl the network are detected and blacklisted. Backward connection lists are never shared, protecting highly connected nodes from being explicitly identified. Additionally, when a node detects that its number of connections has dropped below a predefined threshold, as may occur after a targeted attack, it enters a maintenance mode in which it temporarily favors the selection of preferred nodes over random nodes to rapidly restore connectivity. The protocol considers multiple adversarial strategies, including attackers that form tightly connected subgraphs to artificially increase their likelihood of becoming preferred nodes, as well as attackers that behave honestly before simultaneously disconnecting to induce network fragmentation. Simulation results show that Phenix significantly outperforms random topologies in terms of resilience: even with 30% malicious nodes, approximately 70% of the network remains connected after an attack. Phenix was implemented and evaluated on a real PlanetLab testbed composed of 81 nodes distributed across 43 sites in eight countries. Experimental results confirm the emergence of a heterogeneous degree distribution, with most nodes maintaining between three and four connections and a small number of nodes acting as hubs with significantly higher degrees, reaching up to 18 connections. When these highly connected nodes were deliberately shut down, the network recovered to a stable state in less than one second, demonstrating strong resilience to targeted failures.

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

#cite(<wakamiya2005toward>, form:"prose") explores the concept of overlay network symbiosis, focusing on the interactions and connections between multiple coexisting overlay networks. Rather than addressing a single overlay in isolation, the authors investigate mechanisms for inter-overlay connectivity, aiming to improve overall efficiency, resource utilization, and resilience across different networks.

LLR @sasabe2006llr is a peer-to-peer network construction scheme designed to achieve low diameter, location awareness, and resilience. Nodes join the network individually, obtaining an initial peer list from a bootstrap server. Each node measures physical proximity to its peers using hop counts on the underlying Internet topology and selects the closest peers to form its neighbor set. A preferential attachment mechanism is then applied among these nearby nodes to strengthen connectivity. The protocol also includes a rewiring procedure, allowing nodes to replace distant connections with closer ones while maintaining the preferential connectivity. LLR is explicitly designed to handle churn and potential Byzantine behaviors, and its evaluation relies on topological data from real-world networks such as Abilene and Sprint. No simulation results are reported, but the design emphasizes physical proximity and robustness in dynamic network conditions.

#cite(<vishnumurthy2006heterogeneous>, form:"prose") addresses the construction of heterogeneous unstructured overlay networks and the efficient selection of random nodes within them. The authors propose practical algorithms that adapt the number of outgoing links a node establishes based on its capacity, allowing high-capacity nodes to maintain more connections and thus achieve heterogeneity in the network. New nodes joining the network require knowledge of at least one existing member, which can be facilitated by a well-known rendezvous node. A key contribution is the SwapLinks mechanism, designed to counteract the self-reinforcing effect where early or high-degree nodes accumulate disproportionately many inlinks. SwapLinks actively redistributes inlinks from high-degree nodes to lower-degree nodes, maintaining balance in the network. Additionally, the approach leverages biased random walks during the graph construction and node selection processes, ensuring that connectivity remains efficient while preserving resilience to churn. Simulations indicate that this methodology produces scalable and robust overlay networks suitable for dynamic environments.

The paper #cite(<xie2008scale>, form:"prose") introduces a simple generative model showing that scale-free networks can emerge without network growth. Starting from an arbitrary initial topology, such as a random graph, the network evolves solely through a rewiring process that preserves the total number of edges. At each time step, an existing edge is removed uniformly at random, and a new edge is created by selecting its two endpoints according to a preferential probability that depends on the current node degrees. This preferential rewiring favors high-degree nodes and leads the system toward a stationary equilibrium characterized by a scale-free degree distribution, independently of the initial topology. The model allows self-loops and multiple edges, which simplifies the analysis and highlights the underlying mechanism driving the emergence of heavy-tailed degree distributions. While conceptually important for understanding the origins of scale-free structures, the approach assumes global knowledge of node degrees to perform preferential selection, which limits its direct applicability in fully decentralized peer-to-peer systems.

#cite(<brocco2009bounded>, form:"prose") proposes a self-organized overlay construction algorithm that aims at achieving a bounded network diameter without relying on hubs. Inspired by biological systems, the approach uses lightweight agents, referred to as “ants”, which are periodically sent by nodes to explore the network and collect topological information. Based on the feedback brought by these ants, nodes locally adapt their connections in order to reduce the overall diameter while avoiding highly connected central nodes. Although the construction process is distributed in spirit, the algorithm assumes global knowledge of the network topology to guide optimization decisions, and it relies on a master entity to enforce certain disconnection operations. As a result, the system achieves low-diameter overlays with balanced degrees, but at the cost of stronger assumptions that limit its applicability in fully decentralized and purely peer-to-peer environments.

#cite(<guclu2008limited>, form:"prose") investigates how to construct scale-free overlay networks for unstructured peer-to-peer systems while explicitly limiting the emergence of hubs. The network is assumed to grow incrementally, with nodes joining one at a time, and nodes are assumed to know the total network size. The key idea is to preserve the benefits of scale-free topologies while enforcing a hard cut-off on node degree, thereby preventing any node from accumulating an excessive number of connections. This degree cap applies to peer connections and ensures a bounded level of heterogeneity. As a reference, the paper also considers the Configuration Model to generate random networks with a prescribed degree distribution, although this approach requires global knowledge and is therefore not directly applicable in decentralized settings. To overcome this limitation, the authors propose two distributed algorithms that rely only on local information. The first, Hop-and-Attempt Preferential Attachment, builds connections by iteratively selecting neighbors of neighbors: a joining node first connects to a random node, then probabilistically attempts to connect to one of its peers, and repeats this process until its peer list is filled or the degree constraints are met. The second approach, Discover-and-Attempt Preferential Attachment, leverages information from the underlying physical network to discover candidate peers and apply a similar preferential attachment mechanism. Both algorithms approximate scale-free degree distributions under bounded degree constraints.

#cite(<eum2009self>, form:"prose") proposed a self-organizing mechanism for constructing scale-free topologies in peer-to-peer networks, with the explicit goal of reconciling desirable structural properties of power-law graphs with the practical constraints of decentralized systems. Nodes are assumed to join the network incrementally, one after another, reflecting a realistic P2P setting. To enable the initial contact with the network, the authors assume the existence of a bootstrapping server whose sole role is to return identifiers of randomly selected peers already present in the overlay. This assumption is kept minimal and does not require the server to maintain or expose any global view of the topology. The proposed model is governed by two parameters that directly shape the resulting degree distribution. The first parameter, m, represents the number of links that a newly joining peer establishes upon arrival. The second parameter, α, controls the balance between random attachment and preferential attachment. More precisely, when a new peer seeks to establish a connection, the endpoint is chosen according to a mixed strategy: with probability α, the attachment is purely random, while with probability (1 − α), the attachment follows a preferential rule favoring already well-connected peers. By tuning α, the algorithm allows a fine-grained control over the resulting power-law exponent, enabling the construction of a wide range of scale-free topologies. A key contribution of this work lies in the fully decentralized realization of this mixed attachment process. Rather than requiring global knowledge of node degrees or network size, all decisions are delegated to existing peers. In practice, the joining peer N first contacts the bootstrapping server to obtain the identifiers of m randomly selected peers in the current overlay. For each such peer $D$, the joining node asks $D$ to suggest an attachment target. Peer $D$ then returns either its own identifier with probability α, or the identifier of one of its neighbors with probability (1 − α). The new peer finally connects to the peer whose identifier is returned. As a result, the preferential attachment effect emerges implicitly through local neighbor selection, without ever exposing degree information or global topology data to the joining node. This design choice has important robustness and security implications. Since the new peer does not observe the structure of the overlay and only follows connection decisions made by existing peers, the algorithm naturally limits the information available to a potentially malicious node. The authors argue that this property improves resilience against targeted attacks, as attackers cannot easily infer or exploit high-degree nodes. Moreover, the simplicity of the local rules makes the construction robust under churn: although node arrivals and departures slightly perturb the topology, the scale-free characteristics are largely preserved over time. Beyond topology construction, the paper evaluates the functional benefits of the resulting overlays. In particular, the authors demonstrate that the constructed scale-free networks improve search efficiency when using common P2P search mechanisms such as flooding and random walks. The presence of highly connected nodes accelerates query dissemination, while the adjustable attachment parameter α mitigates the well-known drawback of classical scale-free networks, namely the excessive load placed on a very small number of hubs.

#cite(<eum2010self>, form:"author") extended their model by introducing an explicit topology transformation mechanism based on link rewiring @eum2010self. While the previous approach focused on the construction of scale-free structures during node arrivals, this follow-up study addresses a complementary problem: how to continuously reshape an existing peer-to-peer topology in a decentralized manner, without relying on node churn or global coordination. The central idea of the paper is to modify the degree distribution through local link relocation processes. Instead of adding or removing peers, the network periodically rewires existing connections according to simple probabilistic rules executed by peers with only neighborhood-level information. Two symmetric rewiring schemes are proposed, each favoring a different direction of degree redistribution. In the first scheme, a peer A is selected at random, one of its neighbors E is identified, and E relinquishes one of its links. This link is then reassigned to a randomly chosen peer G, whose degree is not known a priori. Since E is a neighbor of a randomly selected peer, it is statistically biased toward higher-degree nodes. Consequently, this mechanism effectively removes a link from a high-degree peer and transfers it to a randomly chosen peer, thereby reducing degree heterogeneity. The second rewiring scheme operates in the opposite direction. A randomly chosen peer A first drops one of its existing links, and this link is then reconnected to a high-degree peer B, again identified as a neighbor of a randomly selected peer. In this case, the process reinforces degree heterogeneity by moving a link from a randomly selected node toward a well-connected one. By alternating between these two schemes, the network can be driven toward different degree distributions, ranging from more homogeneous to more skewed structures. To control the balance between these two opposing effects, the authors introduce a probability parameter β. The first scheme, which shifts links away from high-degree peers, is applied with probability β, while the second scheme, which concentrates links on high-degree peers, is applied with probability (1 − β). By tuning β, the system can continuously adjust the shape of the degree distribution, enabling either the attenuation or the reinforcement of scale-free properties. This probabilistic combination provides a flexible and lightweight mechanism for topology adaptation. In addition to β, the rewiring process is constrained by explicit degree bounds. Two parameters, M and n, define the maximum and minimum number of connections a peer is allowed to maintain. During rewiring, a peer may refuse a connection request if its degree has reached M, or reject a disconnection if its degree is already at n. These bounds prevent pathological situations such as the emergence of overly dominant hubs or the isolation of poorly connected peers, and they further enhance stability under dynamic conditions.

In a follow-up work @eum2010self2, Eum, Arakawa, and Murata refine their previous self-organizing and self-transforming overlay models by introducing a probabilistic verification step that governs the acceptance of rewiring operations. Building on the 2010 topology transformation scheme, each candidate rewiring is evaluated according to an energy change that reflects how well the resulting topology matches the targeted power-law structure, and the new configuration is accepted with a probability p. This stochastic acceptance mechanism allows the overlay to progressively converge toward a power-law degree distribution while avoiding overly rigid transformations. The model assumes the existence of a mechanism to select random peers, abstracting away its concrete implementation. Unlike earlier studies that rely on churn, the network is considered static, and resilience is instead assessed by progressively removing nodes and measuring the collapse of the giant component. The resulting power-law topology exhibits a small diameter, improved search efficiency, and robustness against random failures, while remaining vulnerable to targeted attacks, and benefits from clustering properties that help preserve efficiency under node removals.

// T-MAN

T-MAN @jelasity2009t is a gossip-based protocol designed for fast and fully decentralized construction of overlay network topologies that approximate a desired target structure. The core idea of the protocol is to view topology management as a distributed ranking problem: each node maintains a preference ordering over other nodes according to some application-defined distance or ranking function, and attempts to connect to those that rank highest with respect to this function. Unlike static overlays, T-MAN continuously refines the topology through gossip exchanges, allowing it to adapt to dynamic environments. In its most naive form, such a ranking problem could be solved by having each node broadcast its identifier to the entire network, collect the full list of nodes, and then locally sort them according to the ranking criterion. While this approach is conceptually simple, it is clearly not scalable. T-MAN replaces this global dissemination with an epidemic exchange of node descriptors, where each node periodically communicates with a small number of peers and incrementally improves its local view of the network. A key contribution of T-MAN is that it generalizes the notion of distance beyond simple metrics such as identifier proximity. The ranking function can encode arbitrary criteria, including physical proximity, node capacity, or application-specific attributes. Each node locally ranks the descriptors it knows and retains those corresponding to the most preferred peers. Through repeated gossip exchanges, high-quality descriptors propagate quickly through the system, leading to rapid convergence toward the target topology. The paper highlights an important design trade-off related to the choice of the ranking method. If the ranking is independent of the base node, meaning that all nodes use the same global ranking criterion, the protocol naturally induces a star-like or hub-centered topology. In this case, many nodes are attracted to the same high-ranking peers, which accelerates convergence because these central nodes are contacted frequently and can rapidly collect and redistribute high-quality descriptors.

VICINITY @voulgaris2013vicinity builds directly upon the principles introduced by T-MAN and can be seen as an explicit improvement of that approach, aimed at increasing robustness and convergence quality in dynamic environments. Like T-MAN, VICINITY addresses overlay topology construction as a distributed ranking problem, where each node seeks to connect to peers that are closest according to an application-defined distance function. The target topology thus emerges from local decisions driven by ranking and gossip-based exchanges. The main limitation identified in T-MAN is its strong determinism: nodes always try to optimize their neighborhood strictly according to the ranking function. While this leads to fast convergence, it can also cause premature convergence to suboptimal local structures, sensitivity to churn, and excessive load on highly ranked nodes. VICINITY mitigates these issues by explicitly introducing controlled randomness into the neighbor selection process, striking a balance between deterministic optimization and random exploration. To achieve this, VICINITY combines T-MAN-style ranking with mechanisms inspired by peer sampling protocols such as Cyclon. Each node maintains a neighborhood that is periodically refreshed using both structured exchanges and random peer samples. The use of Cyclon ensures that the overlay remains well mixed and that nodes continue to discover new peers, preventing the topology from becoming rigid or trapped in poor configurations. In addition, neighbor selection is performed in a round-robin fashion, which avoids repeatedly contacting the same peers and improves fairness in communication. A key insight of the paper is that optimal performance is obtained by carefully balancing determinism and randomness. Experimental results show that allocating roughly half of the neighbor selection to ranking-based choices and half to random choices yields the best trade-off between convergence speed, stability, and robustness. Too much determinism reproduces the weaknesses of T-MAN, while too much randomness slows convergence and degrades the quality of the final topology.

UMM @ripeanu2010search is a self-organizing group communication overlay that combines a random base overlay with dynamically constructed, source-specific multicast dissemination trees. The base overlay is initialized as a random graph and is continuously refined using a local “short–long” heuristic that distinguishes latency-optimized short tunnels from bandwidth-optimized long tunnels, replacing existing connections only when measurable improvements exceed a stability threshold. This lower layer is responsible for bootstrapping, membership management, fault recovery, and connectivity maintenance, and is designed to be independent from higher-level dissemination mechanisms. Multicast trees are then implicitly extracted from the base overlay: new sources initially flood the network, and participating nodes locally suppress redundant or low-quality paths based on observed duplicate traffic. Membership information is maintained through an epidemic gossip mechanism that uniformly spreads random peer identifiers and supports scalable joins without requiring global knowledge, although a bootstrap node is used in practice. The system explicitly targets churn, and experimental results show very high delivery ratios even under aggressive failure rates, indicating that the separation between a resilient random base overlay and adaptive dissemination structures yields both robustness and efficiency.

#cite(<bulut2013constructing>, form:"prose") addresses the problem of constructing *limited* scale-free overlays that closely follow a target power-law degree distribution while remaining practical and cost-efficient for peer-to-peer systems. The main contribution is the introduction of two parameterized growth algorithms, SRA and SDA, which allow the designer to explicitly control the desired scale-free exponent, thereby achieving a high adherence to scale-freeness without creating extreme hubs. Both approaches rely on incremental node addition and focus exclusively on link creation at join time, avoiding costly global rewiring operations. The Semi-Randomized Growth Algorithm (SRA) operates without global knowledge and uses randomized degree targets derived from the desired power-law distribution. A joining node samples target degree values, broadcasts a request, and connects to responding peers whose current degrees match these targets, relaxing the constraints toward nearby degree values when necessary. In contrast, the Semi-Deterministic Growth Algorithm (SDA) assumes knowledge of the total network size and deterministically computes the degree that each node should maintain to preserve the target distribution. Nodes advertising matching degrees respond to new peers, which then establish connections accordingly. While both algorithms can guarantee scale-free properties only for a bounded range of exponents and do not handle churn, they demonstrate that accurate and tunable power-law overlays can be constructed efficiently using join-time decisions alone.

#cite(<armetta2014self>, form:"prose") proposes a self-organized peer-to-peer system aimed at improving data sharing efficiency by jointly adapting search mechanisms and the underlying overlay topology. Starting from an initially random and connected network, the approach leverages ant-inspired routing strategies to guide search operations, particularly targeting the efficient discovery of rare data items. Artificial ants explore the network and leave implicit feedback that helps bias future searches toward more promising regions of the overlay. Beyond routing alone, the system progressively reshapes the topology itself. By exploiting information gathered during the ant-based search process, the overlay evolves toward a power-law degree distribution, which is known to reduce path lengths and improve reachability. The combination of adaptive routing and emergent scale-free structure leads to significant improvements in search performance compared to purely random overlays. The authors validate their approach through simulations conducted on a custom-built simulator, demonstrating scalability to networks comprising several thousand peers and highlighting the benefits of coupling biologically inspired search with self-organizing topological adaptation.

In the paper by #cite(<colman2014local>, form:"prose"), the authors investigate the evolution of complex networks through a combination of growth, global rewiring, and local rewiring mechanisms. The model is not decentralized, as rewiring operations rely on the ability to select nodes and edges uniformly at random across the entire network. At each time step, the network evolves according to one of three possible processes: local rewiring, global rewiring, or growth. In the local rewiring case, a randomly chosen node detaches one of its outgoing edges and reconnects it to a node located within its extended local neighborhood, namely a descendant of a descendant. In contrast, global rewiring reconnects the detached edge to a randomly selected node in the whole network. Finally, during growth, a new node is added and creates a fixed number of outgoing links to randomly chosen existing nodes. A key aspect of the model is the balance between preferential attachment and preferential detachment. While highly connected nodes are more likely to attract new links, they are also more likely to lose existing ones through rewiring. This dual mechanism prevents the emergence of a pure scale-free structure and instead leads to an exponential degree distribution, with only a small number of nodes exhibiting extremely high degrees as outliers. The study focuses on the structural properties that emerge at equilibrium and does not consider churn, as nodes are not removed once added to the network.

#cite(<marza2015new>, form:"prose") proposes a hybrid overlay topology for peer-to-peer video streaming that explicitly combines insights from complex network theory with awareness of the underlying physical topology. Rather than relying solely on abstract graph properties, the approach introduces a position-based construction mechanism aimed at aligning the logical P2P overlay with physical proximity, thereby reducing communication costs and improving streaming efficiency. The authors argue that, since many real-world networks simultaneously exhibit scale-free and small-world properties, an overlay that integrates both characteristics is better suited to practical deployment than models that enforce only one of these properties. The topology construction starts from a minimal motif, a fully connected triangle, which represents an initial set of servers at a CDN-like level and is deliberately chosen such that the three nodes are physically far apart. New peers are then added incrementally and connect to their three closest neighbors, creating a recursive spatial partitioning of the network. Each new insertion subdivides the existing regions into smaller zones, leading to a hierarchical structure that reflects both physical location and logical connectivity. As the network grows, this iterative process yields an overlay that naturally combines clustering, short path lengths, and heterogeneous degree distribution. Experimental results indicate that this hybrid scale-free and small-world topology provides higher robustness to random failures and malicious attacks, outperforming classical small-world and scale-free overlays in terms of resilience while remaining well adapted to the requirements of video streaming applications.

#cite(<takeuchi2016deterministic>, form:"prose") introduces a deterministic method for constructing artificial scale-free networks while explicitly enforcing a predefined upper bound on node degree. The network grows incrementally, with nodes joining one by one, and builds upon the Semi-Deterministic Algorithm (SDA) previously proposed in #cite(<bulut2013constructing>, form:"prose"). The key idea is to move beyond purely incremental attachment by incorporating an explicit target for the global degree distribution. To this end, the algorithm first computes an ideal degree distribution based on the desired power-law exponent γ, the maximum degree k, and the minimum degree m, and derives from it the corresponding ideal number of edges in the network. As in SDA, each newly added node initially connects to k existing nodes in a deterministic manner; however, this step is systematically complemented by a post-processing phase that adjusts the total number of edges so that the evolving topology better matches the ideal distribution. By explicitly correcting the edge count after node insertion, the approach significantly reduces both the average and the worst-case deviation from the target degree distribution. As a result, the method achieves tighter control over scale-freeness under degree constraints, at the cost of increased determinism and coordination compared to purely local or stochastic construction schemes.

#cite(<lopez2017distributed>, form:"prose") presents a distributed rewiring model aimed at improving the structural efficiency of complex networks through local link adjustments. Each node starts with a set of links divided into fixed and dynamic subsets. During network operation, nodes use their incident edges to route packets and gather local performance statistics. Based on these statistics, nodes identify underperforming outgoing links—those that carried fewer packets—and rewire them toward distant nodes that are more likely to shorten future paths. Initially, nodes are deployed on a 2D grid with a Von Neumann neighborhood, where fixed links ensure minimal connectivity and dynamic links remain untied. Each cycle consists of a packet exchange phase, where tracers with random destinations are forwarded sequentially, and a rewiring phase, in which nodes rank neighbors by utility and attempt to replace their least useful links with better-performing nodes. To support this approach, the authors developed a custom Python-based simulator integrating NetworkX for graph analysis, enabling distributed execution and structural monitoring. A coordinator node, randomly selected, synchronizes phase transitions, ensuring orderly progression across the network. Overall, the model leverages purely local information to iteratively optimize network topology, reducing path lengths while maintaining decentralized control.

#cite(<park2018distributed>, form:"prose") introduces a distributed algorithm for constructing scale-free networks through preferential rewiring, without requiring network growth. In this model, all nodes start with an inherent attractiveness reflecting their computational power or availability, and initially maintain only a single link. At each time step, nodes randomly sample a limited set of peers and attempt to establish a bidirectional connection with the most attractive candidate. If the candidate node accepts—by comparing the requesting node’s attractiveness with that of its existing neighbor—both nodes rewire their links, replacing connections to less attractive nodes. This iterative process drives the emergence of a power-law degree distribution with a scaling exponent of 2.5, as confirmed analytically and via Monte Carlo simulations. Notably, the resulting networks exhibit ultra-small diameters, scaling as $O(ln ln N)$ for $2 < gamma < 3$. The algorithm operates without churn, relying solely on local decisions and random sampling, yet efficiently produces highly heterogeneous, scale-free topologies that reflect intrinsic node attributes.

#cite(<diggans2021emergent>, form:"prose") investigate how constraints on node connectivity influence the emergence of hierarchical structures in networks. Building on the classical Barabási–Albert preferential attachment model @barabasi1999emergence, they introduce conductance-based limits on the number of connections a node can maintain. By systematically restricting link capacity, the study demonstrates that bottlenecks in connectivity naturally induce hierarchical organization, where high-degree nodes occupy central positions while lower-degree nodes are relegated to peripheral roles. This work highlights the interplay between local degree constraints and global network topology, showing that hierarchy can emerge as an intrinsic property of scale-free systems when structural limitations are enforced.

#cite(<fasino2021generating>, form:"prose") present a method for generating large scale-free networks using the Chung–Lu random graph model, which requires specifying the expected degree sequence for all nodes. The model constructs networks where each node achieves its target degree exactly, and under suitable conditions, the resulting networks exhibit a power-law degree distribution with a giant connected component. Unlike many other random graph models, the Chung–Lu approach avoids introducing correlations between the degrees of connected nodes. However, the method is not decentralized, does not handle churn, and its admissibility conditions impose restrictions on both the degree sequence and the network size.

#cite(<meng2023scale>, form:"prose") revisit the concept of scale-free networks by highlighting the distinction between the degree distribution (DD) and the degree–degree distance distribution (DDDD). They show that networks exhibiting a power-law DD form only a subset of those with power-law DDDD, and that some networks may have non-power-law DD but still display power-law DDDD. The authors propose two models: a no-growth preferential attachment model, in which nodes are fixed and links are added internally based on degree-dependent probabilities, and a fitness-based model, where links form deterministically if the sum of node fitnesses exceeds a threshold. These approaches emphasize that network structure can emerge from internal rewiring or node fitness rather than growth, and suggest that DDDD provides a more comprehensive measure of scale-free properties than traditional degree distributions. The models are non-decentralized and do not consider churn.

=== Byzantine-Resilient protocols

Byzantine attacks @byzantine refer to arbitrary and potentially malicious behaviors by nodes in a distributed system. Unlike crash failures or omission faults, Byzantine nodes may deviate from the protocol in unpredictable ways, such as sending inconsistent messages to different peers, forging data, or coordinating with other malicious nodes to subvert the system. These attacks pose a significant threat to the robustness and correctness of distributed protocols, especially in decentralized environments where trust assumptions are minimal. In the context of peer sampling and hub selection protocols, Byzantine nodes can manipulate their local views to influence the overlay topology and gain disproportionate visibility. Designing protocols resilient to such behaviors is therefore essential to maintain reliability, fairness, and convergence guarantees under adversarial conditions.

Among Byzantine fault-tolerant protocols, Phenix @wouhaybi2004phenix enables the creation of power-law networks while remaining resilient to Byzantine nodes attempting targeted attacks, such as becoming hubs or disconnecting nodes from the network. When a node detects that it risks disconnection, it switches to a maintenance mode and creates additional connections with preferred (highly connected) nodes to preserve connectivity. The Brahms protocol @bortnikov2008brahms relies on a gossip-based peer sampling algorithm resistant to flooding attacks, in which Byzantine nodes attempt to propagate their identifiers widely to bias local views. Brahms achieves unbiased ID sampling from potentially biased histories using min-wise independent permutations.

Similarly, @anceaume2021byzantine proposes a mechanism capable of producing uniform ID samples while adapting to dynamic environments. Basalt @basalt builds upon Brahms and introduces a ranking function to determine cache updates. Secure Peer Sampling @jesi2010secure extends the Newscast gossip protocol @jelasity2007gossip by incorporating cryptographic keys, a certificate authority, and a hub-detection mechanism to mitigate malicious behavior. SecureCyclon @antonov2023securecyclon, derived from Cyclon @voulgaris2005cyclon, introduces additional security features enabling nodes to detect and blacklist malicious participants that violate the peer sampling protocol. Finally, AUPE @mukam2024aupe leverages trusted hardware components (e.g., Intel SGX) to monitor and control the dissemination of identifiers within the system.


=== Metrics
In order to evaluate the effectiveness of an overlay management protocol, it is necessary to define quantitative metrics that capture the structural and dynamical properties of the resulting network. In an overlay network, the state of the system at a given instant can be represented as a graph snapshot of the underlying time-varying graph (as seen in @def:tvg). Various metrics can then be computed on this graph in order to characterize the structure of the network, monitor its evolution over time, and compare different protocols. Metrics provide insights into connectivity, resilience, efficiency, and overall behavior of the network. In the context of time-varying graphs, these metrics can be computed either on a single snapshot $G(t)$ or observed as time-dependent quantities $m(t) = m(G(t))$ that evolve as the network topology changes.
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

In most unstructured peer-to-peer overlays, the outdegree is constrained by design and
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

=== Open Questions

The existing literature on peer sampling and overlay management largely focuses on unstructured networks, most commonly relying on random graph topologies or on power-law networks in which the influence of hubs is deliberately limited. In many designs, hubs are viewed as a potential source of imbalance, unfair load distribution, or vulnerability to failures, and are therefore constrained through explicit degree caps or corrective mechanisms.

In contrast, relatively few works explore the opposite direction: namely, the deliberate convergence of the overlay topology toward a controlled number of hubs. In particular, the problem of steering a decentralized system toward a target number of hubs, defined by an explicit parameter and selected in a fully decentralized manner, remains largely underexplored.

Moreover, existing approaches rarely address the resilience of such hub-oriented topologies to churn and failures. The ability of the network to autonomously recover from hub disappearance, by allowing new hubs to emerge and take over their role, is a crucial requirement for long-lived decentralized systems. Designing peer sampling and overlay management protocols that jointly enable controlled hub formation, decentralized parameterization, and resilience to failures therefore constitutes an open and important research direction, which the contribution presented in this chapter aims to address.

// == Description & Properties
// The key desired properties we expect from our protocol are _connectivity_ (the overlay remains connected), _low-diameter_ (for efficient communication), _convergence_ (properties are obtained in an autonomous manner), _stability_ (structural overlay properties are maintained throughout execution), and _robustness_ (resilience to churn and targeted attacks). They will serve as metrics during simulation experiments to ascertain the efficacy of our algorithm.

== Elevator Protocol

Elevator introduces a new abstraction in overlay network management, called the *hub sampling service*. 
This service can be viewed as a generalization of the traditional peer sampling service: 
instead of returning arbitrary random peers, it aims to enable the random emergence and maintenance of a controlled number of hub nodes within the overlay.

#definition(title: "Hub")[
Let $G = (V, E)$ be a directed overlay graph representing the state of the network, where each node $v in V$ maintains a partial view $P(v) subset.eq V$.

In the context of the Elevator protocol, a node $h in V$ is defined as a *hub* if its identifier appears in the partial view of every node in the network, including itself:

$
forall v in V, quad h in P(v)
$
] <def:hub>
Equivalently, a hub is a node to which all other nodes are connected, functioning as a highly accessible focal point in the overlay. In practical terms, this is analogous to the role of a server in a centralized network, providing a shortcut for communication and information dissemination.


The objective of a hub sampling service is to promote the appearance of globally reachable nodes that structurally reduce communication distances while preserving decentralization. 
Unlike centralized mechanisms, this service operates without global knowledge and must adapt dynamically to network changes.

// #definition(title: "Decentralized Hub Sampling Service")[
// Let $V$ be the set of nodes in the network and let $h in NN$ 
// be the desired number of hubs, with $1 <= h <= |V|$.

// A decentralized hub sampling service is a distributed randomized mechanism 
// that induces the emergence of a subset $H subset.eq V$ such that $|H| = h$, and with all nodes in $H$ being hubs.
// ]
#definition(title: "Decentralized Hub Sampling Service")[
Let $V$ be the set of nodes in the network and let $h in NN$ 
be the desired number of hubs, with $1 <= h <= |V|$.

A decentralized hub sampling service is a protocol that, starting from an arbitrary overlay configuration, induces the emergence 
of a subset $H subset.eq V$ such that $|H| = h$ and every node in $H$ satisfies 
the hub property defined in @def:hub.

// This mechanism operates without global coordination and relies solely on local information 
// available at each node.
]

Ideally, the resulting hub set $H$ is drawn according to a uniform distribution 
over all subsets of $V$ of size $h$, that is:

$
Pr(H = S) = 1/binom(|V|,h)
$

for every subset $S subset.eq V$ with $|S| = h$.

In practice, the decentralized protocol approximates this ideal uniform selection 
using only local information and without global coordination.

// Before discussing the specific properties of the Elevator protocol, it is necessary to first define what constitutes a hub within our context, as this concept underpins the network's structural objectives.

Elevator is a decentralized peer-to-peer overlay management protocol designed to implement 
this hub sampling service. It autonomously guides the network toward a desired number of hubs 
while maintaining structural efficiency. Its operation relies on a combination of preferential 
attachment and random attachment mechanisms to balance hub emergence with connectivity.

At a high level, hub emergence is driven by a preferential attachment dynamic. 
At each protocol step, nodes tend to select the most frequently observed 
identifiers within their local neighborhood. As this behavior is executed 
independently by all nodes, highly referenced nodes become increasingly visible, 
which amplifies their selection probability and leads to the natural emergence 
of hubs after a few protocol cycles.

In parallel, hubs are used as sources of randomness: since they are present 
in the partial view of every node, requesting a random identifier from a hub is equivalent to sampling a node uniformly at random in the network. This mechanism allows the protocol to preserve uniformly random outgoing connections alongside the preferential ones. As a result, after a small number of cycles, the overlay stabilizes around the desired topology consisting of $h$ hubs and uniformly random remaining connections.

Having established a formal definition of hubs and of a hub sampling service, 
we now turn to the desired properties of the Elevator protocol, which 
characterize its behavior and performance beyond the aspect of hub emergence.

// === Desired Properties for our protocol
=== Desired Properties

The Elevator protocol is designed to satisfy a set of fundamental structural and dynamical properties that characterize the quality and usefulness of the maintained overlay.

*Connectivity* is an indispensable property. An overlay management protocol that fails to maintain global connectivity is of limited practical value, as network partitions prevent nodes from communicating and undermine any distributed application running on top of the overlay. Therefore, Elevator must ensure that the network remains connected despite churn and topology adaptations.

*Low-diameter* is a central objective of our approach. The introduction of hubs is precisely motivated by the need to reduce communication distances across the network. A small diameter implies that messages can reach any node within a limited number of hops, enabling fast information dissemination, efficient aggregation, and improved responsiveness. By promoting the emergence of well-connected hub nodes, Elevator aims to maintain short paths between arbitrary pairs of nodes.

*Convergence* refers to the protocol’s ability to autonomously drive the network toward the desired topology, characterized by a controlled number of hubs. Starting from an arbitrary initial configuration, the overlay should progressively evolve toward the target structural properties in a timely manner. Rapid convergence is particularly important in dynamic environments where network conditions continuously change.

*Stability* ensures that once the desired structural properties are reached, they are maintained over time. The overlay should not exhibit excessive oscillations or structural instability that could degrade performance or increase maintenance overhead.

Finally, *Robustness* captures the resilience of the protocol to churn and targeted attacks. Since hubs play a central structural role, the protocol must tolerate their potential failure and allow new hubs to emerge when necessary, thereby preserving connectivity and low-diameter properties even under adverse conditions.

Some of these properties will be formally analyzed in the theoretical study preceding the simulation section, where we provide analytical arguments and proofs for key structural guarantees. The remaining aspects will be empirically evaluated through simulation experiments to assess the overall effectiveness and reliability of the Elevator protocol.

// === How to achieve the desired properties ?
=== Approach

To achieve both robustness and a low network diameter, we integrate two fundamental concepts: preferential attachment and random attachment, each serving distinct yet complementary roles in shaping the network topology.

*Preferential Attachment.* Drawing from the concept pioneered by Barabási and Albert @barabasi1999emergence, preferential attachment dictates that new connections in the network are established preferentially with nodes possessing a higher number of existing connections. In our adaptation, we modify this concept to elevate certain nodes to the status of hubs without requiring the network to continuously grow. Instead of new nodes joining and preferentially connecting to highly connected nodes, each existing node leverages information from its neighbors to identify and connect to the most frequently connected nodes (up to a predefined number _h_). This mechanism enables the organic emergence of hubs within the network, with selected nodes naturally assuming central roles based on their connectivity without any explicit distinction other than their number of incoming links.

*Random Attachment.* Inspired by gossip-based peer sampling algorithms @jelasity2007gossip  @stavrou2004lightweight, random attachment ensures that nodes maintain connections with a representative and diverse subset of the network. This strategy promotes network robustness by preventing excessive clustering and dependency on specific nodes (hubs). When existing hubs disappear (e.g., due to failures or departure), other nodes within the network are opportunistically elevated to hub status, ensuring continuity and adaptability of the network topology over time.

Our target is to obtain a topology of the network that has the following properties: _(i)_ There are _h_ defined hubs, with _h_ a parameter defined before the start of the network and common to all nodes, _(ii)_ ignoring hubs, the distribution of the remaining connections is random, and _(iii)_ each node has _c_ connections, consisting of _h_ connections to hubs and _c-h_ connections to random nodes.

// Through simulation evaluation, we demonstrate in the sequel the effectiveness and advantages of our protocol with respect to state-of-the-art algorithms.

// === Desired Properties
// The key desired properties we expect from our protocol are _connectivity_ (the overlay remains connected), _low-diameter_ (for efficient communication), _convergence_ (properties are obtained in an autonomous manner), _stability_ (structural overlay properties are maintained throughout execution), and _robustness_ (resilience to churn and targeted attacks). They will serve as metrics during simulation experiments to ascertain the efficacy of our algorithm.

// The key properties targeted by Elevator are:

// - _Connectivity_: the overlay remains connected at all times.
// - _Low-diameter_: the network maintains short paths for efficient communication.
// - _Convergence_: the desired structural properties are achieved autonomously.
// - _Stability_: the overlay maintains its structural properties throughout execution.
// - _Robustness_: the network is resilient to churn and targeted attacks.

// === Preliminaries

// In the context of our study, we consider an overlay network of interconnected nodes modeled as a directed graph. Communication within this network is bidirectional, corresponding to an underlying undirected graph that represents the physical network. Each node in this network possesses a unique address, akin to an IP address in the context of the Internet, serving as an abstract identifier of its identity. Nodes maintain a local list called _cache_, which contains addresses of other nodes, and represents their partial knowledge of the network's node set. The maximum size of this cache, denoted by parameter _c_, is uniform across all nodes. The cache is pivotal for peer sampling, as it serves as the basis for neighbor selection and information exchange. At the network's inception, nodes are initially connected to a random subset of nodes, forming what is known as a random _k_-out graph. Subsequently, new nodes joining the network also establish connections with a random subset of existing nodes, a process that populates their cache and integrates them into the network. Given the decentralized nature of the network, peer sampling algorithms are designed to operate asynchronously, as it is the case for Elevator, and all algorithms presented in this paper, but to help the evaluation of protocols during simulations, we can refer to the idea of _cycles_ of the protocol. During each cycle, every node initiates one execution of the peer sampling protocol, potentially updating its cache based on interactions with neighboring nodes. By leveraging cycles, we can analyze the convergence, performance, and robustness of peer sampling protocols under varying conditions and scenarios within the decentralized network environment.


// ==== Byzantine model
// We adopt the Byzantine failure model defined in the previous chapter, namely the *Byzantine Synchronous Message-Passing model* (BSMP ⟨n, t⟩ [∅]). Our Byzantine model assumes that a certain percentage of nodes are Byzantine from the start.
// These malicious nodes try to break the Elevator protocol by sending false information
// during cache exchanges, manipulating the hub selection process.

// The goal of Byzantine attackers is to get selected as hub by the correct nodes
// (that genuinely execute the protocol). Obviously, if there is a fraction $p$
// of Byzantine nodes overall, then it is trivial for the Byzantine nodes to obtain
// a fraction $p$ of the hubs (they should just behave as correct nodes).
// So, the Byzantine nodes strive to obtain a higher fraction of the hubs
// than their fraction of the nodes.


// *Attack Mechanism:*  
// When legitimate nodes ask Byzantine nodes for their cache contents or backward
// peers information (i.e., the nodes who contacted them in the past),
// the Byzantine nodes respond with fake data designed to help malicious nodes
// become hubs.

// This attack works because Elevator relies on nodes honestly reporting
// their connectivity information. Apart from that, Byzantine nodes perform
// the protocol like other nodes. Byzantine nodes modify their behavior in order
// to achieve the goal of having a large proportion of hubs be Byzantine,
// but their objective is also to avoid detection.
// If their behavior deviates too much from that of a normal node,
// they could easily be detected and blacklisted.

// We are studying several types of Byzantine nodes:

// + Passive unique Byzantine:  
//   A single Byzantine sending an empty cache.

// + Active unique Byzantine:  
//   A single Byzantine who sends his modified cache with a reference to himself
//   (to increase his probability of being chosen as a hub).

// + Non-coordinating Byzantine nodes:  
//   Multiple Byzantine nodes who send their modified cache with a reference
//   to themselves but do not include references to other Byzantine nodes.

// + Coordinated Byzantine nodes:  
//   Each Byzantine node maintains a coordinated fake cache containing references
//   to all other Byzantine participants in the network.
//   When responding to legitimate cache requests,
//   Byzantine nodes return sublists of this coordinated cache,
//   effectively creating an artificial preference for Byzantine nodes
//   in the sampling process.

// === Elevator core concepts

=== Service API
// == Properties

The API of the hub sampling service mirrors that of classical peer sampling service @jelasity2007gossip, comprising two key methods: _(i)_ _init()_ that initializes the service on a given node, _i.e._, initializes the list of outgoing connections of a node (Indeed, we assume that a given node starts connected to a random subset of nodes in the network, the actual initialization procedure being implementation-dependent), and _(ii)_ _getPeer()_ that returns a random peer address from the node list of peers.

The focus of this work is to present an implementation of the _getPeer()_ method, Elevator, as a gossip-based algorithm, and to study the performance of its implementation. 
In addition to these two methods, we add a third method to the API called _getHub()_ that returns a random hub. The _getHub()_ method can be easily derived from _getPeer()_ by filtering the output of _getPeer()_ to only select the $h$ nodes acting as hubs in the network. This method can be useful for applications that only need to contact a hub.


=== Elevator detailed description
// we now present the detailed design of the Elevator protocol, describing how these mechanisms are concretely implemented in a fully decentralized setting. 

Having outlined the underlying principles and the structural properties we aim to achieve, we now provide a formal and operational description of the Elevator protocol, detailing the parameters, data structures, and iterative procedures that implement the hybrid preferential–random attachment mechanism described above.

The algorithm uses the following parameters and data structures:

    - _Parameter $c$_: The maximum number of outgoing connections (its default value for all nodes is 20). 
    - _Parameter $h$_: The number of preferential attachment connections (its default value for all nodes is _c/2_).
    -  _Parameter_ _maxsize_buffer_backward_: The maximum number of backward connections to send (its default value for all nodes is 100).
    - _Structure cache_: The list of outgoing connections. The list is implemented as an array of size _c_. The list is initialized with random existing addresses (random connections to other nodes of the network).
    - _Structure backward_peers_: The list of other nodes that have tried to connect to the node. The list is implemented as a linked list (initially empty).
    // - _Structure frequency_map_: A temporary structure to hold the frequency of occurrence for all neighbors of neighbors. Implemented as a map ($"node" => "integer"$).
    // - _Structure preferred_: A temporary structure to hold the list of preferred nodes. Implemented as a linked list.
    // - _Structure preferred_backward_: A temporary structure to hold the list of backward connections of the preferred nodes. Implemented as a linked list.

Additionally, we have three temporary structures: _(i)_ _frequency_map_ holds the frequency of occurrences for all neighbors of neighbors, implemented as a map ($"node" => "integer"$), _(ii)_ _preferred_ holds the list of preferred nodes, implemented as a linked list, and _(iii)_ _preferred_backward_ holds the list of backward connections of the preferred nodes, implemented as a linked list. 
// %and \emph{(iv)} \emph{$maxsize\_buffer\_backward$}, the number of backward connections to send (fixed to 100 in simulations).

// ==== The proposed protocol executes the following actions at each run: 
// Each node retrieves the neighbor's list of their neighbors _i.e._, the neighbors at distance two). The node then builds an ordered list of the most frequent peers (the frequency map) and contacts the _c_ most frequent nodes (called _preferred_). Each contacted node sends back to the contacting node a maximum of _maxsize_buffer_backward_ addresses from its backward list, maintained in the structure _backward_peers_, and adds the contacting node to its backward list. The cache of the contacting node is then reset as an empty array. Then the node selects the _h_ most frequent peers and _c-h_ random peers from the list of backward peers of all preferred peers to fill its cache. If the cache is not full, the node adds random peers from the frequency map to the cache until the size of the cache is _c_ 
// (see  @Elevator-algorithm and @Elevator-algorithm-background for detailed pseudocode of the algorithm).

==== The proposed protocol executes the following actions at each run:

1. *Retrieve neighbors at distance two*:  
  Each node collects the neighbor lists of its neighbors (i.e., all nodes at distance two).

2. *Build frequency map and select preferred nodes*:  
  From this data, the node builds an ordered list of the most frequent peers (the frequency map) and contacts the top _h_ nodes, referred to as the *preferred* nodes.

3. *Receive backward lists*:
  The node asks all *preferred* nodes for their backward list. Each preferred node contacted sends back a maximum of _maxsize_buffer_backward_ addresses from its backward list (*backward_peers*) and adds the contacting node to its own backward list. The contacting node creates a *preferred_backward* list containing all the received identifiers.

4. *Reset cache*:  
  The node reset its cache to an empty array.

5. *Fill cache with hubs and random peers*:  
  The node selects the *preferred* nodes and _c - h_ random peers from the *preferred_backward* list to populate its cache.

6. *Complete cache if needed*:
  If the cache is still not full, the node adds random peers from the frequency map until the cache reaches size _c_.

(See @Elevator-algorithm and @Elevator-algorithm-background for detailed pseudocode of the algorithm.)

#figure(
  pseudocode-list(booktabs: true)[
    - initial peer list: *cache*
    - cache size: *c*
    - number of hubs desired: *h*
    - initial backward list: *backward_peers* (empty)

    + *loop*
      + *for* peer in backward_peers
        + *if* peer not responding
          + backward_peers.remove(peer)

      + *for* peer in cache
        + *if* peer not responding
          + cache.remove(peer)

      + frequency_map $arrow.l$ {}
      + *for* peer in cache
        + peer_cache $arrow.l$ send(CACHE_REQUEST, peer)
        + frequency_map $arrow.l$ frequency_map $union$ peer_cache

      + preferred $arrow.l$ frequency_map.sortByFrequency().select(number = h)
      + frequency_map.remove(preferred)

      + preferred_backward $arrow.l$ {}
      + *for* peer in preferred
        + peer_backward_peers $arrow.l$ send(BACKWARD_REQUEST, peer)
        + preferred_backward $arrow.l$ preferred_backward $union$ peer_backward_peers

      + preferred_backward.shuffle()

      + cache $arrow.l$ {}
      + cache $arrow.l$ preferred + preferred_backward[1..(c - h)]

      + *while* cache.size() < c
        + peer $arrow.l$ frequency_map.selectRandom()
        + cache.append(peer)
  ],
  caption: [Elevator algorithm (active thread).],
) <Elevator-algorithm>

#figure(
  pseudocode-list(booktabs: true)[
    - max number of backward connections to send: *maxsize_buffer_backward*

    + *loop*
      + request, peer $arrow.l$ receive()

      + *if* request == CACHE_REQUEST
        + send(cache, peer)
        + backward_peers.add(peer)

      + *if* request == BACKWARD_REQUEST
        + backward_peers.shuffle()
        + send(backward_peers[1..maxsize_buffer_backward], peer)
  ],
  caption: [Elevator algorithm (background thread).],
) <Elevator-algorithm-background>

=== Byzantine protocols
The Elevator protocol was not designed to be resilient to Byzantine attacks, and the protocol assumes that each node is honest and returns reliable information. Since in Elevator each node modifies its cache based on the cache of its neighbors, having one or more Byzantine nodes among its neighbors significantly changes the local behavior of the protocol (for a given node) and therefore the overall convergence toward the _h_ hubs.

To describe how such malicious behavior can affect the protocol, we adopt the Byzantine failure model defined in the previous chapter, namely the *Byzantine Synchronous Message-Passing model* (BSMP ⟨n, t⟩ [∅]). Our Byzantine model assumes that a certain percentage of nodes are Byzantine from the start.
These malicious nodes try to break the Elevator protocol by sending false information
during cache exchanges, manipulating the hub selection process.

The goal of Byzantine attackers is to get selected as hub by the correct nodes
(that genuinely execute the protocol). Obviously, if there is a fraction $p$
of Byzantine nodes overall, then it is trivial for the Byzantine nodes to obtain
a fraction $p$ of the hubs (they should just behave as correct nodes).
So, the Byzantine nodes strive to obtain a higher fraction of the hubs
than their fraction of the nodes.


*Attack Mechanism:*  
When legitimate nodes ask Byzantine nodes for their cache contents or backward
peers information (i.e., the nodes who contacted them in the past),
the Byzantine nodes respond with fake data designed to help malicious nodes
become hubs.

This attack works because Elevator relies on nodes honestly reporting
their connectivity information. Apart from that, Byzantine nodes perform
the protocol like other nodes. Byzantine nodes modify their behavior in order
to achieve the goal of having a large proportion of hubs be Byzantine,
but their objective is also to avoid detection.
If their behavior deviates too much from that of a normal node,
they could easily be detected and blacklisted.

We are studying several types of Byzantine nodes:

+ Passive unique Byzantine:  
  A single Byzantine sending an empty cache.

+ Active unique Byzantine:  
  A single Byzantine who sends his modified cache with a reference to himself
  (to increase his probability of being chosen as a hub).

+ Non-coordinating Byzantine nodes:  
  Multiple Byzantine nodes who send their modified cache with a reference
  to themselves but do not include references to other Byzantine nodes.

+ Coordinated Byzantine nodes:  
  Each Byzantine node maintains a coordinated fake cache containing references
  to all other Byzantine participants in the network.
  When responding to legitimate cache requests,
  Byzantine nodes return sublists of this coordinated cache,
  effectively creating an artificial preference for Byzantine nodes
  in the sampling process.

In terms of pseudo-code for the Byzantine nodes, this amounts to replacing the background Elevator process (@Elevator-algorithm-background) with the following algorithms: @DoNothingAttack for the passive unique Byzantine, @NonCoordinatingAttack for the active unique Byzantine attack and the multiple non-coordinating Byzantines, and @CoordinatedAttack for the multiple coordinated Byzantines.


#figure(
  pseudocode-list(booktabs: true)[
    - backward list: *backward_peers*

    + *loop*
      + (request, peer) $arrow.l$ receive()

      + *if* request == CACHE_REQUEST
        + backward_peers.add(peer)
        + backward_peers.shuffle()
        + send([], None, peer)
  ],
  caption: [Do-nothing attack.],
) <DoNothingAttack>

#figure(
  pseudocode-list(booktabs: true)[
    - my address: *my_address*
    - backward list: *backward_peers*

    + *loop*
      + (request, peer) $arrow.l$ receive()

      + *if* request == CACHE_REQUEST
        + backward_peers.add(peer)
        + backward_peers.shuffle()
        + modified_cache $arrow.l$ cache.remove(random()).add(my_address)
        + send(modified_cache, my_address, peer)
  ],
  caption: [Non-coordinating attack.],
) <NonCoordinatingAttack>

#figure(
  pseudocode-list(booktabs: true)[
    - addresses of all byzantine nodes: *all_byzantines*
    - backward list: *backward_peers*

    + *loop*
      + (request, peer) $arrow.l$ receive()

      + *if* request == CACHE_REQUEST
        + backward_peers.add(peer)
        + backward_peers.shuffle()
        + all_byzantines.shuffle()
        + modified_cache $arrow.l$ all_byzantines[0:c]
        + random_backward $arrow.l$ all_byzantines.random_value()
        + send(modified_cache, random_backward, peer)
  ],
  caption: [Coordinated attack.],
) <CoordinatedAttack>
  
=== Lift protocol

To address Elevator's vulnerability to Byzantine attacks, we propose a deterministic hub redistribution mechanism (that we name Lift) that activates after the network has converged to its initial hub configuration. Our approach leverages the fact that node identifiers are assigned randomly and cannot be modified by Byzantine nodes. If Byzantine nodes are active, we hope that our new protocol will be more efficient than Elevator in terms of resilience, and if Byzantine nodes are not active, we hope that the protocol will have no impact on protocol performance and convergence towards hubs.

The counter-attack operates in two phases: an initial convergence phase using standard Elevator, followed by a deterministic hub redistribution phase.

*Phase 1 – Initial Convergence:*  
The network runs the standard Elevator protocol for a predetermined number of cycles to allow hub formation. During this phase, Byzantine nodes may successfully infiltrate hub positions through coordinated attacks.

*Phase 2 – Hub Redistribution:*  
After convergence, all correct nodes simultaneously execute the following deterministic process (see @algo:lift for detailed pseudocode):

+ Each correct node retrieves the identifiers of the _h_ current hubs (which may be Byzantine). Since Elevator has converged, the first _h_ elements of each correct node’s cache correspond to the addresses of the _h_ hubs (a hub may contain itself in its cache).

+ Each node builds a seed by concatenating the _h_ hub identifiers. Because these identifiers are already sorted, the resulting seed is identical for every correct node.

+ Each node initializes a pseudo-random number generator (see @def:prng) using this seed. The PRNG used is Java’s default implementation, namely a linear congruential generator @knuth1997taocp3. Since both the seed and the PRNG are identical for all correct nodes, the generated sequence is identical, effectively creating a shared random list of values.

+ Each correct node generates _h_ new random values using the PRNG, corresponding to _h_ node identifiers in the network. If a generated value has already been selected, the PRNG is invoked again until a fresh identifier is obtained.

+ Each correct node replaces the first _h_ identifiers in its cache (corresponding to the potentially Byzantine hubs) with the _h_ identifiers generated by the PRNG. The old hub connections are therefore removed and replaced with new hubs chosen uniformly at random.


#figure(
  pseudocode-list(booktabs: true)[
    - current hub list: *H*
    - network size: *N*
    - target hubs: *h*

    + seed $arrow.l$ getSortedHubIDs(H) 
      // Extract and sort hub node IDs

    + prng $arrow.l$ Random(seed) 
      // Initialize PRNG with seed

    + selectedIDs $arrow.l$ {}
    + newHubs $arrow.l$ {}

    + *while* selectedIDs.size() < h
      + randomID $arrow.l$ prng.nextInt(N) 
        // Random node ID in [0, N-1]

      + *if* randomID *not in* selectedIDs
        + targetNode $arrow.l$ network.get(randomID)

        + *if* targetNode != null and targetNode.isUp()
          + selectedIDs $arrow.l$ selectedIDs $union$ {randomID}
          + newHubs $arrow.l$ newHubs $union$ {targetNode}

    + replaceCache(newHubs, currentNode) 
      // Update cache with new hubs
  ],
  caption: [Lift: Deterministic Hub Redistribution.],
) <algo:lift>

Since all nodes use the same seed derived from the initial hub selection, they deterministically select identical new hub sets. Because node identifiers are randomly assigned and immutable, each node has equal probability $h / N$ of becoming a hub, regardless of Byzantine status. The algorithm replaces the cache contents entirely: the first _h_ positions are filled with the deterministically selected new hubs, while the remaining positions are populated with random non-hub nodes to maintain cache diversity.

The critical hypothesis is that Byzantine nodes cannot manipulate their node identifiers, which are assigned uniformly at random during network initialization and remain immutable thereafter.

We further assume that the pseudo-random number generator (PRNG) used in the protocol is correct and cannot be biased or influenced by Byzantine nodes. In particular, the seed provided to the PRNG is obtained by concatenating the identifiers of the selected hubs. Since each node identifier is independently and uniformly generated at initialization, this concatenation can be modeled as a uniformly random seed.

Therefore, even if Byzantine nodes dominate the initial hub selection process, the subsequent deterministic redistribution treats all nodes equally, as it depends solely on immutable identifiers and on the output of an unbiased PRNG.

== Theoretical Analysis
We initially introduced the intuition behind hub emergence, explaining how a 
combination of preferential attachment and random sampling can naturally lead 
to the formation of hubs. We then provided a detailed description of the 
Elevator protocol together with its pseudo-code, specifying its operational 
mechanisms at the local level. 

However, while this description clarifies how the protocol functions, it does 
not formally establish its properties. In particular, the convergence toward 
the desired number of hubs, the preservation of connectivity, and the resulting 
structural guarantees remain to be demonstrated. The objective of the following 
section is therefore to provide a theoretical analysis of Elevator and to 
formally study its emergent behavior.

// === Model

First we instantiate the formal framework introduced in the @chap:model. We consider a peer-to-peer system composed of a set of nodes $V$, modeled as in @def:node-system, and evolving according to the global system @def:global-system. The overlay is represented as a time-varying graph $G(t) = (V, E(t))$ in the sense of @def:tvg, and each node maintains a partial view as defined previously. For both the theoretical analysis and simulation experiments, we assume that the initial overlay forms a random $k$-out graph, i.e., each node selects $k$ distinct nodes uniformly at random to populate its partial view. Similarly, when a new node joins the network, it initializes its partial view by connecting to $k$ nodes chosen uniformly at random. Although the protocol operates asynchronously, we analyze its evolution using the notion of protocol cycles defined in @def:protocol-cycle, where each node executes one protocol step per cycle.

// We adopt the crash failure model defined in the previous chapter, namely the *Crash-prone Synchronous Message-Passing model* (CSMP ⟨n, t⟩ [∅]), in which up to $t$ nodes may permanently crash, communication is reliable, and failures occur only at the beginning of protocol cycles.

*All nodes execute the same peer-to-peer protocol, namely Elevator.*


In order to analyze and model the Elevator protocol, we adopt several 
simplifying assumptions. Without these assumptions, a formal analysis would 
be extremely difficult, if not impossible.

==== Assumptions:
- We assume a failure-free network with a constant number of nodes. In 
  particular, Byzantine behavior and the Lift protocol are not considered 
  in this analysis.

- The random identifiers returned to hubs through the `BACKWARD_REQUEST` 
  mechanism are assumed to be equivalent to identifiers drawn from a 
  uniform distribution.

- When selecting preferred nodes, if a node encounters two or more 
  candidates with the same occurrence frequency, it deterministically 
  selects the candidate with the smallest identifier.

- All nodes are assumed to execute the protocol synchronously and 
  correctly at every cycle.

- Prior to the first cycle, the network is assumed to be highly connected 
  and its topology is modeled as a uniform $k$-out random graph, where 
  $k = c$ corresponds to the cache size shared by all nodes.

- The parameter $h$ (the target number of hubs) is assumed to be identical 
  for all nodes.

Under these assumptions, our objective is to analyze the stability and the 
convergence of the Elevator protocol, and to characterize its convergence 
speed.
=== Stability
We define the stability of the Elevator algorithm as the property that, once convergence to a set of $h$ hubs has been reached, both the list of hubs and their number $h$ remain (with high probability) constant over time.  

Formally, let $H(t)$ denote the set of hubs identified at time $t$, and let $C_v (t)$ be the ordered list of outgoing connections (the cache) of node $v in V$.  
The algorithm is said to be _stable_ if, after convergence time $T$, the following holds with high probability:

$Pr[forall t >= T, H(t)=H(T) and forall v in V, C_v (t)[1:h] = H(t)] approx 1$

In other words, after convergence, every node in the network maintains the same $h$ leading entries in its cache, corresponding to the stable hub set $H(T)$, and this structure remains fixed over time.

It is important to note that only the top-$h$ entries of the cache are relevant for stability. The remaining $c-h$ entries of each cache can still fluctuate over time, as they typically contain random samples of other nodes in the network. Since these entries do not influence the global hub set, their variability does not affect the stability of the Elevator algorithm.

#proposition[
Once Elevator has converged to a stable state, it remains in that state. 
To prove this, we must establish that:
  1. the number of hubs cannot exceed $h$,
  2. the number of hubs cannot fall below $h$, and
  3. The set of hubs remain the same.
]

#proof[
We prove point (i) as follows: At each new iteration of the algorithm, each node selects the first $h$ elements of its _frequency_map_. 
Therefore, even if in the previous cycle an additional node temporarily became a hub alongside the $h$ existing hubs, in the next cycle the number of hubs will be restored to at most $h$.

To prove point (ii), it should be noted that for the number of hubs to decrease, one or more nodes must not choose one of the nodes already selected as a hub in their list of potential hubs. 

Given that we are in a stable state, with each node having the same $h$ nodes as hubs in its list, the only way for a node not to choose one of the previous hubs as a potential hub for the next cycle is for a random node to appear in the list of connections of the node's $c$ outgoing neighbours, i.e., as frequently as a hub, and it would also need to have a smaller ID than a hub already present. 

If this happens, and since there can only be a maximum of $h$ nodes chosen as potential hubs by a node $n$, then one of the potential hubs of node $n$ will be removed and replaced by a random node. We therefore need to calculate the probability of this event occurring.

Let us consider a randomly selected node $i$ that could be chosen as a potential hub.  
We first evaluate the probability that $i$ appears in the list of successors of one of the successors $m$ of a given node $n$.  

Since the network contains $N$ nodes in total, and there are $c-h$ remaining slots in the list of successors of $m$ (the $h$ hub positions are already occupied), the probability that $i$ appears in this list can be written as:
$Pr[i in "Succ"(m)] approx (c-h)/N.$

Here we assume independence in the selection of the $c-h$ nodes, which is not strictly true (as once a node has been chosen as a successor, it cannot be selected again). However, this approximation becomes reasonable when $N$ is large.

Next, we calculate the probability that node $i$ appears in the list of all $c$ successors of node $n$.  
Since the choices of successors are independent across the $c$ neighbours of $n$, this probability is:
$
Pr[i in inter.big_(m in "Succ"(n)) "Succ"(m)] 
= ((c-h)/N)^c.
$

This represents the probability that node $i$ is chosen as a potential hub by node $n$: indeed, if $i$ is present in the cache of all successors of $n$, and we assume that its identifier is smaller than at least one of the existing hubs, then $i$ will replace that hub and become a new potential hub for $n$.

Let $N$ be the number of nodes, $h$ the number of hubs, and $c$ the cache (outgoing neighbors) size.
Fix a node $n$. For a given non-hub node $i$ (there are $N-h$ such nodes),
the probability that $i$ appears in the list of successors of a given successor $m$ of $n$
is approximately
$
p_1 approx (c-h)/N,
$ using the large-$N$ approximation (independent sampling without replacement $approx$ with replacement).

Assuming independence across the $c$ successors of $n$, the probability that $i$ belongs to _all_ those successor-lists is
$
p_2 approx p_1^c = ((c-h)/N)^c.
$

Thus the expected number (or by union bound, an upper bound on the probability) that _at least one_ non-hub $i$ satisfies this property for node $n$ is bounded by
$
(N-h)p_2 = (N-h)((c-h)/(N))^c.
$

If we now take the union over all $N$ nodes $n$ (assuming independence for an upper bound), we obtain an upper bound on the probability that some cache (in the whole network) receives such a random node that could replace an existing hub:
$
P_["new potential hub"] approx N (N-h) ((c-h)/N)^c.
$ <eq:P_replace>

This quantity is to be interpreted as a (pessimistic) upper bound on the probability that a potential hub appears at random and replaces an existing hub during one cycle.

Assume that $c << N$ and $h << N$. Then the probability that a new potential hub appears, as computed in Equation @eq:P_replace, is very low. Consequently, the complementary probability, i.e., that no new potential hub appears, is practically equal to 1.

Suppose a new potential hub does appear. This event can at most reduce the number of hubs for a single cycle, because the new potential hub affects only one node's cache. In the subsequent cycle, when this node updates its cache using the Elevator algorithm, it selects the same list of potential hubs as all other nodes, restoring the set of hubs to its previous configuration.

Furthermore, the probability that a new potential hub appears in two consecutive cycles is approximately the square of the already small probability, making it even less likely. Therefore, we can safely neglect these events and conclude that, with high probability, the number of hubs cannot decrease after convergence.

Finally, we consider the scenario where a potential hub is elected randomly by all nodes in the network, and this potential hub has an ID smaller than one of the existing hubs. In this case, the potential hub may replace an existing hub, causing the set of hubs to change. To prove (iii), we need to prove that with high probability, this scenario will not happen.

We aim to compute the probability $p(x)$ that the intersection of all $N$ subsets $A_k$ contains exactly $x$ elements, where $x in \{0, 1, dots, m}$, and $m=c-h$.

We first define $q(x)$, the probability that the intersection of the $N$ subsets $A_k$ contains at least $x$ elements:
$
q(x) = (binom(n,x) dot (binom(n-x,m-x))^N)/( binom(n,m))^N,
$
where
    - $binom(n,x)$ is the number of ways to choose the $x$ elements that are common to all subsets $A_k$,
    - $binom(n - x,m - x)$ is the number of ways to choose the remaining $m - x$ elements for each subset $A_k$, ensuring that the $x$ common elements are included,
    - $binom(n,m)$ is the total number of ways to choose $m$ elements for each subset $A_k$.

The probability $p(x)$ that the intersection contains exactly $x$ elements is then
$
p(x) = q(x) - q(x+1), quad x = 0, 1, dots, m-1,
$
and for the special case $x = m$:
$
p(m) = q(m) = 1/( binom(n,m))^(N-1).
$

Here,
    - $q(x)$ is the probability that the intersection contains at least $x$ elements,
    - $q(x+1)$ is the probability that the intersection contains at least $x+1$ elements,
    - Subtracting $q(x+1)$ from $q(x)$ yields the probability that the intersection contains exactly $x$ elements.


The probability that a new potential hub replaces an existing hub is extremely small for typical parameters $c << N$ and $h << N$.

Indeed, we have
$
q(0) = P[X gt.eq 0],
$
which is the probability that there are at least 0 elements common to all subsets $A_k$. This can be computed as
$
q(0) = (binom(n,0)(binom(n,m))^N)/(binom(n,m) )^N.
$

Since
$
binom(n,0) = 1,
$
we obtain
$
q(0) = (1 dot (binom(n,m))^N)/(binom(n,m) )^N = 1.
$

For the other values, such as $q(1), q(2), dots$, these probabilities are extremely small when $c << N$ and $h << N$. Therefore, we have
$
p(0) = q(0) - q(1) approx 1,
$
where $p(0)$ represents the probability that the set of hubs does not change. This shows that, with very high probability, a randomly selected potential hub cannot replace any existing hub, confirming the stability of the set of hubs in the network.

Combining these three cases, we conclude that the Elevator algorithm is stable: once the network has converged to $h$ hubs, this set remains unchanged with high probability in subsequent cycles.

]

=== Convergence

To reason about the convergence of the Elevator algorithm, we consider three possible scenarios after a protocol cycle:

1. *Network disconnection:* the network becomes disconnected, in which case the system cannot converge to a stable state because nodes in different components cannot coordinate on a common set of hubs.

2. *Multiple hub clusters:* two or more clusters form in the network, with each cluster choosing a distinct set of hubs. In this case, there is no convergence towards a stable state with a single set of $h$ hubs in the network.

3. *Stable convergence:* the network converges towards a stable state with exactly $h$ hubs shared by all nodes.

To prove convergence with high probability, it is therefore sufficient to show that the first two scenarios, i.e., network disconnection and formation of multiple hub clusters, are highly unlikely to occur in practice. Once these cases are ruled out, the system will converge to the stable set of $h$ hubs with high probability.

#proposition[
If the network contains at least one hub, then the network is strongly connected with high probability.
] <prop:convergence1>

#proof[
The presence of at least one hub ensures that every node has an outgoing connection to the hub, which makes the network weakly connected. Additionally, each node has at least one random successor, chosen uniformly across the network, because each node requests a random incoming connection from the hub. Therefore, starting from any node $n$, any other node can be reached by following a sequence of random outgoing connections.

It is possible that the network temporarily forms two or more clusters, in which case some nodes might not be reachable from others. However, this is unlikely:
- If a node is in a small cluster, there is a high probability that it's random outgoing connection points to a node in another cluster.
- If a node is in a big cluster, there are many nodes in its cluster, so it is likely that at least one node has a random outgoing connection to a node in another cluster.

Even if after a protocol cycle the network is temporarily not strongly connected, it will regain strong connectivity with high probability in the next cycle, thanks to new random outgoing connections. Thus, the network may lose this property momentarily, but it will eventually recover it after a few cycles.
]

#proposition[
If the network contains at least one hub, an additional hub will eventually appear with high probability.
] <prop:convergence2>

#proof[
Each hub provides a random outgoing connection to every node in the network. This means there is a small, but non-zero, probability that all nodes points to the same node. If this occurs, that node will be selected as a new hub.

Although the probability for all nodes to select the same node simultaneously is low, it is strictly greater than zero. Therefore, given enough protocol cycles, this event is bound to happen eventually. Consequently, the network will eventually contain at least one additional hub, beyond the original hub.
]

#proposition[
Once the network reaches a state with a number of hubs between $1$ and $h-1$, this number cannot decrease.
] <prop:convergence3>

#proof[
Consider a system state where the number of hubs is $h_i$, with $1 <= h_i <= h-1$. If a node is chosen as a hub, it will be included in the caches of other nodes according to the algorithm. In this scenario:

- Any newly selected node as a hub increases the total number of hubs by $1$, but does not remove any of the previously selected hubs from the network.
- Therefore, the set of existing hubs is preserved in subsequent cycles.

As a consequence, the number of hubs in the network cannot decrease while it remains below $h$. This establishes that, once the system enters a state with $1 <= h_i <= h-1$ hubs, the number of hubs is non-decreasing until it reaches $h$.
]

#proposition[
Let $h$ be the desired number of hubs in the network. Once the network contains at least one hub, it will converge with high probability to a stable state containing exactly $h$ hubs.
] <prop:convergence4>

#proof[
From @prop:convergence1, we know that if the network contains at least one hub, it remains strongly connected with high probability.  
From @prop:convergence2, we know that an additional hub will eventually appear with high probability.  
From @prop:convergence3, we know that once the number of hubs is between $1$ and $h-1$, it cannot decrease.

Combining these results, we can conclude the following:

- Starting from a state with at least one hub, the network remains strongly connected.
- Since the number of hubs cannot decrease, and there is always a non-zero probability for new hubs to appear (@prop:convergence2), the number of hubs will eventually increase until it reaches $h$.
- Once the network reaches $h$ hubs, the system has converged to the desired stable state (as the number of hubs cannot exceed $h$ due to the algorithm’s selection mechanism).

Therefore, starting from at least one hub, the network converges with high probability to the stable state with exactly $h$ hubs.
]

#proposition[
With sufficiently large $c$, the Elevator algorithm generates at least one hub after a finite number of cycles with high probability.
] <prop:convergence5>

#proof[
Initially, each node selects $c$ neighbors uniformly at random. With high probability, these selections are spread across the network and are representative of the network as a whole, ensuring that no isolated cluster is formed before the first cycle.

Each node then selects $h$ nodes as potential hubs, following the preferential attachment rules of the Elevator protocol. With high probability, the chosen potential hubs form a subset representative of the entire network. Each node subsequently requests its potential hubs for random incoming connections. Since the potential hubs are representative of the network, with high probability, each node receives $c-h$ random incoming connections from a subset that is also representative of the network. Thus, after a cycle of the protocol, the list of successors of each node remains representative of the network, maintaining connectivity and minimizing the risk of cluster formation. This state is preserved in subsequent cycles.

In the following cycles, nodes select the top $h$ candidates from their frequency maps. The number of potential hubs gradually decreases, until at least one node emerges as a hub.

Therefore, with sufficiently large $c$, the probability of creating disconnected clusters is very low, and the algorithm converges to a state with at least one hub after a finite number of cycles with high probability.
]

#proposition[
Starting from a random initial network, the Elevator algorithm converges with high probability to a stable state containing exactly $h$ hubs.
] <prop:convergence6>

#proof[
From @prop:convergence5, we know that with sufficiently large $c$, the Elevator algorithm generates at least one hub after a finite number of cycles with high probability.  
From @prop:convergence4, we know that once the network contains at least one hub, it will converge with high probability to a stable state containing exactly $h$ hubs.

Combining these two results, we conclude that:

- Starting from a random network, the algorithm generates the first hub with high probability.
- Once at least one hub exists, the network remains strongly connected, and additional hubs appear until the number of hubs reaches $h$ without decreasing.
- Therefore, the system converges with high probability to the desired stable state containing exactly $h$ hubs.
]

=== Time to Convergence

Studying the convergence time of the Elevator algorithm directly on the full system is extremely challenging. The network can consist of thousands of nodes, each maintaining multiple outgoing connections, resulting in a dynamic graph with stochastic elements. Modeling the system using a Markov chain would be prohibitively complex, as it is practically impossible to compute the transition probabilities between all possible system states. 

Therefore, we adopt a simplified model that captures the essential dynamics of the system while remaining analytically tractable. Our goal is to develop a model that reflects the behavior observed in simulations and experiments, namely the very rapid convergence observed in networks of 1,000 nodes, typically within 4 to 5 protocol cycles.

==== Model A, Geometric Sequence

We provide a simple analytical model to estimate the upper bound on the convergence time of our protocol. The idea is to track the evolution of the node with the highest initial indegree, and observe how quickly its popularity can grow due to the recursive selection mechanism.

We consider a recursive mechanism where each node, at each cycle, selects as new successor the node that appears most frequently among its 2-hop neighbors. This induces a reinforcement effect: popular nodes attract more attention.

Let us assume that a node $v$ has indegree $d_0 = i$ at cycle $t = 0$. Each of these $i$ predecessors has roughly $K$ neighbors (with $K=c$ the size of the cache). Hence, $v$ appears in up to $i · K$ 2-hop paths. If a fraction $p$ of these paths leads to new incoming edges for $v$ at the next cycle, then the indegree evolves as:

$
d_(t+1) = p · K · d_t
$

Such an equation has the general solution given by a geometric progression:

$
d_t = d_0 · (p · K)^t,
$

where $d_0 = i$ is the initial indegree at cycle $t = 0$.

This shows that the indegree evolves exponentially with respect to the number of cycles $t$, growing or shrinking depending on the value of $p · K$.

We define convergence as the moment when a node has indegree comparable to the size of the network, i.e.,

$
d_t ≥ N.
$

Using the closed-form expression

$
d_t = i · (p · K)^t,
$

we solve for $t$:

$
i · (p · K)^t ≥ N ⇒ (p · K)^t ≥ N / i ⇒ t ≥ log(N / i) / log(p · K).
$

This provides an upper bound on the number of cycles required for convergence.

This bound captures a snowball effect: once a node accumulates a small advantage in indegree, it can quickly dominate due to positive feedback. Even if the exact dynamics involve noise and competition, this reasoning shows that convergence is fast (logarithmic in $N$), and largely driven by early centrality fluctuations.

The geometric sequence model provides a first approximation of the convergence dynamics of the Elevator protocol, but it suffers from several important limitations. First, it assumes that the probability of being selected as a hub is strictly proportional to the current indegree, ignoring other structural effects of the network. Second, it neglects the presence of duplicate nodes in the second-degree neighborhoods, which can bias the distribution of choices. Third, the exponential growth curve derived from this model only reflects an average behavior, without capturing the stochastic fluctuations that arise in real network dynamics. Finally, the parameter $p$, representing the fraction of second-degree neighbors selecting a given hub, is chosen arbitrarily. These limitations highlights the need for a more refined model that naturally accounts for the saturation effect as the indegree approaches its maximum possible value. To address this issue, we introduce a logistic-based model, which provides a more realistic description of the slowdown in growth near the system’s capacity.

==== Model B, Logistic Function with Dynamic Rate

We decided to use a logistic function with a dynamic rate of growth to study the convergence time of the Elevator algorithm. This choice is well-suited to our case because the system is dynamic, with one or several hubs increasing their in-degree rapidly, initially in an approximately exponential manner. The rate of increase is not constant, but itself grows over time, before eventually slowing down as the in-degree approaches its upper bound, i.e., the size of the network.  

We model the evolution of the in-degree growth (of the slowest hub) using the following function:

$
d(t) = (N) / (1 + a · exp(-(r_0 t + (1/2) δ_r t^2)))
$

where $N$ is the network size, $a$ is a scaling parameter, $r_0$ is the initial growth rate, and $δ_r$ controls the acceleration of the rate.  

For our case, we selected the following values:  

$
r_0 = 2 + h / 10, quad
δ_r = K / N, quad
a = N / K - 1,
$

with $K=c$ is the size of the cache and $N$ the size of the network.

These choices are motivated as follows: a larger $h$ increases the speed of convergence, since having multiple hubs accelerates the dissemination of hub information in the network. Although $K$ has little influence in practice, in theory a larger cache allows nodes to explore more candidates, which can also increase the convergence speed. Finally, a larger network size $N$ naturally increases the convergence time, as more nodes are required to reach consensus; however, the growth remains exponential, and thus convergence is still very fast in practice.

==== Evaluation of models

We evaluate the two proposed models (Model A: Geometric Growth Model and Model B: Logistic Function) by comparing them with the results obtained from simulations of the Elevator protocol. The goal of this comparison is to examine whether the theoretical models reproduce the same qualitative behavior observed in practice, in particular the progression curve of the hub node’s indegree over time. We will quantitatively assess the models by computing the mean absolute error (MAE) and the root mean squared error (RMSE) between the predicted curves and the simulation data. As we can see in  @ModelNsize, @Modelcachesize and @Modelnbhubs, the Logistic Model is closer to the data from the simulation, and in particular it's more accurate in situations where the values of K and h are changed. As we can see in @Nfit, @Kfit and @hfit, the Logistic has almost always a better RMSE and MAE compared to the Geometric model, and sometimes with values very small, indicating that our model is very good at fitting to the data. If we look at convergence times (in @timeN, @timeK and @timeh), the geometric model is often too fast in terms of convergence time. The logistic model is more pessimistic, but this suits us because we want to have an upper bound on convergence time, and in any case, convergence times remain very close to the simulation results. It should be noted that when calculating the convergence time, we used an approximation of $10^{-3}$ relative to the simulation value, given that the Logistic model never reaches the limit value but comes as close to it as possible.
#grid(
    columns: 1,
[#figure(
  image("../../Images/models/indegree_Nsize_comparison_models.pdf", width: 90%),
  caption: [In-degree evolution of the hub, comparing models with simulation data, with N from 100 to 1000. K=20, h=10.],
) <ModelNsize>],
[#figure(
  image("../../Images/models/indegree_cachesize_comparison_models.pdf", width: 90%),
  caption: [In-degree evolution of the hub, comparing models with simulation data, with varying values for K. N=1000, h=10.],
) <Modelcachesize>],
[#figure(
  image("../../Images/models/indegree_numberhubs_comparison_models.pdf", width: 90%),
  caption: [In-degree evolution of the hub, comparing models with simulation data, with varying values for h. K=20, N=1000.],
) <Modelnbhubs>]
)
#figure(
  table(
    columns: 5,
    align: center,
    table.header(
      [$N$], [RMSE (Logistic)], [RMSE (Geometric)], [MAE (Logistic)], [MAE (Geometric)]
    ),
    [100],  [2.38],  [1.30],   [1.09],  [0.72],
    [200],  [3.92],  [15.79],  [1.82],  [5.93],
    [500],  [21.04], [81.75],  [7.08],  [34.86],
    [1000], [61.72], [221.44], [21.40], [93.59],
  ),
  caption: [Comparison of Logistic and Geometric Models for Different $N$],
) <Nfit>

#figure(
  table(
    columns: 5,
    align: center,
    table.header(
      [$K$], [RMSE (Logistic)], [RMSE (Geometric)], [MAE (Logistic)], [MAE (Geometric)]
    ),
    [10], [118.58], [545.27], [48.77], [385.44],
    [15], [46.23],  [311.61], [18.46], [155.40],
    [20], [61.72],  [221.44], [21.40], [93.59],
  ),
  caption: [Comparison of Logistic and Geometric Models for Different $K$],
) <Kfit>

#figure(
  table(
    columns: 5,
    align: center,
    table.header(
      [$h$], [RMSE (Logistic)], [RMSE (Geometric)], [MAE (Logistic)], [MAE (Geometric)]
    ),
    [1],  [19.95], [315.60], [9.13],  [174.91],
    [5],  [85.72], [275.66], [35.31], [140.56],
    [10], [61.72], [221.44], [21.40], [93.59],
    [20], [30.61], [174.94], [10.64], [71.88],
  ),
  caption: [Comparison of Logistic and Geometric Models for Different $h$],
) <hfit>

#figure(
  table(
    columns: 4,
    align: center,
    table.header(
      [$N$], [Logistic], [Geometric], [Simulation]
    ),
    [100],  [4], [2], [5],
    [200],  [5], [2], [4],
    [500],  [6], [3], [5],
    [1000], [6], [3], [5],
  ),
  caption: [Cycles to reach $N$ for different network sizes.],
) <timeN>

#figure(
  table(
    columns: 4,
    align: center,
    table.header(
      [$K$], [Logistic], [Geometric], [Simulation]
    ),
    [10], [7], [7], [4],
    [15], [6], [4], [5],
    [20], [6], [3], [5],
  ),
  caption: [Cycles to reach $N$ for different values of $K$.],
) <timeK>

#figure(
table(
  columns: 4,
  align: center,
  table.header(
    [$h$], [Logistic], [Geometric], [Simulation]),
    [1],  [9], [5], [7],
    [5],  [7], [4], [6],
    [10], [6], [3], [5],
    [20], [5], [3], [3],
), caption: [Cycles to reach $N$ for different values of $h$.],
) <timeh>

== Simulation-Based Evaluation

We evaluate our proposal by carrying out a simulation campaign.
All simulations use the Java *PeerSim* simulator @p2p09-peersim.
We have modified the simulator to add parallelism to accelerate computations.
With Peersim, we implemented our algorithm Elevator, and state-of-the-art PROOFS @stavrou2004lightweight and Phenix @wouhaybi2004phenix algorithms #footnote[https://gitlab.lip6.fr/legheraba/elevator].
Also, we used the implementation of Newscast provided by PeerSim.

We compared the performance of Elevator with these 3 algorithms.
We chose to compare our proposed algorithm to these three algorithms as they are widely used in the literature.
Newscast is used for gossip learning @ormandi2013gossip, PROOFS is a foundational algorithm, as Secure Cyclon @antonov2023securecyclon, one of the latest peer sampling algorithm in the literature, is based on Cyclon @voulgaris2005cyclon, itself based on PROOFS.
Phenix is interesting as it has especially been conceived to be resilient to failures and Byzantine attacks and also to construct networks that have a low diameter.
We did not include recent algorithms @xie2008scale @bulut2013constructing @lynn2024emergent that primarily focus on improving the power law distribution of the in-degrees @xie2008scale @bulut2013constructing @lynn2024emergent, as they are expected to behave similarly to Phenix @wouhaybi2004phenix.

All simulations were run with a network of size *n* = 1000.
As the Phenix network needs a growing network to work, we started the Phenix algorithm with a network size of 20 and capped the size of the network to 1000.
The simulations were run during 1000 cycles, and we repeated each simulation 100 times.
All simulations were started with a network initialized as a $k$-out random graph, with $k = c = 20$.
All simulations were run on 16 vCPU, using 64G of memory, on a cluster composed of 10 servers, described in @table-cluster.

#figure(
  table(
    columns: 4,
    align: center,
    table.header(
      [Machine], [Memory], [Processors], [Cores]
    ),
    [DELL PowerEdge XE8545], [2 To], [2 x AMD EPYC 7543], [128 threads @ 2.80 GHz],
    [DELL PowerEdge R750xa], [2 To], [2 x Intel Xeon Gold 6330], [112 threads @ 2.00 GHz],
  ),
  caption: [Description of the cluster],
) <table-cluster>

We evaluated the following metrics: in-degree distribution, clustering coefficient, average shortest path length, and diameter.

The degree distributions of Newscast and PROOFS exhibit patterns akin to a normal distribution.
We see similar results for Elevator, except for a distinct group of 10 hubs with an in-degree of 999.
By contrast, the Phenix protocol's degree distribution conforms to a power-law distribution.

PROOFS and Newscast maintain a low clustering coefficient during all simulations, as seen in @fig:ClustCoef.
On the contrary, Phenix and Elevator have both a clustering coefficient of around 0.6.
For Phenix, the value is related to the power-law distribution of in-degree, and for Elevator, the value is linked to the presence of hubs, that are connected to everyone, and this automatically increases the value of the coefficient.

As we can see in @fig:AveragePathLength, Elevator has a very low average path length, with a value below 2.
This value is due to the presence of hubs in the network, that permit to have a maximum distance of 2 between any 2 nodes.
Phenix has the same value.
PROOFS is very close, with a value around 2.15 and Newscast is a bit below 2.6.
All these values are very good and thus we need to compute the diameter to discriminate between algorithms.

In @fig:Diameter, we see that Elevator gives a network with a diameter equal to 2.
Again, this value is due to the presence of hubs in the network.
The Phenix algorithm yields similar results.
This is better than PROOFS and Newscast, which output respectively 3 and 4 for this metric.

#grid(
  columns: 1,
  [#figure(
  image("../../Images/Elevator/normal_1000_100xp_clustering_color.pdf", width: 90%),
  caption: [Clustering coefficient computed during the simulation (no failures), for each algorithm, every 10 cycles],
) <fig:ClustCoef>],
[#figure(
  image("../../Images/Elevator/normal_1000_100xp_average_path_color.pdf", width: 90%),
  caption: [Average path length computed during the simulation (no failures), for each algorithm, every 10 cycles],
) <fig:AveragePathLength>],
[#figure(
  image("../../Images/Elevator/normal_1000_100xp_diameter_color.pdf", width: 90%),
  caption: [Diameter computed during the simulation (no failures), for each algorithm, every 10 cycles],
) <fig:Diameter>],
)

We also compared the algorithms according to their resilience to crashes, churn, and byzantine attacks, as shown below.

=== Resilience to crashes

We analyze the performance of the four algorithms when the network suffers crashes.
To simulate a brutal failure we disconnected 50% of the nodes in the middle of the simulation, *i.e.*, in this case, we have disconnected 500 nodes at cycle 500 (as there are 1000 nodes in total and 1000 cycles).

The performance of Elevator is not affected, as the in-degree distribution is still the same, and we have 10 hubs with an in-degree of 499.
The degree distribution is also the same for Newscast and PROOFS.
For Phenix, the degree distribution remains the same, with values going to a max of 999, even if there are only 500 nodes in the network.
It's because the nodes have kept in their cache the addresses of (old) nodes who are no longer in the network.
In @fig:ClustCoefCrash, the clustering coefficient evolution shows that it is not affected by the crashes, as we have almost the same results as those obtained without a crash.
The same observation holds for the average path length and the diameter, as we can see in @fig:AveragePathLengthCrash and @fig:DiameterCrash.

#grid(
  columns: 1,
[#figure(
  image("../../Images/Elevator/crash_1000_100xp_clustering_color.pdf", width: 90%),
  caption: [Clustering coefficient computed with a 50% crash, for each algorithm, every 10 cycles],
) <fig:ClustCoefCrash>],
[#figure(
  image("../../Images/Elevator/crash_1000_100xp_average_path_color.pdf", width: 90%),
  caption: [Average path length computed with a 50% crash, for each algorithm, every 10 cycles],
) <fig:AveragePathLengthCrash>],
[#figure(
  image("../../Images/Elevator/crash_1000_100xp_diameter_color.pdf", width: 90%),
  caption: [Diameter computed with a 50% crash, for each algorithm, every 10 cycles],
) <fig:DiameterCrash>],
)

=== Resilience to churn

We now analyze the performance of the four algorithms when the network is subject to churn.
To simulate churn, we disconnected 10% of the nodes at each cycle and replaced them with the same amount of new nodes, each connected to 20 nodes uniformly at random.
The churn occurs during 500 cycles, between cycle n°250 and cycle n°750.
As the Phenix algorithm needs a growing network to work, the way we implement churn differs.
Following previous work @wouhaybi2004phenix, in the case of Phenix, we implement churn having the number of removed nodes less than the number of added nodes at each cycle, assuming nodes are removed following a normal distribution $cal(N)(0,1)$, for all cycles of the simulation.

The in-degree distribution of Elevator remains the same, with 10 hubs.
PROOFS seems affected by churn, as the mean degree distribution goes to 10 instead of 20 without churn.
In @fig:ClustCoefChurn we can observe that we have almost the same results as the results obtained without churn for the clustering coefficient.
For the average path length, PROOFS is the most affected, with a value going from 2.25 without churn to a value of 2.5 with churn, and the value keep increasing after the end of the churn, going up to 2.75, as we can see in @fig:AveragePathLengthChurn.
In @fig:DiameterChurn, we can see that the diameter varies with churn, with a mean going up to 3.25 instead of 2.0, but the values for Phenix and Elevator remain below the ones of Newscast and PROOFS.

#grid(
  columns: 1,
[#figure(
  image("../../Images/Elevator/churn_1000_100xp_clustering_color.pdf", width: 90%),
  caption: [Clustering coefficient computed with churn, for each algorithm, every 10 cycles],
) <fig:ClustCoefChurn>],
[#figure(
  image("../../Images/Elevator/churn_1000_100xp_average_path_color.pdf", width: 90%),
  caption: [Average path length computed with churn, for each algorithm, every 10 cycles],
) <fig:AveragePathLengthChurn>],
[#figure(
  image("../../Images/Elevator/churn_1000_100xp_diameter_color.pdf", width: 90%),
  caption: [Diameter computed with churn, for each algorithm, every 10 cycles],
) <fig:DiameterChurn>],
)

=== Resilience to hub-targeted failures

We hereby analyze the performance of the four algorithms after a failure on the hubs during the execution of the simulation.
To simulate it, we disconnected 10 nodes that have the highest in-degree in the middle of the simulated scenario.

Logically, Newscast and PROOFS are not affected by the failure, as there are no hubs in the networks built by these algorithms.
For Elevator, the in-degree distribution remains similar, with 10 high-in-degree peers that have each an in-degree of 989.
We are thus confident in the capacity of our algorithm to promote new nodes to the position of hubs if the previous hubs were disconnected.
In @fig:ClustCoefCrashHub we can see that we have almost the same results as the results obtained without crashes for the clustering coefficient.
Its the same for the average path length and the diameter, there is no impact, as we can see in @fig:AveragePathLengthCrashHub and @fig:DiameterCrashHub.

#grid(
  columns: 1,
[#figure(
  image("../../Images/Elevator/crash_hub_1000_100xp_clustering_color.pdf", width: 90%),
  caption: [Clustering coefficient computed with a hub-targeted failure, for each algorithm, every 10 cycles],
) <fig:ClustCoefCrashHub>],
[#figure(
  image("../../Images/Elevator/crash_hub_1000_100xp_average_path_color.pdf", width: 90%),
  caption: [Average path length computed with a hub-targeted failure, for each algorithm, every 10 cycles],
) <fig:AveragePathLengthCrashHub>],
[#figure(
  image("../../Images/Elevator/crash_hub_1000_100xp_diameter_color.pdf", width: 90%),
  caption: [Diameter computed with a hub-targeted failure, for each algorithm, every 10 cycles],
) <fig:DiameterCrashHub>],
)

=== Resilience to Byzantine attacks
We measure Elevator's Byzantine resilience using two key metrics: (i) _Hub formation rate_ — the number of hub positions held by legitimate nodes versus attackers (Byzantine nodes), and (ii) _Network topology stability_ — whether hub formation continues to function correctly under attack.
Each test runs for 1000 cycles to ensure network stabilization, and results are averaged over 100 independent simulations to account for randomness in network initialization and protocol execution. 
// We first evaluate the impact of Byzantine attacks on Elevator, and then the effectiveness of the Lift countermeasure protocol.

// === Impact of byzantine attacks

Our experimental evaluation of Elevator under Byzantine attacks reveals several important insights regarding its resilience and limitations. When the protocol runs without malicious nodes, convergence to the 10 hubs occurs very quickly — in fewer than 4 cycles on average (@fig:no_attack). Introducing a single Byzantine node in a 1,000-node network shows minimal disruption: in the passive case, the malicious node becomes a hub only 2 times out of 100 simulations, while in the active case, it becomes a hub 7 times out of 100; in both cases, the total number of hubs remains 10 (@fig:single_byzantine_active, @fig:single_byzantine_passive). This confirms that Elevator is robust against isolated adversarial behavior.

When multiple non-coordinated Byzantine nodes are introduced randomly in the network, their impact remains limited. On average, only 0.95 out of 10 hubs are Byzantine, meaning that although the attackers represent 5% of the nodes, they account for 9.5% of hubs (@fig:independent_byzantine). 

#grid(
  columns: 1,
[#figure(
  image("../../Images/CANDAR/no_attack.pdf", width: 90%),
  caption: [Running of Elevator without attack.],
) <fig:no_attack>
],
  [
    #figure(
      image("../../Images/CANDAR/elevator.ElevatorVOneByzantine2_oneByzantineActif_1000_nb_hubs_100_cycles.pdf", width: 90%),
      caption: [Active Byzantine behavior.],
    ) <fig:single_byzantine_active>
  ],
  [
    #figure(
      image("../../Images/CANDAR/elevator.ElevatorVOneByzantine_oneByzantinePassif_1000_nb_hubs_100_cycles.pdf", width: 90%),
      caption: [Passive Byzantine behavior.],
    ) <fig:single_byzantine_passive>
  ],
  [#figure(
  image("../../Images/CANDAR/elevator.ElevatorVByzantine2_5percentindep_1000_nb_hubs_100_cycles.pdf", width: 90%),
  caption: [Independent Byzantine attack at 5% rate.],
) <fig:independent_byzantine>
],)

This highlights that coordination is a critical factor for a successful attack. Indeed, coordinated Byzantine nodes — each aware of all other Byzantine nodes and sharing this information when responding to cache requests — dramatically increase the risk of hub capture. Our experiments show a sharp vulnerability threshold around 2% Byzantine participation (@fig:1percent_byzantine, @fig:2percent_byzantine, @fig:5percent_byzantine): at 1%, the proportion of Byzantine hubs rises from 1% of nodes to 13.4% of hubs, and at 5%, all 10 hubs become Byzantine. This threshold aligns closely with the cache size parameter (_c = 20_), indicating that coordinated attackers need to approach or exceed the cache size to overwhelm the random sampling mechanism effectively.


These findings demonstrate that while Elevator is resilient to individual or independent attacks, its main vulnerability lies in coordinated misinformation. Consequently, it is necessary to implement a defense mechanism that mitigates the influence of Byzantine nodes and restores fairness.

#grid(
  columns: 1,
[#figure(
  image("../../Images/CANDAR/elevator.ElevatorVByzantine2_1percentrandom_1000_nb_hubs_100_cycles.pdf", width: 90%),
  caption: [Byzantine hub infiltration at 1% rate.],
) <fig:1percent_byzantine>
],
[#figure(
  image("../../Images/CANDAR/elevator.ElevatorVByzantine2_2percentrandom_1000_nb_hubs_100_cycles.pdf", width: 90%),
  caption: [Byzantine hub infiltration at 2% rate.],
) <fig:2percent_byzantine>
],
[#figure(
  image("../../Images/CANDAR/elevator.ElevatorVByzantine2_5percentrandom_1000_nb_hubs_100_cycles.pdf", width: 90%),
  caption: [Byzantine hub infiltration at 5% rate.],
) <fig:5percent_byzantine>
],
)

=== Effectiveness of Lift countermeasure

We evaluate the effectiveness of our Lift protocol across different Byzantine participation rates, using the same experimental setup as in the vulnerability analysis. The countermeasure is activated at cycle 100, after which we observe its impact on hub formation and Byzantine infiltration.

At 5% Byzantine participation, the counter-attack is highly effective. After activation, Byzantine hubs are rapidly eliminated and remain at a minimal level for the rest of the simulation. The average total number of hubs decreases slightly to 9.58, while the average number of Byzantine hubs falls to 0.34. In other words, we go from 5% Byzantine nodes to 3.4% Byzantine hubs, representing an almost complete recovery from Byzantine infiltration with only a minor reduction in overall hubs (@fig:counter_5percent).

For 10% Byzantine participation, the countermeasure initially removes Byzantine hubs effectively at cycle 100, but over subsequent cycles, Byzantine nodes gradually regain hub positions. By the end of the simulation, the network has on average 3.19 Byzantine hubs, and the total number of hubs has decreased from 10 to 7.82. This corresponds to approximately 40% of hubs being Byzantine. Although the majority of hubs remain non-Byzantine, the effectiveness is noticeably reduced compared to the 5% case (@fig:counter_10percent).

At 15% Byzantine participation, the Lift countermeasure’s effectiveness diminishes further. While the initial elimination at cycle 100 is successful, Byzantine nodes progressively reestablish themselves as hubs, reaching an average of 4.21 Byzantine hubs by the end. The total number of hubs also decreases from 10 to 6.71, meaning roughly 62% of hubs are now Byzantine. At this level, the countermeasure fails to maintain effective control over hub formation (@fig:counter_15percent).

#grid(
  columns: 1,
[#figure(
      image("../../Images/CANDAR/elevator.ElevatorVCounter_5percentcounter_1000_nb_hubs_100_cycles.pdf", width: 90%),
      caption: [Counter-attack effectiveness at 5% rate.],
    ) <fig:counter_5percent>],
    [    #figure(
      image("../../Images/CANDAR/elevator.ElevatorVCounter_10percentcounter_1000_nb_hubs_100_cycles.pdf", width: 90%),
      caption: [Counter-attack effectiveness at 10% rate.],
    ) <fig:counter_10percent>],
    [    #figure(
      image("../../Images/CANDAR/elevator.ElevatorVCounter_15percentcounter_1000_nb_hubs_100_cycles.pdf", width: 90%),
      caption: [Counter-attack effectiveness at 15% rate.],
    ) <fig:counter_15percent>
],
  )

=== Summary

We first analyzed the structural properties of the network produced by the Elevator protocol. The in-degree distribution remains consistent across different numbers of hubs (see @fig:degreeDistributionVariableNbHubs and @fig:CompareContext), except in the extreme case where $h = c = 20$. In this configuration, nodes connect exclusively to hubs, resulting in a multi-star topology and eliminating random connections. This behavior is fully aligned with the protocol definition, where all outgoing links become preferential.

#grid(
  columns: 1,
[#figure(
  image("../../Images/Elevator/Elevator_1000_100xp_indegree_color.pdf", width: 90%),
  caption: [In-degree distribution of the network, after the run of the Elevator algorithm, with a variable number of hubs (5 hubs, 10 hubs, 15 hubs, 20 hubs), no failures.],
) <fig:degreeDistributionVariableNbHubs>],
[#figure(
  image("../../Images/Elevator/Elevator_context_1000_100xp_indegree_color.pdf", width: 90%),
  caption: [In-degree distribution of the network, after the run of the Elevator algorithm, during each context (no failures, 50% crash, churn, and hub-targeted failure).],
) <fig:CompareContext>],
)

Across different failure contexts, the overall distribution shape and structural metrics remain stable. As illustrated in @fig:ElevatorContextCoefClust, @fig:ElevatorAveragePathLength, and @fig:ElevatorDiameter, the clustering coefficient, average path length, and diameter exhibit only minor variations. This stability is an intrinsic property of the protocol: once hubs emerge, they remain stable over time (except in the presence of failures), which explains the robustness of global metrics. In this regard, Elevator demonstrates greater structural stability than Phenix, particularly concerning diameter and average path length.

#grid(
  columns: 1,
[#figure(
  image("../../Images/Elevator/Elevator_context_1000_100xp_clustering_color.pdf", width: 90%),
  caption: [Clustering of the network, after the run of the Elevator algorithm, during each context (no failures, 50% crash, churn, and hub-targeted failure).],
) <fig:ElevatorContextCoefClust>],
[#figure(
  image("../../Images/Elevator/Elevator_context_1000_100xp_average_path_color.pdf", width: 90%),
  caption: [Average path length of the network, after the run of the Elevator algorithm, during each context (no failures, 50% crash, churn, and hub-targeted failure).],
) <fig:ElevatorAveragePathLength>],
[#figure(
  image("../../Images/Elevator/Elevator_context_1000_100xp_diameter_color.pdf", width: 90%),
  caption: [Diameter of the network, after the run of the Elevator algorithm, during each context (no failures, 50% crash, churn, and hub-targeted failure).],
) <fig:ElevatorDiameter>],
)

We then evaluated the protocol under Byzantine behavior and assessed the effectiveness of the Lift counter-attack. The results show that Lift successfully disrupts coordinated Byzantine hub capture at lower participation rates (e.g., 5%) by introducing a deterministic hub redistribution mechanism. However, as Byzantine participation increases (10% and 15%), its effectiveness decreases: malicious nodes progressively regain hub positions after the countermeasure is triggered. Additionally, the total number of hubs may decrease, indicating that Byzantine interference can prevent some correct nodes from maintaining their hub status.

Interestingly, even after activation of the countermeasure, Byzantine nodes continue attempting hub capture and achieve partial success, leading to slight deviations from the theoretical expectation of an average of $B/N$ Byzantine hubs. Nevertheless, Lift significantly reduces Byzantine influence while remaining lightweight, as it operates as a one-shot solution.

Overall, our simulation results demonstrate that Elevator achieves the targeted structural properties, including the emergence of a controlled number of hubs, bounded degree, and low network diameter. The protocol proves resilient to crash failures and churn, maintaining stable global metrics under dynamic conditions. However, it remains vulnerable to coordinated Byzantine attacks. The proposed Lift countermeasure increases resilience against such attacks without compromising the decentralization or the performance of the protocol.

== Implementation over TCP/IP

// make repository public
// add link to repository

To complement the simulation-based evaluation presented earlier, we implemented a fully operational version of the Elevator protocol over real TCP/IP networks. This implementation (available at https://github.com/MohamedLEGH/elevator-algorithm) serves two main purposes: (i) validating the feasibility of Elevator in a realistic peer-to-peer environment, and (ii) assessing its behavior under asynchronous execution, failures, and heterogeneous deployment conditions.

=== Implementation choices and technological stack

The implementation relies on the Go programming language #footnote[https://go.dev/] and the *libp2p* networking framework #footnote[https://libp2p.io/]. Go was chosen primarily for its strong support for concurrency through goroutines and channels, which naturally fits the highly concurrent nature of peer-to-peer protocols. In addition, Go provides efficient networking primitives and a mature ecosystem for building distributed systems.

The *libp2p* library was used to implement the peer-to-peer communication layer. It provides abstractions for peer identities, transport protocols, stream multiplexing, and protocol negotiation, allowing the Elevator algorithm to be deployed over unstructured peer-to-peer overlays without relying on any centralized component. Communication between peers is performed over TCP/IP using libp2p streams, each stream being associated with a specific protocol identifier.

In parallel, the standard `net/http` library was used to expose a lightweight HTTP interface on each node. This interface serves two roles: (i) enabling external control and monitoring of nodes (e.g., initialization, data collection, experiment orchestration), and (ii) facilitating the bootstrapping phase of the network.

=== Node architecture

Each peer in the network is an autonomous process characterized by:

- a *libp2p port*, used exclusively for peer-to-peer communication and protocol execution;
- an *HTTP port*, used for external control, initialization, and data collection.

Upon startup, a node initializes its libp2p host and registers stream handlers for the Elevator protocol. Each handler corresponds to a specific message type (e.g., cache request or backward request) and defines the logic executed upon reception of a stream. At the same time, an HTTP server is launched in a separate goroutine, allowing the node to receive external commands without blocking protocol execution. A third goroutine is optionally used to process user input from the terminal, mainly for debugging and manual control during experiments.

The node remains idle until its local cache has been fully initialized. Only once this condition is met does it start executing the Elevator protocol.

=== Cache initialization and network bootstrapping

Since the libp2p implementation targets unstructured peer-to-peer networks, no predefined topology is assumed. The initial overlay is therefore constructed externally in a bootstrapping phase.

First, a configuration file listing all participating nodes (IP addresses and HTTP ports) is generated. Using this information, each node is assigned an initial cache of size (c), corresponding to a random (c)-out graph. The initial caches are generated and then distributed to the nodes through HTTP POST requests. Upon reception, each node stores the received cache locally and acknowledges successful initialization.

This approach ensures that all nodes start from a well-defined and controlled initial state, while remaining faithful to the assumptions of the theoretical model.

=== Execution of the Elevator protocol

Once initialized, each node repeatedly executes the Elevator protocol in cycles. During each cycle, the following steps are performed:

1. *Frequency map construction*  
   The node queries all peers in its local cache for their respective caches using libp2p streams. The responses are aggregated into a frequency map that counts how often each peer appears.

2. *Hub selection*  
   The node selects the top-(h) peers with the highest frequencies as potential hubs and removes them from the frequency map.

3. *Backward exploration*  
   For each selected hub, the node requests a backward list (i.e., incoming neighbors) using a dedicated protocol message. These lists are merged to enrich the candidate set.

4. *Cache reconstruction*  
   A new cache of size (c) is built by combining the selected hubs with a subset of backward peers and, if necessary, additional randomly selected nodes.

This process closely mirrors the algorithmic description introduced earlier, but operates over real network connections and asynchronous message exchanges.

=== Execution modes and synchronization strategies

To explore different execution semantics, three variants of the protocol were implemented:

- *Synchronous start, synchronous cycles*  
  All nodes start at a predefined time and execute each cycle in lockstep, waiting a fixed duration between cycles.

- *Externally synchronized execution*  
  A centralized controller periodically triggers the start of each cycle by sending HTTP requests to all nodes. While the Elevator protocol itself remains decentralized, this mode facilitates controlled experiments and reproducibility.

- *Asynchronous execution*  
  Nodes start simultaneously but wait a random duration between cycles. This mode reflects more realistic conditions, where nodes are not synchronized and operate independently.

These variants allow us to study the robustness of Elevator under both idealized and realistic timing assumptions.

=== Experimental validation

The implementation was validated through a series of experiments on small- to medium-scale networks (ranging from 20 to 50 nodes), executed either on a single machine or distributed across two machines. Experiments confirmed the rapid emergence of hubs within the first few cycles, in line with the theoretical analysis and simulation results, as seen in @fig:Victor20nodes and @fig:Victor50nodes.

In @fig:VictorCrash, we show experiments that simulated hub failures by forcibly disconnecting the highest-degree nodes during execution. In all cases, new hubs emerged naturally after a short transient phase, demonstrating the self-healing properties of the protocol. The presence of random connections in the cache played a crucial role in maintaining connectivity and enabling recovery.

From a systems perspective, the implementation revealed a high degree of concurrency, with a large number of goroutines active at runtime. This behavior is expected, as libp2p internally spawns goroutines for stream handling, connection management, and message processing. Despite this, the system remained stable and responsive throughout the experiments.

Overall, this TCP/IP implementation confirms that Elevator is not only theoretically sound and effective in simulation, but also practical and robust when deployed over real peer-to-peer networks. It further demonstrates that the protocol tolerates asynchronous execution, node failures, and dynamic network conditions, making it suitable for realistic distributed environments.

#grid(
  columns: 1,
  [#figure(
  image("../../Images/Victor/graphe_4HUBS_Cycles12.pdf", width: 90%),
  caption: [Number of hubs at each cycle, with $N=20$, $c=10$ and $h=4$],
) <fig:Victor20nodes>],
  [#figure(
  image("../../Images/Victor/graphe_5HUBS_Cycles.pdf", width: 90%),
  caption: [Number of hubs at each cycle, with $N=50$, $c=10$ and $h=5$],
) <fig:Victor50nodes>],
  [#figure(
  image("../../Images/Victor/graphe_4HUBS_deco_Cycles.pdf", width: 90%),
  caption: [Crash of the hubs in the middle of the experiment, with $N=50$, $c=10$ and $h=4$],
) <fig:VictorCrash>],
)

=== CPU Information Collection

Monitoring CPU usage is a critical aspect of evaluating the performance and behavior of each node in the network. Metrics such as CPU utilization (%CPU), CPU time, and memory allocation provide insight into the resource consumption of individual processes. To automate this process, we developed the script `info.py`, which collects these metrics for all nodes and stores them in a CSV file for subsequent analysis. The script is executed at the end of the `launch_nodes.sh` script to ensure that metrics are captured throughout the lifetime of the experiment.

The `info.py` script identifies all processes named `main` and retrieves their process identifiers (PIDs). Using these PIDs, it executes system commands to extract the desired metrics, including CPU and memory statistics. This approach enables precise monitoring of the computational load imposed by the Elevator protocol on each node.

Following preliminary tests on a personal machine, the implementation and scripts were adapted to conduct experiments in a dedicated Linux environment. This allows for more controlled and scalable evaluation of the protocol under realistic system conditions.

For the single-machine experiments, three configurations of the Elevator protocol were tested. In all configurations, the network consisted of 100 nodes executing 100 protocol cycles, with each node maintaining a cache of size 20. The three versions differed in the number of hubs: Version 1 used 10 hubs, Version 2 used 5 hubs, and Version 3 used a single hub. These experiments allowed us to evaluate the impact of varying the number of hubs on the stabilization and performance of the protocol while keeping other parameters constant. For all three versions, the experiments were conducted using 100 nodes with a cache size of 20 and 100 protocol cycles, while varying the number of hubs. The resulting graphs (@fig:Victor100nodes, @fig:Victor100nodesSynchrone and @fig:Victor100nodesAsynchrone) were consistent with those presented in the previous section, showing rapid stabilization of hubs within the first cycles, regardless of parameter variations. Analysis of CPU metrics revealed that certain nodes consumed nearly twice the %CPU and CPU time compared to others. These nodes were identified as the selected hubs, which aligns with the intrinsic definition of a hub: a node maintaining a large number of connections to other peers. Indeed, hubs transmit their caches to a larger subset of nodes, explaining the increased computational load observed.

#grid(
  columns: 1,
[#figure(
  image("../../Images/Victor/graphe_test_V1_10_HUBS.pdf", width: 90%),
  caption: [Number of hubs at each cycle, semi-synchronous, with $N=100$, $c=20$ and $h=10$],
) <fig:Victor100nodes>],
  [#figure(
  image("../../Images/Victor/graphe_test_V2_5_HUBS.pdf", width: 90%),
  caption: [Number of hubs, synchronous mode, with $N=100$, $c=20$ and $h=5$],
) <fig:Victor100nodesSynchrone>],
  [#figure(
  image("../../Images/Victor/graphe_test_V3_1_HUBS.pdf", width: 90%),
  caption: [Number of hubs, asynchronous mode, with $N=100$, $c=20$ and $h=1$],
) <fig:Victor100nodesAsynchrone>],
)

For the two-machine experiments, the network was distributed across a server and a local machine. The server hosted 99 nodes, while the local machine hosted a single node, resulting in a total of 100 nodes. All nodes executed 100 protocol cycles, and each maintained a cache of size 20. The experiment used 10 hubs. This configuration allowed us to observe the behavior and stabilization of hubs in a distributed setup spanning multiple machines, providing insight into the protocol's robustness under a heterogeneous deployment. The results obtained mirrored those of the single-machine experiments. As seen in @fig:Victor100nodesCluster, @fig:Victor100nodesClusterSynchrone and @fig:Victor100nodesClusterAsynchrone, hubs consistently stabilized within the first cycles, demonstrating that the protocol behavior is robust under a distributed setup spanning multiple machines.


Experimental results confirmed theoretical expectations, with rapid convergence to the preconfigured number of hubs across all tested scenarios. Variations in node parameters did not affect the overall stabilization behavior, illustrating the robustness of the Elevator protocol. Future work may involve scaling the experiments to larger networks distributed across more machines to assess performance at a greater scale and to compare results under more heterogeneous deployment conditions.

#grid(
  columns: 1,
  [#figure(
  image("../../Images/Victor/graphe_test2_V1.pdf", width: 90%),
  caption: [Experiments on a cluster of 2 machines, semi-synchronous mode, with $N=100$, $c=20$ and $h=10$],
) <fig:Victor100nodesCluster>],
  [#figure(
  image("../../Images/Victor/graphe_test2_V2.pdf", width: 90%),
  caption: [Experiments on a cluster of 2 machines, synchronous mode, with $N=100$, $c=20$ and $h=10$],
) <fig:Victor100nodesClusterSynchrone>],
  [#figure(
  image("../../Images/Victor/graphe_test2_V3.pdf", width: 90%),
  caption: [Experiments on a cluster of 2 machines, asynchronous mode, with $N=100$, $c=20$ and $h=10$],
) <fig:Victor100nodesClusterAsynchrone>],
)

== Conclusion

We proposed a novel peer sampling algorithm, Elevator, designed for unstructured P2P networks, which enables the organic emergence of a controlled number of hub nodes while preserving decentralization and bounded degree.

Our study combines theoretical analysis, simulation-based evaluation, and real-world experimentation. First, we conducted a formal analysis of the algorithm, establishing its convergence, its stability properties, and providing insights into its convergence speed. This theoretical investigation shows that the protocol drives the system toward a topology characterized by a predefined number of hubs $h$, while maintaining randomness among the remaining connections.

We then validated these properties through extensive simulations. The results demonstrate that Elevator achieves the targeted structural objectives: low network diameter, stable hub formation, bounded degree, and robustness under crash failures and churn. The protocol maintains stable global metrics even under dynamic conditions, confirming the soundness of its design.

Beyond simulations, we implemented Elevator on real peer-to-peer networks, confirming its practical feasibility and validating that its theoretical and simulated properties hold in realistic environments.

We also investigated the vulnerability of Elevator to Byzantine attacks. Our analysis shows that, while the protocol is resilient to failures and churn, it remains vulnerable to coordinated Byzantine strategies aiming at capturing hub positions. To address this limitation, we proposed a modification of the algorithm, Lift, which increases resilience against Byzantine behavior through a deterministic redistribution mechanism. Importantly, this countermeasure improves robustness without compromising decentralization or degrading the performance of the protocol.

Elevator opens the way to a new class of algorithms that we refer to as hub sampling algorithms, where structural centrality is deliberately engineered within unstructured overlays. One particularly promising application domain is artificial intelligence, and federated learning in particular, where controlled hub structures may accelerate model aggregation and dissemination. This use case will be studied in detail in @chap:heal.