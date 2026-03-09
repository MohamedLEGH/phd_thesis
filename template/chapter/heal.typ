#import "@preview/cetz:0.4.2"

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/lovelace:0.3.0": *

#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
#show: show-theorion

= Hub-Based Decentralized Learning <chap:heal>

Decentralized learning enhances privacy, scalability, and fault tolerance by distributing data and computation across nodes. 
A popular approach is Federated learning, which relies on a central aggregator, yet faces challenges such as server vulnerabilities, scalability issues, privacy risks and most importantly, the single point of failure. Alternatively Gossip Learning and Epidemic Learning  offer fully decentralization through peer-to-peer exchanges of model updates, ensuring robustness and privacy, at the price of slower model convergence. 
In this work, we introduce a novel decentralized learning framework called HEAL. HEAL is the first cross-layer decentralized learning framework that exploits an optimized self-organizing and self-healing underlying P2P overlay combining the strengths of Federated Learning, Gossip and Epidemic Learning.
Leveraging the recently proposed Elevator algorithm, HEAL promotes dynamically chosen nodes to act as aggregators. Through simulations, we demonstrate that HEAL has similar performances to that of Federated Learning in crash-free settings, while being fully decentralized and fault-tolerant. In crash and churn prone environments HEAL outperforms Gossip and Epidemic Learning.

Decentralized learning is an approach to training machine learning models, where the data and computational tasks are distributed across multiple nodes or devices, rather than centralized in a single location. 
This paradigm improves privacy, scalability, and fault tolerance by enabling participants to collaboratively train models without sharing raw data. 
Each node processes its local data and exchanges model updates (e.g., gradients or parameters) with others, using a centralized coordinator or through peer-to-peer communication. Decentralized learning is particularly beneficial in scenarios where data is naturally distributed (such as in edge computing or IoT networks), or when data privacy or resource constraints make centralization impractical. 

The idea of decentralized learning originates from distributed optimization 
and parallel computing. However, it was the advent of Federated Learning 
@mcmahan2017communication that truly brought the concept into the spotlight.

In Federated Learning all participants (nodes or devices) in a network train 
a machine learning model locally on their own data. Subsequently, each 
participant sends its model to a centralized aggregator, which aggregates 
the received models and returns the global model to the nodes. This process 
continues until a satisfactory accuracy is achieved.

While Federated Learning provides an efficient alternative to traditional 
(centralized) machine learning, its dependence on a central server for 
aggregating models introduces several limitations. This centralization creates 
a _single point of failure_. That is, when the server crashes the generation 
of the global model becomes impossible. Furthermore, the single server is an 
easy target for adversarial attacks, such as model poisoning or inference 
attacks @rodriguez2023survey, which can compromise the integrity of the global 
model. Additionally, the server's role poses scalability challenges, as it must 
manage potentially vast numbers of updates from distributed participants, 
leading to communication and computation bottlenecks. More importantly, if the 
server is controlled by a single organization, it could introduce biases or 
favor certain participants' updates, exacerbating inequalities in model 
performance. This phenomenon leads to _learning oligarchy_.

To address these limitations, it is essential to explore totally decentralized 
architectures which do not rely on a central coordinator. Gossip 
Learning @ormandi2013gossip and Epidemic Learning @de2024epidemic are the 
state of the art approaches for fully decentralized machine learning. However, 
the stochastic nature of these protocols can result in slower convergence 
compared to Federated Learning-based approaches @hegedHus2021decentralized. 
It should be noted that in the case of gossip learning, recent research has 
been conducted to enhance its various aspects, such as improving its security 
against privacy attacks @danner2015fully, increasing its efficiency by 
compressing the models sent @danner2020decentralized. More recent studies 
focused on examining the impact of poisoning attacks @pham2024data on various 
gossip learning strategies.

Interestingly, none of the previous decentralized federated approaches had a 
cross-layer design philosophy.

_Our contribution._
In this paper we introduce a novel form of decentralized learning, HEAL (for 
#strong[H]ub #strong[E]nhanced #strong[A]daptive #strong[L]earning), which combines the benefits of
Federated Learning, Gossip and Epidemic Learning (summarized in
@tab:all_algorithm).

HEAL leverages the network overlay created by the newly introduced Elevator
algorithm @legheraba2024emergent that promotes in a totally decentralized and
adaptive manner a prescribed number of participating nodes as hubs (nodes
connected to the entire network). HEAL will use these hubs as aggregator nodes
for the learning task. Unlike traditional federated learning, aggregator nodes
are not pre-selected and hence HEAL becomes extremely resilient to the network
dynamicity (nodes crashes and churn). That is, HEAL self-heals and self-adapts
by promoting new hubs while continuing the learning process without significant
losses. We challenged HEAL, Federated Learning, Gossip Learning and Epidemic
Learning with various topologies in static and dynamic environments (crash and
churn prone) on two tasks: a binary classification task using a logistic
regression @hosmer2013applied on the Spambase dataset @spambase_94 and on a
multinomial classification task using the LeNet5 model @lecun1989backpropagation
on the MNIST dataset @lecun2010mnist.

HEAL outperforms Gossip and Epidemic Learning in both accuracy and convergence
time. Moreover, HEAL is resilient to churn and crashes while Federated Learning
cannot cope with these faults.

#figure(
  table(
    columns: (3cm, 3cm, auto, 1.5cm, 2cm),
    align: (left, left, center, left, left),
    stroke: 0.5pt,

    [*Decentralized Federated Learning*], [*Topology*], [*Fault resilience*],
    [*Churn resilience*], [*Aggregation speed*],

    [Federated Learning],
    [Static (Star @mcmahan2017communication and Multi-Star @hsieh2017gaia)],
    [No], [No], [quick at the server],

    table.cell(rowspan: 2)[Gossip Learning],
    [Static (Random Regular @hegedHus2021decentralized)],
    [No], [No], [slow local],

    [Dynamic (with Newscast @ormandi2013gossip)],
    [Yes], [Yes], [slow local],

    table.cell(rowspan: 2)[Epidemic Learning],
    [Dynamic (Newscast @de2024epidemic)],
    [Yes], [Yes], [slow local],

    [Dynamic (FedLay @hua2024towards)],
    [Yes (only one)], [No], [slow local],

    [*HEAL (this paper)*],
    [*Dynamic (Elevator @legheraba2024emergent)*],
    [*Yes*], [*Yes*], [*quick at the hubs*],
  ),
  caption: [Comparison of different decentralized learning algorithms.],
) <tab:all_algorithm>

// *Paper organization.*
// In @sec:learning-background we propose an overview of decentralized learning
// strategies. @sec:HEAL introduces the architecture of HEAL and the detailed
// description of the HEAL learning strategies. @sec:evaluation presents our
// extensive evaluations. @sec:conclusions concludes and proposes open research
// directions.

== Overview of Decentralized Learning Techniques <sec:learning-background>

The distinguishing factors among various decentralized learning algorithms in
the literature are: (1) the algorithm employed to propagate and aggregate
learning models within the network, and (2) the network topology on which the
learning occurs. Naturally, these two concepts are interconnected, as certain
propagation methods are better suited to specific topologies.

*Decentralized propagation and aggregation of the learning models.*

There are various techniques for propagating the learning models within a
network, each with its own set of advantages and disadvantages. The three most
commonly discussed methods in the literature are _Federated Learning_,
_Gossip Learning_, and _Epidemic Learning_. In Federated Learning
@mcmahan2017communication, all models are aggregated at a central server,
facilitating rapid convergence towards a global model. In Gossip Learning
@ormandi2013gossip, each participant shares its model at a specified time
interval with a randomly chosen neighbor in the network. In Epidemic Learning
@de2024epidemic, each participant shares its model with all their neighbors in
each cycle.

*Network topology vs decentralized learning.*

In decentralized learning, the network topology significantly influences the
performance of the learning task, as evidenced by various studies in the
literature @vogels2022beyond. Different topologies impact the speed of
information propagation and the system's resilience to node or link failures.
At the extremes, we have the star topology, typically used with Federated
Learning, and the random graph topology, often paired with Gossip Learning.
However, many other topologies exist between these extremes. Additionally, it
is important to distinguish between static topologies (predefined and
unchangeable) and dynamic topologies (which evolve over time).

- *Static topologies.* Among static topologies, _star topology_, features a
  central server and clients connected to it. This setup is not entirely
  decentralized, as the aggregator server is selected at the beginning of the
  learning process, creating a single point of failure. The _multi-star
  topology_ is a variation of the star topology, involving multiple servers.
  Typically, all stars are interconnected in a complete topology, with all
  other nodes connected to a predefined star. Next, we have the _complete
  topology_, where every participant communicates directly with all others.
  While this maximizes information propagation speed and ensures rapid
  convergence, it is impractical for large-scale networks. Another common
  topology is the _ring topology_, where each node is connected to two
  neighbors, forming a circular ring. This topology is straightforward to
  construct but does not scale well. Finally, in _random regular graphs_ each
  participant is randomly connected to _k_ other participants in the network,
  with _k_ being a predefined parameter. This topology is highly robust against
  failures and churn, but the learning process convergence is slow. Other
  random topologies in the literature include small worlds and power-law
  networks.

- *Self-organised dynamic topologies.* To establish a dynamic topology, two
  primary approaches are discussed in the literature: Distributed Hash Table
  (DHT)-based methods and decentralized peer sampling methods. Among the
  DHT-based methods, Chord @stoica2001chord is a notable example. Additionally,
  Fedlay @hua2024towards is specifically designed for decentralized learning.
  For non-DHT methods, Newscast @jelasity2007gossip is commonly used in Gossip
  Learning and Epidemic Learning.

An important aspect to consider in dynamic topologies is their resilience to
failures. A specific type of failure is churn, where nodes in a peer-to-peer
network enter and leave without any control. Another particular case of failures
involves attacks targeting specific nodes, such as servers or central nodes.
Centralized topologies are highly sensitive to these types of failures.
In a static topology, there is no possibility to repair the topology in the
event of a failure. In a DHT, some repairs are possible, but not always
guaranteed face to high churn.
Peer sampling algorithms are a good compromise to repair the topology when
failures are detected and to be resilient to high churn.

HEAL uses as underlying topology Elevator @legheraba2024emergent, a recently
proposed decentralized peer-sampling algorithm. This algorithm enables nodes in
a peer-to-peer network to construct an overlay with _h_ defined hubs, each hub
being connected to all nodes in the network, with _h_ being a parameter of the
algorithm. Elevator is totally distributed, self-organizing and resilient to
churn.
In @tab:all_algorithm, we summarized the topologies used with various
decentralized learning algorithms, along with the strengths and weaknesses of
each approach.

#figure(
cetz.canvas({
  import cetz.draw: *
  // Dimensions
  let w = 4
  let h = 2  
  let spacing = 2

  // Couleurs
  let colors = (
    rgb(70%, 70%, 70%),    // light grey
    rgb(75%, 90%, 75%),   // green
    rgb(75%, 85%, 95%),   // blue
    rgb(85%, 75%, 90%),   // violet
  )

 
  // Arrow labels
  let labels = (
    "Network Layer",
    "Overlay Layer",
    "Aggregation Layer",
    "Application Layer",
  )
  for i in range(4) {
    rect((0, i*spacing), (w, h + (i*spacing)), name: "rect_"+str(i), fill: colors.at(i)) 
  
    content("rect_"+str(i), labels.at(i))  
  }
}), caption: [Architecture]
) <fig:system-architecture>

== HEAL Architecture

Federated Learning is vulnerable due to its reliance on a central server, so
our protocol must avoid having a single point of failure. Additionally, to
ensure resilience to failures and churn, the topology should not be predefined
but generated in a peer-to-peer manner. Conversely, to guarantee rapid model
convergence, learning models should not be shared via gossip within the network
but aggregated by a network node, which will then create the global model and
distribute it back to the other network nodes. These two aspects may seem
contradictory, but the HEAL-overlay (Elevator) protocol allows us to create a
topology that satisfies both requirements.

HEAL architecture shown in @fig:system-architecture is composed of two layers on top
of the physical network. HEAL-overlay given by the Elevator protocol introduced
in @legheraba2024emergent and HEAL-learning protocol described in the sequel.

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
=== HEAL Overlay

In the following we briefly revisit how Elevator operates. For a more detailed
explanation, readers can refer to the article that introduces the
algorithm @legheraba2024emergent.

The Elevator protocol performs the following actions during each cycle: Each
node in the peer-to-peer network retrieves the list of neighbors of their
neighbors (i.e., the neighbors at a distance of two). The node then constructs
an ordered list of the most frequent peers (the frequency map) and contacts the
_c_ most frequent nodes (referred to as _preferred_). Each contacted node
responds by sending the addresses from its backward list to the contacting node
and adds the contacting node to its backward list. The contacting node's cache
is then reset to an empty array. Subsequently, the node selects the _h_ most
frequent peers and _c-h_ random peers from the backward lists of all preferred
peers to populate its cache.

This protocol enables the rapid formation (in 4 cycles or fewer in practical
settings) of a network topology with _h_ defined hubs and a random distribution
of the remaining incoming connections. The resulting network has a diameter of 2
and is highly resistant to both failures (including hub failures) and churn. In
the event of all hubs failing, new hubs quickly emerge (typically within one
cycle). These properties are particularly advantageous for decentralized
learning, suggesting that we can implement a learning algorithm on this topology
that achieves performance levels similar to Federated Learning while maintaining
resilience properties as Gossip and Epidemic Learning.

=== HEAL Learning Protocol

Regarding the communication algorithm, we utilize the hubs within the network
as aggregators, similar to how the central server aggregates models in Federated
Learning. The key difference is that multiple hubs perform the aggregation, not
just one, and these hubs emerge automatically. We leverage the presence of
multiple hubs to distribute the aggregation workload, with each hub handling a
portion of the network nodes and subsequently aggregating with each other. Each
hub then returns the global model to its clients, and the protocol begins a new
cycle. As with Federated Learning, the learning process continues over several
cycles and concludes when the global model has converged.

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

=// = Properties

=// = Theoretical Analysis

=// = Simulation-Based Evaluation

// e evaluated our algorithm using simulations on the Gossipy
 simulator #footnote[https://github.com/makgyver/gossipy]. We compared Hub
L// earning against Federated Learning @mcmahan2017communication,
G// aia @hsieh2017gaia, Gossip Learning @ormandi2013gossip, Epidemic
L// earning @de2024epidemic, Epidemic Learning on a Chord
t// opology @stoica2001chord, Epidemic Learning on a ring topology, and
F// edlay @hua2024towards. For the static topologies (Federated Learning, ring,
C// hord, and Gaia), we generated the topology using the Python library
N// etworkx#footnote[https://networkx.org/].
F// or the dynamic topologies (Gossip Learning, Epidemic Learning, Fedlay and Hub
L// earning with Elevator), we generated the topology using the PeerSim
s// imulator @p2p09-peersim.
I// n Elevator (used by Hub Learning), the connections are directional. However,
t// o compare them with other algorithms (which assume an undirected graph), we
m// odified the underlying graph of the topology generated to make it undirected.
A// ll evaluations were conducted with a network of 100 nodes. For Elevator, we
u// sed 5 hubs, as we found this number to be a good balance between performance
a// nd resilience. For Gaia, we had 5 servers responsible for aggregation (to
c// ompare with the 5 hubs) and 19 nodes (or workers) attached to each server.
E// ach algorithm was evaluated 5 times, and we present the average results
o// btained.

W// e assessed all protocols on two tasks: a binary classification task (Logistic
R// egression @hosmer2013applied on the Spambase dataset @spambase_94, with a
l// earning rate of 0.1) and on a multinomial classification task
(// LeNet5 @lecun1989backpropagation on the MNIST dataset @lecun2010mnist, with a
l// earning rate of 0.001). The weight decay (regularization parameter) was fixed
a// t 0.01. Our algorithm was evaluated under various conditions: the failure of
2// 0% of nodes, the failure of a hub, the failure of all 5 hubs, and during churn
(// where 10% of nodes disappear at each cycle and are replaced by new nodes).

A// ll simulations were run on 16 vCPU, using 64G of memory, on a cluster
c// omposed of 10 servers.

// _// Crash-free, churn-free environment:_
F// or simulations without failures and churn, we ran all algorithms over 1000
c// ycles, on the two learning tasks (Spambase, MNIST). As shown in
@// fig:AccuracyMNIST, when there are no failures in the network, Federated
L// earning performs best, which was expected. Surprisingly, the ring topology
p// erforms second best despite lower connectivity.
O// ther topologies based on random graphs perform less well. HEAL, however,
p// erforms very well for both the Spambase and MNIST datasets.

I// n @tab:all_results we have compiled the results for all learning algorithms,
f// or the two learning tasks, with the final accuracy obtained after 1000 cycles.
F// ederated Learning, Gaia, and HEAL have very similar results, with a final
a// ccuracy of around 0.88 on Spambase, and 0.95 on MNIST. Gossip-based approaches
a// chieve values of 0.85 and 0.91 on Spambase and MNIST.
C// onvergence time is very fast for aggregator-based approaches: on Spambase,
F// ederated Learning converges to 0.85 in 2 cycles, and HEAL takes 4 cycles. On
t// he other hand, to converge on 0.90 accuracy, HEAL takes 339 cycles while
F// ederated Learning takes 135 cycles, hinting at possible HEAL optimization,
e// .g. adjusting the learning rate.
O// n MNIST, HEAL performs very well, even better than Federated Learning, and it
c// onverges to 0.95 accuracy in 76 cycles.

// _// HEAL parameterized with number of hubs and number chosen hubs:_
W// e ran simulations of HEAL, changing the number of hubs over 2000 cycles. On
@// fig:AccuracyVariousNbHubs, we observe that increasing the number of hubs (and
t// he number of hubs to which clients send their model) has almost no impact on
a// ccuracy, which is expected since hubs aggregate models. There is a slight drop
i// n accuracy when the number of hubs is increased significantly, due to the fact
t// hat only non-hubs are learning, not hubs. Increasing the number of hubs to
w// hich we send our model, from 1 to $"nb\hubs"/2$, slightly increases
c// onvergence speed.

// _// Crashes-prone environment:_
W// e analyze the performance of the algorithms when the network suffers crashes.
T// o simulate a brutal failure we disconnected 20% of the nodes chosen uniformly
a// t random, just after the start of the learning process, i.e., in this case, we
h// ave disconnected 20 nodes at cycle 10, and we compared HEAL with Chord, Gaia
a// nd Fedlay. HEAL is the algorithm with the best results, although Gaia remains
v// ery close, as seen in @fig:AccuracyCrash20peers.

// _// HEAL under churn environment and hub-targeted attacks:_
W// e further analyzed the performance of HEAL under network churn conditions. To
s// imulate churn, we disconnected 10% of the nodes at each cycle and replaced
t// hem with an equal number of new nodes, each connected to 20 nodes uniformly at
r// andom, between cycles 50 and 150.
W// e also analyzed the performance of the main learning algorithms after a
t// argeted attack on the hubs during the execution of the simulation. We tested
t// wo scenarios, one where we disconnected one of the 5 hubs, and another where
w// e disconnected all 5 hubs at the same time. In both cases the failure happened
i// n round 10. In @fig:AccuracyContexts, we have compared the execution of HEAL
w// ithout failures, and with different failure scenarios (crash of 20 nodes, crash
o// f one hub, crash of all 5 hubs, churn). As can be seen, there is no significant
i// mpact when 20 nodes or hubs crash. Indeed, thanks to the Elevator overlay, even
w// hen all the hubs are shutdown, 5 new nodes are elected very quickly as hubs,
a// nd the training job continues as if no catastrophic event had happened. During
c// hurn, model accuracy falls slightly, but rises again very quickly once churn is
o// ver, back to the level without failures.