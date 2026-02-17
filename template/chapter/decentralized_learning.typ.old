#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/lovelace:0.3.0": *

#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
#show: show-theorion

= Decentralized Learning <chap:decentralized_learning>

== History and use cases
// One of the earliest and most fundamental pillars underlying machine learning is the concept of the *algorithm*. As early as the ninth century, the work of the Persian mathematician Al-Khwarizmi introduced systematic and well-defined computational procedures for solving mathematical problems. Although these methods did not involve learning from data, they established a crucial principle: problems can be solved through formal, repeatable, and finite sequences of operations. This algorithmic paradigm laid the groundwork for all subsequent developments in computation and automated reasoning. At this stage, intelligence—whether human or artificial—was understood as the execution of predefined rules rather than the ability to adapt or learn. Nevertheless, the abstraction of problem-solving into algorithmic steps represented a decisive shift toward mechanized reasoning. 
// Modern machine learning inherits much of its theoretical backbone from statistical learning theory, including concepts such as empirical risk minimization, bias–variance trade-offs, and generalization error. Without these statistical foundations, learning from data would remain limited to curve fitting, lacking guarantees about predictive performance on unseen data.
// Foundational contributions by Bayes @bayes1763lii, Fisher, and Neyman–Pearson established the principles of statistical inference, emphasizing generalization beyond observed samples.
The idea of creating artificial systems capable of exhibiting intelligent behavior has long fascinated humanity. Well before the advent of modern computers, philosophers, engineers, and mathematicians speculated about non-human forms of intelligence, ranging from mechanical automata to abstract reasoning machines. The contemporary notion of *machine learning* is the result of a long conceptual evolution, rooted in mathematics, statistics, and algorithmic thinking, rather than an abrupt technological breakthrough. During the Renaissance and early modern period, scientific inquiry increasingly relied on empirical observations to construct mathematical models of natural phenomena. A prominent example is the development of the method of least squares @legendre1806nouvelles, in the context of astronomical observations. This method enabled scientists to derive model parameters directly from noisy observational data, notably for predicting the trajectories of stellar objects. While this approach still did not constitute learning in the modern sense, it introduced a critical idea: models can be *estimated* from data by minimizing an error criterion. Linear regression, as a direct consequence, represents one of the earliest examples of data-driven modeling. The model structure is assumed a priori, but its parameters are inferred from empirical measurements. This marks a conceptual transition from purely deductive reasoning to inductive inference based on data. The formalization of probability theory between the eighteenth and twentieth centuries further strengthened this data-driven perspective. Bayes' seminal work @bayes1763lii introduced a principled framework for reasoning under uncertainty, enabling the incorporation of prior knowledge and its systematic update in light of new observations. The introduction of logistic regression by Berkson @berkson1944application provided an early example of probabilistic classification. In parallel, the work of Markov @марков1906распространение on stochastic processes established a mathematical framework for modeling temporal dependencies through chains of random variables, laying the foundations for sequential and dynamic models. In parallel, the mid-twentieth century witnessed the emergence of cybernetics and control theory, notably through the work of Wiener. These disciplines introduced the concept of adaptive systems governed by feedback loops, capable of adjusting their behavior in response to environmental changes. Unlike static algorithms, such systems continuously update their internal states to maintain stability or optimize performance.

The term *machine learning* itself was popularized in the late 1950s by Arthur Samuel, who described it as the ability of machines to improve their performance on a task through experience rather than explicit programming. From the 1970s onward, advances in computational power, data availability, and algorithmic design led to the rapid development of learning algorithms, particularly in pattern recognition and artificial intelligence. Unlike classical algorithms, machine learning systems are characterized by their ability to automatically infer patterns, representations, or decision rules from data. This paradigm shift marked a departure from hand-crafted rules toward models that adapt based on empirical evidence.

Learning through trial and error constitutes a fundamental mechanism by which humans and animals acquire new skills and adapt to their environment. Rather than relying on explicit and complete models of the world, biological learning systems progressively adjust their behavior based on feedback obtained from interaction and experience. This observation naturally motivates the design of artificial systems capable of learning from data, especially in settings where explicit modeling is infeasible or prohibitively complex.

Indeed, many real-world systems are characterized by high dimensionality, non-linearity, and partial observability, rendering analytical modeling impractical. In such contexts, approximating an unknown function directly from data is often sufficient to achieve satisfactory performance, even in the absence of a precise underlying model. Machine learning embraces this paradigm by prioritizing empirical performance and adaptability over explicit symbolic descriptions.

Subsequent decades saw the rise of neural networks, kernel methods, and, more recently, deep learning architectures. These approaches dramatically expanded the expressive capacity of learning models, enabling them to tackle increasingly complex tasks. However, most early and contemporary machine learning frameworks implicitly assume centralized data collection and computation.

As data generation becomes increasingly distributed across heterogeneous devices and networks, this assumption is progressively challenged. This observation motivates the study of distributed and decentralized learning paradigms, which aim to preserve the core principles of machine learning while adapting them to large-scale, networked, and often unreliable environments.

Learning in natural systems rarely occurs in isolation. Humans acquire knowledge through social interaction, collaboration, and the exchange of information. At a larger scale, scientific research itself can be viewed as a collective and decentralized learning process, where knowledge emerges from the aggregation of contributions produced by many independent agents. This collective dimension of learning provides an additional motivation for studying learning paradigms that go beyond isolated, centralized settings.

== Core concepts

// machine learning
Machine learning can be formalized as the problem of inferring a predictive model from data, such that the model generalizes beyond the observed samples. This section introduces a general mathematical framework encompassing most learning paradigms used in practice.

// #definition[
//   Let $X$ denote an input space and ${Y}$ an output space. In supervised learning, data are assumed to be drawn from an unknown joint probability distribution $\mathcal{D}$ over $\mathcal{X} \times \mathcal{Y}$.
// ]

=== Personalized Learning

== Federated Learning

=== Horizontal Federated Learning

=== Vertical Federated Learning

=== Hierarchical Federated Learning

=== Blockchain-based Federated Learning

=== Asynchronous Federated Learning

== Gossip Learning

== Hybrid Approaches

== Metrics