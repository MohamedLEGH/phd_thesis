#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/cetz:0.4.2"

#import "@preview/lovelace:0.3.0": *

#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
// #import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

= Introduction <chap:introduction>
This thesis is concerned with peer-to-peer protocols for efficient and resilient decentralised learning. Each of these terms carries precise technical meaning, and each reflects a deliberate design choice. Before unpacking them, it is worth stepping back to understand the broader context from which this research emerges. Peer-to-peer networks did not appear in a vacuum --- they are a product of a longer history of communication infrastructure, and understanding what makes them distinctive requires understanding the landscape they emerged from. Similarly, decentralised learning cannot be appreciated without first understanding what machine learning is, how it developed, and why the conditions under which it is practised today raise questions that go well beyond the technical. This introduction therefore proceeds in two steps: it first traces the evolution of communication networks, from their earliest forms to the Internet and the peer-to-peer systems it made possible; it then turns to artificial intelligence and machine learning, from their theoretical foundations to their current concentration in the hands of a small number of actors. From the convergence of these two trajectories, the research question at the heart of this thesis naturally emerges.

Communication networks have long been central to the development of human societies. From the telegraph to the telephone, from postal routes to radio broadcasting, each successive generation of infrastructure has reduced the cost of exchanging information across distance and, in doing so, has reshaped the economic, political, and cultural fabric of the societies it connected. The Internet represents the culmination of this trajectory --- and a qualitative leap beyond it. Born out of a desire to build a communication infrastructure resilient to partial failure, it was designed from the outset so that no single node, no single institution, and no single government could control or interrupt the flow of information. By the turn of the millennium, this global network had become the substrate on which an ever-growing share of human activity took place, enabling near-instantaneous exchange of information across the planet at negligible cost.

Yet the open and decentralised architecture of the Internet did not prevent the emergence of centralisation at the layer of services built on top of it. The protocols that gave rise to the World Wide Web were open and accessible to all, but the services that came to dominate the Web were not. Over the course of two decades, a small number of technology companies --- today grouped under the informal label of Big Tech --- came to occupy a position of structural dominance over the digital lives of billions of people. Their success rested on a straightforward logic: a centralised service, operated from a single infrastructure, can serve the entire planet while continuously improving through the aggregation of its users' data. The simplicity they offered was genuine, and the economies of scale they achieved were real. But these advantages came at a price that was not always made explicit: the progressive transfer of personal data, behavioural traces, and, ultimately, a degree of individual autonomy to private entities whose decisions remain largely opaque.

In response to this concentration, communities of developers and researchers began, from the early days of the Web, to imagine and build alternatives. Peer-to-peer protocols --- systems in which participants interact directly with one another rather than through a central intermediary --- offered a different vision of what networked services could look like: distributed, egalitarian, and resilient by design. Some of these efforts achieved remarkable reach; others remained confined to niche communities. But together, they demonstrated that decentralised alternatives were technically feasible, and they raised questions of sufficient depth and generality to attract the attention of the academic research community. How does a system coordinate without a centre? How does it remain reliable when its participants are unreliable? How does it scale when no single entity oversees its growth? These questions sit at the intersection of computer science, mathematics, and the theory of complex systems, and they remain active areas of inquiry today.

Beyond technical architecture, the question of whether digital infrastructure should be centralised or decentralised is, at its core, a question about power: who controls the systems that mediate communication, commerce, and knowledge; who has access to the data these systems generate; and who bears the risks when they fail or are misused. There is no neutral answer. Centralised services offer convenience and efficiency, but they concentrate power and create dependencies that individuals and institutions may not fully perceive until they are already deeply embedded. Decentralised alternatives demand more from their participants --- a degree of technical literacy, a willingness to share responsibility, and a collective commitment to maintaining the commons --- but they offer in return a form of autonomy and resilience that centralised architectures cannot provide by design. Whether this trade-off is worth making is not a question this thesis attempts to answer. It is an open societal debate, and one that will not be resolved by technical means alone. What this thesis does attempt is to advance the technical foundations that would make decentralised alternatives more viable, so that this choice can be made on informed and practical grounds.

On a separate but parallel trajectory, artificial intelligence has been a driving intellectual ambition since the earliest days of computing. From the foundational theoretical work of Turing and McCarthy to the modern era of machine learning and deep learning, the field has undergone successive waves of progress, each expanding the range of tasks that machines can perform and the scale at which they can operate. Today, machine learning models underpin an ever-growing share of the systems that structure daily life, from search engines and recommendation platforms to medical diagnosis and language understanding.

What distinguishes modern machine learning systems from classical software is not merely their capability, but their fundamental nature. A traditional algorithm is a set of explicit instructions written by a programmer: its behaviour is fully determined by its code, which can in principle be read, audited, and understood. A machine learning model, by contrast, does not follow instructions --- it learns from data. Before it can be used, it must be trained on a large corpus of examples, a process through which it develops internal representations that no human explicitly designed. The result is a system whose behaviour emerges from the interaction of its architecture, its training data, and the precise conditions of the training process --- none of which are recoverable from the model alone. This is what researchers mean when they speak of the black box problem: not that the system is mysterious in principle, but that its decisions cannot be traced back to interpretable rules. This opacity is already a concern when the model is developed in an academic or open setting. It becomes considerably more acute in the context of commercial AI systems, where users interact with a model through an interface or an API without any access to the underlying architecture, the training data, the source code, or even the random seed that determined how training unfolded. In some cases, the weights of a model are made publicly available --- but weights alone, without the data and the process that produced them, offer only a partial and often insufficient basis for understanding or auditing the system's behaviour. The practical consequence is that the systems which today exert the most influence over decisions affecting millions of people are also the least transparent, and the least amenable to independent scrutiny.

These two trajectories --- the progressive concentration of digital services in the hands of a small number of platform operators, and the rise of machine learning as the dominant paradigm in artificial intelligence --- are not independent phenomena. They share a common root: the training of machine learning models is, by its very nature, a resource-intensive operation that favours centralisation. It requires access to large volumes of data, which platforms accumulate as a byproduct of their scale, and to significant computational infrastructure, which only a handful of organisations can afford to operate. Centralisation is not an incidental feature of modern AI development --- it is, under current conditions, a structural tendency. Yet this tendency is not inevitable. One may legitimately ask whether it is possible to train machine learning models differently --- without aggregating raw data in a single location, without delegating control to a central authority, and without requiring any participant to expose information they would prefer to keep private. Is there, in other words, a viable alternative to the centralised paradigm that dominates the field today?

One candidate answer has existed for over two decades, though it was developed in an entirely different context. Peer-to-peer networks, which emerged in the late 1990s and achieved widespread use in the early 2000s, were designed precisely to enable large-scale coordination without central control. Though their mainstream adoption has remained confined to specific niches --- file sharing, cryptocurrency, distributed storage --- the architectural principles they embody are still actively studied and deployed. The question this thesis asks is whether these principles can be transplanted into the domain of machine learning: whether a peer-to-peer network can serve not merely as a medium for transferring files or reaching consensus, but as the substrate on which a machine learning model is collectively trained, iteratively refined, and made available to its participants --- without any of them ever surrendering their data to a central party.

Pursuing this question requires bridging two research communities that have, until recently, evolved largely independently of one another. The networking and distributed systems community has developed a rich body of work on peer-to-peer protocols, graph theory, and self-stabilising systems, and is accustomed to reasoning about well-defined, often deterministic environments: nodes, links, message complexity, consensus protocols, and fault models with precise formal guarantees. The machine learning community operates in a fundamentally different register --- one of statistics, optimisation, and empirical validation, where the objects of study are loss functions, gradient estimates, and generalisation bounds, and where the notion of a network, if it appears at all, refers to the architecture of a model rather than the topology of a communication system. These two communities do not share the same vocabulary, the same proof techniques, or the same experimental culture. The consequence is that the space where they overlap --- decentralised machine learning over peer-to-peer networks --- has remained comparatively underexplored. Addressing it seriously requires fluency in both domains simultaneously: any theoretical analysis must account for the stochastic dynamics of learning and the adversarial dynamics of distributed coordination at the same time, and any experimental evaluation must be credible from both perspectives.

The motivations for pursuing this research direction extend well beyond technical curiosity. The ethical dimensions are concrete and pressing. At stake are three interrelated concerns: privacy, since centralised training requires raw data to leave the hands of those who generated it and be aggregated under the control of a third party; sovereignty, since the growing dependence of public institutions on models developed and controlled by a small number of private actors creates dependencies that individuals, nations, and democratic systems may find increasingly difficult to accept; and accountability, since a model trained on undisclosed data, by an unreproducible process, and deployed through an opaque interface offers little purchase to the conventional instruments of democratic oversight --- transparency, contestability, and liability. These concerns crystallise around a common pattern: there exist many situations in which no single participant holds enough data to train a useful model on their own, yet every participant has strong reasons --- legal, competitive, or ethical --- not to share that data with a third party. Decentralised learning addresses precisely this tension.

Consider the medical domain. A hospital treating patients with a rare disease may have access to only a handful of relevant cases --- far too few to train a reliable diagnostic model. Neighbouring hospitals face the same constraint. Yet patient data is among the most sensitive information that exists, and sharing it with an external party raises serious concerns about confidentiality, consent, and regulatory compliance. A decentralised training framework would allow these institutions to collaboratively build a model of a quality that none of them could achieve alone, without any patient record ever leaving the institution that collected it.

A second case arises among competing actors who share a common interest. Consider the automotive industry, where multiple manufacturers are independently developing autonomous driving systems. Each company guards its data jealously, as it represents a significant competitive asset. Yet all of them share an interest in reducing the rate of accidents --- a goal that improves with the volume and diversity of training data. Decentralised learning makes it possible to aggregate the benefits of a shared training process without requiring any participant to expose proprietary data to its competitors. The result is a model that is safer for everyone, produced by a process that compromises no one.

A third case concerns the construction of large language models --- the systems that today underpin conversational AI, automated writing, and an ever-growing range of decision-support tools. These models are currently trained by a small number of private actors on datasets whose composition is rarely disclosed. This concentration creates a risk that is not merely technical: a sufficiently influential actor could, intentionally or not, shape the values, assumptions, and blind spots of a model that billions of people interact with daily. A language model trained collectively, by a distributed set of participants with heterogeneous data and divergent perspectives, would be structurally more resistant to this kind of influence --- whether commercial, ideological, or political.

What these cases share is something deeper than a technical property. Decentralised learning is, at its core, an exercise in building a common good. Each participant contributes what they have, retains what they wish to protect, and benefits from the collective result. No single actor controls the outcome, and no single actor can capture it. This vision of collaborative intelligence --- distributed, egalitarian, and resistant to capture --- is what gives the research direction developed in this thesis its broader significance.

Decentralised learning is not the only possible response to these concerns, and it would be misleading to present it as a perfect solution. Several alternative approaches exist, each with its own merits and limitations. One option is to encrypt data before sharing it, using techniques such as homomorphic encryption, which allows computations to be performed directly on encrypted data without ever decrypting it. This approach offers strong theoretical guarantees, but it comes at a computational cost that remains, in practice, prohibitive for training large models. Another option is to add carefully calibrated statistical noise to the data or to the model updates before they are shared --- a technique known as differential privacy --- which makes it mathematically impossible to recover individual records from the shared information. This is a valuable complement to decentralised learning, but it does not by itself address the question of who controls the training process. A third option is to rely on trusted execution environments: specialised hardware enclaves that guarantee, at the chip level, that even the operator of the infrastructure cannot access the data being processed. This provides a technical guarantee without requiring decentralisation, but it transfers the question of trust from the service provider to the hardware manufacturer. A fourth option is to place a centralised actor under strict legal obligations, relying on regulation rather than architecture to enforce privacy and accountability. This approach has real value, and the European Union's efforts in this direction --- through the GDPR, the AI Act, and related instruments --- represent a serious attempt to make it work. But a well-intentioned and legally compliant centralised actor remains a single point of failure: it can be compromised by a cyberattack, subject to unconscious biases in how it curates training data, or placed under political or economic pressure that no regulatory framework can fully anticipate. Finally, one might ask whether the problem can be sidestepped altogether --- either by generating synthetic data locally to augment small datasets, or by developing model architectures that require less data to achieve useful performance. These are active and promising research directions, but they do not generalise: for many applications, and in particular for rare or highly specific phenomena, neither synthetic generation nor data-efficient architectures can substitute for the real, distributed data that participants hold.

The appeal of decentralised learning, in this context, lies in the fact that it addresses the problem at the architectural level. Privacy and the absence of central control are not properties that depend on the goodwill of an operator, the robustness of a legal framework, or the security of a hardware supply chain --- they are structural consequences of how the system is designed. This does not mean that decentralised systems are without weaknesses. They introduce their own trade-offs: coordinating training across many independent participants without a central authority is harder, slower, and more vulnerable to certain classes of malicious behaviour#footnote[In this thesis, malicious behaviour is studied at the overlay level, where an adversary could manipulate the hub election (addressed by the Lift protocol, Chapter 4). Defending the machine-learning layer itself against Byzantine or poisoning attacks (e.g., manipulated model updates) lies outside the scope of this work; we return to this point in the limitations and outlook (Chapter 7).] than centralised training.

This raises the central question of this thesis: is it possible to build a decentralised learning system that matches the efficiency of its centralised counterparts, while being fully decentralised and resilient to failures and malicious participants? This question is not merely rhetorical --- it is technically non-trivial, and the answer is far from obvious. This thesis attempts to address it through two complementary lenses: a structured review of the existing literature at the intersection of peer-to-peer systems and machine learning, which maps the landscape of prior work and identifies the open problems that motivate the contributions that follow; and the design and evaluation of original protocols for decentralised federated learning, which make deliberate design choices to advance what is achievable in terms of efficiency, decentralisation, and resilience against malicious behaviour.

== Contributions

The work presented in this thesis is organised around a unifying architectural
view. Decentralised learning of the kind investigated here is not a single
protocol but a *layered architecture* of four layers: a *Network Layer*
responsible for low-level communication; an *Overlay Layer* that maintains the
logical topology and decides which nodes talk to which; an *Aggregation Layer*
that combines locally trained models; and an *Application Layer* that carries
out the learning task. The key design intuition of this thesis is that these
layers must be designed *together*: in particular, the overlay layer should be
engineered so as to make efficient global aggregation possible, instead of being
treated as an independent concern. Each layer exposes a narrow interface and can
be replaced independently of the others, which is what later allows the very
same architecture to be instantiated in different physical settings.

#figure(
cetz.canvas({
  import cetz.draw: *
  let w = 4
  let h = 1.4
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
    "Physical network &\nTCP/IP stack",
    "P2P topology &\nneighbor management",
    "Aggregation protocol &\nparameter fusion",
    "Supervised ML models\n(SVM, NN, ...)",
  )

  for i in range(4) {
    rect((0, i*spacing), (w, h + (i*spacing)), name: "rect_"+str(i), fill: colors.at(i))
    content("rect_"+str(i), labels.at(i))

    let mid_y = (i*spacing) + h/2
    let arrow_x_start = w + 0.15
    let arrow_x_end = w + 0.6
    let text_x = w + 0.7

    line((arrow_x_start, mid_y), (arrow_x_end, mid_y), mark: (end: ">"))
    content((text_x, mid_y), anchor: "west", details.at(i))
  }
}), alt: "Layered architecture of decentralised learning showing four stacked layers: Network, Overlay, Aggregation, and Application", caption: [The four-layer architecture of decentralised learning used throughout this thesis.]
) <fig:architecture-intro>

To the best of our knowledge, such an architecture --- in which a structured
overlay is explicitly designed as the substrate for machine-learning aggregation,
with independently replaceable layers spanning both the networking and the
learning stacks --- has not been proposed before in the context of decentralised
machine learning. Building on this view, the contributions of this thesis instantiate
this architecture piece by piece. The thesis makes four original contributions
at the intersection of peer-to-peer networking and decentralised machine
learning.

The first contribution is *Elevator*, a decentralised peer sampling protocol that organises nodes into a hub-and-spoke overlay through a lightweight, self-organising random election mechanism. Elevator requires no pre-assigned coordinator, makes no assumption about the application running on top of it, and is designed to tolerate node crashes and churn. By elevating a dynamic subset of nodes to the role of hubs, it introduces a structured aggregation topology into an otherwise flat peer-to-peer network, without sacrificing the decentralised nature of the system.

The second contribution is *Lift*, an extension of Elevator that addresses Byzantine fault tolerance. Where Elevator assumes that participants follow the protocol honestly, Lift introduces an analysis of the protocol's behaviour under Byzantine attacks and equips it with a defence mechanism that limits the influence of malicious participants on the hub election process. Lift strengthens the security guarantees of the entire protocol stack built on top of Elevator.

The third contribution is *HEAL*, a decentralised federated learning protocol built directly on top of the Elevator overlay. HEAL exploits the two-level structure of the overlay — hubs aggregating local model updates, and inter-hub communication reconciling aggregates across the network — to recover the convergence efficiency of classical federated learning while preserving full decentralisation. HEAL is evaluated under fault-free conditions as well as under crash failures and churn, across multiple model architectures and learning tasks.

The fourth contribution is *FLAIR* , an adaptation of HEAL to the constraints of physical wireless networks. In a WiFi environment, the overlay topology cannot be chosen freely: it is shaped by radio range, interference, and the physical proximity of devices. FLAIR draws inspiration from LEACH-style clustering to align the logical aggregation structure with the physical network layer, making decentralised federated learning deployable in realistic wireless settings.

== Organisation of the manuscript

The manuscript is organised into six chapters, reflecting the progressive construction of the framework from its theoretical foundations to its applied extensions.

@chap:model introduces the theoretical model that underpins the entire thesis. It formalises the system assumptions, the network model, and the abstractions used throughout the subsequent chapters.

@chap:overlay surveys the state of the art on overlay networks in peer-to-peer systems. It reviews peer sampling protocols, structured and unstructured overlays, and existing approaches to hub election and topology management, situating the Elevator contribution within the existing landscape.

@chap:elevator presents the Elevator and Lift protocols. It covers the design of the hub election mechanism, the theoretical analysis of the resulting overlay properties, and the experimental evaluation conducted on PeerSim and over a real TCP/IP network.

@chap:learning surveys the state of the art on decentralised learning. It introduces the necessary background on federated learning, and gossip learning, and reviews the main approaches to decentralized aggregation in the learning literature.

@chap:heal presents the HEAL and FLAIR protocols. It describes the architecture of HEAL, its aggregation scheme, and its experimental evaluation across multiple learning tasks and fault scenarios. The chapter then introduces FLAIR and its adaptation to physical wireless network constraints, evaluated on the ns-3 simulator.

// @chap:simulators documents the simulation infrastructure developed
// over the course of this thesis. It describes the engineering
// contributions made to PeerSim, the cluster deployment and
// orchestration pipeline, the metric computation and visualization
// tooling, and the hybrid PeerSim--Gossipy architecture used for
// decentralized learning experiments.