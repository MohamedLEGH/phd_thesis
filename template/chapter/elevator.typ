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

- Starting from a random network, the algorithm generates the first hub with high probability (Proposition 6).
- Once at least one hub exists, the network remains strongly connected, and additional hubs appear until the number of hubs reaches $h$ without decreasing (Proposition 5).
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

#figure(
  image("../../Images/models/indegree_Nsize_comparison_models.pdf", width: 85%),
  caption: [In-degree evolution of the hub, comparing models with simulation data, with N from 100 to 1000. K=20, h=10.],
) <ModelNsize>

#figure(
  image("../../Images/models/indegree_cachesize_comparison_models.pdf", width: 85%),
  caption: [In-degree evolution of the hub, comparing models with simulation data, with varying values for K. N=1000, h=10.],
) <Modelcachesize>

#figure(
  image("../../Images/models/indegree_numberhubs_comparison_models.pdf", width: 85%),
  caption: [In-degree evolution of the hub, comparing models with simulation data, with varying values for h. K=20, N=1000.],
) <Modelnbhubs>

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

== Implementation over TCP/IP