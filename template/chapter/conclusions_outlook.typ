#set quote(block: true)

= Conclusions and Outlook <chap:conclusions_outlook>

== General conclusions

This thesis was motivated by a fundamental question: can federated learning be conducted in a truly decentralised manner? The initial intuition pointed toward blockchain as a natural substrate for decentralised coordination. However, a systematic survey of the state of the art revealed an existing paradigm — gossip learning — that already eliminates the central server. Yet gossip learning generally underperforms federated learning, both in convergence speed and, in most settings, in final model accuracy, precisely because it lacks any form of structured aggregation. This underperformance is not, however, systematic: the literature reports instances in which gossip learning can reach the convergence quality of federated learning once the algorithms are adequately configured (@chap:learning). In practice, achieving competitive behaviour with gossip learning thus requires a comparatively careful configuration of parameters, which makes it a less reliable substrate for recovering the efficiency of a centralised reference. By contrast, because our approach introduces structured global aggregation on top of a decentralised overlay, it relies less on such delicate configuration and we are correspondingly more confident of approaching the convergence speed of federated learning. This observation shifted the research question to a lower level of the stack: rather than modifying the learning algorithm itself, we asked whether the underlying communication topology could be engineered to recover the benefits of structured aggregation, while preserving full decentralisation. This led us to survey the peer sampling and overlay management literature, in search of protocols capable of shaping the network toward a topology that would support efficient global aggregation.

Several families of protocols have been proposed, yet none was designed with the explicit goal of structuring the overlay to support global aggregation — in particular, none considered the deliberate emergence of hub nodes as a design objective.
Random-walk and multi-hop gossip protocols accelerate information propagation by
reducing the effective diameter of the communication graph, but they do not
produce a structured topology and their gains in practice are limited by increased
message complexity and latency. Power-law overlay protocols produce degree
distributions that are more favourable to fast dissemination, yet they fall short of
the aggregation efficiency achievable with explicit hub nodes. Byzantine-resilient
peer sampling protocols address a different concern — security rather than
performance — and do not consider decentralised learning as a target use case.
More broadly, very few peer sampling protocols have been designed with
decentralised machine learning as an explicit operational context, as documented
in @chap:overlay.

The machine learning literature exhibits a complementary blind spot. The dominant
research direction in distributed learning is federated learning, where a central
server coordinates model aggregation; the question of full decentralisation
receives comparatively little attention. Blockchain-based approaches do eliminate
the central coordinator, but they rely on complete communication graphs and do
not scale to large networks. Gossip learning protocols are scalable and genuinely
decentralised, yet their lack of global aggregation generally leads to
underperformance relative to federated learning in convergence speed and, in
most settings, in final accuracy (as discussed in @chap:learning, this gap can
narrow, and sometimes close, when gossip learning is adequately configured).
The result is a clear gap: no existing protocol simultaneously achieves
decentralisation, scalability, and aggregation efficiency.

This gap shaped the central research question of the thesis: _how can the efficiency of gossip learning be improved so as to approach federated learning, without sacrificing decentralisation?_ 

The survey of the peer sampling literature confirmed our intuition that the answer lies not at the application layer but one level below, at the peer sampling layer: by shaping the communication topology, it is possible to introduce structured aggregation without relying on any pre-assigned coordinator. However, as documented in @chap:overlay, no existing protocol was designed with this objective in mind — none considered the deliberate elevation of nodes to the role of hubs as a design goal. This absence left us no choice but to design such a protocol from scratch.

The result is *Elevator*, a decentralised peer-to-peer overlay protocol that organises nodes through a lightweight, self-organising random election mechanism. Crucially, Elevator is application-agnostic: it provides a general-purpose structured overlay that any distributed algorithm can exploit.
The evaluation of Elevator rests on three complementary pillars. First, a theoretical analysis characterises the protocol's behaviour in terms of overlay properties — diameter, average shortest path length, and clustering coefficient — and derives analytical bounds on convergence and hub election dynamics. Second, these theoretical results are validated through large-scale simulations conducted on PeerSim, a peer-to-peer network simulator widely used and recognised by the research community. Third, a real implementation over TCP/IP confirms that the protocol behaves as predicted at the network level, bridging the gap between simulation and deployment. The consistency across all three levels of evaluation strengthens confidence in the correctness and robustness of the protocol.

This multi-level methodology did not come for free. Peer-to-peer networks with emergent hub structures of the kind introduced by Elevator are a novelty, and the research community has not converged on standard evaluation practices for such systems. A substantial methodological effort was therefore devoted to establishing appropriate scientific rigour: selecting and justifying the evaluation metrics, designing visualisations that faithfully represent the structural properties of the overlay, and adapting PeerSim — a simulator that is over twenty years old and was not designed with hub-based overlays in mind — to the requirements of this work. In particular, scaling simulations to networks of thousands or even hundreds of thousands of nodes, which is the operational target of a general-purpose peer-to-peer protocol, demanded significant engineering effort to make PeerSim tractable at that scale. The evaluation framework developed in the course of this work — comprising the
selection of appropriate overlay metrics, the design of visualisations adapted to
hub-based structures, and the engineering of a scalable simulation infrastructure
— is itself a contribution to the community. In the absence of established practices
for evaluating hub-based peer-to-peer overlays, this thesis proposes and justifies
a methodology that future work in this area can build upon.

Building on Elevator, the *HEAL* protocol (Hub Enhanced Adaptive Learning) instantiates federated learning directly atop the structured overlay. Hubs serve as aggregators, and the inter-hub communication ensures that locally aggregated models are further reconciled across the network. This two-level aggregation scheme is the mechanism by which HEAL recovers the efficiency of federated learning while preserving decentralisation.

The evaluation of HEAL relies on simulation, but the machine learning component is not simulated: multiple real model architectures are trained on several benchmark datasets covering different learning tasks, ensuring that the measured accuracy figures reflect genuine model behaviour rather than approximations. The combination of diverse models, datasets, and task types provides strong evidence that the results are not artefacts of a particular experimental setup. Accuracy — a standard metric in the federated learning literature — is complemented by overlay topology metrics inherited from the Elevator evaluation, giving a joint view of network-level and learning-level performance. HEAL achieves competitive accuracy under fault-free conditions, and its resilience is confirmed under both crash failures and churn, owing to the redundant hub submission mechanism. Integrating the machine learning workload into large-scale peer-to-peer simulations further required adapting the simulation infrastructure to handle the additional computational and memory demands of real model training within a distributed event-driven framework.

The HEAL framework was subsequently extended in two directions, each addressing
a different deployment constraint. The *Lift* protocol addresses a subtle but critical
vulnerability in Elevator: the hub election mechanism is precisely the highest-value
attack surface in the stack, since an adversary that controls hub election effectively
controls the entire aggregation process. A systematic study of Byzantine resilience
in Elevator reveals that the protocol withstands a range of adversarial behaviours
without modification — including passive byzantines that return empty neighbour
lists, single active byzantines that inflate their own election probability by
self-reporting, and multiple non-colluding byzantines employing the same strategy.
However, when byzantines collude — sharing knowledge of one another and
returning fellow byzantines in their neighbour lists — as few as two percent of
malicious nodes are sufficient to guarantee that all byzantines are elected as hubs,
fully compromising the aggregation layer. Lift addresses this threat through a
dedicated defence mechanism at the overlay level, extending the collusion tolerance
threshold to ten percent of byzantine nodes while preserving the decentralised
nature of the election process. Beyond this threshold, colluding byzantines are
again able to capture hub roles, which defines the boundary of the current security
guarantee. Crucially, Lift operates entirely at the peer sampling layer and is
transparent to the learning layer: HEAL requires no modification to benefit from
the stronger security guarantees provided by the hardened overlay.

The *FLAIR* protocol (Federated Learning with Adaptive Integrity-preserving
Randomness) validates the modularity of the layered architecture by instantiating
it in a fundamentally different operational context: resource-constrained ad-hoc
wireless networks, where the overlay topology is shaped by radio range,
interference, and node mobility rather than by an explicit election mechanism. In
place of Elevator, FLAIR employs a resource-aware cluster-head election mechanism
inspired by LEACH, in which each node associates with the cluster head from which
it receives the strongest signal. Aggregation is confined to the cluster level, and
cluster heads rotate at every round, so that progressive global model mixing
emerges from topology dynamics alone, without any inter-cluster coordination.
The evaluation on the ns-3 network simulator validates these properties across static, fault-prone, mobile,
and heterogeneous deployment scenarios. Taken together, HEAL and FLAIR
constitute two existence proofs that the layered architecture can yield protocols
adapted to fundamentally different deployment contexts — a result that opens a
broad design space for future protocols targeting other network environments such
as satellite, vehicular, or sensor networks.

Considered as a whole, the contributions of this thesis establish a coherent
framework for decentralised, efficient, and resilient machine learning over
peer-to-peer networks. The progression from the state of the art, through Elevator, to HEAL, Lift, and FLAIR constitutes a principled answer to the motivating question: structured aggregation can be achieved without centralisation, provided that the overlay layer is designed with that goal in mind.

It is worth reflecting on the scope and conditions under which this answer holds.
The results established in this thesis are most conclusive under conditions that
approximate the idealised setting of federated learning: data distributions that are
not severely heterogeneous, network scales of up to one thousand nodes for the
overlay layer and one hundred nodes for the learning layer, and fault rates that
remain moderate. Under these conditions, HEAL demonstrably closes the accuracy
gap with centralised federated learning while operating without any coordinator.
Beyond these conditions — in the presence of strongly non-IID data, at very large
scales, or under sustained Byzantine attack at the learning layer — the framework
provides resilience mechanisms and encouraging empirical results, but formal
guarantees are not yet established. The contributions of this thesis should
therefore be understood as a proof of concept and a rigorous foundation, rather
than a fully deployed solution: they demonstrate that structured aggregation
without centralisation is achievable and practically effective, and they identify
precisely the conditions under which the approach succeeds and the boundaries
beyond which further work is needed.

More broadly, this thesis should be read not as an incremental contribution to an
existing body of work, but as the opening of a new research territory. By combining
a novel peer sampling layer with a modular, application-agnostic learning
architecture, the framework departs from both the federated learning tradition —
which has largely taken centralisation for granted — and the gossip learning
tradition — which has accepted limited aggregation efficiency as an inherent
constraint. The resulting design space, in which overlay structure and learning performance
are co-designed from the ground up, had not, to the best of the author's
knowledge, been explored in a principled way prior to this work. The protocols, evaluation methodology, and open
problems identified in this work collectively define a new research agenda, and it
is the author's hope that they will serve as a foundation for a broader community
effort toward truly decentralised, efficient, and trustworthy machine learning over
peer-to-peer networks.

#quote(quotes: true, attribution: [René Descartes, _Discours de la méthode_, 1637])[
  Diviser chacune des difficultés que j'examinerais en autant de parcelles
  qu'il se pourrait et qu'il serait requis pour les mieux résoudre.
]

== Limitations

Despite the contributions presented in this thesis, several limitations must be
acknowledged.

The theoretical analysis of Elevator's convergence relies on idealised assumptions:
the absence of failures during overlay construction, and several reliability
assumptions on the underlying physical network, such as reliable message
delivery and stable connectivity. Relaxing these assumptions — for instance, by
accounting for transient link failures or message loss at the network layer — would
yield a more realistic characterisation of the protocol's behaviour and remains an
open theoretical problem.

On the simulation side, the Elevator experiments do not model the underlying
network layer, abstracting away latency, bandwidth, and packet loss. Furthermore,
the largest simulations conducted in this work reached networks of one thousand
nodes; while this is sufficient to observe the structural properties of the overlay,
a general-purpose peer-to-peer protocol should ideally be validated at scales of
tens or hundreds of thousands of nodes. Reaching such scales would require a more capable simulation infrastructure; this
is precisely the motivation behind the new unified simulator currently under
development, which is described among the near-term research directions.
Regarding fault tolerance, the fault scenarios considered remain moderate in
intensity; higher fault rates and more sustained churn patterns would stress-test
the resilience mechanisms more thoroughly. Similarly, the Byzantine fault
experiments consider relatively straightforward attack strategies; more
sophisticated adversarial behaviours — such as coordinated collusion or adaptive
attacks — are left for future work.

The real network experiments over TCP/IP were conducted on a modest testbed
in terms of both node count and geographic distribution. A larger and more
geographically dispersed deployment would provide stronger evidence of the
protocol's behaviour under realistic wide-area network conditions.

The HEAL experiments were limited to networks of one hundred nodes and
to relatively simple machine learning models. Evaluating HEAL with larger node
populations and more complex model architectures — such as deeper convolutional
networks or transformer-based models — would better reflect the demands of
real-world decentralised learning deployments and would allow a more rigorous
assessment of the framework's scalability at the learning layer. Beyond model
complexity, the evaluation relies solely on accuracy as a performance metric;
complementary measures such as communication cost, convergence speed, or
energy consumption would provide a more complete picture of the framework's
practical efficiency. Furthermore, no formal convergence guarantee is established
for HEAL: the observation that the protocol reaches competitive accuracy levels is
empirical, and a theoretical proof of convergence — even under simplified
assumptions — remains an open problem.

The experimental methodology also presents limitations. Each experimental
configuration was evaluated over only five simulation runs, which may be
insufficient to fully account for the variance introduced by random initialisation
and stochastic training dynamics; a larger number of runs would strengthen the
statistical reliability of the reported results. The range of configurations explored
is likewise limited: the number of hubs, the number of local training rounds
between successive aggregation phases, and the role of hubs as potential
training participants were not systematically varied. A broader parameter study
would clarify the sensitivity of HEAL's performance to these design choices, some
of which were partially explored in the context of FLAIR.

All experiments were conducted in simulation, using a cycle-based notion
of time that does not reflect real execution costs. Deploying HEAL on a physical
testbed would allow the actual overhead of the inter-hub aggregation phase to be
measured — in terms of wall-clock time and network traffic — and would enable
a direct comparison with baseline algorithms under identical hardware and network
conditions. At a more fundamental level, the current design assumes that the
inter-hub aggregation phase is synchronous, meaning that all hubs must
coordinate within a shared round boundary. Achieving a fully asynchronous
variant of HEAL — where hubs aggregate independently without any global
synchronisation primitive — remains an open challenge, and would remove the
implicit dependency on an external coordination mechanism, whether centralised
or distributed.

The Lift protocol, while effective up to a collusion threshold of ten percent of
byzantine nodes, presents several limitations. The adversarial model considered
remains relatively constrained: byzantine nodes operate independently or collude
as a single coordinated group, but more sophisticated threat models are not addressed. Furthermore, Lift hardens only the
overlay layer: the learning layer remains unprotected against poisoning attacks,
in which malicious nodes submit manipulated model updates, and against privacy
attacks such as gradient inversion or membership inference. The security
guarantees of Lift should therefore be understood as a necessary but not
sufficient condition for deploying HEAL in fully adversarial environments.

The FLAIR protocol presents its own set of limitations. Several are shared with
HEAL: the experimental evaluation assumes IID data distributions across nodes,
the behaviour of the protocol under non-IID conditions remains an open question,
and no formal convergence guarantee is established under non-stationary cluster
topologies — as cluster heads rotate and node associations change, the conditions
under which the global model converges to a good solution are not theoretically
characterised. Beyond these shared limitations, the network model underlying the
FLAIR evaluation remains simplified despite the use of ns-3. Message loss,
message corruption, propagation delay, response latency, and the impact of
message size on communication overhead are not explicitly accounted for in the
experimental setup. While ns-3 provides higher-fidelity modelling of wireless
channel conditions than the simulators used for HEAL, the evaluation still
abstracts away several aspects of real wireless network behaviour that could
significantly affect protocol performance in deployment.

== Outlook <sec:outlook>

The work presented in this thesis opens several research directions, spanning
immediate extensions of the existing protocols to longer-term theoretical and
applied challenges.

In the near term, two directions are already under active investigation. The first
concerns the hub election mechanism in Elevator. In its current form, election is
based on a random process, which ensures fairness but does not account for the
heterogeneity of nodes in real deployments — nodes differ widely in computational
capacity, memory, bandwidth, and availability. An ongoing line of work extends the
election mechanism to incorporate node capability metrics, so that hubs are
elected with a bias toward the most capable participants while preserving the
decentralised nature of the process. Preliminary results are encouraging and
suggest that capability-aware election yields overlays with better sustained
aggregation throughput. A complementary direction explores the sensitivity of
Elevator to the initial network topology. The current protocol is initialised from a
random graph; preliminary experiments investigating whether Elevator converges
toward a hub-based structure from alternative starting topologies — such as
ring graphs or scale-free networks — have yielded encouraging results, and a
systematic study of this convergence behaviour is underway. In parallel, ongoing
work targets the efficiency of the Elevator protocol itself: reducing message
complexity, lowering memory overhead, and simplifying the algorithm without
compromising its structural guarantees. These optimisations are in progress and
have not yet been fully validated.

The second near-term direction concerns data heterogeneity in HEAL. The current
aggregation scheme does not account for statistical heterogeneity across nodes,
which can cause the global model to drift away from the local data distributions of
individual participants. Adapting the aggregation strategy — for instance through
personalisation or locally-weighted aggregation — to mitigate this effect is a
natural and pressing extension.

A third near-term priority is the development of a new simulation infrastructure.
The experimental work in this thesis relied on two separate simulators — PeerSim
for the peer sampling layer and Gossipy for the machine learning layer — whose
integration introduced both engineering complexity and methodological
constraints. A new simulator, written from scratch in Python, is currently under
development. It is designed to handle peer sampling, dynamic network evolution,
and machine learning workloads within a single unified framework, using NumPy
for numerical computation. The objective is twofold: to achieve better performance
than the existing tools at the scales of interest, and to provide a simpler and more
accessible experimentation platform for future work in decentralised learning.

At medium term, several challenges stand out. The first is the integration of
robustness against Byzantine attacks into HEAL itself. While Lift addresses
Byzantine resilience at the overlay level, the learning layer remains vulnerable to
poisoning attacks, in which malicious participants submit manipulated model
updates, as well as to privacy attacks such as gradient inversion or membership
inference. Equipping HEAL with defences against these threat models — whether
through robust aggregation rules, differential privacy mechanisms, or secure
aggregation protocols — is a necessary step toward deployment in adversarial
environments. This hardening effort extends naturally to the Elevator layer itself:
adding message encryption and digital signatures would protect against Byzantine
participants attempting to manipulate inter-node communication, and deploying
the stack over a privacy-preserving overlay such as Tor would further protect
participant identities and message confidentiality.

The second medium-term objective is a large-scale real-world deployment of
Elevator and HEAL. Such a deployment would validate the scalability assumptions
made in the simulation studies — in particular the behaviour of the protocol at
node counts that could not be reached within the simulation infrastructure — and
would expose practical challenges such as churn patterns, network heterogeneity,
and hardware diversity that are difficult to reproduce faithfully in simulation.

A third medium-term direction is the evaluation of HEAL with large-scale machine
learning models. The experiments in this thesis were deliberately limited to
lightweight architectures in order to keep simulation tractable. Assessing whether
HEAL can sustain the aggregation of models with hundreds of millions of
parameters — of the scale of contemporary large language models — would expose
fundamental limitations in terms of communication bandwidth, aggregation
latency, and memory requirements at hub nodes, and would motivate targeted
protocol adaptations for this regime.

In the longer term, several directions define a broader research programme. First,
the scope of HEAL is currently limited to supervised learning tasks; extending the
framework to unsupervised learning and reinforcement learning would
significantly broaden its applicability, particularly for settings where labelled data
is scarce or where agents must learn from interaction rather than from a fixed
dataset. Second, HEAL operates under the horizontal federated learning
assumption, where all participants share the same feature space. Adapting the
framework to vertical federated learning — where different participants hold
different features of the same instances — raises fundamentally different
challenges in terms of aggregation, communication, and privacy, and would open
the framework to a wider class of collaborative learning scenarios. Third, and most fundamentally, establishing formal convergence guarantees for
HEAL remains an open theoretical problem. While the limitations section
establishes that the current results are purely empirical, a rigorous convergence
analysis would need to go further: beyond confirming the empirical observations
of this thesis, such guarantees would need to account for realistic operating
conditions — partial participation, heterogeneous data distributions, and dynamic
network topologies — and would provide actionable bounds on the number of
aggregation rounds required to reach a target model quality.

A fourth long-term challenge is the design of an incentive mechanism to reward
active participation and deter free-riding. In any open peer-to-peer system, nodes
may choose to consume the outputs of collaborative learning without contributing
computational resources or local data. Addressing this problem requires a
mechanism that can attribute contributions, measure effort, and distribute rewards
in a decentralised manner. One approach is to design such a mechanism as a
standalone protocol layer within the existing stack. An alternative — and
potentially complementary — direction is to integrate HEAL with a blockchain
system or a layer-two payment network such as the Lightning Network, so that
node contributions are rewarded through on-chain or off-chain transactions. Such
a hybrid architecture would combine the scalability of the HEAL learning stack
with the trust and incentive guarantees of a decentralised ledger.

Finally, a long-term applied objective is the deployment of the full stack — 
Elevator, HEAL, and associated security and incentive layers — in a concrete
industrial use case. Domains such as autonomous vehicles and drone swarms
present particularly demanding requirements: high mobility, stringent latency
constraints, heterogeneous hardware, and safety-critical model quality. Designing
an end-to-end system architecture for such a setting, and validating it under
realistic operational conditions, would constitute a significant step toward the
industrial deployment of fully decentralised machine learning.

#quote(quotes: true, attribution: [Karl Popper])[
  Our knowledge can only be finite, while our ignorance must necessarily be infinite.
]