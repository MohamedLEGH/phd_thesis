#import "@preview/fletcher:0.5.8" as fletcher: node, edge

#import "@preview/lovelace:0.3.0": *
#import "@preview/touying:0.6.1": *
#import themes.simple: *

#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#show: simple-theme.with(
  aspect-ratio: "16-9",
  footer: [],
)

#let my-lovelace-defaults = (
  line-gap: 0.4em
)

#let pseudocode = pseudocode.with(..my-lovelace-defaults)
#let pseudocode-list = pseudocode-list.with(..my-lovelace-defaults)

// cetz and fletcher bindings for touying
// #let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#title-slide[
  = Resilient and Efficient Decentralized Learning
  #v(2em)

  *Mohamed Amine Legheraba*
  
  Supervisors: Maria Potop-Butucaru, Sebastien Tixeuil
  
  Sorbonne University, LIP6, NPA
  // #footnote[Sorbonne University] <uni> #h(1em)

  24 September 2025
]

= Context

== Federated Learning @mcmahan2017communication

#slide[
  #set align(horizon)
  #set align(center)
  #image("federated_learning.png", height: 60%) #footnote(link("https://en.wikipedia.org/wiki/Federated_learning"))
  ]

== Gossip Learning @ormandi2013gossip

#slide[
  #set align(horizon)
  #set align(center)
#fletcher-diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
node((0,0),"1", name: "1", radius: 1em)
edge(label("5"), "-")
edge(label("2"), "-")
node((0.3,1),"2", name: "2", radius: 1em)
edge(label("5"), "-")
edge(label("5"), stroke: 1pt + blue, "<-|", bend: 25deg, label: "peer to peer model aggregation", label-size: 7pt, label-side: right, label-sep: 0.4em, label-angle: right, "dashed")
edge(label("3"), "-")
node((1,1.5),"3", name: "3", radius: 1em)
node((1.8,1),"4", name: "4", radius: 1em)
edge(label("5"), "-")
node((1.8,0),"5", name: "5", radius: 1em)
})][
  #set align(center)

#pseudocode-list(
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
]
  // #image("gossip_algorithm.png", height: 75%, width: 130%)
  ]

== Decentralized peer sampling @stavrou2002lightweight

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 16pt)

  #pseudocode-list(booktabs: true, title: [PROOFS Algorithm (active thread)])[
    - initial peer list: *cache*
    - cache size: *c*
    - shuffle length: *l*
    - node address: *p*
    + *loop*
      + wait($Delta$)
      + subset $arrow.l$ selectRandomSubset(cache, l)
      + q $arrow.l$ selectRandom(subset)
      + subset.remove(q)
      + subset.add(p)
      + send(q, subset)
      + $"subset"_q$ $arrow.l$ receive(q)
      + $"subset"_q$.remove(p)
      + $"subset"_q$.removeAll(cache)
      + cache $arrow.l$ $"subset"_q$ 
  ]
][#set align(center)
  #set text(20pt)
#fletcher-diagram({
node((0,0.5), "7", stroke: 1pt, name: "7", radius: 0.5em)
edge("<|-")
node((0.6,0.5), "1", stroke: 1pt, name: "1", radius: 0.5em, fill: blue.lighten(60%))
edge(label("4"), "-|>")
edge(label("2"), "-|>")
edge(label("3"), "-|>")
node((1.4,-0.1), "2", stroke: 1pt, name: "2", radius: 0.5em)
node((0.6,1.2), "3", stroke: 1pt, name: "3", radius: 0.5em)
node((1.2,0.5), "4", stroke: 1pt, name: "4", radius: 0.5em, fill: green.lighten(60%))
edge(label("3"), "-|>")
edge(label("8"), "-|>")
edge(label("5"), "-|>")
edge(label("6"), "-|>")
node((2,-0.1), "5", stroke: 1pt, name: "5", radius: 0.5em)
node((2,1.2), "6", stroke: 1pt, name: "6", radius: 0.5em)
node((1.2,1.2), "8", stroke: 1pt, name: "8", radius: 0.5em)
})
#v(0.2em)
#fletcher-diagram({
node((0,0.5), "7", stroke: 1pt, name: "7", radius: 0.5em)
edge("<|-")
node((0.6,0.5), "1", stroke: 1pt, name: "1", radius: 0.5em, fill: blue.lighten(60%))
edge(label("5"), "-|>")
edge(label("8"), "-|>")
edge(label("6"), "-|>")
node((1.4,-0.1), "2", stroke: 1pt, name: "2", radius: 0.5em)
node((0.6,1.2), "3", stroke: 1pt, name: "3", radius: 0.5em)
node((1.2,0.5), "4", stroke: 1pt, name: "4", radius: 0.5em, fill: green.lighten(60%))
edge(label("1"), "-|>")
edge(label("3"), "-|>")
edge(label("2"), "-|>")
node((2,-0.1), "5", stroke: 1pt, name: "5", radius: 0.5em)
node((2,1.2), "6", stroke: 1pt, name: "6", radius: 0.5em)
node((1.2,1.2), "8", stroke: 1pt, name: "8", radius: 0.5em)
})
#v(0.2em)
#set text(size: 12pt)
Before and after a shuffling operation. Node 1 sends addresses {itself, 2, 3} to node 4. Node 4 sends back {5,6,
8}.
]


= Elevator & HEAL protocols

== Hub-based topology & Hub sampling @legheraba2024elevator
#slide[
#set text(size: 15pt)
- The objective is to obtains an overlay network with *h* defined hubs, with *h* a parameter of the algorithm, and each hub is connected to all the nodes in the networks. The application running on top will be able to take advantage of this overlay to speed up message transmission in the network.

- *Preferential Attachment*: Drawing from the concept pioneered by Barabási and Albert @barabasi2002evolution, preferential attachment dictates that new connections in the network are established preferentially with nodes possessing a higher number of existing connections. 
// This mechanism enables the organic emergence of hubs within the network, with selected nodes naturally assuming central roles based on their connectivity without any explicit distinction other than their number of incoming links.

- *Random Attachment*: Inspired by gossip-based peer sampling algorithms (@stavrou2002lightweight @jelasity2007gossip), random attachment ensures that nodes maintain connections with a representative and diverse subset of the network. 
// This strategy promotes network robustness by preventing excessive clustering and dependency on specific nodes (hubs). When existing hubs disappear (e.g., due to failures or departure), other nodes within the network are opportunistically elevated to hub status, ensuring continuity and adaptability of the network topology over time.
]

// == Elevator's Algorithm
// #slide[
//   #set align(horizon)
//   #set align(center)
//   #set text(size: 15pt)

//   #pseudocode-list(booktabs: true, title: [Elevator Algorithm (active thread)])[
//     - initial peer list: *cache*
//     - cache size: *c*
//     - desired number of hubs: *h*
//     - initial backward list: *backward_peers* (empty)
//     + *loop*
//       + wait($Delta$)
//       + frequency_map $arrow.l$ ${}$
//       + *for* peer in *cache* do
//         + peer_cache $arrow.l$ send(CACHE_REQUEST, peer)
//         + frequency_map $arrow.l$ frequency_map $union$ peer_cache
//       + preferred $arrow.l$ frequency_map.sort().select(*c*)
//       + preferred_backward $arrow.l$ ${}$
//       + *for* peer in *preferred* do
//         + peer_backward_peers $arrow.l$ send(BACKWARD_REQUEST, peer)
//         + preferred_backward $arrow.l$ preferred_backward $union$ peer_backward_peers
//       + cache $arrow.l$ ${}$
//       + cache $arrow.l$ selectRandom(preferred, h) $+$ selectRandom(peer_backward_peers, $c-h$)
//       ]
// ]

== Elevator's Algorithm
#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 13pt)

  #pseudocode-list(booktabs: true, title: [Elevator Algorithm (active thread)])[
    - initial peer list: *cache*
    - cache size: *c*
    - desired number of hubs: *h*
    - initial backward list: *backward_peers* (empty)
    + *loop*
      + wait($Delta$)
      + frequency_map $arrow.l$ ${}$
      + *for* peer in *cache* do
        + peer_cache $arrow.l$ send(CACHE_REQUEST, peer)
        + frequency_map $arrow.l$ frequency_map $union$ peer_cache
      + preferred $arrow.l$ frequency_map.sort().select(*h*)
      + preferred_backward $arrow.l$ ${}$
      + *for* peer in *preferred* do
        + peer_backward_peer $arrow.l$ send(BACKWARD_REQUEST, peer)
        + preferred_backward.*add*(peer_backward_peer)
      + cache $arrow.l$ ${}$
      + cache $arrow.l$ preferred $union$ preferred_backward
      + backward_peers $arrow.l$ ${}$
      ]
][
  #set align(horizon)
  #set align(center)
  #set text(size: 20pt)

  #pseudocode-list(booktabs: true, title: [Elevator Algorithm (background thread)])[
   + *loop*
      + request, peer $arrow.l$ receive()
      + if request == CACHE_REQUEST then
        + send(cache, peer)
        + backward_peers.add(peer)
      + if request == BACKWARD_REQUEST then
        + send(randomValue(backward_peers), peer)
      ]
]


== Example of topology generated

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 15pt)

#grid(
  columns: (1fr, 1fr),
fletcher-diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
    // Définition des nœuds
    node((0.00,0.00), "0", name: "0", radius: 0.5em, fill: blue.lighten(60%))
    node((1.00,0.00), "1", name: "1", radius: 0.5em, fill: blue.lighten(60%))
    node((-1.35,0.86), "2", name: "2", radius: 0.5em)
    node((1.22,-0.89), "3", name: "3", radius: 0.5em)
    node((-1.47,-0.38), "4", name: "4", radius: 0.5em)
    node((0.35,-0.60), "5", name: "5", radius: 0.5em)
    node((1.67,-1.23), "6", name: "6", radius: 0.5em)
    node((-0.85,1.54), "7", name: "7", radius: 0.5em)
    node((2.96,-1.37), "8", name: "8", radius: 0.5em)
    node((-0.49,0.66), "9", name: "9", radius: 0.5em)
    node((1.14,0.73), "10", name: "10", radius: 0.5em)
    node((-0.11,-0.71), "11", name: "11", radius: 0.5em)

    // Connexions (edges)
    edge(label("0"), label("1"), "-|>")
    edge(label("1"), label("0"), "-|>")
    edge(label("2"), label("0"), "-|>")
    edge(label("2"), label("1"), "-|>")
    edge(label("2"), label("4"), "-|>")
    edge(label("2"), label("3"), "-|>")
    edge(label("3"), label("0"), "-|>")
    edge(label("3"), label("1"), "-|>")
    edge(label("3"), label("7"), "-|>")
    edge(label("3"), label("6"), "-|>")
    edge(label("4"), label("0"), "-|>")
    edge(label("4"), label("1"), "-|>")
    edge(label("4"), label("6"), "-|>")
    edge(label("4"), label("5"), "-|>")
    edge(label("5"), label("0"), "-|>")
    edge(label("5"), label("1"), "-|>")
    edge(label("5"), label("3"), "-|>")
    edge(label("5"), label("11"), "-|>")
    edge(label("6"), label("0"), "-|>")
    edge(label("6"), label("1"), "-|>")
    edge(label("6"), label("9"), "-|>")
    edge(label("6"), label("2"), "-|>")
    edge(label("7"), label("0"), "-|>")
    edge(label("7"), label("1"), "-|>")
    edge(label("7"), label("2"), "-|>")
    edge(label("7"), label("3"), "-|>")
    edge(label("8"), label("0"), "-|>")
    edge(label("8"), label("1"), "-|>")
    edge(label("8"), label("5"), "-|>")
    edge(label("8"), label("11"), "-|>")
    edge(label("9"), label("0"), "-|>")
    edge(label("9"), label("1"), "-|>")
    edge(label("9"), label("11"), "-|>")
    edge(label("9"), label("2"), "-|>")
    edge(label("10"), label("0"), "-|>")
    edge(label("10"), label("1"), "-|>")
    edge(label("10"), label("11"), "-|>")
    edge(label("10"), label("5"), "-|>")
    edge(label("11"), label("0"), "-|>")
    edge(label("11"), label("1"), "-|>")
    edge(label("11"), label("10"), "-|>")
    edge(label("11"), label("8"), "-|>")
}),
  figure(
  image("Elevator_normal_1000_100xp_indegree_color.svg", width: 90%), caption: [Indegree distribution of a network generated with Elevator, with 1000 nodes and 10 hubs])
)
]

== Resilience
#slide[
  // #set align(horizon)
  // #set align(center)
  // #set text(size: 15pt)

#grid(
  columns: (1fr, 1fr),
  image("Elevator_context_1000_100xp_indegree_color.svg", fit: "cover"),
image("Elevator_context_1000_100xp_diameter_color.svg", fit: "cover")
)

]
== Resilience against byzantines attacks (paper submitted to CANDAR 2025)
#slide[
  #v(-1cm)
  #set align(horizon)
  #set align(center)
  // #set text(size: 15pt)
  #image("elevator.ElevatorVCounter_5percentcounter_1000_nb_hubs_100_cycles.svg", width: 60%)
]

== Hub Learning Protocol @legheraba2025heal
#slide[
  #set align(horizon)
  #set align(center)
#set text(size: 23pt)

#fletcher-diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
let dash_node = (paint: green, dash: "dashed")
let dash_hub = (paint: blue, dash: "dashed")

node((-1.5,-0.4), `1) Each node train a 
local model`, stroke: dash_node, inset: 0.5em)

node((-1.5,0.4), `2) Each node sends 
its model to 
a (random) hub`, stroke: dash_node, inset: 0.5em)

node((2.2,-0.8), `3) Hubs receive 
and aggregate models`, fill: blue.lighten(60%), stroke: dash_hub, inset: 0.5em)

node((2.2, 0), `4) Hubs compute 
a global model 
together`, fill: blue.lighten(60%), stroke: dash_hub, inset: 0.5em)

node((2.2,0.8), `5) Hubs send back 
the global model 
to the nodes`, fill: blue.lighten(60%), stroke: dash_hub, inset: 0.5em)

    node((0.00,0.00), "0", name: "0", radius: 0.5em, fill: blue.lighten(60%))
    node((1.00,0.00), "1", name: "1", radius: 0.5em, fill: blue.lighten(60%))
    node((1.22,-0.89), "2", name: "2", radius: 0.5em)
    node((0.35,-0.60), "3", name: "3", radius: 0.5em)
    node((-0.49,0.66), "4", name: "4", radius: 0.5em)
    node((1.14,0.73), "5", name: "5", radius: 0.5em)
    node((-0.11,-0.71), "6", name: "6", radius: 0.5em)

    edge(label("0"), label("1"), "-|>")
    edge(label("1"), label("0"), "-|>")
    edge(label("2"), label("0"), "-|>")
    edge(label("2"), label("1"), "-|>")
    edge(label("3"), label("0"), "-|>")
    edge(label("3"), label("1"), "-|>")
    edge(label("2"), label("3"), "-|>")
    edge(label("3"), label("6"), "-|>")
    edge(label("4"), label("0"), "-|>")
    edge(label("4"), label("1"), "-|>")
    edge(label("4"), label("6"), "-|>")
    edge(label("5"), label("0"), "-|>")
    edge(label("5"), label("1"), "-|>")
    edge(label("5"), label("6"), "-|>")
    edge(label("5"), label("3"), "-|>")
    edge(label("6"), label("0"), "-|>")
    edge(label("6"), label("1"), "-|>")
    edge(label("6"), label("5"), "-|>")
})
]


== Architecture

#slide[
  #set align(horizon)
  #set align(center)
  // #set text(size: 15pt)

#image("architecture.png", width: 60%)
]

== Context of experiments
#slide[

#set text(size: 23pt)

- *Peer-to-Peer*: On the PeerSim simulator.
  - Each generated network had 100 nodes, and the Hub-based topology had 5 hubs
  - In addition to the crash-free context, we ran the algorithm during a context of crash, a context of churn and a context of an attack on the hubs

- *Decentralized Learning*: On the gossipy simulator
  - *ML models*: Logistic Regression & LeNet5
  - *Datasets*: Spambase and MNIST 
  - Comparison with Federated Learning, Gossip Learning, Epidemic Learning, GAIA, Chord-based Learning, Fedlay
]

// #set text(size: 18pt)
// == Simulation results
==
#slide[
  #set align(horizon)
  #set align(center)

  #v(-2cm)
// Simulation results

#grid(
  columns: (1fr),
  image("normal_accuracy_MNIST_color.svg", width: 75%), 
  image("various_hub_accuracy_MNIST_color.svg", width: 75%),
  image("hub_learning_accuracy_allcontexts_color.svg", width: 75%)
  )
]

= Work at NII

== Heterogeneous nodes
#set text(size: 20pt)

- For now, the protocol assumes homogeneous nodes (same capabilities and IID data)

- To adapt the procotol to manage heterogeneous nodes, I propose the following modifications:

  - Each node will compute a score based on 1) Data quantity, 2) Data diversity, 3) CPU power, 4) Bandwidth, 5) Energy

$ "Score" = w_1 dot Q_n + w_2 dot D_n + w_3 dot C_n + w_4 dot B_n + w_5 dot E_n $

  - Each node will ask it's neighbors for the score of all it's own neighbors and connect to the nodes that have the higher score until convergence to the hubs

// #let node_score = formula(
//   "Score_n = w_1 \cdot Q_n + w_2 \cdot D_n + w_3 \cdot C_n + w_4 \cdot B_n + w_5 \cdot E_n"
// )

// #node_score

// #text("Where:")
// #list(
//   "Q_n: Data quantity of node n",
//   "D_n: Data diversity of node n",
//   "C_n: CPU power of node n",
//   "B_n: Bandwidth of node n",
//   "E_n: Energy of node n",
//   "w_1, ..., w_5: weights assigned to each factor"
// )


== Physical network
#set text(size: 20pt)

- For now, the protocol assumes an overlay network (if you have the network address of a node you can contact it)

- To adapt the protocol for physical networks, I propose to build a hierarchical topology with 2 levels:

  - Local network
  - Global network

- We can keep the same protocol (Elevator) for the local networks, but we need a protocol to coordinate the hubs of each local network on the global level (consensus protocol)

- Need to take into account the specific features on the local level:
  - Personalized learning with 3 levels: Global, Local, Device
// == Conclusion
// #slide[

// #set text(size: 18pt)

// // Our simulation results show that, on the MNIST dataset, HEAL (with 5 hubs) achieves:
// - Results:
//   - 136% higher accuracy than Gossip Learning and 99% of Federated Learning.
//   - Our protocol continues to operate in the presence of faults, and in each fault scenario, the final accuracy is at most equal to 98% of the accuracy in a fault-free context.

// // - HEAL  achieves an accuracy of 0.95 in 76 cycles, which is one cycle slower than Gaia, and much faster than random graph methods, which achieve this value in 5 times as many cycles.
 
// // - By setting HEAL with 7 hubs and the number of hubs to which each node sends its model at 3, it is possible to reduce it to 33 cycles, which is 2.3 times faster than Gaia (the second best result). 

// - Next steps:
//   - Resilience to privacy and poisoning attacks
//   - Modelisation with Markov Chain
//   - Experiment on a real P2P network

// #set align(center)
// #set align(horizon)

// *Thanks!*

// Any questions ?


// ]
// == Next steps


#slide[
== 
#set text(size: 15pt)
#bibliography("ref.bib")
]

#show: appendix

= Appendix



== Hub Learning algorithms
#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 12pt)

#pseudocode-list(
  booktabs: true,
  title: [HEAL Learning: The Hub Algorithm],
)[
  - duration to wait for model: *delta_time*
  - list of all hubs: *hubs_list*
  + nb_hubs $arrow.l$ *hubs_list*.size()
  + *loop*
    + models $arrow.l$ ${}$
    + time $arrow.l$ time.now()
    + backwards_list $arrow.l$ ${}$
    + *while* time.now() < time + delta_time *do*
      + (peer_model, peer) $arrow.l$ receive()
      + models.append(peer_model)
      + backwards_list.append(peer)
    + average_model $arrow.l$ average(models)
    + send(hubs_list, average_model)
    + models_hubs $arrow.l$ ${}$
    + models_hubs.append(average_model)
    + nb_receive $arrow.l$ 0
    + *while* nb_receive < nb_hubs - 1 *do*
      + hub_model $arrow.l$ receive()
      + nb_receive $arrow.l$ nb_receive + 1
      + models_hubs.append(hub_model)
    + global_model $arrow.l$ average(models_hubs)
    + send(backwards_list, global_model)
]][
#set align(horizon)
#set align(center)
#set text(size: 14pt)

#pseudocode-list(
  booktabs: true,
  title: [HEAL Learning: The Client Algorithm],
)[
  - duration to wait for model: *delta_time*
  - The ML model, initialized at random: *model*
  - The local data: *data*
  - list of all hubs: *hubs_list*
  - number of hubs to send the model: *s*
  + *loop*
    + model $arrow.l$ trainModel(model, data)
    + hubs $arrow.l$ chooseRandom(hubs_list, s)
    + *for* hub *in* hubs *do*
      + send(hub, model)
    + hubs_models $arrow.l$ ${}$
    + *for* hub *in* hubs *do*  // Receiving the global models from the hubs
      + model_hub $arrow.l$ receive()
      + hubs_models.append(model_hub)
    + model $arrow.l$ average(hubs_models)
]
]

== Background thread

#slide[
  #set align(horizon)
  #set align(center)

  #pseudocode-list(booktabs: true, title: [Elevator Algorithm (background thread)])[
    + *loop*
      + request, peer $arrow.l$ receive()
      + if request == CACHE_REQUEST then
        + send(cache, peer)
        + backward_peers.add(peer)
      + if request == BACKWARD_REQUEST then
        + send(backward_peers, peer)
      ]
]

== Simulation
#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 19pt)

- Simulations done with the Java PeerSim @p2p09-peersim simulator (modified), 
with the cycle based mode

- Comparaisons against 3 peer sampling algorithms : Newscast, Proofs and Phenix (Power-law) 

#table(
  columns: (auto, auto),
  // inset: 10pt,
  align: horizon,
  table.header(
    [], [*Value*],
  ),
  "Network size",
  "1000",
  "Number of cycles for each simulation",
  "1000",
  "Number of times each simulation was run (with different seed)",
  "100",
  "c parameter (cache size)",
  "20",
  "h parameter (number of hubs)",
  "10",
)

- All simulations were run on 16 vCPU, using 64G of memory.


- Code is available at #link("https://gitlab.lip6.fr/legheraba/elevator")
]

== Metrics

#slide[
  #set align(horizon)
  #set align(center)

#grid(
  columns: (1fr, 1fr),
  image("Elevator_1000_100xp_indegree_color.svg", fit: "cover"),
image("normal_1000_100xp_average_path_color.svg", fit: "cover"),
image("normal_1000_100xp_clustering_color.svg", fit: "cover"),
image("normal_1000_100xp_diameter_color.svg", fit: "cover")
)
]
== Contexts
#slide[
  #set align(horizon)
  #set align(center)

#grid(
  columns: (1fr, 1fr),
  image("Elevator_context_1000_100xp_indegree_color.svg", fit: "cover"),
image("Elevator_context_1000_100xp_average_path_color.svg", fit: "cover"),
image("Elevator_context_1000_100xp_clustering_color.svg", fit: "cover"),
image("Elevator_context_1000_100xp_diameter_color.svg", fit: "cover")
)
]

== Churn

#slide[
  #set align(horizon)
  #set align(center)

#grid(
  columns: (1fr, 1fr),
image("churn_1000_100xp_average_path_color.svg", fit: "cover"),
image("churn_1000_100xp_clustering_color.svg", fit: "cover"),
image("churn_1000_100xp_diameter_color.svg", fit: "cover")
)
]

== Federated Learning algorithm
#slide[
#set align(center)
#set text(size: 20pt)

#pseudocode-list(
  booktabs: true,
  title: [Federated Learning (for the Server)],
)[
  - Number of iterations: *T*
  - Number of clients: *K*
  - Fraction of clients per iteration: *C*
  + *for each* t = 1...T *do*
    + m $arrow.l$ max($C dot K$, 1)
    + $S_t$ $arrow.l$ selectRandomSubset(m, clients)
    + *for each* $k in S_t$
      + send(k, $w_t$)
      + $w_(t+1)^k$ $arrow.l$ receive(k)
    + $m_t$ $arrow.l$ $sum_(k in S_t) n_k$
    + $w_(t+1)$ $arrow.l$ $sum_(k in S_t) n_k / m_t w_(t+1)^k$)  // Aggregate models
]][
 #set align(center)
#set text(size: 20pt)
 
#pseudocode-list(
  booktabs: true,
  title: [Federated Learning (for a Client)],
)[
  - Local dataset: *$D_k$*
  - Number of local epochs: *E*
  - Learning rate: *η*
  + receive($w_t$)
  + *for each* epoch = 1...E *do*
    + *for* batch b $subset$ $D_k$ *do*
      + $w_t^k $arrow.l$ w_t - η dot ∇L(w_t; b)$
  + send($w_t^k$)
]
  ]


== Hub Learning main idea
#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 15pt)

#pseudocode-list(
  booktabs: true,
)[
  + *loop*
    + *if* node_is_hub *do*
      + *while* time.now() < time_start + delta_time *do*
        + models_from_nodes.append(receiveModelFromNode())
      + aggregated_model $arrow.l$ average(models_from_nodes)
      + sendAll(hubs_list, aggregated_model)
      + global_model $arrow.l$ average(models_from_other_hubs)
      + send(nodes_list, global_model)
    + *else*
      + hubs $arrow.l$ chooseRandom(hubs_list, number_hubs_to_send_model)
      + model $arrow.l$ trainModel(model, data)
      + sendAll(hubs, model)
      + *for* hub *in* hubs *do*
        + global_models.append(receiveGlobalModelFromHub())
      + model $arrow.l$ average(global_models)
]

// Each node in the network executes the HEAL learning protocol, in addition to HEAL overlay construction via the Elevator protocol (that dynamically assigns *normal* or *hub*  status to the participating nodes):

// - If the node is a normal node, it:
//   - Selects a number of hubs at random.
//   - Performs a local training step.
//   - Sends the trained model to the hubs.
//   - Waits for the global model from each hub.
//   - Aggregates the global models.

// - If the node is a hub, it:
//   - Waits for a delta period to receive models from normal nodes.
//   - Aggregates these models by averaging their parameters.
//   - Sends its aggregated model to all other hubs.
//   - Waits to receive models from other hubs.
//   - Aggregates all these models to obtain the global model.
//   - Finally, sends the global model back to the nodes.
]
