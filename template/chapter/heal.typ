#import "@preview/cetz:0.4.2"

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/lovelace:0.3.0": *

#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
#show: show-theorion

// = Hub-Based Decentralized Learning <chap:heal>
= Efficient and Resilient Decentralized Learning Protocols <chap:heal>

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
}), alt: "Layered architecture diagram of HEAL showing four stacked layers: Network, Overlay, Aggregation, and Application", caption: [Layered architecture of HEAL]
) <fig:system-architecture>

==== Network Layer

The Network Layer forms the foundation of the HEAL protocol stack. It is responsible for low-level peer-to-peer communication, providing the basic message passing primitives upon which all higher layers depend. This layer directly implements the network assumptions formalized in @chap:model. In particular, we assume the underlying network is connected, reliable, and provides bidirectional communication channels between nodes.

For all practical purposes, the Network Layer is equivalent to a standard TCP/IP stack. Each node is identified by a unique network address (e.g., an IP address and port), and messages are transmitted over reliable, bidirectional channels that guarantee in-order delivery without loss or corruption. This abstraction aligns with our modeling assumptions, where message transmission is treated as instantaneous and reliable, allowing us to focus on overlay-level protocols without accounting for network-level failures.

The Network Layer exposes two primary operations to the layer above:
- `send(peer_id, message)`: transmits a message to a specified peer identified by its network address,
- `receive()`: listens for incoming messages and delivers them to the upper layer for processing.

By delegating all physical networking concerns to this layer, HEAL ensures that higher-level components --- overlay maintenance, aggregation, and learning orchestration --- remain agnostic to the underlying transport mechanisms. This separation enables the protocol to operate over any standard network infrastructure without modification, while also allowing future extensions (e.g., support for unreliable transports or encrypted channels) to be implemented at this layer without affecting the rest of the system.

==== Overlay Layer

The Overlay Layer implements the logical topology that enables efficient decentralized learning in HEAL. This layer is powered by the Elevator protocol, whose design and theoretical guarantees are detailed in @chap:elevator. Elevator builds upon the reliable communication primitives provided by the Network Layer to dynamically elect a subset of nodes as *hubs*, forming a structured overlay with desirable properties for model dissemination and aggregation.

Elevator operates in a fully decentralized manner and converges within $O(log N)$ communication cycles, where $N$ is the network size. The protocol is resilient to node churn and failures: the departure or crash of any individual node --- including a hub --- does not compromise the overlay's connectivity, as replacement mechanisms automatically restore the desired topology.

The overlay exposes two configurable global parameters:
- $c in NN^*$: the total size of each node's partial view, i.e. the number of outgoing connections it maintains,
- $h in NN^*$ with $c > h$: the number of preferential connections maintained by each node, targeting the most connected peers in the neighborhood.

Each node maintains a partial view of $c$ outgoing connections to other nodes, structured as follows:
- $h$ preferential connections, targeting the most connected peers discovered in the local neighborhood,
- $c - h$ connections to randomly selected peers, refreshed periodically to ensure good mixing properties.

As an emergent property of this local attachment rule, exactly $h$ nodes spontaneously rise to hub status at the system level, forming a dense interconnected core to which all other nodes maintain a direct outgoing connection.

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

HEAL is designed to support any supervised machine learning model (as defined in @def:supervised-ml, given in the Appendix, @sec:appendix_ml), without imposing structural constraints on the model architecture. Linear regressors, support vector machines, and deep neural networks are all valid instantiations, provided that three conditions are satisfied. First, the model must be trainable via gradient descent, as local training relies on iterative parameter updates driven by a differentiable loss function. Second, each node must hold a local dataset partitioned into a training set, used to update the model parameters, and a test set, used to evaluate model quality independently of the training process. Third, all nodes must represent their models in a compatible parameter format, so that model averaging during the aggregation phase is well-defined.

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

// == Simulation-Based Evaluation

// Having established the design and theoretical properties of HEAL, we now turn to its empirical
// evaluation. The protocol is assessed through simulation, which allows us to control network
// conditions, vary key parameters, and measure convergence behavior in a reproducible setting. This section describes the experimental setup and results.

=== Experimental setup

Having established the design and theoretical properties of HEAL, we now turn to its empirical
evaluation. The protocol is assessed through simulation, which allows us to control network
conditions, vary key parameters, and measure convergence behavior in a reproducible setting. 

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
classification, as defined in the Appendix (@def:binary-classification and
@def:multinomial-classification, given in @sec:appendix_ml). Binary classification constitutes a straightforward
baseline that allows us to verify the correctness of the protocol, whilst multinomial
classification is more complex, enabling us to compare our protocol more precisely with
other decentralised protocols.

The binary classification task is evaluated on the Spambase dataset (@sec:datasets), which
comprises 4601 samples split into 90% for training and 10% for testing. We use a logistic
regression model (@def:logistic-regression, given in the Appendix, @sec:appendix_ml) — a simple model that is sufficient for this
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

// @tab:baselines summarises the valid combinations of topology and aggregation strategy
// considered in our evaluation.

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
cycles, on the two learning tasks (Spambase, MNIST). As shown in @fig:AccuracySpambase and
@fig:AccuracyMNIST, when there are no failures in the network, Federated
Learning performs best, which was expected. Surprisingly, the ring topology
performs second best despite lower connectivity.
Other topologies based on random graphs perform less well. HEAL, however,
performs very well for both the Spambase and MNIST datasets.

#grid(
    columns: 1,
    [
#figure(
        image("../../Images/HEAL/normal_accuracy_Spambase_color.svg", width: 90%),
        caption: [Accuracy of various communication protocols, with a network of 100 nodes, during 1000 cycles. HEAL overlay has 5 hubs, each node sends its model to one hub, for the Spambase dataset, no failures],
      ) <fig:AccuracySpambase>
    ],
    [
#figure(
        image("../../Images/HEAL/normal_accuracy_MNIST_color.svg", width: 90%),
        caption: [Accuracy of various communication protocols, with a network of 100 nodes, during 1000 cycles. HEAL overlay has 5 hubs, each node sends its model to one hub, for the MNIST dataset, no failures],
      ) <fig:AccuracyMNIST>
    ])
    
In @tab:all_results, @tab:results-spambase and @tab:results-mnist we have compiled the results for all learning algorithms,
for the two learning tasks, with the final accuracy obtained after 1000 cycles.
Federated Learning, Gaia, and HEAL have very similar results, with a final
accuracy of around 0.88 on Spambase, and 0.95 on MNIST. Gossip-based approaches
achieve values of 0.85 and 0.91 on Spambase and MNIST.

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

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, center, center),
    table.header(
      [*Method*], [*0.85*], [*0.90*],
    ),
    [Federated Learning],                                    [2],   [135],
    [Gaia (5 servers)],                                      [6],   [N/A],
    [Gossip Learning],                                       [N/A], [N/A],
    [Epidemic Learning],                                     [12],  [25],
    [Ring],                                                  [13],  [141],
    [Chord],                                                 [12],  [27],
    [FedLay],                                                [12],  [26],
    [HEAL (5 hubs, $s=1$)],                                  [4],   [339],
  ),
  caption: [Number of cycles required to achieve different accuracy levels on the Spambase
  dataset, for a network of 100 nodes, without failures. N/A indicates that the protocol
  did not achieve the target accuracy within 1000 cycles.],
) <tab:results-spambase>

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left, center, center, center),
    table.header(
      [*Method*], [*0.85*], [*0.90*], [*0.95*],
    ),
    [Federated Learning],                                    [22],  [37],  [91],
    [Gaia (5 servers)],                                      [13],  [28],  [88],
    [Gossip Learning],                                       [N/A], [N/A], [N/A],
    [Epidemic Learning],                                     [90],  [137], [372],
    [Ring],                                                  [74],  [157], [569],
    [Chord],                                                 [98],  [159], [451],
    [FedLay],                                                [89],  [136], [422],
    [HEAL (5 hubs, $s=1$)],                                  [15],  [27],  [76],
    [HEAL (7 hubs, $s=3$)],                                  [5],   [10],  [33],
  ),
  caption: [Number of cycles required to achieve different accuracy levels on the MNIST
  dataset, for a network of 100 nodes, without failures. N/A indicates that the protocol
  did not achieve the target accuracy within 1000 cycles.],
) <tab:results-mnist>

Convergence time is very fast for aggregator-based approaches: on Spambase,
Federated Learning converges to 0.85 in 2 cycles, and HEAL takes 4 cycles. On
the other hand, to converge on 0.90 accuracy, HEAL takes 339 cycles while
Federated Learning takes 135 cycles, hinting at possible HEAL optimization,
e.g. adjusting the learning rate.
On MNIST, HEAL performs very well, even better than Federated Learning, and it
converges to 0.95 accuracy in 76 cycles.

// ==== HEAL parameterized with number of hubs and number chosen hubs:

We ran simulations changing the number of hubs over 2000 cycles. On
@fig:AccuracyVariousNbHubs, we observe that increasing the number of hubs (and
the number of hubs to which clients send their model) has almost no impact on
accuracy, which is expected since hubs aggregate models. There is a slight drop
in accuracy when the number of hubs is increased significantly, due to the fact
that only non-hubs are learning, not hubs. Increasing the number of hubs to
which we send our model, from 1 to $"nb_hubs"/2$, slightly increases
convergence speed.

#figure(
  image("../../Images/HEAL/various_hub_accuracy_MNIST_color.svg", width: 90%),
  caption: [HEAL with different numbers of hubs (_h_), from 1 to 25, each
  node sent its model to (_s_) hubs, with (_s_) equals to 1 or $h/2$,
  no failures, 2000 cycles],
) <fig:AccuracyVariousNbHubs>

We have computed the number of models exchanged by cycle for each algorithm. The results match the theoretical values, and we have summarized the results in the @tab:nb_messages_compute. HEAL is very close to Federated Learning, with a number of models sent equal to 210, compared with 198 for Federated Learning. Epidemic Learning is much higher, with 1000 messages per cycle. 

#figure(
  table(
    columns: (auto, auto),
    align: (left, center),
    table.header(
      [*Algorithm*], [*Messages per cycle*],
    ),
    [Federated Learning],        [198],
    [Gaia],                      [210],
    [Gossip Learning],           [100],
    [Epidemic Learning],         [1000],
    [Epidemic Learning on ring], [200],
    [Epidemic Learning on Chord],[1000],
    [FedLay],                    [956],
    [*HEAL*],                    [*210*],
  ),
  caption: [Number of models exchanged per cycle for each protocol, with $n = 100$,
  $c = 10$, $h = 5$, and $s = 1$.],
) <tab:nb_messages_compute>

// ==== Crashes-prone environment
==== Learning despite crashes

We analyze the performance of the algorithms when the network suffers crashes.
To simulate a brutal failure we disconnected 20% of the nodes chosen uniformly
at random, just after the start of the learning process, i.e., in this case, we
have disconnected 20 nodes at cycle 10, and we compared HEAL with Chord, Gaia
and Fedlay. HEAL is the algorithm with the best results, although Gaia remains
very close, as seen in @fig:AccuracyCrash20peers.

#figure(
  image("../../Images/HEAL/crash20peers_accuracy_MNIST_color.svg", width: 90%),
  caption: [Accuracy of various communication protocols, with a network of 100 nodes, during 1000 cycles. HEAL overlay has 5 hubs, each node sends its model to one hub. for the MNIST dataset, when 20\% of the nodes fail at cycle 10],
) <fig:AccuracyCrash20peers>

We also compared HEAL subjected to different level of crashes (20%, 30%, 40%, 50%), as seen in the @fig:AccuracyCrashVarious. HEAL remain resilient even under a crash level of 50%.
We have summarized our results in @tab:results-crash. The final accuracy, at cycle n°200, is very close to the accuracy obtained without crashes for a crash level of 20\%. For greater crash level, the drop in accuracy is greater, but the algorithm still manages to converge. For a crash level of 40%, accuracy reaches 0.9, in a number of cycles of 107.

#figure(
  image("../../Images/HEAL/hub_learning_crash_accuracy_MNIST_color.svg", width: 90%),
  caption: [Accuracy of HEAL for the MNIST dataset for different levels of crash, with 100 nodes and 5 hubs, each node sent its model to one hub, 200 cycles],
) <fig:AccuracyCrashVarious>

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left, left, center, center),
    table.header(
      [*Method*], [*Fault scenario*], [*Final accuracy \ (cycle 200)*], [*Cycles to \ 0.90 accuracy*],
    ),
    [Gaia (5 servers)],       [20% node crash], [0.9637], [37],
    [Chord],                  [20% node crash], [0.9520], [53],
    [FedLay],                 [20% node crash], [0.9563], [51],
    [FedLay],                 [30% node crash], [0.9540], [51],
    [FedLay],                 [40% node crash], [0.9521], [51],
    [FedLay],                 [50% node crash], [0.9537], [51],
    [HEAL (5 hubs, $s=1$)],   [20% node crash], [0.9658], [30],
    [HEAL (5 hubs, $s=1$)],   [30% node crash], [0.9178], [59],
    [HEAL (5 hubs, $s=1$)],   [40% node crash], [0.8987], [107],
    [HEAL (5 hubs, $s=1$)],   [50% node crash], [0.8719], [N/A],
    [HEAL (5 hubs, $s=1$)],   [1 hub crash],    [0.9638], [28],
    [HEAL (5 hubs, $s=1$)],   [5 hub crash],    [0.9629], [28],
  ),
  caption: [Accuracy after a crash occurring at cycle 10, on the MNIST dataset. Final
  accuracy is measured at cycle 200. N/A indicates that the protocol did not achieve
  the target accuracy within the simulation.],
) <tab:results-crash>

==== HEAL under churn environment and hub-targeted attacks

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

#figure(
  image("../../Images/HEAL/hub_learning_accuracy_allcontexts_color.svg", width: 90%),
  caption: [HEAL for all contexts (no failures, crash of 20 peers, crash
  of 1 hub, crash of all hubs, churn), with 5 hubs, each node sent its
  model to one hub, 200 cycles],
) <fig:AccuracyContexts>

We also compared HEAL subjected to different level of churn (10%, 20%, 30%), as seen in the @fig:AccuracyChurnVarious. HEAL remain resilient even under a churn level of 30%. The accuracy level drops sharply during the churn phase, but rises again almost immediately when the churn is over.

#figure(
  image("../../Images/HEAL/hub_learning_churn_accuracy_MNIST_color.svg", width: 90%),
  caption: [Accuracy of HEAL for the MNIST dataset for different levels of churn, with 100 nodes and 5 hubs, each node sent its model to one hub, 200 cycles.],
) <fig:AccuracyChurnVarious>

We have summarized our results in @tab:results-churn. The final accuracy, at cycle n°200, is very close to the final accuracy obtained without churn, even for a churn level of 30%. We also computed the mean drop level of accuracy during churn. With a churn level of 30\%, the drop is 0.28, which is sharp, but the final accuracy is not affected.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left, left, center, center),
    table.header(
      [*Method*], [*Churn context*], [*Final accuracy \ (cycle 200)*], [*Mean accuracy \ drop during churn*],
    ),
    [HEAL (5 hubs, $s=1$)], [10% churn], [0.9507], [0.0955],
    [HEAL (5 hubs, $s=1$)], [20% churn], [0.9477], [0.1777],
    [HEAL (5 hubs, $s=1$)], [30% churn], [0.9500], [0.2767],
    [FedLay],               [10% churn], [0.9510], [0.0045],
    [FedLay],               [20% churn], [0.9505], [0.0140],
    [FedLay],               [30% churn], [0.9501], [0.0232],
  ),
  caption: [Final accuracy at cycle 200 under churn conditions between cycles 50 and 150,
  on the MNIST dataset.],
) <tab:results-churn>

=== Summary

The experimental results demonstrate that HEAL achieves competitive learning performance
whilst providing resilience properties that centralised and gossip-based approaches cannot
offer simultaneously.

In a fault-free environment, HEAL reaches a final accuracy of 0.90 on Spambase and 0.97
on MNIST, comparable to Federated Learning (0.91 and 0.97) and significantly above
gossip-based approaches such as Gossip Learning (0.83 and 0.71). In terms of convergence
speed on MNIST, HEAL ($s=1$) reaches 0.95 accuracy in 76 cycles, faster than all
gossip-based baselines, and HEAL ($s=3$) further reduces this to 33 cycles, outperforming
even Federated Learning (91 cycles). The number of models exchanged per cycle remains
low (210), close to Federated Learning (198) and far below Epidemic Learning (1000).

Under crash conditions, HEAL maintains a final accuracy of 0.97 even after 20% of nodes
fail, and remains functional up to a crash level of 50%. Crucially, hub-targeted attacks
— including the simultaneous failure of all 5 hubs — have no measurable impact on
accuracy, thanks to the hub re-election mechanism provided by the Elevator overlay. This
confirms that HEAL has no single point of failure, in contrast to Federated Learning and
Gaia, where server failure unconditionally halts training.

Under churn, HEAL experiences a temporary accuracy drop during the churn phase, but
recovers to its pre-churn level almost immediately once churn subsides. Even at a churn
rate of 30%, the final accuracy at cycle 200 remains above 0.95, demonstrating the
robustness of the protocol under the dynamic membership conditions typical of real
peer-to-peer networks.

== FLAIR Protocol

A key claim of HEAL's layered architecture is that each layer can be substituted
independently, yielding a different protocol without redesigning the system from scratch.
To validate this modularity, we present FLAIR (_Federated Learning with Adaptive
Integrity-preserving Randomness_), an alternative instantiation of the same architecture
targeting wireless edge networks.

FLAIR departs from HEAL in three layers. At the network layer, FLAIR operates over
WiFi rather than a general-purpose internet overlay. At the overlay layer, nodes are
organised into clusters using a protocol inspired by LEACH @heinzelman2000energy, a
well-known cluster-based routing protocol designed for energy-constrained networks, in
which cluster heads are elected periodically and rotate among nodes. At the aggregation
layer, model aggregation is performed locally within each cluster, rather than globally
across all hubs as in HEAL. This design reduces communication costs and is well-suited
to scenarios where nodes are geographically or topologically grouped.

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
    "Learning Task Layer",
  )
  let details = (
    "Reliable packet delivery\nover wireless (IEEE 802.11)",
    "Resource-aware cluster\nformation & head election",
    "Local aggregation within\nclusters by cluster-heads",
    "Supervised ML models\n(classification, regression, ...)",
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
}), alt: "Layered architecture diagram of FLAIR showing four stacked layers: Network, Overlay, Aggregation, and Learning Task", caption: [Layered architecture of FLAIR]
) <fig:flair-architecture>

=== FLAIR Architecture

==== Network Layer

The Network Layer forms the foundation of the FLAIR protocol stack. It is
responsible for low-level wireless communication, providing the basic message passing
primitives upon which all higher layers depend. Unlike HEAL, which operates over a
standard TCP/IP infrastructure, FLAIR targets infrastructure-less ad-hoc wireless
networks where nodes communicate over a shared wireless medium, without relying on any
fixed network infrastructure.

Each node is equipped with a wireless interface compliant with the IEEE 802.11 standard @ieee802.11-2024
and can only communicate directly with nodes within its transmission range. Communication
is therefore inherently single-hop: a node cannot relay messages through intermediaries
at this layer. This constraint shapes the overlay design, as cluster members communicate
directly with their cluster-head, and cluster-heads broadcast directly to their members,
without any inter-cluster coordination at the communication level.

Nodes are heterogeneous in both their computational resources (CPU, memory) and their
communication capabilities (bandwidth, transmission range). Each node is identified by its wireless interface address. The Network Layer exposes the same two primitive operations as in HEAL:

#list(
  [`send(peer_id, message)`: transmits a message to a peer within direct wireless range,],
  [`receive()`: listens for incoming messages and delivers them to the upper layer for processing.],
)

==== Overlay Layer

The Overlay Layer implements the logical topology that enables efficient decentralized
learning in FLAIR. Rather than relying on a pre-configured or manually maintained
topology, this layer provides a fully decentralized and automatic clustering mechanism
inspired by LEACH @heinzelman2000energy. Built on top of the Network Layer, it
dynamically organizes nodes into clusters and elects a subset of nodes as
*cluster-heads* (CHs), which serve as local aggregation points. The entire process
— from CH election to cluster formation — proceeds autonomously at each round, without
any central coordinator or global knowledge.

The protocol operates in rounds. Two mechanisms are central to its design. First, a
target fraction $p in (0,1)$ of nodes is expected to serve as CHs in each round,
ensuring probabilistic load balancing across the network. Second, every node evaluates a
Verifiable Random Function (VRF) @micali1999verifiable, which produces a random value in
$[0,1]$ that cannot be biased by the node and is publicly verifiable. However, actually
verifying such a value requires an external mechanism that exposes the node's VRF output
(e.g. a public register), which falls outside the scope of this thesis. Under the
fault-free setting considered here, the VRF primarily ensures fairness by making the
election draw unpredictable, while remaining lightweight enough for resource-constrained
environments.

_Phase 1: Cluster-head selection_

Let $G$ be the set of eligible nodes at round $r$. A node $n$ is eligible to become a CH
only if it has not acted as one during the last $1\/p$ rounds. Each eligible node computes
a threshold $T(n)$ and samples $x tilde "Uniform"(0,1)$ through a VRF. Node $n$ elects
itself as CH if $x < T(n)$, where

$
T(n) = cases(
  display(frac(p dot R_n, 1 - p dot (r mod 1/p))) & "if" n in G\,,
  0 & "otherwise,"
)
$

and the resource score $R_n$ is defined as

$
R_n = alpha dot "CPU"_n + beta dot "RAM"_n + gamma dot "GPU"_n + delta dot "BW"_n,
$

with $alpha + beta + gamma + delta = 1$. The four components of $R_n$ are normalized
indicators collected locally by each node from kernel-level system metrics, without
requiring any external coordination:

- $"CPU"_n in [0,1]$: the fraction of CPU capacity currently available on node $n$,
  derived from processor utilization statistics exposed by the operating system kernel,
- $"RAM"_n in [0,1]$: the fraction of available memory on node $n$, obtained from
  the kernel memory subsystem,
- $"GPU"_n in [0,1]$: the fraction of GPU capacity available on node $n$, when a GPU
  is present; set to $0$ otherwise,
- $"BW"_n in [0,1]$: the available wireless bandwidth of node $n$, estimated from
  link-layer statistics reported by the network interface.

Each node computes its own resource score $R_n$ independently and autonomously, using
only local information from its operating system. No global resource monitoring or
centralized collection is required. This weighted combination biases elections toward
resource-rich nodes while preserving the probabilistic load-balancing properties of
LEACH. The VRF ensures that the random draw underlying the election is both
unpredictable and publicly verifiable, preventing a node from biasing its own draw or
manipulating the random process. Within the non-adversarial setting considered here, in
which nodes are assumed to report their resources honestly, this suffices to keep the
election fair and auditable; the resource score $R_n$ itself remains self-reported.
Detecting nodes that would misreport their capabilities (e.g. their actual CPU, RAM,
GPU, or bandwidth) to inflate their election probability is an open and non-trivial
direction for strengthening the protocol.
#figure(
  pseudocode-list(booktabs: true)[
    - target CH ratio: *p*
    - current round: *r*
    - eligibility set: *G*
    - resource vector: *$("CPU"_n, "RAM"_n, "GPU"_n, "BW"_n)$*
    - weights: *alpha, beta, gamma, delta*
    + *for each* node $n in cal(N)$ *in parallel do*
      + *if* $n in.not G$ *then*
        + $T(n) arrow.l 0$
      + *else*
        + $R_n arrow.l alpha dot "CPU"_n + beta dot "RAM"_n + gamma dot "GPU"_n + delta dot "BW"_n$
        + $T(n) arrow.l display(frac(p dot R_n, 1 - p dot (r mod 1/p)))$
      + *end if*
      + $x arrow.l "VRF"_"Uniform"(0,1)$
      + *if* $x < T(n)$ *then*
        + broadcast `CH-ADV`
        + mark $n$ as CH
      + *end if*
    + *end for*
  ],
  caption: [Resource-aware CH selection with verifiable randomness.],
) <alg:ch-selection>

_Phase 2: Cluster formation_

Once CHs have been elected, each CH broadcasts a cluster-head advertisement
(`CH-ADV`) within its transmission range. Non-CH nodes listen for incoming
advertisements, evaluate a distance-based cost for each candidate CH, and join
the most suitable one by sending a `JOIN-REQ` message. The CH responds with a
`JOIN-ACK` and updates its membership list. The outcome is a stable partition of
the network into clusters with balanced resource allocation and minimized
communication costs.

#figure(
  pseudocode-list(booktabs: true)[
    + *for each* non-CH node $u$ *in parallel do*
      + listen for `CH-ADV` beacons; collect candidate set $cal(C)$
      + compute $"cost"(u, c)$ for all $c in cal(C)$
      + $c^* arrow.l arg min_(c in cal(C)) "cost"(u, c)$
      + send `JOIN-REQ` to $c^*$
    + *end for*
    + *for each* CH $c$ *do*
      + *for each* `JOIN-REQ` from $u$ *do*
        + *if* capacity allows *then*
          + send `JOIN-ACK` to $u$
          + update membership list
        + *end if*
      + *end for*
    + *end for*
  ],
  caption: [Cluster formation.],
) <alg:cluster-formation>

The Overlay Layer exposes the following API to the Aggregation Layer above:

#list(
  [`isCH()`: returns `true` if the local node is currently elected as a cluster-head,],
  [`getMembers()`: returns the list of member nodes in the local cluster (CH only),],
  [`getCH()`: returns the address of the cluster-head the local node has joined,],
  [`broadcast(message)`: sends a message to all members of the local cluster (CH only),],
)

==== Aggregation Layer

Once clusters are formed, decentralized learning begins within each cluster
independently, removing the need for any global coordination between clusters. Unlike
HEAL, where hubs exchange aggregated models with one another before redistribution,
FLAIR performs aggregation exclusively at the cluster-head level, with no inter-cluster
communication. Each cluster thus runs a fully self-contained learning process.
This design is made possible by the fact that cluster-heads are re-elected at each
round: although each cluster learns in isolation during a given round, the rotation of
cluster-heads causes the aggregated models to be progressively redistributed across
clusters over successive rounds, ensuring global mixing without any inter-cluster
communication. This point is developed in detail in the architectural properties below.

_Phase 1: Local training_

Every node $u$ trains the current model $bold(w)^((t))$ on its private dataset
$cal(D)_u$ for $E$ local epochs, producing a locally updated model
$bold(w)_u^((t+1))$. Only model updates are shared; raw data always remains private.

_Phase 2: Model aggregation_

Each CH aggregates the updates received from its members using a simple averaging rule (see @def:average-sgd):

$
bold(w)^((t+1)) = frac(1, |cal(S)_c|) sum_(u in cal(S)_c) bold(w)_u^((t+1)),
$

where $cal(S)_c$ is the set of members of cluster $c$. The aggregated model is then
redistributed to all cluster members for the next iteration.

Phases 1 and 2 are repeated for a fixed number of in-cluster learning epochs per round,
denoted $E_"round"$. After each iteration, members receive the aggregated model from
their CH, perform local training, and send updated weights back. This iterative loop
continues until all $E_"round"$ epochs are completed, forming one full round of
in-cluster decentralized learning.

#figure(
  pseudocode-list(booktabs: true)[
    - initial model: *$bold(w)^((0))$*
    - batch size: *$B$*
    - in-cluster epochs: *$E_"round"$*
    + *for each* cluster $c$ *in parallel do*
      + $t arrow.l 0$
      + *for* $e = 1$ *to* $E_"round"$ *do*
        + *for each* member $u in cal(S)_c$ *in parallel do*
          + $bold(w)_u^((t+1)) arrow.l "LocalTrain"(bold(w)^((t)), cal(D)_u, B)$
          + send $bold(w)_u^((t+1))$ to CH
        + *end for*
        + CH computes $bold(w)^((t+1)) arrow.l display(frac(1, |cal(S)_c|)) sum_(u in cal(S)_c) bold(w)_u^((t+1))$
        + CH broadcasts $bold(w)^((t+1))$ to $cal(S)_c$
        + $t arrow.l t + 1$
      + *end for*
    + *end for*
  ],
  caption: [In-cluster decentralized learning.],
) <alg:fl>

=== Architectural properties

The layered architecture of FLAIR directly supports a set of desirable properties for
decentralized learning over wireless networks. Several of these properties are shared
with HEAL, whilst others are specific to the wireless and cluster-based setting.

Model convergence is promoted by the iterative in-cluster aggregation design: within
each cluster, the CH performs repeated averaging over member updates across
$E_"round"$ epochs per round, driving local consensus. Although no global aggregation
occurs between clusters, convergence across the full network is achieved through the
rotation of cluster-heads at every round. Since any node may become a CH in a
subsequent round, locally aggregated models are progressively redistributed across
the network, causing models from different clusters to merge over time without
requiring explicit inter-cluster communication.

The number of in-cluster epochs $E_"round"$ introduces a tunable trade-off: a large
value of $E_"round"$ accelerates local convergence within each cluster but delays
inter-cluster model mixing, as cluster-heads rotate less frequently relative to the
amount of training performed. Conversely, a small value of $E_"round"$ favors rapid
cluster-head rotation and therefore faster global mixing, at the cost of slower local
convergence per round. This parameter allows FLAIR to be adapted to the requirements
of a given deployment.

Fast dissemination is achieved through the combination of in-cluster broadcasting and
CH rotation. Within a cluster, the CH redistributes the aggregated model to all members
in a single broadcast step. Across clusters, the rotation mechanism ensures that
aggregated models gradually propagate throughout the network over successive rounds.

Model agnosticism is preserved by the Aggregation Layer interface, which imposes no
structural constraints on the learning model beyond gradient-based trainability and a
compatible parameter format. FLAIR accommodates any supervised learning model, from
linear classifiers to deep neural networks, in the same manner as HEAL.

Resilience to failures and churn is provided by the clustering protocol. Since
cluster-heads are re-elected at every round using a probabilistic, resource-aware
mechanism, the failure of any individual node — including a current CH — only affects
the current round. A new CH is elected at the start of the following round, and the
learning process resumes automatically without manual intervention or global
coordination.

Scalability and wireless compatibility are native properties of FLAIR's architecture.
The protocol operates entirely over IEEE 802.11 @ieee802.11-2024 wireless links and
requires only single-hop communication within each cluster, making it deployable on
standard Wi-Fi hardware without any additional infrastructure. Since each cluster
operates independently, the protocol scales naturally with the number of nodes:
adding nodes to the network increases the number of clusters or their size, without
introducing any centralised bottleneck.

=== Experimental setup

This section describes the experimental setup used to evaluate FLAIR. We detail the
simulation environment, the learning tasks, the baselines, and the experimental
scenarios considered.

==== Simulation environment

All experiments were conducted using ns-3 @riley2010ns, a discrete-event network simulator that provides faithful modeling of IEEE 802.11 wireless communications, including ad-hoc mode and single-hop transmissions. Unlike Gossipy, which simulates the networking layer whilst performing real model training, ns-3 simulates the full network stack, including wireless channel conditions, interference, and packet scheduling. In our setup, the machine learning component is not simulated: the models are actually trained, and this training is executed directly inside ns-3 (in C++), without resorting to any third-party or external learning framework. All baseline algorithms — as well as the models — are thus included and re-implemented in ns-3 to ensure strict comparability under identical network conditions. The details of this integration are reported in the Appendix (@sec:flair-ns3).

All simulations were run on a dedicated server equipped with two Intel Xeon E5-2660 v3
processors (10 cores, 2 threads per core, 2.6 GHz base frequency), 125 GB of RAM, and
456 GB of storage, running Arch Linux (kernel 6.12.4-arch1-1).

==== Learning tasks

We evaluate FLAIR on two binary classification tasks. Both tasks use a logistic
regression model @hosmer2013applied with cross-entropy loss, and data is partitioned
across nodes such that each node holds a private local subset that never leaves the
device.

The first task uses the Spambase dataset (@sec:datasets), which was also used in the HEAL experiments.

The second task uses the "Predicting Watering the Plants" dataset @nelakurthi2021plants,
a Kaggle dataset tailored for intelligent irrigation systems. It contains 100,000 samples
described by features capturing soil state and ambient conditions (e.g., soil moisture,
temperature, humidity), with a binary label indicating whether watering is required. The
class distribution is 53.6% positive and 46.4% negative, representing a mildly imbalanced
scenario. This dataset was selected to demonstrate the applicability of FLAIR to
real-world edge deployments such as smart farming.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left, left, left, right),
    table.header(
      [*Task*], [*Dataset*], [*Model*], [*Samples*],
    ),
    [Binary classification], [Spambase],              [Logistic regression], [4,601],
    [Binary classification], [Watering the Plants],   [Logistic regression], [100,000],
  ),
  caption: [Summary of the learning tasks used in the FLAIR experiments.],
) <tab:flair-datasets>

==== Baselines

FLAIR is compared against four representative protocols, each capturing a different
architectural paradigm. Centralized Federated Learning @mcmahan2017communication (C-FL)
serves as the canonical client–server baseline, with a single global server aggregating
all updates at each round. Gaia @hsieh2017gaia represents the hierarchical paradigm,
with 5 local servers each coordinating 20 clients. HEAL provides a hybrid
decentralized reference point, with 5 dynamically elected hubs per round performing
two-stage aggregation. Finally, Gossip Learning @ormandi2013gossip represents the fully
decentralized paradigm, where each node contacts 3 random peers per round.

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, left, left),
    table.header(
      [*Protocol*], [*Aggregation*], [*Configuration*],
    ),
    [C-FL],          [Global averaging],       [$E=3$, $eta = 0.01$],
    [Gaia],          [Local + global averaging],[5 local servers, $E=3$],
    [HEAL],          [Hub + inter-hub],         [5 hubs per round],
    [Gossip Learning],[Pairwise averaging],     [3 peers per round],
    [*FLAIR*],       [In-cluster averaging],    [$E_"round"=3$],
  ),
  caption: [Configuration of protocols in Experiment 1.],
) <tab:flair-baselines>

==== Experimental scenarios

Four experiments were designed to assess different aspects of FLAIR's performance.
Performance was assessed in terms of final accuracy, recovery speed, and stability of
convergence. To capture the effect of round duration, two configurations were
considered: longer rounds of $E_"round" = 3$ FL epochs per round, and shorter rounds
of $E_"round" = 1$ FL epoch per round.

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, left, left),
    table.header(
      [*Experiment*], [*Objective*], [*Setup*],
    ),
    [Experiment 1],
      [Comparative evaluation in static networks],
      [100 static nodes; comparison with C-FL, Gaia, HEAL, Gossip Learning],
    [Experiment 2],
      [Resilience to node dropouts],
      [Permanent, temporary, and random crashes (up to 90% nodes); $E_"round"=1$ and $E_"round"=3$],
    [Experiment 3],
      [Impact of mobility on learning performance],
      [5 mobility models; perfect vs. range-limited connectivity],
    [Experiment 4],
      [Smart farming with heterogeneous nodes],
      [80 fixed sensors + 20 mobile robots; Watering the Plants dataset],
  ),
  caption: [Overview of experimental scenarios for FLAIR evaluation.],
) <tab:flair-experiments>

Experiment 1 evaluates learning performance in a static network of 100 nodes under
fault-free and full-connectivity conditions, and is the only experiment that compares
FLAIR with the baselines (C-FL, Gaia, HEAL, and Gossip Learning). Under this setting
every node can reach every other node directly, so that the communication topology
required by each baseline remains faithfully realizable without further adaptation of
the protocols to the radio range. Experiments 2 to 4, described below, evaluate FLAIR
on its own.

Experiment 2 examines resilience under three types of node dropout: permanent crashes,
where nodes leave the system at the start of the second round and do not return;
temporary crashes, where nodes remain inactive for 15 time units (equivalent to 3 rounds
of 5 epochs) before resuming, with repeated failures injected once accuracy begins to
stabilize; and random dropouts, where nodes intermittently disconnect and reconnect
throughout training, creating highly unpredictable availability patterns. As in
Experiment 1, the underlying wireless network is fully connected; the only disruptions
come from the injected node dropouts.

Experiment 3 investigates the effect of node mobility on learning performance. Two
connectivity scenarios are considered. In the perfect connectivity scenario, all nodes
communicate regardless of their physical positions. In the range-limited connectivity
scenario, nodes can only communicate within a fixed transmission radius,
resulting in temporary disconnections as nodes move. Five well-known mobility models
@bai2004survey are simulated: RandomWaypoint, RandomWalk, RandomDirection,
Gauss-Markov, and ConstantVelocity.

Experiment 4 demonstrates FLAIR in a realistic smart farming application, and is not
run under fully connected wireless conditions. The network consists of 80 fixed sensors
that continuously sample environmental parameters (soil moisture, temperature,
humidity), together with 20 mobile robotic nodes that autonomously navigate the field.
Fixed sensors located in the same area interact with one another, forming separate
clusters; radio connectivity between these clusters is not available. Model updates are
propagated from one cluster to another by the mobile robots, which physically carry the
aggregated models as they move across the field, thereby bridging the connectivity gaps
between distant locations. Learning is performed on the Watering the Plants dataset
@nelakurthi2021plants.

=== Results

==== Comparative evaluation in static networks

@fig:flair-comparison shows the accuracy evolution over training cycles in a static network
of 100 nodes. FLAIR achieves the highest final accuracy ($approx 0.91$), surpassing
C-FL, HEAL, and Gossip Learning ($approx 0.90$), and clearly outperforming Gaia
($approx 0.88$). These results demonstrate that the clustering-based design of FLAIR
accelerates convergence whilst sustaining higher steady-state accuracy. Compared to
Gaia, convergence is up to $2.5 times$ faster, and compared to Gossip Learning, the
protocol requires significantly fewer cycles to stabilize. Overall, FLAIR combines the
scalability of decentralized designs with the efficiency of clustering, providing
superior performance in static deployments.

#figure(
  image("../../Images/FLAIR/fl_comparison_100n_100e.svg", width: 90%),
  caption: [Accuracy evolution of FLAIR and baselines in static networks (100 nodes).],
) <fig:flair-comparison>

==== Resilience to node dropouts <sec:flair-dropouts>

@fig:flair-leach_fault_recurring_1epoch, @fig:flair-leach_fault_permanent_1epoch, @fig:flair-leach_fault_random_1epoch, @fig:flair-leach_fault_recurring_3epochs, @fig:flair-leach_fault_permanent_3epochs, and @fig:flair-leach_fault_random_3epochs report the average accuracy evolution under permanent, temporary, and random crashes for both round duration settings ($E_"round" = 1$ and $E_"round" = 3$).
In the baseline case without dropout, FLAIR stabilized around $0.90$ accuracy.

#figure(
  image("../../Images/FLAIR/leach_fault_recurring_1_epoch_per_round.svg", width: 95%),
  caption: [Accuracy evolution of FLAIR under recurring fault conditions (1 epoch per round).],
) <fig:flair-leach_fault_recurring_1epoch>

#figure(
  image("../../Images/FLAIR/leach_fault_permanent_1_epoch_per_round.svg", width: 95%),
  caption: [Accuracy evolution of FLAIR under permanent fault conditions (1 epoch per round).],
) <fig:flair-leach_fault_permanent_1epoch>

#figure(
  image("../../Images/FLAIR/leach_fault_random_1_epoch_per_round.svg", width: 95%),
  caption: [Accuracy evolution of FLAIR under random fault conditions (1 epoch per round).],
) <fig:flair-leach_fault_random_1epoch>

#figure(
  image("../../Images/FLAIR/leach_fault_recurring_3_epochs_per_round.svg", width: 95%),
  caption: [Accuracy evolution of FLAIR under recurring fault conditions (3 epochs per round).],
) <fig:flair-leach_fault_recurring_3epochs>

#figure(
  image("../../Images/FLAIR/leach_fault_permanent_3_epochs_per_round.svg", width: 95%),
  caption: [Accuracy evolution of FLAIR under permanent fault conditions (3 epochs per round).],
) <fig:flair-leach_fault_permanent_3epochs>

#figure(
  image("../../Images/FLAIR/leach_fault_random_3_epochs_per_round.svg", width: 95%),
  caption: [Accuracy evolution of FLAIR under random fault conditions (3 epochs per round).],
) <fig:flair-leach_fault_random_3epochs>

Under permanent crashes, even when 90% of nodes were removed, the system still converged
above $0.88$, as summarized in @tab:flair-test2, demonstrating graceful degradation.
Convergence was slightly faster with longer rounds, as multiple local epochs helped
amortize the impact of node removals.

Temporary crashes caused only short-lived perturbations, with accuracy rapidly recovering
once nodes rejoined and maintaining a trajectory close to the baseline. With
$E_"round" = 3$, the system quickly returned to baseline accuracy, whilst with
$E_"round" = 1$, perturbations persisted longer and induced minor oscillations. An
interesting observation is that once accuracy stabilized, subsequent temporary crashes
had only a marginal effect.

Random crashes proved the most disruptive, especially under the short-round
configuration. At high dropout rates (e.g., 90%), convergence was significantly delayed
and oscillations were frequent. In contrast, with $E_"round" = 3$, the dynamics were
smoother and recovery more stable, since longer aggregation intervals absorbed much of
the instability. Overall, FLAIR consistently maintained accuracy above $0.85$ across all
scenarios, confirming strong resilience even under extreme dropout conditions.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    table.header(
      [*Scenario*],
      table.cell(colspan: 2)[$bold(E_"round" = 3)$],
      table.cell(colspan: 2)[$bold(E_"round" = 1)$],
    ),
    table.header(
      [],
      [*0.80*], [*0.85*],
      [*0.80*], [*0.85*],
    ),
    [Permanent crashes (80%)], [3],  [4],  [5],  [9],
    [Temporary crashes (80%)], [4],  [8],  [6],  [9],
    [Random crashes (80%)],    [4],  [10], [39], [55],
    [Permanent crashes (90%)], [4],  [6],  [8],  [13],
    [Temporary crashes (90%)], [5],  [8],  [7],  [10],
    [Random crashes (90%)],    [12], [29], [/],  [/],
  ),
  caption: [Number of rounds required to reach 0.80 and 0.85 accuracy under different
  dropout scenarios and round duration settings.],
) <tab:flair-test2>

==== Impact of mobility on learning performance

@fig:flair-mobility_perfect and @fig:flair-mobility_range_limited shows the accuracy evolution under both connectivity scenarios across
five mobility models. Under perfect connectivity, mobility had no measurable impact on
convergence speed or final accuracy, which remained comparable to the static network
baseline. When communication was range-limited, occasional disconnections caused minor
perturbations and slightly slower convergence, yet overall accuracy remained within 2%
of the static case, staying above $0.88$ for all mobility patterns. These results
indicate that FLAIR is resilient to mobility effects and that its clustering mechanism
effectively adapts to dynamic topologies.

#figure(
  image("../../Images/FLAIR/mobility_perfect.svg", width: 90%),
  caption: [Accuracy evolution of FLAIR under five mobility patterns with perfect connectivity.],
) <fig:flair-mobility_perfect>

#figure(
  image("../../Images/FLAIR/mobility_range_limited.svg", width: 90%),
  caption: [Accuracy evolution of FLAIR under five mobility patterns with range-limited connectivity.],
) <fig:flair-mobility_range_limited>

==== Smart farming with heterogeneous nodes

@fig:fl_rounds_comparison shows the accuracy evolution under two local update settings. With
$E_"round" = 3$, convergence is faster in early stages, exceeding 70% within 10 epochs,
whilst $E_"round" = 1$ initially converges more slowly but eventually closes the gap.
Both configurations converge near the centralized baseline of 71.9%, with final
accuracies of 71.2% and 71.4% respectively.

#figure(
  image("../../Images/FLAIR/fl_rounds_comparison.svg", width: 90%),
  caption: [Accuracy evolution on the Watering the Plants dataset under the smart
  farming setup (80 fixed sensors + 20 mobile robots). Two local update settings
  ($E_"round" = 1$ vs. $E_"round" = 3$) are compared against the centralized baseline
  (71.9%).],
) <fig:fl_rounds_comparison>

To further validate robustness in realistic deployments, the dropout experiments from
@sec:flair-dropouts were extended to the smart farming setup. The same failure types —
permanent, temporary, and random crashes — were injected under the $E_"round" = 3$
setting, as shown in @fig:flair-smart_fault_permanent, @fig:flair-smart_fault_recurring and @fig:flair-smart_fault_random. These results confirm that the resilience
properties identified in controlled static networks extend to heterogeneous,
application-driven scenarios. Even in the presence of mobility and partial connectivity,
FLAIR demonstrates graceful degradation and rapid recovery, underscoring its
practicality for real-world IoT deployments.

#figure(
  image("../../Images/FLAIR/smart_leach_fault_permanent.svg", width: 95%),
  caption: [Accuracy evolution of FLAIR under permanent fault conditions in the smart farming scenario.],
) <fig:flair-smart_fault_permanent>

#figure(
  image("../../Images/FLAIR/smart_leach_fault_recurring.svg", width: 95%),
  caption: [Accuracy evolution of FLAIR under recurring fault conditions in the smart farming scenario.],
) <fig:flair-smart_fault_recurring>

#figure(
  image("../../Images/FLAIR/smart_leach_fault_random.svg", width: 95%),
  caption: [Accuracy evolution of FLAIR under random fault conditions in the smart farming scenario.],
) <fig:flair-smart_fault_random>

=== Summary

FLAIR demonstrates that the layered architecture introduced in this thesis is genuinely
modular: by substituting the network layer, the overlay protocol, and the aggregation
strategy independently of one another, a protocol well-suited to resource-constrained
ad-hoc wireless networks emerges naturally from the same architectural foundations as
HEAL.

The core contribution of FLAIR lies in its dynamic, resource-aware, and verifiable
cluster-head election mechanism, which facilitates load balancing and enhances system
robustness without requiring any fixed infrastructure. By confining aggregation to the
cluster level and rotating cluster-heads at every round, FLAIR achieves progressive
global model mixing without inter-cluster communication, keeping communication overhead
low whilst preserving convergence.

The experimental evaluation conducted in ns-3 validated these properties across four
scenarios. In static networks, FLAIR achieved faster convergence and higher final
accuracy than C-FL, Gaia, HEAL, and Gossip Learning. Under extreme node dropout
conditions — up to 90% of nodes failing — the protocol demonstrated graceful
degradation, consistently maintaining accuracy above $0.85$. Under all five mobility
models considered, accuracy remained within 2% of the static baseline, confirming
resilience to dynamic topologies. Finally, the smart farming experiment showed that
FLAIR achieves performance near the centralized baseline (71.9%) in a heterogeneous
IoT deployment with fixed sensors and mobile robots.

// Several directions remain open for future investigation. Extending FLAIR to non-IID
// data distributions — through personalized learning or adaptive aggregation rules —
// is a natural next step, as real-world edge deployments rarely satisfy the IID
// assumption. Reinforcing the protocol against Byzantine and malicious nodes is equally
// important, given the open nature of ad-hoc wireless environments. Finally, scaling
// FLAIR to ultra-large networks and exploring hybrid paradigms such as blockchain-based
// aggregation or over-the-air model fusion would broaden its applicability further.

== Conclusion

This chapter presented two original contributions to decentralized learning: HEAL and
FLAIR. Both protocols were designed and evaluated as part of this thesis, and both
instantiate the same layered architecture, demonstrating that cross-layer design is a
principled and productive approach to building decentralized learning systems.

HEAL addresses the fundamental tension between convergence speed and fault resilience by
leveraging the Elevator overlay to dynamically elect hub nodes as distributed
aggregators. Simulation results on the MNIST dataset show that HEAL achieves 99% of the
accuracy of Federated Learning whilst remaining fully decentralized and fault-tolerant.
With 5 hubs, HEAL reaches 0.95 accuracy in 76 cycles — comparable to Gaia and
significantly faster than all gossip-based baselines. With 7 hubs and $s = 3$, this
reduces to 33 cycles, making HEAL $2.3 times$ faster than the second-best result.
HEAL continues to operate in the presence of node crashes, hub failures, and churn,
with final accuracy remaining above 98% of the fault-free baseline in all tested
scenarios. The communication overhead (210 messages per cycle) remains close to that of
Federated Learning (198), and far below gossip-based alternatives.

FLAIR validates the modularity claim of the layered architecture by instantiating it in
a different operational context: resource-constrained ad-hoc wireless networks. By
substituting the Elevator overlay with a resource-aware, verifiable clustering protocol
and confining aggregation to the cluster level, FLAIR yields a protocol with no fixed
infrastructure and no inter-cluster coordination, yet competitive learning performance.
In static networks, FLAIR surpasses all baselines in final accuracy. Under extreme
dropout conditions of up to 90% node failures, it consistently maintains accuracy above
$0.85$. Under five mobility models, accuracy remains within 2% of the static baseline.
In the smart farming scenario, FLAIR approaches the centralized baseline (71.9%) with
final accuracies of 71.2% and 71.4% for $E_"round" = 1$ and $E_"round" = 3$
respectively.

The central finding of this chapter is that the layered architecture itself is the
primary contribution: HEAL and FLAIR are two existence proofs that the same design
principles — separation of concerns, modular substitution, and cross-layer composability
— can yield protocols adapted to fundamentally different deployment contexts without
redesigning the system from scratch. This opens a broad research avenue, as future
protocols targeting other network environments (satellite networks, vehicular networks,
underwater sensor networks) could be designed by composing existing or new layer
implementations within the same framework.

Several directions remain open. Both protocols currently assume IID data distributions;
extending them to non-IID settings through personalized aggregation or adaptive
weighting is a natural next step. Reinforcing both protocols against Byzantine and
adversarial nodes — including model poisoning and inference attacks — is equally
important for real-world deployments. Finally, a formal convergence analysis of FLAIR
under non-stationary cluster topologies, and of HEAL under non-IID data, would
strengthen the theoretical foundations of both contributions.

// In this paper we introduced HEAL protocol for decentralized learning that
// combines the convergence speed of Federated Learning with the resilience to
// churn and failures of Gossip and Epidemic Learning. Our simulation results
// (summarized in @tab:all_results) show that, on the MNIST dataset, HEAL (with 5
// hubs) achieves an accuracy 136% higher than Gossip Learning, 106% higher than
// Epidemic Learning and 99% of the accuracy of the baseline Federated Learning.
// HEAL achieves an accuracy of 0.95 in 76 cycles, which is one cycle slower than
// Gaia, and much faster than random graph methods, which achieve this value in 5
// times as many cycles. By setting HEAL with 7 hubs and the number of hubs to
// which each node sends its model at 3, it is possible to reduce it to 33 cycles,
// which is 2.3 times faster than Gaia (the second best result). Our protocol
// continues to operate in the presence of faults, and in each fault scenario, the
// final accuracy is at most equal to 98% of the accuracy in a fault-free context.
// HEAL paves the way for a new approach to decentralized learning, featuring a
// cross-layer approach. Our future work will focus on adapting HEAL to
// heterogeneous environments, enhancing its robustness against various attacks
// (e.g. poisoning attacks, model attacks, etc).