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

As established in @chap:overlay, no existing overlay management protocol simultaneously achieves full decentralization, controlled topology shaping, and hub election. Yet, the presence of highly connected nodes in a peer-to-peer network would be highly desirable in a number of practical settings. In decentralized federated learning, such nodes could serve as aggregators, collecting and redistributing machine learning models across the network, playing a role analogous to that of the central server in classical federated learning. Beyond federated learning, similar benefits would arise in file sharing systems, where well-connected nodes could act as high-availability relay nodes, or in distributed storage architectures, where they could serve as replication anchors. In all these settings, the key property is the same: a small number of nodes acting as bridges between the rest of the network, ensuring that any two nodes are at most two hops apart and thus keeping the network diameter at two.

However, relying on statically designated nodes introduces well-known vulnerabilities: a fixed, publicly known hub is a natural target for adversarial attacks. What is needed instead is a mechanism that allows such nodes to emerge organically from the network itself, without central coordination, while remaining controllable in number and resilient to failures and churn.

This chapter presents Elevator, a protocol designed precisely for this purpose. Elevator allows selected nodes to naturally ascend to hub status through a process we term _hub sampling_, by hybridizing two fundamental concepts: _preferential attachment_ and _random attachment_. This combination promotes a balanced network structure where hubs emerge organically based on connectivity patterns, yet adapt to dynamic network changes. The parameter $h$, representing the desired number of hubs, provides flexibility and control over the resulting topology, enabling tailored configurations to suit specific application requirements.

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

To describe how such malicious behavior can affect the protocol, we adopt the Byzantine failure model defined in @chap:model, namely the *Byzantine Synchronous Message-Passing model* (BSMP ⟨n, t⟩ [∅]). Our Byzantine model assumes that a certain percentage of nodes are Byzantine from the start.
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

To address Elevator's vulnerability to Byzantine attacks, we propose a deterministic hub redistribution mechanism (that we name Lift) that activates after the network has converged to its initial hub configuration. Our approach leverages the fact that node identifiers are assigned randomly and cannot be modified by Byzantine nodes. Lift is designed to be more efficient than Elevator in terms of resilience when Byzantine nodes are active, while having no impact on protocol performance and convergence toward hubs when Byzantine nodes are absent.

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
    - hub list: *H*
    - network size: *N*
    - target hubs: *h*

    + seed $arrow.l$ getSortedHubIDs(H) 
      // Extract and sort hub node IDs

    + prng $arrow.l$ Random(seed) 
      // Initialize PRNG with seed

    + selectedIDs $arrow.l$ {}

    + *while* selectedIDs.size() < h
      + randomID $arrow.l$ prng.nextInt(N) 
        // Random node ID in [0, N-1]

      + *if* randomID *not in* selectedIDs
        + selectedIDs $arrow.l$ selectedIDs $union$ {randomID}

    + H $arrow.l$ selectedIDs
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

$Pr[forall t >= T, H(t)=H(T) and forall v in V, C_v (t)[1:h] = H(t)] = 1$

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
If the network contains between one and $h-1$ hubs, an additional hub will eventually appear with high probability.
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
  image("../../Images/models/indegree_Nsize_comparison_models.svg", width: 90%),
  caption: [In-degree evolution of the hub, comparing models with simulation data, with N from 100 to 1000. K=20, h=10.],
) <ModelNsize>],
[#figure(
  image("../../Images/models/indegree_cachesize_comparison_models.svg", width: 90%),
  caption: [In-degree evolution of the hub, comparing models with simulation data, with varying values for K. N=1000, h=10.],
) <Modelcachesize>],
[#figure(
  image("../../Images/models/indegree_numberhubs_comparison_models.svg", width: 90%),
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
We see similar results for Elevator, except for a distinct group of 10 hubs with an in-degree of 1000.
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
  image("../../Images/Elevator/normal_1000_100xp_clustering_color.svg", width: 90%),
  caption: [Clustering coefficient computed during the simulation (no failures), for each algorithm, every 10 cycles],
) <fig:ClustCoef>],
[#figure(
  image("../../Images/Elevator/normal_1000_100xp_average_path_color.svg", width: 90%),
  caption: [Average path length computed during the simulation (no failures), for each algorithm, every 10 cycles],
) <fig:AveragePathLength>],
[#figure(
  image("../../Images/Elevator/normal_1000_100xp_diameter_color.svg", width: 90%),
  caption: [Diameter computed during the simulation (no failures), for each algorithm, every 10 cycles],
) <fig:Diameter>],
)

We also compared the algorithms according to their resilience to crashes, churn, and byzantine attacks, as shown below.

=== Resilience to crashes

We analyze the performance of the four algorithms when the network suffers crashes.
To simulate a brutal failure we disconnected 50% of the nodes in the middle of the simulation, *i.e.*, in this case, we have disconnected 500 nodes at cycle 500 (as there are 1000 nodes in total and 1000 cycles).

The performance of Elevator is not affected, as the in-degree distribution is still the same, and we have 10 hubs with an in-degree of 500.
The degree distribution is also the same for Newscast and PROOFS.
For Phenix, the degree distribution remains the same, with values going to a max of 1000, even if there are only 500 nodes in the network.
It's because the nodes have kept in their cache the addresses of (old) nodes who are no longer in the network.
In @fig:ClustCoefCrash, the clustering coefficient evolution shows that it is not affected by the crashes, as we have almost the same results as those obtained without a crash.
The same observation holds for the average path length and the diameter, as we can see in @fig:AveragePathLengthCrash and @fig:DiameterCrash.

#grid(
  columns: 1,
[#figure(
  image("../../Images/Elevator/crash_1000_100xp_clustering_color.svg", width: 90%),
  caption: [Clustering coefficient computed with a 50% crash, for each algorithm, every 10 cycles],
) <fig:ClustCoefCrash>],
[#figure(
  image("../../Images/Elevator/crash_1000_100xp_average_path_color.svg", width: 90%),
  caption: [Average path length computed with a 50% crash, for each algorithm, every 10 cycles],
) <fig:AveragePathLengthCrash>],
[#figure(
  image("../../Images/Elevator/crash_1000_100xp_diameter_color.svg", width: 90%),
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
  image("../../Images/Elevator/churn_1000_100xp_clustering_color.svg", width: 90%),
  caption: [Clustering coefficient computed with churn, for each algorithm, every 10 cycles],
) <fig:ClustCoefChurn>],
[#figure(
  image("../../Images/Elevator/churn_1000_100xp_average_path_color.svg", width: 90%),
  caption: [Average path length computed with churn, for each algorithm, every 10 cycles],
) <fig:AveragePathLengthChurn>],
[#figure(
  image("../../Images/Elevator/churn_1000_100xp_diameter_color.svg", width: 90%),
  caption: [Diameter computed with churn, for each algorithm, every 10 cycles],
) <fig:DiameterChurn>],
)

=== Resilience to hub-targeted failures

We hereby analyze the performance of the four algorithms after a failure on the hubs during the execution of the simulation.
To simulate it, we disconnected 10 nodes that have the highest in-degree in the middle of the simulated scenario.

Logically, Newscast and PROOFS are not affected by the failure, as there are no hubs in the networks built by these algorithms.
For Elevator, the in-degree distribution remains similar, with 10 high-in-degree peers that have each an in-degree of 990.
We are thus confident in the capacity of our algorithm to promote new nodes to the position of hubs if the previous hubs were disconnected.
In @fig:ClustCoefCrashHub we can see that we have almost the same results as the results obtained without crashes for the clustering coefficient.
Its the same for the average path length and the diameter, there is no impact, as we can see in @fig:AveragePathLengthCrashHub and @fig:DiameterCrashHub.

#grid(
  columns: 1,
[#figure(
  image("../../Images/Elevator/crash_hub_1000_100xp_clustering_color.svg", width: 90%),
  caption: [Clustering coefficient computed with a hub-targeted failure, for each algorithm, every 10 cycles],
) <fig:ClustCoefCrashHub>],
[#figure(
  image("../../Images/Elevator/crash_hub_1000_100xp_average_path_color.svg", width: 90%),
  caption: [Average path length computed with a hub-targeted failure, for each algorithm, every 10 cycles],
) <fig:AveragePathLengthCrashHub>],
[#figure(
  image("../../Images/Elevator/crash_hub_1000_100xp_diameter_color.svg", width: 90%),
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
  image("../../Images/CANDAR/elevator.ElevatorV15_normalStats_100_nb_hubs_graph_100_cycles.svg", width: 90%),
  caption: [Running of Elevator without attack.],
) <fig:no_attack>
],
  [
    #figure(
      image("../../Images/CANDAR/elevator.ElevatorVOneByzantine2_oneByzantineActif_1000_nb_hubs_100_cycles.svg", width: 90%),
      caption: [Active Byzantine behavior.],
    ) <fig:single_byzantine_active>
  ],
  [
    #figure(
      image("../../Images/CANDAR/elevator.ElevatorVOneByzantine_oneByzantinePassif_1000_nb_hubs_100_cycles.svg", width: 90%),
      caption: [Passive Byzantine behavior.],
    ) <fig:single_byzantine_passive>
  ],
  [#figure(
  image("../../Images/CANDAR/elevator.ElevatorVByzantine2_5percentindep_1000_nb_hubs_100_cycles.svg", width: 90%),
  caption: [Independent Byzantine attack at 5% rate.],
) <fig:independent_byzantine>
],)

This highlights that coordination is a critical factor for a successful attack. Indeed, coordinated Byzantine nodes — each aware of all other Byzantine nodes and sharing this information when responding to cache requests — dramatically increase the risk of hub capture. Our experiments show a sharp vulnerability threshold around 2% Byzantine participation (@fig:1percent_byzantine, @fig:2percent_byzantine, @fig:5percent_byzantine): at 1%, the proportion of Byzantine hubs rises from 1% of nodes to 13.4% of hubs, and at 5%, all 10 hubs become Byzantine. This threshold aligns closely with the cache size parameter (_c = 20_), indicating that coordinated attackers need to approach or exceed the cache size to overwhelm the random sampling mechanism effectively.


These findings demonstrate that while Elevator is resilient to individual or independent attacks, its main vulnerability lies in coordinated misinformation. Consequently, it is necessary to implement a defense mechanism that mitigates the influence of Byzantine nodes and restores fairness.

#grid(
  columns: 1,
[#figure(
  image("../../Images/CANDAR/elevator.ElevatorVByzantine2_1percentrandom_1000_nb_hubs_100_cycles.svg", width: 90%),
  caption: [Byzantine hub infiltration at 1% rate.],
) <fig:1percent_byzantine>
],
[#figure(
  image("../../Images/CANDAR/elevator.ElevatorVByzantine2_2percentrandom_1000_nb_hubs_100_cycles.svg", width: 90%),
  caption: [Byzantine hub infiltration at 2% rate.],
) <fig:2percent_byzantine>
],
[#figure(
  image("../../Images/CANDAR/elevator.ElevatorVByzantine2_5percentrandom_1000_nb_hubs_100_cycles.svg", width: 90%),
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
      image("../../Images/CANDAR/elevator.ElevatorVCounter_5percentcounter_1000_nb_hubs_100_cycles.svg", width: 90%),
      caption: [Counter-attack effectiveness at 5% rate.],
    ) <fig:counter_5percent>],
    [    #figure(
      image("../../Images/CANDAR/elevator.ElevatorVCounter_10percentcounter_1000_nb_hubs_100_cycles.svg", width: 90%),
      caption: [Counter-attack effectiveness at 10% rate.],
    ) <fig:counter_10percent>],
    [    #figure(
      image("../../Images/CANDAR/elevator.ElevatorVCounter_15percentcounter_1000_nb_hubs_100_cycles.svg", width: 90%),
      caption: [Counter-attack effectiveness at 15% rate.],
    ) <fig:counter_15percent>
],
  )

=== Summary

We first analyzed the structural properties of the network produced by the Elevator protocol. The in-degree distribution remains consistent across different numbers of hubs (see @fig:degreeDistributionVariableNbHubs and @fig:CompareContext), except in the extreme case where $h = c = 20$. In this configuration, nodes connect exclusively to hubs, resulting in a multi-star topology and eliminating random connections. This behavior is fully aligned with the protocol definition, where all outgoing links become preferential.

#grid(
  columns: 1,
[#figure(
  image("../../Images/Elevator/Elevator_1000_100xp_indegree_color.svg", width: 90%),
  caption: [In-degree distribution of the network, after the run of the Elevator algorithm, with a variable number of hubs (5 hubs, 10 hubs, 15 hubs, 20 hubs), no failures.],
) <fig:degreeDistributionVariableNbHubs>],
[#figure(
  image("../../Images/Elevator/Elevator_context_1000_100xp_indegree_color.svg", width: 90%),
  caption: [In-degree distribution of the network, after the run of the Elevator algorithm, during each context (no failures, 50% crash, churn, and hub-targeted failure).],
) <fig:CompareContext>],
)

Across different failure contexts, the overall distribution shape and structural metrics remain stable. As illustrated in @fig:ElevatorContextCoefClust, @fig:ElevatorAveragePathLength, and @fig:ElevatorDiameter, the clustering coefficient, average path length, and diameter exhibit only minor variations. This stability is an intrinsic property of the protocol: once hubs emerge, they remain stable over time (except in the presence of failures), which explains the robustness of global metrics. In this regard, Elevator demonstrates greater structural stability than Phenix, particularly concerning diameter and average path length.

#grid(
  columns: 1,
[#figure(
  image("../../Images/Elevator/Elevator_context_1000_100xp_clustering_color.svg", width: 90%),
  caption: [Clustering of the network, after the run of the Elevator algorithm, during each context (no failures, 50% crash, churn, and hub-targeted failure).],
) <fig:ElevatorContextCoefClust>],
[#figure(
  image("../../Images/Elevator/Elevator_context_1000_100xp_average_path_color.svg", width: 90%),
  caption: [Average path length of the network, after the run of the Elevator algorithm, during each context (no failures, 50% crash, churn, and hub-targeted failure).],
) <fig:ElevatorAveragePathLength>],
[#figure(
  image("../../Images/Elevator/Elevator_context_1000_100xp_diameter_color.svg", width: 90%),
  caption: [Diameter of the network, after the run of the Elevator algorithm, during each context (no failures, 50% crash, churn, and hub-targeted failure).],
) <fig:ElevatorDiameter>],
)

We then evaluated the protocol under Byzantine behavior and assessed the effectiveness of the Lift counter-attack. The results show that Lift successfully disrupts coordinated Byzantine hub capture at lower participation rates (e.g., 5%) by introducing a deterministic hub redistribution mechanism. However, as Byzantine participation increases (10% and 15%), its effectiveness decreases: malicious nodes progressively regain hub positions after the countermeasure is triggered. Additionally, the total number of hubs may decrease, indicating that Byzantine interference can prevent some correct nodes from maintaining their hub status.

Interestingly, even after activation of the countermeasure, Byzantine nodes continue attempting hub capture and achieve partial success, leading to slight deviations from the theoretical expectation of an average of $B/N$ Byzantine hubs. Nevertheless, Lift significantly reduces Byzantine influence while remaining lightweight, as it operates as a one-shot solution.

Overall, our simulation results demonstrate that Elevator achieves the targeted structural properties, including the emergence of a controlled number of hubs, bounded degree, and low network diameter. The protocol proves resilient to crash failures and churn, maintaining stable global metrics under dynamic conditions. However, it remains vulnerable to coordinated Byzantine attacks. The proposed Lift countermeasure increases resilience against such attacks without compromising the decentralization or the performance of the protocol.

== Implementation over TCP/IP

// make repository public
// add link to repository

To complement the simulation-based evaluation, we implemented a fully operational version of the Elevator protocol over real TCP/IP networks. This implementation (available at https://github.com/MohamedLEGH/elevator-algorithm) serves two main purposes: (i) validating the feasibility of Elevator in a realistic peer-to-peer environment, and (ii) assessing its behavior under asynchronous execution, failures, and heterogeneous deployment conditions.

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
  image("../../Images/Victor/graphe_4HUBS_Cycles12.svg", width: 90%),
  caption: [Number of hubs at each cycle, with $N=20$, $c=10$ and $h=4$],
) <fig:Victor20nodes>],
  [#figure(
  image("../../Images/Victor/graphe_5HUBS_Cycles.svg", width: 90%),
  caption: [Number of hubs at each cycle, with $N=50$, $c=10$ and $h=5$],
) <fig:Victor50nodes>],
  [#figure(
  image("../../Images/Victor/graphe_4HUBS_deco_Cycles.png", width: 90%),
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
  image("../../Images/Victor/graphe_test_V1_10_HUBS.svg", width: 90%),
  caption: [Number of hubs at each cycle, semi-synchronous, with $N=100$, $c=20$ and $h=10$],
) <fig:Victor100nodes>],
  [#figure(
  image("../../Images/Victor/graphe_test_V2_5_HUBS.svg", width: 90%),
  caption: [Number of hubs, synchronous mode, with $N=100$, $c=20$ and $h=5$],
) <fig:Victor100nodesSynchrone>],
  [#figure(
  image("../../Images/Victor/graphe_test_V3_1_HUBS.svg", width: 90%),
  caption: [Number of hubs, asynchronous mode, with $N=100$, $c=20$ and $h=1$],
) <fig:Victor100nodesAsynchrone>],
)

For the two-machine experiments, the network was distributed across a server and a local machine. The server hosted 99 nodes, while the local machine hosted a single node, resulting in a total of 100 nodes. All nodes executed 100 protocol cycles, and each maintained a cache of size 20. The experiment used 10 hubs. This configuration allowed us to observe the behavior and stabilization of hubs in a distributed setup spanning multiple machines, providing insight into the protocol's robustness under a heterogeneous deployment. The results obtained mirrored those of the single-machine experiments. As seen in @fig:Victor100nodesCluster, @fig:Victor100nodesClusterSynchrone and @fig:Victor100nodesClusterAsynchrone, hubs consistently stabilized within the first cycles, demonstrating that the protocol behavior is robust under a distributed setup spanning multiple machines.


Experimental results confirmed theoretical expectations, with rapid convergence to the preconfigured number of hubs across all tested scenarios. Variations in node parameters did not affect the overall stabilization behavior, illustrating the robustness of the Elevator protocol. Future work may involve scaling the experiments to larger networks distributed across more machines to assess performance at a greater scale and to compare results under more heterogeneous deployment conditions.

#grid(
  columns: 1,
  [#figure(
  image("../../Images/Victor/graphe_test2_V1.svg", width: 90%),
  caption: [Experiments on a cluster of 2 machines, semi-synchronous mode, with $N=100$, $c=20$ and $h=10$],
) <fig:Victor100nodesCluster>],
  [#figure(
  image("../../Images/Victor/graphe_test2_V2.svg", width: 90%),
  caption: [Experiments on a cluster of 2 machines, synchronous mode, with $N=100$, $c=20$ and $h=10$],
) <fig:Victor100nodesClusterSynchrone>],
  [#figure(
  image("../../Images/Victor/graphe_test2_V3.svg", width: 90%),
  caption: [Experiments on a cluster of 2 machines, asynchronous mode, with $N=100$, $c=20$ and $h=10$],
) <fig:Victor100nodesClusterAsynchrone>],
)

== Conclusion

We proposed a novel peer sampling algorithm, Elevator, designed for unstructured P2P networks, which enables the organic emergence of a controlled number of hub nodes while preserving decentralization and bounded degree.

Our study combines theoretical analysis, simulation-based evaluation, and real-world experimentation. First, we conducted a formal analysis of the algorithm, establishing its convergence, its stability properties, and providing insights into its convergence speed. This theoretical investigation shows that the protocol drives the system toward a topology characterized by a predefined number of hubs $h$, while maintaining randomness among the remaining connections.

We then validated these properties through extensive simulations. The results demonstrate that Elevator achieves the targeted structural objectives: low network diameter, stable hub formation, bounded degree, and robustness under crash failures and churn. The protocol maintains stable global metrics even under dynamic conditions, confirming the soundness of its design.

Beyond simulations, we implemented Elevator on a real network, confirming its practical feasibility and validating that its theoretical and simulated properties hold in realistic environments.

We also investigated the vulnerability of Elevator to Byzantine attacks. Our analysis shows that, while the protocol is resilient to failures and churn, it remains vulnerable to coordinated Byzantine strategies aiming at capturing hub positions. To address this limitation, we proposed a modification of the algorithm, Lift, which increases resilience against Byzantine behavior through a deterministic redistribution mechanism. Importantly, this countermeasure improves robustness without compromising decentralization or degrading the performance of the protocol.

Elevator opens the way to a new class of algorithms that we refer to as hub sampling algorithms, where structural centrality is deliberately engineered within unstructured overlays. One particularly promising application domain is artificial intelligence, and federated learning in particular, where controlled hub structures may accelerate model aggregation and dissemination. Before presenting this contribution, @chap:learning surveys the state of the art in decentralized learning. This use case (and our associated contribution in the field) is then studied in detail in @chap:heal.

