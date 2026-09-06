#heading(level: 2, outlined: false, numbering: none)[Abstract]

Decentralized peer-to-peer systems offer a compelling alternative to
centralized architectures for large-scale distributed computing: they
are inherently resilient to failures, scalable by design, and
respectful of data locality. Yet coordinating a large number of
autonomous nodes without any central authority remains a fundamental
challenge, particularly when the application layer demands
collaborative machine learning over private, heterogeneous data.

This thesis proposes a layered architecture for decentralized learning, which separates the communication substrate from the learning logic. Its main contribution is an architecture composed of an overlay layer, responsible for the network topology, and a decentralized federated learning layer built on top of it. The overlay layer is instantiated by Elevator, a fully decentralized peer-sampling protocol that organizes a peer-to-peer network into a two-tier topology through an emergent hub election mechanism. At each cycle, every node connects preferentially to the
$h$ most connected nodes in its two-hop neighborhood while retaining
$c - h$ random connections. This preferential attachment causes $h$
hub nodes to emerge spontaneously within a small number of cycles,
forming a dense interconnected core to which all other nodes are
directly attached. Elevator is analyzed theoretically and evaluated through large-scale simulations and on a real TCP/IP network. Elevator is complemented by Lift, a
Byzantine-resilient extension that prevents adversarial nodes from
manipulating the election outcome through a shared pseudo-random
number generator seeded by the current hub identifiers, and is evaluated through simulation.

The decentralized federated learning layer is instantiated by HEAL (Hub Enhanced Adaptive Learning), a
decentralized federated learning framework built on the Elevator overlay. HEAL
organizes model aggregation into two successive phases per cycle: an
intra-hub phase, in which each hub aggregates the models of its
attached nodes, and an inter-hub phase, in which hubs exchange and
merge their respective aggregates. This hierarchical structure
accelerates convergence compared to flat gossip and epidemic learning
baselines. HEAL is evaluated on image and text classification tasks
under fault-free operation, static node failures, and churn.
We also propose to adapt the architecture to the context of wireless networks with FLAIR, which instantiates the same layered design in that setting by electing cluster heads based on node
capabilities following the LEACH framework, and is evaluated on
the ns-3 simulator.