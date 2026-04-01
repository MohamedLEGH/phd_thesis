#import "@preview/cetz:0.4.2"

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/lovelace:0.3.0": *

#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
#show: show-theorion

= Hub-Based Decentralized Learning <chap:heal>

// Decentralized learning enhances privacy, scalability, and fault tolerance by distributing data and computation across nodes. 
// A popular approach is Federated learning, which relies on a central aggregator, yet faces challenges such as server vulnerabilities, scalability issues, privacy risks and most importantly, the single point of failure. Alternatively Gossip Learning and Epidemic Learning  offer fully decentralization through peer-to-peer exchanges of model updates, ensuring robustness and privacy, at the price of slower model convergence. 
// In this work, we introduce a novel decentralized learning framework called HEAL. HEAL is the first cross-layer decentralized learning framework that exploits an optimized self-organizing and self-healing underlying P2P overlay combining the strengths of Federated Learning, Gossip and Epidemic Learning.
// Leveraging the recently proposed Elevator algorithm, HEAL promotes dynamically chosen nodes to act as aggregators. Through simulations, we demonstrate that HEAL has similar performances to that of Federated Learning in crash-free settings, while being fully decentralized and fault-tolerant. In crash and churn prone environments HEAL outperforms Gossip and Epidemic Learning.

// Decentralized learning is an approach to training machine learning models, where the data and computational tasks are distributed across multiple nodes or devices, rather than centralized in a single location. 
// This paradigm improves privacy, scalability, and fault tolerance by enabling participants to collaboratively train models without sharing raw data. 
// Each node processes its local data and exchanges model updates (e.g., gradients or parameters) with others, using a centralized coordinator or through peer-to-peer communication. Decentralized learning is particularly beneficial in scenarios where data is naturally distributed (such as in edge computing or IoT networks), or when data privacy or resource constraints make centralization impractical. 

// The idea of decentralized learning originates from distributed optimization 
// and parallel computing. However, it was the advent of Federated Learning 
// @mcmahan2017communication that truly brought the concept into the spotlight.

// In Federated Learning all participants (nodes or devices) in a network train 
// a machine learning model locally on their own data. Subsequently, each 
// participant sends its model to a centralized aggregator, which aggregates 
// the received models and returns the global model to the nodes. This process 
// continues until a satisfactory accuracy is achieved.

// While Federated Learning provides an efficient alternative to traditional 
// (centralized) machine learning, its dependence on a central server for 
// aggregating models introduces several limitations. This centralization creates 
// a _single point of failure_. That is, when the server crashes the generation 
// of the global model becomes impossible. Furthermore, the single server is an 
// easy target for adversarial attacks, such as model poisoning or inference 
// attacks @rodriguez2023survey, which can compromise the integrity of the global 
// model. Additionally, the server's role poses scalability challenges, as it must 
// manage potentially vast numbers of updates from distributed participants, 
// leading to communication and computation bottlenecks. More importantly, if the 
// server is controlled by a single organization, it could introduce biases or 
// favor certain participants' updates, exacerbating inequalities in model 
// performance. This phenomenon leads to _learning oligarchy_.

// To address these limitations, it is essential to explore totally decentralized 
// architectures which do not rely on a central coordinator. Gossip 
// Learning @ormandi2013gossip and Epidemic Learning @de2024epidemic are the 
// state of the art approaches for fully decentralized machine learning. However, 
// the stochastic nature of these protocols can result in slower convergence 
// compared to Federated Learning-based approaches @hegedHus2021decentralized. 
// It should be noted that in the case of gossip learning, recent research has 
// been conducted to enhance its various aspects, such as improving its security 
// against privacy attacks @danner2015fully, increasing its efficiency by 
// compressing the models sent @danner2020decentralized. More recent studies 
// focused on examining the impact of poisoning attacks @pham2024data on various 
// gossip learning strategies.

// Interestingly, none of the previous decentralized federated approaches had a 
// cross-layer design philosophy.

// _Our contribution._
// In this paper we introduce a novel form of decentralized learning, HEAL (for 
// #strong[H]ub #strong[E]nhanced #strong[A]daptive #strong[L]earning), which combines the benefits of
// Federated Learning, Gossip and Epidemic Learning (summarized in
// @tab:all_algorithm).
The previous chapter established a fundamental tension in decentralized
learning: centralized approaches such as federated learning achieve fast
convergence through coordinated aggregation, but at the cost of a single
point of failure, scalability limitations, and trust requirements on the
central server. Fully decentralized approaches such as gossip learning and
epidemic learning eliminate this dependency and offer strong resilience
properties, but typically converge more slowly due to the limited bandwidth
of pairwise or local interactions.


In this chapter, we introduce HEAL (for 
#strong[H]ub #strong[E]nhanced #strong[A]daptive #strong[L]earning),
a novel decentralized learning framework designed to bridge this gap. HEAL is
the first cross-layer decentralized learning framework that exploits an
optimized, self-organizing peer-to-peer overlay --- specifically the Elevator
protocol introduced in @chap:elevator --- to dynamically promote a controlled
number of nodes to act as aggregators. Unlike traditional federated learning, aggregator nodes
are not pre-selected and hence HEAL becomes extremely resilient to the network
dynamicity (nodes crashes and churn). That is, HEAL self-heals and self-adapts
by promoting new hubs while continuing the learning process without significant
losses. We challenged HEAL, Federated Learning, Gossip Learning and Epidemic
Learning with various topologies in static and dynamic environments (crash and
churn prone) on two tasks: a binary classification task using a logistic
regression @hosmer2013applied on the Spambase dataset @spambase_94 and on a
multinomial classification task using the LeNet5 model @lecun1989backpropagation
on the MNIST dataset @lecun2010mnist. HEAL outperforms Gossip and Epidemic Learning in both accuracy and convergence
time. Moreover, HEAL is resilient to churn and crashes while Federated Learning
cannot cope with these faults.

#figure(
  table(
    columns: (4cm, 3cm, auto, 3.5cm, 3cm),
    align: (left, left, center, left, left),
    stroke: 0.5pt,

    [*Decentralized Learning Protocol*], [*Topology*], [*Fault resilience*],
    [*Churn resilience*], [*Aggregation speed*],

    [Federated Learning],
    [Static (Star @mcmahan2017communication and Multi-Star @hsieh2017gaia)],
    [No], [No], [quick & centralized],

    table.cell(rowspan: 2)[Gossip Learning],
    [Static (Random Regular @hegedHus2021decentralized)],
    [No], [No], [slow & local],

    [Dynamic (Newscast @ormandi2013gossip)],
    [Yes], [Yes], [slow & local],

    [Epidemic Learning],
    [Dynamic (Newscast @de2024epidemic)],
    [Yes], [Yes], [slow & local],

    [FedLay @hua2024towards],
    [Dynamic (based on virtual rings)],
    [Yes (only one)], [No], [slow & local],

    [*HEAL*],
    [*Dynamic (Elevator @legheraba2024emergent)*],
    [*Yes*], [*Yes*], [*quick, using hubs*],
  ),
  caption: [Comparison of different decentralized learning algorithms.],
) <tab:all_algorithm>

// *Paper organization.*
// In @sec:learning-background we propose an overview of decentralized learning
// strategies. @sec:HEAL introduces the architecture of HEAL and the detailed
// description of the HEAL learning strategies. @sec:evaluation presents our
// extensive evaluations. @sec:conclusions concludes and proposes open research
// directions.

// == Overview of Decentralized Learning Techniques <sec:learning-background>

// The distinguishing factors among various decentralized learning algorithms in
// the literature are: (1) the algorithm employed to propagate and aggregate
// learning models within the network, and (2) the network topology on which the
// learning occurs. Naturally, these two concepts are interconnected, as certain
// propagation methods are better suited to specific topologies.

// *Decentralized propagation and aggregation of the learning models.*

// There are various techniques for propagating the learning models within a
// network, each with its own set of advantages and disadvantages. The three most
// commonly discussed methods in the literature are _Federated Learning_,
// _Gossip Learning_, and _Epidemic Learning_. In Federated Learning
// @mcmahan2017communication, all models are aggregated at a central server,
// facilitating rapid convergence towards a global model. In Gossip Learning
// @ormandi2013gossip, each participant shares its model at a specified time
// interval with a randomly chosen neighbor in the network. In Epidemic Learning
// @de2024epidemic, each participant shares its model with all their neighbors in
// each cycle.

// *Network topology vs decentralized learning.*

// In decentralized learning, the network topology significantly influences the
// performance of the learning task, as evidenced by various studies in the
// literature @vogels2022beyond. Different topologies impact the speed of
// information propagation and the system's resilience to node or link failures.
// At the extremes, we have the star topology, typically used with Federated
// Learning, and the random graph topology, often paired with Gossip Learning.
// However, many other topologies exist between these extremes. Additionally, it
// is important to distinguish between static topologies (predefined and
// unchangeable) and dynamic topologies (which evolve over time).

// - *Static topologies.* Among static topologies, _star topology_, features a
//   central server and clients connected to it. This setup is not entirely
//   decentralized, as the aggregator server is selected at the beginning of the
//   learning process, creating a single point of failure. The _multi-star
//   topology_ is a variation of the star topology, involving multiple servers.
//   Typically, all stars are interconnected in a complete topology, with all
//   other nodes connected to a predefined star. Next, we have the _complete
//   topology_, where every participant communicates directly with all others.
//   While this maximizes information propagation speed and ensures rapid
//   convergence, it is impractical for large-scale networks. Another common
//   topology is the _ring topology_, where each node is connected to two
//   neighbors, forming a circular ring. This topology is straightforward to
//   construct but does not scale well. Finally, in _random regular graphs_ each
//   participant is randomly connected to _k_ other participants in the network,
//   with _k_ being a predefined parameter. This topology is highly robust against
//   failures and churn, but the learning process convergence is slow. Other
//   random topologies in the literature include small worlds and power-law
//   networks.

// - *Self-organised dynamic topologies.* To establish a dynamic topology, two
//   primary approaches are discussed in the literature: Distributed Hash Table
//   (DHT)-based methods and decentralized peer sampling methods. Among the
//   DHT-based methods, Chord @stoica2001chord is a notable example. Additionally,
//   Fedlay @hua2024towards is specifically designed for decentralized learning.
//   For non-DHT methods, Newscast @jelasity2007gossip is commonly used in Gossip
//   Learning and Epidemic Learning.

// An important aspect to consider in dynamic topologies is their resilience to
// failures. A specific type of failure is churn, where nodes in a peer-to-peer
// network enter and leave without any control. Another particular case of failures
// involves attacks targeting specific nodes, such as servers or central nodes.
// Centralized topologies are highly sensitive to these types of failures.
// In a static topology, there is no possibility to repair the topology in the
// event of a failure. In a DHT, some repairs are possible, but not always
// guaranteed face to high churn.
// Peer sampling algorithms are a good compromise to repair the topology when
// failures are detected and to be resilient to high churn.

// HEAL uses as underlying topology Elevator @legheraba2024emergent, a recently
// proposed decentralized peer-sampling algorithm. This algorithm enables nodes in
// a peer-to-peer network to construct an overlay with _h_ defined hubs, each hub
// being connected to all nodes in the network, with _h_ being a parameter of the
// algorithm. Elevator is totally distributed, self-organizing and resilient to
// churn.
// In @tab:all_algorithm, we summarized the topologies used with various
// decentralized learning algorithms, along with the strengths and weaknesses of
// each approach.

== HEAL Protocol

=== Desired Properties 

HEAL is designed to satisfy a set of fundamental properties that characterize a practical, efficient, and resilient decentralized learning framework.

*Model convergence* is the primary objective. A decentralized learning framework that fails to drive participating nodes toward a common, accurate model is of no practical utility. HEAL must therefore ensure that the collaborative training process converges to a model of quality comparable to what centralized training would yield. In strict adherence to the federated learning paradigm, raw data must remain local at all times, authorizing exclusively the exchange of model parameters. This constraint ensures privacy and security by design, preventing sensitive information from leaking during the training process.

*Fast dissemination* is a central motivation for HEAL. The framework aims to propagate model updates across the network within a small number of communication rounds. Rapid dissemination directly translates into faster convergence, reduced training time, and improved responsiveness to distributional shifts in the data.

*Model agnosticism* ensures that HEAL imposes no structural assumptions on the learning task or the model architecture. The framework should support any supervised learning model, from linear classifiers to deep neural networks, provided that the model parameters can be exchanged and aggregated. This generality is essential for broad applicability across heterogeneous deployment scenarios.

*Resilience to failures and churn* captures the framework's ability to sustain learning progress in the presence of node departures, crashes, and unpredictable network dynamics. Ensuring continuity of the learning process under such adverse conditions requires a fully decentralized design, where no single node acts as an indispensable coordinator. Any architecture that relies on a central point of control introduces a single point of failure, whose loss would halt the entire training process. HEAL must therefore distribute both coordination and aggregation responsibilities across the network, so that the failure of any individual node, regardless of its role in the network, does not compromise the overall learning dynamics.

*Resource efficiency and algorithmic simplicity* reflect the practical constraints under which decentralized learning systems operate. HEAL should minimize communication overhead, avoid redundant model transmissions, and keep memory and computation requirements within reasonable bounds to remain viable on resource-constrained devices. Beyond computational constraints, the design must adhere to a minimalist philosophy. A simpler algorithmic approach reduces implementation complexity and facilitates auditing, ensuring that the system is not only performant but also transparent and verifiable.

Addressing these properties in a cohesive manner requires a structured design. HEAL therefore follows a *layered architecture*, drawing inspiration from the OSI model @osi-model. This approach isolates concerns into distinct layers --- from network overlay management to model aggregation --- enabling modularity, easier verification, and incremental refinement. The next subsection presents the detailed architecture of HEAL.

=== HEAL Architecture

HEAL is structured as a four-layer protocol stack, designed to enforce modularity, separation of concerns, and extensibility. From bottom to top, these layers are: the *Network Layer*, responsible for low-level peer-to-peer communication and message routing; the *Overlay Layer*, which maintains the logical topology and manages neighbor discovery; the *Aggregation Layer*, implementing the core decentralized learning logic such as model merging and synchronization; and the *Application Layer*, which interfaces with the local learning task, handles data loading, and orchestrates the training loop. Each layer operates independently, interacting with adjacent layers only through well-defined interfaces. This strict decoupling enables modular development, simplifies debugging and auditing, and allows individual components to be replaced or optimized without affecting the rest of the system. In the following paragraphs, we detail the responsibilities and internal mechanisms of each layer, and describe how they interact to achieve efficient and resilient decentralized learning.

#figure(
cetz.canvas({
  import cetz.draw: *
  let w = 4
  let h = 1.4
  let spacing = 2
  let colors = (
    rgb(70%, 70%, 70%),
    rgb(75%, 90%, 75%),
    rgb(75%, 85%, 95%),
    rgb(85%, 75%, 90%),
  )
  let labels = (
    "Network Layer",
    "Overlay Layer",
    "Aggregation Layer",
    "Application Layer",
  )
  let details = (
    "Physical network &\nTCP/IP stack",
    "P2P topology &\nneighbor management",
    "Aggregation protocol &\nparameter fusion",
    "Supervised ML models\n(SVM, NN, ...)",
  )

  for i in range(4) {
    rect((0, i*spacing), (w, h + (i*spacing)), name: "rect_"+str(i), fill: colors.at(i))
    content("rect_"+str(i), labels.at(i))

    let mid_y = (i*spacing) + h/2
    let arrow_x_start = w + 0.15
    let arrow_x_end = w + 0.6
    let text_x = w + 0.7

    line((arrow_x_start, mid_y), (arrow_x_end, mid_y), mark: (end: ">"))
    content((text_x, mid_y), anchor: "west", details.at(i))
  }
}), caption: [Layered architecture of HEAL]
) <fig:system-architecture>

// Federated Learning is vulnerable due to its reliance on a central server, so
// our protocol must avoid having a single point of failure. Additionally, to
// ensure resilience to failures and churn, the topology should not be predefined
// but generated in a peer-to-peer manner. Conversely, to guarantee rapid model
// convergence, learning models should not be shared via gossip within the network
// but aggregated by a network node, which will then create the global model and
// distribute it back to the other network nodes. These two aspects may seem
// contradictory, but the HEAL-overlay (Elevator) protocol allows us to create a
// topology that satisfies both requirements.

// HEAL architecture shown in @fig:system-architecture is composed of two layers on top
// of the physical network. HEAL-overlay given by the Elevator protocol introduced
// in @legheraba2024emergent and HEAL-learning protocol described in the sequel.

==== Network Layer

The Network Layer forms the foundation of the HEAL protocol stack. It is responsible for low-level peer-to-peer communication, providing the basic message passing primitives upon which all higher layers depend. This layer directly implements the network assumptions formalized in @chap:model. In particular, we assume the underlying network is connected, reliable, and provides bidirectional communication channels between nodes.

For all practical purposes, the Network Layer is equivalent to a standard TCP/IP stack. Each node is identified by a unique network address (e.g., an IP address and port), and messages are transmitted over reliable, bidirectional channels that guarantee in-order delivery without loss or corruption. This abstraction aligns with our modeling assumptions from @chap:model, where message transmission is treated as instantaneous and reliable, allowing us to focus on overlay-level protocols without accounting for network-level failures.

The Network Layer exposes two primary operations to the layer above:
- `send(peer_id, message)`: transmits a message to a specified peer identified by its network address,
- `receive()`: listens for incoming messages and delivers them to the upper layer for processing.

By delegating all physical networking concerns to this layer, HEAL ensures that higher-level components --- overlay maintenance, aggregation, and learning orchestration --- remain agnostic to the underlying transport mechanisms. This separation enables the protocol to operate over any standard network infrastructure without modification, while also allowing future extensions (e.g., support for unreliable transports or encrypted channels) to be implemented at this layer without affecting the rest of the system.

==== Overlay Layer

The Overlay Layer implements the logical topology that enables efficient decentralized learning in HEAL. This layer is powered by the Elevator protocol, whose design and theoretical guarantees are detailed in @chap:elevator. Elevator builds upon the reliable communication primitives provided by the Network Layer to dynamically elect a subset of nodes as *hubs*, forming a structured overlay with desirable properties for model dissemination and aggregation.

Elevator operates in a fully decentralized manner and converges within $O(log N)$ communication cycles, where $N$ is the network size. The protocol is resilient to node churn and failures: the departure or crash of any individual node --- including a hub --- does not compromise the overlay's connectivity, as replacement mechanisms automatically restore the desired topology.

The overlay exposes two configurable global parameters:
- $h in NN^*$: the number of hubs maintained in the system,
- $c in NN^*$ with $c > h$: the total number of logical connections (degree) maintained by each node.

Each node in the overlay maintains exactly $c$ connections, structured as follows:
- $h$ connections to *all* hubs in the system (every node, including hubs themselves, is connected to every hub),
- $c - h$ connections to randomly selected non-hub peers, refreshed periodically to ensure good mixing properties.

This hybrid structure combines the low-diameter benefits of a hub-based topology with the robustness of random gossip-style connections. Hubs serve as high-visibility coordination points, while random edges provide redundancy and mitigate the risk of partitioning.

The Overlay Layer exposes the following API to the Aggregation Layer above:
#list(
  [ `getHub()`: returns a uniformly random hub from the current hub set, useful for sampling an aggregator without global knowledge, ],
  [ `getHubs()`: returns the complete, consistent list of all $h$ hubs, identical across all nodes in the system, ],
  [ `getRandomPeers()`: returns the set of $c - h$ random neighbors for gossip-based exchanges, ],
  [ `isHub()`: returns `true` if the local node currently holds hub status, `false` otherwise. ],
)

The primary objective of this overlay design is to enable efficient model aggregation in the layer above. Hubs act as natural aggregation points: nodes can push model updates to hubs, which then merge and redistribute aggregated models.

By decoupling overlay management from learning logic, HEAL ensures that the aggregation strategy can be modified or extended without affecting the underlying topology maintenance, and vice versa. This separation of concerns is central to the modularity and extensibility of the overall architecture.

// ==== HEAL Overlay

// In the following we briefly revisit how Elevator operates. For a more detailed
// explanation, readers can refer to the article that introduces the
// algorithm @legheraba2024emergent.

// The Elevator protocol performs the following actions during each cycle: Each
// node in the peer-to-peer network retrieves the list of neighbors of their
// neighbors (i.e., the neighbors at a distance of two). The node then constructs
// an ordered list of the most frequent peers (the frequency map) and contacts the
// _c_ most frequent nodes (referred to as _preferred_). Each contacted node
// responds by sending the addresses from its backward list to the contacting node
// and adds the contacting node to its backward list. The contacting node's cache
// is then reset to an empty array. Subsequently, the node selects the _h_ most
// frequent peers and _c-h_ random peers from the backward lists of all preferred
// peers to populate its cache.

// This protocol enables the rapid formation (in 4 cycles or fewer in practical
// settings) of a network topology with _h_ defined hubs and a random distribution
// of the remaining incoming connections. The resulting network has a diameter of 2
// and is highly resistant to both failures (including hub failures) and churn. In
// the event of all hubs failing, new hubs quickly emerge (typically within one
// cycle). These properties are particularly advantageous for decentralized
// learning, suggesting that we can implement a learning algorithm on this topology
// that achieves performance levels similar to Federated Learning while maintaining
// resilience properties as Gossip and Epidemic Learning.

==== HEAL Learning Protocol

Regarding the communication algorithm, we utilize the hubs within the network
as aggregators, similar to how the central server aggregates models in Federated
Learning. The key difference is that multiple hubs perform the aggregation, not
just one, and these hubs emerge automatically. We leverage the presence of
multiple hubs to distribute the aggregation workload, with each hub handling a
portion of the network nodes and subsequently aggregating with each other. Each
hub then returns the global model to its clients, and the protocol begins a new
cycle. As with Federated Learning, the learning process continues over several
cycles and concludes when the global model has converged.

#figure(
  pseudocode-list(booktabs: true)[
    - duration to wait for model: *delta_time*
    - list of all hubs (obtained by the HEAL overlay, Elevator protocol): *hubs_list*
    + *loop*
      + nb_hubs $arrow.l$ hubs_list.size() 
      + models $arrow.l$ ${}$
      + time $arrow.l$ time.now()
      + backwards_list $arrow.l$ ${}$
      + *while* time.now() < time + delta_time 
        + peer_model, peer $arrow.l$ receive()
        + models.append(peer_model)
        + backwards_list.append(peer)
      + average_model $arrow.l$ average(models)
      + send(hubs_list, average_model)
      + models_hubs $arrow.l$ ${}$
      + models_hubs.append(average_model)
      + nb_receive $arrow.l$ $0$
      + *while* nb_receive < $"nb_hubs" - 1$
        + hub_model $arrow.l$ receive()
        + nb_receive
        + models_hubs.append(hub_model)
      + global_model $arrow.l$ average(models_hubs)
      + send(backwards_list, global_model)
    ],  caption: [HEAL Learning: The Hub algorithm.],
) <algo:HubLearningHub>


#figure(
  pseudocode-list(booktabs: true)[
    - duration to wait for model: *delta_time*
    - The model, weights or parameters initialized at random: *model*
    - The local data of the node: *data*
    - list of all hubs (obtained by HEAL overlay, Elevator protocol): *hubs_list*
    - number of hubs to send the model to: *number_hub_send*
    + *loop*
      + model $arrow.l$ trainModel(model, data)
      + hubs $arrow.l$ chooseRandom(hubs_list, number_hub_send)
      + *for* hub *in* hubs
        + send(hub, model)
      + hubs_models $arrow.l$ list()
      // + #text(style: "italic")[//Receiving the global models from the hubs]
      + *for* hub *in* hubs
        + model_hub $arrow.l$ receive()
        + hubs_models.append(model_hub)
      + model $arrow.l$ average(hubs_models)
  ],
  caption: [HEAL Learning: The client algorithm.],
) <algo:HubLearningNode>


In the event of one or more hubs failing during a protocol cycle, the remaining
hubs can temporarily manage the nodes without a dedicated hub until a new hub
emerges, which typically occurs within two cycles. If all hubs fail, the
aggregation process halts but resumes as soon as new hubs appear, again within
two cycles. It's important to note that Elevator also establishes random
connections in the network, in addition to hub connections. In HEAL, we focus
solely on connections to hubs (and between hubs) for model aggregation. These
random connections could potentially be used to accelerate model convergence or
mitigate malicious behavior, but this is beyond the scope of our current work.
For now, we assume that all network nodes (and hubs) are honest, with plans to
investigate malicious behavior in future research.

One intriguing feature of Elevator is the ability to select the number of hubs
in the network through a parameter shared by all nodes. This is particularly
valuable in HEAL, as it allows us to balance between having fewer hubs for
higher convergence speed and more hubs for greater resilience to failures.
Additionally, HEAL offers the flexibility to choose the number of hubs to which
a client sends its model. A more detailed description of how Learning operates
in HEAL follows.

Each node in the network executes the HEAL learning protocol, in addition to
HEAL overlay construction via the Elevator protocol (that dynamically assigns
"normal" (client) or "hub" (server) status to the participating nodes):

- If the node is a normal (client) node, it (1) selects a number of hubs
  (servers) at random, (2) performs a local training step, (3) sends the
  trained model to the hubs, and (4) waits for the global model.

- If the node is a hub, it (1) waits for a _delta_ period to receive models
  from normal nodes, (2) aggregates these models by averaging their parameters,
  and (3) sends its aggregated model to all other hubs. (4) It then waits to
  receive models from other hubs and (5) aggregates all these models to obtain
  the global model. (6) Finally, the hub sends the global model back to the
  nodes.

  
@algo:HubLearningHub and @algo:HubLearningNode present the detailed pseudo-code of HEAL Learning.

// == Description

// = Properties

// = Theoretical Analysis

== Simulation-Based Evaluation

We evaluated our algorithm using simulations on the Gossipy
simulator#footnote[https://github.com/makgyver/gossipy]. We compared Hub
Learning against Federated Learning @mcmahan2017communication,
Gaia @hsieh2017gaia, Gossip Learning @ormandi2013gossip, Epidemic
Learning @de2024epidemic, Epidemic Learning on a Chord
topology @stoica2001chord, Epidemic Learning on a ring topology, and
Fedlay @hua2024towards. For the static topologies (Federated Learning, ring,
Chord, and Gaia), we generated the topology using the Python library
Networkx#footnote[https://networkx.org/].
For the dynamic topologies (Gossip Learning, Epidemic Learning, Fedlay and Hub
Learning with Elevator), we generated the topology using the PeerSim
simulator @p2p09-peersim.
In Elevator (used by Hub Learning), the connections are directional. However,
to compare them with other algorithms (which assume an undirected graph), we
modified the underlying graph of the topology generated to make it undirected.
All evaluations were conducted with a network of 100 nodes. For Elevator, we
used 5 hubs, as we found this number to be a good balance between performance
and resilience. For Gaia, we had 5 servers responsible for aggregation (to
compare with the 5 hubs) and 19 nodes (or workers) attached to each server.
Each algorithm was evaluated 5 times, and we present the average results
obtained.

We assessed all protocols on two tasks: a binary classification task (Logistic
Regression @hosmer2013applied on the Spambase dataset @spambase_94, with a
learning rate of 0.1) and on a multinomial classification task
(LeNet5 @lecun1989backpropagation on the MNIST dataset @lecun2010mnist, with a
learning rate of 0.001). The weight decay (regularization parameter) was fixed
at 0.01. Our algorithm was evaluated under various conditions: the failure of
20% of nodes, the failure of a hub, the failure of all 5 hubs, and during churn
(where 10% of nodes disappear at each cycle and are replaced by new nodes).

All simulations were run on 16 vCPU, using 64G of memory, on a cluster
composed of 10 servers.

_Crash-free, churn-free environment:_
For simulations without failures and churn, we ran all algorithms over 1000
cycles, on the two learning tasks (Spambase, MNIST). As shown in
@fig:AccuracyMNIST, when there are no failures in the network, Federated
Learning performs best, which was expected. Surprisingly, the ring topology
performs second best despite lower connectivity.
Other topologies based on random graphs perform less well. HEAL, however,
performs very well for both the Spambase and MNIST datasets.

In @tab:all_results we have compiled the results for all learning algorithms,
for the two learning tasks, with the final accuracy obtained after 1000 cycles.
Federated Learning, Gaia, and HEAL have very similar results, with a final
accuracy of around 0.88 on Spambase, and 0.95 on MNIST. Gossip-based approaches
achieve values of 0.85 and 0.91 on Spambase and MNIST.
Convergence time is very fast for aggregator-based approaches: on Spambase,
Federated Learning converges to 0.85 in 2 cycles, and HEAL takes 4 cycles. On
the other hand, to converge on 0.90 accuracy, HEAL takes 339 cycles while
Federated Learning takes 135 cycles, hinting at possible HEAL optimization,
e.g. adjusting the learning rate.
On MNIST, HEAL performs very well, even better than Federated Learning, and it
converges to 0.95 accuracy in 76 cycles.

_HEAL parameterized with number of hubs and number chosen hubs:_
We ran simulations of HEAL, changing the number of hubs over 2000 cycles. On
@fig:AccuracyVariousNbHubs, we observe that increasing the number of hubs (and
the number of hubs to which clients send their model) has almost no impact on
accuracy, which is expected since hubs aggregate models. There is a slight drop
in accuracy when the number of hubs is increased significantly, due to the fact
that only non-hubs are learning, not hubs. Increasing the number of hubs to
which we send our model, from 1 to $"nb\_hubs"/2$, slightly increases
convergence speed.

_Crashes-prone environment:_
We analyze the performance of the algorithms when the network suffers crashes.
To simulate a brutal failure we disconnected 20% of the nodes chosen uniformly
at random, just after the start of the learning process, i.e., in this case, we
have disconnected 20 nodes at cycle 10, and we compared HEAL with Chord, Gaia
and Fedlay. HEAL is the algorithm with the best results, although Gaia remains
very close, as seen in @fig:AccuracyCrash20peers.

_HEAL under churn environment and hub-targeted attacks:_
We further analyzed the performance of HEAL under network churn conditions. To
simulate churn, we disconnected 10% of the nodes at each cycle and replaced
them with an equal number of new nodes, each connected to 20 nodes uniformly at
random, between cycles 50 and 150.
We also analyzed the performance of the main learning algorithms after a
targeted attack on the hubs during the execution of the simulation. We tested
two scenarios, one where we disconnected one of the 5 hubs, and another where
we disconnected all 5 hubs at the same time. In both cases the failure happened
in round 10. In @fig:AccuracyContexts, we have compared the execution of HEAL
without failures, and with different failure scenarios (crash of 20 nodes, crash
of one hub, crash of all 5 hubs, churn). As can be seen, there is no significant
impact when 20 nodes or hubs crash. Indeed, thanks to the Elevator overlay, even
when all the hubs are shutdown, 5 new nodes are elected very quickly as hubs,
and the training job continues as if no catastrophic event had happened. During
churn, model accuracy falls slightly, but rises again very quickly once churn is
over, back to the level without failures.

#grid(
    columns: 1,
    [
      #figure(
        image("../../Images/HEAL/normal_accuracy_MNIST_color.pdf", width: 95%),
        caption: [Without failures],
      ) <fig:AccuracyMNIST>
    ],
    [
      #figure(
        image("../../Images/HEAL/crash20peers_accuracy_MNIST_color.pdf", width: 95%),
        caption: [When 20% of the nodes fail at round 10],
      ) <fig:AccuracyCrash20peers>
    ],
  )

  #grid(
    columns: 1,
    [
      #figure(
        image("../../Images/HEAL/various_hub_accuracy_MNIST_color.pdf", width: 95%),
        caption: [HEAL with different numbers of hubs (_h_), from 1 to 25, each
        node sent its model to (_s_) hubs, with (_s_) equals to 1 or $h/2$,
        no failures, 2000 cycles],
      ) <fig:AccuracyVariousNbHubs>
    ],
    [
      #figure(
        image("../../Images/HEAL/hub_learning_accuracy_allcontexts_color.pdf", width: 95%),
        caption: [HEAL for all contexts (no failures, crash of 20 peers, crash
        of 1 hub, crash of all hubs, churn), with 5 hubs, each node sent its
        model to one hub, 200 cycles],
      ) <fig:AccuracyContexts>
    ],
  ),


// #figure(
//   grid(
//     columns: 2,
//     gutter: 1em,
//     [
//       #figure(
//         image("../../Images/HEAL/normal_accuracy_MNIST_color.pdf", width: 100%),
//         caption: [Without failures],
//       ) <fig:AccuracyMNIST>
//     ],
//     [
//       #figure(
//         image("../../Images/HEAL/crash20peers_accuracy_MNIST_color.pdf", width: 100%),
//         caption: [When 20% of the nodes fail at round 10],
//       ) <fig:AccuracyCrash20peers>
//     ],
//   ),
//   caption: [Accuracy of various communication protocols, for the MNIST dataset,
//   with a network of 100 nodes, during 1000 cycles. HEAL overlay has 5 hubs,
//   each node sends its model to one hub.],
// )

// #figure(
//   grid(
//     columns: 2,
//     gutter: 1em,
//     [
//       #figure(
//         image("../../Images/HEAL/various_hub_accuracy_MNIST_color.pdf", width: 100%),
//         caption: [HEAL with different numbers of hubs (_h_), from 1 to 25, each
//         node sent its model to (_s_) hubs, with (_s_) equals to 1 or $h/2$,
//         no failures, 2000 cycles],
//       ) <fig:AccuracyVariousNbHubs>
//     ],
//     [
//       #figure(
//         image("../../Images/HEAL/hub_learning_accuracy_allcontexts_color.pdf", width: 100%),
//         caption: [HEAL for all contexts (no failures, crash of 20 peers, crash
//         of 1 hub, crash of all hubs, churn), with 5 hubs, each node sent its
//         model to one hub, 200 cycles],
//       ) <fig:AccuracyContexts>
//     ],
//   ),
//   caption: [Accuracy of HEAL for the MNIST dataset, with 100 nodes.],
// )

#figure(
  table(
    columns: (auto, auto, auto),
    align: center,
    inset: 12pt,
    [*Method*], [*Spambase*], [*MNIST (LeNet)*],
    [Federated Learning], [0.9087], [0.9742],
    [Gaia],              [0.8826], [0.9442],
    [Gossip Learning],   [0.8322], [0.7098],
    [Epidemic Learning], [0.9548], [0.9111],
    [Ring],              [0.9076], [0.9499],
    [Chord],             [0.9063], [0.9542],
    [FedLay],            [0.9056], [0.9639],
    [HEAL],              [0.9001], [0.9687],
  ),
  caption: [Final accuracy by communication method and dataset used. HEAL overlay
  with 5 hubs, each node sends its model to one hub (fault and churn free
  scenario).],
) <tab:all_results>

== Conclusion

In this paper we introduced HEAL protocol for decentralized learning that
combines the convergence speed of Federated Learning with the resilience to
churn and failures of Gossip and Epidemic Learning. Our simulation results
(summarized in @tab:all_results) show that, on the MNIST dataset, HEAL (with 5
hubs) achieves an accuracy 136% higher than Gossip Learning, 106% higher than
Epidemic Learning and 99% of the accuracy of the baseline Federated Learning.
HEAL achieves an accuracy of 0.95 in 76 cycles, which is one cycle slower than
Gaia, and much faster than random graph methods, which achieve this value in 5
times as many cycles. By setting HEAL with 7 hubs and the number of hubs to
which each node sends its model at 3, it is possible to reduce it to 33 cycles,
which is 2.3 times faster than Gaia (the second best result). Our protocol
continues to operate in the presence of faults, and in each fault scenario, the
final accuracy is at most equal to 98% of the accuracy in a fault-free context.
HEAL paves the way for a new approach to decentralized learning, featuring a
cross-layer approach. Our future work will focus on adapting HEAL to
heterogeneous environments, enhancing its robustness against various attacks
(e.g. poisoning attacks, model attacks, etc).