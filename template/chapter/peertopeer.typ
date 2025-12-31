#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/lovelace:0.3.0": *

#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
// #import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

= Peer-to-Peer Networks <chap:p2p>
#grid(
  columns: (1fr, 1fr),
  [#figure(
diagram({
  node((1,0), "Server", name: "Server", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client1"), "-", stroke: 1pt)
  edge(label("Client2"), "-", stroke: 1pt)
  edge(label("Client3"), "-", stroke: 1pt)

  node((0,1.5), "Client", name: "Client1", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((1,1.5), "Client", name: "Client2", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((2,1.5), "Client", name: "Client3", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))  
}),
  caption: [A client-server architecture, with 1 server and 3 clients.],
) <client-server-diagram>],
[#figure(
diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0),"Peer", name: "1", radius: 2em)
edge(label("5"), "-", stroke: 1pt)
edge(label("2"), "-", stroke: 1pt)
node((0.3,1),"Peer", name: "2", radius: 2em)
edge(label("5"), "-", stroke: 1pt)
edge(label("3"), "-", stroke: 1pt)
node((1,1.5),"Peer", name: "3", radius: 2em)
node((1.8,1),"Peer", name: "4", radius: 2em)
edge(label("5"), "-", stroke: 1pt)
node((1.8,0),"Peer", name: "5", radius: 2em)
}),
  caption: [A peer-to-peer architecture.],
) <p2p-diagram>]
)

// Core concepts
// Examples of p2p protocols
// Review of the literature

== History and use cases

The client–server architecture is the most common communication model on the Internet. It is a natural fit for protocols such as HTTP, FTP, or SSH, where one central server provides services or data to multiple clients that request them.
The main advantage of client–server architecture lies in its simplicity. The server manages client requests and coordinates their interactions, while users only need to establish a connection to this central point. Security is also easier to enforce, since it mainly involves securing the server.
However, this apparent simplicity comes at a significant cost: the server represents a single point of failure. If it crashes, the entire service becomes unavailable. If it is compromised, all clients are potentially affected. In addition, the computing and networking load is concentrated on the server, while the clients’ capabilities (bandwidth, CPU, storage) often remain underutilized.

To overcome these limitations, peer-to-peer (P2P) architectures emerged as an alternative model. In a P2P system, all nodes (or peers) can act both as clients and servers, directly sharing resources, data, and computation. This decentralization enhances resilience, as there is no single point of failure, and promotes a fairer use of global resources by distributing the workload across participants. P2P systems can also scale naturally, since each new peer contributes additional resources to the network.

Nevertheless, these benefits come at the cost of increased complexity. Moving from a 1–N to an N–N communication model introduces significant challenges in coordination, data consistency, and peer discovery. Security and trust management also become more difficult, as there is no central authority to authenticate or regulate interactions. Moreover, peers are heterogeneous, with varying reliability and performance. As a result, P2P systems must rely on adaptive and fault-tolerant protocols capable of handling a wide range of network conditions and potential attacks.

Although today’s digital services (e.g. GAFAM) are mostly based on centralized architectures, the Internet itself was originally conceived as a decentralised system, as illustrated by the ARPANET network (see @arpanet). While the Internet Protocol (IP) does not form a single decentralised network — but rather a federation of interconnected operator networks — it inherently supports decentralisation, as any node can directly reach another by its IP address without relying on a central server to route messages.
Among the first Internet protocols, several exhibited decentralised or hybrid characteristics rather than a purely client–server model. SMTP and NNTP, for instance, rely on direct communication between independent servers — making them peer-to-peer at the inter-server level — while still following a client–server model for end users connecting to their local instance. Similarly, DNS introduced a distributed yet hierarchical naming system, in which authority is delegated across multiple autonomous zones rather than centralised in a single entity. Moreover, long before the Internet, human societies relied on decentralised networks of exchange, such as medieval trade routes #footnote[https://en.wikipedia.org/wiki/Silk_Road] or the Universal Postal Union #footnote[https://en.wikipedia.org/wiki/Treaty_of_Bern]. In that sense, peer-to-peer architectures reflect a natural and recurring pattern of human organisation.

// we could even add open source projects like the Linux kernel

#figure(
  image("../../Images/1_ieIdnYcxt4kS71uA1QsFGw_arpanet.webp", width: 100%),
  caption: [ARPANET, a network with a peer to peer architecture.],
) <arpanet>

The idea of decentralisation, initially present in the Internet’s underlying protocols, resurfaced more visibly in the late 1990s as peer-to-peer applications began empowering users to exchange data directly with one another.
At that time, the growing demand for large-scale multimedia sharing—combined with limited computing and networking resources (CPU, memory, bandwidth, and storage)—made it difficult for any single server to handle massive numbers of simultaneous downloads. Peer-to-peer networks addressed this limitation by enabling participants to contribute their own resources—especially upload bandwidth—to the system. For example, instead of downloading a 100 MB file from a single server, a user could download small chunks (e.g., 2 MB) from dozens of peers simultaneously, dramatically increasing throughput and scalability.

This concept led to the creation of Napster #footnote[https://en.wikipedia.org/wiki/Napster] in 1999, one of the first large-scale file-sharing systems. Although Napster used a central index server to locate files, the data transfer itself occurred directly between peers, marking a key milestone in the history of P2P networking. Following Napster, other peer-to-peer file-sharing systems emerged, such as Gnutella #footnote[https://en.wikipedia.org/wiki/Gnutella] and BitTorrent #footnote[https://www.bittorrent.com/].
Gnutella is fully decentralised, as it does not rely on any central file index. Starting with version 0.6, it introduced the concept of ultrapeers with the Gia protocol @chawathe2003making — high-capacity nodes that help route queries and files across the network, improving scalability while preserving decentralisation.
BitTorrent brought several notable innovations, including the tit-for-tat mechanism, which encourages fairness by balancing uploading and downloading among peers, and the use of the Kademlia Distributed Hash Table (DHT) for decentralised peer discovery @maymounkov2002kademlia — eliminating the need for central trackers or hierarchical nodes such as ultrapeers. Another notable protocol is Tribler #footnote[https://www.tribler.org/] #footnote[I contributed very briefly to the development of Tribler in 2017, https://github.com/Tribler/tribler/issues/3240], which builds upon BitTorrent while introducing several key innovations, including a distributed search engine and an anonymisation layer. Uniquely, Tribler is an academic project @pouwelse2008tribler developed at Delft University of Technology (TU Delft) in the Netherlands, aiming to create a fully self-sustaining and censorship-resistant file-sharing network.

During the same period, another use case for decentralised networks emerged: anonymisation systems. The Internet Protocol itself does not provide any built-in mechanism for user anonymity or end-to-end encryption. To address this, anonymous overlay networks were developed on top of the Internet, designed to conceal both the content and the origin of communications. These systems typically rely on multi-hop routing and layered encryption, offering a high level of confidentiality at the cost of higher latency and complexity. The most notable examples are Freenet #footnote[https://freenet.org/], I2P #footnote[https://geti2p.net/en/], and Tor #footnote[https://www.torproject.org/]. Although Tor is not entirely peer-to-peer—since a small number of directory authorities coordinate the list of relays—it remains a decentralised system and the most widely used anonymisation network, with around 7,000 active nodes worldwide.

The success of these peer-to-peer protocols inspired other use cases for applications that were not fully decentralised but leveraged peer-to-peer technology to improve performance. Examples include Skype #footnote[https://en.wikipedia.org/wiki/Skype], which until 2014 relied on a peer-to-peer overlay network with supernodes for VoIP communications between users, and Streamroot #footnote[https://github.com/streamroot], which used peer-to-peer technology during live football matches to reduce server load by sharing stream data among viewers. At the academic level, researchers have also explored hybrid architectures for online games @buyukkaya2009vorogame, combining central servers with peer-to-peer mechanisms for data distribution and game state consistency.

Finally, we can mention distributed computing projects such as the Great Internet Mersenne Prime Search (GIMPS) #footnote[https://www.mersenne.org/], SETI\@home #footnote[https://setiathome.berkeley.edu/], and Folding\@home #footnote[https://foldingathome.org/]. Although these systems are not peer-to-peer — since a central server distributes computation tasks to clients — they have demonstrated the feasibility and efficiency of large-scale volunteer computing. These early systems paved the way for later research on decentralised and federated computing models.

Interest in peer-to-peer networking peaked around 2004, with a surge of academic research and widespread adoption by end users. At that time, peer-to-peer applications accounted for roughly 60% of global Internet traffic (with BitTorrent alone representing about 35%) @ftc2005p2p.
In subsequent years, the proportion of P2P traffic declined sharply #footnote[https://torrentfreak.com/bittorrent-is-no-longer-the-king-of-upstream-internet-traffic-240315/], as server performance, bandwidth, and storage capacities increased, enabling efficient large-scale content delivery through centralized services such as streaming platforms and cloud-based distribution networks.
Moreover, the association of P2P networks with copyright infringement and piracy—due to their lack of centralized control—discouraged mainstream users and pushed content providers toward centralized architectures.
Nevertheless, BitTorrent remains actively used today for legitimate purposes, such as distributing Linux operating system images #footnote[For instance, the Ubuntu 25.10 desktop ISO image can be obtained via BitTorrent: https://releases.ubuntu.com/25.10/ubuntu-25.10-desktop-amd64.iso.torrent] and large open-source datasets, including machine learning model weights #footnote[For example, the Mixtral model was shared through a torrent link announced in a post on X in December 2023 by the company Mistral: https://x.com/MistralAI/status/1733150512395038967].

There was a resurgence of interest in peer-to-peer technology in the 2010s, following the emergence of Bitcoin @nakamoto2008bitcoin, which introduced the first blockchain network. The key innovation of Bitcoin is that it enables a completely decentralised and secure payment system by combining peer-to-peer networking, cryptographic proofs and a consensus mechanism. Building on this innovation, and on later advances such as Ethereum’s introduction of smart contracts @buterin2013ethereum, it became possible to create decentralised financial applications (DeFi) #footnote[https://en.wikipedia.org/wiki/Decentralized_finance] and to assign ownership of digital assets such as NFTs #footnote[https://en.wikipedia.org/wiki/Non-fungible_token].

Building on the principle of immutability introduced by blockchain systems—where every transaction is permanently recorded and verifiable—new approaches emerged to apply similar ideas to data storage and sharing. One of the most influential of these systems is the InterPlanetary File System (IPFS) #footnote[https://ipfs.tech/]. Inspired by BitTorrent’s peer-to-peer file distribution, IPFS generalises and extends it by introducing content addressing: every piece of data is identified by the cryptographic hash of its content, ensuring both integrity and permanence. In addition, IPFS structures data using a Merkle Directed Acyclic Graph (Merkle DAG), allowing efficient deduplication and versioning, much like Git but at the scale of a global network.

By combining the guarantees of blockchain immutability, the programmability of smart contracts, and the distributed storage capabilities of IPFS, new forms of decentralised cloud infrastructures have emerged. These systems aim to provide computing and storage services without relying on traditional centralised data centres. Notable examples include Golem #footnote[https://www.golem.network/], which offers a marketplace for distributed computing resources; Sia #footnote[https://sia.tech/], which enables decentralised cloud storage through cryptographically secured contracts; and Filecoin #footnote[https://filecoin.io/], which builds directly on top of IPFS to incentivise data storage and retrieval through a native cryptocurrency. Together, these projects illustrate the ongoing shift towards a decentralised Internet infrastructure, where computation and storage are shared and coordinated through peer-to-peer and blockchain mechanisms rather than controlled by central entities. This paradigm of distributing computation and coordination across multiple nodes naturally extends to the field of machine learning, giving rise to decentralized learning, which we will discuss in a later chapter, as it constitutes the main use case studied in this thesis.

// Hors sujet mais intéressant:
// Decentralized identity
// Lightning Network
// mixnets (NIM and Snowpack)
// Distributed social media (Mastodon, Bluesky)
// airdrop
// AirTag

All of the peer-to-peer networks discussed so far are built on top of the IP layer, and therefore operate as overlay networks — virtual topologies that sit above the underlying Internet infrastructure. Later in this chapter, we will examine in detail how overlay networks function. It is worth noting, however, that decentralized communication networks can also be deployed without relying on the Internet — for instance, through Wi-Fi Direct #footnote[https://en.wikipedia.org/wiki/Wi-Fi_Direct] to form local mesh networks #footnote[https://en.wikipedia.org/wiki/Mesh_networking], via 5G Device-to-Device (D2D) communication, or even using technologies such as Bluetooth Mesh #footnote[https://en.wikipedia.org/wiki/Bluetooth_mesh_networking] or Meshtatic #footnote[https://meshtastic.org/].

// Throughout this chapter, we examine key characteristics of peer-to-peer networks—such as network structure, communication patterns, peer discovery, fault-tolerance and performance metrics—which will allow us to define a taxonomy of these networks.

// In the remainder of this chapter, we will examine some key technical characteristics of peer-to-peer networks, with particular emphasis on unstructured networks.

== Core concepts

=== Overlay Networks

One might wonder why we are interested in overlay networks. The motivation is straightforward. A physical network is typically static and simple—for example, a local network with a router, a computer, and possibly a printer—and its capabilities are largely fixed at creation. Modifying such a network requires physical changes to connections, which is cumbersome. In contrast, an overlay network is implemented on top of a physical network, so changes can be made through software, simply by modifying the protocol. This flexibility has driven the widespread adoption of overlay networks. The ability to easily reconfigure the network is particularly important for peer-to-peer systems, which require highly dynamic structures. While it is theoretically possible to implement a P2P protocol at the physical network level, doing so is complex and resource-intensive, whereas deploying it as an overlay network is simpler, faster, and more practical. An overlay network can also be implemented on top of a network that is itself an overlay network, such as the Lightning Network, which is on top of the Bitcoin network (itself on top of IP).

#definition(title: "Overlay Network")[
  An overlay network is a logical computer network that is layered on top of a physical network, where nodes establish virtual links that may not correspond to direct physical connections, enabling flexible routing, topology management, and distributed services. It is assumed that each participant in the network has a unique identifier (such as an IP address) and that it is sufficient to know the identifier of another node in order to contact it (send it a message).
] <def:overlay-network>

#example[
  The Bitcoin network, which operates as a peer-to-peer protocol for decentralized transaction propagation, functions as an overlay network on top of the physical IP network.
]

Generally, a node in a network does not have knowledge of all other nodes, as storing all identifiers could require a large amount of memory and may be infeasible in dynamic networks where nodes frequently join or leave. In client-server architectures, each client knows only the server, which is sufficient for it to participate in the network. In contrast, peer-to-peer overlay networks rely on nodes maintaining a partial view of the network, containing a small subset of nodes. These partial views form the basis of the overlay topology and determine how nodes discover resources, route messages, and maintain connectivity in the network.

#definition(title: "Partial View")[
  A partial view of a network is the subset of participants known by a given node. It consists of a list of node identifiers, typically of limited size, representing only a fraction of the entire network.
] <def:partial-view>

#example[
  In Bitcoin, even if the size of the network is more than 10 000 nodes, each node typically knows only about a hundred addresses, some of which are obtained by contacting a peer discovery service (DNS seed) that provides the initial addresses to connect to.
]

=== Graph theory

In order to study overlay networks, it is useful to adopt a mathematical representation that allows formalizing and comparing their properties. Graph theory provides a natural framework for this purpose. A network can be represented as a graph, where nodes correspond to servers or users, and edges represent connections between them. Depending on the nature of the connections, a network can be modeled as either undirected or directed: bidirectional connections (e.g., TCP connections) are naturally represented by undirected edges, while unidirectional connections (e.g., UDP connections) are better captured by directed edges. In overlay networks, edges do not correspond to direct physical connections, but rather to a node's virtual view of the network—that is, the subset of nodes that each node is aware of.
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
  
] <def:graph>

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

=== Topology
Network topology refers to the structural organization of a network, that is, the way nodes are interconnected and how links are arranged between them. In the context of overlay networks, topology is naturally described through the shape of the underlying graph, where nodes represent participants and edges represent logical connections. Different topologies lead to fundamentally different properties in terms of connectivity, robustness, routing efficiency, and scalability. Broadly, network topologies can be divided into two categories: deterministic and random. Deterministic topologies are defined by explicit construction rules that impose a fixed structure on the graph, such as stars, rings, trees, or meshes, where the presence of an edge is fully determined by the position or role of each node. In contrast, random topologies are generated according to probabilistic rules, where edges are created based on random processes or statistical constraints rather than fixed patterns. This category includes classical random graphs, as well as more advanced models from complex network theory such as small-world networks, power-law networks, and stochastic block models, which introduce community structure through probabilistic connection patterns. Random topologies are particularly relevant for modeling large-scale and dynamic peer-to-peer systems, where global coordination is impractical and network structure often emerges from local interactions.

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

==== Random-graph

==== Small world

==== Power-law

==== Stochastic block model

=== Overlay management

==== Structured network

==== Unstructured network

=== Dynamic Networks

==== Failures

==== Churn

=== Security

=== Metrics

== Structured vs Unstructured Networks

#grid(
  columns: (1fr, 1fr),
[#figure(
diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0),"Peer", name: "1", radius: 2em)
edge(label("5"), "-", stroke: 1pt)
edge(label("2"), "-", stroke: 1pt)
node((0.3,1),"Peer", name: "2", radius: 2em)
edge(label("5"), "-", stroke: 1pt)
edge(label("3"), "-", stroke: 1pt)
node((1,1.5),"Peer", name: "3", radius: 2em)
node((1.8,1),"Peer", name: "4", radius: 2em)
edge(label("5"), "-", stroke: 1pt)
node((1.8,0),"Peer", name: "5", radius: 2em)
}),
  caption: [An unstructured network.],
) <p2p-unstructured>],
[#figure(
diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0),"Peer", name: "1", radius: 2em)
edge( "-", stroke: 1pt)
node((0.8,0.3),"Peer", name: "2", radius: 2em)
edge( "-", stroke: 1pt)
node((0.8,1.2),"Peer", name: "3", radius: 2em)
edge( "-", stroke: 1pt)
node((0,1.5),"Peer", name: "4", radius: 2em)
edge( "-", stroke: 1pt)
node((-0.8,1.2),"Peer", name: "6", radius: 2em)
edge( "-", stroke: 1pt)
node((-0.8,0.3),"Peer", name: "6", radius: 2em)
edge(label("1"),"-", stroke: 1pt)

}),
  caption: [A structured network (ring).],
) <p2p-structured>]
)


Peer-to-peer networks can be broadly divided into two categories: structured and unstructured networks. 
As their name suggests, structured networks rely on a predefined and strictly enforced organization of the network topology. 
This organization is dictated by a protocol that constrains how nodes join, connect, and interact within the system.

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

Another well-known protocol for building structured peer-to-peer networks is Pastry@rowstron2001pastry. 
In Pastry, each node is assigned a random identifier, called a _nodeId_, from a large identifier space. 
Each node maintains several data structures to support efficient and robust routing, including a _routing table_ organized by shared identifier prefixes, a _leaf set_ containing nodes with numerically closest nodeIds, and a _neighborhood set_ composed of nodes that are close in terms of network proximity. When a node issues a request for a given key, the message is forwarded to nodes whose nodeIds share progressively longer prefixes with the key, until it reaches the node responsible for that key. 
This prefix-based routing strategy enables efficient lookup operations while exploiting network locality. Pastry is resilient to node failures, as it dynamically repairs its routing structures in response to node joins and departures.


Kademlia @maymounkov2002kademlia is a widely used DHT protocol, notably employed by BitTorrent, as we have seen before. As in Pastry, each node in Kademlia is assigned a random identifier (nodeId) from a large identifier space. Kademlia defines a distance between identifiers using the XOR metric, which induces a logical tree-like structure over the identifier space.

Each node maintains a routing table composed of multiple _k-buckets_, where each bucket stores up to $k$ node contacts whose identifiers fall within a specific range of XOR distances from the local node. When a node performs a lookup for a given key, it computes the XOR distance between the key and known node identifiers, and iteratively queries the nodes that are closest to the target key. This process is repeated until the node responsible for the key is reached. 
Kademlia supports parallel and iterative lookups, which improves robustness and resilience to node failures. 

Not all structured networks are based on DHTs. For example, Tiara @clouser2012tiara is a structured overlay network that maintains a deterministic topology based on skip lists and skip graphs. Unlike DHTs, Tiara does not rely on consistent hashing to map keys to nodes or objects; instead, nodes are totally ordered according to their identifiers and connected following strict structural rules. A skip list is a layered linked structure where each node maintains forward pointers at multiple levels, allowing searches to be performed in logarithmic time by progressively skipping over nodes. A skip graph generalizes this idea to a distributed setting by organizing nodes into multiple overlapping ordered lists, which improves fault tolerance and connectivity. Tiara combines these concepts with self-stabilization mechanisms, ensuring that the overlay converges deterministically to the desired structured topology even in the presence of transient faults or churn.

While structured networks, and in particular Kademlia, have been widely adopted in peer-to-peer systems for their scalability and efficient lookup guarantees, they exhibit limitations in highly dynamic environments. 
Under extreme churn, the continuous maintenance of routing tables, neighbor sets, and replicated data can introduce significant overhead and may temporarily compromise routing consistency. 
These challenges have motivated the exploration of alternative designs based on unstructured peer-to-peer networks. 
Unlike structured systems, unstructured networks do not impose a predefined topology or DHT-based organization; instead, nodes establish and maintain connections in an ad-hoc fashion or rely on peer-sampling services to dynamically discover peers, favoring resilience and adaptability over deterministic lookup guarantees.

// Unstructured peer-to-peer (P2P) networks constitute an alternative to structured overlay networks when flexibility and robustness under highly dynamic conditions are prioritized over strict lookup guarantees. 
// In contrast to structured P2P systems, unstructured networks do not impose a predefined topology or a global data placement scheme such as a Distributed Hash Table. Instead, nodes maintain a partial and dynamic view of the network, establishing connections in an ad-hoc manner or through lightweight auxiliary services.

Because of the absence of a global structure, unstructured P2P networks rely on a set of fundamental services to ensure connectivity, information dissemination, and resource discovery.
A core component of such systems is the _peer sampling service_, whose role is to provide each node with a continuously refreshed, quasi-random subset of peers. This service is essential to preserve network connectivity, avoid topological bias, and prevent partitioning, especially in the presence of churn.

In addition to peer sampling, unstructured P2P networks typically require several complementary services. _Membership management_ mechanisms are used to handle node arrivals and departures, ensuring that local neighbor sets remain up-to-date. _Neighbor selection and topology management_ strategies may be employed to shape the overlay according to specific objectives, such as latency reduction or load balancing.
Furthermore, _information dissemination services_, often based on gossip or epidemic protocols, enable efficient broadcast, aggregation, and synchronization of state across the network. Finally, _resource discovery_ in unstructured networks generally relies on probabilistic techniques such as flooding, random walks, or gossip-based search, trading deterministic guarantees for scalability and resilience. Together, these services allow unstructured peer-to-peer networks to operate efficiently in highly dynamic and decentralized environments, making them particularly suitable for large-scale systems where strict structural maintenance would be costly or impractical.
As part of our work, we focus on the peer sampling service, which constitutes a fundamental building block of unstructured peer-to-peer systems. 

== Peer sampling

A peer sampling service provides each node with addresses of other nodes in the network, thereby enabling communication and maintaining connectivity. Indeed, it is often impractical or impossible for a node to store the addresses of all other nodes in the network in memory, particularly in peer-to-peer networks, which can often contain several hundred thousand nodes. Furthermore, these nodes do not necessarily remain connected all the time, and the number of nodes in the network fluctuates constantly. Each node will therefore only maintain a limited number of addresses of other nodes in the network, known as the partial view or neighbor list of each node. There is therefore a need for a service that allows us to connect to other nodes in the network, particularly given the risk that all our neighbors may be disconnected and that we may thus find ourselves disconnected from the network due to a lack of neighbors with whom to communicate.
Typically, the objective of a peer sampling service is to supply node addresses that are as random and uniformly distributed as possible, so as to avoid structural bias and network partitioning.

Conceptually, a peer sampling service exposes a minimal interface composed of two main functions.
An initialization function, _init()_, initializes the service at the node level, while a function _getPeer()_ returns the address of another node in the network.

Peer sampling services can be implemented in a centralized manner, where a central entity maintains knowledge of all participating nodes  and responds to sampling requests. 
While such an approach is simple, it suffers from scalability limitations and introduces a single point of failure.
Alternatively, peer sampling can be implemented in a fully decentralized way, where nodes continuously exchange and update peer information using only local interactions.
Decentralized peer sampling services are more scalable and allow the construction of fully decentralized peer-to-peer systems that don't need to rely on a centralized service.

// need to cite litterature about peer sampling service
// give examples in details 
Among the earliest decentralized protocols addressing membership management and peer sampling in large-scale distributed systems is Lightweight Probabilistic Broadcast (lpbcast), proposed by Eugster et al. @eugster2003lightweight. Lpbcast is a gossip-based publish/subscribe protocol designed to disseminate membership information and application events in highly dynamic and unstructured peer-to-peer environments. In this protocol, each node periodically exchanges gossip messages with a subset of peers selected from its local partial view. These messages encapsulate subscriptions, unsubscriptions, and published events, allowing nodes to progressively build and maintain a probabilistic view of the system. To ensure bounded resource consumption, lpbcast relies on fixed-size buffers to store received messages. When these buffers become full, messages are discarded using a probabilistic eviction strategy, favoring the removal of stale or redundant information while preserving dissemination efficiency. Node joins are handled through subscription messages initially sent to a single node and subsequently propagated through gossip; with high probability, these messages eventually reach all active nodes. Unsubscriptions follow a similar dissemination process but include timestamps to prevent outdated leave information from persisting indefinitely in the network. A key aspect of lpbcast is its peer weighting mechanism, which assigns weights to known peers based on the frequency of received notifications. Peers with higher weights are more likely to be removed from local views, a strategy that promotes peer diversity and prevents topological convergence, thereby reducing the risk of network partitioning under churn. The protocol offers probabilistic delivery guarantees rather than deterministic reliability, trading strict consistency for improved scalability, fault tolerance, and adaptability to dynamic membership. The authors provide a theoretical analysis of message dissemination time and partition probability, demonstrating that lpbcast achieves rapid and reliable propagation with limited overhead. Experimental evaluation combines simulations with real-world deployments conducted on two local-area networks composed of 60 and 65 SUN Ultra 10 workstations, respectively, interconnected via Fast Ethernet. Experiments involving up to 125 concurrent processes, each publishing 40 events per gossip round, confirm the protocol’s ability to scale while maintaining acceptable latency and network load.

The paper @montresor2003toward proposes an early conceptual framework for building distributed systems that are self-organizing, self-repairing, and resilient, drawing strong inspiration from complex adaptive systems and biological metaphors such as ant colonies. Rather than focusing on a single protocol, the authors advocate a system-level approach in which global behavior emerges from simple local interactions between autonomous agents. This vision is materialized through the Anthill project, whose objective is to provide a generic framework for the design and deployment of peer-to-peer applications built as swarms of agents. In Anthill, agents interact with and modify a shared environment, enabling adaptive behaviors such as dynamic reconfiguration, fault tolerance, and recovery from failures without centralized control. The framework also serves as an experimental platform for studying the fundamental properties of CAS-based peer-to-peer systems, allowing researchers to evaluate scalability, robustness, and performance under dynamic conditions such as churn. This work laid important conceptual foundations for later gossip- and epidemic-based protocols by emphasizing emergence, decentralization, and adaptability as first-class design principles in large-scale distributed systems.


Astrolabe, introduced by van Renesse et al. @van2003astrolabe, is a distributed information management system designed to support scalable monitoring, management, and data mining in large-scale distributed environments. Unlike fully decentralized peer-to-peer systems, Astrolabe relies on a hierarchical zoning architecture in which nodes are organized into nested zones forming a tree rooted at a global root zone. Each zone elects one or more designated routers responsible for aggregating and propagating information between hierarchical levels. While Astrolabe employs epidemic gossip protocols for information dissemination within and across zones, the presence of explicitly defined zones and routing roles makes the system fundamentally hierarchical rather than purely peer-to-peer. Within each zone, nodes periodically exchange state information using gossip, while inter-zone communication follows the hierarchy, with updates being propagated toward the least common ancestor zone and aggregated along the way. Each node maintains a peer list of logarithmic size relative to the system, ensuring scalability. Security is enforced through the use of public-key certificates, allowing authenticated communication and administrative control. Although Astrolabe avoids centralized servers, it is not fully decentralized: the hierarchical topology is manually configured, and system administrators are able to maintain a global view of the system state. The protocol was evaluated through simulations and experimentally deployed on the Emulab testbed with up to 126 agents running on 63 hosts, demonstrating the scalability and robustness of hierarchical gossip-based aggregation.

In contrast to hierarchical approaches, Ganesh, Kermarrec, and Massoulié introduced SCAMP @ganesh2003peer, one of the first fully decentralized peer-to-peer membership protocols designed for large-scale gossip-based systems. SCAMP abandons the assumption that nodes have access to a global membership list or even to the total number of participants, assumptions that are unrealistic in the presence of churn. Instead, each node maintains a partial view of the network, whose size remains logarithmic in the number of nodes, ensuring scalability and robustness. SCAMP relies on epidemic dissemination to propagate membership information and guarantees, with high probability, the strong atomicity property, meaning that a broadcast message eventually reaches all nodes. More precisely, if each node gossips to $log(n) + k$ peers on average, the probability of complete dissemination converges asymptotically to $e^(-e^-k)$. Membership dynamics are handled through explicit join and leave procedures. When a node joins the system, its identifier is disseminated through controlled random walks, and recipient nodes probabilistically decide whether to include it in their partial view, allowing the overlay to self-balance without any global coordination. Each node maintains both a partial view, representing its outgoing neighbor references, and an in-view list, corresponding to incoming references from other nodes. This distinction is exploited during graceful departures: when a node leaves, it informs its neighbors, which replace its identifier using the entries contained in its in-view list, preserving the desired average degree of the overlay. To cope with failures and churn, SCAMP incorporates heartbeat-based failure detection, lease mechanisms that periodically expire neighbor relationships, and re-subscription procedures for isolated nodes. An indirection mechanism with decreasing tokens further prevents overload and contributes to maintaining balanced partial views.

Araneola @melamed2004araneola is a multicast system designed to provide scalable and reliable message dissemination in dynamic network environments. Unlike fully connected overlays, Araneola maintains a sparse undirected network in which each node has either K or K+1 neighbors, forming a K-connected graph that ensures resilience to node failures. Membership information is exchanged infrequently, primarily to integrate new nodes or perform maintenance, which reduces overhead and improves scalability. By carefully structuring the network and limiting the number of connections per node, Araneola achieves reliable multicast delivery while remaining efficient in highly dynamic conditions.

Stavrou et al. introduced PROOFS @stavrou2004lightweight (P2P Randomized Overlays to Obviate Flash-crowd Symptoms), a lightweight protocol designed to cope with Internet flash crowds and sudden surges in demand for data in a network. PROOFS relies on the construction and continuous maintenance of a random overlay network through a shuffling mechanism, combined with a random-walk-based object lookup protocol. The authors provide theoretical guarantees showing that the resulting directed overlay exhibits strong resilience properties, including the ability to self-heal to avoid network partitions, ensuring eventual connectivity despite churn and failures. The shuffle operation consists of a periodic exchange of partial neighbor views between pairs of randomly selected peers: Each node stores a local peer list, called a *cache*, of fixed size $c$. Periodically, every $Delta$ time units, a node initiates a *shuffle operation* to refresh its view. The node first selects a random subset of $l$ peers from its cache and randomly chooses one peer $q$ from this subset as the shuffle partner. 
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

Jelasity et al. (2004) @jelasity2004peer proposed a generic framework for implementing gossip-based peer sampling services. The protocol relies on only two core functions: init() to initialize the service and getPeer() to retrieve a peer address. The authors analyze peer sampling protocols along three dimensions: (i) peer selection — random, head (most recently added), or tail (oldest node), (ii) view propagation — push, pull, or push-pull, and (iii) view selection — random, head, or tail. These dimensions yield 27 possible combinations, including lpbcast @eugster2003lightweight (rand, rand, push) and Newscast @jelasity2003newscast (rand, head, push-pull). A good peer sampling service should satisfy several properties: a uniform degree distribution to avoid hubs, a short average path length for scalability, and a moderate clustering coefficient to reduce message redundancy. Experimental results show that some combinations have limitations: (head, any, any) tends to create a highly clustered network, (any, tail, any) is poorly resilient under dynamic node joins and leaves, and (any, any, pull) converges to a star topology. In contrast, protocols (any, rand, pushpull) provide the closest approximation to a random topology in terms of average path length and clustering coefficient, while (rand, head, any) produces a degree distribution close to uniform. Overall, the resulting topologies exhibit small-world properties, ensuring both connectivity and resilience in unstructured networks.

In their extended work, Jelasity et al @jelasity2007gossip proposed a refined gossip-based peer sampling protocol (called Newscast) along with a framework for systematic evaluation. During each exchange, the active thread selects a peer from the local peer list, sends a buffer containing half of its freshest entries (and optionally its own address), receives a buffer from the remote peer if pull is enabled, and updates its peer list by combining entries from both buffers while removing duplicates and old items, maintaining a fixed cache size. In @Newscast-algorithm and @Newscast-algorithm-passive we provide the pseudocodes for the Newscast protocol. The protocol introduces two tunable parameters: H, the self-healing parameter controlling the removal of stale links, and S, the swap parameter prioritizing entries received from the remote peer. These parameters define a triangular design space with three archetypes: blind (H=0, S=0), maintaining the same subset; healer (H=c/2), keeping the freshest entries; and swapper (H=0, S=c/2), maximizing swaps. Experimental results show that a push-pull approach outperforms push-only or pull-only strategies, which are prone to partitioning or star-like topologies. Furthermore, robustness against churn is enhanced by dropping old entries in the peer list, although a tradeoff exists between load balancing and churn resilience. 

#figure(
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

#figure(
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

The paper *Correctness of a Gossip-Based Membership Protocol* @allavena2005correctness proposes a peer-sampling protocol in which each node executes the algorithm periodically and independently in an asynchronous manner. At each round, a node i first builds a list L1 by collecting the local views of f peers selected uniformly at random from its current peer list. In parallel, it constructs a second list L2 containing the identities of all nodes that have contacted i during the current round to request its peer list. The node then updates its peer list by randomly selecting k nodes from the union of L1 and L2, where a weighting parameter $omega$ biases the selection toward entries from L2 relative to L1. New nodes join the system by initially contacting a bootstrap server. The authors provide formal correctness proofs showing that the protocol has a very low probability of network partitioning and that, despite churn due to node joins and leaves, the overlay converges with high probability to a random graph topology.

Among the protocols that have contributed to the state of the art, we also have Cyclon @voulgaris2005cyclon. The paper that presents the Cyclon protocol defines a lightweight gossip-based membership protocol designed to maintain random unstructured overlays at low cost. The authors first recall the PROOFS protocol @stavrou2004lightweight, where peers periodically exchange subsets of their neighbor lists. CYCLON improves upon this approach by associating an age value with each neighbor entry and by always initiating the shuffle with the oldest known peer, which accelerates the removal of stale links and improves robustness under churn. Experimental results show that the resulting overlay converges to the properties of a random graph rather than a small-world topology: the average path length remains very small, while the clustering coefficient decreases exponentially as the network size grows. To support efficient node joins while preserving randomness, a new peer contacts an introducer node and sends c shuffle messages that perform random walks in the overlay. Each of the c nodes reached by these messages replies with one of its neighbors and replaces that neighbor with the address of the joining peer. This join procedure allows newcomers to rapidly acquire a random peer list without disrupting the overall randomness of the network.

Another interesting approach is the paper Massoulié et al @massoulie2006peer. The main contribution of the work is to show that random walk mechanisms can be used both to estimate global properties of the network and to obtain unbiased peer samples, without requiring global knowledge or structured overlays. The authors first propose the Random Tour method to estimate the size of a peer-to-peer network. In this approach, a counter is forwarded along a random walk and incremented at each visited node by a value proportional to φ(i)/d(i), where d(i) is the node degree and φ(i) is a function of interest (the identity function when estimating network size). When the counter returns to the initiator, it is scaled by the initiator’s degree to obtain an unbiased estimate of the network size. The accuracy of this estimate is shown to depend on the spectral gap of the overlay graph, highlighting the importance of good expansion properties. The paper then introduces Sample and Collide, a second technique based on Continuous Time Random Walks (CTRW), whose key novelty is to provide unbiased peer sampling. In this method, a value T is propagated through the network and decremented at each hop by a random amount derived from an exponential distribution parameterized by the node degree. When T reaches zero, the current node reports its identifier to the initiator. By collecting multiple such samples and stopping when repeated samples occur, the initiator can estimate the network size using maximum likelihood estimation. Experimental results demonstrate that Sample and Collide is robust under churn, reinforcing the paper’s central message that random walk–based methods can be used for decentralized measurement and sampling in dynamic overlay networks.

In @terelius2018peer, the authors address the problem of efficiently disseminating a data stream from a small set of seed nodes to all other participants in a peer-to-peer network subject to churn. The authors propose a distributed protocol that incrementally constructs a so-called gradient topology, starting from an initially random overlay. In this topology, nodes are organized according to a utility function that captures their performance characteristics, such as bandwidth or forwarding capacity, with higher-utility nodes positioned closer to the seed nodes that act as data sources. Each node locally adapts its set of neighbors in order to maximize its own utility, which indirectly improves the global efficiency of data dissemination by favoring high-capacity paths near the sources. The paper provides a formal analysis of the protocol using Markov chain techniques, proving convergence toward the desired gradient graph, characterizing the expected convergence time, and showing that the topology can re-converge efficiently even in the presence of churn.

HyParView @leitao2007hyparview is a membership protocol designed to support reliable gossip-based broadcast in large and dynamic networks. Each node maintains two views: an active view consisting of established TCP connections used for message dissemination, and a passive view that contains additional nodes that can replace failed members of the active view. The passive view is maintained using a cyclic strategy, where each node periodically performs a shuffle operation with a randomly selected node to update and refresh its list. This dual-view structure allows HyParView to provide both reliability and resilience to node failures while keeping the network overhead low. HyParView is used as the membership protocol of some frameworks to build distributed networks, like Partisan @meiklejohn2019partisan.

X-BOT @leitao2009x is an evolution of the HyParView protocol, developed by the same authors, designed to optimize unstructured overlay networks while preserving resilience. Like HyParView, each node maintains an active and a passive view to support reliable gossip-based communication. The main innovation in X-BOT is the introduction of a local “oracle” that evaluates the quality of the node’s connections according to a given criterion, such as network latency or other performance metrics. Each node iteratively adjusts its connections to maximize the oracle’s score, using only local information, until the overlay topology is optimized. This approach allows X-BOT to adapt the network structure to improve efficiency and performance while retaining the fault tolerance and low overhead properties of the original HyParView protocol.

Readers who wish to explore gossip networks in more depth can refer to this survey @montresor2017gossip, which not only explains the mechanics of peer sampling in gossip systems but also addresses broader topics such as information dissemination, epidemic modeling, and aggregation techniques.

// == Topology
// === Random graph
// Gossip and Epidemic Protocols
// Alberto Montresor

All the previously discussed protocols primarily aim at constructing random k-out graph topologies, in which each node maintains approximately k outgoing links and the distribution of incoming degrees follows a binomial law centered around k. Such topologies are known for their strong resilience to node crashes and churn: even when a large fraction of nodes fail or leave the system, the overlay graph remains connected with high probability. However, this robustness comes at a cost in terms of performance. In particular, information dissemination may be suboptimal, and some nodes can experience relatively high incoming degrees, leading to increased load. In contrast, alternative overlay structures introduce heterogeneity in the distribution of incoming degrees. These include power-law networks, where the degree distribution follows an exponential or heavy-tailed law, and scale-free networks, whose structure scales with the number of nodes in a self-similar manner. Although such topologies are generally less resilient to failures and churn, they often provide better performance for information dissemination, as highly connected nodes act as hubs that can rapidly spread information throughout the network.

=== Power-law networks

// Gia
Gia @chawathe2003making is an unstructured peer-to-peer overlay designed to address the scalability limitations of early Gnutella-like systems by explicitly accounting for heterogeneity in node capacities. Unlike structured overlays or DHT-based systems, Gia preserves the flexibility and robustness of unstructured networks while introducing mechanisms that significantly improve query efficiency and load management. The system is built around the notion of supernodes, although this role is not statically assigned: instead, nodes with higher capacity naturally emerge as better connected and more central in the overlay.

A key observation underlying Gia is that the effective capacity of a peer is multidimensional and depends on several factors, including processing power, disk access latency, and, most importantly, available network bandwidth. Traditional unstructured overlays treat all nodes uniformly, which leads to severe bottlenecks when low-capacity nodes become transit points for large volumes of queries. Gia addresses this issue through a combination of dynamic topology adaptation and explicit flow control.

The topology adaptation protocol continuously reshapes the overlay so that most nodes remain within a small number of hops from high-capacity peers. Each node independently evaluates its local connectivity using a satisfaction metric S, defined as a value in the interval [0,1]. This metric captures how well a node’s current neighbors meet its performance expectations in terms of query handling and forwarding capacity. When a node’s satisfaction level is below one, it actively seeks better neighbors, typically favoring peers with higher advertised capacity. This process continues until the node reaches a stable configuration in which its satisfaction is maximized, leading to a topology where high-degree nodes are also those most capable of sustaining heavy query loads.

To prevent overload and ensure fair utilization of resources, Gia introduces a token-based flow control mechanism. Nodes periodically distribute flow-control tokens to their neighbors, where each token authorizes the transmission of a single query. A node may only forward a query to a neighbor if it holds a valid token from that neighbor, effectively bounding the rate at which any node can receive queries. Token allocation is aligned with the node’s processing capacity: nodes issue tokens at a rate proportional to the number of queries they can handle. If a node experiences congestion, either due to excessive incoming queries or insufficient tokens from its neighbors, it temporarily queues excess queries and adapts by reducing its token distribution rate, thereby throttling incoming traffic.

An important aspect of Gia’s design is the incentive mechanism for truthful capacity advertisement. Rather than distributing tokens uniformly among neighbors, nodes allocate tokens in proportion to their neighbors’ advertised capacities. As a result, nodes that declare higher capacity receive more tokens for issuing their own queries, directly benefiting from honest reporting. This feedback loop encourages high-capacity nodes to expose their true capabilities, reinforcing the formation of a topology where connectivity and load are aligned with available resources.

The paper @montresor2004robust introduces SG-1, a gossip-based protocol designed to construct and maintain superpeer overlay networks in a fully decentralized and adaptive manner. The core idea is to let nodes periodically exchange local state information with randomly selected peers, including their role (client or superpeer) and their current load. Based solely on this local knowledge, nodes can autonomously change roles or reassign clients in order to balance load and reduce the overall number of superpeers. As a result, the system converges toward a configuration in which each client is attached to exactly one superpeer, superpeers are interconnected through an approximately random overlay, and the set of superpeers is close to minimal with respect to the aggregate capacity required to serve all clients.

A key design choice of SG-1 is to build the superpeer topology as an additional overlay extracted from an existing connected network, rather than replacing the underlying topology. Any protocol capable of maintaining connectivity can be used for this base layer; in the paper, a gossip-based peer sampling protocol is employed to provide an approximately random connected graph. This layered approach significantly improves robustness, as it allows the system to recover even if a large fraction of superpeers fail simultaneously. In such cases, affected clients can temporarily promote themselves to superpeers, after which the gossip process gradually selects a new, balanced set of superpeers among the remaining nodes.

The protocol is shown to be highly efficient, with a total message overhead that scales linearly with network size and without concentrating excessive load on any single node. Moreover, the time needed to reach a near-optimal superpeer configuration is constant with respect to the number of nodes, while convergence to an optimal configuration grows only logarithmically. Experimental results indicate fast convergence in practice and show that the resulting superpeer topology exhibits heterogeneous connectivity patterns resembling power-law networks, combining scalability with robustness under churn and failures.

// Phenix
Phenix @wouhaybi2004phenix is a peer sampling protocol designed to construct and maintain resilient, low-diameter peer-to-peer topologies while preserving scalability under churn and adversarial conditions. The protocol is motivated by the observation that low-diameter networks exhibit an average shortest-path length of $O(log n)$, enabling efficient information dissemination at scale. While unstructured peer-to-peer networks are generally resilient to churn and crashes, they often suffer from limited performance, whereas structured overlays provide better performance at the cost of reduced robustness. Phenix aims to reconcile these trade-offs by introducing heterogeneous connectivity patterns inspired by real-world networks.

Unlike approaches based on homogeneous random graph topologies, Phenix explicitly constructs power-law degree distributions, where the probability that a node has degree $K$ follows $p(K) ~ K^(-γ)$. The parameter $γ$ controls the level of heterogeneity and is empirically close to 2.2 for the Internet topology. This results in the natural emergence of a small number of highly connected nodes, or hubs, which significantly reduce the network diameter and improve information dissemination. Importantly, Phenix is among the first peer-to-peer topology construction protocols to explicitly consider resilience against targeted attacks that aim to remove highly connected nodes in order to fragment the network.

When a node i joins the network, it first obtains a list of peer addresses either by contacting a host cache server or by using a locally stored cache from a previous session. This list is then divided into two subsets: random_nodes and friends_nodes. Node i sends a ping message with a time-to-live (TTL) of 1 to all nodes in the friends_nodes set. Each of these nodes replies by sending its own neighbor list to node i and forwards the ping message to its neighbors while decrementing the TTL and incrementing a hop counter. All nodes that receive this message, corresponding to friends-of-friends, temporarily store node i in a list called gamma for a duration tau, which serves as a protection mechanism against crawling attacks.

Node i aggregates all received neighbor lists into a set of candidate_nodes and ranks them according to their frequency of occurrence. Nodes that appear most frequently are selected as preferred_nodes, reflecting their higher structural importance in the local topology. Node i then establishes connections with nodes in both the random_nodes and preferred_nodes sets. When a node m receives a connection request from node i, it creates a backward connection to node i only if node i appears in its gamma list and if the backward connection counter remains below a threshold that bounds the maximum number of backward connections as a function of the node’s incoming degree. This constraint prevents excessive hub formation while preserving the desired power-law structure.

If node i receives a backward connection from a node m, it removes m from the preferred_nodes list and adds it to a highly_preferred_nodes list. The final peer view maintained by node i thus consists of random_nodes, preferred_nodes, highly_preferred_nodes, and backward connections, collectively enforcing a heterogeneous topology with low diameter. In @Phenix-algorithm and @Phenix-background-algorithm, we give the pseudocode of the algorithm used when a node enters the network, constructing its cache with *random* and *preferred* nodes, and the pseudocode of the background thread.

To protect the network from malicious behavior, Phenix incorporates several defensive mechanisms. Nodes attempting to crawl the network are detected and blacklisted. Backward connection lists are never shared, protecting highly connected nodes from being explicitly identified. Additionally, when a node detects that its number of connections has dropped below a predefined threshold, as may occur after a targeted attack, it enters a maintenance mode in which it temporarily favors the selection of preferred nodes over random nodes to rapidly restore connectivity.

The protocol considers multiple adversarial strategies, including attackers that form tightly connected subgraphs to artificially increase their likelihood of becoming preferred nodes, as well as attackers that behave honestly before simultaneously disconnecting to induce network fragmentation. Simulation results show that Phenix significantly outperforms random topologies in terms of resilience: even with 30% malicious nodes, approximately 70% of the network remains connected after an attack.

Phenix was implemented and evaluated on a real PlanetLab testbed composed of 81 nodes distributed across 43 sites in eight countries. Experimental results confirm the emergence of a heterogeneous degree distribution, with most nodes maintaining between three and four connections and a small number of nodes acting as hubs with significantly higher degrees, reaching up to 18 connections. When these highly connected nodes were deliberately shut down, the network recovered to a stable state in less than one second, demonstrating strong resilience to targeted failures.

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

The paper @wakamiya2005toward explores the concept of overlay network symbiosis, focusing on the interactions and connections between multiple coexisting overlay networks. Rather than addressing a single overlay in isolation, the authors investigate mechanisms for inter-overlay connectivity, aiming to improve overall efficiency, resource utilization, and resilience across different networks.

LLR @sasabe2006llr is a peer-to-peer network construction scheme designed to achieve low diameter, location awareness, and resilience. Nodes join the network individually, obtaining an initial peer list from a bootstrap server. Each node measures physical proximity to its peers using hop counts on the underlying Internet topology and selects the closest peers to form its neighbor set. A preferential attachment mechanism is then applied among these nearby nodes to strengthen connectivity. The protocol also includes a rewiring procedure, allowing nodes to replace distant connections with closer ones while maintaining the preferential connectivity. LLR is explicitly designed to handle churn and potential Byzantine behaviors, and its evaluation relies on topological data from real-world networks such as Abilene and Sprint. No simulation results are reported, but the design emphasizes physical proximity and robustness in dynamic network conditions.

The paper @vishnumurthy2006heterogeneous addresses the construction of heterogeneous unstructured overlay networks and the efficient selection of random nodes within them. The authors propose practical algorithms that adapt the number of outgoing links a node establishes based on its capacity, allowing high-capacity nodes to maintain more connections and thus achieve heterogeneity in the network. New nodes joining the network require knowledge of at least one existing member, which can be facilitated by a well-known rendezvous node. A key contribution is the SwapLinks mechanism, designed to counteract the self-reinforcing effect where early or high-degree nodes accumulate disproportionately many inlinks. SwapLinks actively redistributes inlinks from high-degree nodes to lower-degree nodes, maintaining balance in the network. Additionally, the approach leverages biased random walks during the graph construction and node selection processes, ensuring that connectivity remains efficient while preserving resilience to churn. Simulations indicate that this methodology produces scalable and robust overlay networks suitable for dynamic environments.

The paper @xie2008scale introduces a simple generative model showing that scale-free networks can emerge without network growth. Starting from an arbitrary initial topology, such as a random graph, the network evolves solely through a rewiring process that preserves the total number of edges. At each time step, an existing edge is removed uniformly at random, and a new edge is created by selecting its two endpoints according to a preferential probability that depends on the current node degrees. This preferential rewiring favors high-degree nodes and leads the system toward a stationary equilibrium characterized by a scale-free degree distribution, independently of the initial topology. The model allows self-loops and multiple edges, which simplifies the analysis and highlights the underlying mechanism driving the emergence of heavy-tailed degree distributions. While conceptually important for understanding the origins of scale-free structures, the approach assumes global knowledge of node degrees to perform preferential selection, which limits its direct applicability in fully decentralized peer-to-peer systems.

The paper @brocco2009bounded proposes a self-organized overlay construction algorithm that aims at achieving a bounded network diameter without relying on hubs. Inspired by biological systems, the approach uses lightweight agents, referred to as “ants”, which are periodically sent by nodes to explore the network and collect topological information. Based on the feedback brought by these ants, nodes locally adapt their connections in order to reduce the overall diameter while avoiding highly connected central nodes. Although the construction process is distributed in spirit, the algorithm assumes global knowledge of the network topology to guide optimization decisions, and it relies on a master entity to enforce certain disconnection operations. As a result, the system achieves low-diameter overlays with balanced degrees, but at the cost of stronger assumptions that limit its applicability in fully decentralized and purely peer-to-peer environments.

The work @guclu2008limited investigates how to construct scale-free overlay networks for unstructured peer-to-peer systems while explicitly limiting the emergence of hubs. The network is assumed to grow incrementally, with nodes joining one at a time, and nodes are assumed to know the total network size. The key idea is to preserve the benefits of scale-free topologies while enforcing a hard cut-off on node degree, thereby preventing any node from accumulating an excessive number of connections. This degree cap applies to peer connections and ensures a bounded level of heterogeneity. As a reference, the paper also considers the Configuration Model to generate random networks with a prescribed degree distribution, although this approach requires global knowledge and is therefore not directly applicable in decentralized settings. To overcome this limitation, the authors propose two distributed algorithms that rely only on local information. The first, Hop-and-Attempt Preferential Attachment, builds connections by iteratively selecting neighbors of neighbors: a joining node first connects to a random node, then probabilistically attempts to connect to one of its peers, and repeats this process until its peer list is filled or the degree constraints are met. The second approach, Discover-and-Attempt Preferential Attachment, leverages information from the underlying physical network to discover candidate peers and apply a similar preferential attachment mechanism. Both algorithms approximate scale-free degree distributions under bounded degree constraints.

The work @eum2009self by Eum, Arakawa, and Murata proposes a self-organizing mechanism for constructing scale-free topologies in peer-to-peer networks, with the explicit goal of reconciling desirable structural properties of power-law graphs with the practical constraints of decentralized systems. Nodes are assumed to join the network incrementally, one after another, reflecting a realistic P2P setting. To enable the initial contact with the network, the authors assume the existence of a bootstrapping server whose sole role is to return identifiers of randomly selected peers already present in the overlay. This assumption is kept minimal and does not require the server to maintain or expose any global view of the topology. The proposed model is governed by two parameters that directly shape the resulting degree distribution. The first parameter, m, represents the number of links that a newly joining peer establishes upon arrival. The second parameter, α, controls the balance between random attachment and preferential attachment. More precisely, when a new peer seeks to establish a connection, the endpoint is chosen according to a mixed strategy: with probability α, the attachment is purely random, while with probability (1 − α), the attachment follows a preferential rule favoring already well-connected peers. By tuning α, the algorithm allows a fine-grained control over the resulting power-law exponent, enabling the construction of a wide range of scale-free topologies. A key contribution of this work lies in the fully decentralized realization of this mixed attachment process. Rather than requiring global knowledge of node degrees or network size, all decisions are delegated to existing peers. In practice, the joining peer N first contacts the bootstrapping server to obtain the identifiers of m randomly selected peers in the current overlay. For each such peer D, the joining node asks D to suggest an attachment target. Peer D then returns either its own identifier with probability α, or the identifier of one of its neighbors with probability (1 − α). The new peer finally connects to the peer whose identifier is returned. As a result, the preferential attachment effect emerges implicitly through local neighbor selection, without ever exposing degree information or global topology data to the joining node. This design choice has important robustness and security implications. Since the new peer does not observe the structure of the overlay and only follows connection decisions made by existing peers, the algorithm naturally limits the information available to a potentially malicious node. The authors argue that this property improves resilience against targeted attacks, as attackers cannot easily infer or exploit high-degree nodes. Moreover, the simplicity of the local rules makes the construction robust under churn: although node arrivals and departures slightly perturb the topology, the scale-free characteristics are largely preserved over time. Beyond topology construction, the paper evaluates the functional benefits of the resulting overlays. In particular, the authors demonstrate that the constructed scale-free networks improve search efficiency when using common P2P search mechanisms such as flooding and random walks. The presence of highly connected nodes accelerates query dissemination, while the adjustable attachment parameter α mitigates the well-known drawback of classical scale-free networks, namely the excessive load placed on a very small number of hubs.

Eum, Arakawa, and Murata extended their model by introducing an explicit topology transformation mechanism based on link rewiring @eum2010self. While the previous approach focused on the construction of scale-free structures during node arrivals, this follow-up study addresses a complementary problem: how to continuously reshape an existing peer-to-peer topology in a decentralized manner, without relying on node churn or global coordination. The central idea of the paper is to modify the degree distribution through local link relocation processes. Instead of adding or removing peers, the network periodically rewires existing connections according to simple probabilistic rules executed by peers with only neighborhood-level information. Two symmetric rewiring schemes are proposed, each favoring a different direction of degree redistribution. In the first scheme, a peer A is selected at random, one of its neighbors E is identified, and E relinquishes one of its links. This link is then reassigned to a randomly chosen peer G, whose degree is not known a priori. Since E is a neighbor of a randomly selected peer, it is statistically biased toward higher-degree nodes. Consequently, this mechanism effectively removes a link from a high-degree peer and transfers it to a randomly chosen peer, thereby reducing degree heterogeneity. The second rewiring scheme operates in the opposite direction. A randomly chosen peer A first drops one of its existing links, and this link is then reconnected to a high-degree peer B, again identified as a neighbor of a randomly selected peer. In this case, the process reinforces degree heterogeneity by moving a link from a randomly selected node toward a well-connected one. By alternating between these two schemes, the network can be driven toward different degree distributions, ranging from more homogeneous to more skewed structures. To control the balance between these two opposing effects, the authors introduce a probability parameter β. The first scheme, which shifts links away from high-degree peers, is applied with probability β, while the second scheme, which concentrates links on high-degree peers, is applied with probability (1 − β). By tuning β, the system can continuously adjust the shape of the degree distribution, enabling either the attenuation or the reinforcement of scale-free properties. This probabilistic combination provides a flexible and lightweight mechanism for topology adaptation. In addition to β, the rewiring process is constrained by explicit degree bounds. Two parameters, M and n, define the maximum and minimum number of connections a peer is allowed to maintain. During rewiring, a peer may refuse a connection request if its degree has reached M, or reject a disconnection if its degree is already at n. These bounds prevent pathological situations such as the emergence of overly dominant hubs or the isolation of poorly connected peers, and they further enhance stability under dynamic conditions.

In a follow-up work @eum2010self2, Eum, Arakawa, and Murata refine their previous self-organizing and self-transforming overlay models by introducing a probabilistic verification step that governs the acceptance of rewiring operations. Building on the 2010 topology transformation scheme, each candidate rewiring is evaluated according to an energy change that reflects how well the resulting topology matches the targeted power-law structure, and the new configuration is accepted with a probability p. This stochastic acceptance mechanism allows the overlay to progressively converge toward a power-law degree distribution while avoiding overly rigid transformations. The model assumes the existence of a mechanism to select random peers, abstracting away its concrete implementation. Unlike earlier studies that rely on churn, the network is considered static, and resilience is instead assessed by progressively removing nodes and measuring the collapse of the giant component. The resulting power-law topology exhibits a small diameter, improved search efficiency, and robustness against random failures, while remaining vulnerable to targeted attacks, and benefits from clustering properties that help preserve efficiency under node removals.

// T-MAN

T-MAN @jelasity2009t is a gossip-based protocol designed for fast and fully decentralized construction of overlay network topologies that approximate a desired target structure. The core idea of the protocol is to view topology management as a distributed ranking problem: each node maintains a preference ordering over other nodes according to some application-defined distance or ranking function, and attempts to connect to those that rank highest with respect to this function. Unlike static overlays, T-MAN continuously refines the topology through gossip exchanges, allowing it to adapt to dynamic environments.

In its most naive form, such a ranking problem could be solved by having each node broadcast its identifier to the entire network, collect the full list of nodes, and then locally sort them according to the ranking criterion. While this approach is conceptually simple, it is clearly not scalable. T-MAN replaces this global dissemination with an epidemic exchange of node descriptors, where each node periodically communicates with a small number of peers and incrementally improves its local view of the network.

A key contribution of T-MAN is that it generalizes the notion of distance beyond simple metrics such as identifier proximity. The ranking function can encode arbitrary criteria, including physical proximity, node capacity, or application-specific attributes. Each node locally ranks the descriptors it knows and retains those corresponding to the most preferred peers. Through repeated gossip exchanges, high-quality descriptors propagate quickly through the system, leading to rapid convergence toward the target topology.

The paper highlights an important design trade-off related to the choice of the ranking method. If the ranking is independent of the base node, meaning that all nodes use the same global ranking criterion, the protocol naturally induces a star-like or hub-centered topology. In this case, many nodes are attracted to the same high-ranking peers, which accelerates convergence because these central nodes are contacted frequently and can rapidly collect and redistribute high-quality descriptors.

VICINITY @voulgaris2013vicinity builds directly upon the principles introduced by T-MAN and can be seen as an explicit improvement of that approach, aimed at increasing robustness and convergence quality in dynamic environments. Like T-MAN, VICINITY addresses overlay topology construction as a distributed ranking problem, where each node seeks to connect to peers that are closest according to an application-defined distance function. The target topology thus emerges from local decisions driven by ranking and gossip-based exchanges.

The main limitation identified in T-MAN is its strong determinism: nodes always try to optimize their neighborhood strictly according to the ranking function. While this leads to fast convergence, it can also cause premature convergence to suboptimal local structures, sensitivity to churn, and excessive load on highly ranked nodes. VICINITY mitigates these issues by explicitly introducing controlled randomness into the neighbor selection process, striking a balance between deterministic optimization and random exploration.

To achieve this, VICINITY combines T-MAN-style ranking with mechanisms inspired by peer sampling protocols such as Cyclon. Each node maintains a neighborhood that is periodically refreshed using both structured exchanges and random peer samples. The use of Cyclon ensures that the overlay remains well mixed and that nodes continue to discover new peers, preventing the topology from becoming rigid or trapped in poor configurations. In addition, neighbor selection is performed in a round-robin fashion, which avoids repeatedly contacting the same peers and improves fairness in communication.

A key insight of the paper is that optimal performance is obtained by carefully balancing determinism and randomness. Experimental results show that allocating roughly half of the neighbor selection to ranking-based choices and half to random choices yields the best trade-off between convergence speed, stability, and robustness. Too much determinism reproduces the weaknesses of T-MAN, while too much randomness slows convergence and degrades the quality of the final topology.

UMM @ripeanu2010search is a self-organizing group communication overlay that combines a random base overlay with dynamically constructed, source-specific multicast dissemination trees. The base overlay is initialized as a random graph and is continuously refined using a local “short–long” heuristic that distinguishes latency-optimized short tunnels from bandwidth-optimized long tunnels, replacing existing connections only when measurable improvements exceed a stability threshold. This lower layer is responsible for bootstrapping, membership management, fault recovery, and connectivity maintenance, and is designed to be independent from higher-level dissemination mechanisms. Multicast trees are then implicitly extracted from the base overlay: new sources initially flood the network, and participating nodes locally suppress redundant or low-quality paths based on observed duplicate traffic. Membership information is maintained through an epidemic gossip mechanism that uniformly spreads random peer identifiers and supports scalable joins without requiring global knowledge, although a bootstrap node is used in practice. The system explicitly targets churn, and experimental results show very high delivery ratios even under aggressive failure rates, indicating that the separation between a resilient random base overlay and adaptive dissemination structures yields both robustness and efficiency.

The paper @bulut2013constructing addresses the problem of constructing *limited* scale-free overlays that closely follow a target power-law degree distribution while remaining practical and cost-efficient for peer-to-peer systems. The main contribution is the introduction of two parameterized growth algorithms, SRA and SDA, which allow the designer to explicitly control the desired scale-free exponent, thereby achieving a high adherence to scale-freeness without creating extreme hubs. Both approaches rely on incremental node addition and focus exclusively on link creation at join time, avoiding costly global rewiring operations. The Semi-Randomized Growth Algorithm (SRA) operates without global knowledge and uses randomized degree targets derived from the desired power-law distribution. A joining node samples target degree values, broadcasts a request, and connects to responding peers whose current degrees match these targets, relaxing the constraints toward nearby degree values when necessary. In contrast, the Semi-Deterministic Growth Algorithm (SDA) assumes knowledge of the total network size and deterministically computes the degree that each node should maintain to preserve the target distribution. Nodes advertising matching degrees respond to new peers, which then establish connections accordingly. While both algorithms can guarantee scale-free properties only for a bounded range of exponents and do not handle churn, they demonstrate that accurate and tunable power-law overlays can be constructed efficiently using join-time decisions alone.

The paper @armetta2014self proposes a self-organized peer-to-peer system aimed at improving data sharing efficiency by jointly adapting search mechanisms and the underlying overlay topology. Starting from an initially random and connected network, the approach leverages ant-inspired routing strategies to guide search operations, particularly targeting the efficient discovery of rare data items. Artificial ants explore the network and leave implicit feedback that helps bias future searches toward more promising regions of the overlay. Beyond routing alone, the system progressively reshapes the topology itself. By exploiting information gathered during the ant-based search process, the overlay evolves toward a power-law degree distribution, which is known to reduce path lengths and improve reachability. The combination of adaptive routing and emergent scale-free structure leads to significant improvements in search performance compared to purely random overlays. The authors validate their approach through simulations conducted on a custom-built simulator, demonstrating scalability to networks comprising several thousand peers and highlighting the benefits of coupling biologically inspired search with self-organizing topological adaptation.

In this work @colman2014local, the authors investigate the evolution of complex networks through a combination of growth, global rewiring, and local rewiring mechanisms. The model is not decentralized, as rewiring operations rely on the ability to select nodes and edges uniformly at random across the entire network. At each time step, the network evolves according to one of three possible processes: local rewiring, global rewiring, or growth. In the local rewiring case, a randomly chosen node detaches one of its outgoing edges and reconnects it to a node located within its extended local neighborhood, namely a descendant of a descendant. In contrast, global rewiring reconnects the detached edge to a randomly selected node in the whole network. Finally, during growth, a new node is added and creates a fixed number of outgoing links to randomly chosen existing nodes. A key aspect of the model is the balance between preferential attachment and preferential detachment. While highly connected nodes are more likely to attract new links, they are also more likely to lose existing ones through rewiring. This dual mechanism prevents the emergence of a pure scale-free structure and instead leads to an exponential degree distribution, with only a small number of nodes exhibiting extremely high degrees as outliers. The study focuses on the structural properties that emerge at equilibrium and does not consider churn, as nodes are not removed once added to the network.

The paper @marza2015new proposes a hybrid overlay topology for peer-to-peer video streaming that explicitly combines insights from complex network theory with awareness of the underlying physical topology. Rather than relying solely on abstract graph properties, the approach introduces a position-based construction mechanism aimed at aligning the logical P2P overlay with physical proximity, thereby reducing communication costs and improving streaming efficiency. The authors argue that, since many real-world networks simultaneously exhibit scale-free and small-world properties, an overlay that integrates both characteristics is better suited to practical deployment than models that enforce only one of these properties. The topology construction starts from a minimal motif, a fully connected triangle, which represents an initial set of servers at a CDN-like level and is deliberately chosen such that the three nodes are physically far apart. New peers are then added incrementally and connect to their three closest neighbors, creating a recursive spatial partitioning of the network. Each new insertion subdivides the existing regions into smaller zones, leading to a hierarchical structure that reflects both physical location and logical connectivity. As the network grows, this iterative process yields an overlay that naturally combines clustering, short path lengths, and heterogeneous degree distribution. Experimental results indicate that this hybrid scale-free and small-world topology provides higher robustness to random failures and malicious attacks, outperforming classical small-world and scale-free overlays in terms of resilience while remaining well adapted to the requirements of video streaming applications.

The paper @takeuchi2016deterministic introduces a deterministic method for constructing artificial scale-free networks while explicitly enforcing a predefined upper bound on node degree. The network grows incrementally, with nodes joining one by one, and builds upon the Semi-Deterministic Algorithm (SDA) previously proposed by Bulut and Szymanski @bulut2013constructing. The key idea is to move beyond purely incremental attachment by incorporating an explicit target for the global degree distribution. To this end, the algorithm first computes an ideal degree distribution based on the desired power-law exponent γ, the maximum degree k, and the minimum degree m, and derives from it the corresponding ideal number of edges in the network. As in SDA, each newly added node initially connects to k existing nodes in a deterministic manner; however, this step is systematically complemented by a post-processing phase that adjusts the total number of edges so that the evolving topology better matches the ideal distribution. By explicitly correcting the edge count after node insertion, the approach significantly reduces both the average and the worst-case deviation from the target degree distribution. As a result, the method achieves tighter control over scale-freeness under degree constraints, at the cost of increased determinism and coordination compared to purely local or stochastic construction schemes.

This study @lopez2017distributed presents a distributed rewiring model aimed at improving the structural efficiency of complex networks through local link adjustments. Each node starts with a set of links divided into fixed and dynamic subsets. During network operation, nodes use their incident edges to route packets and gather local performance statistics. Based on these statistics, nodes identify underperforming outgoing links—those that carried fewer packets—and rewire them toward distant nodes that are more likely to shorten future paths. Initially, nodes are deployed on a 2D grid with a Von Neumann neighborhood, where fixed links ensure minimal connectivity and dynamic links remain untied. Each cycle consists of a packet exchange phase, where tracers with random destinations are forwarded sequentially, and a rewiring phase, in which nodes rank neighbors by utility and attempt to replace their least useful links with better-performing nodes. To support this approach, the authors developed a custom Python-based simulator integrating NetworkX for graph analysis, enabling distributed execution and structural monitoring. A coordinator node, randomly selected, synchronizes phase transitions, ensuring orderly progression across the network. Overall, the model leverages purely local information to iteratively optimize network topology, reducing path lengths while maintaining decentralized control.

In this article @park2018distributed, the author introduces a distributed algorithm for constructing scale-free networks through preferential rewiring, without requiring network growth. In this model, all nodes start with an inherent attractiveness reflecting their computational power or availability, and initially maintain only a single link. At each time step, nodes randomly sample a limited set of peers and attempt to establish a bidirectional connection with the most attractive candidate. If the candidate node accepts—by comparing the requesting node’s attractiveness with that of its existing neighbor—both nodes rewire their links, replacing connections to less attractive nodes. This iterative process drives the emergence of a power-law degree distribution with a scaling exponent of 2.5, as confirmed analytically and via Monte Carlo simulations. Notably, the resulting networks exhibit ultra-small diameters, scaling as (O(\ln \ln N)) for (2 < \gamma < 3). The algorithm operates without churn, relying solely on local decisions and random sampling, yet efficiently produces highly heterogeneous, scale-free topologies that reflect intrinsic node attributes.

Diggans et al. (2021) @diggans2021emergent investigate how constraints on node connectivity influence the emergence of hierarchical structures in networks. Building on the classical Barabási–Albert preferential attachment model @barabasi1999emergence, they introduce conductance-based limits on the number of connections a node can maintain. By systematically restricting link capacity, the study demonstrates that bottlenecks in connectivity naturally induce hierarchical organization, where high-degree nodes occupy central positions while lower-degree nodes are relegated to peripheral roles. This work highlights the interplay between local degree constraints and global network topology, showing that hierarchy can emerge as an intrinsic property of scale-free systems when structural limitations are enforced.

Fasino et al. (2021) @fasino2021generating present a method for generating large scale-free networks using the Chung–Lu random graph model, which requires specifying the expected degree sequence for all nodes. The model constructs networks where each node achieves its target degree exactly, and under suitable conditions, the resulting networks exhibit a power-law degree distribution with a giant connected component. Unlike many other random graph models, the Chung–Lu approach avoids introducing correlations between the degrees of connected nodes. However, the method is not decentralized, does not handle churn, and its admissibility conditions impose restrictions on both the degree sequence and the network size.

Meng and Zhou (2023) @meng2023scale revisit the concept of scale-free networks by highlighting the distinction between the degree distribution (DD) and the degree–degree distance distribution (DDDD). They show that networks exhibiting a power-law DD form only a subset of those with power-law DDDD, and that some networks may have non-power-law DD but still display power-law DDDD. The authors propose two models: a no-growth preferential attachment model, in which nodes are fixed and links are added internally based on degree-dependent probabilities, and a fitness-based model, where links form deterministically if the sum of node fitnesses exceeds a threshold. These approaches emphasize that network structure can emerge from internal rewiring or node fitness rather than growth, and suggest that DDDD provides a more comprehensive measure of scale-free properties than traditional degree distributions. The models are non-decentralized and do not consider churn.

Over the past two decades, research on peer-to-peer and complex network topologies has explored multiple directions, ranging from classical random graph constructions to scale-free networks with power-law degree distributions. Various approaches have been considered, including algorithms that rely on global knowledge of the network and fully decentralized mechanisms, as well as techniques that impose limitations on hub formation to avoid overload. Studies have addressed both static and dynamic networks, examined the impact of node failures and churn, and compared multiple network models in terms of efficiency, robustness, and search performance. Despite this extensive body of work, significant challenges remain. In particular, there is still a need for fully decentralized networks that allow hubs to emerge naturally while maintaining resilience to failures and churn, achieving ultra-low diameters (e.g., diameter 2), and providing efficient routing and connectivity without centralized control. In the next chapter, we present our contributions toward designing such a network, combining self-organization, robustness, and minimal diameter within a decentralized framework.

// == Metrics

// == Use-cases
// == History
// == Graph theory
// == Security

// == Fault-tolerance
// == Asynchronous communications

// Brahms
// Scale-free Overlay Structures for Unstructured Peer-to-Peer Networks
// # On Complexity and Approximability of Optimal DoS Attacks on Multiple-Tree P2P Streaming Topologies
