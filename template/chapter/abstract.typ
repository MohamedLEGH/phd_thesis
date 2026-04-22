#heading(level: 2, outlined: false, numbering: none)[Abstract]

Decentralized peer-to-peer systems offer a compelling alternative to
centralized architectures for large-scale distributed computing: they
are inherently resilient to failures, scalable by design, and
respectful of data locality. Yet coordinating a large number of
autonomous nodes without any central authority remains a fundamental
challenge, particularly when the application layer demands
collaborative machine learning over private, heterogeneous data.

This thesis makes two original contributions. The first is Elevator,
a fully decentralized overlay protocol that organizes a peer-to-peer
network into a two-tier topology through an emergent hub election
mechanism. At each cycle, every node connects preferentially to the
$h$ most connected nodes in its two-hop neighborhood while retaining
$c - h$ random connections. This preferential attachment causes $h$
hub nodes to emerge spontaneously within a small number of cycles,
forming a dense interconnected core to which all other nodes are
directly attached. Elevator is complemented by Lift, a
Byzantine-resilient extension that prevents adversarial nodes from
manipulating the election outcome through a shared pseudo-random
number generator seeded by the current hub identifiers. Both
protocols are analyzed theoretically and evaluated through
large-scale simulations and on a real TCP/IP network.

The second contribution is HEAL (Hub Enhanced Adaptive Learning), a
decentralized federated learning framework built on Elevator. HEAL
organizes model aggregation into two successive phases per cycle: an
intra-hub phase, in which each hub aggregates the models of its
attached nodes, and an inter-hub phase, in which hubs exchange and
merge their respective aggregates. This hierarchical structure
accelerates convergence compared to flat gossip and epidemic learning
baselines. HEAL is evaluated on image and text classification tasks
under fault-free operation, static node failures, and churn.
A complementary protocol, FLAIR, adapts hub-based aggregation to
physical wireless networks by electing cluster heads based on node
capabilities following the LEACH framework, and is evaluated on
the ns-3 simulator under realistic Wi-Fi conditions.