#import "@preview/cetz:0.4.2": canvas, draw

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

== Common network topologies <sec:common_topologies>

Network topology refers to the structural organization of a network:
the way nodes are interconnected and how links are arranged between
them. Different topologies lead to fundamentally different properties
in terms of connectivity, robustness, routing efficiency, and
scalability. In the context of overlay networks, topologies are not
viewed as static structures but as reference models describing the
possible shapes of snapshot graphs $G(t)$ induced by peer-to-peer
protocols over time.

Network topologies can be broadly divided into two categories.
*Deterministic topologies* are defined by explicit construction rules
that fully determine the presence of each edge from the position or
role of nodes --- stars, rings, trees, grids, and meshes fall into
this category. *Random topologies* are generated according to
probabilistic rules, and include classical random graphs as well as
more advanced models such as small-world networks, power-law
networks, and stochastic block models.

==== Mesh
A mesh network topology corresponds to a complete graph, in which every node is directly connected to every other node in the network. This topology offers optimal communication properties, as any node can reach any other node in a single hop, resulting in a graph diameter equal to one and minimal latency for message dissemination. Such full connectivity also provides high redundancy, making the network inherently robust to individual link failures. However, these advantages come at a prohibitive cost in large-scale systems. Each node must maintain a connection with all other nodes, leading to a quadratic growth in the number of links and significant overhead in terms of bandwidth, memory, and connection management. Moreover, a mesh topology requires each node to know the complete list of participants in the network, which is impractical or impossible in dynamic environments where nodes frequently join and leave. As a result, mesh networks are inherently static and do not scale well, limiting their applicability to small, tightly controlled systems rather than large peer-to-peer or highly dynamic overlay networks.

#figure(diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0), name: "1", radius: 2em)
edge(label("2"), "-", stroke: 1pt)
edge(label("3"), "-", stroke: 1pt)
edge(label("4"), "-", stroke: 1pt)
node((1,1), name: "2", radius: 2em)
edge(label("3"), "-", stroke: 1pt)
edge(label("4"), "-", stroke: 1pt)
node((0, 1), name: "3", radius: 2em)
edge(label("4"), "-", stroke: 1pt)
node((1,0), name: "4", radius: 2em)
}),
  caption: [A mesh network with 4 nodes.],
) <mesh-network>

==== Star
A star network topology corresponds, from a graph-theoretic perspective, to a graph in which all nodes are connected to a single central node, often referred to as the hub. This topology naturally maps to a client–server architecture, where the central node acts as a server and all other nodes act as clients. Communication between any two clients must pass through the central node, which results in a graph diameter equal to two and enables fast message exchanges with low hop count. The simplicity of this topology makes it easy to deploy, manage, and control, and clients only need to maintain a single connection to participate in the network. However, the central node constitutes a critical bottleneck, as it must handle all communications and can become overloaded as the network grows. More importantly, it represents a single point of failure: if the server crashes, is disconnected, or is compromised, the entire network becomes unavailable.
#figure(
diagram({
  node((1,0), name: "Server", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client1"), "-", stroke: 1pt)
  edge(label("Client2"), "-", stroke: 1pt)
  edge(label("Client3"), "-", stroke: 1pt)

  node((0,1.5), name: "Client1", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((1,1.5), name: "Client2", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((2,1.5), name: "Client3", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))  
}),
  caption: [A star topology.],
) <star-topology>
==== Multi-star

A multi-star topology can be seen as an extension of the star topology in which several central nodes coexist, each forming a local star with a subset of clients. From a graph-theoretic point of view, this corresponds to a collection of star subgraphs that may or may not be interconnected. This topology is widely used in cloud systems, for instance in distributed databases where a primary server is supported by one or more replica servers that can take over in case of failure or overload. Multi-star architectures are also common in geographically distributed systems, where services are replicated across multiple regions to reduce latency and provide better quality of service to users worldwide. Several variants of multi-star topologies exist: in some designs, clients are connected to all available servers, while in others each client is connected to a single server at a time; similarly, servers may be fully interconnected, partially connected, or completely isolated from each other. Compared to a single-star topology, multi-star networks improve scalability, fault tolerance, and availability, but they still rely on centralized components at the level of each star. As a result, they remain more structured and less decentralized than peer-to-peer topologies, and require coordination mechanisms for load balancing, leader election, or consistency among servers.
#figure(
diagram({
  node((0,0), name: "Server 1", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client1"), "-", stroke: 1pt)
  edge(label("Client2"), "-", stroke: 1pt)
  edge(label("Client3"), "-", stroke: 1pt)
  node((2,0), name: "Server 2", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client1"), "-", stroke: 1pt)
  edge(label("Client2"), "-", stroke: 1pt)
  edge(label("Client3"), "-", stroke: 1pt)

  node((0,1.5), name: "Client1", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((1,1.5), name: "Client2", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((2,1.5), name: "Client3", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))  
}),
  caption: [A multi-star topology, with 2 servers and 3 clients. Each client is connected to each server.],
) <multi-star-topology>

==== Ring
A ring topology corresponds to a graph in which each node maintains exactly two connections, typically referred to as its left and right neighbors, forming a closed cycle. From a graph-theoretic perspective, this structure is a simple cycle graph. Ring topologies require coordination mechanisms between nodes, as well-defined rules are needed to handle the addition or removal of one or more nodes without breaking the ring and disconnecting the network. In particular, join and leave operations must ensure that neighbor relationships are consistently updated to preserve connectivity. The diameter of a ring network grows linearly with the number of nodes, i.e., it is proportional to $N$, which leads to potentially high communication latency as information may need to traverse many intermediate nodes. To mitigate this limitation, many ring-based systems introduce additional long-range links, often inspired by skip lists, allowing nodes to bypass large portions of the ring and significantly reduce routing and propagation times. Such enhancements improve efficiency while preserving the simplicity and locality properties of the underlying ring structure.
#figure(
diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0), name: "1", radius: 2em)
edge( "-", stroke: 1pt)
node((0.8,0.3), name: "2", radius: 2em)
edge( "-", stroke: 1pt)
node((0.8,1.2), name: "3", radius: 2em)
edge( "-", stroke: 1pt)
node((0,1.5), name: "4", radius: 2em)
edge( "-", stroke: 1pt)
node((-0.8,1.2), name: "5", radius: 2em)
edge( "-", stroke: 1pt)
node((-0.8,0.3), name: "6", radius: 2em)
edge(label("1"),"-", stroke: 1pt)

}),
  caption: [A ring topology, with 6 nodes.],
) <ring>

==== Grid / Lattice

A grid (or lattice) network topology arranges nodes in a regular
$d$-dimensional structure, where each node is connected only to its
immediate neighbors along each dimension. In a $d$-dimensional
lattice, each interior node has exactly $2d$ neighbors: two per
dimension, corresponding to its left and right neighbors along each
axis. The most common case encountered in practice is the
two-dimensional grid, where each interior node has exactly four
neighbors, while boundary and corner nodes have three and two
neighbors respectively.

It is worth noting that the one-dimensional grid corresponds exactly
to the ring topology discussed earlier, where each node is connected
to exactly two neighbors forming a closed cycle. At the other
extreme, the *hypercube* is a $d$-dimensional grid over $N = 2^d$
nodes, in which each node has exactly $d = log_2 N$ neighbors. This
topology offers a favorable trade-off between degree and diameter:
the diameter grows as $O(log N)$, significantly better than the
two-dimensional grid while maintaining a moderate and uniform degree.

The local nature of connections in grid topologies comes at the cost
of communication efficiency. The diameter of a two-dimensional
$n times n$ grid grows as $O(n) = O(sqrt(N))$, meaning that messages
may need to traverse many hops to reach distant nodes. Information
dissemination and aggregation processes are therefore significantly
slower than in mesh or scale-free topologies.

#figure(
  diagram(
    node-fill: green.lighten(60%),
    node-stroke: 1pt,
    spacing: 18mm,
    {
      // Row 0
      node((0,0), name: "n00", radius: 1.2em)
      edge(label("n10"), "-", stroke: 1pt)
      edge(label("n01"), "-", stroke: 1pt)
      node((1,0), name: "n10", radius: 1.2em)
      edge(label("n20"), "-", stroke: 1pt)
      edge(label("n11"), "-", stroke: 1pt)
      node((2,0), name: "n20", radius: 1.2em)
      edge(label("n30"), "-", stroke: 1pt)
      edge(label("n21"), "-", stroke: 1pt)
      node((3,0), name: "n30", radius: 1.2em)
      edge(label("n40"), "-", stroke: 1pt)
      edge(label("n31"), "-", stroke: 1pt)
      node((4,0), name: "n40", radius: 1.2em)
      edge(label("n50"), "-", stroke: 1pt)
      edge(label("n41"), "-", stroke: 1pt)
      node((5,0), name: "n50", radius: 1.2em)
      edge(label("n51"), "-", stroke: 1pt)

      // Row 1
      node((0,1), name: "n01", radius: 1.2em)
      edge(label("n11"), "-", stroke: 1pt)
      edge(label("n02"), "-", stroke: 1pt)
      node((1,1), name: "n11", radius: 1.2em)
      edge(label("n21"), "-", stroke: 1pt)
      edge(label("n12"), "-", stroke: 1pt)
      node((2,1), name: "n21", radius: 1.2em)
      edge(label("n31"), "-", stroke: 1pt)
      edge(label("n22"), "-", stroke: 1pt)
      node((3,1), name: "n31", radius: 1.2em)
      edge(label("n41"), "-", stroke: 1pt)
      edge(label("n32"), "-", stroke: 1pt)
      node((4,1), name: "n41", radius: 1.2em)
      edge(label("n51"), "-", stroke: 1pt)
      edge(label("n42"), "-", stroke: 1pt)
      node((5,1), name: "n51", radius: 1.2em)
      edge(label("n52"), "-", stroke: 1pt)

      // Row 2
      node((0,2), name: "n02", radius: 1.2em)
      edge(label("n12"), "-", stroke: 1pt)
      node((1,2), name: "n12", radius: 1.2em)
      edge(label("n22"), "-", stroke: 1pt)
      node((2,2), name: "n22", radius: 1.2em)
      edge(label("n32"), "-", stroke: 1pt)
      node((3,2), name: "n32", radius: 1.2em)
      edge(label("n42"), "-", stroke: 1pt)
      node((4,2), name: "n42", radius: 1.2em)
      edge(label("n52"), "-", stroke: 1pt)
      node((5,2), name: "n52", radius: 1.2em)
    }
  ),
  caption: [A $6 times 3$ two-dimensional grid network.],
) <fig:grid-network>
==== Hierarchical
A hierarchical network topology corresponds to a graph structured as a tree, where nodes are organized into different levels with parent–child relationships. This topology is commonly used in large-scale systems such as the Domain Name System (DNS), which relies on a hierarchical structure of authorities, ranging from root servers at the top level to top-level domain servers and authoritative name servers below. Compared to a star topology, hierarchical networks scale more effectively, as intermediate nodes distribute and absorb part of the workload, reducing the burden on any single central node. However, this topology remains largely static and is inherently fragile to failures. If an intermediate node fails, all its descendants become disconnected from the rest of the network, and a failure at the root level can impact the entire system. As a result, hierarchical topologies often require additional mechanisms such as redundancy, replication, or failover strategies to improve fault tolerance and availability.
#figure(
diagram({
  node((1,0), name: "ServerRoot", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Server1"), "-", stroke: 1pt)
  edge(label("Server2"), "-", stroke: 1pt)
  edge(label("Server3"), "-", stroke: 1pt)

  node((0,1.5), name: "Server1", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client1"), "-", stroke: 1pt)
  edge(label("Client2"), "-", stroke: 1pt)

  node((1,1.5), name: "Server2", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client3"), "-", stroke: 1pt)

  node((2,1.5), name: "Server3", radius: 2em, stroke: 1pt, fill: green.lighten(60%))  
  edge(label("Client4"), "-", stroke: 1pt)

  node((-1,2.8), name: "Client1", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((0,2.8), name: "Client2", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((1,2.8), name: "Client3", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((2,2.8), name: "Client4", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

}),
  caption: [A hierarchical (or tree) topology, with 2 levels, the root server and the intermediate servers.],
) <tree-topology>

==== Random network <sec:random-graph>

In contrast to the deterministic topologies presented above, real-world networks are often not explicitly organized but instead emerge in a largely random manner. Social networks, for instance, are formed through independent and uncoordinated interactions between individuals, leading to structures that are difficult to predict or control globally. To model such systems, random network models have been widely studied, among which the Erdős–Rényi random graph @erdHos1959evolution is the most classical and intuitive. In this model, edges are created at random, either by fixing the probability of connection between any pair of nodes or by fixing the expected number of connections per node. Despite the apparent lack of structure, random graphs exhibit several desirable properties. When the average degree k is greater than a small constant (typically slightly above 2), the probability that the graph is connected rapidly approaches one as the network size grows. Moreover, the diameter of the graph remains relatively small, scaling logarithmically with the number of nodes, which ensures efficient information propagation. In the directed case, k usually denotes the out-degree of each node, while the in-degree follows a binomial distribution centered around k. These properties make random graphs attractive as baseline models for large-scale decentralized systems, even though they do not capture heterogeneity or hub formation observed in many real networks.

#figure(
diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0), name: "1", radius: 2em)
edge(label("5"), "->", stroke: 1pt)
edge(label("2"), "->", stroke: 1pt)
node((0.3,1), name: "2", radius: 2em)
edge(label("5"), "->", stroke: 1pt)
edge(label("3"), "->", stroke: 1pt)
node((1,1.5), name: "3", radius: 2em)
edge(label("5"), "->", stroke: 1pt)
edge(label("2"), "->", stroke: 1pt)
node((1.8,1), name: "4", radius: 2em)
edge(label("1"), "->", stroke: 1pt)
edge(label("5"), "->", stroke: 1pt)
node((1.8,0), name: "5", radius: 2em)
edge(label("1"), "->", stroke: 1pt)
edge(label("4"), "->", stroke: 1pt)
}),
  caption: [A random directed graph, $k=2$, with $k$ the outdegree of each node.],
) <random-graph>

#definition(title: "Erdős–Rényi Random Graph G(n, p)")[
  Let $n in NN$ be the number of vertices and $p in [0, 1]$.
  An Erdős–Rényi random graph $G(n, p)$ is defined as a random graph
  $G = (V, E)$ where:
  - $V = {1, 2, ..., n}$ is the set of vertices;
  - for every unordered pair ${i, j} subset V$ with $i != j$,
    the edge ${i, j}$ is included in $E$ independently with probability $p$:
    $
    forall i != j, quad Pr({i, j} in E) = p.
    $
] <def:Erdos-Renyi-Gnp>

// #definition(title: "Erdős–Rényi Random Graph G(n, m)")[
//   Let $n in NN$ be the number of vertices and $m in NN$ the number of edges.
//   An Erdős–Rényi random graph $G(n, m)$ is a random graph
//   $G = (V, E)$ where:
//   - $V = {1, 2, ..., n}$;
//   - $E$ is chosen uniformly at random among all subsets of
//     ${ {i, j} | i, j in V, i != j }$
//     such that $|E| = m$.
// ] <def:Erdos-Renyi-Gnm>

#definition(title: "Directed Random Graph with Fixed Outdegree")[
  Let $n in NN$ be the number of nodes and $k in NN$ such that $k < n$.
  A directed random graph $G = (V, E)$ with fixed outdegree $k$ is defined as follows:
  - $V = {1, 2, ..., n}$;
  - for each node $i in V$, exactly $k$ outgoing edges are created;
  - the $k$ distinct destination nodes are selected uniformly at random
    from $V$, without replacement.
  
  Formally, for each node $i$, the set of outgoing neighbors
  $N_"out"(i)$ satisfies:
  $
  |N_"out"(i)| = k,
  $
  and each subset of size $k$ of $V$ is equally likely.
] <def:Directed-Random-Graph>

==== Small world

Small-world networks provide a more realistic representation of many real-world networks compared to classical random graphs. In such networks, the neighbors of a node are often also neighbors of each other, reflecting the common social phenomenon that “friends of my friends are also friends.” This property results in a high clustering coefficient, which contrasts with the Erdős–Rényi random graph, where clustering is typically very low. The Watts–Strogatz model @watts1998strogatz formalizes this concept by starting from a regular lattice and randomly rewiring a fraction of edges. These random long-range connections create shortcuts between distant parts of the network, significantly reducing the graph diameter while preserving local clusters. This combination of high clustering and small diameter makes small-world networks highly relevant for modeling social networks, communication systems, and peer-to-peer overlays, where local connectivity and fast information propagation are both crucial.

#definition(title: "Watts-Strogatz Small-World Network")[
  A Watts-Strogatz small-world network is generated by the following procedure:
  1. Start with a regular ring lattice with $N$ nodes, each connected to $K$ nearest neighbors ($K/2$ on each side).
  2. For each edge $(i,j)$, rewire it with probability $p$:
     - Remove the edge $(i,j)$.
     - Connect node $i$ to a randomly chosen node $k$ (excluding $i$ and avoiding duplicate edges).
  3. Repeat for all edges.
  
  Parameters:
  - $N$: number of nodes in the network.
  - $K$: initial number of neighbors per node (must be even).
  - $p$: rewiring probability, controlling the randomness of the network.
  
  Properties:
  - High clustering coefficient compared to random graphs.
  - Small average shortest-path length due to long-range shortcuts.
] <def:watts-strogatz>

#figure(
diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0), name: "1", radius: 2em)
edge(label("2"), "->", stroke: 1pt)
edge(label("3"), "->", stroke: 1pt)
edge(label("5"), "->", stroke: 1pt)
node((0.3,1), name: "2", radius: 2em)
edge(label("1"), "->", stroke: 1pt)
edge(label("3"), "->", stroke: 1pt)
node((1,1.5), name: "3", radius: 2em)
edge(label("1"), "->", stroke: 1pt)
node((1.8,1), name: "4", radius: 2em)
edge(label("5"), "->", stroke: 1pt)
node((1.8,0), name: "5", radius: 2em)
edge(label("1"), "->", stroke: 1pt)
edge(label("6"), "->", stroke: 1pt)
node((3,0.4), name: "6", radius: 2em)
edge(label("4"), "->", stroke: 1pt)
}),
  caption: [A directed small world network, with 2 clusters (left and right).],
) <watts-strogatz-example>

==== Power-law and scale-free networks <sec:power-law>

The Erdős–Rényi and Watts–Strogatz models are useful approximations,
but many real-world networks are more complex than simple random
graphs. In particular, they are commonly described as *scale-free*
networks @barabasi1999emergence: their structural properties remain
invariant across scales, meaning that the same organizational patterns
can be observed regardless of the network size, with no characteristic
degree scale dominating the topology.

In practice, scale-free behavior is most often associated with degree
distributions that follow a *power-law*. While the notions of
scale-free and power-law are not strictly equivalent, the latter
provides a precise mathematical framework to characterize the absence
of a characteristic scale in the degree distribution.

#definition(title: "Power-law network")[
Let $G = (V, E)$ be a graph with $|V| = N$. Let $K$ be the random
variable denoting the degree of a node chosen uniformly at random
from $V$. The network is said to be power-law if
$
P(K = k) ~ k^(-gamma)
$
where $gamma > 1$ is the power-law exponent.
]

A defining characteristic of power-law networks is their heavy-tailed
degree distribution: most nodes have small degree, while a small but
non-negligible fraction --- commonly referred to as *hubs* --- exhibit
very large degree. This structural heterogeneity sharply contrasts
with Erdős–Rényi graphs, whose degree distribution is binomial.
Empirical studies of real-world systems, including peer-to-peer
overlays, communication networks, and social graphs, frequently report
power-law exponents in the range $2 < gamma < 3$ @barabasi1999emergence,
a regime in which the average degree remains finite while the variance
diverges in the limit of large network size.

This structural heterogeneity has direct consequences for information
dissemination. Hubs act as communication shortcuts, significantly
reducing the average path length and facilitating rapid message
exchange. As a consequence, broadcast, gossip, and aggregation
processes may converge faster than in more homogeneous topologies.
Many scale-free networks also exhibit the *ultra-small world* property
@cohen2003scale: while the diameter of classical random graphs
typically scales as $log N$, scale-free networks may display diameters
scaling as $log log N$, further accelerating information spreading.

A classical generative model for scale-free networks is the
Barabási--Albert (BA) model @barabasi1999emergence, which produces
power-law degree distributions through *preferential attachment*: when
a new node joins the network, it connects to existing nodes with
probability proportional to their current degree,
$
Pi(i) = k_i / (sum_j k_j),
$
where $k_i$ is the degree of node $i$. Starting from a small initial
network of $m_0$ nodes and adding one node with $m <= m_0$ edges at
each step, this rich-get-richer mechanism naturally leads to the
emergence of hubs and a power-law degree distribution, reproducing
the structural properties observed in many real-world networks.

#figure(
diagram({
  node((1,0), name: "ServerRoot", radius: 1em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Server1"), "-", stroke: 1pt)
  edge(label("Server2"), "-", stroke: 1pt)
  edge(label("Server3"), "-", stroke: 1pt)
  edge(label("Client6"), "-", stroke: 1pt)

  node((-1,1.5), name: "Server1", radius: 1em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client1"), "-", stroke: 1pt)
  edge(label("Client2"), "-", stroke: 1pt)
  edge(label("Client3"), "-", stroke: 1pt)

  node((0.5,1.5), name: "Server2", radius: 1em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client4"), "-", stroke: 1pt)
  edge(label("Client5"), "-", stroke: 1pt)

  node((2,1.5), name: "Server3", radius: 1em, stroke: 1pt, fill: green.lighten(60%))  
  edge(label("Client7"), "-", stroke: 1pt)
  edge(label("Client8"), "-", stroke: 1pt)
  edge(label("Client9"), "-", stroke: 1pt)

  node((-3,2.8), name: "Client1", radius: 1em, stroke: 1pt, fill: green.lighten(60%))

  node((-2,2.8), name: "Client2", radius: 1em, stroke: 1pt, fill: green.lighten(60%))

  node((-1.2,2.8), name: "Client3", radius: 1em, stroke: 1pt, fill: green.lighten(60%))

  node((-0.5,2.8), name: "Client4", radius: 1em, stroke: 1pt, fill: green.lighten(60%))

  node((0.2,2.8), name: "Client5", radius: 1em, stroke: 1pt, fill: green.lighten(60%))
  
  node((1,2.8), name: "Client6", radius: 1em, stroke: 1pt, fill: green.lighten(60%))

  node((1.8,2.8), name: "Client7", radius: 1em, stroke: 1pt, fill: green.lighten(60%))
  
  node((2.5,2.8), name: "Client8", radius: 1em, stroke: 1pt, fill: green.lighten(60%))

  node((3.5,2.8), name: "Client9", radius: 1em, stroke: 1pt, fill: green.lighten(60%))

}),
  caption: [Example of a scale-free network],
) <fig:scale-free-example>

==== Stochastic block model
While power-law and scale-free models capture degree heterogeneity,
they do not explicitly account for community structure --- the
tendency of nodes to form densely connected groups with sparser
connections between them. Stochastic Block Models (SBM)
@holland1983stochastic address this limitation by providing a
generative framework in which nodes are partitioned into communities
(or blocks), and the probability of a link between two nodes depends
solely on the communities to which they belong. This allows the
generation of networks that appear random globally but exhibit strong
local structure, with explicit control over the number and size of
communities as well as intra- and inter-community connection
probabilities. SBM generalizes the Erdős–Rényi random graph, which
corresponds to the special case of a single block, and is
particularly well suited to model overlays organized around hubs or
clusters of nodes sharing common interests. Because it is
probabilistic, multiple network instances can be generated from the
same parameters, making it a valuable tool for benchmarking community
detection algorithms and studying networks with varying modularity.

#definition(title: "Stochastic Block Model")[
  A Stochastic Block Model (SBM) is a generative model for random graphs with community structure. 
  Consider a graph $G = (V, E)$ with $N$ nodes, and let the nodes be partitioned into $K$ disjoint blocks (or communities) $C_1, C_2, dots, C_K$.
  The probability of an edge between two nodes depends only on the blocks to which they belong.
  
  Formally, let $B in [0,1]^{K times K}$ be a matrix of connection probabilities between blocks, where $B_{"ab"}$ is the probability that a node in block $C_a$ connects to a node in block $C_b$. Then, for each pair of nodes $(i,j)$:
  
  - If node $i in C_a$ and node $j in C_b$, the edge $(i,j)$ exists independently with probability $B_(a b)$:
      $P((i,j) in E) = B_(a b)$.
  
  Special cases include:
  - *Intra-block probabilities*: $B_(a a)$, the probability of connection between nodes within the same community.
  - *Inter-block probabilities*: $B_(a b)$, $a eq.not b$, the probability of connection between nodes of different communities.
  
  SBM generalizes the Erdős–Rényi random graph, which corresponds to the case $K=1$.
] <def:sbm>

The topologies surveyed above --- from deterministic structures such
as meshes, stars, and rings, to probabilistic models such as random
graphs, small-world networks, power-law networks, and stochastic
block models --- provide a rich vocabulary for characterizing the
structural properties of peer-to-peer overlays. Having established
this repertoire, we now turn to the formal modeling of overlay
networks as graphs, and introduce the abstractions that will be used
throughout this manuscript to reason about connectivity, communication,
and protocol execution.

== History and Use cases of Peer to Peer networks <sec:p2p-history>

The client–server architecture is the most common communication model on the Internet. It is a natural fit for protocols such as HTTP, FTP, or SSH, where one central server provides services or data to multiple clients that request them.
The main advantage of client–server architecture lies in its simplicity. The server manages client requests and coordinates their interactions, while users only need to establish a connection to this central point. Security is also easier to enforce, since it mainly involves securing the server.

#grid(
  columns: (1fr, 1fr),
  [#figure(
diagram({
  node((1,0), "Server", name: "Server", radius: 2em, stroke: 1pt, fill: green.lighten(60%))
  edge(label("Client1"), "-", stroke: 1pt)
  edge(label("Client2"), "-", stroke: 1pt)
  edge(label("Client3"), "-", stroke: 1pt)

  node((0,1.5), "Client", name: "Client1", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((1,1.5), "Client", name: "Client2", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))

  node((2,1.5), "Client", name: "Client3", radius: 2em, stroke: 1pt, fill: blue.lighten(60%))  
}),
  caption: [A client-server architecture, with 1 server and 3 clients.],
) <client-server-diagram>],
[#figure(
diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0),"Peer", name: "1", radius: 2em)
edge(label("5"), "-", stroke: 1pt)
edge(label("2"), "-", stroke: 1pt)
node((0.3,1),"Peer", name: "2", radius: 2em)
edge(label("5"), "-", stroke: 1pt)
edge(label("3"), "-", stroke: 1pt)
node((1,1.5),"Peer", name: "3", radius: 2em)
node((1.8,1),"Peer", name: "4", radius: 2em)
edge(label("5"), "-", stroke: 1pt)
node((1.8,0),"Peer", name: "5", radius: 2em)
}),
  caption: [A peer-to-peer architecture.],
) <p2p-diagram>]
)


However, this apparent simplicity comes at a significant cost: the server represents a single point of failure. If it crashes, the entire service becomes unavailable. If it is compromised, all clients are potentially affected. In addition, the computing and networking load is concentrated on the server, while the clients’ capabilities (bandwidth, CPU, storage) often remain underutilized.

To overcome these limitations, peer-to-peer (P2P) architectures emerged as an alternative model. In a P2P system, all nodes (or peers) can act both as clients and servers, directly sharing resources, data, and computation. This decentralization enhances resilience, as there is no single point of failure, and promotes a fairer use of global resources by distributing the workload across participants. P2P systems can also scale naturally, since each new peer contributes additional resources to the network.

Nevertheless, these benefits come at the cost of increased complexity. Moving from a 1–N to an N–N communication model introduces significant challenges in coordination, data consistency, and peer discovery. Security and trust management also become more difficult, as there is no central authority to authenticate or regulate interactions. Moreover, peers are heterogeneous, with varying reliability and performance. As a result, P2P systems must rely on adaptive and fault-tolerant protocols capable of handling a wide range of network conditions and potential attacks.

Although today’s digital services (e.g. GAFAM) are mostly based on centralized architectures, the Internet itself was originally conceived as a decentralized system, as illustrated by the ARPANET network (see @arpanet). While the Internet Protocol (IP) does not form a single decentralized network — but rather a federation of interconnected operator networks — it inherently supports decentralization, as any node can directly reach another by its IP address without relying on a central server to route messages.
Among the first Internet protocols, several exhibited decentralized or hybrid characteristics rather than a purely client–server model. SMTP and NNTP, for instance, rely on direct communication between independent servers — making them peer-to-peer at the inter-server level — while still following a client–server model for end users connecting to their local instance. Similarly, DNS introduced a distributed yet hierarchical naming system, in which authority is delegated across multiple autonomous zones rather than centralized in a single entity. Moreover, long before the Internet, human societies relied on decentralized networks of exchange, such as medieval trade routes #footnote[https://en.wikipedia.org/wiki/Silk_Road] or the Universal Postal Union #footnote[https://en.wikipedia.org/wiki/Treaty_of_Bern]. In that sense, peer-to-peer architectures reflect a natural and recurring pattern of human organization.

// we could even add open source projects like the Linux kernel

#figure(
  image("../../Images/1_ieIdnYcxt4kS71uA1QsFGw_arpanet.webp", width: 100%),
  caption: [ARPANET, a network with a peer to peer architecture.],
) <arpanet>

The idea of decentralization, initially present in the Internet’s underlying protocols, resurfaced more visibly in the late 1990s as peer-to-peer applications began empowering users to exchange data directly with one another.
At that time, the growing demand for large-scale multimedia sharing—combined with limited computing and networking resources (CPU, memory, bandwidth, and storage)—made it difficult for any single server to handle massive numbers of simultaneous downloads. Peer-to-peer networks addressed this limitation by enabling participants to contribute their own resources—especially upload bandwidth—to the system. For example, instead of downloading a 100 MB file from a single server, a user could download small chunks (e.g., 2 MB) from dozens of peers simultaneously, dramatically increasing throughput and scalability.

This concept led to the creation of Napster #footnote[https://en.wikipedia.org/wiki/Napster] in 1999, one of the first large-scale file-sharing systems. Although Napster used a central index server to locate files, the data transfer itself occurred directly between peers, marking a key milestone in the history of P2P networking. Following Napster, other peer-to-peer file-sharing systems emerged, such as Gnutella #footnote[https://en.wikipedia.org/wiki/Gnutella] and BitTorrent #footnote[https://www.bittorrent.com/].
Gnutella is fully decentralized, as it does not rely on any central file index. Starting with version 0.6, it introduced the concept of ultrapeers with the Gia protocol @chawathe2003making — high-capacity nodes that help route queries and files across the network, improving scalability while preserving decentralization.
BitTorrent brought several notable innovations, including the tit-for-tat mechanism, which encourages fairness by balancing uploading and downloading among peers, and the use of the Kademlia Distributed Hash Table (DHT) for decentralized peer discovery @maymounkov2002kademlia — eliminating the need for central trackers or hierarchical nodes such as ultrapeers. Another notable protocol is Tribler #footnote[https://www.tribler.org/] #footnote[I contributed very briefly to the development of Tribler in 2017, https://github.com/Tribler/tribler/issues/3240], which builds upon BitTorrent while introducing several key innovations, including a distributed search engine and an anonymization layer. Uniquely, Tribler is an academic project @pouwelse2008tribler developed at Delft University of Technology (TU Delft) in the Netherlands, aiming to create a fully self-sustaining and censorship-resistant file-sharing network.

During the same period, another use case for decentralized networks emerged: anonymization systems. The Internet Protocol itself does not provide any built-in mechanism for user anonymity or end-to-end encryption. To address this, anonymous overlay networks were developed on top of the Internet, designed to conceal both the content and the origin of communications. These systems typically rely on multi-hop routing and layered encryption, offering a high level of confidentiality at the cost of higher latency and complexity. The most notable examples are Freenet #footnote[https://freenet.org/], I2P #footnote[https://geti2p.net/en/], and Tor #footnote[https://www.torproject.org/]. Although Tor is not entirely peer-to-peer—since a small number of directory authorities coordinate the list of relays—it remains a decentralized system and the most widely used anonymization network, with around 7,000 active nodes worldwide.

The success of these peer-to-peer protocols inspired other use cases for applications that were not fully decentralized but leveraged peer-to-peer technology to improve performance. Examples include Skype #footnote[https://en.wikipedia.org/wiki/Skype], which until 2014 relied on a peer-to-peer overlay network with supernodes for VoIP communications between users, and Streamroot #footnote[https://github.com/streamroot], which used peer-to-peer technology during live football matches to reduce server load by sharing stream data among viewers. At the academic level, researchers have also explored hybrid architectures for online games @buyukkaya2009vorogame, combining central servers with peer-to-peer mechanisms for data distribution and game state consistency.

Finally, we can mention distributed computing projects such as the Great Internet Mersenne Prime Search (GIMPS) #footnote[https://www.mersenne.org/], SETI\@home #footnote[https://setiathome.berkeley.edu/], and Folding\@home #footnote[https://foldingathome.org/]. Although these systems are not peer-to-peer — since a central server distributes computation tasks to clients — they have demonstrated the feasibility and efficiency of large-scale volunteer computing. These early systems paved the way for later research on decentralized and federated computing models.

Interest in peer-to-peer networking peaked around 2004, with a surge of academic research and widespread adoption by end users. At that time, peer-to-peer applications accounted for roughly 60% of global Internet traffic (with BitTorrent alone representing about 35%) @ftc2005p2p.
In subsequent years, the proportion of P2P traffic declined sharply #footnote[https://torrentfreak.com/bittorrent-is-no-longer-the-king-of-upstream-internet-traffic-240315/], as server performance, bandwidth, and storage capacities increased, enabling efficient large-scale content delivery through centralized services such as streaming platforms and cloud-based distribution networks.
Moreover, the association of P2P networks with copyright infringement and piracy—due to their lack of centralized control—discouraged mainstream users and pushed content providers toward centralized architectures.
Nevertheless, BitTorrent remains actively used today for legitimate purposes, such as distributing Linux operating system images #footnote[For instance, the Ubuntu 25.10 desktop ISO image can be obtained via BitTorrent: https://releases.ubuntu.com/25.10/ubuntu-25.10-desktop-amd64.iso.torrent] and large open-source datasets, including machine learning model weights #footnote[For example, the Mixtral model was shared through a torrent link announced in a post on X in December 2023 by the company Mistral: https://x.com/MistralAI/status/1733150512395038967].

There was a resurgence of interest in peer-to-peer technology in the 2010s, following the emergence of Bitcoin @nakamoto2008bitcoin, which introduced the first blockchain network. The key innovation of Bitcoin is that it enables a completely decentralized and secure payment system by combining peer-to-peer networking, cryptographic proofs and a consensus mechanism. Building on this innovation, and on later advances such as Ethereum’s introduction of smart contracts @buterin2013ethereum, it became possible to create decentralized financial applications (DeFi) #footnote[https://en.wikipedia.org/wiki/Decentralized_finance] and to assign ownership of digital assets such as NFTs #footnote[https://en.wikipedia.org/wiki/Non-fungible_token].

Building on the principle of immutability introduced by blockchain systems—where every transaction is permanently recorded and verifiable—new approaches emerged to apply similar ideas to data storage and sharing. One of the most influential of these systems is the InterPlanetary File System (IPFS) #footnote[https://ipfs.tech/]. Inspired by BitTorrent’s peer-to-peer file distribution, IPFS generalizes and extends it by introducing content addressing: every piece of data is identified by the cryptographic hash of its content, ensuring both integrity and permanence. In addition, IPFS structures data using a Merkle Directed Acyclic Graph (Merkle DAG), allowing efficient deduplication and versioning, much like Git but at the scale of a global network.

By combining the guarantees of blockchain immutability, the programmability of smart contracts, and the distributed storage capabilities of IPFS, new forms of decentralized cloud infrastructures have emerged. These systems aim to provide computing and storage services without relying on traditional centralized data centers. Notable examples include Golem #footnote[https://www.golem.network/], which offers a marketplace for distributed computing resources; Sia #footnote[https://sia.tech/], which enables decentralized cloud storage through cryptographically secured contracts; and Filecoin #footnote[https://filecoin.io/], which builds directly on top of IPFS to incentivise data storage and retrieval through a native cryptocurrency. Together, these projects illustrate the ongoing shift towards a decentralized Internet infrastructure, where computation and storage are shared and coordinated through peer-to-peer and blockchain mechanisms rather than controlled by central entities. 

== Machine Learning <sec:appendix_ml>

This appendix introduces the fundamental definitions and concepts of machine
learning that underpin the decentralized learning protocols discussed in the main
body of this thesis. The material presented here is drawn from the foundational
works of Tom Mitchell @learning1997tom and the Deep Learning book
@Goodfellow-et-al-2016. We begin with a formal definition of learning, as
introduced by Tom Mitchell, which serves as the backbone of all subsequent
concepts.

#definition(title: "Machine Learning" )[
A computer program is said to *learn* from experience $E$ with respect
to some class of tasks $T$ and performance measure $P$, if its performance at tasks in
$T$, as measured by $P$, improves with experience $E$.

Formally, we denote:
- $E$: the experience or data that the system uses to learn;
- $T$: the class of tasks the system is intended to perform;
- $P$: the performance measure used to evaluate success on tasks in $T$.
] <def:ml-mitchell>

This definition highlights that learning is the process by which a system improves its ability to perform a task through exposure to data or experience. Building on this notion of improvement through experience, machine learning algorithms can be broadly classified according to the nature of the experience they leverage.
Machine learning algorithms are typically categorized into three main types: 
*supervised learning*, *unsupervised learning*, and *reinforcement learning*. 
Supervised learning involves learning a mapping from input data to known outputs, 
unsupervised learning aims to discover patterns or structure in data without labeled outputs, 
and reinforcement learning focuses on learning optimal decision-making policies through repeated interaction with an environment, guided by a reward signal that evaluates the agent's actions.
In the context of this thesis, our primary focus is on *supervised learning*, 
as it provides the foundation for the federated and decentralized learning approaches. 
// studied in the following chapters.

Supervised learning involves observing several examples of a random vector $x$ and an associated value or vector $y$, and learning to predict $y$ from $x$, usually by estimating the conditional probability $p(y | x)$. All supervised learning algorithms share a common two-phase structure.
During the *training phase*, the algorithm is exposed to labeled data and adjusts its internal parameters to minimize a measure of prediction error.
Once training is complete, the resulting model is deployed during the *inference phase* to make predictions on previously unseen data, without further parameter updates.

#definition(title: "Supervised Learning")[

  Given a dataset of $N$ examples:
  $
    D = {(x_1, y_1), (x_2, y_2), dots, (x_N, y_N)},
  $
  the goal of a supervised learning algorithm is to find a function $f_theta (x)$ parameterized 
  by $theta$ that approximates the mapping from $x$ to $y$.
] <def:supervised-ml>

#figure(
  diagram(
    spacing: (3.5cm, 2.2cm),
    node-stroke: 1.2pt,
    node-corner-radius: 4pt,

    // ── Nodes ────────────────────────────────────────────────
    node((0,0), [Training Data \ $bold(X) = {bold(x)_i}_(i=1)^n$],
         fill: rgb("#dbeafe"), stroke: rgb("#1d4ed8"), name: <data>),

    node((2,0), [Labels \ $bold(y) = {y_i}_(i=1)^n$],
         fill: rgb("#dbeafe"), stroke: rgb("#1d4ed8"), name: <labels>),

    node((1,1), [Model $f_theta$],
         fill: rgb("#fef9c3"), stroke: rgb("#ca8a04"), name: <model>),

    node((1,2), [Predictions \ $hat(bold(y)) = f_theta (bold(X))$],
         fill: rgb("#dbeafe"), stroke: rgb("#1d4ed8"), name: <pred>),

    node((0,3), [Loss Function \ $cal(L)(hat(bold(y)), bold(y))$],
         fill: rgb("#fce7f3"), stroke: rgb("#be185d"), name: <loss>),

    node((2,3), [Optimizer \ $theta arrow.l theta - eta nabla_theta cal(L)$],
         fill: rgb("#dcfce7"), stroke: rgb("#15803d"), name: <opt>),

    // ── Edges — forward pass ─────────────────────────────────
    edge(<data>,   <model>, "->", stroke: 1.5pt, label: [features],     label-side: left),
    edge(<labels>, <model>, "->", stroke: 1.5pt),
    edge(<model>,  <pred>,  "->", stroke: 1.5pt, label: [forward pass],  label-side: left),
    edge(<pred>,   <loss>,  "->", stroke: 1.5pt),
    // edge(<labels>, <loss>,  "-->", label: [ground truth], label-side: right,
    //      stroke: (dash: "dashed")),
    edge(<loss>,   <opt>,   "->", stroke: 1.5pt),

    // ── Edge — backward pass ─────────────────────────────────
    edge(<opt>, <model>, "->",
         label: [backward pass],
         label-side: right,
         stroke: (paint: rgb("#15803d"), thickness: 1.5pt),
         bend: -40deg),
  ),
  caption: [The supervised learning training loop.]
) <fig-supervised-learning>

#figure(
  diagram(
    spacing: (3.5cm, 2.2cm),
    node-stroke: 1.2pt,
    node-corner-radius: 4pt,

    // ── Nodes ────────────────────────────────────────────────
    node((0,0), [Unseen Data \ $bold(x)_"new" in RR^d$],
         fill: rgb("#dbeafe"), stroke: rgb("#1d4ed8"), name: <input>),

    node((1,0), [Trained Model \ $f_(theta^*)$],
         fill: rgb("#fef9c3"), stroke: rgb("#ca8a04"), name: <model>),

    node((2,0), [Prediction \ $hat(y) = f_(theta^*)(bold(x)_"new")$],
         fill: rgb("#dcfce7"), stroke: rgb("#15803d"), name: <output>),

    // ── Edges ─────────────────────────────────────────────────
    edge(<input>, <model>,  "->", stroke: 1.5pt),
    edge(<model>, <output>, "->", stroke: 1.5pt),
  ),
  caption: [The supervised learning inference phase.]
) <fig-supervised-inference>

In practice, this mapping is typically found by minimizing a loss function 
$L(f_theta (x), y)$ over the dataset $D$, which measures the discrepancy 
between the predicted outputs and the true labels, reflecting how well the 
model performs on a given example or dataset.

  // In supervised learning, a *loss function* (or cost function) 
  // quantifies the difference between the predicted output of a model 
  // $f_theta(x)$ and the true output $y$. It provides a measure of 
  // how well the model performs on a given example or dataset.

#definition(title: "Loss Function")[
  A loss function $L$ takes a predicted output $f_theta (x)$ and a true 
  label $y$ as inputs, and returns a non-negative real value measuring 
  the discrepancy between the two:
  $
    L(f_theta (x), y) in RR_(>= 0),
  $
  where smaller values indicate better predictions. Given a dataset 
  $D = {(x_1, y_1), dots, (x_N, y_N)}$, the overall loss is computed 
  as the average over all examples:
  $
    L(theta) = 1/N sum_(i=1)^N L(f_theta (x_i), y_i).
  $
] <def:loss-function>

Beyond the loss function, which measures the discrepancy between
predicted and true labels during training, it is useful to introduce
a complementary performance metric that is more directly interpretable
in classification settings. *Accuracy* measures the proportion of
correctly classified examples, and provides an intuitive assessment
of model quality on held-out data.

#definition(title: "Accuracy")[
Let $D^("test") = {(x_i, y_i)}_(i=1)^M$ be a test dataset and let
$hat(y)_i = f_(theta^*)(x_i)$ be the predicted label for input $x_i$.
The *accuracy* of a model $f_(theta^*)$ is defined as:
$
"Accuracy" = 1/M sum_(i=1)^M bb(1){hat(y)_i = y_i},
$
where $bb(1){dot}$ is the indicator function, equal to $1$ if the
prediction is correct and $0$ otherwise.
] <def:accuracy>

#remark[
Accuracy and loss measure complementary aspects of model performance.
The loss quantifies the magnitude of prediction errors and drives
optimization, while accuracy provides a threshold-based measure of
correctness that is directly interpretable. In classification tasks,
a model with low loss will typically achieve high accuracy, but the
two metrics need not be perfectly aligned, particularly in the
presence of class imbalance.
]

Common examples of loss functions include the *Mean Squared Error (MSE)*, 
$L(f_theta (x), y) = ||f_theta (x) - y||^2$, widely used in regression tasks, 
and the *Cross-Entropy Loss*, $L(f_theta (x), y) = -sum_i y_i log f_theta (x)_i$, 
commonly used in classification tasks.

These two loss functions naturally reflect the two main types of prediction 
tasks encountered in supervised learning: *regression* and *classification*. 
Regression problems aim to predict a continuous value, while classification 
problems aim to assign an input to one of a discrete set of classes. 
In this thesis, we focus on *classification problems*, specifically 
*binary classification* (two possible classes) and *multinomial classification* 
(more than two classes).


Binary classification refers to the supervised learning task where each input $x$ is associated with a label $y$ 
that can take only two possible values, typically denoted $y in {0,1}$. 
The goal is to learn a function $f_theta (x)$ that outputs a predicted label $hat(y)$ that approximates the true label $y$. 

#definition(title: "Binary Classification")[
  Given a dataset $D = {(x_i, y_i)}_(i=1)^N$ where $x_i in RR^d$ and 
  $y_i in {0, 1}$, binary classification aims to find a function 
  $f_theta : RR^d -> [0,1]$ that estimates the probability 
  $p(y = 1 | x)$, by solving:
  $
    theta^* = "argmin"_theta 1/N sum_(i=1)^N L(f_theta (x_i), y_i),
  $
  where $L$ is a loss function measuring the discrepancy between 
  predicted and true labels.
] <def:binary-classification>

Multinomial classification generalizes binary classification to the case where each label $y$ 
can take one of $K > 2$ possible classes: $y in {1,2,...,K}$. 
The goal is to learn a function $f_theta (x)$ that outputs either a class label $hat(y)$ or a probability distribution over the $K$ classes.


#definition(title: "Multinomial Classification")[
  Given a dataset $D = {(x_i, y_i)}_(i=1)^N$ where $x_i in RR^d$ and 
  $y_i in {1, dots, K}$, multinomial classification aims to find a function 
  $f_theta : RR^d -> [0, 1]^K$ that estimates the probability distribution 
  $p(y = k | x)$ over all $K$ classes, by solving:
  $
    theta^* = "argmin"_theta 1/N sum_(i=1)^N L(f_theta (x_i), y_i),
  $
  where $L$ is a loss function measuring the discrepancy between 
  predicted and true labels.
] <def:multinomial-classification>

In supervised learning, once a loss function $L(f_theta(x), y)$ has been defined, the next step is to find a way to minimize this loss. 
Minimizing the loss corresponds to improving the model's performance on the task, that is, making its predictions closer to the true labels. 
This is achieved using an *optimization algorithm*. While many optimization algorithms exist, 
the most widely used in practice is *gradient descent* @cauchy1847methode and its variants, due to its simplicity and efficiency in handling large datasets.

Gradient descent iteratively updates the parameters of the model in the direction of the negative gradient of the loss function. This procedure requires that the loss function be *differentiable*, so that the gradient exists, and ideally have a *continuous gradient* to ensure stable updates. If the function is *convex*, then gradient descent is guaranteed to converge to the global minimum. However, in most machine learning applications, the loss function is *non-convex*, meaning that gradient descent may only reach a local minimum. Despite the lack of theoretical guarantees for reaching the global minimum, in practice gradient descent and its variants often yield very good results.

#definition(title: "Gradient Descent")[
Gradient descent is an iterative optimization algorithm used to minimize a differentiable function, such as a loss function in machine learning. 
The idea is to update the model parameters $theta$ in the direction opposite to the gradient of the loss function with respect to these parameters:

$
theta_(t+1) = theta_t - eta * nabla_theta L(theta_t),
$

where:
- $theta_t$ are the parameters at iteration $t$,
- $eta > 0$ is the learning rate controlling the step size,
- $nabla_theta L(theta_t)$ is the gradient of the loss function with respect to $theta$ evaluated at iteration $t$.

By repeatedly applying this update rule, the algorithm moves towards a local minimum of the loss function, thereby improving the model's performance.

The algorithm is typically stopped when one of the following conditions is met:
1. The absolute difference between successive loss values is smaller than a predefined threshold:
   $|L(theta_(t+1)) - L(theta_t)| < epsilon, "with" epsilon > 0$,
   in which case we consider that the algorithm has *converged*.
2. A maximum number of iterations $T_(max)$ is reached. In this case, the algorithm stops and the loss value at the final iteration is used.

] <def:gradient-descent>

#figure(
  canvas({
    import draw: *

    // ── Axes ────────────────────────────────────────────────
    set-style(stroke: (paint: gray.darken(20%), thickness: 0.8pt))
    line((-0.3, 0), (10.3, 0))
    line((0, -0.3), (0, 5.8))
    line((10.1, -0.15), (10.3, 0), (10.1, 0.15))
    line((-0.15, 5.6), (0, 5.8), (0.15, 5.6))
    content((10.6, 0),  text(size: 9pt)[$theta$])
    content((0.4, 5.9), text(size: 9pt)[$cal(L)(theta)$])

    // ── Loss curve : U-shape ─────────────────────────────────
    let f(x) = 0.45 * (x - 5) * (x - 5) + 0.4

    let pts = range(0, 101).map(i => {
      let x = i * 9.5 / 100.0 + 0.3
      (x, f(x))
    })
    set-style(stroke: (paint: blue.darken(10%), thickness: 2pt))
    hobby(..pts)

    // ── Steps on the curve (oscillating, converging) ─────────
    let steps = (
      (1.2,  f(1.2)),
      (8.2,  f(8.2)),
      (2.5,  f(2.5)),
      (7.2,  f(7.2)),
      (3.8,  f(3.8)),
      (6.2,  f(6.2)),
      (5.0,  f(5.0)),
    )

    let c = green.darken(20%)

// ── Arrows between consecutive points ────────────────────
    let r = 0.1  // offset = radius + small margin
    for i in range(steps.len() - 1) {
      let (x0, y0) = steps.at(i)
      let (x1, y1) = steps.at(i + 1)
      // Compute direction vector and normalize
      let dx = x1 - x0
      let dy = y1 - y0
      let dist = calc.sqrt(dx * dx + dy * dy)
      let nx = dx / dist
      let ny = dy / dist
      // Shorten both ends by r
      let ax0 = x0 + nx * r
      let ay0 = y0 + ny * r
      let ax1 = x1 - nx * r
      let ay1 = y1 - ny * r
      set-style(stroke: (paint: gray.darken(30%), thickness: 1.2pt), fill: none)
      line((ax0, ay0), (ax1, ay1), mark: (end: ">", size: 0.22))
    }
    
    // ── Dots on curve ────────────────────────────────────────
    for i in range(steps.len()) {
      let (x0, y0) = steps.at(i)
      set-style(stroke: (paint: c.darken(10%), thickness: 1.2pt), fill: c)
      circle((x0, y0), radius: 0.18)
    }

    // ── Labels ───────────────────────────────────────────────
    // Random init
    let (x0, y0) = steps.at(0)
    content((x0 - 1, y0 + 0.3), text(size: 8pt)[Random \ initialization])

    // Minimum
    let (xm, ym) = steps.last()
    content((xm + 1.2, ym - 0.2), text(size: 8pt)[$theta^* ("minimum")$])

  }),
  caption: [Gradient descent on a convex loss surface $cal(L)(theta)$: starting from a random initialization, the parameters $theta$ are iteratively updated in the direction opposite to the gradient until convergence to the minimum $theta^*$.]
) <fig-gradient-descent>

In its basic form, gradient descent is applied to the entire dataset at once, meaning that the gradient is computed over all available samples before each parameter update.

In practice, the available dataset is divided into a *training set* and a *test set*. The model's parameters $theta$ are updated via gradient descent to minimize the loss function $L(theta)$ on the training set, while the test set is held out entirely and used only to evaluate the model's performance on unseen data, providing an estimate of its generalization ability.

This separation is essential to detect *overfitting*, a phenomenon that occurs when the model memorizes the training data rather than capturing general patterns. A key indicator of overfitting is a divergence between the two losses: while the training loss continues to decrease, the test loss starts to increase. By monitoring both losses throughout training, one can assess whether the model generalizes well to unseen data or merely fits the training set.

#remark[In the sense of @def:ml-mitchell, the task $T$ corresponds to binary or multinomial classification, the experience $E$ to the labeled dataset $D = {(x_i, y_i)}_(i=1)^N$ from which the model learns, and the performance measure $P$ to the loss function $cal(L)(theta)$ that quantifies how well the model performs on this task.]

=== Datasets <sec:datasets>

Previously, we introduced the notion of dataset in the supervised learning 
setting, defining it abstractly as a collection of labeled examples drawn from an unknown 
joint distribution. To ground this abstraction, we now present two concrete datasets drawn 
from the machine learning literature, covering binary and multiclass classification 
respectively. These examples illustrate what such a dataset looks like in practice.

==== Spambase

The Spambase dataset @spambase_94 is a binary classification benchmark originally compiled by
Hewlett-Packard Labs and made publicly available through the UCI Machine Learning Repository. It
consists of 4,601 email messages, each represented as a feature vector of 57 continuous attributes,
grouped into three categories. The first 48 attributes, of type `word_freq_WORD`, measure the
percentage of words in the email that match a given keyword, computed as $100 times (text("count of "
"WORD")) \/ text("total words")$. The following 6 attributes, of type `char_freq_CHAR`, measure the
percentage of characters in the email matching a given special character, computed analogously over
the full character sequence. The remaining 3 attributes capture the structure of capital letter
sequences: `capital_run_length_average` is the average length of uninterrupted sequences of capital
letters, `capital_run_length_longest` is the length of the longest such sequence, and
`capital_run_length_total` is the total number of capital letters in the email. The task is to
classify each email as either spam ($y = 1$) or legitimate ($y = 0$), making this a standard binary
classification problem. The dataset is moderately imbalanced, with approximately 39% of instances
labeled as spam. Its relatively small size and tabular structure make it well suited for evaluating
lightweight models such as support vector machines and shallow neural networks in a distributed
setting.

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, left, left),
    table.header([*Attribute*], [*Type*], [*Description*]),
    [`word_freq_meeting`], [Continuous $[0,100]$], [% of words matching "meeting"],
    [`word_freq_original`], [Continuous $[0,100]$], [% of words matching "original"],
    [`word_freq_project`], [Continuous $[0,100]$], [% of words matching "project"],
    [#sym.dots.v], [#sym.dots.v], [#sym.dots.v],
    [`char_freq_;`], [Continuous $[0,100]$], [% of characters matching ";"],
    [`char_freq_(`], [Continuous $[0,100]$], [% of characters matching "("],
    [#sym.dots.v], [#sym.dots.v], [#sym.dots.v],
    [`capital_run_length_average`], [Continuous $[1, +infinity[$], [Average length of capital letter runs],
    [`capital_run_length_longest`], [Integer $[1, +infinity[$],   [Length of longest capital letter run],
    [`capital_run_length_total`],   [Integer $[1, +infinity[$],   [Total number of capital letters],
    [*Class*], [Binary], [Spam ($y=1$) or legitimate ($y=0$)],
  ),
  caption: [Selected attributes of the Spambase dataset. The full feature set comprises 48 word frequency attributes, 6 character frequency attributes, and 3 capital run-length attributes.],
) <tab:spambase-features>

==== MNIST

The MNIST dataset @lecun2010mnist is a multiclass classification benchmark consisting of 70,000
grayscale images of handwritten digits, partitioned into 60\,000 training samples and 10,000 test
samples. Each image is of size $28 times 28$ pixels, yielding a 784-dimensional input vector after
flattening. The task is to assign each image to one of ten classes corresponding to the digits 0
through 9. MNIST is one of the most widely used benchmarks in the machine learning literature,
serving as a standard testbed for evaluating classification models ranging from logistic regression
to deep convolutional networks. It provides a more demanding evaluation
setting than Spambase, due to its higher input dimensionality and the multiclass nature of the
learning task.

#figure(image("../../Images/Dataset/MNIST_dataset_example.png"),  caption: [MNIST Dataset.],
) <fig:mnist>

=== Machine Learning Models
Having introduced the key components of supervised learning, we now have all the ingredients to formally define a supervised learning model as a mathematical tool for solving the supervised learning problem.

// #definition(title: "Machine Learning Model")[
//   A machine learning model is defined by:
//   - A *hypothesis class* $cal(F) = {f_theta : cal(X) -> cal(Y) | theta in Theta}$, that is, a parametrized family of functions mapping inputs $x in cal(X)$ to outputs $y in cal(Y)$,
//   - A *parameter space* $Theta$, which is the set of all admissible values for the parameters $theta$,
//   - A *loss function* $L : cal(Y) times cal(Y) -> RR_(>=0)$, chosen to reflect the assumptions of the model and the nature of the task.

//   Training the model consists in finding the optimal parameters:
//   $
//     theta^* = "argmin"_(theta in Theta) 1/N sum_(i=1)^N L(f_theta (x_i), y_i).
//   $
// ] <def:ml-model>

#definition(title: "Machine Learning Model")[
  A supervised learning model is defined by:
  - A *hypothesis class* $cal(F) = {f_theta : cal(X) -> cal(Y) | theta in Theta}$,
    that is, a parametrized family of functions mapping inputs $x in cal(X)$ to 
    outputs $y in cal(Y)$ (see @def:supervised-ml),
  - A *parameter space* $Theta$, which is the set of all admissible values for 
    the parameters $theta$,
  - A *loss function* $L : cal(Y) times cal(Y) -> RR_(>=0)$, chosen to reflect 
    the assumptions of the model and the nature of the task (see @def:loss-function).

  Training the model consists in finding the optimal parameters $theta^*$ via 
  gradient descent (@def:gradient-descent):
  $
    theta^* = op("argmin", limits: #true)_(theta in Theta) cal(L)(theta) 
    = op("argmin", limits: #true)_(theta in Theta) 1/N sum_(i=1)^N L(f_theta (x_i), y_i).
  $
] <def:ml-model>

In supervised learning, there is no single universal model: infinitely many 
hypothesis classes $cal(F)$ can in principle be considered, each encoding 
different assumptions about the structure of the mapping $f_theta$. The choice 
of model is therefore guided by the nature of the task, the structure of the 
data, and practical constraints such as computational efficiency and 
interpretability. In what follows, we introduce three widely used supervised 
learning models that serve as building blocks for the federated and 
decentralized learning frameworks studied in this thesis: *linear regression*, 
suited to regression problems; *logistic regression*, suited to binary 
classification problems; and *multilayer perceptrons (MLPs)*, suited to tasks 
where the relationship between inputs and outputs is too complex to be captured 
by a linear model. These three models also represent increasing levels of 
complexity and expressiveness in the hypothesis class $cal(F)$.

// In what follows, we introduce several machine learning models that are widely used in practice and that serve as building blocks for the federated and decentralized learning frameworks studied in this thesis. Specifically, we cover *linear regression*, *logistic regression*, and *multilayer perceptrons (MLPs)*, each representing a different level of complexity and expressiveness in the hypothesis class $cal(F)$.

==== Linear Regression

Linear regression is one of the simplest and most widely used models in machine learning. 
It is a type of supervised learning model used to predict a continuous output variable $y$ 
from one or more input features $x$. The model assumes a linear relationship between the input 
variables and the output, making it easy to interpret and efficient to train. 

Linear regression is often used as a baseline model before trying more complex algorithms, 
and it also serves as a foundation for understanding more advanced models such as generalized 
linear models and neural networks.

#figure(
  canvas({
    import draw: *

    let points = (
      (0.5, 1.8),
      (1.0, 0.6),
      (1.5, 2.8),
      (2.0, 1.2),
      (2.5, 3.9),
      (3.0, 1.8),
      (3.5, 4.8),
      (4.0, 2.5),
      (4.5, 5.6),
      (5.0, 3.1),
      (5.5, 6.2),
      (6.0, 4.3),
      (6.5, 7.5),
      (7.0, 5.2),
      (7.5, 8.6),
      (8.0, 6.1),
      (8.5, 9.0),
      (9.0, 7.3),
    )

    let a = 0.84
    let b = 0.55
    let reg(x) = a * x + b

    // ── Axes ────────────────────────────────────────────────
    set-style(stroke: (paint: luma(80), thickness: 0.8pt))
    line((-0.2, 0), (10.2, 0))
    line((0, -0.2), (0, 9.5))
    line((10.0, -0.15), (10.2, 0), (10.0, 0.15))
    line((-0.15, 9.3), (0, 9.5), (0.15, 9.3))
    content((10.5, 0),  text(size: 9pt)[$x$])
    content((0.35, 9.7), text(size: 9pt)[$y$])

    // ── Residuals ───────────────────────────────────────────
    for (px, py) in points {
      let ry = reg(px)
      let col = if py > ry { red.lighten(20%) } else { blue.lighten(20%) }
      set-style(stroke: (paint: col, thickness: 1.0pt, dash: "dashed"), fill: none)
      line((px, py), (px, ry))
    }

    // ── Regression line ──────────────────────────────────────
    set-style(stroke: (paint: green.darken(30%), thickness: 2pt, dash: "solid"), fill: none)
    line((0.0, reg(0.0)), (9.5, reg(9.5)))

    // ── Data points ─────────────────────────────────────────
    for (px, py) in points {
      set-style(stroke: (paint: luma(30), thickness: 0.8pt), fill: white)
      circle((px, py), radius: 0.15)
      set-style(stroke: none, fill: luma(30))
      circle((px, py), radius: 0.07)
    }

    // ── Equation box ─────────────────────────────────────────
    content((7.2, 1.8),
      box(
        fill: white,
        stroke: green.darken(30%) + 0.7pt,
        radius: 3pt,
        inset: 5pt,
        text(size: 9pt, fill: green.darken(40%))[
          $hat(y) = 0.84 x + 0.55$
        ]
      )
    )

    // ── Legend ───────────────────────────────────────────────
    let lx = 0.6
    let ly = 9.0
    set-style(stroke: (paint: red.lighten(20%), thickness: 1.0pt, dash: "dashed"), fill: none)
    line((lx, ly), (lx + 0.5, ly))
    content((lx + 1.6, ly), text(size: 7.5pt)[positive residual])
    set-style(stroke: (paint: blue.lighten(20%), thickness: 1.0pt, dash: "dashed"), fill: none)
    line((lx, ly - 0.55), (lx + 0.5, ly - 0.55))
    content((lx + 1.6, ly - 0.55), text(size: 7.5pt)[negative residual])
  }),
  caption: [Linear regression: the green line minimizes the sum of squared residuals between predicted and observed values.]
) <fig-linear-regression>


#definition(title: "Linear Regression")[
A linear regression model predicts a continuous output $y in RR$ from an input 
feature vector $x in RR^d$ using an affine function:

$
hat(y) = f_theta (x) = w^T x + b,
$

where:
- $w in RR^d$ is the weight vector,
- $b in RR$ is the bias term,
- $theta = (w, b)$ denotes the set of model parameters.

Given a training dataset 
$
D = {(x_1, y_1), ..., (x_N, y_N)},
$
the parameters $theta$ are learned by minimizing the mean squared error (MSE):

$
L(theta) = 1/N sum_(n=1)^N (y_n - f_theta (x_n))^2.
$
] <def:linear-regression>

==== Logistic Regression
Logistic regression is a supervised learning model used for classification tasks, 
rather than predicting continuous values. It is particularly suited for binary 
classification problems, where the goal is to predict whether an instance belongs 
to one of two classes. Unlike linear regression, logistic regression outputs 
a probability value between 0 and 1, which can then be thresholded to assign a class label.

The model is based on a linear combination of input features, transformed by 
the logistic (sigmoid) function, allowing it to model the probability of class membership.

#figure(
  canvas({
    import draw: *

    // ── Data points — class 0 (blue) ─────────────────────────
    let class0 = (
      (1.0, 1.2),
      (1.5, 3.1),
      (2.0, 1.8),
      (2.3, 4.2),
      (2.8, 2.5),
      (3.0, 5.0),
      (3.2, 1.1),
      (3.6, 3.8),
      (1.8, 5.5),
      (2.5, 0.8),
      (6.5, 3.1),
    )

    // ── Data points — class 1 (red) ──────────────────────────
    let class1 = (
      (6.0, 4.8),
      (6.8, 4.2),
      (7.0, 5.5),
      (7.6, 4.1),
      (8.0, 2.8),
      (8.3, 5.8),
      (8.8, 1.8),
    )

    // ── Decision boundary: x = 4.8 (vertical line) ───────────
    // boundary line: y = -1.5x + 12  (separates the two clouds)
    let boundary-x1 = 0.5
    let boundary-x2 = 9.5
    let bound(x) = -1.2 * x + 11.5

    // ── Axes ────────────────────────────────────────────────
    set-style(stroke: (paint: luma(80), thickness: 0.8pt))
    line((-0.2, 0), (10.2, 0))
    line((0, -0.2), (0, 9.5))
    line((10.0, -0.15), (10.2, 0), (10.0, 0.15))
    line((-0.15, 9.3), (0, 9.5), (0.15, 9.3))
    content((10.5, 0),   text(size: 9pt)[$x_1$])
    content((0.35, 9.7), text(size: 9pt)[$x_2$])

    // ── Decision boundary ────────────────────────────────────
    set-style(stroke: (paint: green.darken(30%), thickness: 2pt, dash: "solid"), fill: none)
    line((boundary-x1, bound(boundary-x1)), (boundary-x2, bound(boundary-x2)))

    // ── Class 0 points ───────────────────────────────────────
    for (px, py) in class0 {
      set-style(stroke: (paint: blue.darken(20%), thickness: 1.2pt), fill: blue.lighten(40%))
      circle((px, py), radius: 0.18)
    }

    // ── Class 1 points ───────────────────────────────────────
    for (px, py) in class1 {
      set-style(stroke: (paint: red.darken(20%), thickness: 1.2pt), fill: red.lighten(40%))
      circle((px, py), radius: 0.18)
    }

    // ── Decision boundary label ───────────────────────────────
    content((5.5, 7.0),
      box(
        fill: white,
        stroke: green.darken(30%) + 0.7pt,
        radius: 3pt,
        inset: 4pt,
        text(size: 8.5pt, fill: green.darken(40%))[decision boundary]
      )
    )

    // ── Legend ───────────────────────────────────────────────
    let lx = 4.4
    let ly = 9.0
    set-style(stroke: (paint: blue.darken(20%), thickness: 1.2pt), fill: blue.lighten(40%))
    circle((lx + 0.2, ly), radius: 0.18)
    content((lx + 1.4, ly), text(size: 7.5pt)[Class 0  $(y=0)$])

    set-style(stroke: (paint: red.darken(20%), thickness: 1.2pt), fill: red.lighten(40%))
    circle((lx + 0.2, ly - 0.65), radius: 0.18)
    content((lx + 1.4, ly - 0.65), text(size: 7.5pt)[Class 1  $(y=1)$])
  }),
  caption: [Logistic regression: a linear decision boundary separates two classes in the feature space $(x_1, x_2)$.]
) <fig-logistic-regression>

#definition(title: "Logistic Regression")[
Logistic regression is a supervised learning model for binary classification. 
It estimates the probability that an input $x in RR^d$ belongs to the positive class:
$
p(y = 1 | x; theta) = sigma(w^T x + b),
$
where:
- $sigma(z) = 1 / (1 + exp(-z))$ is the sigmoid function,
- $theta = (w, b)$ are the model parameters,
- $hat(y)_n = sigma(w^T x_n + b)$ denotes the predicted probability for the $n$-th sample.

The parameters are learned by minimizing the binary cross-entropy loss:
$
L(theta) = - 1/N sum_(n=1)^N [y_n log(hat(y)_n) + (1 - y_n) log(1 - hat(y)_n)].
$
] <def:logistic-regression>

==== Multinomial Logistic Regression

While binary logistic regression predicts the probability of an instance 
belonging to one of two classes, multinomial logistic regression generalizes 
this approach to problems with $K > 2$ classes. In this case, the model outputs 
a probability distribution over all possible classes for each input instance. 
The probabilities are obtained using the softmax function, which ensures they 
sum to 1.

Multinomial logistic regression is widely used for multi-class classification 
tasks such as handwritten digit recognition, text categorization, or image labeling.

#definition(title: "Multinomial Logistic Regression")[
For a classification problem with $K$ classes, multinomial logistic regression 
models the conditional class probabilities using the softmax function.
Let:
- $x in RR^d$ be an input vector,
- $W in RR^(K times d)$ be the weight matrix,
- $b in RR^K$ be the bias vector.
The probability of class $k$ is given by:
$
p(y = k | x; theta) =
(exp((W x + b)_k))/(
sum_(j=1)^K exp((W x + b)_j)
),
$
where:
- $(W x + b)_k$ denotes the $k$-th component of the score vector,
- $theta = (W, b)$ are the model parameters.

The model is trained by minimizing the categorical cross-entropy loss:
$
L(theta) =
- 1/N sum_(n=1)^N sum_(k=1)^K y_(n k) log(p(y_n = k | x_n; theta)),
$
where $y_(n k) in {0, 1}$ indicates whether the $n$-th example belongs to class $k$, following a one-hot encoding of the true labels.
] <def:multinomial-logistic>

#remark[For $K = 2$, this formulation reduces to binary logistic regression.]

==== Neural Networks and Multi-Layer Perceptrons

The models introduced so far rely on a linear mapping of the form $W^T x + b$ applied to the input features. 
While these models are simple, efficient, and well understood, their expressive power is fundamentally limited: they can only represent linear decision boundaries in the input space.

#figure(
  diagram(
    spacing: (20mm, 8mm),
    node-stroke: 0.8pt,
    node-fill: white,

    // --- Input layer ---
    node((0, 0), $x_1$, shape: circle, name: <i1>),
    node((0, 1), $x_2$, shape: circle, name: <i2>),
    node((0, 2), $x_3$, shape: circle, name: <i3>),

    // --- Hidden layer 1 ---
    node((1, 0), $h_1^((1))$, shape: circle, name: <h11>),
    node((1, 1), $h_2^((1))$, shape: circle, name: <h12>),
    node((1, 2), $h_3^((1))$, shape: circle, name: <h13>),
    node((1, 3), $h_4^((1))$, shape: circle, name: <h14>),

    // --- Hidden layer 2 ---
    node((2, 0.5), $h_1^((2))$, shape: circle, name: <h21>),
    node((2, 1.5), $h_2^((2))$, shape: circle, name: <h22>),
    node((2, 2.5), $h_3^((2))$, shape: circle, name: <h23>),

    // --- Output layer ---
    node((3, 0.75), $f_1$, shape: circle, name: <o1>),
    node((3, 1.75), $f_2$, shape: circle, name: <o2>),

    // --- Connections: input → hidden 1 ---
    for i in (<i1>, <i2>, <i3>) {
      for j in (<h11>, <h12>, <h13>, <h14>) {
        edge(i, j, stroke: gray.lighten(30%))
      }
    },

    // --- Connections: hidden 1 → hidden 2 ---
    for i in (<h11>, <h12>, <h13>, <h14>) {
      for j in (<h21>, <h22>, <h23>) {
        edge(i, j, stroke: gray.lighten(30%))
      }
    },

    // --- Connections: hidden 2 → output ---
    for i in (<h21>, <h22>, <h23>) {
      for j in (<o1>, <o2>) {
        edge(i, j, stroke: gray.lighten(30%))
      }
    },

    // --- Layer labels ---
    node((0, 3.3),  text(size: 8pt)[Input],          stroke: none, fill: none),
    node((1, 4.3),  text(size: 8pt)[Hidden Layer 1], stroke: none, fill: none),
    node((2, 3.8),  text(size: 8pt)[Hidden Layer 2], stroke: none, fill: none),
    node((3, 2.75), text(size: 8pt)[Output],          stroke: none, fill: none),
  ),
  caption: [A fully connected neural network with two hidden layers ($L = 3$).],
)

Artificial neural networks extend these models by composing multiple linear transformations with nonlinear activation functions. 
The simplest neural network, known as the *single-layer perceptron*, consists of a single linear unit followed by a nonlinear activation function. 
Although this model already allows for binary classification, it remains limited to linearly separable problems.

To overcome this limitation, neural networks introduce *hidden layers*, leading to the so-called *Multi-Layer Perceptrons (MLPs)*. 
An MLP is a feedforward neural network composed of several layers of perceptrons, where each layer applies an affine transformation followed by a nonlinear activation. 
By stacking multiple such layers, MLPs are able to learn complex, nonlinear mappings between inputs and outputs.

This layered structure allows neural networks to progressively transform the input representation into higher-level features, making them powerful models for a wide range of tasks, including classification, regression, and function approximation.

#definition(title: "Multi-Layer Perceptron (MLP)")[
A Multi-Layer Perceptron (MLP) is a feedforward neural network composed of a finite sequence of layers, where each layer applies an affine transformation followed by a nonlinear activation function.
Let $x in RR^(d_0)$ be an input vector. An MLP with $L$ layers defines a sequence of hidden representations $(h^(1), h^(2), dots, h^(L))$ as follows:
$
h^(0) = x,
$
$
h^(l) = phi(W^(l) h^(l-1) + b^(l)), quad l = 1, dots, L-1,
$
where:
- $W^(l) in RR^(d_l times d_(l-1))$ is the weight matrix of layer $l$,
- $b^(l) in RR^(d_l)$ is the bias vector of layer $l$,
- $phi: RR -> RR$ is a nonlinear activation function applied element-wise (e.g. ReLU, sigmoid),
- $h^(l) in RR^(d_l)$ is the output of layer $l$.

The output layer applies a task-specific transformation:
$
f_theta (x) = phi^(L)(W^(L) h^(L-1) + b^(L)),
$
where $phi^(L)$ is chosen according to the task: the identity function for regression, the sigmoid for binary classification, or the softmax for multinomial classification.

The full set of trainable parameters is $theta = {W^(1), b^(1), dots, W^(L), b^(L)}$.
] <def:mlp>

== Learning Paradigms <sec:learning_paradigms>

Machine learning models can be trained under very different assumptions regarding data availability, computational resources, and the organization of the learning process. These assumptions define what is called a *learning paradigm*, which specifies how data is accessed, how computation is distributed, and how the model is updated during training.

=== Centralized Learning
Centralized learning refers to a learning paradigm in which all training data are 
collected and stored at a single location, and the learning process is performed 
using the complete dataset.

#definition(title: "Centralized Learning")[
Centralized learning is a learning paradigm in which a single learner has full access to a dataset $D = {(x_1, y_1), dots, (x_N, y_N)}$ and trains a model $f_theta$ by solving:
$
theta^* = "argmin"_(theta in Theta) 1/N sum_(i=1)^N L(f_theta (x_i), y_i),
$
where $L$ is a loss function chosen according to the task, and $Theta$ is the parameter space.

This setting assumes that all data are available to a single computing entity throughout training, which enables exact gradient computation over the full dataset at each iteration of gradient descent:
$
theta_(t+1) = theta_t - eta nabla_theta 1/N sum_(i=1)^N L(f_theta (x_i), y_i).
$
] <def:centralized-learning>

In practice, training is often carried out using mini-batches for computational 
efficiency, particularly to leverage GPU or accelerator architectures. However, 
this does not alter the fundamental assumption of centralized learning, which 
requires that all data be available to the learner, either in advance or on demand.

As a consequence, centralized learning typically relies on a single machine or a 
tightly coupled computing cluster with sufficient computational and memory 
resources to process the full dataset. 

While computationally straightforward, this paradigm imposes strong assumptions: all data must be collected, stored, and processed at a single location, raising fundamental challenges in terms of scalability, data privacy, and data locality.

=== Online Learning

#figure(
  diagram(
    spacing: (22mm, 12mm),
    node-stroke: 0.8pt,
    node-fill: white,

    // --- Data stream ---
    node((0, 0), [Sample $t-1$\ $(x_(t-1), y_(t-1))$],
      shape: rect, name: <prev>, stroke: gray.lighten(50%)),
    node((0, 1), [*Sample $t$*\ $(x_t, y_t)$],
      shape: rect, name: <cur>),
    node((0, 2), [Sample $t+1$\ $(x_(t+1), y_(t+1))$],
      shape: rect, name: <next>, stroke: gray.lighten(50%)),

    // --- Model ---
    node((1, 1), [*Model*\ $f(x ; theta_t)$],
      shape: rect, name: <model>),

    // --- Loss ---
    node((2, 1), [*Loss*\ $ell(f(x_t ; theta_t), y_t)$],
      shape: rect, name: <loss>),

    // --- Update ---
    node((1, 2.5), [$theta_(t+1) = theta_t - eta nabla ell$],
      shape: rect, name: <update>),

    // --- Edges ---
    edge(<cur>,    <model>,  marks: "->", label: "(1) forward"),
    edge(<model>,  <loss>,   marks: "->", label: "(2) loss"),
    edge(<loss>,   <update>, marks: "->", label: "(3) backward"),
    edge(<update>, <model>,  marks: "->", label: "(4) update θ"),
  ),
  caption: [
    Online learning: the model receives one sample $(x_t, y_t)$ at a time,
    computes the loss, and updates its parameters $theta$ before processing
    the next sample.
  ],
)
Centralized learning, as introduced in @def:centralized-learning, assumes that the entire dataset $D$ is available before training begins. However, in many real-world settings, data is generated sequentially over time, possibly in large volumes or under resource constraints, making this assumption impractical.

Online learning @shalev2025online addresses this limitation by allowing a model to be updated 
incrementally as new data becomes available. Instead of learning from a fixed 
dataset, the model continuously adapts to a stream of observations, enabling 
learning in dynamic, non-stationary, or distributed environments. This paradigm 
is particularly relevant in decentralized systems, which are central to the context of this thesis.

#definition(title: "Online Learning")[
Online learning is a learning paradigm in which model parameters are updated 
sequentially as data arrives, rather than being trained once on a fixed dataset.

At each time step $t$, the learning algorithm receives an input $x_t$, produces 
a prediction $hat(y)_t$, and then observes the true label $y_t$. Based on this 
feedback, the model parameters $theta_t$ are updated using an online optimization 
rule, typically of the form:

$
theta_(t+1) = theta_t - eta_t * nabla_theta L(f_(theta_t)(x_t), y_t)
$

where:
- $theta_t$ denotes the model parameters at time $t$,
- $eta_t > 0$ is a possibly time-dependent learning rate,
- $L$ is a loss function measuring the prediction error.

The objective of online learning is to minimize the cumulative loss over time, 
often expressed as:

$
sum_(t=1)^T L(f_(theta_t)(x_t), y_t)
$

while adapting efficiently to new data and potential changes in the data 
distribution.
] <def:online-learning>

=== Ensemble Learning

#figure(
  diagram(
    spacing: (18mm, 10mm),
    node-stroke: 0.8pt,
    node-fill: white,

    // --- Input ---
    node((0, 2), [*Input* $x$], shape: rect, name: <input>),

    // --- Weak learners ---
    node((1, 0), [Weak learner $f_1$\ $hat(y)_1 = f_1(x)$],
      shape: rect, name: <f1>),
    node((1, 1), [Weak learner $f_2$\ $hat(y)_2 = f_2(x)$],
      shape: rect, name: <f2>),
    node((1, 2), [Weak learner $f_3$\ $hat(y)_3 = f_3(x)$],
      shape: rect, name: <f3>),
    node((1, 3), [Weak learner $f_4$\ $hat(y)_4 = f_4(x)$],
      shape: rect, name: <f4>),
    node((1, 4), [Weak learner $f_5$\ $hat(y)_5 = f_5(x)$],
      shape: rect, name: <f5>),

    // --- Aggregation ---
    node((2, 2),
      [*Aggregation*\ $sum_(m=1)^M alpha_m f_m(x)$],
      shape: rect, name: <agg>),

    // --- Strong learner ---
    node((3, 2),
      [*Strong learner*\ $f_"ens"(x)$],
      shape: rect, name: <strong>),

    // --- Edges: input → weak learners ---
    edge(<input>, <f1>, marks: "->"),
    edge(<input>, <f2>, marks: "->"),
    edge(<input>, <f3>, marks: "->"),
    edge(<input>, <f4>, marks: "->"),
    edge(<input>, <f5>, marks: "->"),

    // --- Edges: weak learners → aggregation ---
    edge(<f1>, <agg>, marks: "->"),
    edge(<f2>, <agg>, marks: "->"),
    edge(<f3>, <agg>, marks: "->"),
    edge(<f4>, <agg>, marks: "->"),
    edge(<f5>, <agg>, marks: "->"),

    // --- Edge: aggregation → strong learner ---
    edge(<agg>, <strong>, marks: "->"),
  ),
  caption: [
    Ensemble learning: an input $x$ is fed to $M$ weak learners
    $f_1, dots, f_M$. An aggregation step combines their predictions
    via a weighted sum $sum_(m=1)^M alpha_m f_m(x)$
  ],
)
Beyond individual learning models, an important paradigm in machine learning 
consists in combining multiple models in order to improve predictive performance. 
This approach, known as ensemble learning @dietterich2000ensemble, is based on the observation that 
multiple imperfect or weak models can collectively yield a more accurate and 
robust predictor than any single model alone.

Ensemble methods are particularly effective at reducing variance, improving 
generalization, and increasing robustness to noise or model misspecification. 
They play a central role in modern machine learning and are especially relevant 
in distributed and decentralized settings, where multiple models may be trained 
independently and later combined.

#definition(title: "Ensemble Learning")[
Ensemble learning is a learning paradigm in which a set of models 
${f_1, f_2, dots, f_M}$, often referred to as weak learners, are combined to form 
a single predictor $f_"ens"$ with improved performance.
] <def:ensemble-learning>

A common form of ensemble model is a weighted aggregation of individual predictors:

$
f_"ens"(x) = sum_(m=1)^M alpha_m f_m(x),
$

where:
- $f_m$ denotes the prediction of model $m$,
- $alpha_m in R$ is a weight associated with model $m$.

#remark[
  When all weights are equal, i.e. $alpha_m = 1 slash M$ for all $m$,
  the weighted aggregation ensemble model reduces to a simple average:
  $
  f_"ens"(x) = 1/M sum_(m=1)^M f_m(x).
  $
  In classification settings, this corresponds to a majority vote:
  each weak learner $f_m$ casts a vote for a class, and $f_"ens"(x)$
  returns the class receiving the most votes.
]

#remark[
  The weights $alpha_m$ in the ensemble formulation should not be
  confused with the weight matrices $W^(l)$ introduced in
  @def:mlp. Here, $alpha_m in RR$ is a scalar coefficient
  assigned to each model $f_m$, reflecting its relative contribution
  to the ensemble prediction. It bears no relation to the learnable
  parameters internal to any individual model.
]

For linear models, such as linear or logistic regression, this aggregation is 
equivalent to a single model of the same class, with parameters equal to the 
weighted sum of the individual parameters. In this case, the aggregation is 
order-independent and preserves linearity.

For nonlinear models, such as neural networks, the aggregation generally does not 
admit an equivalent representation within the same hypothesis class. The 
interaction between nonlinear decision functions may lead to more complex 
behaviors, and the resulting ensemble cannot, in general, be reduced to a single 
model.

Despite the lack of general theoretical guarantees for nonlinear ensembles, 
ensemble learning has been shown empirically to significantly improve predictive 
performance in a wide range of applications.

=== Distributed Learning
While ensemble learning focuses on combining multiple models to improve predictive 
performance, it typically assumes that models are trained independently and that 
their aggregation is performed in a centralized manner. More generally, most 
classical machine learning algorithms rely on a centralized learning paradigm, in 
which all data and computation are collected and processed at a single location.

However, the increasing scale of data, computational requirements, and the 
emergence of decentralized systems have motivated the development of distributed 
learning approaches. In distributed learning, data, computation, or decision-making 
are spread across multiple nodes, which collaboratively contribute to the training 
process while operating under communication, synchronization, and resource 
constraints.

==== Data parallelism

As deep neural networks have grown in size and complexity, training them on a
single device has become increasingly time-consuming. Modern architectures may
require days or even weeks of computation on a single processor, which makes
reducing training time a central concern in distributed learning @dean2012large.
A natural response to this challenge is to exploit the parallel computing
capabilities of modern hardware: GPUs expose hundreds to thousands of cores that
can perform floating-point operations simultaneously, making them well-suited for
the kind of matrix computations that dominate neural network training.

Data parallelism is one of the most common strategies for distributed training and
leverages this hardware parallelism by distributing the training data across
multiple workers. The training dataset is partitioned into disjoint subsets, each
assigned to a different worker, while all workers maintain a replica of the same
model. Neural networks are particularly amenable to this form of parallelism:
because the gradient of the loss with respect to the parameters decomposes
additively over individual samples, the full gradient can be approximated by
aggregating local gradients computed independently on each worker. This property
makes distributed SGD a natural fit for data parallelism @dean2012large.

During training, each worker computes gradients on its local data partition using
mini-batch SGD. These gradients are then aggregated across workers --- typically
by averaging --- to produce a global gradient estimate, which is used to update
the shared model parameters. This process is repeated iteratively until a
convergence criterion is met.

Data parallelism preserves the centralized learning objective, as the model is
effectively trained on the full dataset, while distributing the computational
load. In its synchronous form, it ensures that each parameter update is consistent
with the global gradient. However, this approach still relies on frequent
synchronization and communication between workers, and assumes a coordinated
training process under a common optimization objective.

#figure(
  diagram(
    spacing: (20mm, 8mm),
    node-stroke: 0.8pt,
    node-fill: white,

    // --- Parameter server ---
    node((1, 0),
      [*Parameter server*\ global model $theta$],
      shape: rect, name: <server>),

    // --- GPU 1 ---
    node((0, 2),
      [*GPU 1*\ model replica $theta$\ mini-batch $cal(B)_1$],
      shape: rect, name: <gpu1>),

    // --- GPU 2 ---
    node((1, 2),
      [*GPU 2*\ model replica $theta$\ mini-batch $cal(B)_2$],
      shape: rect, name: <gpu2>),

    // --- GPU 3 ---
    node((2, 2),
      [*GPU 3*\ model replica $theta$\ mini-batch $cal(B)_3$],
      shape: rect, name: <gpu3>),

    // --- Broadcast: server → GPUs ---
    edge(<server>, <gpu1>,
      marks: "->",
      label: $theta$,
      bend: -15deg),
    edge(<server>, <gpu2>,
      marks: "->",
      label: $theta$),
    edge(<server>, <gpu3>,
      marks: "->",
      label: $theta$,
      bend: 15deg),

    // --- Gradient push: GPUs → server ---
    edge(<gpu1>, <server>,
      marks: "->",
      label: $nabla ell_1$,
      label-side: left,
      bend: -15deg),
    edge(<gpu2>, <server>,
      marks: "->",
      label: $nabla ell_2$),
    edge(<gpu3>, <server>,
      marks: "->",
      label-side: right,
      label: $nabla ell_3$,
      bend: 15deg),
  ),
  caption: [
    Data parallelism: each GPU holds a replica of
    the model and processes a distinct mini-batch.
  ],
)

==== Model parallelism

As neural networks have grown to billions of parameters, storing and training
them on a single device has become infeasible: the model simply does not fit
within the memory of a single CPU or GPU @dean2012large. Model parallelism
addresses this constraint by partitioning the model itself across multiple
devices, rather than replicating it as in data parallelism.

The most straightforward form of model parallelism is *pipeline parallelism*,
in which the layers of the network are divided into sequential stages, each
assigned to a dedicated device. Neural networks are well suited to this form
of parallelism: because computation flows naturally from one layer to the next,
the model can be split along layer boundaries without altering the learning
objective. During the forward pass, each device computes its stage and
transmits the resulting activations to the next; during the backward pass,
gradients flow in the reverse direction. A practical limitation of this
approach is the *pipeline bubble*: when a device is waiting for the output of
the preceding stage, it remains idle, reducing overall hardware utilization.

#figure(
  diagram(
    spacing: (18mm, 12mm),
    node-stroke: 0.8pt,
    node-fill: white,

    // --- Input ---
    node((1, 1), [*Input* $x$], shape: rect, name: <input>),

    // --- GPU 1 ---
    node((1, 0),
      [*GPU 1*\ layers $1 dots l_1$],
      shape: rect, name: <gpu1>),

    // --- GPU 2 ---
    node((2, 0),
      [*GPU 2*\ layers $l_1+1 dots l_2$],
      shape: rect, name: <gpu2>),

    // --- GPU 3 ---
    node((3, 0),
      [*GPU 3*\ layers $l_2+1 dots L$],
      shape: rect, name: <gpu3>),

    // --- Output ---
    node((4, 1), [*Output*\ $f_theta (x)$], shape: rect, name: <output>),

    // --- Loss ---
    node((3, 1), [*Loss*\ $ell(f_theta (x), y)$], shape: rect, name: <loss>),

    // --- Forward pass ---
    edge(<input>, <gpu1>,
      marks: "->",
      label: [forward],
      label-side: left),
    edge(<gpu1>, <gpu2>,
      marks: "->",
      label: $h^((l_1))$,
      label-side: left),
    edge(<gpu2>, <gpu3>,
      marks: "->",
      label: $h^((l_2))$,
      label-side: left),
    edge(<gpu3>, <output>,
      marks: "->",
      label: [forward],
      label-side: left),
    edge(<output>, <loss>,
      marks: "->"),

    // --- Backward pass ---
    edge(<loss>, <gpu3>,
      marks: "->",
      label: $nabla ell$,
      label-side: left,
      bend: 30deg),
    edge(<gpu3>, <gpu2>,
      marks: "->",
      label: $delta^((l_2))$,
      label-side: right,
      bend: 30deg),
    edge(<gpu2>, <gpu1>,
      marks: "->",
      label: $delta^((l_1))$,
      label-side: right,
      bend: 30deg),
  ),
  caption: [
    Pipeline parallelism: the layers of the network are partitioned into
    three stages, each assigned to a dedicated GPU.
  ],
)


A more advanced form is *tensor parallelism*, in which individual operations
--- such as matrix multiplications within a single layer --- are themselves
distributed across devices @shoeybi2019megatron. This approach can be more
efficient than pipeline parallelism, as it reduces inter-stage dependencies
and better utilizes available compute. However, it requires the model
architecture to be explicitly designed or adapted for distributed tensor
operations, making it harder to implement in practice and not universally
applicable.

At the hardware level, Tensor Processing Units (TPUs) embody a related
philosophy: they are specialized accelerators built around a systolic array
architecture optimized for large-scale matrix and tensor computations, and are
designed to efficiently distribute such operations across a large number of
processing elements. In this sense, tensor parallelism and TPU-based
computation share the same foundational idea of exploiting the structure of
tensor operations to achieve scalable parallelism.

While model parallelism enables the training of models that would be
infeasible on a single device, it typically incurs higher communication
overhead than data parallelism and is more sensitive to latency. In practice,
large-scale systems often combine model parallelism and data parallelism to
balance memory constraints, computational efficiency, and communication costs @dean2012large.

#figure(
  diagram(
    spacing: (18mm, 12mm),
    node-stroke: 0.8pt,
    node-fill: white,

    // --- Input ---
    node((0.3, 1), [*Input*\ $h^((l-1))$], shape: rect, name: <input>),

    // --- GPU 1 ---
    node((1, 0),
      [*GPU 1*\ $W_1^((l)) h^((l-1))$\ shard 1],
      shape: rect, name: <gpu1>),

    // --- GPU 2 ---
    node((1, 1),
      [*GPU 2*\ $W_2^((l)) h^((l-1))$\ shard 2],
      shape: rect, name: <gpu2>),

    // --- GPU 3 ---
    node((1, 2),
      [*GPU 3*\ $W_3^((l)) h^((l-1))$\ shard 3],
      shape: rect, name: <gpu3>),

    // --- All-reduce ---
    node((1.8, 1),
      [Concatenate shards],
      shape: rect, name: <allreduce>),

    // --- Output ---
    node((2.8, 1),
      [*Output*\ $h^((l)) = phi(W^((l)) h^((l-1)) + b^((l)))$],
      shape: rect, name: <output>),

    // --- Broadcast input to all GPUs ---
    edge(<input>, <gpu1>, marks: "->"),
    edge(<input>, <gpu2>, marks: "->"),
    edge(<input>, <gpu3>, marks: "->"),

    // --- Partial results to all-reduce ---
    edge(<gpu1>, <allreduce>, marks: "->"),
    edge(<gpu2>, <allreduce>, marks: "->"),
    edge(<gpu3>, <allreduce>, marks: "->"),

    // --- Output ---
    edge(<allreduce>, <output>, marks: "->"),
  ),
  caption: [
    Tensor parallelism: the weight matrix $W^((l))$ of a single layer is
    partitioned into shards, each stored
    and computed on a dedicated GPU.
  ],
)
==== Multi-agent reinforcement learning

Multi-Agent Reinforcement Learning (MARL) extends the reinforcement learning
framework to settings involving multiple agents that learn and act simultaneously
within a shared environment @albrecht2024multi. Unlike supervised learning, which
is driven by labeled datasets and a fixed optimization objective, MARL relies on
interaction, exploration, and reward signals: each agent aims to learn a policy
that maximizes its expected cumulative reward, while the dynamics of the
environment are jointly shaped by the actions of all agents.

Agents in MARL may be cooperative, competitive, or operate in mixed settings,
depending on whether their reward structures are aligned or opposed
@albrecht2024multi. In most formulations, agents observe either the same global
state or partial views of that state, and must act without full knowledge of the
other agents' policies or intentions.

#figure(
  diagram(
    spacing: (20mm, 14mm),
    node-stroke: 0.8pt,
    node-fill: white,

    // --- Environment ---
    node((1, 0),
      [*Environment*\ shared state $s_t$],
      shape: rect, name: <env>),

    // --- Agents ---
    node((0, 2),
      [*Agent 1*\ policy $pi_1$],
      shape: rect, name: <a1>),
    node((1, 2),
      [*Agent 2*\ policy $pi_2$],
      shape: rect, name: <a2>),
    node((2, 2),
      [*Agent 3*\ policy $pi_3$],
      shape: rect, name: <a3>),

    // --- Observations: environment → agents ---
    edge(<env>, <a1>,
      marks: "<->"),
    edge(<env>, <a2>,
      marks: "<->"),
    edge(<env>, <a3>,
      marks: "<->"),
  ),
  caption: [
    Multi-agent reinforcement learning: three agents interact simultaneously
    within a shared environment.
  ],
)

This thesis focuses on supervised learning and its distributed variants; MARL
therefore falls outside its primary scope. Nevertheless, it is relevant to
mention here because it shares structural similarities with decentralized
learning: in both paradigms, multiple autonomous learners operate locally,
without centralized coordination, and their individual behaviors collectively
determine the outcome of the learning process. The key distinction is that MARL
agents optimize reward signals through interaction with an environment, whereas
decentralized learning nodes optimize a supervised loss over local datasets.

==== Transfer learning and fine-tuning

Transfer learning refers to a learning paradigm in which knowledge acquired
from one task or domain is reused to improve learning performance on a
different, but related, task or domain @pan2009survey. A central motivation
is the scarcity of labeled data: when a target task does not have sufficient
training examples, leveraging representations learned on a larger source
dataset can substantially reduce training cost and improve generalization.

In a typical transfer learning setup, a model is first pretrained on a large
source dataset to solve a source task, allowing it to acquire general-purpose
representations. The pretrained model is then reused for a target task, which
may involve a smaller, noisier, or differently distributed dataset. The source
and target tasks may differ in label spaces or objectives, but are assumed to
share some underlying structure @pan2009survey. A special case of this
setting is domain adaptation, in which the task remains the same but the
distribution of the data shifts between source and target.

This paradigm has become dominant in modern deep learning: large neural
networks pretrained on massive datasets --- such as language models or vision
transformers --- are routinely adapted to downstream tasks, often with limited
additional data.

Fine-tuning is a specific instantiation of transfer learning in which the
pretrained model is further trained on the target dataset by continuing the
optimization process, typically with a smaller learning rate. Depending on
the application, fine-tuning may involve updating all model parameters or
only a subset of them, such as the final layers of the network.

#figure(
  diagram(
    spacing: (22mm, 10mm),
    node-stroke: 0.8pt,
    node-fill: white,

    // --- Source dataset ---
    node((0.4, 0),
      [*Source dataset*\ $cal(D)_S$ (large, generic)],
      shape: rect, name: <ds>),

    // --- Pretraining ---
    node((1.2, 0),
      [*Pretraining*\ source task $cal(T)_S$],
      shape: rect, name: <pretrain>),

    // --- Pretrained model ---
    node((2, 0),
      [*Pretrained model*\ $f_(theta_S)$\ general representations],
      shape: rect, name: <pretrained>),

    // --- Target dataset ---
    node((0.4, 1.3),
      [*Target dataset*\ $cal(D)_T$ (small, specific)],
      shape: rect, name: <dt>),

    // --- Fine-tuning ---
    node((2, 1.3),
      [*Fine-tuning*\ target task $cal(T)_T$\ $cal(T)_T approx cal(T)_S$],
      shape: rect, name: <finetune>),

    // --- Fine-tuned model ---
    node((2.7, 1.3),
      [*Fine-tuned model*\ $f_(theta_T)$\ adapted representations],
      shape: rect, name: <finetuned>),

    // --- Source pipeline ---
    edge(<ds>, <pretrain>, marks: "->"),
    edge(<pretrain>, <pretrained>, marks: "->"),

    // --- Transfer ---
    edge(<pretrained>, <finetune>,
      marks: "->",
      label: [transfer $theta_S$],
      label-side: right),

    // --- Target pipeline ---
    edge(<dt>, <finetune>, marks: "->"),
    edge(<finetune>, <finetuned>, marks: "->"),
  ),
  caption: [
    Transfer learning: a model $f_(theta_S)$ is first pretrained on a large
    source dataset $cal(D)_S$ for a source task $cal(T)_S$. Its parameters
    $theta_S$ are then transferred to a fine-tuning stage on a smaller target
    dataset $cal(D)_T$, yielding an adapted model $f_(theta_T)$ suited to the
    target task $cal(T)_T$. Transfer is effective when $cal(T)_S$ and
    $cal(T)_T$ share underlying structure.
  ],
)

While transfer learning and fine-tuning are not distributed learning
techniques per se, they are often complementary to federated and decentralized
learning systems. A common pattern, known as personalized federated learning, is to train a
global model in a federated manner and subsequently fine-tune it locally on
each node using its private data, thereby adapting the shared representations
to each node's local data distribution @fallah2020personalized.

// #set heading(numbering: none)  // Heading numbering
// #set heading(numbering: "A1")
== Simulators <sec:simulators>
// #counter(heading).update(1)

// #set heading(numbering: "A.1", supplement: [Appendix])  // Defines Appendix numbering

Federated and decentralized learning protocols are inherently difficult to
evaluate analytically: their behavior depends on the dynamic interplay between
network topology, asynchronous message passing, heterogeneous data
distributions, and fault injection — conditions that resist closed-form
characterization and demand empirical investigation at scale. Conducting such
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
researcher to reproduce the experimental conditions of our work from scratch:
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

// ==== Overview <sec:peersim-overview>

PeerSim is open-source, developed
at the University of Bologna, and designed specifically for large-scale
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