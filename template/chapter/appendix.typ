#import "@preview/cetz:0.4.2"

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/lovelace:0.3.0": *
#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
#show: show-theorion

#set heading(numbering: none)  // Heading numbering
= Appendix
#counter(heading).update(1)

#set heading(numbering: "A.1", supplement: [Appendix])  // Defines Appendix numbering

// == Notation<sec:notation>
// #table(
//   columns: 2,
//   column-gutter: 3em,
//   stroke: none,
//   [$C_0$], [functions with compact support],
//   [$overline(RR)$], [extended real numbers $RR union {oo}$],
// )
// #v(1.5cm, weak: true)

// == Abbreviations<sec:abbreviations>
// #table(
//   columns: 2,
//   column-gutter: 1.55em,
//   stroke: none,
//   [iff], [if and only if],
//   [s.t.], [such that],
//   [w.r.t.], [with respect to],
//   [w.l.o.g], [without loss of generality],
// )


// #set heading(numbering: none)  // Heading numbering
// #set heading(numbering: "A1")
== Simulators <sec:simulators>
// #counter(heading).update(1)

// #set heading(numbering: "A.1", supplement: [Appendix])  // Defines Appendix numbering

Federated and decentralized learning protocols are inherently difficult to
evaluate analytically: their behavior depends on the dynamic interplay between
network topology, asynchronous message passing, heterogeneous data
distributions, and fault injection — conditions that resist closed-form
characterisation and demand empirical investigation at scale. Conducting such
experiments on physical infrastructure is costly, barely reproducible, and
ill-suited to the systematic exploration of parameter spaces that comparative
evaluation requires. Simulation is therefore not an auxiliary tool in this
thesis: it is the primary experimental substrate on which the claims of
our protocols rest.

This chapter documents a substantial body of work that remained largely
invisible in the main chapters. Over the course of this thesis, significant
effort was invested in adapting, instrumenting, and validating the simulation
frameworks used to evaluate our protocols. The simulators were
originally designed for network-level experiments in a different era of
distributed systems research; making them suitable for modern federated
learning workloads required non-trivial engineering work. This included
porting and configuring them for execution on a compute cluster, integrating
contemporary tooling for dependency management and job scheduling, implementing
missing protocol components, designing reproducible fault-injection mechanisms,
and ensuring that the simulation environment faithfully reflects the theoretical
model. Without this foundational work, the experimental results presented in
@chap:elevator and @chap:heal would not have been obtainable.

Beyond implementation, this appendix serves a second purpose: reproducibility.
Decentralized learning experiments involve many interacting moving parts —
simulator configuration, cluster deployment, parameter sweeps, result
collection, and post-processing — and the absence of documented procedures
is a common obstacle to replication. The following sections therefore describe
the full simulation workflow in sufficient detail to allow an independent
researcher to reproduce the experimental conditions of @chap:elevator and @chap:heal from scratch:
from cluster installation and job submission to result extraction and
aggregation.

=== Peer-to-peer simulations <sec:p2p-simulations>

Simulating peer-to-peer protocols at scale requires a dedicated
framework that can handle large, dynamic networks while remaining
flexible enough to accommodate the specific requirements of each
protocol under study. Several simulators were considered during the
preparation of this thesis, including OMNeT++, NS-3, and Shadow,
each of which offers high-fidelity network emulation at the cost of
complexity, steep learning curves, and implementations primarily in
C++. These tools are well-suited for transport-layer and network-layer
research but impose unnecessary overhead for protocol-level
experiments in which the details of packet scheduling and link
simulation are not the primary concern.

PeerSim @p2p09-peersim was selected as the simulation platform for
this thesis. The choice is motivated by several factors. PeerSim has
an established presence in the peer-to-peer research community: it
has been used to evaluate foundational gossip-based protocols such as
gossip-based peer sampling @jelasity2007gossip, and continues to appear
in recent decentralized systems publications such as
SecureCyclon @antonov2023securecyclon. Its component model is explicitly
modular — protocols, topologies, and observers are interchangeable
building blocks — and the distribution ships with a large library of
ready-to-use components covering overlay construction, aggregation,
and topology management. In principle, the cycle-based engine scales
to networks of hundreds of thousands of nodes, which covers the range
of sizes evaluated in this thesis. PeerSim natively supports dynamic
graphs: nodes may join, leave, or fail during a simulation, and the
overlay topology evolves accordingly, making it suitable for the churn
and fault scenarios of @chap:heal. Finally, PeerSim is written in
Java, which is considerably more accessible than the C++ codebases of
alternative simulators and facilitated the substantial extensions
described in @sec:peersim-engineering.

==== Overview <sec:peersim-overview>

PeerSim @p2p09-peersim is an open-source, Java-based simulator developed
at the University of Bologna, designed specifically for large-scale
peer-to-peer protocol research. Its guiding design principles are extreme
scalability and support for dynamic network membership: nodes may join and
leave continuously, and the simulator has been demonstrated to handle
networks of millions of nodes. PeerSim is structured around pluggable,
interchangeable components — protocols, initializers, and control objects —
combined through a plain-text configuration file, making it straightforward
to swap overlay topologies, aggregation strategies, or fault models without
modifying protocol code.

PeerSim provides two distinct simulation engines. The _cycle-based engine_
operates under simplifying assumptions: there is no transport layer
simulation and no concurrency. Instead, nodes are granted control
sequentially at each discrete cycle, during which they may exchange state
with neighbors and perform local computation. This model trades realism for
performance, enabling scalable parameter sweeps over large networks. The
_event-based engine_ is more realistic — it models transport-layer behavior
and supports asynchronous message passing — at the cost of higher
computational overhead. Cycle-based protocols can additionally be executed
under the event-based engine, providing a migration path when fidelity
requirements increase. The experiments of this thesis rely on the
cycle-based engine, whose simplifying assumptions are appropriate for the
epidemic and gossip protocols studied.

==== Architecture

A PeerSim simulation is composed of four kinds of objects, each implementing
a dedicated interface.

A *`Node`* is a container for protocols. It provides access to all protocol
instances it holds and exposes a unique, fixed numeric identifier.

A *`CDProtocol`* (cycle-driven protocol) defines the behavior executed by
each node at every cycle via a `nextCycle()` method. This is the primary
extension point for implementing new distributed algorithms.

A *`Linkable`* defines the local neighborhood of a node — its partial view
of the overlay. Rather than managing neighbor lists internally, protocols
delegate topology access to a separate `Linkable` component, allowing any
overlay (random graph, Newscast, T-Man, etc.) to be composed with any
protocol without code changes.

A *`Control`* object is scheduled for execution at configurable points
during the simulation. Controls serve two roles: _initializers_ (prefixed
`init` in the configuration file) set up the initial state of nodes and
protocols before the first cycle; _observers_ collect metrics and emit them
to standard output, which may be redirected to a file for post-processing.
The same interface covers both roles; the distinction is purely one of
scheduling.

The simulation life-cycle proceeds as follows. PeerSim reads a
plain-text configuration file specifying network size, protocol classes,
initializer order, control schedules, and all component-level parameters.
It then constructs the node array by cloning a single prototype instance of
each protocol — a design that requires careful implementation of the
`clone()` method in any custom protocol. After initialization controls have
run, the cycle-driven engine repeatedly invokes all active components once
per cycle, in a configurable order, until the target number of cycles is
reached or a component signals termination. Metric output is written to
standard output and is trivially redirectable to a file for collection.

==== Configuration

Experiments are fully described by a configuration file consisting of
key--value pairs. Global parameters (network size, cycle count, random
seed) are declared at the top level; component-specific parameters follow
the pattern `<type>.<name>.<parameter>`. For example:

```
network.size        10000
simulation.cycles   100
random.seed         1234567890
protocol.lnk        IdleProtocol
protocol.avg        example.aggregation.AverageFunction
protocol.avg.linkable lnk
init.rnd            WireKOut
init.rnd.protocol   lnk
init.rnd.k          20
control.obs         example.aggregation.AverageObserver
control.obs.protocol avg
```

This configuration defines a simulation of 10,000 nodes running for 100
cycles. The random seed is fixed to ensure full reproducibility of all
stochastic elements of the simulation. Two protocols are declared. The
first, `IdleProtocol`, is a passive link container: it holds the neighbor
list of each node but executes no logic of its own, modeling a static,
non-adaptive overlay network. The second, `AverageFunction`, implements
gossip-based aggregation: at each cycle, every node contacts one neighbor
drawn from its local view and replaces its current value with the average
of the two. The `linkable` parameter binds `AverageFunction` to
`IdleProtocol`, specifying that peer selection must consult the static
neighbor list. The initializer `WireKOut` wires the overlay before the
first cycle by assigning exactly $k = 20$ outgoing links to each node
chosen uniformly at random, producing a $20$-regular random directed
graph. Finally, `AverageObserver` is a control object scheduled at every
cycle: it traverses all nodes, computes network-wide statistics over their
current values (minimum, maximum, mean, and variance), and emits them to
standard output, where they can be redirected to a file for
post-processing.

The configuration format supports arithmetic expressions via the Java
Expression Parser, allowing derived quantities (e.g. `SIZE 2^MAG`) to be
defined once and referenced throughout the file, which reduces
transcription errors in parameter sweeps.

==== Simulation protocol <sec:peersim-protocol>

_Engine selection_

Among the two simulation engines offered by PeerSim, the cycle-based
engine was selected for all experiments in this thesis. The event-based
engine is designed to approximate real deployment conditions as closely
as possible — asynchronous message delivery, concurrent execution, and
transport-layer simulation — which makes it well-suited for high-fidelity
validation. However, Elevator had already been evaluated in a real distributed
environment; a second
round of realistic execution-level experiments was therefore not the
primary objective here. The cycle-based engine, by contrast, executes
node logic sequentially and deterministically within each round, which
offers two practical advantages: parameter sweeps are fully reproducible
given a fixed random seed, and the absence of concurrency eliminates a
class of non-deterministic artifacts that would complicate the
interpretation of aggregate metrics. These properties make it the
appropriate choice for the comparative, large-scale evaluation carried
out in @chap:elevator and @chap:heal.

_Experimental workflow_

Each simulation runs for 1,000 cycles. To reduce the influence of random
initialization — topology wiring, initial model weights, failure
sampling — every experimental condition is repeated 100 times with
distinct seeds, and all reported metrics are averaged across these
repetitions. The full workflow proceeds in five stages.

*Stage 1 — Simulation execution.* Each of the 100 runs for a given
condition is launched independently, producing one output stream per run.
A dedicated observer, scheduled at every cycle, serializes the current
state of the overlay graph to a file in GML format at the end of each
round. A run of 1,000 cycles therefore produces 1,000 GML snapshots,
each capturing the full adjacency structure and per-node protocol state
at that point in time.

*Stage 2 — Result collection.* Upon completion, the GML files from all
100 runs are collected and organized by condition, network size, and
cycle index, forming a structured archive that constitutes the raw
experimental record.

*Stage 3 — Metric computation.* A post-processing script reads the GML
files, reconstructs the graph at each cycle, and computes the metrics of
interest — convergence rate, model accuracy, connectivity properties, and
protocol-specific indicators. For each metric and each cycle index, the
100 values obtained across repetitions are averaged, yielding a
smooth, low-variance time series that reflects the expected behavior of
the protocol rather than the outcome of any single run. The data is stored as CSV files.

*Stage 4 — Visualization.* The aggregated time series (CSV files) are passed to a
plotting pipeline that produces the figures reported in @chap:elevator.
Each figure is generated programmatically from the metric files, ensuring
that all visual results are directly traceable to the underlying data.

*Stage 5 — Condition sweep.* Stages 1 through 4 are repeated for every
experimental condition in the evaluation matrix. Conditions vary along
multiple axes: fault scenario (fault-free, node failures, churn, ...),
protocol variant, and network size
(100, 200, 500, 1000, ...). The total number of simulations
executed across all conditions is therefore substantial.

==== Engineering contributions <sec:peersim-engineering>

The experimental infrastructure underlying this thesis required
substantial software engineering work across three independent
components: an extensively modified version of PeerSim, a cluster
deployment and orchestration system, and two successive generations of
metric computation and visualization tooling. Each is described in turn.

_PeerSim extensions_

The modifications made to PeerSim over the course of this thesis are
extensive enough to constitute a distinct fork of the simulator. The
original codebase was hosted on Subversion (SVN); the first step was
migrating the project to Git to enable proper version control,
branching, and collaboration. Dependency management was absent from
the original project: third-party libraries were bundled as untracked
JAR files. The build system was rewritten to use Gradle, which
formalizes dependency declarations, reproducible builds, and
installation. A Dockerfile was added to containerize the simulator,
and a GitLab CI/CD pipeline was configured to enforce automated
builds and tests on every commit. The code is available at https://gitlab.lip6.fr/legheraba/peersim.

The most significant technical contribution was parallelizing the
cycle-based engine. The original implementation was entirely
sequential: a single thread drove the simulation loop, visiting each
node in turn. The core data structures were not thread-safe, and
making the engine concurrent required modifying nearly every source
file to replace shared mutable state with thread-safe equivalents.
On top of this foundation, a simulation-level parallelism mode was
implemented: multiple independent runs, each with a distinct seed,
execute concurrently across available cores. Because the runs share
no state, this constitutes an embarrassingly parallel workload, and
throughput scales linearly with the number of cores allocated.
General performance optimizations were carried out alongside this
work to reduce per-cycle overhead.

On the protocol side, fault models were implemented from scratch:
static node failures with graceful disconnection, churn (concurrent
arrivals and departures), and node addition following a configurable
random process. Byzantine fault tolerance was also integrated into
PeerSim, implementing the attack models defined in @chap:elevator.
This required embedding Byzantine behavior at the core of the
simulator, which was not designed with adversarial node models in
mind. A dedicated class hierarchy was introduced, in which Byzantine
node classes extend the standard node class and override its
communication and aggregation behavior to inject the targeted attack.
When the overlay state is serialized to GML at the end of each cycle,
Byzantine nodes are annotated with a distinguishing label, allowing
downstream metric computation tools to identify them and compute
protocol-specific resilience metrics accordingly.

The following protocols were implemented in full, each derived from
the pseudocode of the corresponding publication: Elevator (with
multiple configuration variants, @chap:elevator), Chord, Proofs,
Phenix, and Fedlay. Finally, a machine learning layer was implemented
in Java and integrated directly into PeerSim, with the aim of running
decentralized federated learning experiments entirely within the
simulator. Although this approach was ultimately superseded by the
Gossipy-based evaluation reported in @chap:heal, it established the
feasibility of in-simulator learning and informed the design of the
final experimental setup.

_Cluster deployment and orchestration_

PeerSim was deployed on a Slurm-managed compute cluster via Docker.
Each experimental condition — a combination of protocol, network
size, fault scenario, and repetition count — is described by a
dedicated Slurm job script that invokes the containerized simulator
with the appropriate configuration file and seed range. A top-level
orchestration layer ties all job scripts together so that the entire
experimental campaign can be (re)launched with a single command. Once
triggered, the workflow requires no further human intervention: jobs
are queued, executed, and their GML output files collected
automatically. The result is a fully reproducible experimental
pipeline in which the mapping from a configuration parameter to its
corresponding raw output is unambiguous and auditable.

_Metric computation and visualization_

Two generations of tooling were developed to process the GML output
files and produce the figures reported in this thesis.

The first tool, `compute-metrics` #footnote[https://gitlab.lip6.fr/legheraba/compute-metrics], was written in Python and Java.
Graph-theoretic metrics were computed using JGraphT, chosen over
pure Python because NetworkX proved too slow and difficult to
parallelize at the scale of the experiments; Python handled
aggregation and figure generation via Matplotlib. Like PeerSim
itself, `compute-metrics` was version-controlled on Git, containerized
with Docker, covered by a GitLab CI/CD pipeline, and executed on the
cluster via Slurm. Metric data and generated figures were committed
directly to the repository, providing a persistent, indexed record of
all results.

After two years of thesis work, `compute-metrics` was rewritten from
scratch in Julia#footnote[https://julialang.org/] as a new tool named `graph-metrics`#footnote[https://gitlab.lip6.fr/legheraba/graph-metrics]. The rewrite was
motivated by the desire for a single, uniform language covering both
metric computation and visualization, with better performance and
simpler parallelism than the Python--Java combination. `graph-metrics`
is designed as a command-line interface: metrics and figures are
requested by issuing CLI commands with explicit parameters, and the
tool automatically resolves the corresponding GML files from a
structured directory hierarchy organized by protocol, network size,
and fault context. The same DevOps practices apply: Git versioning,
GitLab CI/CD, Docker containerization, and co-location of data and
figures in the repository.

=== Decentralized learning simulations <sec:dl-simulations>

==== Candidate tools and their limitations

Unlike peer-to-peer protocol simulation, which benefits from two
decades of dedicated tooling, the simulation of federated and
decentralized learning is a recent and still maturing field. No
established, general-purpose simulator exists for decentralized
learning at the time of writing, and the evaluation of a new
protocol such as HEAL required navigating a fragmented landscape of
partial solutions, each with significant limitations.

Several candidate platforms were evaluated before settling on the
final approach. Flower @beutel2020flower is a widely used federated
learning framework that includes a simulation mode, but its
architecture is centered on the canonical server--client topology of
standard federated learning. Adapting it to a fully decentralized,
serverless setting would have required deep modifications to its
aggregation and communication abstractions, amounting to a near-total
rewrite of its core coordination layer. This effort was judged
disproportionate given that the resulting tool would remain tightly
coupled to Flower's design assumptions.

Adding machine learning capabilities directly to OMNeT++ and NS-3 was
also considered. Both are mature network simulators with rich
protocol libraries, but they are designed for physical and link-layer
network modeling: their primary abstractions are packets, interfaces,
and routing tables. Overlay networks and model-averaging protocols fit
poorly into this paradigm, and the integration of a machine learning
layer would have required bridging fundamentally incompatible levels
of abstraction.

The option of extending PeerSim with machine learning support was
pursued more seriously, and is described in @sec:peersim-engineering.
This direction had a precedent: the authors of gossip learning
@hegedHus2021decentralized implemented machine learning models
directly in Java within PeerSim, without relying on any external
library, by reimplementing the required model architectures by hand.
While functional, this approach is inflexible: every new model
architecture requires a full manual reimplementation, and keeping
custom Java implementations consistent with modern deep learning
frameworks is unsustainable as model complexity grows. An alternative
approach — bridging PeerSim to PyTorch by serializing model
parameters across the Java--Python boundary — was attempted but
proved impractical: the serialization overhead and the complexity of
managing two runtimes synchronously introduced more fragility than it
resolved.

Gossipy @ormandi2013gossip, a Python-based gossip learning simulator,
was also evaluated as a potential base. Gossipy natively supports
machine learning workloads and provides a clean implementation of
several gossip protocols, but its overlay model is not designed to
accommodate custom peer-to-peer protocols such as Newscast or Elevator. Adapting
it to support dynamic networks would have required restructuring its core communication layer.

A final candidate, decentralizepy @dhasade2023decentralized, was
developed by the authors of Epidemic Learning and is the closest
existing tool to what this thesis requires: a simulator designed
explicitly for decentralized machine learning over overlay networks.
Decentralizepy was studied in depth over several months and partial
experiments were conducted with it. However, the simulator was at an
early stage of development at the time of evaluation: recurring
crashes and instabilities under the experimental conditions of
interest made it impossible to obtain reliable results, and the
effort required to stabilize it for production use was judged
excessive.

In light of these evaluations, a hybrid approach was adopted,
combining PeerSim and Gossipy: PeerSim handles overlay topology
construction and peer-to-peer protocol logic, while Gossipy provides
the machine learning substrate.

==== Hybrid simulation protocol <sec:hybrid-protocol>

The simulation of decentralized learning experiments in this thesis
follows a two-phase hybrid approach that combines PeerSim and Gossipy,
each handling the aspects of the problem for which it is best suited.

_Phase 1: topology generation_

The first phase produces the sequence of GML snapshots consumed by
Gossipy in phase 2. Two distinct generation paths are used depending
on whether the experiment involves a static or a dynamic topology.

For dynamic topologies — those involving node failures, churn, or
protocol-driven overlay evolution — PeerSim is used as described in
@sec:peersim-protocol. The simulator produces one GML snapshot per
cycle, capturing node identities, active connections, and any
structural changes induced by the fault scenario, yielding a
complete, deterministic record of the overlay's evolution over the
1,000 cycles of the experiment.

For static topologies, PeerSim is not involved. Instead, a dedicated
command-line tool, `topology_generator` #footnote[https://gitlab.lip6.fr/legheraba/topology_generator], was developed to produce
fixed GML graphs using NetworkX. The tool accepts parameters
controlling the graph family, network size, and degree, and supports
the following topology types: random graph, power-law, ring, star,
multi-star, and Chord. Since the topology does not change over time,
a single GML file is generated and reused identically at every cycle.
This avoids running PeerSim for conditions in which no dynamic
behavior is needed, and ensures that static baseline topologies are
generated by a well-tested graph library rather than by the
simulator's wiring routines. In both cases, the GML files produced
by this phase constitute the sole topological input to phase 2.

_Phase 2: decentralized learning with Gossipy_

Gossipy was extended to consume the GML files produced by PeerSim.
At the start of each cycle, the simulator reads the corresponding GML
snapshot and reconstructs the overlay graph, determining which nodes
are active and which connections are available for that round. Each
active node then executes its machine learning algorithm for that
cycle: local model update, peer selection according to the aggregation
protocol, and model exchange with neighbors. At the end of each cycle,
the per-node accuracy is evaluated and written to a CSV file. Once all
cycles have been processed, Matplotlib is used to generate figures
showing the evolution of accuracy over time, averaged across the 5
repetitions of the experiment.

The aggregation protocols evaluated in this thesis were each
implemented within Gossipy. Gossip learning and Epidemic learning
were already partially available but required adaptation to handle
dynamic network membership. HEAL required a full implementation of
its multi-phase protocol: local training, hub selection, intra-hub
aggregation, inter-hub aggregation, and model broadcast, each
executed in the correct sequence within the Gossipy cycle loop.

_Fault handling_

The hybrid architecture handles the three fault scenarios of
@chap:heal as follows. For static node failures, a node that is
marked as down in the PeerSim GML at cycle $t$ ceases all learning
activity from that cycle onward: it neither performs local training
nor participates in aggregation. The same policy applies to nodes
that depart under churn. Nodes that join the network during churn
are initialized with a randomly drawn model; they immediately begin
participating in aggregation and progressively converge toward the
rest of the network through repeated model exchanges. This mirrors
the situation of a late-joining participant in a real decentralized
system, which has no prior knowledge of the models already in
circulation and must recover through the protocol's natural
convergence mechanism.

_Deployment and reproducibility_

Gossipy was adapted for execution on the Slurm cluster following the
same DevOps practices applied to PeerSim. Each experimental condition
is described by a Slurm job script that configures a Conda virtual
environment with all required dependencies, specifies the path to the
relevant GML files, and launches the Gossipy simulation with the
appropriate parameters. A GitLab CI/CD pipeline validates the
environment on every commit. As with the PeerSim pipeline, metric
data and generated figures are committed to the repository, providing
a versioned, indexed record of all experimental results.

_Limitations_

The hybrid approach rests on the assumption that topology and
learning dynamics can be decoupled: PeerSim determines who is
connected to whom at each cycle, and Gossipy determines what is
exchanged. This separation is a simplification. In a real deployment,
the outcome of a learning round may influence subsequent peer
selection decisions, and the latency of model transfers would affect
the effective topology seen by each node. The present protocol does
not capture these feedback effects. It is nonetheless a principled
compromise: it preserves the structural realism of the overlay
dynamics, ensures full reproducibility, and allows the aggregation
protocols to be evaluated under identical, controlled topological
conditions — which is the primary requirement for the comparative
analysis of @chap:heal.

==== FLAIR simulations on ns-3 <sec:flair-ns3>

The simulation of FLAIR, introduced in @chap:heal, required a
different infrastructure from the PeerSim--Gossipy hybrid used for
HEAL. FLAIR targets physical wireless networks, and its evaluation
therefore demands a simulator that faithfully models radio propagation,
interference, and the MAC-layer behavior of Wi-Fi links. ns-3 was
selected for this purpose, as it provides mature and well-validated
Wi-Fi network components that cover the physical and link layers
required by the FLAIR evaluation scenarios.

The ns-3 distribution already includes the necessary network-level
building blocks: Wi-Fi channel models, IEEE 802.11 MAC implementations,
and node mobility support. What it does not provide is any machine
learning substrate. Integrating a learning layer into ns-3 raised the
same fundamental challenge encountered throughout the simulator
evaluation process: bridging a network simulation framework with
machine learning primitives.

Several integration strategies were considered. The ns-3 Python
bindings offer a scripting interface to the simulator, which in
principle allows Python-side machine learning code to be called from
within a simulation. However, this interface imposes significant
overhead at the boundary between the C++ simulation core and the
Python interpreter, and its support for fine-grained per-node,
per-cycle callbacks is limited. A second approach — connecting ns-3
to PyTorch through model serialization, analogous to the
PeerSim--PyTorch bridge attempted earlier — was evaluated but
discarded for the same reasons: the serialization overhead and the
complexity of synchronizing two independent runtimes proved
unmanageable at the scale of the experiments. A third option, a
dedicated ns-3 machine learning package, was also examined but found
to be insufficiently mature for the model architectures required by
FLAIR.

The approach ultimately retained was to reimplement the required
machine learning models directly in C++, within the ns-3 codebase.
This decision carries a significant development cost: model
architectures, training routines, and aggregation operators must
all be written from scratch without the support of an automatic
differentiation framework. It yields, however, substantial
advantages in return. The simulation is entirely self-contained:
there are no external runtime dependencies, no serialization
boundaries, and no synchronization overhead. Launch procedures are
identical to those of any standard ns-3 simulation. Performance is
optimal, as the learning computations execute natively within the
same process as the network simulation. The resulting setup allowed
FLAIR to be evaluated under realistic wireless conditions with full
control over the experimental parameters, at the cost of a longer
initial development phase.

=== Conclusion <sec:simulators-conclusion>

The simulation infrastructure described in this chapter was not built
in a straight line. The exploration of candidate platforms, the dead
ends, the partial implementations, and the successive tool rewrites
consumed a significant share of the time and energy invested in this
thesis. This cost was not without return. Each evaluated platform —
whether ultimately adopted or abandoned — deepened the understanding
of what a decentralized learning simulator must provide, and each
implementation effort, including those that were discarded, sharpened
the understanding of the protocols themselves: their failure modes,
their sensitivity to topology, and the subtleties of their aggregation
logic that only become apparent when one attempts to implement them
faithfully.

The hybrid PeerSim--Gossipy architecture that emerged from this
process is a pragmatic solution rather than an ideal one. Its
limitations are acknowledged in @sec:hybrid-protocol. It was,
however, sufficient to produce the experimental results of @chap:elevator and @chap:heal,
and the engineering discipline applied throughout — reproducible
builds, containerization, automated pipelines, versioned data — means
that those results are fully auditable and re-runnable.

Toward the end of this thesis, work began on a new simulator designed
from scratch to address the shortcomings identified over the preceding
years. The tool is written entirely in Python, structured as a
modular, extensible library with a command-line interface designed to
make experimental configuration and execution straightforward. The
simulation engine is fully parallelized from the ground up. The
machine learning layer is based on NumPy rather than PyTorch: a
deliberate choice motivated by the observation that the model
operations performed in decentralized learning — weighted averaging,
gradient accumulation, parameter broadcasting — do not require the
full apparatus of an automatic differentiation framework, and that a
lighter dependency leads to faster simulation and simpler deployment.
The simulator natively supports dynamic network conditions: node
failures, churn, and Byzantine participants. It also handles
heterogeneous data distributions and personalized learning scenarios,
two dimensions that the current infrastructure addresses only
partially. The tool is still under active development, but early
results are encouraging.