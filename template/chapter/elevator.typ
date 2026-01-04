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
#grid(
    columns: 2,
[#figure(
  image("../../Images/models/indegree_Nsize_comparison_models.pdf"),
  caption: [In-degree evolution of the hub, comparing models with simulation data, with N from 100 to 1000. K=20, h=10.],
) <ModelNsize>],
[#figure(
  image("../../Images/models/indegree_cachesize_comparison_models.pdf"),
  caption: [In-degree evolution of the hub, comparing models with simulation data, with varying values for K. N=1000, h=10.],
) <Modelcachesize>],
[#figure(
  image("../../Images/models/indegree_numberhubs_comparison_models.pdf"),
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
// A detailed description of these algorithms can be found in Appendix @sec:algorithms.
We compared the performance of Elevator with these 3 algorithms.
We chose to compare our proposed algorithm to these three algorithms as they are widely used in the literature.
Newscast is used for gossip learning @ormandi2013gossip, PROOFS is a foundational algorithm, as Secure Cyclon @antonov2023securecyclon, one of the latest peer sampling algorithm in the literature, is based on Cyclon @voulgaris2005cyclon, itself based on PROOFS.
Phenix is interesting as it has especially been conceived to be resilient to failures and Byzantine attacks and also to construct networks that have a low diameter.
We did not include recent algorithms @xie2008scale @bulut2013constructing @lynn2024emergent that primarily focus on improving the power law distribution of the in-degrees @xie2008scale @bulut2013constructing @lynn2024emergent, as they are expected to behave similarly to Phenix @wouhaybi2004phenix.

All simulations were run with a network of size *n* = 1000.
As the Phenix network needs a growing network to work, we started the Phenix algorithm with a network size of 20 and capped the size of the network to 1000.
The simulations were run during 1000 cycles, and we repeated each simulation 100 times.
All simulations were started with a network initialized as a $k$-out random graph, with $k = c = 20$.
All simulations were run on 16 vCPU, using 64G of memory, on a cluster composed of 10 servers, described in Table @table-cluster.

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

We also compared the algorithms according to their resilience to crashes, churn, and attacks on hubs, as shown below.
// Additional results and the accompanying figures are included in the Appendix @sec:figures.

=== Resilience to crashes

We analyze the performance of the four algorithms when the network suffers crashes.
To simulate a brutal failure we disconnected 50% of the nodes in the middle of the simulation, *i.e.*, in this case, we have disconnected 500 nodes at cycle 500 (as there are 1000 nodes in total and 1000 cycles).

The performance of Elevator is not affected, as the in-degree distribution is still the same, and we have 10 hubs with an in-degree of 499.
The degree distribution is also the same for Newscast and PROOFS.
For Phenix, the degree distribution remains the same, with values going to a max of 999, even if there are only 500 nodes in the network.
It's because the nodes have kept in their cache the addresses of (old) nodes who are no longer in the network.
In @fig:ClustCoefCrash, the clustering coefficient evolution shows that it is not affected by the crashes, as we have almost the same results as those obtained without a crash.
The same observation holds for the average path length and the diameter, as we can see in @fig:AveragePathLengthCrash and @fig:DiameterCrash.

=== Resilience to churn

We now analyze the performance of the four algorithms when the network is subject to churn.
To simulate churn, we disconnected 10% of the nodes at each cycle and replaced them with the same amount of new nodes, each connected to 20 nodes uniformly at random.
The churn occurs during 500 cycles, between cycle n°250 and cycle n°750.
As the Phenix algorithm needs a growing network to work, the way we implement churn differs.
Following previous work [@wouhaybi2004phenix], in the case of Phenix, we implement churn having the number of removed nodes less than the number of added nodes at each cycle, assuming nodes are removed following a normal distribution $cal(N)(0,1)$, for all cycles of the simulation.

The in-degree distribution of Elevator remains the same, with 10 hubs.
PROOFS seems affected by churn, as the mean degree distribution goes to 10 instead of 20 without churn.
In @fig:ClustCoefChurn we can observe that we have almost the same results as the results obtained without churn for the clustering coefficient.
For the average path length, PROOFS is the most affected, with a value going from 2.25 without churn to a value of 2.5 with churn, and the value keep increasing after the end of the churn, going up to 2.75, as we can see in @fig:AveragePathLengthChurn.
In @fig:DiameterChurn, we can see that the diameter varies with churn, with a mean going up to 3.25 instead of 2.0, but the values for Phenix and Elevator remain below the ones of Newscast and PROOFS.

=== Resilience to hub-targeted attacks

We hereby analyze the performance of the four algorithms after a targeted attack on the hubs during the execution of the simulation.
To simulate a hub-targeted attack, we disconnected 10 nodes that have the highest in-degree in the middle of the simulated scenario.

Logically, Newscast and PROOFS are not affected by the attack, as there are no hubs in the networks built by these algorithms.
For Elevator, the in-degree distribution remains similar, with 10 high-in-degree peers that have each an in-degree of 989.
We are thus confident in the capacity of our algorithm to promote new nodes to the position of hubs if the previous hubs were disconnected.
In @fig:ClustCoefCrashHub we can see that we have almost the same results as the results obtained without crashes for the clustering coefficient.
Its the same for the average path length and the diameter, there is no impact, as we can see in @fig:AveragePathLengthCrashHub and @fig:DiameterCrashHub.

=== Summary

We have compared the in-degree distribution of the network after the run of the Elevator algorithm for a various number of hubs in @fig:degreeDistributionVariableNbHubs, and also for each context of simulation in @fig:CompareContext.
The shape of the degree distribution remains consistent across different hub counts, except for a scenario with 20 hubs where nodes exclusively connect to these hubs (resulting in a multi-star topology).
This phenomenon aligns with the prescribed number of preferred connections (*h* = *c* = 20), where nodes exclusively link to elevated hub nodes, omitting random connections entirely.
The shape of distribution also remains consistent across failure contexts.
In @fig:ElevatorContextCoefClust, @fig:ElevatorAveragePathLength and @fig:ElevatorDiameter, we compare Elevator across all contexts for the different metrics, and we can see that there are not many variations in values, as expected from the definition of our protocol and as seen in previous comparative analyses presented above.
Another notable feature is that Elevator seems more stable than Phenix.
This is because once the hubs are in place they do not change (except in the event of failures), which provides stability in terms of network diameter or average path length.
#grid(
  columns: 2,
  [#figure(
  image("../../Images/Elevator/normal_1000_100xp_clustering_color.pdf"),
  caption: [Clustering coefficient computed during the simulation (no failures), for each algorithm, every 10 cycles],
) <fig:ClustCoef>],
[#figure(
  image("../../Images/Elevator/normal_1000_100xp_average_path_color.pdf"),
  caption: [Average path length computed during the simulation (no failures), for each algorithm, every 10 cycles],
) <fig:AveragePathLength>],
[#figure(
  image("../../Images/Elevator/normal_1000_100xp_diameter_color.pdf"),
  caption: [Diameter computed during the simulation (no failures), for each algorithm, every 10 cycles],
) <fig:Diameter>],
[#figure(
  image("../../Images/Elevator/crash_1000_100xp_clustering_color.pdf"),
  caption: [Clustering coefficient computed with a 50% crash, for each algorithm, every 10 cycles],
) <fig:ClustCoefCrash>],
[#figure(
  image("../../Images/Elevator/crash_1000_100xp_average_path_color.pdf"),
  caption: [Average path length computed with a 50% crash, for each algorithm, every 10 cycles],
) <fig:AveragePathLengthCrash>],
[#figure(
  image("../../Images/Elevator/crash_1000_100xp_diameter_color.pdf"),
  caption: [Diameter computed with a 50% crash, for each algorithm, every 10 cycles],
) <fig:DiameterCrash>],
[#figure(
  image("../../Images/Elevator/churn_1000_100xp_clustering_color.pdf"),
  caption: [Clustering coefficient computed with churn, for each algorithm, every 10 cycles],
) <fig:ClustCoefChurn>],
[#figure(
  image("../../Images/Elevator/churn_1000_100xp_average_path_color.pdf"),
  caption: [Average path length computed with churn, for each algorithm, every 10 cycles],
) <fig:AveragePathLengthChurn>],
[#figure(
  image("../../Images/Elevator/churn_1000_100xp_diameter_color.pdf"),
  caption: [Diameter computed with churn, for each algorithm, every 10 cycles],
) <fig:DiameterChurn>],
[#figure(
  image("../../Images/Elevator/crash_hub_1000_100xp_clustering_color.pdf"),
  caption: [Clustering coefficient computed with a hub-targeted attack, for each algorithm, every 10 cycles],
) <fig:ClustCoefCrashHub>],
[#figure(
  image("../../Images/Elevator/crash_hub_1000_100xp_average_path_color.pdf"),
  caption: [Average path length computed with a hub-targeted attack, for each algorithm, every 10 cycles],
) <fig:AveragePathLengthCrashHub>],
[#figure(
  image("../../Images/Elevator/crash_hub_1000_100xp_diameter_color.pdf"),
  caption: [Diameter computed with a hub-targeted attack, for each algorithm, every 10 cycles],
) <fig:DiameterCrashHub>],
[#figure(
  image("../../Images/Elevator/Elevator_1000_100xp_indegree_color.pdf"),
  caption: [In-degree distribution of the network, after the run of the Elevator algorithm, with a variable number of hubs (5 hubs, 10 hubs, 15 hubs, 20 hubs), no failures.],
) <fig:degreeDistributionVariableNbHubs>],
[#figure(
  image("../../Images/Elevator/Elevator_context_1000_100xp_indegree_color.pdf"),
  caption: [In-degree distribution of the network, after the run of the Elevator algorithm, during each context (no failures, 50% crash, churn, and hub-targeted attack).],
) <fig:CompareContext>],
[#figure(
  image("../../Images/Elevator/Elevator_context_1000_100xp_clustering_color.pdf"),
  caption: [Clustering of the network, after the run of the Elevator algorithm, during each context (no failures, 50% crash, churn, and hub-targeted attack).],
) <fig:ElevatorContextCoefClust>],
[#figure(
  image("../../Images/Elevator/Elevator_context_1000_100xp_average_path_color.pdf"),
  caption: [Average path length of the network, after the run of the Elevator algorithm, during each context (no failures, 50% crash, churn, and hub-targeted attack).],
) <fig:ElevatorAveragePathLength>],
[#figure(
  image("../../Images/Elevator/Elevator_context_1000_100xp_diameter_color.pdf"),
  caption: [Diameter of the network, after the run of the Elevator algorithm, during each context (no failures, 50% crash, churn, and hub-targeted attack).],
) <fig:ElevatorDiameter>]
)

== Implementation over TCP/IP

To complement the simulation-based evaluation presented earlier, we implemented a fully operational version of the Elevator protocol over real TCP/IP networks. This implementation was carried out in collaboration with an undergraduate intern and serves two main purposes: (i) validating the feasibility of Elevator in a realistic peer-to-peer environment, and (ii) assessing its behavior under asynchronous execution, failures, and heterogeneous deployment conditions.

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

First, a configuration file listing all participating nodes (IP addresses and HTTP ports) is generated. Using this information, each node is assigned an initial cache of size (c), corresponding to a random (c)-out graph. The initial caches are generated offline and then distributed to the nodes through HTTP POST requests. Upon reception, each node stores the received cache locally and acknowledges successful initialization.

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

The implementation was validated through a series of experiments on small- to medium-scale networks (ranging from 20 to 50 nodes), executed either on a single machine or distributed across two machines. Experiments confirmed the rapid emergence of hubs within the first few cycles, in line with the theoretical analysis and simulation results.

Additional experiments simulated hub failures by forcibly disconnecting the highest-degree nodes during execution. In all cases, new hubs emerged naturally after a short transient phase, demonstrating the self-healing properties of the protocol. The presence of random connections in the cache played a crucial role in maintaining connectivity and enabling recovery.

=== Practical observations

From a systems perspective, the implementation revealed a high degree of concurrency, with a large number of goroutines active at runtime. This behavior is expected, as libp2p internally spawns goroutines for stream handling, connection management, and message processing. Despite this, the system remained stable and responsive throughout the experiments.

Overall, this TCP/IP implementation confirms that Elevator is not only theoretically sound and effective in simulation, but also practical and robust when deployed over real peer-to-peer networks. It further demonstrates that the protocol tolerates asynchronous execution, node failures, and dynamic network conditions, making it suitable for realistic distributed environments.

=== CPU Information Collection

Monitoring CPU usage is a critical aspect of evaluating the performance and behavior of each node in the network. Metrics such as CPU utilization (%CPU), CPU time, and memory allocation provide insight into the resource consumption of individual processes. To automate this process, we developed the script `info.py`, which collects these metrics for all nodes and stores them in a CSV file for subsequent analysis. The script is executed at the end of the `launch_nodes.sh` script to ensure that metrics are captured throughout the lifetime of the experiment.

The `info.py` script identifies all processes named `main` and retrieves their process identifiers (PIDs). Using these PIDs, it executes system commands to extract the desired metrics, including CPU and memory statistics. This approach enables precise monitoring of the computational load imposed by the Elevator protocol on each node.

Following preliminary tests on a personal machine, the implementation and scripts were adapted to conduct experiments in a dedicated Linux environment. This allows for more controlled and scalable evaluation of the protocol under realistic system conditions.

For the single-machine experiments, three configurations of the Elevator protocol were tested. In all configurations, the network consisted of 100 nodes executing 100 protocol cycles, with each node maintaining a cache of size 20. The three versions differed in the number of hubs: Version 1 used 10 hubs, Version 2 used 5 hubs, and Version 3 used a single hub. These experiments allowed us to evaluate the impact of varying the number of hubs on the stabilization and performance of the protocol while keeping other parameters constant. For all three versions, the experiments were conducted using 100 nodes with a cache size of 20 and 100 protocol cycles, while varying the number of hubs. The resulting graphs were consistent with those presented in the previous section, showing rapid stabilization of hubs within the first cycles, regardless of parameter variations. Analysis of CPU metrics revealed that certain nodes consumed nearly twice the %CPU and CPU time compared to others. These nodes were identified as the selected hubs, which aligns with the intrinsic definition of a hub: a node maintaining a large number of connections to other peers. Indeed, hubs transmit their caches to a larger subset of nodes, explaining the increased computational load observed.

For the two-machine experiments, the network was distributed across a server and a local machine. The server hosted 99 nodes, while the local machine hosted a single node, resulting in a total of 100 nodes. All nodes executed 100 protocol cycles, and each maintained a cache of size 20. The experiment used 10 hubs. This configuration allowed us to observe the behavior and stabilization of hubs in a distributed setup spanning multiple machines, providing insight into the protocol's robustness under a heterogeneous deployment.

The results obtained mirrored those of the single-machine experiments. Hubs consistently stabilized within the first cycles, demonstrating that the protocol behavior is robust under a distributed setup spanning multiple machines.


Experimental results confirmed theoretical expectations, with rapid convergence to the preconfigured number of hubs across all tested scenarios. Variations in node parameters did not affect the overall stabilization behavior, illustrating the robustness of the Elevator protocol. Future work may involve scaling the experiments to larger networks distributed across more machines to assess performance at a greater scale and to compare results under more heterogeneous deployment conditions.

== Conclusion

We proposed a novel peer sampling algorithm, Elevator, designed for unstructured P2P networks, which facilitates the organic promotion of specific nodes to serve as hubs. Our simulations confirm that the Elevator algorithm successfully maintains network connectivity, constructs networks with low diameters, achieves stability with a defined number of hubs (denoted as _h_), and demonstrates resilience against crashes, churn, and targeted attacks on hubs.
The distinctive aspect of our work lies in our pursuit of developing an unstructured network model with inherent hub nodes. 
We anticipate that this work will pave the way for a new category of algorithms known as "hub sampling algorithms", which could hold significant relevance for specific decentralized applications. For instance, such algorithms may accelerate the transmission of machine learning models in federated learning scenarios or automate the selection of validators in blockchain networks, thus potentially replacing the need for traditional proof-of-work protocols.
While our current study does not delve into these specific use cases, we envision exploring federated learning applications within this network paradigm in future investigations. 
