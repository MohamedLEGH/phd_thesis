#import "@preview/cetz:0.4.0": canvas, draw

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/lovelace:0.3.0": *

#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
#show: show-theorion

= Decentralized Machine Learning <chap:learning>

This chapter focuses on a less explored branch of machine learning: decentralized
learning. While the dominant research direction assumes the existence of a central
authority to coordinate the learning process, decentralized learning investigates
how a set of nodes can collaboratively train a model without any central
coordinator. Throughout this chapter, we assume familiarity with the foundational
concepts of supervised learning — in particular the notions of loss function,
gradient descent, and standard model architectures — which are covered in detail
in @sec:appendix_ml. In brief, supervised learning consists in finding the
parameters $theta$ of a model $f_theta$ that minimize a loss function $L(theta)$
over a labeled dataset, using gradient descent as the optimization procedure.

Machine learning models can be trained under different assumptions regarding
data availability, computational resources, and the organization of the learning
process. The most straightforward paradigm is *centralized learning*, in which
all training data are collected and processed at a single location. This setting
enables exact gradient computation over the full dataset and provides strong
theoretical guarantees, but it raises fundamental challenges: data must be
transferred to a central location, which is costly, raises privacy concerns, and
becomes impractical at the scale of modern distributed systems. *Online learning*
relaxes the assumption that the full dataset is available before training begins,
allowing the model to update incrementally as new data arrives. *Ensemble
learning* shows that combining multiple independently trained models can yield
better predictive performance than any single model — a principle that
foreshadows the aggregation mechanisms central to decentralized learning, where
nodes repeatedly exchange and average local model updates to collectively
optimize a shared objective without any node having access to the full dataset.
*Distributed learning* addresses the scalability limitations of centralized
learning by spreading data and computation across multiple nodes, but still relies
on a coordinating entity — typically a parameter server. A detailed treatment of
these paradigms is provided in @sec:learning_paradigms. 

The natural next step, and the focus of this chapter, is to remove this central
coordinator entirely: decentralized learning requires nodes to collaborate over
data that remains private and local to each node, emerging naturally at the
intersection of machine learning and peer-to-peer systems, as illustrated
subsequently in @fig:dl-intersection.

From a
distributed systems perspective, it extends decentralized computation to the
learning setting: instead of collaboratively computing a global statistic, each
node maintains a local model and participates in the learning process exclusively
through peer-to-peer interactions. From a machine learning perspective, it
relaxes the centralisation assumption by keeping data local and moving models
across nodes rather than data. We now formalise this setting.

#figure(
  canvas(length: 1.2cm, {
    import draw: *

    // --- Circles ---
circle((2.8, 0), radius: 3.8,
  fill: rgb("#1D9E75").lighten(75%).transparentize(30%),
  stroke: rgb("#1D9E75") + 0.5pt)
circle((6.2, 0), radius: 3.8,
  fill: rgb("#7F77DD").lighten(75%).transparentize(30%),
  stroke: rgb("#7F77DD") + 0.5pt)
  
    // --- Left: Machine learning ---
    content((1.0, 1.4), text(size: 10pt, weight: "bold")[Machine learning])
    content((1.0, 0.7), text(size: 8.5pt)[Supervised learning])
    content((1.0, 0.1), text(size: 8.5pt)[Optimization])
    content((1.0, -0.5), text(size: 8.5pt)[Model training])

    // --- Right: Peer-to-peer systems ---
    content((8.0, 1.4), text(size: 10pt, weight: "bold")[Peer-to-peer systems])
    content((8.0, 0.7), text(size: 8.5pt)[Distributed computation])
    content((8.0, 0.1), text(size: 8.5pt)[No central coordinator])
    content((8.0, -0.5), text(size: 8.5pt)[Local interactions])
    content((8.0, -1.1), text(size: 8.5pt)[Fault tolerance])

    // --- Intersection: Decentralized learning ---
    content((4.5, 1.4), text(size: 10pt, weight: "bold")[Decentralized])
    content((4.5, 0.7), text(size: 10pt, weight: "bold")[learning])
    content((4.5, 0.0), text(size: 8.5pt)[Local data])
    content((4.5, -0.6), text(size: 8.5pt)[Model exchange])
  }),
  caption: [
    Decentralized learning at the intersection of machine learning and
    peer-to-peer systems.
  ],
) <fig:dl-intersection>

== Formal Framework <sec:dl-formal>

Having situated decentralized learning at the intersection of machine learning
and peer-to-peer systems, and distinguished it from centralized and distributed
paradigms, we now turn to a formal treatment of the problem. We begin by
clarifying how data are partitioned across nodes, which conditions all
subsequent definitions.

=== Data Partitioning

Decentralized learning approaches can be broadly categorized into two
settings, commonly referred to as horizontal and vertical, depending on
how data are partitioned across nodes @zhang2021survey.

In horizontal decentralized learning, all nodes share the same feature
space but hold different subsets of data instances. Each node trains a
local model on its own dataset, and learning proceeds by combining these
local models through parameter-wise aggregation --- for instance by
averaging corresponding parameters across nodes. This setting is
particularly well suited to peer-to-peer and federated environments,
where data are naturally distributed across participants but follow a
common schema.

In vertical decentralized learning, nodes observe the same set of data
instances but with disjoint feature subsets. No single node has access
to the full feature vector of an instance; learning therefore requires
exchanging intermediate representations or partial gradients computed
on complementary feature subsets. This setting involves stronger
coordination constraints and more complex communication patterns than
the horizontal case.


#figure(
  canvas(length: 1.0cm, {
    import draw: *

    // --- Parameters ---
    let cell-w = 1.6
    let cell-h = 0.9
    let n-feat = 5
    let n-inst = 3

    // ================================================================
    // HORIZONTAL FEDERATED LEARNING (left)
    // ================================================================

    // Title
    content((3.5, 1.5), text(size: 10pt, weight: "bold")[Horizontal federated learning])

    // Column headers: features
    for j in range(n-feat) {
      content((j * cell-w + 0.8, 0.7),
        text(size: 7.5pt)[$x^((#(j+1)))$])
    }

    // Row labels + cells
    let h-colors = (
      rgb("#1D9E75").lighten(70%),
      rgb("#1D9E75").lighten(55%),
      rgb("#1D9E75").lighten(40%),
    )
    let node-labels = ("Node 1", "Node 2", "Node 3")

    for i in range(n-inst) {
      let col = h-colors.at(i)

      // Node label on first row of each node
        content((-0.5, -i * cell-h),
          text(size: 7pt)[#node-labels.at(i)])

      for j in range(n-feat) {
        rect(
          (j * cell-w, -i * cell-h - cell-h * 0.5),
          (j * cell-w + cell-w - 0.1, -i * cell-h + cell-h * 0.5 - 0.05),
          fill: col,
          stroke: white + 1pt,
          radius: 0.05,
        )
      }
    }

    // ================================================================
    // VERTICAL FEDERATED LEARNING (right, offset)
    // ================================================================

    let x-off = n-feat * cell-w + 2.0
    let n-feat-v = 3
    let n-inst-v = 4

    content((x-off + n-feat-v * cell-w * 0.5, 1.5),
      text(size: 10pt, weight: "bold")[Vertical federated learning])

    // Node color per feature column
    let v-colors = (
      rgb("#7F77DD").lighten(60%),
      rgb("#7F77DD").lighten(40%),
      rgb("#7F77DD").lighten(20%),
    )
    let v-node-labels = ("Node 1", "Node 2", "Node 3")

    // Column headers with node labels
    for j in range(n-feat-v) {
      content((x-off + j * cell-w + 0.8, 0.7),
        text(size: 7.5pt)[#v-node-labels.at(j)])
    }

    // Row labels: instances
    for i in range(n-inst-v) {
      content((x-off - 0.7, -i * cell-h),
        text(size: 7pt)[$z^((#(i+1)))$])
    }

    for i in range(n-inst-v) {
      for j in range(n-feat-v) {
        rect(
          (x-off + j * cell-w, -i * cell-h - cell-h * 0.5),
          (x-off + j * cell-w + cell-w - 0.1, -i * cell-h + cell-h * 0.5 - 0.05),
          fill: v-colors.at(j),
          stroke: white + 1pt,
          radius: 0.05,
        )
      }
    }


  }),
  caption: [
    Horizontal federated learning (left): nodes share the same feature
    space but hold disjoint sets of instances. Vertical federated learning (right):
    nodes observe the same instances but hold disjoint feature subsets.
  ],
)


In this thesis, we focus exclusively on *horizontal decentralized
learning*, which is by far the most prevalent setting in the literature
and aligns naturally with peer-to-peer systems where nodes independently
collect data instances under a shared feature schema.

// === Model


=== Assumptions

The decentralized learning system inherits the assumptions established in
the peer-to-peer model of @chap:model. In particular, we assume that all
nodes are identical in terms of computational capabilities and memory
(see @chap:model), that communication channels are reliable and
instantaneous, and that message transmission incurs no latency or
bandwidth constraints.

These assumptions extend naturally to the machine learning components
introduced in @def:dl-node. Specifically:

- *Model size*: the size of the local model $f_(theta_i)$ — that is,
  the number of parameters $p = |theta_i|$ — is assumed to be identical
  across all nodes and imposes no memory or transmission constraint.
  Model exchanges between nodes are therefore treated as instantaneous,
  regardless of the number of parameters.

- *Training time*: the time required to perform a local model update,
  such as computing a gradient step or aggregating received parameters,
  is assumed to be negligible. Local learning computations are therefore
  considered instantaneous, consistently with the abstract execution
  model of @def:node-system.

These assumptions allow us to isolate the algorithmic and theoretical
properties of decentralized learning protocols from hardware and network
effects, and to focus on the convergence and communication behavior of
the system.

=== Adversarial models

In addition to the network-level failure models introduced in
@chap:model --- crash failures and Byzantine failures at the
communication layer --- decentralized learning systems are exposed
to a second class of perturbations that operate at the learning
level. Even when the underlying network functions correctly, the
aggregation process can be compromised by adversarial behaviors of
participating nodes with respect to their model updates.

Several types of adversarial actions are commonly considered in the
literature @rodriguez2023survey:

- *Privacy attacks*: a node attempts to infer or reconstruct the
  private data of other nodes by analyzing received model updates @biswas2024low.

- *Poisoning attacks*: a node intentionally manipulates its local
  model updates to degrade the performance of the global model @pham2024data.

- *Backdoor attacks*: a malicious node injects hidden triggers or
  patterns into the model during training, aiming to influence the
  model's behavior on specific inputs while preserving normal
  performance on clean data @bagdasaryan2020backdoor.

- *Free-riding*: a node benefits from the aggregated models of
  others without contributing meaningful updates, for instance by
  sending stale or null parameters @rodriguez2023survey.

These behaviors are orthogonal to the crash and Byzantine failure
models of @chap:model: a node may be honest at the network level
--- forwarding messages correctly and remaining available --- while
behaving adversarially at the learning level. Conversely, a
Byzantine node in the network sense may also corrupt model updates.

In this thesis, we do not study these adversarial behaviors. We
assume that all nodes are honest and follow the prescribed learning
protocol correctly. This allows us to focus on the convergence and
dynamic properties of decentralized learning protocols under the
assumption of fully cooperative participants, and leave the study
of robustness to adversarial settings as a direction for future work.

=== Abstract learning node

Building on the abstract node model introduced in @def:node-entity and
@def:node-system, we now define the notion of an *abstract learning node* by enriching the general peer-to-peer node with machine learning components.

#definition(title: "Learning Node")[
A *learning node* is an abstract node (see @def:node-entity)
whose local state $s_i$ is extended with two additional components:

1. a *local dataset* $cal(D)_i = {(x_j, y_j)}_(j=1)^(n_i)$, where
   $x_j in RR^d$ are feature vectors and $y_j$ are labels. The dataset
   is private: it is stored exclusively on node $i$ and is never
   transmitted to other nodes.

2. a *local model* $f_(theta_i) : RR^d -> cal(Y)$, parameterized by
   $theta_i in RR^p$, which represents the current state of the model
   maintained by node $i$.

The local state of node $i$ is thus $s_i = (cal(D)_i, theta_i, P(i))$,
where $P(i)$ denotes its partial view of the network (see @def:partial-view).

The dataset $cal(D)_i$ is a static component of the local state: it does
not change across protocol cycles. The model parameters $theta_i$, by
contrast, constitute the dynamic component of the state and are updated
at each protocol step.
] <def:dl-node>

#remark[
  From a multi-agent systems perspective @marl-book, each decentralized learning node can be viewed as an autonomous agent: its local state $s_i$ corresponds to the agent's internal memory, its neighbourhood $P(i)$ and the evolving overlay topology constitute its local environment, and the empirical loss defines the objective to be minimised. Although this multi-agent framing establishes a natural conceptual bridge to cooperative reinforcement learning and decentralized control, formalising our nodes as agents within a multi-agent learning framework lies explicitly outside the scope of this work.
]

// #remark[
// The local dataset $cal(D)_i$ can be seen as a global parameter of the
// node in the sense of @def:node-system: it is fixed at initialization
// and conditions all subsequent computations, but does not itself evolve
// as a result of protocol execution.
// ]

=== Decentralized learning objective

Having defined the learning node, we can now state the
global learning objective. Each learning node $i$ defines a local empirical loss $L_i (theta)$ (see @def:loss-function).

The global objective of the decentralized learning system is to
collectively minimise the aggregate loss over all nodes, in the sense
of @def:global-objective:
$
min_(theta in RR^p) L_"global" (theta), quad
L_"global" (theta) = 1/N sum_(i=1)^N L_i (theta),
$

#remark[
No single node has access to the full loss $L_"global" (theta)$, since
$cal(D)_i$ is local to node $i$. The minimisation must therefore be
achieved collaboratively, through the exchange of model parameters
$theta_i$ or gradients $nabla L_i (theta_i)$ between
neighbouring nodes, without any node ever observing the data of another.
]

Building on the notion of convergence introduced in @def:convergence,
we say that a decentralized learning system has converged if the global
loss falls below a prescribed threshold $epsilon > 0$.

#definition(title: "Convergence of Decentralized Learning")[
A decentralized learning system is said to have *converged* if there
exists a time $T >= 0$ such that for all $t >= T$:
$
L_"global" (S(t)) = sum_(i=1)^N alpha_i L_i (theta_i (t)) <= epsilon,
$
where $S(t) = (theta_i (t))_(i in V)$ is the global state of the system
at time $t$ (see @def:global-system), and $epsilon > 0$ is a
convergence threshold fixed a priori.
] <def:dl-convergence>

#remark[
In practice, exact convergence in the sense of @def:dl-convergence is
rarely studied directly. Instead, one typically fixes a time horizon
$T$ and evaluates the global loss $L_"global" (S(T))$ achieved after $T$
protocol cycles. This allows one to compare decentralized learning
protocols in terms of their convergence speed: a protocol that reaches
a lower loss within the same number of cycles is considered more
efficient.
]

=== Performance metrics

While convergence in the sense of @def:dl-convergence is defined in
terms of the global loss $L_"global"$, it is useful in practice to
complement this criterion with a more interpretable metric. Building
on @def:accuracy, we define the global accuracy of the decentralized
learning system as the average accuracy across all nodes, evaluated
on their respective local test datasets.

#definition(title: "Global accuracy")[
Let $cal(D)_i^("test")$ denote the local test dataset of node $i$,
and let $hat(y)_j = f_(theta_i)(x_j)$ be the predicted label for
input $x_j$. The *local accuracy* of node $i$ at time $t$ is:
$
"Acc"_i (t) = 1/(|cal(D)_i^("test")|)
sum_((x_j, y_j) in cal(D)_i^("test"))
bb(1){hat(y)_j = y_j}.
$

The *global accuracy* of the system at time $t$ is the average local
accuracy across all nodes:
$
"Acc"(t) = 1/N sum_(i=1)^N "Acc"_i (t).
$
] <def:global-accuracy>

We evaluate the performance of decentralized learning protocols
through two complementary criteria.

- *Final accuracy*: the global accuracy $"Acc"(T)$ measured after a
  fixed number of protocol cycles $T$. This criterion captures the
  asymptotic quality of the learned model and allows direct comparison
  between protocols under a fixed computational budget.

- *Time to accuracy*: the number of protocol cycles required for the
  global accuracy to reach a predetermined threshold $tau in (0, 1)$,
  formally defined as:
  $
  T_tau = min { t >= 0 | "Acc"(t) >= tau }.
  $
  This criterion measures the convergence speed of the protocol,
  independently of its final performance level.

#remark[
Final accuracy and time to accuracy are complementary: a protocol
may converge quickly to a moderate accuracy (low $T_tau$, moderate
$"Acc"(T)$), while another may converge more slowly but ultimately
reach a higher accuracy. Both criteria are therefore necessary to
fully characterize the behavior of a decentralized learning protocol.
]

// Having defined the formal framework of the decentralized learning
// system --- its nodes, objective, convergence criterion, and performance
// metrics --- we now turn to the two central design questions that
// govern the behavior of any decentralized learning protocol: how local
// models should be combined, and which nodes should communicate with
// whom.

== Aggregation Strategies <sec:dl-aggregation>

Having defined the formal framework of decentralized learning, we now turn to
the two central design questions that govern any decentralized learning protocol:
how local models should be combined, and which nodes should communicate with
whom. We address these questions in turn, first through the choice of aggregation
operator, then through the choice of collaboration topology.

=== Aggregation operator

A first question in decentralized learning concerns the aggregation
operator itself: given that nodes have exchanged their local model
parameters, how should these be combined into an improved model ?
As established in @def:dl-node, each node $i$ maintains a local model
$f_(theta_i)$ trained exclusively on its private dataset $cal(D)_i$,
and since the amount of data available at a single node is generally
insufficient to achieve low loss, collaboration between nodes is
required to leverage the information distributed across the network.

In horizontal decentralized learning (see @def:dl-node), all nodes
share the same feature space and parameter space $RR^p$, which makes
parameter-wise aggregation well-defined: the parameters of multiple
local models can be directly combined.


Several aggregation operators have been proposed in the literature,
ranging from weighted averaging to more sophisticated strategies based
on gradient correction or momentum. In this work, we focus on the
simplest and most widely studied: *model averaging*, in which nodes
exchange their local parameters and compute their arithmetic mean
@zinkevich2010parallelized. Despite its simplicity, this operator
forms the basis of most decentralized and federated learning algorithms
and admits strong theoretical guarantees under standard assumptions.

#definition(title: "Average SGD")[
At each iteration $t$, every node $i$ performs a local stochastic
gradient descent step on its local objective $L_i$ (see
@def:loss-function):
$
theta_(t+1/2) = theta_t - eta nabla_theta L_i (theta_t),
$

After a synchronization step, the local models are aggregated by
averaging:
$
theta_(t+1) = 1/N sum_(i=1)^N theta_(t+1/2).
$
] <def:average-sgd>

#remark[Under standard regularity assumptions on $L_i$ and IID data
distribution across nodes, Average SGD converges to the same optimum
as centralized SGD @lian2017can.
]

Two design choices govern the practical behavior of Average SGD. The
first is *aggregation frequency*: nodes may aggregate at every
iteration or after several local gradient steps, trading off
communication cost against convergence speed. The second is the
*synchronization scope*: rather than averaging model parameters,
an alternative is to aggregate gradients directly --- nodes exchange
$nabla L_i (theta_i (t))$, average them, and apply the result to a
shared model. This is equivalent to parameter averaging when models
are synchronized at every step, but the two strategies diverge when
local updates accumulate over several steps before aggregation. In
this work, we restrict our study to parameter-based aggregation for
simplicity.

The statistical properties of local datasets also play a crucial role
in the convergence behavior of Average SGD. Under IID distributions,
model averaging performs comparably to centralized training. In the
non-IID setting, however, local data distributions may differ
significantly across nodes, causing local models to drift in different
directions --- a phenomenon known as *client drift* @karimireddy2020scaffold.
In such cases, arithmetic averaging may no longer be appropriate, and
more robust aggregation operators have been proposed, such as geometric
median-based aggregation @blanchard2017machine, which is less sensitive
to outlier models induced by heterogeneous data distributions. Since
this thesis focuses on the interaction between aggregation and network
dynamics, we operate under the IID assumption throughout, and leave
the non-IID setting as a direction for future work.

=== Topology-driven Aggregation

A central design question in decentralized learning is determining which
nodes should exchange and aggregate their models, and according to what
structure. While the aggregation operator --- here Average SGD (see
@def:average-sgd) --- defines *how* models are combined, the
collaboration topology defines *who* communicates with whom. 
// Individual nodes typically possess only a limited and potentially biased view of the overall data distribution. Aggregation across nodes is therefore essential to enable convergence toward a model that reflects the collective knowledge of the network.

// Aggregation strategies differ in the network structures and communication patterns they assume. 

The choice of topology, ranging from centralized star-shaped architectures to fully decentralized peer-to-peer overlays, directly impacts convergence speed, robustness to failures, scalability, and resilience to churn. Understanding these trade-offs is therefore essential for the design and analysis of decentralized learning protocols.

Here, we look at the main aggregation strategies encountered in the literature, organized according to their underlying network topologies and coordination mechanisms. We progressively move from centralized and hierarchical approaches, such as Federated Learning and its multi-server extensions, to fully decentralized schemes based on gossip and local interactions.

We focus on aggregation strategies defined by network topology and communication patterns. Orthogonal aspects such as robust aggregation rules, privacy mechanisms, or incentive schemes are not discussed.

==== Federated learning

Federated learning (FL) @mcmahan2017communication is a collaborative learning paradigm in which
multiple clients train a shared model without exchanging their raw data.
Each client performs local training on its private dataset and
communicates only model parameters to a central coordinating entity,
referred to as the server. The paradigm was introduced to address
privacy, bandwidth, and data ownership constraints in large-scale
systems such as mobile devices and edge computing environments.

#figure(
  diagram(
    // --- Server ---
    node((1, 0),
      [*Server*\ global model $theta^((t))$],
      shape: rect,
      fill: blue.lighten(70%),
      stroke: blue.darken(20%) + 0.8pt,
      name: <server>),

    // --- Clients ---
    node((0, 2),
      [*Client 1*\ dataset $cal(D)_1$\ model $theta_1^((t))$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c1>),
    node((1, 2),
      [*Client 2*\ dataset $cal(D)_2$\ model $theta_2^((t))$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c2>),
    node((2, 2),
      [*Client 3*\ dataset $cal(D)_3$\ model $theta_3^((t))$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c3>),

    // --- Broadcast: server → clients ---
    edge(<server>, <c1>,
      marks: "<->",
      stroke: 1pt),
    edge(<server>, <c2>,
      marks: "<->",
    stroke: 1pt),
    edge(<server>, <c3>,
      marks: "<->",
    stroke: 1pt),
  ),
  caption: [
    Federated learning with a star topology: the server broadcasts
    $theta^((t))$, clients train locally on $cal(D)_i$, and return
    updated parameters $theta_i^((t+1))$ for aggregation.
  ],
)
The FedAvg algorithm @mcmahan2017communication generalizes
Average SGD (see @def:average-sgd) by allowing each client to perform
$E >= 1$ local gradient steps between communication rounds, rather
than a single step. This reduces communication frequency at the cost
of introducing a potential divergence between local and global
objectives when $E$ is large.

From a network perspective, federated learning relies on a star-shaped
topology: a single server communicates with all clients, collects their
local parameters, aggregates them --- typically as a weighted average
$theta^((t+1)) = sum_(i=1)^N w_i theta_i^((t))$ with
$w_i = n_i \/ sum_j n_j$ --- and broadcasts the updated global model
back to all participants.

While this architecture enables efficient coordination and simplifies
convergence analysis, it introduces a strong centralization point.
Although federated learning avoids centralizing data, it does not
eliminate central control: the server must be reliable and trusted,
and its failure or compromise may disrupt the entire learning process.
// This limitation motivates the development of fully decentralized
// approaches, in which no central coordinator is assumed.

#figure(
pseudocode-list(booktabs: true)[
  - *Input*: number of clients $N$, local datasets ${cal(D)_1, dots, cal(D)_N}$,
    learning rate $eta$, communication rounds $T$,
    local steps per round $E$,
    weights $w_i = n_i \/ sum_j n_j$,
    initial model $theta^((0))$
  + *for* $t = 0$ *to* $T - 1$ *do*
    + server broadcasts $theta^((t))$ to all clients
    + *for each* client $i$ *in parallel do*
      + $theta_i^((t, 0)) arrow.l theta^((t))$
      + *for* $e = 1$ *to* $E$ *do*
        + sample minibatch $xi_i subset cal(D)_i$
        + $theta_i^((t, e)) arrow.l theta_i^((t, e-1)) - eta nabla_theta L_i (theta_i^((t, e-1)) ; xi_i)$
      + *end for*
      + send $theta_i^((t, E))$ to server
    + *end for*
    + server aggregates:
      + $theta^((t+1)) arrow.l sum_(i=1)^N w_i theta_i^((t, E))$
  + *end for*
  + *return* $theta^((T))$
  ],
  caption: [Federated averaging (FedAvg) @mcmahan2017communication.],
) <algo:fedavg>

==== Multi-star federated learning

Multi-star federated learning extends the classical federated learning
paradigm by replacing the single central server with multiple
coordinating servers. Each server acts as a local aggregation point
for a subset of clients, forming multiple star-shaped subnetworks that
operate in parallel. This architecture is motivated by scalability,
fault tolerance, and geographical distribution --- as illustrated by
Gaia @hsieh2017gaia, a system designed for geographically distributed
machine learning in which workers send their updates to an assigned
regional server, and servers synchronize across geographical zones.
It is commonly encountered in large-scale industrial deployments where
a single server would become a performance bottleneck.

In a multi-star setting, clients are assigned to one or more servers
and perform local training in the same way as in standard federated
learning. Each server collects the updated parameters from its
associated clients and performs a local aggregation, for instance
using FedAvg (see @algo:fedavg). Compared to the single-star topology,
this reduces communication load and latency, and allows the system to
scale to a much larger number of clients.


#figure(
  diagram(
    spacing: (18mm, 14mm),
    node-stroke: 0.8pt,
    edge-stroke: 1pt,

    // --- Servers ---
    node((0, 0),
      [*Server 1*\ $theta^((t))_1$],
      shape: rect,
      fill: blue.lighten(70%),
      stroke: blue.darken(20%) + 0.8pt,
      name: <s1>),
    node((2, 0),
      [*Server 2*\ $theta^((t))_2$],
      shape: rect,
      fill: blue.lighten(70%),
      stroke: blue.darken(20%) + 0.8pt,
      name: <s2>),
    node((1, 1.5),
      [*Server 3*\ $theta^((t))_3$],
      shape: rect,
      fill: blue.lighten(70%),
      stroke: blue.darken(20%) + 0.8pt,
      name: <s3>),

    // --- Clients of server 1 ---
    node((-1, -1.5),
      [*Client 1*\ $cal(D)_1$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c11>),
    node((0, -1.5),
      [*Client 2*\ $cal(D)_2$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c12>),

    // --- Clients of server 2 ---
    node((2, -1.5),
      [*Client 3*\ $cal(D)_3$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c21>),
    node((3, -1.5),
      [*Client 4*\ $cal(D)_4$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c22>),

    // --- Clients of server 3 ---
    node((0.2, 3),
      [*Client 5*\ $cal(D)_5$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c31>),
    node((1.8, 3),
      [*Client 6*\ $cal(D)_6$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c32>),

    // --- Server clique ---
    edge(<s1>, <s2>, marks: "<->"),
    edge(<s2>, <s3>, marks: "<->"),
    edge(<s1>, <s3>, marks: "<->"),

    // --- Server 1 ↔ clients ---
    edge(<s1>, <c11>, marks: "<->"),
    edge(<s1>, <c12>, marks: "<->"),

    // --- Server 2 ↔ clients ---
    edge(<s2>, <c21>, marks: "<->"),
    edge(<s2>, <c22>, marks: "<->"),

    // --- Server 3 ↔ clients ---
    edge(<s3>, <c31>, marks: "<->"),
    edge(<s3>, <c32>, marks: "<->"),
  ),
  caption: [
    Multi-star federated learning: three servers form a fully connected
    clique for cross-server synchronization, each coordinating a local
    star of two clients. Clients communicate only with their assigned
    server; servers exchange aggregated models with one another.
  ],
)

However, the presence of multiple servers raises fundamental design
questions regarding global consistency and convergence. In particular,
servers must be synchronized to prevent model drift between different
regions of the network. Several synchronization strategies can be
considered:

- *Server-level aggregation*: servers periodically exchange their
  aggregated models and perform a second-level aggregation
  @hsieh2017gaia.
- *Client-to-multiple-servers*: clients send their local models to
  multiple servers, increasing redundancy and robustness at the cost
  of higher communication overhead.

From a topological perspective, multi-star federated learning
corresponds to a two-level hierarchy. While it removes the single
point of failure of classical federated learning, each server still
represents a critical coordination node for its associated clients.
If a server fails or behaves in a Byzantine manner, the learning
process of its local star can be compromised, and inconsistencies
may propagate to other servers during synchronization.

==== Hierarchical federated learning

Hierarchical federated learning (HFL) generalizes the multi-star
architecture by organizing servers into a tree-shaped topology,
forming a hierarchy of aggregation levels @liu2020client.
At the lowest level, clients perform local training and send their
model updates to intermediate servers, which act as local aggregators.
These intermediate servers then forward partially aggregated models
upward in the hierarchy, until a final aggregation is performed at a
root server.

#figure(
  diagram(
    spacing: (18mm, 16mm),
    node-stroke: 0.8pt,
    edge-stroke: 1pt,

    // --- Root server ---
    node((1.5, 0),
      [*Root server*\ $theta^((t))$],
      shape: rect,
      fill: rgb("#378ADD").lighten(40%),
      stroke: rgb("#185FA5") + 0.8pt,
      name: <root>),

    // --- Intermediate servers ---
    node((0, 1),
      [*Server 1*\ $theta^((t))_1$],
      shape: rect,
      fill: blue.lighten(70%),
      stroke: blue.darken(20%) + 0.8pt,
      name: <s1>),
    node((1.5, 1),
      [*Server 2*\ $theta^((t))_2$],
      shape: rect,
      fill: blue.lighten(70%),
      stroke: blue.darken(20%) + 0.8pt,
      name: <s2>),
    node((3, 1),
      [*Server 3*\ $theta^((t))_3$],
      shape: rect,
      fill: blue.lighten(70%),
      stroke: blue.darken(20%) + 0.8pt,
      name: <s3>),

    // --- Clients of server 1 ---
    node((-0.5, 2),
      [*Client 1*\ $cal(D)_1$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c11>),
    node((0.3, 2),
      [*Client 2*\ $cal(D)_2$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c12>),

    // --- Clients of server 2 ---
    node((1.1, 2),
      [*Client 3*\ $cal(D)_3$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c21>),
    node((1.8, 2),
      [*Client 4*\ $cal(D)_4$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c22>),

    // --- Clients of server 3 ---
    node((2.7, 2),
      [*Client 5*\ $cal(D)_5$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c31>),
    node((3.5, 2),
      [*Client 6*\ $cal(D)_6$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c32>),

    // --- Root ↔ intermediate servers ---
    edge(<root>, <s1>, marks: "<->"),
    edge(<root>, <s2>, marks: "<->"),
    edge(<root>, <s3>, marks: "<->"),

    // --- Server 1 ↔ clients ---
    edge(<s1>, <c11>, marks: "<->"),
    edge(<s1>, <c12>, marks: "<->"),

    // --- Server 2 ↔ clients ---
    edge(<s2>, <c21>, marks: "<->"),
    edge(<s2>, <c22>, marks: "<->"),

    // --- Server 3 ↔ clients ---
    edge(<s3>, <c31>, marks: "<->"),
    edge(<s3>, <c32>, marks: "<->"),
  ),
  caption: [
    Hierarchical federated learning: a root server coordinates three
    intermediate servers, each aggregating updates from two local
    clients. Aggregated models propagate upward level by level until
    a global model is produced at the root.
  ],
)

From a graph-theoretic perspective, this architecture corresponds to
a tree topology, where each internal node performs aggregation over
the models received from its children. This structure enables scalable
learning over very large populations of clients by distributing the
aggregation workload across multiple levels, thereby reducing
communication and computational pressure on the root server
@liu2020client.

Despite these scalability benefits, HFL remains fundamentally
centralized and inherits several limitations from tree-based
topologies. The structure is typically rigid, with predefined
parent--child relationships. Failures of intermediate aggregation
nodes can disconnect entire subtrees, temporarily preventing a large
number of clients from contributing to the global model. Similarly,
failures or Byzantine behavior at higher levels of the hierarchy may
corrupt or block the learning process for all downstream nodes
@an2025abd.

==== Blockchain-based federated learning

Blockchain-based federated learning combines federated learning with
blockchain-based distributed ledger technologies in order to remove
the reliance on a single trusted coordinator, motivated by the promise
of decentralization, auditability, and trust minimization
@wang2021systematic.

Several architectural strategies have been proposed. In a first
approach, each participant submits its local model update to a smart
contract deployed on the blockchain @ramanan2020baffle. Once a
sufficient number of updates has been received, the smart contract
performs the aggregation and publishes the resulting global model,
acting as a decentralized coordinator that enforces participation
rules and aggregation logic. An alternative approach relies on the
block validation process: instead of performing aggregation on-chain,
the block validator designates a node or a small committee as
aggregator for a given round @qu2020decentralized. Participants send
their local models to the selected aggregator, which computes the
aggregated model and disseminates it to the network, while the
blockchain records the selection process and ensures accountability.

Despite their conceptual appeal, these approaches inherit significant
limitations from blockchain technology. First, blockchain systems
require consensus on an exact global state, whereas machine learning
optimization only requires convergence toward a sufficiently low loss.
Enforcing strict consensus at every learning round introduces
substantial overhead without providing proportional benefit to the
learning process. Second, storing model parameters directly on-chain
is often impractical due to storage constraints and associated costs,
particularly for large models. 

#figure(
  diagram(
    spacing: (20mm, 18mm),
    node-stroke: 0.8pt,
    edge-stroke: 1pt,

    // --- Smart contract (center) ---
    node((1.5, 1),
      [*Smart contract*\ aggregation logic],
      shape: rect,
      fill: rgb("#EF9F27").lighten(50%),
      stroke: rgb("#BA7517") + 0.8pt,
      name: <sc>),

    // --- Participants ---
    node((0, 0),
      [*Node 1*\ $cal(D)_1$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <n1>),
    node((1.5, 0),
      [*Node 2*\ $cal(D)_2$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <n2>),
    node((3, 0),
      [*Node 3*\ $cal(D)_3$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <n3>),
    node((0, 2),
      [*Node 4*\ $cal(D)_4$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <n4>),
    node((3, 2),
      [*Node 5*\ $cal(D)_5$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <n5>),

    // --- Peer-to-peer connections between nodes ---
    edge(<n1>, <n2>, marks: "-"),
    edge(<n2>, <n3>, marks: "-"),
    edge(<n3>, <n5>, marks: "-"),
    edge(<n5>, <n4>, marks: "-"),
    edge(<n4>, <n1>, marks: "-"),
    edge(<n1>, <n3>, marks: "-"),
    edge(<n2>, <n4>, marks: "-"),

    // --- Nodes → smart contract (model upload) ---
    edge(<n1>, <sc>,
      marks: "->",
      label: $theta_1^((t))$,
      label-side: left),
    edge(<n2>, <sc>,
      marks: "->",
      label: $theta_2^((t))$,
      label-side: left),
    edge(<n3>, <sc>,
      marks: "->",
      label: $theta_3^((t))$,
      label-side: right),
    edge(<n4>, <sc>,
      marks: "->",
      label: $theta_4^((t))$,
      label-side: right),
    edge(<n5>, <sc>,
      marks: "->",
      label: $theta_5^((t))$,
      label-side: right),
  ),
  caption: [
    Blockchain-based federated learning: nodes are interconnected in a
    peer-to-peer overlay and submit their local model parameters
    $theta_i^((t))$ to a smart contract, which performs aggregation
    and publishes the updated global model to all participants.
  ],
)

Most practical implementations
therefore resort to off-chain storage or aggregation, which
reintroduces trust assumptions and partially undermines the
decentralization objective @wang2021systematic. Finally, when
aggregation is delegated to a single node or a small committee
selected by the block validator, the system remains vulnerable to
centralization risks, contradicting the original motivation for
using a blockchain.

From a topological perspective, blockchain-based federated learning
relies on a globally accessible coordination layer when smart
contracts are used, as all participants interact through a shared
ledger. When off-chain aggregators are employed, the resulting
communication structure resembles a star topology, with the
aggregator acting as a temporary central node.

In summary, the high communication latency, storage overhead, and
consensus costs of blockchain systems are poorly aligned with the
iterative and approximate nature of distributed machine learning,
and the practical deployment of such systems remains an open
challenge @wang2021systematic.


==== Gossip learning

Gossip Learning @ormandi2013gossip is a fully decentralized learning paradigm in which nodes exchange models 
through randomized peer-to-peer interactions. At each communication round, a node selects 
one of its neighbors uniformly at random and sends its current local model to that neighbor. 
There is no central coordinator and no notion of a global aggregation phase.

Upon receiving a model from a neighbor, a node performs a local aggregation between the 
received model and its own local model, typically by computing a weighted or uniform average 
of their parameters. The resulting aggregated model is then refined by performing one or 
several local learning steps using the node’s private dataset. This interaction pattern is 
repeated asynchronously across the network, leading to a gradual diffusion of information.

In the most common formulation, aggregation is 
performed before the local learning step. An alternative variant applies a local learning 
update independently to both models before merging them, which can improve robustness in 
non-IID data settings. Another extreme variant removes aggregation altogether: the local 
model is simply replaced by the received model. In this case, models effectively perform 
random walks over the network, and learning corresponds to successive local updates applied 
along these trajectories.

#figure(
  diagram(
    node-stroke: 0.8pt,
    edge-stroke: 0.8pt,
    node-fill: white,
    spacing: 25mm,

    // --- Nodes ---
    node((0, 0),   [*1*\ $cal(D)_1$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n1>),
    node((0.3, 1), [*2*\ $cal(D)_2$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n2>),
    node((1, 1.5), [*3*\ $cal(D)_3$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n3>),
    node((1.8, 1), [*4*\ $cal(D)_4$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n4>),
    node((1.8, 0), [*5*\ $cal(D)_5$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n5>),

    // --- Topology edges ---
    edge(<n1>, <n2>, marks: "-"),
    edge(<n1>, <n5>, marks: "-"),
    edge(<n2>, <n3>, marks: "-"),
    edge(<n2>, <n5>, marks: "-"),
    edge(<n3>, <n4>, marks: "-"),
    edge(<n4>, <n5>, marks: "-"),

    // --- Gossip exchange (node 2 → node 5) ---
    edge(<n2>, <n5>,
      marks: "-->",
      stroke: blue.darken(10%) + 1pt,
      bend: 20deg,
      label: [$theta_2^((t))$],
      label-side: left),
  ),
  caption: [
    Gossip learning: nodes are connected in a random peer-to-peer
    overlay. At each round, a node selects a neighbor uniformly at
    random and sends its current local model.
  ],
)

Gossip learning is typically deployed over random graph topologies, where the randomized 
communication pattern ensures sufficient mixing properties. Aggregation remains strictly 
local, and no global model is ever explicitly computed. Nevertheless, under suitable 
assumptions on the learning rate, loss function, and network connectivity, the local models 
are known to converge toward a common global solution. This convergence, however, is 
significantly slower than in Federated Learning due to the absence of coordinated global 
synchronization and the limited bandwidth of local interactions.

Despite its slower theoretical convergence, gossip learning offers
strong advantages in terms of system robustness. The absence of any
central entity makes the scheme inherently resilient to node failures,
network partitions, and churn. Nodes can join or leave the system
dynamically without disrupting the learning process, provided the
underlying communication graph remains connected on average. These
properties make gossip learning particularly attractive for
large-scale, dynamic, and failure-prone environments where centralized
or hierarchical approaches are impractical. Importantly, empirical
results suggest that the gap with federated learning may be smaller
than theoretical bounds indicate: @hegedHus2021decentralized show
that gossip learning can match the convergence quality of federated
learning in practice, while operating without any central coordinator.

#align(center,
grid(columns: 2,
[#figure(
pseudocode-list(
  booktabs: true,
  title: [Gossip Learning (main thread)],
)[
  - ML model: *model*
  - List of neighbors : *cache*
  // + model $arrow.l$ initModel()
  + *loop*
    + Wait for *Δ* time units
    + peer $arrow.l$ selectRandom(cache)
    + send(peer, model)
], caption: [Gossip Learning]
) <algo:gossip-learning>
],
[#figure(
pseudocode-list(
  booktabs: true,
  title: [Gossip Learning (background thread)],
)[
  - ML model: *model*
  - local dataset: *data*
  + *loop*
    + peer_model $arrow.l$ receive()
    + model $arrow.l$ merge(model, peer_model)
    + model.update(data)
], caption: [Gossip Learning (background thread)]
) <algo:gossip-learning-background>
])
)

Beyond the foundational work of @ormandi2013gossip, gossip learning
has attracted a substantial body of follow-up research aimed at
improving its convergence speed, robustness, and applicability to
diverse settings.

Several works address the efficiency of the gossip communication
pattern itself. @danner2018token propose a token-account approach
that improves convergence speed by better controlling the flow of
models across the network, and @danner2023improving further refine
the model merging strategy to amplify the benefits of token-based
flow control, reporting significant improvements over prior solutions
in simulations based on real-world smartphone availability traces.
@giaretta2019gossip extend the base algorithm to account for node
heterogeneity: since faster nodes send more models than slower ones,
they propose storing one model per neighbor and selecting from this
cache before merging, though this extension assumes a fixed neighbor
set. @wang2019matcha improve decentralized SGD by introducing a
matching decomposition sampling strategy that constructs better
communication topologies, while @koloskova2020unified provide a
unified theoretical framework for analyzing the convergence of
gossip-based SGD under changing topologies and local updates.

The algorithm has also been extended to non-standard learning tasks.
@berta2014lightning adapt gossip learning to $k$-means clustering,
demonstrating the generality of the paradigm beyond supervised
learning. @hu2019decentralized propose a segmented gossip approach in
which nodes exchange only a subset of model parameters rather than
the full model, reducing communication overhead, though their setting
is closer to a distributed cluster than a fully decentralized
peer-to-peer network.

A distinct line of work focuses on non-IID data settings and
personalization. @onoszko2021decentralized introduce PENS, a
performance-based neighbor selection algorithm in which nodes
evaluate received models on their local test set and preferentially
gossip with peers whose models perform best locally, effectively
steering communication toward nodes with similar data distributions.
In a related direction, @belal2022pepper argue that approximating
a global distribution is not always necessary, and propose PEPPER,
a gossip-based personalized recommender system in which each node
trains a model tailored to its own user rather than optimizing a
global objective.

==== Epidemic learning

Epidemic learning is a decentralized learning scheme in which each
node exchanges its local model with all of its neighbors at every
communication round @de2023epidemic. Contrary to classical
gossip learning, where interactions are pairwise and asynchronous,
this approach requires each node to wait for the models of all its
neighbors before performing aggregation. As a result, the learning
process is inherently synchronous.

#figure(
  diagram(
    node-stroke: 0.8pt,
    edge-stroke: 0.8pt,
    node-fill: white,
    spacing: 25mm,

    // --- Nodes ---
    node((0.9, 0.8), [*1*\ $cal(D)_1$], radius: 1.8em,
      fill: rgb("#EF9F27").lighten(50%),
      stroke: rgb("#BA7517") + 0.8pt,
      name: <n1>),
    node((0, 0),   [*2*\ $cal(D)_2$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n2>),
    node((0, 1.6), [*3*\ $cal(D)_3$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n3>),
    node((1.8, 0), [*4*\ $cal(D)_4$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n4>),
    node((1.8, 1.6), [*5*\ $cal(D)_5$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n5>),

    // --- Topology edges (non-neighbors of node 1) ---
    edge(<n2>, <n3>, marks: "-"),
    edge(<n4>, <n5>, marks: "-"),
    edge(<n2>, <n4>, marks: "-"),
    edge(<n3>, <n5>, marks: "-"),

    // --- Node 1 broadcasts to all neighbors ---
    edge(<n1>, <n2>,
      marks: "<-",
      stroke: blue.darken(10%) + 1.5pt,
      label: $theta_2^((t))$,
      label-side: left),
    edge(<n1>, <n3>,
      marks: "<-",
      stroke: blue.darken(10%) + 1.5pt,
      label: $theta_3^((t))$,
      label-side: left),
    edge(<n1>, <n4>,
      marks: "<-",
      stroke: blue.darken(10%) + 1.5pt,
      label: $theta_4^((t))$,
      label-side: right),
    edge(<n1>, <n5>,
      marks: "<-",
      stroke: blue.darken(10%) + 1.5pt,
      label: $theta_5^((t))$,
      label-side: right),
  ),
  caption: [
    Epidemic learning: node 1 (orange) collects the models
    $theta_2^((t)), dots, theta_5^((t))$ from all its neighbors
    simultaneously. Once all models are received, node 1 aggregates
    them and performs a local update on $cal(D)_1$.
  ],
)

At each round, a node broadcasts its current model to all adjacent
nodes and collects the models received from its neighborhood. Once
all expected models have been received, the node computes an
aggregation, typically by averaging the parameters of its own model
with those of its neighbors. The aggregated model is then updated
using a local learning step on the node's private dataset. This
process is repeated synchronously across the network.

Epidemic learning can be deployed over various network topologies.
On random graphs, it preserves some of the decentralization benefits
of gossip learning while accelerating convergence thanks to richer
local aggregation. On a fully connected topology, where every node
is connected to all others, the scheme becomes equivalent to a global
aggregation performed in a fully decentralized manner.

However, the increased degree of connectivity comes at a significant
cost. The communication and aggregation overhead grows linearly with
the number of neighbors, making the approach poorly scalable for
high-degree nodes. In fully connected networks, the communication
cost per round becomes prohibitive as the number of nodes increases.
Furthermore, the synchronous nature of the protocol makes it sensitive
to stragglers and node failures, as a single slow or unavailable
neighbor can delay the entire aggregation step.

While epidemic learning offers faster convergence than pairwise gossip
schemes, it sacrifices robustness and scalability due to its synchronous
nature and high communication overhead at high-degree nodes.

Epidemic learning has served as a foundation for a growing body of
work addressing practical limitations of the base protocol. These
extensions target a range of challenges including privacy, anonymity,
energy efficiency, data heterogeneity, scalability, and stragglers.

On the privacy and anonymity front, Zip-DL @biswas2024low introduces
resistance to privacy attacks by adding carefully calibrated noise to
model updates before transmission, while Shatter @biswas2024noiseless
takes a complementary approach by introducing the concept of virtual
nodes: instead of transmitting models under their true identity,
nodes split their model across virtual identities, thereby concealing
which physical node carries which model and preventing adversaries
from linking model updates to specific participants.

From an energy efficiency perspective, SkipTrain @de2024energy
proposes alternating between training phases and transmission phases,
allowing nodes to skip local training during transmission rounds.
This decoupling reduces the energy consumption of the protocol,
making epidemic learning more suitable for resource-constrained
environments such as mobile or edge devices.

The non-IID setting is addressed by Facade @biswas2025fair, which
adapts epidemic learning to heterogeneous data distributions by
clustering nodes according to the similarity of their local datasets.
By preferentially exchanging models within clusters of nodes sharing
similar data distributions, Facade mitigates the client drift problem
that arises when models trained on heterogeneous data are naively
averaged. DivShare @biswas2025boosting addresses a related challenge
by improving resilience to stragglers: when slow nodes delay the
aggregation step, DivShare adapts the protocol to tolerate late or
missing model transmissions without blocking the learning process.

Finally, two works address the scalability of epidemic learning at
larger network sizes. Plexus @dhasade2025practical selects a subset
of nodes at each cycle to participate in training and model
construction, reducing the per-round communication and computation
cost while preserving convergence properties, thereby enabling
epidemic learning to scale to larger networks. Mosaic Learning
@biswas2026mosaic fragments models into pieces and strategically
disseminates the fragments that differ most across nodes, exploiting
model diversity to accelerate convergence time.

==== Ring-based decentralized learning

Decentralized learning can also be implemented over a ring topology  @hua2024towards, although this approach 
is relatively uncommon in the machine learning literature. In a ring-based system, each node 
maintains connections with exactly two neighbors, typically referred to as its left and right neighbors, forming a closed cycle. This topology is simple, deterministic, and requires each node to store only a constant number of connections, which makes it attractive from a 
maintenance and routing perspective.

#figure(
  diagram(
    node-stroke: 0.8pt,
    edge-stroke: 0.8pt,
    node-fill: white,
    spacing: 22mm,

    // --- Nodes arranged in a ring ---
    node((1, 0),   [*1*\ $cal(D)_1$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n1>),
    node((2, 0.7), [*2*\ $cal(D)_2$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n2>),
    node((2, 1.8), [*3*\ $cal(D)_3$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n3>),
    node((1, 2.5), [*4*\ $cal(D)_4$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n4>),
    node((0, 1.8), [*5*\ $cal(D)_5$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n5>),
    node((0, 0.7), [*6*\ $cal(D)_6$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n6>),

    // --- Ring topology ---
    edge(<n1>, <n2>, marks: "-"),
    edge(<n2>, <n3>, marks: "-"),
    edge(<n3>, <n4>, marks: "-"),
    edge(<n4>, <n5>, marks: "-"),
    edge(<n5>, <n6>, marks: "-"),
    edge(<n6>, <n1>, marks: "-"),

    // --- Model circulation (circulating model highlighted) ---
    edge(<n1>, <n2>,
      marks: "->",
      stroke: blue.darken(10%) + 1.5pt,
      bend: 30deg,
      label: $theta^((t))$,
      label-side: left),
  ),
  caption: [
    Decentralized learning on a ring topology: nodes are connected
    to exactly two neighbors, forming a closed cycle. A model
    $theta^((t))$ circulates sequentially along the ring --- here
    from node 1 to node 2 --- and is updated at each node using
    its local dataset $cal(D)_i$ before being forwarded to the
    next neighbor.
  ],
)


Several aggregation strategies can be employed in a ring topology. A first approach consists 
in *local neighborhood aggregation*, where each node periodically exchanges model parameters 
or updates with its immediate neighbors and aggregates them, for instance by averaging its 
own model with those received from the left and right neighbors.

A second strategy relies on *model circulation*. In this approach, a single model is passed sequentially from node to node along the ring. Each node locally updates the received model using its own dataset before forwarding it to the next neighbor. 
After a full traversal of the ring, the model has effectively been trained on the data of all 
nodes, in a manner reminiscent of incremental or online learning. 

An illustrative example of a ring-based decentralized learning protocol is Fedlay @hua2024towards, which organizes nodes into *virtual rings*. In Fedlay, each node maintains connections to $2 ell$ neighbors across $ell$ distinct virtual rings, where $ell in NN^*$ is a configurable protocol parameter. At each training cycle, every node performs model aggregation by merging its local model with those received from its neighbors in each virtual ring, typically through weighted averaging. This multi-ring structure increases connectivity without sacrificing the simplicity of ring-based routing, allowing for more robust information propagation compared to a single-ring topology. However, the reliance on virtual rings still inherits some of the fundamental limitations of ring structures, particularly regarding latency and sensitivity to node churn.

Despite its conceptual simplicity, decentralized learning on a ring topology suffers from 
significant limitations. The rigid structure of the ring makes the system particularly vulnerable to 
failures and churn. The failure of a single node or link may break the ring and disconnect the 
network unless additional repair mechanisms are employed @hua2024towards. Frequent joins and leaves further 
complicate the maintenance of the ring structure and may disrupt the learning process.

==== Summary

The aggregation strategies surveyed in this section differ
fundamentally in their underlying network topology, which directly
shapes their convergence speed, scalability, and fault tolerance
properties. @tab:aggregation-strategies-topology summarises the main
strategies discussed, together with their associated topologies.

#figure(
table(
  columns: (1fr, 1fr),
  inset: 10pt,
  align: horizon,
  table.header(
    [*Aggregation strategy*], [*Associated topology*],
  ),
  [Federated learning],
  [Star (single central server)],
  [Multi-star federated learning],
  [Multiple stars],
  [Hierarchical federated learning],
  [Tree / hierarchical topology],
  [Blockchain-based federated learning],
  [Complete graph],
  [Gossip learning],
  [Random graph or complete graph],
  [Epidemic learning],
  [Random graph or complete graph],
  [Ring-based decentralized learning],
  [Ring],
),
  caption: [Main aggregation strategies and their associated network topologies.],
) <tab:aggregation-strategies-topology>

== Conclusion

This chapter has examined decentralized learning as a response to a fundamental
limitation shared by centralized and distributed learning alike: the requirement
that data be aggregated or made accessible at a central location, which raises
insurmountable challenges in terms of privacy, scalability, and data ownership.
Decentralized learning addresses this limitation at its root by keeping data
strictly local to each node, enabling collaborative model training without any
node ever observing the data of another. We formalized this setting by grounding
it in the node model of @chap:model: a decentralized learning node is a node
enriched with a local dataset and a local model, and the global learning objective
is to collectively minimize the aggregate loss $L_"global"$. We characterized
convergence in terms of this global objective, and introduced complementary
performance metrics --- final accuracy and time to accuracy --- that will serve
as evaluation criteria throughout the remainder of this thesis.

We then surveyed the main topology-driven aggregation strategies proposed in the literature, ranging from the star-shaped architecture of federated learning and its hierarchical extensions, to fully decentralized schemes such as gossip learning and epidemic learning. This survey revealed a fundamental tension that runs through the field: centralized and hierarchical approaches such as federated learning benefit from efficient coordination and fast convergence, but rely on a central point of control that introduces fragility, scalability limitations, and trust requirements. Fully decentralized approaches such as gossip learning eliminate this central dependency and offer strong resilience properties, but typically converge more slowly due to the limited bandwidth of local pairwise interactions.

Beyond this architectural tension, several broader challenges remain for the next generation of decentralized learning systems:

- *Security against privacy and Byzantine attacks.* Decentralized architectures are inherently exposed to data inference, membership inference, and model poisoning attacks. Designing protocols that guarantee robust aggregation or differential privacy without relying on central trust remains largely open.
- *Theoretical performance guarantees.* While empirical results abound, formal convergence bounds and complexity analyses for fully decentralized, asynchronous, and highly heterogeneous settings are still fragmented. Bridging empirical practice with rigorous theoretical foundations is a critical unsolved problem.
- *Adaptation to large language models (LLMs).* Training or fine-tuning billion-parameter models in a decentralized setting clashes with severe bandwidth, memory, and compute constraints at the edge. Developing communication-efficient, parameter-optimized strategies tailored to LLMs without sacrificing convergence is an emerging frontier.
- *Resilient and efficient decentralized learning systems.* Building fully peer-to-peer learning frameworks that simultaneously achieve high fault tolerance, rapid convergence, and low communication overhead --- without relying on fragile coordinators or hierarchical structures --- remains a core systems-level challenge.

Among these open research directions, this thesis deliberately narrows its scope to the fourth challenge: *the design of a resilient and efficient decentralized learning system*. Rather than attempting to solve security, theoretical bounds, or LLM-specific optimizations in isolation, our work targets the foundational systems problem of achieving fast, fault-tolerant, and communication-efficient model aggregation in fully decentralized environments. The following chapter (@chap:heal) presents our contribution to this problem.