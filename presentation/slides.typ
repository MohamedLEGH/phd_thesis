#import "@preview/fletcher:0.5.8" as fletcher: node, edge

#import "@preview/cetz:0.4.2"
#import "@preview/great-theorems:0.1.2": *
#import "../template/customization/colors.typ": *
#import "@preview/lovelace:0.3.0": *
#import "@preview/touying:0.6.1": *
#import themes.university: *

// touying: university
// nombre de page
// logo sorbonne
// footer plutot que header

#let thanks(body) = {
  footnote(numbering: _ => [\*])[#text(size: 9pt)[#body]]
  counter(footnote).update(n => n - 1)
}

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Peer-to-peer protocols for efficient and resilient decentralized learning],
    short-title: [PhD defense],
    author: [Mohamed Amine Legheraba],
    institution: [LIP6 · Sorbonne Université],
    date: [September 7, 2026],
    logo: image("../Logos/SORBONNE UNIVERSITÉ/SORBONNE_UNIVERSITE.svg", height: 18pt, alt: "Sorbonne Université"),
  ),
)

#let my-lovelace-defaults = (
  line-gap: 0.4em
)

#let pseudocode = pseudocode.with(..my-lovelace-defaults)
#let pseudocode-list = pseudocode-list.with(..my-lovelace-defaults)

#let labelbox(pos, ..args) = node(pos, ..args, fill: luma(97%), outset: 3pt)
#let title(pos, ..args) = node(pos, ..args, stroke: none, fill: none)
#let imagebox(pos, ..args) = node(pos, ..args, shape: rect, stroke: none, fill: none, outset: 0pt, inset: 0pt)

// cetz and fletcher bindings for touying
// #let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#title-slide(authors: ([
  Mohamed Amine Legheraba
  #v(0.4em)
  #text(size: 0.7em)[Supervisors: Maria Potop-Butucaru, Sébastien Tixeuil]
]))

// == About Me

// #slide[
//   #set align(horizon)
//   #set align(center)

//   #align(left)[
//     - #text(weight: "bold")[2018] — Engineering degree from Polytech Sorbonne
//     - #text(weight: "bold")[2019 – 2023] — Blockchain engineer at *Sia Partners*, then *Deloitte*
//     - #text(weight: "bold")[2023 – present] — PhD at LIP6, Sorbonne Université
//     - #text(weight: "bold")[Next] — Blockchain & AI consultant at *Temeritati*
//   ]
// ]

== Context

#slide[
  #set align(horizon)
  #set align(center)

  #image("nemo_stack_clean.png", width: 80%)
]

// == Plan

// = Context

== Supervised Classification

#slide[
  #set text(size: 18pt)
  #set align(horizon)
  #set align(center)

  #fletcher-diagram(
    node-fill: white,
    node-stroke: 1pt,
    {
      title((-2,-2.7), [*Training*])
      title((-2.7,-2.2), [*Data*])
       imagebox((-2.7, -1.5), image("dog.svg", width: 120pt), name: <dog_img>)
       imagebox((-2, -1.5), image("cat.svg", width: 120pt), name: <cat_img>)
      title((-2.7,-0.5), [*Labels*])
      labelbox((-2.7,-0.9), "Dog", name: <dog_lbl>)
      labelbox((-2,-0.9), "Cat", name: <cat_lbl>)
      imagebox((-0.6, -1.3), image("machine.svg", width: 120pt), name: <ml>)
      title((-0.6, -0.7), [*Model*])

      // flèche du couple (image chat + label Cat) vers le modèle
      edge(<cat_lbl>, <ml>, "->", stroke: 3pt)
      edge(<cat_img>, <ml>, "->", label: [(data, label)], label-size: 19pt, label-side: left, stroke: 3pt)

      // barre verticale pointillée bleue à droite du modèle (sépare l'inférence)
      node((0, -3), name: <sep_top>, stroke: none, fill: none)
      node((0, 1), name: <sep_bot>, stroke: none, fill: none)
      edge(<sep_top>, <sep_bot>, stroke: (paint: rgb("#02a9e0"), dash: "dashed", thickness: 1pt))

      title((1.7,-2.7), [*Prediction*])

      imagebox((0.5,-1.3), image("cat2.svg", width: 100pt))
      edge("->", stroke: 3pt)
      imagebox((1.8,-1.3), image("machine.svg", width: 120pt),name: <machine_trained>)
      title((1.8,-.7), [*Trained Model*])
      edge(<machine_trained>, <cat_lbl2>, "->", stroke: 3pt)
      labelbox((3,-1.3), "Cat", name: <cat_lbl2>)

  })
]

== Federated Learning

#slide[
  #set align(horizon)
  #set align(center)

  #grid(
    columns: (1fr, 1fr),
    align(center)[
      #fletcher-diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
        imagebox((0, 0.5), image("server.svg", width: 100pt), name: <server>)
        imagebox((-0.6, 2), image("smartphone.svg", width: 100pt), name: <c1>)
        imagebox((0, 2), image("smartphone.svg", width: 100pt), name: <c2>)
        imagebox((0.6, 2), image("smartphone.svg", width: 100pt), name: <c3>)

        edge(<server>, <c1>, marks: "<->", stroke: 3pt)
        edge(<server>, <c2>, marks: "<->", stroke: 3pt)
        edge(<server>, <c3>, marks: "<->", stroke: 3pt)
      })
    ],
    align(left)[
      #text(size: 19pt)[
        #pseudocode-list(booktabs: true, title: [Server])[
          + *loop*
            + received_models $arrow.l$ collect(clients)
            + global_model $arrow.l$ merge(received_models)
            + broadcast(global_model)
        ]
        #pseudocode-list(booktabs: true, title: [Client])[
          + *loop*
            + local_model $arrow.l$ train(model, local_data)
            + send(local_model, server)
            + model $arrow.l$ receive(global_model)
        ]
      ]
    ]
  )

  #text(size: 12pt)[#cite(<mcmahan2017communication>, form: "full")]
]

== Structured vs Unstructured networks

#slide[
  #set align(horizon)
  #set align(center)

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 2em,

    fletcher-diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
      node((0,1), name: "1", radius: 1em)
      edge(label("5"), "-", stroke: 1pt)
      edge(label("6"), "-", stroke: 1pt)
      node((2,1), name: "2", radius: 1em)
      edge(label("4"), "-", stroke: 1pt)
      edge(label("3"), "-", stroke: 1pt)
      node((1.5,1.8), name: "3", radius: 1em)
      edge(label("6"), "-", stroke: 1pt)
      node((1.5,0.2), name: "4", radius: 1em)
      edge(label("5"), "-", stroke: 1pt)
      node((0.5,0.2), name: "5", radius: 1em)
      node((0.5,1.8), name: "6", radius: 1em)
    }),

    fletcher-diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
      node((0,0), name: "1", radius: 1em)
      edge(label("5"), "-", stroke: 1pt)
      edge(label("2"), "-", stroke: 1pt)
      node((0.3,1), name: "2", radius: 1em)
      edge(label("5"), "-", stroke: 1pt)
      edge(label("3"), "-", stroke: 1pt)
      node((1,1.5), name: "3", radius: 1em)
      node((1.8,1), name: "4", radius: 1em)
      edge(label("5"), "-", stroke: 1pt)
      node((1.8,0), name: "5", radius: 1em)
    }),
  )
]

== Gossip Learning
#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 22pt)

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,

    fletcher-diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
      node((0,0), "1", name: "1", radius: 1em)
      edge(label("5"), "-")
      edge(label("2"), "-")
      node((0.3,1), "2", name: "2", radius: 1em)
      edge(label("5"), "-")
      edge(label("5"), stroke: 1pt + blue, "<-|", bend: 25deg, label: "peer to peer model aggregation", label-size: 7pt, label-side: right, label-sep: 0.4em, label-angle: right, "dashed")
      edge(label("3"), "-")
      node((1,1.5), "3", name: "3", radius: 1em)
      node((1.8,1), "4", name: "4", radius: 1em)
      edge(label("5"), "-")
      node((1.8,0), "5", name: "5", radius: 1em)
    }),

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
    ],
  )

  #text(size: 12pt)[#cite(<ormandi2013gossip>, form: "full")]
]

== Gossip Learning vs Federated Learning

#slide[
  #set align(horizon)
  #set align(center)

  #image("gossip_results.png", height: 86%)

  #text(size: 12pt)[#cite(<hegedHus2021decentralized>, form: "full")]
]

== State of the Art Summary

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 14pt)

  #let ok = text(fill: green)[✓]
  #let no = text(fill: red)[✗]

  #table(
    columns: (auto, auto, auto, auto, auto, auto),
    inset: 6pt,
    align: (left, center, center, center, center, center),
    table.header(
      [], [*Decentralized*], [*Local data*], [*Fast convergence*], [*Fault-tolerant*], [*No overlay overhead*],
    ),
    [*Centralized learning*], no, no, ok, no, ok,
    [*Federated learning*], no, ok, ok, no, ok,
    [*Decentralized learning* (structured net.)], ok, ok, ok, no, no,
    [*Gossip learning*], ok, ok, no, ok, ok,
    [*Local learning*], ok, ok, stack(spacing: 2pt, no, text(size: 9pt)[no generalizing model]), ok, ok,
  )

  #v(0.8em)
  #text(size: 16pt, weight: "bold")[No single solution is fully satisfactory]
]

== Contributions

#slide[
  #set align(horizon)
  #set align(center)

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
    align(center)[
      #cetz.canvas({
        import cetz.draw: *
        let w = 8
        let h = 1.6
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

        for i in range(4) {
          rect((0, i*spacing), (w, h + (i*spacing)), name: "rect_"+str(i), fill: colors.at(i))
          content((w/2, i*spacing + h/2), labels.at(i), anchor: "center")
        }
      })
    ],
    align(left + horizon)[
      #text(size: 25pt, weight: "bold")[Outline]
      #v(1em)
      #text(size: 25pt)[
        - *Elevator* — overlay (hub election)
        #v(0.6em)
        - *Lift* — malicious resilience
        #v(0.6em)
        - *HEAL* — model aggregation
        #v(0.6em)
        - *FLAIR* — wireless networks adaptation
      ]
    ],
  )
]

= Elevator

== Hub-based topology

#slide[
  #set align(horizon)
  #set align(center)

  #let hubdef = mathblock(
    blocktitle: "Definition",
    fill: rgb(75%, 90%, 75%),
    stroke: rgb(40%, 65%, 40%),
    radius: 0.3em,
    inset: 0.8em,
  )

  #hubdef(title: "Hub")[
    Let $G = (V, E)$ be the directed overlay graph, where each node $v in V$ keeps
    a partial view $P(v) subset.eq V$.
    #v(0.4em)
    A node $h in V$ is a *hub* if it appears in the partial view of every node:
    #v(0.4em)
    $ forall v in V, quad h in P(v) $
  ]

  #v(0.5em)

  #text(size: 12pt)[#cite(<legheraba2024emergent>, form: "full")]
]

== Preferential Attachment

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 15pt)

  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 1em,

    align(center)[
      #text(size: 20pt, weight: "bold")[1. One node is more connected]
      #v(0.6em)
      #fletcher-diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
        node((0, 1), "A", name: "a", radius: 0.6em, fill: orange.lighten(40%))
        node((-1, 0), "B", name: "b", radius: 0.6em)
        node((1, 0), "C", name: "c", radius: 0.6em)
        node((0, -1.2), "D", name: "d", radius: 0.6em)
        edge(<b>, <a>, "-|>")
        edge(<c>, <a>, "-|>")
        edge(<a>, <d>, "-|>")
        edge(<b>, <d>, "-|>")
      })
    ],

    align(center)[
      #text(size: 20pt, weight: "bold")[2. It attracts more connections]
      #v(0.6em)
      #fletcher-diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
        node((0, 1), "A", name: "a", radius: 0.7em, fill: orange.lighten(40%))
        node((-1.5, 0.3), "B", name: "b", radius: 0.6em)
        node((1.5, 0.3), "C", name: "c", radius: 0.6em)
        node((-0.8, -1.2), "D", name: "d", radius: 0.6em)
        node((1, -1.2), "E", name: "e", radius: 0.6em)
        edge(<b>, <a>, "-|>")
        edge(<c>, <a>, "-|>")
        edge(<d>, <a>, "-|>")
        edge(<e>, <a>, "-|>")
        edge(<b>, <d>, "-|>")
      })
    ],

    align(center)[
      #text(size: 20pt, weight: "bold")[3. Snowball effect: it becomes a hub]
      #v(0.6em)
      #fletcher-diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
        node((0, 0.5), "A", name: "a", radius: 1.1em, fill: orange.lighten(30%))
        node((-2.2, 0), "B", name: "b", radius: 0.6em)
        node((2.2, 0), "C", name: "c", radius: 0.6em)
        node((-1.2, -1.6), "D", name: "d", radius: 0.6em)
        node((1.2, -1.6), "E", name: "e", radius: 0.6em)
        node((0, 1.3), "F", name: "f", radius: 0.6em)
        node((-2, 1.4), "G", name: "g", radius: 0.6em)
        edge(<b>, <a>, "-|>")
        edge(<c>, <a>, "-|>")
        edge(<d>, <a>, "-|>")
        edge(<e>, <a>, "-|>")
        edge(<f>, <a>, "-|>")
        edge(<g>, <a>, "-|>")
      })
    ],
  )

  #v(0.8em)
  #text(size: 12pt)[#cite(<barabasi2002evolution>, form: "full")]
]

== Random Attachment

#slide[
  #set align(horizon)
  #set align(center)

  #set text(25pt)
#grid(
  columns: (1fr, 1fr),
  align(center)[
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
  ],
  align(center)[
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
  ],
)
#v(0.2em)
#set text(size: 20pt)
Before and after a shuffling operation. Node 1 sends addresses {itself, 2, 3} to node 4. Node 4 sends back {5,6,
8}.

#text(size: 12pt)[#cite(<stavrou2002lightweight>, form: "full")]
]

== Combining both ideas?

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 30pt)

  #block(width: 90%)[
    *Preferential attachment* makes hubs emerge…
    #v(1em)
    *Random attachment* keeps the network resilient…
    #v(1.5em)
    #text(weight: "bold")[Can we combine both to get *hubs* that are *resilient*?]
  ]
]

== Elevator in a nutshell

#slide[
  #set align(center)
  #set text(size: 20pt)

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
    align(center)[
      #text(size: 20pt, weight: "bold")[Mechanism]
      #v(0.6em)
      #align(left)[
        1. Each node asks its *neighbours* for *their* neighbour lists.
        #v(0.5em)
        2. It connects to the *$h$ most frequent* nodes.
        #v(0.5em)
        3. It asks these $h$ hubs for extra incoming connections, to fill a *random subset* of its view.
      ]
    ],
    align(center)[
      #text(size: 20pt, weight: "bold")[Observed]
      #v(0.6em)
      #align(left)[
        - After a few cycles, *hubs emerge* (the preferred $h$ are the same for everyone);
        - Hubs are *elected at random* among the network nodes;
        - Even after *hub failures*, new nodes are elected as hubs.
      ]
    ]
  )
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
  image("Elevator_normal_1000_100xp_indegree_color.svg", width: 110%), caption: [Indegree distribution of a network generated with Elevator, with 1000 nodes and 10 hubs])
)
]

== Stability

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 20pt)

  #let defbox = mathblock(
    blocktitle: "Definition",
    fill: rgb(75%, 90%, 75%),
    stroke: rgb(40%, 65%, 40%),
    radius: 0.3em,
    inset: 0.8em,
  )

  #defbox(title: "Stability")[
    Once Elevator has converged to a set of $h$ hubs, both the list of hubs
    and their number $h$ remain constant (with high probability) over time.
    #v(0.4em)
    Formally, after convergence time $T$:
    $ Pr[forall t >= T, H(t) = H(T) and forall v in V, C_v (t)[1:h] = H(t)] = 1 $
  ]
]

== Convergence

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 19pt)

  #let defbox = mathblock(
    blocktitle: "Definition",
    fill: rgb(75%, 90%, 75%),
    stroke: rgb(40%, 65%, 40%),
    radius: 0.3em,
    inset: 0.8em,
  )
  #let proofbox = mathblock(
    blocktitle: "Idea of the proof",
    fill: rgb(75%, 85%, 95%),
    stroke: rgb(40%, 65%, 90%),
    radius: 0.3em,
    inset: 0.8em,
  )

  #defbox(title: "Convergence")[
    The network converges to a stable state containing *exactly* $h$ hubs
    shared by all nodes.
  ]

  #v(0.8em)

  #proofbox[
    - A new hub is produced with *non-zero probability* at each cycle.
    #v(0.4em)
    - The number of hubs *cannot decrease* (until it reaches $h$).
    #v(0.4em)
    - Once at least one hub exists, the network is *strongly connected* (w.h.p.)
      and produces a new hub.
  ]
]

== Speed of convergence

#slide[
  #set align(horizon)
  #set align(center)

  #image("../Images/models/indegree_Nsize_comparison_models.pdf", height: 90%)

]

== Simulations

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 20pt)

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
    align(center)[
      #align(left)[
        PeerSim was *forked and substantially rewritten* for this thesis:
        - Migrated from *SVN to Git*, build rewritten in *Gradle*;
        - *Docker* + *GitLab CI/CD*;
        - *Parallelised* the cycle-based engine;
        - Failure models from scratch (*crash, churn, Byzantine*);
      ]
    ],
    align(center)[
      #text(size: 19pt, weight: "bold")[Parameters]
      #v(0.6em)
      #align(left)[
        - Network size: *N = 1000 nodes*;
        - *1000 cycles*, repeated *100 times*;
        - Initial topology: *random k-out graph* with *k = c = 20*;
        - *h = 10* hubs;
        - e.g. brutal crash: *50% of nodes* disconnected at cycle *500*.
      ]
    ]
  )
]

== Metrics

#slide[
  // #set align(horizon)
  #set align(center)
  #set text(size: 28pt)

  #grid(
    columns: (1fr, 1fr),
    align(center)[
      #text(size: 28pt, weight: "bold")[Overlay]
      #v(0.5em)
      #align(left)[
        - *In-degree distribution*
        - *Clustering coefficient*
        - *Average path length*
        - *Diameter*
        - *Convergence time*
      ]
    ],
    align(center)[
      #text(size: 28pt, weight: "bold")[Machine learning]
      #v(0.5em)
      #align(left)[
        - *Accuracy*
        - *Convergence time*
      ]
    ]
  )
]

== Failures

#slide[
  // #set align(horizon)
  #set align(center)
  #set text(size: 28pt)

  #grid(
    columns: (1fr, 1fr),
    align(center)[
      #text(size: 28pt, weight: "bold")[Overlay]
      #v(0.5em)
      #align(left)[
        - *Crash failures*
        - *Churn* (dynamic joins / leaves)
        - *Byzantine failures*
      ]
    ],
    align(center)[
      #text(size: 28pt, weight: "bold")[Machine learning]
      #v(0.5em)
      #align(left)[
        - *Privacy attacks*
        - *Poisoning attacks*
      ]
    ]
  )
  #v(1em)
  #text(size: 14pt)[*Note:* ML-level failures are not addressed in this thesis]
]

== Resilience
#slide[
  #set align(horizon)
  #set align(center)
  // #set text(size: 15pt)

#grid(
  columns: (1fr, 1fr),
  image("Elevator_context_1000_100xp_indegree_color.svg", fit: "cover"),
  stack(dir: ttb, spacing: 4pt, align(center)[
    #image("Elevator_context_1000_100xp_diameter_color.svg", fit: "cover")
    #v(-1.5cm)
    #text(size: 10pt)[Cycle]
  ]),
)

]

== Real TCP/IP experiments

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 16pt)

  #grid(
    columns: (1fr, 1.3fr),
    column-gutter: 1.5em,
    align(center)[
      #align(left)[
        - *Go* + *libp2p* over *TCP/IP streams* (+ light *HTTP* per node);
        - networks up to *100 nodes*;
        - modes: *synchronous / externally-synchronized / asynchronous*;
        - *hubs emerge within the first few cycles* — matching theory & simulation.
      ]
    ],
    align(center)[
      #image("../Images/Victor/graphe_4HUBS_Cycles12.svg", width: 100%)
    ],
  )
]

= Lift

== Malicious nodes
#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 20pt)

  #pseudocode-list(
    booktabs: true,
    title: [Coordinated attack — lying about neighbors],
  )[
    - addresses of all colluding nodes: *colluders*
    - backward list: *backward_peers*
    + *loop*
      + (request, peer) $arrow.l$ receive()
      + *if* request == CACHE_REQUEST
        + backward_peers.add(peer)
        + colluders.shuffle()
        + modified_cache $arrow.l$ colluders[0:c]
        + send(modified_cache, peer)
  ]

  #v(0.8em)
  #text(size: 16pt)[Each colluding node answers with a fake cache that only
  contains *other colluding nodes*, inflating their visibility.]
]

== Attack outcome

#slide[
  #set align(horizon)
  #set align(center)

  #image("../Images/CANDAR/elevator.ElevatorVByzantine2_5percentrandom_1000_nb_hubs_100_cycles.pdf", width: 80%)

]

== LIFT

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 20pt)

  #text(size: 15pt)[After convergence, correct nodes *deterministically* re-draw the hubs
  from a shared random seed — attackers can no longer keep their hub position
  (effective against infiltration at low collusion rates).]
  #v(1em)

  #pseudocode-list(
    booktabs: true,
    title: [Hub redistribution],
  )[
    - current hub list: *H*
    - network size: *N*
    - target hubs: *h*
    + seed $arrow.l$ sort(H)
    + prng $arrow.l$ Random(seed)
    + selected $arrow.l$ ${}$
    + *while* selected.size() < h
      + id $arrow.l$ prng.nextInt(N)
      + *if* id *not in* selected
        + selected $arrow.l$ selected $union$ {id}
    + H $arrow.l$ selected
  ]
]

== Resilience against colluding attackers 
#slide[
  #v(-1cm)
  #set align(horizon)
  #set align(center)
  // #set text(size: 15pt)
  #image("elevator.ElevatorVCounter_5percentcounter_1000_nb_hubs_100_cycles.pdf", width: 75%)
]

= HEAL

== Architecture

#slide[
  #set align(horizon)
  #set align(center)
  // #set text(size: 15pt)

#cetz.canvas({
  import cetz.draw: *
  let w = 8
  let h = 1.6
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
    "Physical network",
    "Elevator",
    underline("HEAL"),
    "Supervised ML models",
  )

  for i in range(4) {
    rect((0, i*spacing), (w, h + (i*spacing)), name: "rect_"+str(i), fill: colors.at(i))
    // label centré au centre géométrique du rectangle
    content((w/2, i*spacing + h/2), labels.at(i), anchor: "center")

    let mid_y = (i*spacing) + h/2
    let arrow_x_start = w + 0.15
    let arrow_x_end = w + 1.5
    let text_x = w + 1.7

    line((arrow_x_start, mid_y), (arrow_x_end, mid_y), mark: (end: ">"))
    content((text_x, mid_y), anchor: "west", details.at(i))
  }
})
]

== Hub Learning Protocol
#slide[
  #set align(horizon)
  #set align(center)
#set text(size: 19pt)

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

#text(size: 12pt)[#cite(<legheraba2025heal>, form: "full")]

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
  image("normal_accuracy_MNIST_color.svg", width: 70%), 
  image("various_hub_accuracy_MNIST_color.svg", width: 70%),
  image("hub_learning_accuracy_allcontexts_color.svg", width: 70%)
  )
]

// = Next steps

// == Heterogeneous nodes
// #set text(size: 20pt)

// - For now, the protocol assumes homogeneous nodes (same capabilities and IID data)

// - To adapt the procotol to manage heterogeneous nodes, I propose the following modifications:

//   - Each node will compute a score based on 1) Data quantity, 2) Data diversity, 3) CPU power, 4) Bandwidth, 5) Energy

// $ "Score" = w_1 dot Q_n + w_2 dot D_n + w_3 dot C_n + w_4 dot B_n + w_5 dot E_n $

//   - Each node will ask it's neighbors for the score of all it's own neighbors and connect to the nodes that have the higher score until convergence to the hubs

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


// == Physical network
// #set text(size: 20pt)

// - For now, the protocol assumes an overlay network (if you have the network address of a node you can contact it)

// - To adapt the protocol for physical networks, I propose to build a hierarchical topology with 2 levels:

//   - Local network
//   - Global network

// - We can keep the same protocol (Elevator) for the local networks, but we need a protocol to coordinate the hubs of each local network on the global level (consensus protocol)

// - Need to take into account the specific features on the local level:
//   - Personalized learning with 3 levels: Global, Local, Device
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

= FLAIR

== FLAIR architecture

#slide[
  #set align(horizon)
  #set align(center)

#cetz.canvas({
  import cetz.draw: *
  let w = 8
  let h = 1.6
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
    "Reliable packet delivery over wireless (IEEE 802.11b)",
    "Resource-aware cluster formation & head election",
    "Local aggregation within clusters by cluster-heads",
    "Supervised ML models (classification, regression, ...)",
  )

  for i in range(4) {
    rect((0, i*spacing), (w, h + (i*spacing)), name: "rect_"+str(i), fill: colors.at(i))
    content((w/2, i*spacing + h/2), labels.at(i), anchor: "center")

    let mid_y = (i*spacing) + h/2
    let arrow_x_start = w + 0.15
    let arrow_x_end = w + 1.5
    let text_x = w + 1.7

    line((arrow_x_start, mid_y), (arrow_x_end, mid_y), mark: (end: ">"))
    content((text_x, mid_y), anchor: "west", text(size: 20pt)[#details.at(i)])
  }
})
]

== FLAIR algorithm

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 21pt)

  #block(width: 90%)[
    FLAIR operates in *rounds* (LEACH-style clustering):
    #v(0.6em)
    1. Each node computes its *resource score* (CPU, RAM, GPU, bandwidth).
    #v(0.5em)
    2. Each round, a fraction of nodes *elect themselves as cluster-heads* (CHs) — the role rotates.
    #v(0.5em)
    3. Nodes send their *local models* to their nearest CH, which aggregates them.
    #v(0.5em)
    4. CHs *change every round* → the aggregated models keep *mixing across clusters*.
  ]
]

== FLAIR simulation results

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 20pt)

  #grid(
    columns: (1fr, 1.2fr),
    align(center)[
      #block(width: 95%)[
        - Static network (100 nodes): *highest accuracy* $approx 0.91$
          (C-FL / HEAL / Gossip $approx 0.90$, Gaia $approx 0.88$)
        - Convergence up to *2.5x faster* than Gaia
        - Resilient to *permanent / temporary / random crashes*
          (up to 90% nodes)
        - Tested under *mobility* and in a *smart farming* scenario
      ]
    ],
    align(center)[
      #image("../Images/FLAIR/fl_comparison_100n_100e.svg", width: 100%)
    ],
  )
]

= Conclusion

== Overview

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 16pt)

  #let ok = text(fill: green)[✓]
  #let no = text(fill: red)[✗]

  #table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    inset: 6pt,
    align: (left, center, center, center, center, center, center),
    table.header(
      [], [*Decentralized*], [*Fast convergence*], [*Fault-tolerant*], [*Resistant to colluding*], [*Learning*], [*Network type*],
    ),
    [*Elevator*], ok, ok, ok, no, text(fill: gray)[—], [P2P],
    [*Elevator + Lift*], ok, ok, ok, ok, text(fill: gray)[—], [P2P],
    [*Elevator + HEAL*], ok, ok, ok, no, ok, [P2P],
    [*FLAIR*], ok, ok, ok, no, ok, [Wireless],
  )
]

== Limitations

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 19pt)

  #align(left)[
    - *Simple ML models.* Benchmarks are modest — logistic regression on
      Spambase, LeNet5 on MNIST. No large-scale task, so convergence and
      accuracy conclusions remain to be confirmed on more ambitious models.
    #v(0.8em)
    - *Combinatorial explosion.* Network parameters ($N$, $c$, $h$),
      failure/churn scenarios, fraction of malicious nodes, ML hyper-parameters,
      and seeds define an enormous space — only a small fraction can be
      explored.
  ]
]

== Perspectives — short term

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 19pt)

  #align(left)[
    - *Capability-aware hub election* (heterogeneous nodes) and sensitivity to the initial topology.
    - Optimise Elevator (message complexity, memory, simplicity).
    - Address *data heterogeneity* in HEAL (personalisation, locally-weighted aggregation).
    - A unified *Python simulator* for networking + ML.
  ]

  #v(1em)
  #text(size: 15pt, fill: gray)[
    This work has already begun during a *3-month internship at NII (Tokyo)*.
  ]
]

== Perspectives — medium & long term

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 19pt)

  #align(left)[
    - Better robustness at the Overlay layer
    - Byzantine robustness in the learning layer (poisoning & privacy attacks)
    - Extend HEAL to unsupervised and reinforcement learning
    - Vertical federated learning (different features per participant).
    - Formal convergence guarantees for HEAL.
  ]
]

== Publications

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 14pt)

  #align(left)[
    - #cite(<legheraba2024brief>, form: "full")
    - #cite(<legheraba2024emergent>, form: "full")
    - #cite(<legheraba2025lift>, form: "full") — *Outstanding Paper Award*
    - #cite(<legheraba2025heal>, form: "full")
    - #cite(<boutebicha2026netys>, form: "full")
    - #cite(<legheraba2025noeuds>, form: "full")
    - #cite(<legheraba2025etoiles>, form: "full")
    - A journal extension (journal version of this work) has been *submitted to the
      IEEE/ACM Transactions on Networking*; we are awaiting the *final review*
      (currently in *minor revision*).
  ]
]

#slide[
== 
#set text(size: 15pt)
#bibliography("ref.bib")
]

#show: appendix

= Appendix

== Conclusion (detailed)

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 19pt)

  #align(left)[
    - *Elevator*: a self-organising overlay that makes hubs emerge — provides a
      *structured overlay* for structured aggregation without any coordinator.
    - *HEAL*: federated learning directly onto the structured overlay —
      recovers the efficiency of FL while staying decentralised.
    - *Lift*: hardens hub election against colluding byzantines (up to 10%).
    - *FLAIR*: validates the modular architecture in wireless networks (LEACH-style clustering).
    #v(0.5em)
    *Answer:* structured aggregation is possible *without centralisation*, if the
    overlay layer is designed with that goal in mind.
  ]
]

== Federated Learning

#slide[
  #set align(horizon)
  #set align(center)

  #grid(
    columns: (1fr, 1fr),
    fletcher-diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
      node((-0.5, 0), [*Server*\ global model $theta^((t))$], shape: rect, fill: blue.lighten(70%), stroke: blue.darken(20%) + 0.8pt, name: <server>)
      node((-1.2, 2), [*Client 1*\ dataset $cal(D)_1$], shape: rect, fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <c1>)
      node((-0.4, 2), [*Client 2*\ dataset $cal(D)_2$], shape: rect, fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <c2>)
      node((0.4, 2), [*Client 3*\ dataset $cal(D)_3$], shape: rect, fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <c3>)
      edge(<server>, <c1>, marks: "<->", stroke: 1pt)
      edge(<server>, <c2>, marks: "<->", stroke: 1pt)
      edge(<server>, <c3>, marks: "<->", stroke: 1pt)
    }),
    pseudocode-list(
      booktabs: true,
      title: [Federated Learning (FedAvg)],
    )[
      + *for* $t = 0$ *to* $T - 1$ *do*
        + server broadcasts $theta^((t))$
        + *for each* client $i$ *in parallel*: $theta_i arrow.l$ local training (lr $eta$, $E$ steps)
        + server aggregates: $theta^((t+1)) arrow.l sum w_i theta_i$
      + *end for*
    ],
  )

  #text(size: 12pt)[#cite(<mcmahan2017communication>, form: "full")]
]

== Federated Learning building blocks

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 9pt)

  #grid(
    columns: (1fr, 1fr),
    // LEFT: online learning
    fletcher-diagram(
      spacing: (16mm, 10mm),
      node-stroke: 0.8pt,
      node-fill: white,
      {
      node((0, 0), [Sample $t-1$\ $(x_(t-1), y_(t-1))$], shape: rect, name: <prev>, stroke: gray.lighten(50%))
      node((0, 1), [*Sample $t$*\ $(x_t, y_t)$], shape: rect, name: <cur>)
      node((0, 2), [Sample $t+1$\ $(x_(t+1), y_(t+1))$], shape: rect, name: <next>, stroke: gray.lighten(50%))
      node((1, 1), [*Model*\ $f(x ; theta_t)$], shape: rect, name: <model>)
      node((2, 1), [*Loss*\ $ell(f(x_t ; theta_t), y_t)$], shape: rect, name: <loss>)
      node((1, 2.5), [$theta_(t+1) = theta_t - eta nabla ell$], shape: rect, name: <update>)
      edge(<cur>,    <model>,  marks: "->", label: "(1) forward")
      edge(<model>,  <loss>,   marks: "->", label: "(2) loss")
      edge(<loss>,   <update>, marks: "->", label: "(3) backward")
      edge(<update>, <model>,  marks: "->", label: "(4) update θ")
    }),
    // RIGHT: ensemble learning
    fletcher-diagram(
      spacing: (14mm, 8mm),
      node-stroke: 0.8pt,
      node-fill: white,
      {
      node((0, 2), [*Input* $x$], shape: rect, name: <input>)
      node((1, 0), [Weak learner $f_1$\ $hat(y)_1 = f_1(x)$], shape: rect, name: <f1>)
      node((1, 1), [Weak learner $f_2$\ $hat(y)_2 = f_2(x)$], shape: rect, name: <f2>)
      node((1, 2), [Weak learner $f_3$\ $hat(y)_3 = f_3(x)$], shape: rect, name: <f3>)
      node((1, 3), [Weak learner $f_4$\ $hat(y)_4 = f_4(x)$], shape: rect, name: <f4>)
      node((1, 4), [Weak learner $f_5$\ $hat(y)_5 = f_5(x)$], shape: rect, name: <f5>)
      node((2, 2), [*Aggregation*\ $sum_(m=1)^M alpha_m f_m(x)$], shape: rect, name: <agg>)
      node((3, 2), [*Strong learner*\ $f_"ens"(x)$], shape: rect, name: <strong>)
      edge(<input>, <f1>, marks: "->")
      edge(<input>, <f2>, marks: "->")
      edge(<input>, <f3>, marks: "->")
      edge(<input>, <f4>, marks: "->")
      edge(<input>, <f5>, marks: "->")
      edge(<f1>, <agg>, marks: "->")
      edge(<f2>, <agg>, marks: "->")
      edge(<f3>, <agg>, marks: "->")
      edge(<f4>, <agg>, marks: "->")
      edge(<f5>, <agg>, marks: "->")
      edge(<agg>, <strong>, marks: "->")
    })
  )
]

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

- Simulations done with the Java PeerSim #thanks[#cite(<p2p09-peersim>, form: "full")] simulator (modified), 
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

== Machine Learning

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 9pt)

  // TRAINING LOOP
  #fletcher-diagram(
    spacing: (3.5cm, 1.0cm),
    node-stroke: 1.2pt,
    node-corner-radius: 4pt,
    {
    node((0,0), [Training Data \ $bold(X)$],
         fill: rgb("#dbeafe"), stroke: rgb("#1d4ed8"), name: <data>)
    node((2,0), [Labels \ $bold(y)$],
         fill: rgb("#dbeafe"), stroke: rgb("#1d4ed8"), name: <labels>)
    node((1,1), [Model $f_theta$],
         fill: rgb("#fef9c3"), stroke: rgb("#ca8a04"), name: <model>)
    node((1,2), [Predictions \ $hat(bold(y)) = f_theta(bold(X))$],
         fill: rgb("#dbeafe"), stroke: rgb("#1d4ed8"), name: <pred>)
    node((0,3), [Loss \ $cal(L)(hat(bold(y)), bold(y))$],
         fill: rgb("#fce7f3"), stroke: rgb("#be185d"), name: <loss>)
    node((2,3), [Optimizer \ $theta arrow.l theta - eta nabla_theta cal(L)$],
         fill: rgb("#dcfce7"), stroke: rgb("#15803d"), name: <opt>)
    edge(<data>,   <model>, "->", stroke: 1.5pt, label: [features], label-side: left)
    edge(<labels>, <model>, "->", stroke: 1.5pt)
    edge(<model>,  <pred>,  "->", stroke: 1.5pt, label: [forward pass], label-side: left)
    edge(<pred>,   <loss>,  "->", stroke: 1.5pt)
    edge(<loss>,   <opt>,   "->", stroke: 1.5pt)
    edge(<opt>, <model>, "->",
         label: [backward pass], label-side: right,
         stroke: (paint: rgb("#15803d"), thickness: 1.5pt),
         bend: -40deg)
  })

  #v(0.5em)

  // INFERENCE
  #fletcher-diagram(
    spacing: (6.0cm, 1.0cm),
    node-stroke: 1.2pt,
    node-corner-radius: 4pt,
    {
    node((0,0), [Unseen Data \ $bold(x)_"new" in RR^d$],
         fill: rgb("#dbeafe"), stroke: rgb("#1d4ed8"), name: <input>)
    node((1.5,0), [Trained Model \ $f_(theta^*)$],
         fill: rgb("#fef9c3"), stroke: rgb("#ca8a04"), name: <model2>)
    node((3,0), [Prediction \ $hat(y) = f_(theta^*)(bold(x)_"new")$],
         fill: rgb("#dcfce7"), stroke: rgb("#15803d"), name: <output>)
    edge(<input>, <model2>,  "->", stroke: 1.5pt)
    edge(<model2>, <output>, "->", stroke: 1.5pt)
  })
]

== Decentralized peer sampling

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 13pt)

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
  #set text(15pt)
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

#text(size: 12pt)[#cite(<stavrou2002lightweight>, form: "full")]
]

== Hub-based topology & Hub sampling

#slide[
#set text(size: 15pt)
- The objective is to obtains an overlay network with *h* defined hubs, with *h* a parameter of the algorithm, and each hub is connected to all the nodes in the networks. The application running on top will be able to take advantage of this overlay to speed up message transmission in the network.

- *Preferential Attachment*: Drawing from the concept pioneered by Barabási and Albert #thanks[#cite(<barabasi2002evolution>, form: "full")], preferential attachment dictates that new connections in the network are established preferentially with nodes possessing a higher number of existing connections. 
// This mechanism enables the organic emergence of hubs within the network, with selected nodes naturally assuming central roles based on their connectivity without any explicit distinction other than their number of incoming links.

- *Random Attachment*: Inspired by gossip-based peer sampling algorithms (#thanks[#cite(<stavrou2002lightweight>, form: "full")] #thanks[#cite(<jelasity2007gossip>, form: "full")]), random attachment ensures that nodes maintain connections with a representative and diverse subset of the network. 
// This strategy promotes network robustness by preventing excessive clustering and dependency on specific nodes (hubs). When existing hubs disappear (e.g., due to failures or departure), other nodes within the network are opportunistically elevated to hub status, ensuring continuity and adaptability of the network topology over time.

#text(size: 12pt)[#cite(<legheraba2024emergent>, form: "full")]
]

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

== Blockchain-based Federated Learning
#slide[

  #set align(horizon)
  #set align(center)

  #fletcher-diagram(
    spacing: (20mm, 18mm),
    node-stroke: 0.8pt,
    edge-stroke: 1pt,

    // --- Smart contract (center) ---
    labelbox((1.5, 0.7),
      [*Smart contract*],
      name: <sc>),

    // --- Participants ---
    imagebox((0,0), image("computer.svg", width: 70pt), name: <n1>),
    imagebox((1.5,0), image("computer.svg", width: 70pt), name: <n2>),
    imagebox((3,0), image("computer.svg", width: 70pt), name: <n3>),
    imagebox((0,1.3), image("computer.svg", width: 70pt), name: <n4>),
    imagebox((3,1.3), image("computer.svg", width: 70pt), name: <n5>),

    // --- Peer-to-peer connections between nodes ---
    edge(<n1>, <n2>, marks: "-"),
    edge(<n2>, <n3>, marks: "-"),
    edge(<n3>, <n5>, marks: "-"),
    edge(<n5>, <n4>, marks: "-"),
    edge(<n4>, <n1>, marks: "-"),
    edge(<n1>, <n3>, marks: "-"),
  )

  #text(size: 12pt)[#cite(<huang2023blockchain>, form: "full")]
]

== Services in a P2P Network

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 28pt)

  #v(1.5em)
  #grid(
    columns: (1fr, 1fr, 1fr),
    row-gutter: 2em,
    column-gutter: 1em,
    box(width: 100%, height: 3em, fill: luma(92%), stroke: gray.lighten(30%) + 1pt,
        inset: 0.4em, align(center + horizon)[*Peer sampling*]),
    box(width: 100%, height: 3em, fill: luma(92%), stroke: gray.lighten(30%) + 1pt,
        inset: 0.4em, align(center + horizon)[*Peer discovery*]),
    box(width: 100%, height: 3em, fill: luma(92%), stroke: gray.lighten(30%) + 1pt,
        inset: 0.4em, align(center + horizon)[*Data request*]),
    box(width: 100%, height: 3em, fill: luma(92%), stroke: gray.lighten(30%) + 1pt,
        inset: 0.4em, align(center + horizon)[*Membership management*]),
    box(width: 100%, height: 3em, fill: luma(92%), stroke: gray.lighten(30%) + 1pt,
        inset: 0.4em, align(center + horizon)[*Topology management*]),
    box(width: 100%, height: 3em, fill: luma(92%), stroke: gray.lighten(30%) + 1pt,
        inset: 0.4em, align(center + horizon)[*Information dissemination*]),
  )
]


== Peer sampling

#slide[
  #set align(horizon)
  #set align(center)

  #let pvdef = mathblock(
    blocktitle: "Definition",
    fill: rgb(75%, 90%, 75%),
    stroke: rgb(40%, 65%, 40%),
    radius: 0.3em,
    inset: 0.6em,
  )

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    align(center)[
      #fletcher-diagram(node-fill: green.lighten(60%), node-stroke: 1pt, {
        node((0, 2.2), [*Server*\ peer list $P$], shape: rect,
          fill: blue.lighten(70%), stroke: blue.darken(20%) + 0.8pt, name: <srv>)
        node((0, 0), [*Node*], shape: rect,
          fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <nd>)
        edge(<nd>, <srv>, "-|>", label: [request peers],
        label-side: left, label-size: 18pt)
        edge(<srv>, <nd>, "-|>", label: [return random \ [$\{p_1, ..., p_N\}$]], label-size: 18pt, bend: 30deg)
      })
    ],
    align(center)[
      #pvdef(title: "Partial View")[
        The *partial view* of $v$, denoted $P(v)$, is the set of nodes $v$ can send
        messages to, $P(v) subset.eq V$, with $|P(v)| <= c$, $c << N$,
        and $P(v) = "neigh"_G (v)$.      ]
    ]
  )
]

== Datasets & Models

#slide[
  #set align(horizon)
  #set align(center)
  #set text(size: 26pt)

  #v(0.5em)
  #stack(dir: ltr, spacing: 1.5em,
    // BLOC 1 : Spambase + Logistic regression (sans boîte)
    align(center + horizon)[
      #text(size: 20pt)[*Spambase* + *Logistic regression*]
      #v(0.3em)
      #image("spambase_features.png", height: 5.5cm)
      #v(0.2em)
      #text(size: 20pt)[4601 emails, binary  \   57 parameters]
    ],
    // BLOC 2 : MNIST + LeNet5 (sans boîte)
    align(center + horizon)[
      #text(size: 20pt)[*MNIST* + *LeNet5*]
      #v(0.3em)
      #image("../Images/Dataset/MNIST_dataset_example.png", height: 5.5cm)
      #v(0.2em)
      #text(size: 20pt)[70k digits, 10 classes  \   CNN, ~60k parameters]
    ],
  )
]
