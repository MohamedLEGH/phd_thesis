#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

// TODO
// Advantages and cons of centralized architecture vs p2p
// how p2p use Internet for transmissions
// Bitorrent
// uses cases
// Blockchain
// IPFS
// Lightning Network
// I2P, Tor, mixnet

= Foundations of Peer-to-Peer Networks <chap:p2p>
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
Gnutella is fully decentralised, as it does not rely on any central file index. Starting with version 0.6, it introduced the concept of ultrapeers @chawathe2003making — high-capacity nodes that help route queries and files across the network, improving scalability while preserving decentralisation.
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

By combining the guarantees of blockchain immutability, the programmability of smart contracts, and the distributed storage capabilities of IPFS, new forms of decentralised cloud infrastructures have emerged. These systems aim to provide computing and storage services without relying on traditional centralised data centres. Notable examples include Golem #footnote[https://www.golem.network/], which offers a marketplace for distributed computing resources; Sia #footnote[https://sia.tech/], which enables decentralised cloud storage through cryptographically secured contracts; and Filecoin #footnote[https://filecoin.io/], which builds directly on top of IPFS to incentivise data storage and retrieval through a native cryptocurrency. Together, these projects illustrate the ongoing shift towards a decentralised Internet infrastructure, where computation and storage are shared and coordinated through peer-to-peer and blockchain mechanisms rather than controlled by central entities. This paradigm of distributing computation and coordination across multiple nodes naturally extends to the field of machine learning, giving rise to decentralised learning, which we will discuss in a later chapter, as it constitutes the main use case studied in this PhD.

// Hors sujet mais intéressant:
// Decentralized identity
// Lightning Network
// mixnets (NIM and Snowpack)
// Distributed social media (Mastodon, Bluesky)
// airdrop
// AirTag

All of the peer-to-peer networks discussed so far are built on top of the IP layer, and therefore operate as overlay networks — virtual topologies that sit above the underlying Internet infrastructure. Later in this chapter, we will examine in detail how overlay networks function. It is worth noting, however, that decentralised communication networks can also be deployed without relying on the Internet — for instance, through Wi-Fi Direct #footnote[https://en.wikipedia.org/wiki/Wi-Fi_Direct] to form local mesh networks #footnote[https://en.wikipedia.org/wiki/Mesh_networking], via 5G Device-to-Device (D2D) communication, or even using technologies such as Bluetooth Mesh #footnote[https://en.wikipedia.org/wiki/Bluetooth_mesh_networking].

== Structured vs Unstructured Networks
// Chord, Pastry, Kademlia

// == Unstructured Networks

// == Services in a p2p system

== Peer sampling

// == Random graph & Power-law networks

== Metrics

== Fault-tolerance

// == Use-cases
// == History

== Security
