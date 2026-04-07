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
    // [*Dynamic (Elevator @legheraba2024emergent)*],
    [*Dynamic (Elevator)*],
    [*Yes*], [*Yes*], [*quick, using hubs*],
  ),
  caption: [Comparison of different decentralized learning algorithms.],
) <tab:all_algorithm>

== HEAL Protocol

=== Desired Properties <sec:heal-desired-properties>

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

==== Aggregation Layer

The Aggregation Layer defines the strategy by which locally trained models are combined into a global model and redistributed across the network. As surveyed in @chap:learning, the literature offers a variety of aggregation strategies for decentralized learning, ranging from gossip-based averaging to more structured federated approaches. These strategies differ in their communication patterns, convergence guarantees, and tolerance to heterogeneous data distributions.

HEAL adopts an aggregation design inspired by Federated Learning @mcmahan2017communication, but departs from the classical single-server assumption by distributing the aggregation responsibility across multiple coordinators. Specifically, HEAL leverages the hub set maintained by the Overlay Layer to instantiate $h$ concurrent aggregators, where $h$ is a global parameter of the underlying Elevator protocol. This design choice directly addresses the single point of failure inherent to centralized federated approaches, and distributes the aggregation load evenly across the network.
Each node in the network executes the HEAL aggregation learning protocol, in addition to the Elevator protocol (that dynamically assigns "normal" (client) or "hub" (server) status to the participating nodes).

The aggregation process unfolds in five successive phases.

1. *Local training.* Each non-hub node trains its current model on its local dataset, producing an
   updated set of parameters ready for aggregation.

2. *Model transfer.* Each non-hub node selects $s$ hubs uniformly at random and transmits its
   current local model to these hubs (with $s$ a global parameter of the protocol). This randomized
   assignment ensures that the incoming load is balanced across all hubs in expectation.

3. *Hub aggregation.* Upon receiving model submissions, each hub waits for a configurable delay
   $delta in RR^+$ before proceeding. This window allows the hub to collect contributions from a
   sufficient number of nodes before aggregating. After the delay, each hub independently computes a
   local aggregate from the models it has received, using Average SGD (as defined in @def:average-sgd).

4. *Inter-hub coordination.* Once local aggregation is complete, all hubs enter a synchronous
   coordination phase. Since hubs form a complete graph --- every hub is connected to every other hub
   by construction of the Elevator overlay --- each hub broadcasts its local aggregate to all other
   hubs and receives their aggregates in return. Each hub then computes the global model from the
   full set of hub aggregates (again, using Average SGD). Because all hubs perform this computation
   on the same inputs, the resulting global model is identical across all hubs.

5. *Redistribution.* Finally, each hub transmits the global model back to the non-hub nodes that
   submitted their local model to it during the model transfer phase. Since each non-hub node has
   submitted its model to $s$ hubs, and all hubs compute an identical global model during the
   inter-hub coordination phase, each node receives $s$ copies of the same global model. The node
   retains the first received copy and discards the remaining ones, then proceeds to the next
   training round.

This five-phase process is repeated over successive rounds until the global model converges,
mirroring the iterative communication structure of Federated Learning @mcmahan2017communication.
#figure(
  diagram(
    node-fill: green.lighten(60%),
    node-stroke: 1pt,
    {
      let dash_node = (paint: green, dash: "dashed")
      let dash_hub = (paint: blue, dash: "dashed")

      node((-1.1,-1.2), `1) Each node trains a
      local model`,
        stroke: dash_node, inset: 0.5em)
      node((-1.2, -0.1), `2) Each node sends 
      its model to a (random) 
      subset of hubs`,
        stroke: dash_node, inset: 0.5em)
      node(( 2.2,-1.2), `3) Hubs receive 
      and aggregate models`,
        fill: blue.lighten(60%), stroke: dash_hub, inset: 0.5em)
      node(( 2, -0.3), `4) Hubs compute a global 
      model together`,
        fill: blue.lighten(60%), stroke: dash_hub, inset: 0.5em)
      node(( 2.2, 0.5), `5) Hubs send back
      the global model 
      to the nodes`,
        fill: blue.lighten(60%), stroke: dash_hub, inset: 0.5em)

      node((0.00, 0.00), "0", name: <0>, radius: 1em, fill: blue.lighten(60%))
      node((1.00, 0.00), "1", name: <1>, radius: 1em, fill: blue.lighten(60%))
      node((1.22,-1), "2", name: <2>, radius: 1em)
      node((0.6,-1), "3", name: <3>, radius: 1em)
      node((-0.49, 0.66), "4", name: <4>, radius: 1em)
      node((1.14, 0.73), "5", name: <5>, radius: 1em)
      node((-0.11,-0.71), "6", name: <6>, radius: 1em)

      edge(<0>, <1>, "-|>")
      edge(<1>, <0>, "-|>")
      edge(<2>, <0>, "-|>")
      edge(<2>, <1>, "-|>")
      edge(<3>, <0>, "-|>")
      edge(<3>, <1>, "-|>")
      edge(<2>, <3>, "-|>")
      edge(<3>, <6>, "-|>")
      edge(<4>, <0>, "-|>")
      edge(<4>, <1>, "-|>")
      edge(<4>, <6>, "-|>")
      edge(<5>, <0>, "-|>")
      edge(<5>, <1>, "-|>")
      edge(<5>, <6>, "-|>")
      edge(<5>, <3>, "-|>")
      edge(<6>, <0>, "-|>")
      edge(<6>, <1>, "-|>")
      edge(<6>, <5>, "-|>")
    }
  ),
  caption: [HEAL learning protocol: the five phases],
) <fig:heal-aggregation>

The number of aggregators $h$ is inherited directly from the Elevator protocol, making it a tunable parameter that jointly governs overlay topology and aggregation granularity. Increasing $h$ reduces the per-hub load and improves fault tolerance, at the cost of additional inter-hub communication during the reconciliation phase. The parameter $s$ offers a flexibility-redundancy trade-off: setting $s = 1$ minimizes bandwidth usage, while $s > 1$ provides redundancy in the event of hub failures. Since each node contributes its model the same number of times regardless of $s$, the aggregated global model is unaffected by this choice.

In the event of one or more hubs failing during a protocol cycle, the remaining hubs can temporarily manage the nodes without a dedicated hub until a new hub emerges, which typically occurs within two cycles. If all hubs fail simultaneously, the aggregation process halts but resumes as soon as new hubs appear. Elevator also establishes random connections between nodes in addition to hub connections. In HEAL, model aggregation relies solely on hub connections and inter-hub exchanges. These random connections could potentially be exploited to accelerate model convergence or mitigate malicious behavior, but this lies beyond the scope of the present work. We currently assume that all network nodes are honest, and leave the investigation of Byzantine-resilient aggregation to future research.

@algo:HubLearningHub and @algo:HubLearningNode present the detailed pseudo-code of HEAL Aggregation.

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
        + nb_receive $arrow.l$ nb_receive $+ 1$
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
    - number of hubs to send the model to: *s*
    + *loop*
      + model $arrow.l$ trainModel(model, data)
      + hubs $arrow.l$ chooseRandom(hubs_list, s)
      + *for* hub *in* hubs
        + send(hub, model)
      + hubs_models $arrow.l$ list()
      + *for* hub *in* hubs
        + model_hub $arrow.l$ receive()
        + hubs_models.append(model_hub)
      + model $arrow.l$ hubs_models[0]
  ],
  caption: [HEAL Learning: The client algorithm.],
) <algo:HubLearningNode>

The Aggregation Layer exposes two primary artifacts to the Application Layer above: the current model, updated at the end of each aggregation round, and access to the node's local dataset, which the Application Layer uses to drive the local training loop.

==== Application Layer

The Application Layer constitutes the topmost component of the protocol stack, interfacing with the Aggregation Layer to retrieve the current global model and contribute locally trained updates. In HEAL, the application is a machine learning model itself, as formally defined in @chap:learning.

HEAL is designed to support any supervised machine learning model (as defined in @def:supervised-ml), without imposing structural constraints on the model architecture. Linear regressors, support vector machines, and deep neural networks are all valid instantiations, provided that three conditions are satisfied. First, the model must be trainable via gradient descent, as local training relies on iterative parameter updates driven by a differentiable loss function. Second, each node must hold a local dataset partitioned into a training set, used to update the model parameters, and a test set, used to evaluate model quality independently of the training process. Third, all nodes must represent their models in a compatible parameter format, so that model averaging during the aggregation phase is well-defined.

The aggregation function used in HEAL, Average SGD (defined in @def:average-sgd), computes a simple uniform average of the received model parameters. This approach implicitly assumes that the local datasets are independently and identically distributed (IID) across nodes, meaning that each node's data is drawn from the same underlying distribution. While this assumption simplifies the convergence analysis and is standard in introductory federated learning literature @mcmahan2017communication, it does not always hold in practice: nodes in a real deployment may hold data with significantly different statistical properties, a setting commonly referred to as non-IID or heterogeneous data. The study of decentralized learning under non-IID data distributions, and the design of aggregation strategies robust to such heterogeneity, lie beyond the scope of this thesis and are left as directions for future work.

In practice, model size imposes implicit constraints on both local computation and network transfer costs. Large models require more memory, longer training times, and higher communication bandwidth. HEAL does not address these engineering concerns directly; the model is treated as an abstract parameterized function throughout the protocol. In our simulations, we restrict experiments to small-scale models for practical reasons, but nothing in the protocol design precludes the use of larger architectures.

Once the iterative training process has converged and a satisfactory global model has been reached, the HEAL protocol is no longer needed. Each node retains its local copy of the global model and can use it autonomously for inference, without any further communication with the rest of the network.

// === From architecture to properties
=== Architectural properties

The layered architecture presented in the preceding subsection directly supports the desired properties
established in @sec:heal-desired-properties. Model convergence follows from the aggregation design:
by distributing the federated averaging computation across $h$ concurrent hubs and ensuring that all
hubs reach an identical global model through the inter-hub coordination phase, HEAL reproduces the
communication structure of FedAvg @mcmahan2017communication and inherits its convergence guarantees
under IID data distributions. Fast dissemination is achieved through the Elevator overlay, whose
$O(log N)$ convergence diameter ensures that model updates propagate to all nodes within a small
number of communication rounds. Model agnosticism is enforced by the Application Layer interface,
which imposes no structural constraints beyond gradient-based trainability and a compatible parameter
format, accommodating any supervised learning model from linear classifiers to deep neural networks.
Resilience to failures and churn is provided by Elevator, which tolerates individual node departures
--- including hub failures --- and restores the desired topology within a bounded number of cycles;
the aggregation process may pause if all hubs fail simultaneously, but resumes automatically once
new hubs are elected. Finally, resource efficiency and algorithmic simplicity are reflected in the
two-phase aggregation design: each non-hub node transmits its model to at most $s$ hubs per round,
and the hub algorithm requires no coordination beyond a single broadcast among hubs, keeping both
communication overhead and implementation complexity minimal.

=== Communication overhead

The number of models exchanged per cycle varies depending on the topology type and the
aggregation algorithm used. We derive the theoretical message count for each framework
as follows. In Federated Learning, each of the $n-1$ non-server nodes sends its local
model to the server, which then broadcasts the aggregated global model back to all $n-1$
nodes, yielding $2(n-1)$ exchanges per cycle. In Gossip Learning, each node sends its
model to one neighbor per cycle, resulting in $n$ exchanges in total. Epidemic Learning
follows the same principle, except that each node contacts all $c$ of its outgoing
neighbors, giving $n dot c$ exchanges. For HEAL, the exchange proceeds in three steps:
first, each of the $n-h$ non-hub nodes sends its model to $s$ hubs, contributing
$(n-h) dot s$ messages; the hubs then exchange their aggregated models with one another,
producing $h(h-1)$ messages; finally, each hub redistributes the global model back to
the $n-h$ non-hub nodes that contributed to it, adding another $(n-h) dot s$ messages.
The total per-cycle overhead for HEAL is therefore $2(n-h) dot s + h(h-1)$.

#figure(
  table(
    columns: (auto, auto),
    align: (left, center),
    table.header(
      [*Aggregation framework*], [*Number of messages per cycle*],
    ),
    [Federated Learning],  [$2(n-1)$],
    [Gossip Learning],     [$n$],
    [Epidemic Learning],   [$n dot c$],
    [*HEAL*],              [$2(n-h) dot s + h(h-1)$],
  ),
  caption: [Comparison of decentralised learning frameworks in terms of communication
  overhead per cycle, where $n$ is the total number of nodes (including server\/hubs),
  $c$ is the number of outgoing connections, $h$ is the number of hubs, and $s$ is the
  number of hubs to which each node sends its model.],
) <tab:nb-messages>

== Simulation-Based Evaluation

Having established the design and theoretical properties of HEAL, we now turn to its empirical
evaluation. The protocol is assessed through simulation, which allows us to control network
conditions, vary key parameters, and measure convergence behavior in a reproducible setting. This section describes the experimental setup and results.

=== Experimental setup

This section describes the experimental setup used to evaluate HEAL. We detail the
simulation environment, the learning tasks, the baselines, the configuration of each
protocol, and the fault scenarios considered.

==== Simulation environment

All experiments were conducted using Gossipy #footnote[https://github.com/makgyver/gossipy],
a cycle-based peer-to-peer learning simulator. In Gossipy, each cycle consists of every
node sequentially executing the protocol. The learning component is not simulated —
models are trained using real gradient updates via PyTorch @ketkar2021introduction — while the networking layer
is fully simulated: nodes are Python objects with direct in-memory access, and all model
exchanges are virtual. This design allows for reproducible and controlled experiments
without the overhead of a real network infrastructure.

By default, Gossipy only supports static topologies defined ahead of time. To accommodate
dynamic topologies, we integrated it with the PeerSim simulator @p2p09-peersim, which
handles dynamic peer sampling and topology evolution. At each cycle, the graph generated
by PeerSim is retrieved and passed to Gossipy, which uses it to determine the virtual
connections between nodes and consequently the aggregation partners for that cycle.

All simulations were run on 16 vCPU, using 64G of memory, on a cluster composed of 10 servers, already described in @table-cluster.

==== Learning Tasks

We evaluate our protocol on two learning tasks: 1) binary classification and 2) multinomial
classification, as defined in the previous chapter (@def:binary-classification and
@def:multinomial-classification). Binary classification constitutes a straightforward
baseline that allows us to verify the correctness of the protocol, whilst multinomial
classification is more complex, enabling us to compare our protocol more precisely with
other decentralised protocols.

The binary classification task is evaluated on the Spambase dataset (@sec:datasets), which
comprises 4601 samples split into 90% for training and 10% for testing. We use a logistic
regression model (@def:logistic-regression) — a simple model that is sufficient for this
dataset — with 57 parameters (excluding the bias) and a binary output. The model is
trained using SGD with a learning rate of $0.1$ and a batch size of 32.

The multinomial classification task is evaluated on the MNIST dataset (@sec:datasets),
which provides 60,000 training images and 10,000 test images. We use a LeNet5
@lecun1989backpropagation convolutional neural network, originally designed for this dataset, with approximately 60,000 parameters and an output over 10 classes. The model is trained using the Adam optimiser @kingma2014adam with a learning rate of $0.001$, a weight decay of $0.01$, and a batch size of 32.

In both cases, the dataset is partitioned across the network nodes in an IID fashion. The data partition is performed randomly and uniformly across nodes.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left, left, left, right),
    table.header(
      [*Task*], [*Dataset*], [*Model*], [*Parameters*],
    ),
    [Binary classification],      [Spambase], [Logistic regression], [57],
    [Multinomial classification], [MNIST],    [LeNet5],              [60,000],
  ),
  caption: [Summary of the learning tasks and models used in our experiments.],
) <tab:models-summary>

==== Baselines

The decentralised learning protocols considered in the literature were surveyed in
@chap:learning. Revisiting them through the lens of HEAL's layered architecture reveals
that a given protocol is in fact the result of two independent choices: a network topology
and an aggregation strategy. Not all combinations are valid — some aggregation strategies
presuppose a particular topology — but the decomposition clarifies the design space.
Furthermore, a fundamental distinction exists between static and dynamic topologies.
Static topologies are simpler to deploy but offer no resilience to node failures or churn.
Dynamic topologies are more complex to maintain, yet they enable greater model mixing in
gossip-based networks and provide inherent resilience to failures.

@tab:baselines summarises the valid combinations of topology and aggregation strategy
considered in our evaluation.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left, center, center, center),
    table.header(
      [*Topology*], [*Central aggregation*], [*Gossip*], [*Epidemic*],
    ),
    [Star],     [#sym.checkmark (FL)], [#sym.times], [#sym.times],
    [Ring],     [#sym.times], [#sym.checkmark], [#sym.checkmark],
    [Random],   [#sym.times], [#sym.checkmark], [#sym.checkmark],
    [Complete], [#sym.times], [#sym.checkmark], [#sym.checkmark],
    [Elevator], [#sym.checkmark (HEAL)], [#sym.checkmark], [#sym.checkmark],
  ),
  caption: [Valid combinations of network topology and aggregation strategy. #sym.checkmark
  indicates a supported combination and #sym.times an incompatible one. FL denotes
  Federated Learning.],
) <tab:baselines>

The baselines retained for our evaluation cover a representative subset of this design
space: Federated Learning @mcmahan2017communication (star topology with central aggregation), Gossip Learning @ormandi2013gossip and
Epidemic Learning @de2024epidemic (dynamic random topology), Epidemic Learning on a Chord @stoica2001chord topology,
Epidemic Learning on a ring topology, Gaia @hsieh2017gaia (multi-star static topology with central
aggregation), and Fedlay @hua2024towards (dynamic topology). HEAL combines the
Elevator dynamic topology with central aggregation at the hubs level, and is the only
protocol in our evaluation that spans all three aggregation strategies.

==== Configuration

Gossipy natively provides implementations of Federated Learning, Gossip Learning, and
Epidemic Learning. We extended the simulator with the following contributions: Epidemic
Learning on Chord and ring topologies, Gaia, Fedlay, and HEAL. The Elevator component
of HEAL was implemented in PeerSim, while the aggregation logic was implemented directly
in Gossipy. Static topologies (Federated Learning, ring, Chord, and Gaia) were generated
using the NetworkX #footnote[https://networkx.org/] Python library.

In Elevator (used by HEAL), the connections are directional. However,
to compare them with other algorithms (which assume an undirected graph), we
modified the underlying graph of the topology generated to make it undirected.

All evaluations were conducted with a network of 100 nodes. For Elevator, we
used 5 hubs, as we found this number to be a good balance between performance
and resilience. For Gaia, we had 5 servers responsible for aggregation (to
compare with the 5 hubs) and 19 nodes (or workers) attached to each server.
Each algorithm was evaluated 5 times, and we present the average results
obtained.

==== Fault scenarios

HEAL is evaluated under five scenarios. The first is a fault-free baseline, against which
all other scenarios are compared, allowing us to assess the performance of HEAL under
normal operating conditions. The remaining scenarios follow the fault taxonomy introduced
in @chap:elevator, with the exception of Byzantine failures, which are outside the scope
of this thesis for the decentralised learning component.

The second scenario simulates the failure of 20% of nodes, testing whether the protocol
maintains acceptable learning performance when a non-negligible fraction of participants
becomes unavailable. The third and fourth scenarios simulate the failure of a single hub
and the failure of all 5 hubs respectively, verifying that HEAL does not exhibit a single
point of failure — a key design requirement for any decentralised protocol. Finally, the
fifth scenario introduces churn, where 10% of nodes leave the network and are replaced by
new nodes at each cycle, testing whether the protocol remains functional under the
dynamic membership conditions typical of real peer-to-peer networks.

For Federated Learning and Gaia, which are centralised by nature, node failures are
applied exclusively to non-server nodes, as the failure of a server unconditionally halts
training in these protocols. This asymmetry is inherent to their architecture and further
motivates the need for fully decentralised alternatives such as HEAL.
=== Results

==== Learning in a crash-free, churn-free environment

For simulations without failures and churn, we ran all algorithms over 1000
cycles, on the two learning tasks (Spambase, MNIST). As shown in
@fig:AccuracyMNIST, when there are no failures in the network, Federated
Learning performs best, which was expected. Surprisingly, the ring topology
performs second best despite lower connectivity.
Other topologies based on random graphs perform less well. HEAL, however,
performs very well for both the Spambase and MNIST datasets.

#figure(
        image("../../Images/HEAL/normal_accuracy_MNIST_color.pdf", width: 95%),
        caption: [Accuracy of various communication protocols, with a network of 100 nodes, during 1000 cycles. HEAL overlay has 5 hubs, each node sends its model to one hub, for the MNIST dataset, no failures],
      ) <fig:AccuracyMNIST>

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

==== HEAL parameterized with number of hubs and number chosen hubs:

We ran simulations of HEAL, changing the number of hubs over 2000 cycles. On
@fig:AccuracyVariousNbHubs, we observe that increasing the number of hubs (and
the number of hubs to which clients send their model) has almost no impact on
accuracy, which is expected since hubs aggregate models. There is a slight drop
in accuracy when the number of hubs is increased significantly, due to the fact
that only non-hubs are learning, not hubs. Increasing the number of hubs to
which we send our model, from 1 to $"nb_hubs"/2$, slightly increases
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

== LEACH-FL: Alternative Architecture

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