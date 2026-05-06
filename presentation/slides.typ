#import "@preview/touying:0.5.5": *
#import themes.metropolis: *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Peer-to-Peer Protocols for Efficient and Resilient Decentralised Learning],
    subtitle: [Theory, Design and Evaluation],
    author: [Mohamed Amine LEGHERABA],
    date: [PhD Defence · 2025],
    logo: image("../Logos/SORBONNE UNIVERSITÉ/SORBONNE_UNIVERSITE.svg", height: 1.2em),
  ),
  config-colors(
    primary: rgb("#800080"),
    primary-light: rgb("#d6c6b7"),
    secondary: rgb("#23373b"),
    neutral-lightest: rgb("#fafafa"),
    neutral-dark: rgb("#23373b"),
    neutral-darkest: rgb("#23373b"),
  ),
)

#set text(font: "DejaVu Sans", weight: "light", size: 20pt)
#show math.equation: set text(font: "DejaVu Math TeX Gyre")
#set strong(delta: 100)
#set par(justify: true)

// ============================================================
// TITLE SLIDE
// ============================================================

#title-slide(extra: [
  #table(
    columns: (1fr, 1fr, 1fr),
    stroke: none,
    align: (center, center, center),
    inset: 0pt,
    image("../Logos/SORBONNE UNIVERSITÉ/SORBONNE_UNIVERSITE.svg", height: 1.4em),
    image("../Logos/LIP6/LIP6.svg", height: 1.4em),
    image("../Logos/CNRS/CNRS.svg", height: 1.4em),
  )
  #v(0.3em)
  #text(size: 0.7em)[
    Supervised by Pr. Maria Potop-Butucaru & Pr. Sébastien Tixeuil
  ]
])

// ============================================================
// PART 0: OPENING
// ============================================================

= Opening

#slide(title: [About Me])[
  #grid(
    columns: (2fr, 1fr),
    column-gutter: 2em,
  )[
    *Mohamed Amine LEGHERABA*

    #v(0.5em)

    #text(size: 0.85em)[
      - *2018*: Engineering degree in Computer Science
      - *2018–2022*: 4 years in IT consulting
        - Blockchain architecture
        - DevOps engineering
      - *Feb. 2023*: Started PhD at Sorbonne Université, LIP6
        - Supervisors: Maria Potop-Butucaru, Sébastien Tixeuil
        - Team: NPA (Networks, Performance and Algorithms)
    ]
  ][
    #align(center)[
      #rect(width: 80%, fill: rgb("#800080").lighten(90%), stroke: rgb("#800080"), inset: 1em, radius: 0.5em)[
        #text(size: 0.85em, fill: rgb("#800080"))[
          *3-month research stay*\
          National Institute of Informatics\
          Tokyo, Japan\
          Host: Megumi Kaneko
        ]
      ]
    ]
  ]
]

#slide(title: [Research Trajectory])[
  #align(center)[
    #rect(width: 90%, fill: rgb("#f5f5f5"), stroke: none, inset: 1.5em, radius: 0.5em)[
      #grid(
        columns: (1fr, auto, 1fr, auto, 1fr),
        column-gutter: 1em,
        row-gutter: 0.8em,
        align: (center, center, center, center, center),
      )[
        #rect(fill: rgb("#800080").lighten(85%), stroke: rgb("#800080"), inset: 0.8em, radius: 0.3em)[
          #text(size: 0.8em)[
            *Initial idea*\
            Federated Learning\
            + Blockchain
          ]
        ]
      ][
        #text(size: 1.5em, fill: rgb("#800080"))[→]
      ][
        #rect(fill: rgb("#008002").lighten(85%), stroke: rgb("#008002"), inset: 0.8em, radius: 0.3em)[
          #text(size: 0.8em)[
            *Pivot 1*\
            Gossip Learning\
            is more appropriate
          ]
        ]
      ][
        #text(size: 1.5em, fill: rgb("#008002"))[→]
      ][
        #rect(fill: rgb("#0000ff").lighten(85%), stroke: rgb("#0000ff"), inset: 0.8em, radius: 0.3em)[
          #text(size: 0.8em)[
            *Pivot 2*\
            Gossip underperforms\
            → Peer Sampling
          ]
        ]
      ]
    ]
  ]

  #v(1em)

  #text(size: 0.85em)[
    - *Initial plan*: Security of FL (privacy attacks, poisoning attacks) using blockchain
    - *Realisation*: Blockchain consensus ≠ ML optimisation — mismatch of objectives
    - *Discovery*: Gossip learning already eliminates the central server, but convergence is slow
    - *Key insight*: The bottleneck is the *communication topology*, not the learning algorithm
  ]
]

#slide(title: [NEMO Project])[
  #grid(
    columns: (3fr, 2fr),
    column-gutter: 2em,
  )[
    This thesis is part of the *NEMO* project (*N*etworks of *E*volving *M*icro-*O*perators)

    #v(0.5em)

    #text(size: 0.85em)[
      - European project (H2020)
      - Rethinking Internet and 5G network architectures in Europe
      - Goal: decentralised, micro-operator driven networks
      - Key challenge: distributed coordination without central authority
      - Our contribution: peer-to-peer protocols for decentralised learning
    ]
  ][
    #align(center)[
      #rect(width: 90%, fill: rgb("#008002").lighten(90%), stroke: rgb("#008002"), inset: 1em, radius: 0.5em)[
        #text(size: 0.85em, fill: rgb("#008002"))[
          *From security to performance*\
          \
          We initially targeted security (privacy, poisoning)\
          \
          → Realised gossip learning performance was the bottleneck\
          \
          → Shifted focus to peer sampling & overlay topology
        ]
      ]
    ]
  ]
]

#slide(title: [The Centralisation of AI])[
  #text(size: 0.9em)[
    Modern AI development follows a structural tendency toward *centralisation*:
  ]

  #v(0.5em)

  - A *small number* of actors collect the data, train the models, deploy the services
  - Users interact through opaque APIs — no access to data, code, or training process
  - The *black box problem*: models whose decisions cannot be traced to interpretable rules

  #v(0.5em)

  #text(size: 0.9em)[
    Three interrelated concerns:
  ]

  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 1em,
  )[
    #rect(fill: rgb("#800080").lighten(90%), stroke: rgb("#800080"), inset: 0.8em, radius: 0.3em)[
      #align(center)[
        *#text(fill: rgb("#800080"))[Privacy]*\
        #text(size: 0.8em)[Raw data leaves the hands of those who generated it]
      ]
    ]
  ][
    #rect(fill: rgb("#0000ff").lighten(90%), stroke: rgb("#0000ff"), inset: 0.8em, radius: 0.3em)[
      #align(center)[
        *#text(fill: rgb("#0000ff"))[Sovereignty]*\
        #text(size: 0.8em)[Dependency on private actors for critical infrastructure]
      ]
    ]
  ][
    #rect(fill: rgb("#008002").lighten(90%), stroke: rgb("#008002"), inset: 0.8em, radius: 0.3em)[
      #align(center)[
        *#text(fill: rgb("#008002"))[Accountability]*\
        #text(size: 0.8em)[Opaque models resist democratic oversight]
      ]
    ]
  ]
]

#slide(title: [Why Decentralise?])[
  *Use case 1: Healthcare*\
  #text(size: 0.85em)[A hospital with a rare disease has too few cases to train alone — neighbouring hospitals face the same constraint, yet patient data cannot be shared.]

  #v(0.8em)

  *Use case 2: Autonomous vehicles*\
  #text(size: 0.85em)[Manufacturers guard their data jealously, yet all share an interest in reducing accidents — a model that improves with collective data, produced by a process that compromises no one.]

  #v(0.8em)

  *Use case 3: Language models*\
  #text(size: 0.85em)[A model trained collectively by heterogeneous participants would be structurally more resistant to commercial, ideological, or political influence.]

  #v(0.5em)

  #align(center)[
    #rect(fill: rgb("#800080").lighten(90%), stroke: rgb("#800080"), inset: 0.6em, radius: 0.3em)[
      *Decentralised learning: privacy and the absence of central control are structural consequences of how the system is designed.*
    ]
  ]
]

#slide(title: [Research Question])[
  #align(center + horizon)[
    #rect(width: 85%, fill: rgb("#800080").lighten(90%), stroke: rgb("#800080") + 1.5pt, inset: 1.5em, radius: 0.5em)[
      #align(center)[
        #text(size: 1.1em, weight: "bold", fill: rgb("#800080"))[
          Can we build a decentralised learning system that matches the efficiency of centralised federated learning, while being fully decentralised and resilient to failures?
        ]
      ]
    ]
  ]
]

// ============================================================
// PART 1: FOUNDATIONS
// ============================================================

= Foundations

#slide(title: [Contributions])[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
    row-gutter: 1em,
  )[
    #rect(fill: rgb("#800080").lighten(90%), stroke: rgb("#800080"), inset: 0.8em, radius: 0.3em)[
      *C1: Elevator*\
      #text(size: 0.8em)[Decentralised overlay protocol that organises nodes into a hub-and-spoke topology through emergent hub election]
    ]
  ][
    #rect(fill: rgb("#008002").lighten(90%), stroke: rgb("#008002"), inset: 0.8em, radius: 0.3em)[
      *C2: Lift*\
      #text(size: 0.8em)[Byzantine-resilient extension of Elevator that prevents adversarial nodes from manipulating hub election]
    ]
  ][
    #rect(fill: rgb("#0000ff").lighten(90%), stroke: rgb("#0000ff"), inset: 0.8em, radius: 0.3em)[
      *C3: HEAL*\
      #text(size: 0.8em)[Decentralised federated learning framework built on Elevator — hub-based aggregation recovers FL efficiency]
    ]
  ][
    #rect(fill: rgb("#ffa500").lighten(90%), stroke: rgb("#ffa500"), inset: 0.8em, radius: 0.3em)[
      *C4: FLAIR*\
      #text(size: 0.8em)[Adaptation to wireless networks using LEACH-style clustering — validates the layered architecture]
    ]
  ]
]

#slide(title: [Formal Model: Node & Network])[
  *Node* — abstract computational entity:\
  #text(size: 0.85em)[State machine $(S, s_0, delta)$, partial view $P(v) subset.eq V$, cache size $c << N$]

  #v(0.5em)

  *Overlay network* — directed graph $G = (V, E)$:\
  #text(size: 0.85em)[Vertices = nodes, edges = communication channels (unidirectional or bidirectional)]

  #v(0.5em)

  *Protocol* — distributed algorithm executed by all nodes:\
  #text(size: 0.85em)[Specifies local state, messages, transition rules. All nodes share global parameters ($c$, $h$).]

  #v(0.5em)

  *Execution model*:
  - *Protocol step* = one execution of the protocol loop by one node
  - *Protocol cycle* = every node executes one step (synchronous or sequential)
  - *Time-varying graph* $G(t) = (V(t), E(t))$ to capture churn

  #v(0.5em)

  *Global state* = concatenation of all local states: $S_"global" = (s_v)_(v in V)$
]

#slide(title: [Failure Models])[
  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 1.2em,
  )[
    #rect(fill: rgb("#ffa500").lighten(90%), stroke: rgb("#ffa500"), inset: 0.8em, radius: 0.3em)[
      *Crash failures*\
      #text(size: 0.8em)[
        - Node permanently stops
        - No message sent/received
        - Model: CSMP $chevron.l n, t chevron.r [emptyset]$
        - Permanent, no recovery
      ]
    ]
  ][
    #rect(fill: rgb("#008002").lighten(90%), stroke: rgb("#008002"), inset: 0.8em, radius: 0.3em)[
      *Churn*\
      #text(size: 0.8em)[
        - Dynamic arrivals/departures
        - Fraction of nodes replaced per cycle
        - Modelled as time-varying graph
        - Period of churn + stabilisation
      ]
    ]
  ][
    #rect(fill: rgb("#ff0000").lighten(90%), stroke: rgb("#ff0000"), inset: 0.8em, radius: 0.3em)[
      *Byzantine failures*\
      #text(size: 0.8em)[
        - Arbitrary behaviour
        - Can send incorrect messages
        - Can collude with others
        - Model: BSMP $chevron.l n, t chevron.r [emptyset]$
      ]
    ]
  ]
]

// ============================================================
// PART 2: STATE OF THE ART
// ============================================================

= State of the Art

#slide(title: [Overlay Networks: Landscape])[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
  )[
    *Structured overlays* (DHTs)
    #text(size: 0.85em)[
      - Chord, Kademlia, Pastry
      - Logarithmic diameter ✓
      - Deterministic routing ✓
      - Fragile under churn ✗
      - Vulnerable to Byzantine ✗
      - Application-specific ✗
      - No hub election ✗
    ]
  ][
    *Unstructured overlays* (gossip)
    #text(size: 0.85em)[
      - Cyclon, Newscast, HyParView
      - Resilient to churn ✓
      - Low overhead ✓
      - Application-agnostic ✓
      - Slow convergence ✗
      - No global aggregation ✗
      - No hub election ✗
    ]
  ]

  #v(0.5em)
  #align(center)[
    #text(fill: rgb("#800080"), weight: "bold")[Neither family supports deliberate hub election for structured aggregation.]
  ]
]

#slide(title: [Power-Law & Scale-Free Overlays])[
  *Protocols*: Phenix, Gia, SG-1, T-MAN, VICINITY, Park et al.

  #v(0.5em)

  *Key insight*: degree heterogeneity → hubs emerge naturally → faster dissemination

  #v(0.5em)

  *But*:
  - Hubs are *passive structural properties* — not coupled to any active protocol role
  - Hub identity changes continuously — unreliable for learning layer
  - Vulnerable to targeted attacks (removing hubs fragments the network)
  - Many protocols require continuous network growth or bootstrap servers
  - Degree caps in some protocols *explicitly prevent* hub formation

  #v(0.5em)

  #rect(fill: rgb("#800080").lighten(90%), stroke: rgb("#800080"), inset: 0.6em, radius: 0.3em)[
    #text(size: 0.85em)[
      *Topological emergence of hubs ≠ structured aggregation mechanism.*\
      What is needed: a protocol that *elects* hubs, *assigns* them aggregation responsibility, and *maintains* this structure under failures.
    ]
  ]
]

#slide(title: [Decentralised Learning Landscape])[
  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 1em,
  )[
    #rect(fill: rgb("#0000ff").lighten(90%), stroke: rgb("#0000ff"), inset: 0.8em, radius: 0.3em)[
      *Federated Learning*\
      #text(size: 0.8em)[
        Fast convergence ✓\
        Star topology\
        Single point of failure ✗\
        No churn resilience ✗
      ]
    ]
  ][
    #rect(fill: rgb("#008002").lighten(90%), stroke: rgb("#008002"), inset: 0.8em, radius: 0.3em)[
      *Gossip Learning*\
      #text(size: 0.8em)[
        Fully decentralised ✓\
        Churn resilient ✓\
        Slow convergence ✗\
        No aggregation ✗
      ]
    ]
  ][
    #rect(fill: rgb("#ffa500").lighten(90%), stroke: rgb("#ffa500"), inset: 0.8em, radius: 0.3em)[
      *Epidemic Learning*\
      #text(size: 0.8em)[
        Fully decentralised ✓\
        Broadcast-based\
        Slow convergence ✗\
        High overhead ✗
      ]
    ]
  ]

  #v(0.8em)

  #align(center)[
    #text(fill: rgb("#800080"), weight: "bold", size: 1.1em)[
      Gap: no protocol simultaneously achieves decentralisation, scalability, and aggregation efficiency
    ]
  ]
]

#slide(title: [The Gap We Fill])[
  #align(center + horizon)[
    #rect(width: 90%, fill: rgb("#800080").lighten(90%), stroke: rgb("#800080") + 1.5pt, inset: 1.5em, radius: 0.5em)[
      #text(size: 0.95em)[
        *How can the efficiency of gossip learning be improved to approach federated learning, without sacrificing decentralisation?*
      ]

      #v(1em)

      #text(size: 0.9em)[
        Our answer: the bottleneck is *not at the learning layer* — it is *one level below*, at the *peer sampling layer*. By shaping the communication topology to introduce structured aggregation, we recover FL efficiency without any central coordinator.
      ]
    ]
  ]
]

// ============================================================
// PART 3: ELEVATOR
// ============================================================

= Elevator & Lift

#slide(title: [Elevator: Intuition])[
  *Combine two attachment mechanisms*:

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
  )[
    #rect(fill: rgb("#800080").lighten(90%), stroke: rgb("#800080"), inset: 0.8em, radius: 0.3em)[
      *Preferential attachment*\
      #text(size: 0.85em)[
        Connect to the most connected nodes in the 2-hop neighbourhood\
        → hubs emerge organically\
        → low diameter
      ]
    ]
  ][
    #rect(fill: rgb("#008002").lighten(90%), stroke: rgb("#008002"), inset: 0.8em, radius: 0.3em)[
      *Random attachment*\
      #text(size: 0.85em)[
        Maintain $c - h$ connections to random peers via hubs\
        → robustness to failures\
        → self-healing when hubs fail
      ]
    ]
  ]

  #v(0.8em)

  *Result*: a network with $h$ hubs where:
  - Every node is at most 2 hops from any other (diameter = 2)
  - Hubs emerge *spontaneously* — no central coordinator
  - The number of hubs $h$ is a *tunable parameter*
]

#slide(title: [Hub — Formal Definition])[
  *Definition (Hub)*: A node $h in V$ is a *hub* if its identifier appears in the partial view of *every* node in the network:

  $ forall v in V, quad h in P(v) $

  #v(0.5em)

  *Definition (Hub Sampling Service)*: A protocol that, starting from an arbitrary overlay, induces the emergence of a subset $H subset.eq V$, $|H| = h$, where every node in $H$ satisfies the hub property.

  #v(0.5em)

  *Ideally*: $H$ is drawn uniformly at random over all $binom(|V|, h)$ subsets.

  #v(0.5em)

  *Key property*: A hub is known to *all* nodes — it can serve as:
  - Aggregation point (like a server in FL)
  - Source of randomness (random peer from a hub = uniform sample)
]

#slide(title: [Elevator Protocol])[
  *Parameters*: cache size $c$, number of preferential connections $h$, backward buffer size

  #v(0.5em)

  At each cycle, every node executes:

  #text(size: 0.85em)[
    1. *Retrieve 2-hop neighbours*: collect caches of all $c$ neighbours
    2. *Build frequency map*: count occurrences of each node identifier
    3. *Select preferred nodes*: top $h$ most frequent → these are the *hub candidates*
    4. *Request backward lists*: ask each preferred node for its incoming connections
    5. *Reset cache*: clear current outgoing connections
    6. *Fill cache*: $h$ preferred + $(c - h)$ random peers from backward lists
    7. *Complete if needed*: fill remaining slots from frequency map
  ]

  #v(0.5em)

  *Result*: after a few cycles, the same $h$ nodes appear in every node's cache → *hubs have emerged*
]

#slide(title: [Elevator: Desired Properties])[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
    row-gutter: 0.8em,
  )[
    #rect(fill: rgb("#800080").lighten(90%), inset: 0.6em, radius: 0.3em)[
      *Connectivity*\
      #text(size: 0.85em)[Overlay remains connected despite churn and topology adaptations]
    ]
  ][
    #rect(fill: rgb("#008002").lighten(90%), inset: 0.6em, radius: 0.3em)[
      *Low diameter*\
      #text(size: 0.85em)[Hubs reduce communication distance → diameter $\leq 2$ after convergence]
    ]
  ][
    #rect(fill: rgb("#0000ff").lighten(90%), inset: 0.6em, radius: 0.3em)[
      *Convergence*\
      #text(size: 0.85em)[From arbitrary initial state → stable hub topology in $O(log N)$ cycles]
    ]
  ][
    #rect(fill: rgb("#ffa500").lighten(90%), inset: 0.6em, radius: 0.3em)[
      *Stability*\
      #text(size: 0.85em)[Once converged, hub set remains unchanged with high probability]
    ]
  ][
    #rect(fill: rgb("#ff0000").lighten(90%), inset: 0.6em, radius: 0.3em)[
      *Robustness*\
      #text(size: 0.85em)[Resilient to crash failures, churn, and targeted hub attacks]
    ]
  ]
]

#slide(title: [Theoretical Analysis: Stability])[
  *Proposition*: Once Elevator has converged to $h$ hubs, it remains stable.

  #v(0.3em)

  *Sketch of proof*:
  - Number of hubs *cannot exceed* $h$: each node selects at most $h$ preferred nodes
  - Number of hubs *cannot decrease*: probability of a random node replacing a hub:
    $P_"new hub" approx N(N-h) ((c-h)/N)^c$
    This is negligible for $c << N$ and $h << N$
  - Hub set *cannot change*: intersection probability of random subsets:
    $p(0) = q(0) - q(1) approx 1$

  #v(0.5em)

  *Key insight*: the stability is a consequence of the *concentration of indegree* on the hub nodes — random fluctuations are exponentially unlikely to perturb it.
]

#slide(title: [Theoretical Analysis: Convergence])[
  *Proposition*: Starting from a random $k$-out graph, Elevator converges w.h.p. to exactly $h$ hubs.

  #v(0.3em)

  *Proof structure*:
  1. With sufficiently large $c$, at least one hub emerges after finite cycles (w.h.p.)
  2. If $\geq 1$ hub exists → network is strongly connected (w.h.p.)
  3. Additional hubs appear eventually (non-zero probability per cycle)
  4. Number of hubs is non-decreasing between 1 and $h$
  5. Therefore: $1 -> 2 -> ... -> h$ hubs (monotone progression)

  #v(0.5em)

  *Convergence time*: modelled via a logistic function with dynamic growth rate:

  $d(t) = N / (1 + a dot exp(-(r_0 t + (1/2) delta_r t^2)))$

  #text(size: 0.85em)[where $r_0 = 2 + h/10$, $delta_r = K/N$, $a = N/K - 1$]
]

#slide(title: [Convergence Time: Model vs Simulation])[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
  )[
    #image("../Images/models/indegree_Nsize_comparison_models.pdf", width: 100%)
  ][
    #image("../Images/models/indegree_numberhubs_comparison_models.pdf", width: 100%)
  ]

  #text(size: 0.8em)[
    Logistic model closely fits simulation data (lower RMSE than geometric model).\
    Convergence in 4–5 cycles for $N = 1000$ — very fast in practice.
  ]
]

#slide(title: [Simulation Evaluation: Overview])[
  *Setup*: PeerSim simulator, networks of 100 to 1000 nodes, $c = 20$, $h = 10$

  #v(0.5em)

  *Metrics compared against baselines* (Newscast, Cyclon, Phenix, SimpleNewscast):
  - Indegree / outdegree distribution
  - Clustering coefficient
  - Average path length
  - Network diameter
  - Largest strongly connected component

  #v(0.5em)

  *Scenarios*:
  - Normal (fault-free)
  - Crash failures (20% of nodes)
  - Crash of hub nodes
  - Churn (10% per cycle)

  #v(0.5em)

  *Baselines*: Newscast, Cyclon, Phenix, FedLay, SimpleNewscast
]

#slide(title: [Simulation: Normal Operation])[
  #image("../Images/TON/Fedlay_normal_1000_100xp_indegree_color.pdf", width: 65%)

  #text(size: 0.85em)[
    Elevator converges to a *bimodal indegree distribution*: $h$ hubs with indegree $approx N$, remaining nodes with indegree $approx c - h$.\
    Diameter drops to 2 within 4–5 cycles.
  ]
]

#slide(title: [Simulation: Crash & Churn])[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
  )[
    #image("../Images/TON/Fedlay_crash_1000_100xp_diameter_color.pdf", width: 100%)
  ][
    #image("../Images/TON/Phenix_churn_1000_100xp_diameter_color.pdf", width: 100%)
  ]

  #text(size: 0.85em)[
    - *Crash*: diameter remains low; new hubs are elected within 2 cycles\
    - *Churn*: overlay self-heals; topology stabilises quickly after churn ends\
    - *Hub crash*: even when all hubs fail simultaneously, the network recovers
  ]
]

#slide(title: [Real TCP/IP Deployment])[
  #text(size: 0.9em)[
    *Setup*: Real network deployment over TCP/IP
  ]

  #v(0.5em)

  - Validates that Elevator works beyond simulation
  - Measures: latency of reconfiguration, message volume
  - Confirms: hub emergence and stability behave as predicted

  #v(1em)

  #align(center)[
    #rect(fill: rgb("#008002").lighten(90%), stroke: rgb("#008002"), inset: 0.8em, radius: 0.3em)[
      *Three-level evaluation*: Theory + Simulation + Real deployment\
      → Consistent results across all three
    ]
  ]
]

#slide(title: [Byzantine Attacks on Elevator])[
  *Vulnerability*: Elevator assumes honest reporting → Byzantine nodes can manipulate hub election

  #v(0.5em)

  *Attack types studied*:

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 0.5em,
  )[
    #text(size: 0.85em)[
      1. *Passive*: send empty cache
      2. *Active*: inflate own presence in cache
    ]
  ][
    #text(size: 0.85em)[
      3. *Non-coordinating*: each Byzantine promotes itself
      4. *Coordinated*: Byzantines promote each other
    ]
  ]

  #v(0.5em)

  *Key finding*: Types 1–3 are tolerated by Elevator without modification.\
  *But*: Type 4 (coordinated) — as few as *2%* of malicious nodes can guarantee all Byzantines become hubs.

  #v(0.3em)

  #text(fill: rgb("#ff0000"), weight: "bold")[The hub election is the highest-value attack surface in the entire stack.]
]

#slide(title: [Lift: Byzantine-Resilient Hub Redistribution])[
  *Idea*: After Elevator converges, *deterministically redistribute* hubs using a shared PRNG.

  #v(0.5em)

  *Protocol (2 phases)*:

  #text(size: 0.85em)[
    *Phase 1*: Run standard Elevator → hub set $H$ (may contain Byzantines)

    *Phase 2*: All correct nodes execute:
    1. Retrieve IDs of the $h$ current hubs (identical across all nodes)
    2. Build a *seed* by concatenating sorted hub IDs → same seed for all
    3. Initialise PRNG with this seed → identical random sequence
    4. Generate $h$ new node IDs from PRNG → *new hub set*
    5. Replace the first $h$ cache entries with the new hubs
  ]

  #v(0.5em)

  *Result*: Even if Byzantines dominated the initial hub set, the redistribution treats all nodes equally — each node has probability $h/N$ of becoming a hub, regardless of Byzantine status.

  #v(0.3em)

  *Tolerance*: Collusion threshold extended from 2% → *10%* of Byzantine nodes.
]

// ============================================================
// PART 4: HEAL
// ============================================================

= HEAL & FLAIR

#slide(title: [HEAL: Motivation])[
  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 1em,
  )[
    #rect(fill: rgb("#0000ff").lighten(90%), stroke: rgb("#0000ff"), inset: 0.6em, radius: 0.3em)[
      *FL*\
      #text(size: 0.8em)[
        Fast convergence\
        Central server\
        Single point of failure
      ]
    ]
  ][
    #rect(fill: rgb("#008002").lighten(90%), stroke: rgb("#008002"), inset: 0.6em, radius: 0.3em)[
      *Gossip*\
      #text(size: 0.8em)[
        Fully decentralised\
        Churn resilient\
        Slow convergence
      ]
    ]
  ][
    #rect(fill: rgb("#800080").lighten(90%), stroke: rgb("#800080") + 1.5pt, inset: 0.6em, radius: 0.3em)[
      *HEAL*\
      #text(size: 0.8em, weight: "bold")[
        FL convergence speed\
        + Full decentralisation\
        + Churn & crash resilience
      ]
    ]
  ]

  #v(0.5em)

  *Key idea*: Use Elevator's hubs as *distributed aggregators* → recover the communication structure of FL without any central server.
]

#slide(title: [HEAL: Layered Architecture])[
  #grid(
    columns: (3fr, 2fr),
    column-gutter: 1.5em,
  )[
    #image("../Images/HEAL/hub_learning_accuracy_allcontexts_color.pdf", width: 90%)

    // Placeholder for architecture diagram — describe in text
    #text(size: 0.85em)[
      *Application Layer*: ML model (SVM, NN, ...)\
      *Aggregation Layer*: FedAvg at hub level\
      *Overlay Layer*: Elevator (hub election)\
      *Network Layer*: TCP/IP
    ]
  ][
    *Key design principles*:

    #v(0.3em)

    #text(size: 0.85em)[
      - Strict *separation of concerns*
      - Each layer independent
      - Well-defined interfaces between layers
      - A layer can be *substituted* without affecting others
      - This is validated by FLAIR (different overlay + network)
    ]

    #v(0.5em)

    *HEAL = FL aggregation + Elevator overlay*
  ]
]

#slide(title: [HEAL: 5-Phase Protocol])[
  Each cycle consists of five successive phases:

  #v(0.3em)

  #grid(
    columns: (auto, 5fr),
    column-gutter: 0.5em,
    row-gutter: 0.4em,
  )[
    #rect(fill: rgb("#800080"), inset: (x: 0.5em, y: 0.3em), radius: 0.2em)[#text(fill: white, size: 0.8em)[1]]
  ][
    *Local training*: each node trains its model on private data
  ][
    #rect(fill: rgb("#800080"), inset: (x: 0.5em, y: 0.3em), radius: 0.2em)[#text(fill: white, size: 0.8em)[2]]
  ][
    *Model transfer*: each node sends its model to $s$ randomly chosen hubs
  ][
    #rect(fill: rgb("#008002"), inset: (x: 0.5em, y: 0.3em), radius: 0.2em)[#text(fill: white, size: 0.8em)[3]]
  ][
    *Hub aggregation*: each hub averages received models (Average SGD)
  ][
    #rect(fill: rgb("#0000ff"), inset: (x: 0.5em, y: 0.3em), radius: 0.2em)[#text(fill: white, size: 0.8em)[4]]
  ][
    *Inter-hub coordination*: hubs exchange aggregates → identical global model
  ][
    #rect(fill: rgb("#ffa500"), inset: (x: 0.5em, y: 0.3em), radius: 0.2em)[#text(fill: white, size: 0.8em)[5]]
  ][
    *Redistribution*: hubs send global model back to contributing nodes
  ]

  #v(0.5em)

  #text(size: 0.85em)[
    *Communication overhead per cycle*: $2(n-h) dot s + h(h-1)$ messages\
    For $n=100, h=5, s=1$: *210 messages* (vs 198 for FL, 1000 for Epidemic)
  ]
]

#slide(title: [HEAL: Crash-Free Results])[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
  )[
    #image("../Images/HEAL/normal_accuracy_MNIST_color.pdf", width: 100%)
  ][
    #image("../Images/HEAL/normal_accuracy_Spambase_color.pdf", width: 100%)
  ]

  #text(size: 0.85em)[
    - MNIST (LeNet5): HEAL reaches 0.97 — comparable to FL (0.97), far above Gossip (0.71)
    - Spambase (LogReg): HEAL reaches 0.90 — comparable to FL (0.91)
    - Convergence speed: HEAL reaches 0.95 on MNIST in *76 cycles* (FL: 91 cycles)
  ]
]

#slide(title: [HEAL: Convergence Speed])[
  #figure(
    table(
      columns: (auto, auto, auto, auto),
      align: (left, center, center, center),
      inset: 8pt,
      table.header([*Method*], [*0.85*], [*0.90*], [*0.95*]),
      [Federated Learning], [22], [37], [91],
      [Gaia (5 servers)], [13], [28], [88],
      [Gossip Learning], [N/A], [N/A], [N/A],
      [Epidemic Learning], [90], [137], [372],
      [Ring], [74], [157], [569],
      [Chord], [98], [159], [451],
      [FedLay], [89], [136], [422],
      [*HEAL (5 hubs, $s=1$)*], [*15*], [*27*], [*76*],
      [*HEAL (7 hubs, $s=3$)*], [*5*], [*10*], [*33*],
    ),
  ) 

  #text(size: 0.85em)[Cycles to reach target accuracy on MNIST. N/A = not reached within 1000 cycles.]
]

#slide(title: [HEAL: Crash Resilience])[
  #image("../Images/HEAL/crash20peers_accuracy_MNIST_color.pdf", width: 60%)

  #v(0.3em)

  #text(size: 0.85em)[
    - 20% crash at cycle 10: HEAL maintains accuracy ≈ 0.97
    - *Crucially*: crash of all 5 hubs → *no measurable impact* (new hubs elected within 2 cycles)
    - HEAL remains functional up to 50% crash rate
    - FL and Gaia: server crash → training halts unconditionally
  ]
]

#slide(title: [HEAL: Churn Resilience])[
  #image("../Images/HEAL/hub_learning_churn_accuracy_MNIST_color.pdf", width: 60%)

  #v(0.3em)

  #text(size: 0.85em)[
    - 10–30% churn (cycles 50–150): temporary accuracy drop during churn phase
    - *Recovery*: accuracy returns to pre-churn level almost immediately after churn ends
    - At 30% churn: mean drop = 0.28 during churn, but *final accuracy = 0.95*
    - FedLay: smaller drop during churn but same final accuracy
  ]
]

#slide(title: [HEAL: Summary of Results])[
  #table(
    columns: (auto, auto, auto, auto),
    align: (left, center, center, center),
    inset: 8pt,
    stroke: 0.5pt,
    table.header(
      [*Property*], [*FL*], [*Gossip*], [*HEAL*],
    ),
    [Fast convergence], [✓], [✗], [✓],
    [Decentralised], [✗], [✓], [✓],
    [Crash resilient], [✗], [✓], [✓],
    [Churn resilient], [✗], [✓], [✓],
    [No single point of failure], [✗], [✓], [✓],
    [Hub-targeted attack resilient], [—], [✓], [✓],
    [Low communication overhead], [✓], [✓], [✓],
  )

  #v(0.5em)

  #align(center)[
    #text(fill: rgb("#800080"), weight: "bold")[HEAL closes the gap between FL and gossip learning.]
  ]
]

#slide(title: [FLAIR: Motivation])[
  *Question*: Can the layered architecture be adapted to a fundamentally different network context?

  #v(0.5em)

  *Target*: Resource-constrained ad-hoc *wireless networks* (WiFi 802.11)

  #v(0.5em)

  *Key differences from HEAL*:

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
  )[
    #text(size: 0.85em)[
      - Overlay topology shaped by *radio range*, not explicit election
      - Nodes are *heterogeneous* (CPU, RAM, bandwidth)
      - Communication is *single-hop* within clusters
      - No inter-cluster coordination
    ]
  ][
    #text(size: 0.85em)[
      - Cluster heads elected based on *resource score*
      - CHs *rotate* every round
      - Global model mixing emerges from rotation alone
      - Evaluated on *ns-3* simulator
    ]
  ]

  #v(0.5em)

  #rect(fill: rgb("#008002").lighten(90%), stroke: rgb("#008002"), inset: 0.6em, radius: 0.3em)[
    #text(size: 0.85em)[
      *FLAIR = existence proof that the layered architecture is modular*: substitute Overlay + Network layers → working protocol for wireless edge.
    ]
  ]
]

#slide(title: [FLAIR: Architecture & Evaluation])[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5em,
  )[
    *Architecture*:

    #v(0.3em)

    #text(size: 0.85em)[
      - Network Layer: IEEE 802.11 ad-hoc
      - Overlay Layer: LEACH-inspired clustering with resource-aware CH election
      - Aggregation Layer: in-cluster FedAvg (no inter-CH exchange)
      - Application Layer: logistic regression
    ]

    #v(0.5em)

    *CH election*:
    - Verifiable Random Function (VRF) for fairness
    - Resource score: $R_n = alpha dot "CPU"_n + beta dot "RAM"_n + gamma dot "GPU"_n + delta dot "BW"_n$
    - Threshold: $T(n) = (p dot R_n) / (1 - p dot (r mod 1/p))$
  ][
    *Evaluation (ns-3)*:

    #v(0.3em)

    #text(size: 0.85em)[
      - Binary classification on Spambase and Plants dataset
      - Scenarios: fault-free, random faults, recurring faults, permanent faults, node mobility
      - Baselines: LEACH, Smart-LEACH, standard FL
    ]

    #v(0.5em)

    *Key results*:
    - Convergence comparable to centralised FL in static settings
    - Resilient to permanent and recurring faults
    - Mobility has limited impact on convergence
    - Resource-aware election improves over random LEACH
  ]
]

// ============================================================
// PART 5: CONCLUSIONS
// ============================================================

= Conclusions & Outlook

#slide(title: [Summary of Contributions])[
  #let ctag(label) = rect(fill: rgb("#800080"), inset: (x: 0.5em, y: 0.3em), radius: 0.2em, [#text(fill: white, size: 0.8em)[#label]])
  #table(
    columns: (auto, 5fr),
    stroke: none,
    column-gutter: 0.8em,
    row-gutter: 0.6em,
    inset: 0pt,
    ctag[C1], [*Elevator*: first decentralised overlay protocol with *deliberate hub emergence* — application-agnostic, $O(log N)$ convergence, validated by theory + simulation + real deployment],
    ctag[C2], [*Lift*: Byzantine-resilient extension — deterministic hub redistribution via shared PRNG, extends collusion tolerance from 2% to 10%],
    ctag[C3], [*HEAL*: first *cross-layer* decentralised learning framework — hub-based aggregation recovers FL efficiency while preserving full decentralisation and fault resilience],
    ctag[C4], [*FLAIR*: validates architectural modularity — adaptation to wireless networks via layer substitution],
  )
]

#slide(title: [Limitations])[
  #text(size: 0.9em)[
    - *Theoretical*: convergence proofs rely on idealised assumptions; no formal convergence guarantee for HEAL
    - *Scale*: Elevator validated at 1 000 nodes; HEAL at 100 nodes — below P2P community standards
    - *ML benchmarks*: LeNet5/MNIST, Spambase — below current standards
    - *Statistical rigour*: only 5 runs per configuration; no error bars
    - *IID assumption*: all experiments assume homogeneous data distributions
    - *Byzantine*: Lift protects overlay only; learning layer vulnerable to poisoning
    - *Synchronisation*: inter-hub phase is synchronous — tension with full decentralisation
    - *FLAIR*: limited to binary classification; no convergence guarantee under non-stationary topology
  ]
]

#slide(title: [Near-Term Perspectives])[
  #let ntag(num, col) = rect(fill: col, inset: (x: 0.5em, y: 0.3em), radius: 0.2em, text(fill: white, size: 0.8em, str(num)))
  #table(
    columns: (auto, 5fr),
    stroke: none,
    column-gutter: 0.8em,
    row-gutter: 0.6em,
    inset: 0pt,
    ntag(1, rgb("#800080")), [*Capability-aware hub election*: bias election toward resource-rich nodes while preserving decentralisation],
    ntag(2, rgb("#008002")), [*Non-IID data*: adapt aggregation strategy (personalisation, locally-weighted aggregation)],
    ntag(3, rgb("#0000ff")), [*Unified simulator*: Python-based, combining peer sampling + dynamic topology + ML in a single framework],
  )
]

#slide(title: [Long-Term Perspectives])[
  #let ntag(num, col) = rect(fill: col, inset: (x: 0.5em, y: 0.3em), radius: 0.2em, text(fill: white, size: 0.8em, str(num)))
  #table(
    columns: (auto, 5fr),
    stroke: none,
    column-gutter: 0.8em,
    row-gutter: 0.6em,
    inset: 0pt,
    ntag(4, rgb("#800080")), [*Byzantine-hardened HEAL*: robust aggregation + differential privacy + secure aggregation at the learning layer],
    ntag(5, rgb("#008002")), [*Large-scale deployment*: validate at 10K–100K nodes on real infrastructure],
    ntag(6, rgb("#0000ff")), [*Formal convergence guarantees*: for HEAL under partial participation and heterogeneous data],
    ntag(7, rgb("#ffa500")), [*Beyond supervised learning*: extend to unsupervised and reinforcement learning],
    ntag(8, rgb("#ff0000")), [*Incentive mechanisms*: reward participation, deter free-riding (potentially via blockchain/Lightning Network)],
  )
]

#focus-slide[
  #text(1.5em, weight: "bold")[Thank you for your attention]

  #v(1em)

  #text(1em)[Questions?]
]

// ============================================================
// APPENDIX
// ============================================================

= Appendix

#slide(title: [Publications])[
  #text(size: 0.9em)[
    International conferences:
  ]

  #v(0.3em)

  - M. A. Legheraba et al., "A Brief Overview of Elevator," *ICDCN* 2024
  - M. A. Legheraba et al., "Emergent Peer-to-Peer Multi-Hub Topology," *ICDCN* 2024
  - M. A. Legheraba et al., "Lift: Byzantine-Resilient Hub Redistribution," *ICDCN* 2025 — *#text(fill: rgb("#800080"), weight: "bold")[Outstanding Paper Award]*
  - M. A. Legheraba et al., "HEAL: Hub Enhanced Adaptive Learning," *IEEE IPDPS* 2025

  #v(0.5em)

  National conferences:
  - M. A. Legheraba et al., "Nœuds hubs émergents," *Compas* 2025
  - M. A. Legheraba et al., "Étoiles fédérées décentralisées," *Compas* 2025
]

#slide(title: [Elevator: Detailed Evaluation — Crash])[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
  )[
    #image("../Images/TON/Fedlay_crash_1000_100xp_biggest_component_color_zoom.pdf", width: 100%)
  ][
    #image("../Images/TON/Fedlay_crash_1000_100xp_clustering_color.pdf", width: 100%)
  ]

  #text(size: 0.85em)[
    Elevator under 20% crash scenario (1000 nodes, 100 experiments).\
    Largest connected component remains stable; clustering coefficient recovers within 2 cycles.
  ]
]

#slide(title: [Elevator: Comparison with Baselines])[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
  )[
    #image("../Images/TON/crash_hub_1000_100xp_indegree_color_zoom.pdf", width: 100%)
  ][
    #image("../Images/TON/Elevator_normal_1000_100xp_biggest_component_strong_color_zoom.pdf", width: 100%)
  ]

  #text(size: 0.85em)[
    Left: indegree under hub crash — Elevator quickly re-elects new hubs.\
    Right: largest SCC under normal operation — Elevator maintains full connectivity.
  ]
]

#slide(title: [Byzantine Attack Types — Detail])[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 0.8em,
  )[
    #rect(fill: rgb("#ffa500").lighten(90%), stroke: rgb("#ffa500"), inset: 0.6em, radius: 0.3em)[
      *Do-nothing attack*\
      #text(size: 0.8em)[Byzantine returns empty cache → minimal impact on hub election]
    ]
  ][
    #rect(fill: rgb("#008002").lighten(90%), stroke: rgb("#008002"), inset: 0.6em, radius: 0.3em)[
      *Non-coordinating attack*\
      #text(size: 0.8em)[Each Byzantine inflates own ID → slight increase in Byzantine hub proportion]
    ]
  ][
    #rect(fill: rgb("#ff0000").lighten(90%), stroke: rgb("#ff0000"), inset: 0.6em, radius: 0.3em)[
      *Coordinated attack*\
      #text(size: 0.8em)[Byzantines share fake caches promoting each other → 2% sufficient to capture all hubs]
    ]
  ][
    #rect(fill: rgb("#800080").lighten(90%), stroke: rgb("#800080"), inset: 0.6em, radius: 0.3em)[
      *Lift counter-measure*\
      #text(size: 0.8em)[Deterministic redistribution via shared PRNG → tolerance extended to 10% collusion]
    ]
  ]
]

#slide(title: [HEAL: Impact of Number of Hubs])[
  #image("../Images/HEAL/various_hub_accuracy_MNIST_color.pdf", width: 65%)

  #text(size: 0.85em)[
    - Increasing $h$ has minimal impact on final accuracy (hubs don't train, only aggregate)
    - Sending to $s = h/2$ hubs slightly improves convergence speed
    - $h = 5$, $s = 1$ offers a good balance between performance and resilience
  ]
]

#slide(title: [HEAL: Crash of All Hubs])[
  #image("../Images/HEAL/hub_learning_crash_accuracy_MNIST_color.pdf", width: 65%)

  #text(size: 0.85em)[
    - 1 hub crash: no measurable impact (0.9638 accuracy at cycle 200)
    - 5 hub crash (all hubs): *no measurable impact* (0.9629 accuracy)
    - Elevator re-elects new hubs within 2 cycles → HEAL self-heals
    - FL/Gaia: server crash → *training halts unconditionally*
  ]
]

#slide(title: [Simulation Infrastructure])[
  #text(size: 0.9em)[
    *Elevator & overlay evaluation*: PeerSim (Java)
  ]

  #v(0.3em)

  #text(size: 0.85em)[
    - Migrated from SVN to Git; introduced Gradle, Docker, CI/CD
    - Parallelised simulation engine
    - Implemented fault models, Byzantine attacks, overlay protocols
  ]

  #v(0.5em)

  #text(size: 0.9em)[
    *HEAL & learning evaluation*: Gossipy + PeerSim (hybrid)
  ]

  #v(0.3em)

  #text(size: 0.85em)[
    - PeerSim: dynamic topology (overlay layer)
    - Gossipy: real PyTorch training (learning layer, not simulated)
    - At each cycle: PeerSim graph → Gossipy determines aggregation partners
  ]

  #v(0.5em)

  #text(size: 0.9em)[
    *FLAIR evaluation*: ns-3 (C++)
  ]

  #v(0.3em)

  #text(size: 0.85em)[
    - Full network stack simulation (WiFi, propagation, interference)
    - All baselines re-implemented in C++ for strict comparability
  ]

  #v(0.5em)

  #rect(fill: rgb("#800080").lighten(90%), stroke: rgb("#800080"), inset: 0.5em, radius: 0.3em)[
    #text(size: 0.85em)[*Ongoing*: new unified Python simulator combining topology + learning + faults]
  ]
]

#slide(title: [FLAIR: Detailed Evaluation])[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
  )[
    #image("../Images/FLAIR/fl_comparison_100n_100e.pdf", width: 100%)
  ][
    #image("../Images/FLAIR/smart_leach_fault_permanent.pdf", width: 100%)
  ]

  #text(size: 0.85em)[
    Left: FLAIR vs baselines (100 nodes, fault-free). Right: under permanent fault scenario.\
    Resource-aware CH election outperforms standard LEACH and Smart-LEACH.
  ]
]
