// #import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/lovelace:0.3.0": *

#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
// // #import cosmos.rainbow: *
// // #import cosmos.clouds: *
#show: show-theorion


= First contribution: Elevator <chap:elevator>
In this paper we propose and evaluate an innovative algorithm that enables the creation of Peer-to-Peer network overlays characterized by emergent multi-hubs. This approach generates overlays that balance between the randomness of a graph and the structure of a star network, resulting in networks that not only feature prominent hubs but also exhibit strong resilience to failures. By leveraging principles of preferential attachment and random attachment, our method allows hubs to form spontaneously, offering a decentralized and fault-tolerant solution ideal for applications requiring both low network diameter and high robustness. The protocol is entirely decentralized, operates asynchronously, and depends exclusively on local information. Nodes organically evolve into hubs and remain indistinguishable from other nodes (except in terms of the number of incoming links). The quantity of hubs that emerge can be predetermined by the application as a network parameter.

Peer-to-peer networks, Peer sampling service, Hub sampling, Resilient networks, System design, Algorithms, Simulations.

== Introduction
    The growing usage of decentralized systems such as blockchain @nakamoto2008bitcoin and federated learning @mcmahan2017communication in recent years has sparked considerable interest in peer-to-peer (P2P) communication protocols. While existing P2P protocols have demonstrated significant utility across various applications, emerging demands for enhanced performance, scalability, and robustness necessitate the development of innovative solutions.

Peer-to-peer (P2P) protocols have undergone extensive research and development to facilitate efficient decentralized communication among networked devices. Foundational P2P protocols like Napster, Gnutella @frankel2003gnutella, and BitTorrent paved the way for distributed file sharing and content distribution across the Internet. Typically, P2P overlay networks are categorized as either structured (e.g. CAN @ratnasamy2001scalable, Chord @stoica2001chord, or Kademlia @maymounkov2002kademlia) or unstructured (e.g. Gnutella @frankel2003gnutella). More comprehensive details about peer-to-peer overlays can be found in recent surveys @malatras2015state, @naik2020next. 

Structured overlays come with a maintenance cost @malatras2015state, and are more susceptible to Byzantine attacks (that is, attacks performed by the peers themselves) @naik2020next and churn @malatras2015state (that is, the unexpected departure and arrival process of the peers). 
Unstructured networks exhibit advantages in resilience to node failures and adaptability to shifting network conditions @jelasity2007gossip, rendering them well-suited for dynamic and heterogeneous environments when compared to their structured counterparts. Their shortcomings are that the quality of services built on top of the network is difficult to assess. 

Peers within an unstructured overlay maintain a dynamic set of neighbors, often discovered through mechanisms like peer sampling @jelasity2007gossip, which enables nodes to gather and exchange information about other nodes in the network, and thus dictates the network topology.
Existing peer sampling algorithms in the literature yield two types of topologies (random and power-law) that demonstrate favorable networking characteristics. Random graphs are built from gossip peer sampling algorithms and are known to be resilient to churn @jelasity2007gossip. 
Power-law (or scale-free) networks are built from algorithms that use the concept of preferential attachment and are known to have ultra-small diameter @cohen2003scale, which helps scalability. 
However, when considering the specific use case of federated learning, certain limitations emerge: _(i)_ gossip learning, based on gossip peer sampling, exhibits a slower convergence rate compared to centralized federated learning methodologies @hegedHus2021decentralized, and _(ii)_ while power-law topologies theoretically offer improved convergence efficiency, prior research has predominantly focused on constructing networks adhering strictly to power-law distributions @xie2008scale, @bulut2013constructing, implementing algorithms to restrict the proliferation of hubs @guclu2008limited, @eum2009self (that is, peers that are extremely well connected), or leveraging other metrics to construct node connections, like the distance in terms of Internet hops @sasabe2006llr or an initial attractiveness @park2018distributed. 

Yet, for federated learning, the presence of hubs is advantageous, as these hubs facilitate rapid relay of machine learning models across the network, accelerating convergence rates. Nonetheless, conventional approaches relying on predefined hubs (e.g., super-peer-based topologies) are susceptible to attacks targeting static and well-defined hub nodes @montresor2004robust.

Hence, there exists a pressing need for a protocol that fosters the organic emergence of hubs within networks. The service outlined in this article is designed precisely for this purpose, allowing selected nodes to naturally ascend to hub status through a process we term "hub sampling". By enabling nodes to organically assume the role of hubs, our protocol aims to strike a balance between leveraging the efficiency of hub-based networks for applications like federated learning, while mitigating vulnerabilities associated with static hub designations.

Our primary goal is to develop a protocol that autonomously promotes nodes to act as hubs within unstructured peer-to-peer networks. To achieve this goal, we hybridize two fundamental concepts: 
_preferential attachment_, and _random attachment_.
By integrating these two concepts, our protocol promotes a balanced network structure, where hubs emerge organically based on connectivity patterns and yet adapt to dynamic network changes. 
This approach not only fosters robustness against failures and disruptions but also maintains a low network diameter, facilitating efficient communication and information propagation. The parameter _h_, representing the desired number of hubs, allows for flexibility and control over the network's topology, enabling tailored configurations to suit specific application requirements and network environments.
The rationale behind this initiative is rooted in the benefits of having hub nodes, particularly in applications such as federated learning, where efficient information dissemination is crucial. The existence of hubs facilitates faster network-wide communication compared to overlay networks structured in a random graph topology.

// The structure of this article is organized as follows: Section~\ref{sec:2} presents the hub sampling service altogether with its properties, its programming interface (API), and its implementation, the \emph{Elevator algorithm}. Section~\ref{sec:3} presents a theoretical analysis of the properties of the algorithm. Section~\ref{sec:4} presents extensive simulations of Elevator, compared against three classical algorithms from the literature~\cite{jelasity2007gossip,stavrou2004lightweight,wouhaybi2004phenix}.

== Description & Properties
The key desired properties we expect from our protocol are _connectivity_ (the overlay remains connected), _low-diameter_ (for efficient communication), _convergence_ (properties are obtained in an autonomous manner), _stability_ (structural overlay properties are maintained throughout execution), and _robustness_ (resilience to churn and targeted attacks). They will serve as metrics during simulation experiments to ascertain the efficacy of our algorithm.

=== Service API
// == Properties

The API of the hub sampling service mirrors that of classical peer sampling service @jelasity2007gossip, comprising two key methods: _(i)_ _init()_ that initializes the service on a given node, _i.e._, initializes the list of outgoing connections of a node (Indeed, we assume that a given node starts connected to a random subset of nodes in the network, the actual initialization procedure being implementation-dependent), and _(ii)_ _getPeer()_ that returns a random peer address from the node list of peers.

The focus of this work is to present an implementation of the _getPeer()_ method, Elevator, as a gossip-based algorithm, and to study the performance of its implementation. 
In addition to these two methods, we add a third method to the API called _getHub()_ that returns a random hub. The _getHub()_ method can be easily derived from _getPeer()_ by filtering the output of _getPeer()_ to only select the $h$ nodes acting as hubs in the network. This method can be useful for applications that only need to contact a hub.

=== Preliminaries

In the context of our study, we consider an overlay network of interconnected nodes modeled as a directed graph. Communication within this network is bidirectional, corresponding to an underlying undirected graph that represents the physical network. Each node in this network possesses a unique address, akin to an IP address in the context of the Internet, serving as an abstract identifier of its identity. Nodes maintain a local list called _cache_, which contains addresses of other nodes, and represents their partial knowledge of the network's node set. The maximum size of this cache, denoted by parameter _c_, is uniform across all nodes. The cache is pivotal for peer sampling, as it serves as the basis for neighbor selection and information exchange. At the network's inception, nodes are initially connected to a random subset of nodes, forming what is known as a random _k_-out graph. Subsequently, new nodes joining the network also establish connections with a random subset of existing nodes, a process that populates their cache and integrates them into the network. Given the decentralized nature of the network, peer sampling algorithms are designed to operate asynchronously, as it is the case for Elevator, and all algorithms presented in this paper, but to help the evaluation of protocols during simulations, we can refer to the idea of _cycles_ of the protocol. During each cycle, every node initiates one execution of the peer sampling protocol, potentially updating its cache based on interactions with neighboring nodes. By leveraging cycles, we can analyze the convergence, performance, and robustness of peer sampling protocols under varying conditions and scenarios within the decentralized network environment.

=== Elevator core concepts
To achieve both robustness and a low network diameter, we integrate two fundamental concepts: preferential attachment and random attachment, each serving distinct yet complementary roles in shaping the network topology.

*Preferential Attachment.* Drawing from the concept pioneered by Barabási and Albert @barabasi1999emergence, preferential attachment dictates that new connections in the network are established preferentially with nodes possessing a higher number of existing connections. In our adaptation, we modify this concept to elevate certain nodes to the status of hubs without requiring the network to continuously grow. Instead of new nodes joining and preferentially connecting to highly connected nodes, each existing node leverages information from its neighbors to identify and connect to the most frequently connected nodes (up to a predefined number \emph{h}). This mechanism enables the organic emergence of hubs within the network, with selected nodes naturally assuming central roles based on their connectivity without any explicit distinction other than their number of incoming links.

*Random Attachment.* Inspired by gossip-based peer sampling algorithms @jelasity2007gossip  @stavrou2004lightweight, random attachment ensures that nodes maintain connections with a representative and diverse subset of the network. This strategy promotes network robustness by preventing excessive clustering and dependency on specific nodes (hubs). When existing hubs disappear (e.g., due to failures or departure), other nodes within the network are opportunistically elevated to hub status, ensuring continuity and adaptability of the network topology over time.

Our target is to obtain a topology of the network that has the following properties: _(i)_ There are _h_ defined hubs, with _h_ a parameter defined before the start of the network and common to all nodes, _(ii)_ ignoring hubs, the distribution of the remaining connections is random, and _(iii)_ each node has _c_ connections, consisting of _h_ connections to hubs and _c-h_ connections to random nodes.

// Through simulation evaluation, we demonstrate in the sequel the effectiveness and advantages of our protocol with respect to state-of-the-art algorithms.

=== Elevator detailed description
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

==== The proposed protocol executes the following actions at each run: 
Each node retrieves the neighbor's list of their neighbors _i.e._, the neighbors at distance two). The node then builds an ordered list of the most frequent peers (the frequency map) and contacts the _c_ most frequent nodes (called _preferred_). Each contacted node sends back to the contacting node a maximum of _maxsize_buffer_backward_ addresses from its backward list, maintained in the structure _backward_peers_, and adds the contacting node to its backward list. The cache of the contacting node is then reset as an empty array. Then the node selects the _h_ most frequent peers and _c-h_ random peers from the list of backward peers of all preferred peers to fill its cache. If the cache is not full, the node adds random peers from the frequency map to the cache until the size of the cache is _c_ 
(see  @Elevator-algorithm and @Elevator-algorithm-background for detailed pseudocode of the algorithm).

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

      + preferred $arrow.l$ frequency_map.sortByFrequency().select(number = c)
      + frequency_map.remove(preferred)

      + preferred_backward $arrow.l$ {}
      + *for* peer in preferred
        + peer_backward_peers $arrow.l$ send(BACKWARD_REQUEST, peer)
        + preferred_backward $arrow.l$ preferred_backward $union$ peer_backward_peers

      + preferred_backward.shuffle()

      + cache $arrow.l$ {}
      + cache $arrow.l$ preferred[1..h] + preferred_backward[1..(c - h)]

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


== Theoretical Analysis
In order to analyze and model the ELEVATOR protocol we adopt several simplifying assumptions; without them a formal analysis would be extremely difficult if not impossible. First, we assume a failure-free network with a constant number of nodes. The random identifiers returned to hubs via the BACKWARD_REQUEST mechanism are considered equivalent to identifiers drawn from a uniform distribution. When selecting preferred nodes, if a node encounters two or more candidates with equal occurrence frequency, it deterministically selects the candidate with the smallest identifier. All nodes are assumed to execute the protocol synchronously and without failure at every cycle. Prior to the first cycle, the network is assumed to be highly connected and its topology is modeled as a uniform $k$-out random graph (with $k=c$ equal to the cache size common to all nodes). The parameter $h$ (the target number of hubs) is also assumed to be identical across all nodes. Our objective with our analysis is to demonstrate the stability and convergence of Elevator. We also wish to model the convergence speed of the protocol.

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
]

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

== Simulation-Based Evaluation

== Implementation over TCP/IP