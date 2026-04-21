#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/lovelace:0.3.0": *

#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
// #import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

= Introduction <chap:introduction>

Networks have been a subject of scientific inquiry long before the digital age, from the earliest studies of communication infrastructures to the mathematical foundations of graph theory. With the emergence of the Internet, interest in networked systems grew dramatically, and peer-to-peer networks in particular captured the attention of the research community. Their appeal lies in a set of properties that centralised architectures cannot offer by design: decentralisation, in the sense that no single entity controls the system; equality, in the sense that every participant contributes to and benefits from the network on equal footing; and resilience, in the sense that the absence of a central point of failure makes the system robust to partial outages and adversarial conditions. These properties are not merely theoretical virtues — they reflect a vision of what large-scale distributed systems could be.

On a separate but parallel trajectory, artificial intelligence has been a driving intellectual ambition since the earliest days of computing. From the foundational theoretical work of Turing and McCarthy to the modern era of machine learning and deep learning, the field has undergone successive waves of progress, each expanding the range of tasks that machines can perform and the scale at which they can operate. Today, machine learning models underpin an ever-growing share of the systems that structure daily life, from search engines and recommendation platforms to medical diagnosis and language understanding.

This thesis stands at the intersection of these two research traditions. The central question it addresses is whether the training of machine learning models — an operation that the vast majority of the literature treats as inherently centralised — can instead be performed over a peer-to-peer network, and if so, how far such a system can be pushed in terms of efficiency relative to classical training, degree of decentralisation, security against malicious behaviour, and frugality in resource consumption. These are not independent dimensions: advancing along one axis often creates tension with another, and navigating these trade-offs is a recurring theme throughout the thesis.

This research is not motivated by academic curiosity alone. There are concrete and pressing stakes in the real world. The training of large AI models is today the exclusive province of a small number of organisations with the financial and infrastructural means to operate massive data centres. This concentration creates a structural asymmetry: the entities that shape the most powerful AI systems are few, their decisions are opaque, and the data used to train these systems is centralised in ways that raise serious concerns about privacy and sovereignty. Enabling the decentralised training of AI models would help address each of these issues. It would democratise access to AI technology by allowing communities of participants to collaboratively build models without delegating control to a central authority. It would preserve data privacy by keeping raw data local to each participant, sharing only model updates rather than sensitive observations. And it would distribute the governance of AI systems more broadly, reducing the dependence of individuals, institutions, and nations on a handful of private actors. These are not peripheral concerns: they are at the heart of ongoing debates about the role of AI in society, and this thesis contributes a concrete technical foundation to the tools that could make decentralised AI a practical reality.

== Contributions

This thesis makes four original contributions at the intersection of peer-to-peer networking and decentralised machine learning.

The first contribution is *Elevator*, a decentralised peer sampling protocol that organises nodes into a hub-and-spoke overlay through a lightweight, self-organising random election mechanism. Elevator requires no pre-assigned coordinator, makes no assumption about the application running on top of it, and is designed to tolerate node crashes and churn. By elevating a dynamic subset of nodes to the role of hubs, it introduces a structured aggregation topology into an otherwise flat peer-to-peer network, without sacrificing the decentralised nature of the system.

The second contribution is *Lift*, an extension of Elevator that addresses Byzantine fault tolerance. Where Elevator assumes that participants follow the protocol honestly, Lift introduces an analysis of the protocol's behaviour under Byzantine attacks and equips it with a defence mechanism that limits the influence of malicious participants on the hub election process. Lift strengthens the security guarantees of the entire protocol stack built on top of Elevator.

The third contribution is *HEAL*, a decentralised federated learning protocol built directly on top of the Elevator overlay. HEAL exploits the two-level structure of the overlay — hubs aggregating local model updates, and inter-hub communication reconciling aggregates across the network — to recover the convergence efficiency of classical federated learning while preserving full decentralisation. HEAL is evaluated under fault-free conditions as well as under crash failures and churn, across multiple model architectures and learning tasks.

The fourth contribution is *FLAIR* , an adaptation of HEAL to the constraints of physical wireless networks. In a WiFi environment, the overlay topology cannot be chosen freely: it is shaped by radio range, interference, and the physical proximity of devices. FLAIR draws inspiration from LEACH-style clustering to align the logical aggregation structure with the physical network layer, making decentralised federated learning deployable in realistic wireless settings.

== Organisation of the manuscript

The manuscript is organised into seven chapters, reflecting the progressive construction of the framework from its theoretical foundations to its applied extensions.

@chap:model introduces the theoretical model that underpins the entire thesis. It formalises the system assumptions, the network model, and the abstractions used throughout the subsequent chapters.

@chap:overlay surveys the state of the art on overlay networks in peer-to-peer systems. It reviews peer sampling protocols, structured and unstructured overlays, and existing approaches to hub election and topology management, situating the Elevator contribution within the existing landscape.

@chap:elevator presents the Elevator and Lift protocols. It covers the design of the hub election mechanism, the theoretical analysis of the resulting overlay properties, and the experimental evaluation conducted on PeerSim and over a real TCP/IP network.

@chap:learning surveys the state of the art on machine learning and decentralised learning. It introduces the necessary background on supervised learning, federated learning, and gossip learning, and reviews the main approaches to decentralised aggregation in the learning literature.

@chap:heal presents the HEAL and FLAIR protocols. It describes the architecture of HEAL, its aggregation scheme, and its experimental evaluation across multiple learning tasks and fault scenarios. The chapter then introduces FLAIR and its adaptation to physical wireless network constraints, evaluated on the ns-3 simulator.
