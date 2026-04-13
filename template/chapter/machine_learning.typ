#import "@preview/cetz:0.4.0": canvas, draw

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/lovelace:0.3.0": *

#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
#show: show-theorion

= From Centralized to Decentralized Machine Learning <chap:learning>

Artificial intelligence and machine learning have become central drivers of
technological innovation over the past decade, transforming domains ranging from
healthcare and finance to autonomous systems and natural language processing.
The remarkable progress achieved in these fields has been largely fueled by the
availability of massive datasets and the computational power of centralized
infrastructures, where data is collected, stored, and processed in a single
location. However, despite this rapid advancement, surprisingly little attention
has been devoted to the question of decentralization. Most state-of-the-art
approaches implicitly assume the existence of a central authority capable of
aggregating data and coordinating the learning process, an assumption that is
increasingly at odds with the reality of modern distributed systems, privacy
regulations, and the sheer scale of connected devices. This chapter examines the
shift from centralized to decentralized machine learning, exploring the
motivations, challenges, and state-of-the-art approaches that define this
emerging and critical research direction.

== Machine Learning

Before discussing *decentralized learning*, it is essential to first establish
a clear understanding of classical *machine learning*.
In this section, we provide the fundamental definitions and concepts of machine
learning, which form the basis for more advanced distributed learning paradigms.
The definitions and concepts presented here are drawn from the foundational
works of Tom Mitchell @learning1997tom and the Deep Learning book
@Goodfellow-et-al-2016, two references in the field.

// Machine learning is the art of teaching computers to recognize patterns in data so they can make predictions or decisions, without being explicitly programmed with every rule.

We start by laying the groundwork with a formal definition of learning, as introduced by Tom Mitchell, which will serve as the backbone of all subsequent concepts

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
to deep convolutional networks. In the context of HEAL, it provides a more demanding evaluation
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

== Learning Paradigms
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
and better utilises available compute. However, it requires the model
architecture to be explicitly designed or adapted for distributed tensor
operations, making it harder to implement in practice and not universally
applicable.

At the hardware level, Tensor Processing Units (TPUs) embody a related
philosophy: they are specialised accelerators built around a systolic array
architecture optimised for large-scale matrix and tensor computations, and are
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
that maximises its expected cumulative reward, while the dynamics of the
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
dataset can substantially reduce training cost and improve generalisation.

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
optimisation process, typically with a smaller learning rate. Depending on
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
techniques per se, they are often complementary to federated and decentralised
learning systems. A common pattern, known as personalised federated learning, is to train a
global model in a federated manner and subsequently fine-tune it locally on
each node using its private data, thereby adapting the shared representations
to each node's local data distribution @fallah2020personalized.

=== Towards decentralisation

The paradigms surveyed in this section --- ensemble learning, data parallelism, model parallelism, multi-agent reinforcement learning, and transfer learning ---
each offer distinct strategies for improving the efficiency, scalability, or
generalisation of learned models. However, they all retain, in one form or
another, a fundamentally centralised assumption: ensemble methods aggregate models trained
using a common dataset; data parallelism and model
parallelism presuppose that the full training dataset is available and can be
freely distributed across workers; MARL agents evolve within a shared
environment governed by a single dynamics model; and transfer learning relies
on a globally pretrained model whose representations are assumed to be
transferable. In all these settings, centralised control --- over the data,
the environment, or the model --- remains implicit.

Decentralised learning departs from this assumption along a fundamentally
different dimension. Rather than distributing computation over centrally
held data, it considers settings in which each node or agent holds its own
private dataset, which is never shared or aggregated at a central location.
The learning problem must therefore be solved collaboratively across nodes
whose data may be heterogeneous, whose communication is constrained, and
whose privacy must be preserved. This shift from centralised to decentralised
data ownership defines the core challenge addressed in the remainder of this
chapter.

== Decentralized Learning

Decentralized learning naturally emerges at the intersection of peer-to-peer
systems and machine learning. From a distributed systems perspective, it can
be seen as a direct extension of decentralized computation: instead of
collaboratively computing a single numerical value or global statistic, each
node maintains a local model and a local dataset, and participates in the
learning process exclusively through peer-to-peer interactions, without
relying on any central coordinator or shared memory.

From a machine learning perspective, decentralized learning can be viewed as
a relaxation of the centralisation assumption that underlies most classical
learning paradigms. Rather than moving data to a central location where
computation is performed, decentralized learning operates under the constraint
that data remain local to each node. Learning is therefore achieved by moving
models --- or model updates --- across nodes, rather than moving the data
themselves. In this sense, it inverts the classical data parallelism paradigm:
instead of distributing centrally held data across workers, it distributes
computation across nodes whose data are inherently local and never aggregated.

#figure(
  canvas(length: 1.2cm, {
    import draw: *

    // --- Circles ---
circle((2.8, 0), radius: 3.8,
  fill: rgb("#1D9E75").lighten(75%).transparentize(30%),
  stroke: rgb("#1D9E75") + 0.5pt)
circle((6.2, 0), radius: 3.8,
  fill: rgb("#7F77DD").lighten(75%).transparentize(30%),
  stroke: rgb("#7F77DD") + 0.5pt)
  
    // --- Left: Machine learning ---
    content((1.0, 1.4), text(size: 10pt, weight: "bold")[Machine learning])
    content((1.0, 0.7), text(size: 8.5pt)[Supervised learning])
    content((1.0, 0.1), text(size: 8.5pt)[Optimization])
    content((1.0, -0.5), text(size: 8.5pt)[Model training])

    // --- Right: Peer-to-peer systems ---
    content((8.0, 1.4), text(size: 10pt, weight: "bold")[Peer-to-peer systems])
    content((8.0, 0.7), text(size: 8.5pt)[Distributed computation])
    content((8.0, 0.1), text(size: 8.5pt)[No central coordinator])
    content((8.0, -0.5), text(size: 8.5pt)[Local interactions])
    content((8.0, -1.1), text(size: 8.5pt)[Fault tolerance])

    // --- Intersection: Decentralized learning ---
    content((4.5, 1.4), text(size: 10pt, weight: "bold")[Decentralized])
    content((4.5, 0.7), text(size: 10pt, weight: "bold")[learning])
    content((4.5, 0.0), text(size: 8.5pt)[Local data])
    content((4.5, -0.6), text(size: 8.5pt)[Model exchange])
  }),
  caption: [
    Decentralized learning at the intersection of machine learning and
    peer-to-peer systems.
  ],
)

This framework also bears a conceptual resemblance to ensemble learning: just
as ensemble methods combine the predictions of multiple locally trained models
to form a stronger predictor (see @def:ensemble-learning), decentralized learning
repeatedly exchanges and aggregates local model updates across nodes, enabling
a collection of autonomous agents to collectively optimize a shared learning
objective without any node having access to the full dataset.

==== Horizontal and vertical decentralized learning

Decentralized learning approaches can be broadly categorized into two
settings, commonly referred to as horizontal and vertical, depending on
how data are partitioned across nodes @zhang2021survey.

In horizontal decentralized learning, all nodes share the same feature
space but hold different subsets of data instances. Each node trains a
local model on its own dataset, and learning proceeds by combining these
local models through parameter-wise aggregation --- for instance by
averaging corresponding parameters across nodes. This setting is
particularly well suited to peer-to-peer and federated environments,
where data are naturally distributed across participants but follow a
common schema.

In vertical decentralized learning, nodes observe the same set of data
instances but with disjoint feature subsets. No single node has access
to the full feature vector of an instance; learning therefore requires
exchanging intermediate representations or partial gradients computed
on complementary feature subsets. This setting involves stronger
coordination constraints and more complex communication patterns than
the horizontal case.


#figure(
  canvas(length: 1.0cm, {
    import draw: *

    // --- Parameters ---
    let cell-w = 1.6
    let cell-h = 0.9
    let n-feat = 5
    let n-inst = 3

    // ================================================================
    // HORIZONTAL FEDERATED LEARNING (left)
    // ================================================================

    // Title
    content((3.5, 1.5), text(size: 10pt, weight: "bold")[Horizontal federated learning])

    // Column headers: features
    for j in range(n-feat) {
      content((j * cell-w + 0.8, 0.7),
        text(size: 7.5pt)[$x^((#(j+1)))$])
    }

    // Row labels + cells
    let h-colors = (
      rgb("#1D9E75").lighten(70%),
      rgb("#1D9E75").lighten(55%),
      rgb("#1D9E75").lighten(40%),
    )
    let node-labels = ("Node 1", "Node 2", "Node 3")

    for i in range(n-inst) {
      let col = h-colors.at(i)

      // Node label on first row of each node
        content((-0.5, -i * cell-h),
          text(size: 7pt)[#node-labels.at(i)])

      for j in range(n-feat) {
        rect(
          (j * cell-w, -i * cell-h - cell-h * 0.5),
          (j * cell-w + cell-w - 0.1, -i * cell-h + cell-h * 0.5 - 0.05),
          fill: col,
          stroke: white + 1pt,
          radius: 0.05,
        )
      }
    }

    // ================================================================
    // VERTICAL FEDERATED LEARNING (right, offset)
    // ================================================================

    let x-off = n-feat * cell-w + 2.0
    let n-feat-v = 3
    let n-inst-v = 4

    content((x-off + n-feat-v * cell-w * 0.5, 1.5),
      text(size: 10pt, weight: "bold")[Vertical federated learning])

    // Node color per feature column
    let v-colors = (
      rgb("#7F77DD").lighten(60%),
      rgb("#7F77DD").lighten(40%),
      rgb("#7F77DD").lighten(20%),
    )
    let v-node-labels = ("Node 1", "Node 2", "Node 3")

    // Column headers with node labels
    for j in range(n-feat-v) {
      content((x-off + j * cell-w + 0.8, 0.7),
        text(size: 7.5pt)[#v-node-labels.at(j)])
    }

    // Row labels: instances
    for i in range(n-inst-v) {
      content((x-off - 0.7, -i * cell-h),
        text(size: 7pt)[$z^((#(i+1)))$])
    }

    for i in range(n-inst-v) {
      for j in range(n-feat-v) {
        rect(
          (x-off + j * cell-w, -i * cell-h - cell-h * 0.5),
          (x-off + j * cell-w + cell-w - 0.1, -i * cell-h + cell-h * 0.5 - 0.05),
          fill: v-colors.at(j),
          stroke: white + 1pt,
          radius: 0.05,
        )
      }
    }


  }),
  caption: [
    Horizontal federated learning (left): nodes share the same feature
    space but hold disjoint sets of instances. Vertical federated learning (right):
    nodes observe the same instances but hold disjoint feature subsets.
  ],
)


In this thesis, we focus exclusively on *horizontal decentralized
learning*, which is by far the most prevalent setting in the literature
and aligns naturally with peer-to-peer systems where nodes independently
collect data instances under a shared feature schema.

=== Model

Having established the conceptual foundations of decentralized learning ---
its position at the intersection of machine learning and peer-to-peer systems,
its distinction from centralized and distributed paradigms, and its primary
setting of interest --- we now turn to a formal treatment of the problem.

==== Assumptions

The decentralized learning system inherits the assumptions established in
the peer-to-peer model of @chap:model. In particular, we assume that all
nodes are identical in terms of computational capabilities and memory
(see @chap:model), that communication channels are reliable and
instantaneous, and that message transmission incurs no latency or
bandwidth constraints.

These assumptions extend naturally to the machine learning components
introduced in @def:dl-node. Specifically:

- *Model size*: the size of the local model $f_(theta_i)$ — that is,
  the number of parameters $p = |theta_i|$ — is assumed to be identical
  across all nodes and imposes no memory or transmission constraint.
  Model exchanges between nodes are therefore treated as instantaneous,
  regardless of the number of parameters.

- *Training time*: the time required to perform a local model update,
  such as computing a gradient step or aggregating received parameters,
  is assumed to be negligible. Local learning computations are therefore
  considered instantaneous, consistently with the abstract execution
  model of @def:node-system.

These assumptions allow us to isolate the algorithmic and theoretical
properties of decentralized learning protocols from hardware and network
effects, and to focus on the convergence and communication behavior of
the system.

==== Adversarial models

In addition to the network-level failure models introduced in
@chap:model --- crash failures and Byzantine failures at the
communication layer --- decentralized learning systems are exposed
to a second class of perturbations that operate at the learning
level. Even when the underlying network functions correctly, the
aggregation process can be compromised by adversarial behaviors of
participating nodes with respect to their model updates.

Several types of adversarial actions are commonly considered in the
literature @rodriguez2023survey:

- *Privacy attacks*: a node attempts to infer or reconstruct the
  private data of other nodes by analyzing received model updates @biswas2024low.

- *Poisoning attacks*: a node intentionally manipulates its local
  model updates to degrade the performance of the global model @pham2024data.

- *Backdoor attacks*: a malicious node injects hidden triggers or
  patterns into the model during training, aiming to influence the
  model's behavior on specific inputs while preserving normal
  performance on clean data @bagdasaryan2020backdoor.

- *Free-riding*: a node benefits from the aggregated models of
  others without contributing meaningful updates, for instance by
  sending stale or null parameters @rodriguez2023survey.

These behaviors are orthogonal to the crash and Byzantine failure
models of @chap:model: a node may be honest at the network level
--- forwarding messages correctly and remaining available --- while
behaving adversarially at the learning level. Conversely, a
Byzantine node in the network sense may also corrupt model updates.

In this thesis, we do not study these adversarial behaviors. We
assume that all nodes are honest and follow the prescribed learning
protocol correctly. This allows us to focus on the convergence and
dynamic properties of decentralized learning protocols under the
assumption of fully cooperative participants, and leave the study
of robustness to adversarial settings as a direction for future work.

==== Abstract learning node

Building on the abstract node model introduced in @def:node-entity and
@def:node-system, we now define the notion of an *abstract learning node* by enriching the general peer-to-peer node with machine learning components.

#definition(title: "Learning Node")[
A *learning node* is an abstract node (see @def:node-entity)
whose local state $s_i$ is extended with two additional components:

1. a *local dataset* $cal(D)_i = {(x_j, y_j)}_(j=1)^(n_i)$, where
   $x_j in RR^d$ are feature vectors and $y_j$ are labels. The dataset
   is private: it is stored exclusively on node $i$ and is never
   transmitted to other nodes.

2. a *local model* $f_(theta_i) : RR^d -> cal(Y)$, parameterized by
   $theta_i in RR^p$, which represents the current state of the model
   maintained by node $i$.

The local state of node $i$ is thus $s_i = (cal(D)_i, theta_i, P(i))$,
where $P(i)$ denotes its partial view of the network (see @def:partial-view).

The dataset $cal(D)_i$ is a static component of the local state: it does
not change across protocol cycles. The model parameters $theta_i$, by
contrast, constitute the dynamic component of the state and are updated
at each protocol step.
] <def:dl-node>

#remark[
  From a multi-agent systems perspective @marl-book, each decentralized learning node can be viewed as an autonomous agent: its local state $s_i$ corresponds to the agent's internal memory, its neighbourhood $P(i)$ and the evolving overlay topology constitute its local environment, and the empirical loss defines the objective to be minimised. Although this multi-agent framing establishes a natural conceptual bridge to cooperative reinforcement learning and decentralized control, formalising our nodes as agents within a multi-agent learning framework lies explicitly outside the scope of this work.
]

// #remark[
// The local dataset $cal(D)_i$ can be seen as a global parameter of the
// node in the sense of @def:node-system: it is fixed at initialization
// and conditions all subsequent computations, but does not itself evolve
// as a result of protocol execution.
// ]

==== Decentralized learning objective

Having defined the learning node, we can now state the
global learning objective. Each learning node $i$ defines a local empirical loss $L_i (theta)$ (see @def:loss-function).

The global objective of the decentralized learning system is to
collectively minimise the aggregate loss over all nodes, in the sense
of @def:global-objective:
$
min_(theta in RR^p) L_"global" (theta), quad
L_"global" (theta) = 1/N sum_(i=1)^N L_i (theta),
$

#remark[
No single node has access to the full loss $L_"global" (theta)$, since
$cal(D)_i$ is local to node $i$. The minimisation must therefore be
achieved collaboratively, through the exchange of model parameters
$theta_i$ or gradients $nabla L_i (theta_i)$ between
neighbouring nodes, without any node ever observing the data of another.
]

Building on the notion of convergence introduced in @def:convergence,
we say that a decentralized learning system has converged if the global
loss falls below a prescribed threshold $epsilon > 0$.

#definition(title: "Convergence of Decentralized Learning")[
A decentralized learning system is said to have *converged* if there
exists a time $T >= 0$ such that for all $t >= T$:
$
L_"global" (S(t)) = sum_(i=1)^N alpha_i L_i (theta_i (t)) <= epsilon,
$
where $S(t) = (theta_i (t))_(i in V)$ is the global state of the system
at time $t$ (see @def:global-system), and $epsilon > 0$ is a
convergence threshold fixed a priori.
] <def:dl-convergence>

#remark[
In practice, exact convergence in the sense of @def:dl-convergence is
rarely studied directly. Instead, one typically fixes a time horizon
$T$ and evaluates the global loss $L_"global" (S(T))$ achieved after $T$
protocol cycles. This allows one to compare decentralized learning
protocols in terms of their convergence speed: a protocol that reaches
a lower loss within the same number of cycles is considered more
efficient.
]

==== Performance metrics

While convergence in the sense of @def:dl-convergence is defined in
terms of the global loss $L_"global"$, it is useful in practice to
complement this criterion with a more interpretable metric. Building
on @def:accuracy, we define the global accuracy of the decentralized
learning system as the average accuracy across all nodes, evaluated
on their respective local test datasets.

#definition(title: "Global accuracy")[
Let $cal(D)_i^("test")$ denote the local test dataset of node $i$,
and let $hat(y)_j = f_(theta_i)(x_j)$ be the predicted label for
input $x_j$. The *local accuracy* of node $i$ at time $t$ is:
$
"Acc"_i (t) = 1/(|cal(D)_i^("test")|)
sum_((x_j, y_j) in cal(D)_i^("test"))
bb(1){hat(y)_j = y_j}.
$

The *global accuracy* of the system at time $t$ is the average local
accuracy across all nodes:
$
"Acc"(t) = 1/N sum_(i=1)^N "Acc"_i (t).
$
] <def:global-accuracy>

We evaluate the performance of decentralized learning protocols
through two complementary criteria.

- *Final accuracy*: the global accuracy $"Acc"(T)$ measured after a
  fixed number of protocol cycles $T$. This criterion captures the
  asymptotic quality of the learned model and allows direct comparison
  between protocols under a fixed computational budget.

- *Time to accuracy*: the number of protocol cycles required for the
  global accuracy to reach a predetermined threshold $tau in (0, 1)$,
  formally defined as:
  $
  T_tau = min { t >= 0 | "Acc"(t) >= tau }.
  $
  This criterion measures the convergence speed of the protocol,
  independently of its final performance level.

#remark[
Final accuracy and time to accuracy are complementary: a protocol
may converge quickly to a moderate accuracy (low $T_tau$, moderate
$"Acc"(T)$), while another may converge more slowly but ultimately
reach a higher accuracy. Both criteria are therefore necessary to
fully characterize the behavior of a decentralized learning protocol.
]

Having defined the formal framework of the decentralized learning
system --- its nodes, objective, convergence criterion, and performance
metrics --- we now turn to the two central design questions that
govern the behavior of any decentralized learning protocol: how local
models should be combined, and which nodes should communicate with
whom.

=== Aggregation operator

A first question in decentralized learning concerns the aggregation
operator itself: given that nodes have exchanged their local model
parameters, how should these be combined into an improved model ?
As established in @def:dl-node, each node $i$ maintains a local model
$f_(theta_i)$ trained exclusively on its private dataset $cal(D)_i$,
and since the amount of data available at a single node is generally
insufficient to achieve low loss, collaboration between nodes is
required to leverage the information distributed across the network.

In horizontal decentralized learning (see @def:dl-node), all nodes
share the same feature space and parameter space $RR^p$, which makes
parameter-wise aggregation well-defined: the parameters of multiple
local models can be directly combined.


Several aggregation operators have been proposed in the literature,
ranging from weighted averaging to more sophisticated strategies based
on gradient correction or momentum. In this work, we focus on the
simplest and most widely studied: *model averaging*, in which nodes
exchange their local parameters and compute their arithmetic mean
@zinkevich2010parallelized. Despite its simplicity, this operator
forms the basis of most decentralized and federated learning algorithms
and admits strong theoretical guarantees under standard assumptions.

#definition(title: "Average SGD")[
At each iteration $t$, every node $i$ performs a local stochastic
gradient descent step on its local objective $L_i$ (see
@def:loss-function):
$
theta_(t+1/2) = theta_t - eta nabla_theta L_i (theta_t),
$

After a synchronization step, the local models are aggregated by
averaging:
$
theta_(t+1) = 1/N sum_(i=1)^N theta_(t+1/2).
$
] <def:average-sgd>

#remark[Under standard regularity assumptions on $L_i$ and IID data
distribution across nodes, Average SGD converges to the same optimum
as centralized SGD @lian2017can.
]

Two design choices govern the practical behavior of Average SGD. The
first is *aggregation frequency*: nodes may aggregate at every
iteration or after several local gradient steps, trading off
communication cost against convergence speed. The second is the
*synchronization scope*: rather than averaging model parameters,
an alternative is to aggregate gradients directly --- nodes exchange
$nabla L_i (theta_i (t))$, average them, and apply the result to a
shared model. This is equivalent to parameter averaging when models
are synchronized at every step, but the two strategies diverge when
local updates accumulate over several steps before aggregation. In
this work, we restrict our study to parameter-based aggregation for
simplicity.

The statistical properties of local datasets also play a crucial role
in the convergence behavior of Average SGD. Under IID distributions,
model averaging performs comparably to centralized training. In the
non-IID setting, however, local data distributions may differ
significantly across nodes, causing local models to drift in different
directions --- a phenomenon known as *client drift* @karimireddy2020scaffold.
In such cases, arithmetic averaging may no longer be appropriate, and
more robust aggregation operators have been proposed, such as geometric
median-based aggregation @blanchard2017machine, which is less sensitive
to outlier models induced by heterogeneous data distributions. Since
this thesis focuses on the interaction between aggregation and network
dynamics, we operate under the IID assumption throughout, and leave
the non-IID setting as a direction for future work.

=== Topology-driven aggregation

A central design question in decentralized learning is determining which
nodes should exchange and aggregate their models, and according to what
structure. While the aggregation operator --- here Average SGD (see
@def:average-sgd) --- defines *how* models are combined, the
collaboration topology defines *who* communicates with whom. 
// Individual nodes typically possess only a limited and potentially biased view of the overall data distribution. Aggregation across nodes is therefore essential to enable convergence toward a model that reflects the collective knowledge of the network.

// Aggregation strategies differ in the network structures and communication patterns they assume. 

The choice of topology, ranging from centralized star-shaped architectures to fully decentralized peer-to-peer overlays, directly impacts convergence speed, robustness to failures, scalability, and resilience to churn. Understanding these trade-offs is therefore essential for the design and analysis of decentralized learning protocols.

Here, we look at the main aggregation strategies encountered in the literature, organized according to their underlying network topologies and coordination mechanisms. We progressively move from centralized and hierarchical approaches, such as Federated Learning and its multi-server extensions, to fully decentralized schemes based on gossip and local interactions.

We focus on aggregation strategies defined by network topology and communication patterns. Orthogonal aspects such as robust aggregation rules, privacy mechanisms, or incentive schemes are not discussed.

==== Federated learning

Federated learning (FL) @mcmahan2017communication is a collaborative learning paradigm in which
multiple clients train a shared model without exchanging their raw data.
Each client performs local training on its private dataset and
communicates only model parameters to a central coordinating entity,
referred to as the server. The paradigm was introduced to address
privacy, bandwidth, and data ownership constraints in large-scale
systems such as mobile devices and edge computing environments.

#figure(
  diagram(
    // --- Server ---
    node((1, 0),
      [*Server*\ global model $theta^((t))$],
      shape: rect,
      fill: blue.lighten(70%),
      stroke: blue.darken(20%) + 0.8pt,
      name: <server>),

    // --- Clients ---
    node((0, 2),
      [*Client 1*\ dataset $cal(D)_1$\ model $theta_1^((t))$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c1>),
    node((1, 2),
      [*Client 2*\ dataset $cal(D)_2$\ model $theta_2^((t))$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c2>),
    node((2, 2),
      [*Client 3*\ dataset $cal(D)_3$\ model $theta_3^((t))$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c3>),

    // --- Broadcast: server → clients ---
    edge(<server>, <c1>,
      marks: "<->",
      stroke: 1pt),
    edge(<server>, <c2>,
      marks: "<->",
    stroke: 1pt),
    edge(<server>, <c3>,
      marks: "<->",
    stroke: 1pt),
  ),
  caption: [
    Federated learning with a star topology: the server broadcasts
    $theta^((t))$, clients train locally on $cal(D)_i$, and return
    updated parameters $theta_i^((t+1))$ for aggregation.
  ],
)
The FedAvg algorithm @mcmahan2017communication generalizes
Average SGD (see @def:average-sgd) by allowing each client to perform
$E >= 1$ local gradient steps between communication rounds, rather
than a single step. This reduces communication frequency at the cost
of introducing a potential divergence between local and global
objectives when $E$ is large.

From a network perspective, federated learning relies on a star-shaped
topology: a single server communicates with all clients, collects their
local parameters, aggregates them --- typically as a weighted average
$theta^((t+1)) = sum_(i=1)^N w_i theta_i^((t))$ with
$w_i = n_i \/ sum_j n_j$ --- and broadcasts the updated global model
back to all participants.

While this architecture enables efficient coordination and simplifies
convergence analysis, it introduces a strong centralization point.
Although federated learning avoids centralizing data, it does not
eliminate central control: the server must be reliable and trusted,
and its failure or compromise may disrupt the entire learning process.
// This limitation motivates the development of fully decentralized
// approaches, in which no central coordinator is assumed.

#figure(
pseudocode-list(booktabs: true)[
  - *Input*: number of clients $N$, local datasets ${cal(D)_1, dots, cal(D)_N}$,
    learning rate $eta$, communication rounds $T$,
    local steps per round $E$,
    weights $w_i = n_i \/ sum_j n_j$,
    initial model $theta^((0))$
  + *for* $t = 0$ *to* $T - 1$ *do*
    + server broadcasts $theta^((t))$ to all clients
    + *for each* client $i$ *in parallel do*
      + $theta_i^((t, 0)) arrow.l theta^((t))$
      + *for* $e = 1$ *to* $E$ *do*
        + sample minibatch $xi_i subset cal(D)_i$
        + $theta_i^((t, e)) arrow.l theta_i^((t, e-1)) - eta nabla_theta L_i (theta_i^((t, e-1)) ; xi_i)$
      + *end for*
      + send $theta_i^((t, E))$ to server
    + *end for*
    + server aggregates:
      + $theta^((t+1)) arrow.l sum_(i=1)^N w_i theta_i^((t, E))$
  + *end for*
  + *return* $theta^((T))$
  ],
  caption: [Federated averaging (FedAvg) @mcmahan2017communication.],
) <algo:fedavg>

==== Multi-star federated learning

Multi-star federated learning extends the classical federated learning
paradigm by replacing the single central server with multiple
coordinating servers. Each server acts as a local aggregation point
for a subset of clients, forming multiple star-shaped subnetworks that
operate in parallel. This architecture is motivated by scalability,
fault tolerance, and geographical distribution --- as illustrated by
Gaia @hsieh2017gaia, a system designed for geographically distributed
machine learning in which workers send their updates to an assigned
regional server, and servers synchronize across geographical zones.
It is commonly encountered in large-scale industrial deployments where
a single server would become a performance bottleneck.

In a multi-star setting, clients are assigned to one or more servers
and perform local training in the same way as in standard federated
learning. Each server collects the updated parameters from its
associated clients and performs a local aggregation, for instance
using FedAvg (see @algo:fedavg). Compared to the single-star topology,
this reduces communication load and latency, and allows the system to
scale to a much larger number of clients.


#figure(
  diagram(
    spacing: (18mm, 14mm),
    node-stroke: 0.8pt,
    edge-stroke: 1pt,

    // --- Servers ---
    node((0, 0),
      [*Server 1*\ $theta^((t))_1$],
      shape: rect,
      fill: blue.lighten(70%),
      stroke: blue.darken(20%) + 0.8pt,
      name: <s1>),
    node((2, 0),
      [*Server 2*\ $theta^((t))_2$],
      shape: rect,
      fill: blue.lighten(70%),
      stroke: blue.darken(20%) + 0.8pt,
      name: <s2>),
    node((1, 1.5),
      [*Server 3*\ $theta^((t))_3$],
      shape: rect,
      fill: blue.lighten(70%),
      stroke: blue.darken(20%) + 0.8pt,
      name: <s3>),

    // --- Clients of server 1 ---
    node((-1, -1.5),
      [*Client 1*\ $cal(D)_1$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c11>),
    node((0, -1.5),
      [*Client 2*\ $cal(D)_2$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c12>),

    // --- Clients of server 2 ---
    node((2, -1.5),
      [*Client 3*\ $cal(D)_3$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c21>),
    node((3, -1.5),
      [*Client 4*\ $cal(D)_4$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c22>),

    // --- Clients of server 3 ---
    node((0.2, 3),
      [*Client 5*\ $cal(D)_5$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c31>),
    node((1.8, 3),
      [*Client 6*\ $cal(D)_6$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c32>),

    // --- Server clique ---
    edge(<s1>, <s2>, marks: "<->"),
    edge(<s2>, <s3>, marks: "<->"),
    edge(<s1>, <s3>, marks: "<->"),

    // --- Server 1 ↔ clients ---
    edge(<s1>, <c11>, marks: "<->"),
    edge(<s1>, <c12>, marks: "<->"),

    // --- Server 2 ↔ clients ---
    edge(<s2>, <c21>, marks: "<->"),
    edge(<s2>, <c22>, marks: "<->"),

    // --- Server 3 ↔ clients ---
    edge(<s3>, <c31>, marks: "<->"),
    edge(<s3>, <c32>, marks: "<->"),
  ),
  caption: [
    Multi-star federated learning: three servers form a fully connected
    clique for cross-server synchronization, each coordinating a local
    star of two clients. Clients communicate only with their assigned
    server; servers exchange aggregated models with one another.
  ],
)

However, the presence of multiple servers raises fundamental design
questions regarding global consistency and convergence. In particular,
servers must be synchronized to prevent model drift between different
regions of the network. Several synchronization strategies can be
considered:

- *Server-level aggregation*: servers periodically exchange their
  aggregated models and perform a second-level aggregation
  @hsieh2017gaia.
- *Client-to-multiple-servers*: clients send their local models to
  multiple servers, increasing redundancy and robustness at the cost
  of higher communication overhead.

From a topological perspective, multi-star federated learning
corresponds to a two-level hierarchy. While it removes the single
point of failure of classical federated learning, each server still
represents a critical coordination node for its associated clients.
If a server fails or behaves in a Byzantine manner, the learning
process of its local star can be compromised, and inconsistencies
may propagate to other servers during synchronization.

==== Hierarchical federated learning

Hierarchical federated learning (HFL) generalizes the multi-star
architecture by organizing servers into a tree-shaped topology,
forming a hierarchy of aggregation levels @liu2020client.
At the lowest level, clients perform local training and send their
model updates to intermediate servers, which act as local aggregators.
These intermediate servers then forward partially aggregated models
upward in the hierarchy, until a final aggregation is performed at a
root server.

#figure(
  diagram(
    spacing: (18mm, 16mm),
    node-stroke: 0.8pt,
    edge-stroke: 1pt,

    // --- Root server ---
    node((1.5, 0),
      [*Root server*\ $theta^((t))$],
      shape: rect,
      fill: rgb("#378ADD").lighten(40%),
      stroke: rgb("#185FA5") + 0.8pt,
      name: <root>),

    // --- Intermediate servers ---
    node((0, 1),
      [*Server 1*\ $theta^((t))_1$],
      shape: rect,
      fill: blue.lighten(70%),
      stroke: blue.darken(20%) + 0.8pt,
      name: <s1>),
    node((1.5, 1),
      [*Server 2*\ $theta^((t))_2$],
      shape: rect,
      fill: blue.lighten(70%),
      stroke: blue.darken(20%) + 0.8pt,
      name: <s2>),
    node((3, 1),
      [*Server 3*\ $theta^((t))_3$],
      shape: rect,
      fill: blue.lighten(70%),
      stroke: blue.darken(20%) + 0.8pt,
      name: <s3>),

    // --- Clients of server 1 ---
    node((-0.5, 2),
      [*Client 1*\ $cal(D)_1$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c11>),
    node((0.3, 2),
      [*Client 2*\ $cal(D)_2$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c12>),

    // --- Clients of server 2 ---
    node((1.1, 2),
      [*Client 3*\ $cal(D)_3$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c21>),
    node((1.8, 2),
      [*Client 4*\ $cal(D)_4$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c22>),

    // --- Clients of server 3 ---
    node((2.7, 2),
      [*Client 5*\ $cal(D)_5$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c31>),
    node((3.5, 2),
      [*Client 6*\ $cal(D)_6$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <c32>),

    // --- Root ↔ intermediate servers ---
    edge(<root>, <s1>, marks: "<->"),
    edge(<root>, <s2>, marks: "<->"),
    edge(<root>, <s3>, marks: "<->"),

    // --- Server 1 ↔ clients ---
    edge(<s1>, <c11>, marks: "<->"),
    edge(<s1>, <c12>, marks: "<->"),

    // --- Server 2 ↔ clients ---
    edge(<s2>, <c21>, marks: "<->"),
    edge(<s2>, <c22>, marks: "<->"),

    // --- Server 3 ↔ clients ---
    edge(<s3>, <c31>, marks: "<->"),
    edge(<s3>, <c32>, marks: "<->"),
  ),
  caption: [
    Hierarchical federated learning: a root server coordinates three
    intermediate servers, each aggregating updates from two local
    clients. Aggregated models propagate upward level by level until
    a global model is produced at the root.
  ],
)

From a graph-theoretic perspective, this architecture corresponds to
a tree topology, where each internal node performs aggregation over
the models received from its children. This structure enables scalable
learning over very large populations of clients by distributing the
aggregation workload across multiple levels, thereby reducing
communication and computational pressure on the root server
@liu2020client.

Despite these scalability benefits, HFL remains fundamentally
centralized and inherits several limitations from tree-based
topologies. The structure is typically rigid, with predefined
parent--child relationships. Failures of intermediate aggregation
nodes can disconnect entire subtrees, temporarily preventing a large
number of clients from contributing to the global model. Similarly,
failures or Byzantine behavior at higher levels of the hierarchy may
corrupt or block the learning process for all downstream nodes
@an2025abd.

==== Blockchain-based federated learning

Blockchain-based federated learning combines federated learning with
blockchain-based distributed ledger technologies in order to remove
the reliance on a single trusted coordinator, motivated by the promise
of decentralization, auditability, and trust minimization
@wang2021systematic.

Several architectural strategies have been proposed. In a first
approach, each participant submits its local model update to a smart
contract deployed on the blockchain @ramanan2020baffle. Once a
sufficient number of updates has been received, the smart contract
performs the aggregation and publishes the resulting global model,
acting as a decentralized coordinator that enforces participation
rules and aggregation logic. An alternative approach relies on the
block validation process: instead of performing aggregation on-chain,
the block validator designates a node or a small committee as
aggregator for a given round @qu2020decentralized. Participants send
their local models to the selected aggregator, which computes the
aggregated model and disseminates it to the network, while the
blockchain records the selection process and ensures accountability.

Despite their conceptual appeal, these approaches inherit significant
limitations from blockchain technology. First, blockchain systems
require consensus on an exact global state, whereas machine learning
optimization only requires convergence toward a sufficiently low loss.
Enforcing strict consensus at every learning round introduces
substantial overhead without providing proportional benefit to the
learning process. Second, storing model parameters directly on-chain
is often impractical due to storage constraints and associated costs,
particularly for large models. 

#figure(
  diagram(
    spacing: (20mm, 18mm),
    node-stroke: 0.8pt,
    edge-stroke: 1pt,

    // --- Smart contract (center) ---
    node((1.5, 1),
      [*Smart contract*\ aggregation logic],
      shape: rect,
      fill: rgb("#EF9F27").lighten(50%),
      stroke: rgb("#BA7517") + 0.8pt,
      name: <sc>),

    // --- Participants ---
    node((0, 0),
      [*Node 1*\ $cal(D)_1$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <n1>),
    node((1.5, 0),
      [*Node 2*\ $cal(D)_2$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <n2>),
    node((3, 0),
      [*Node 3*\ $cal(D)_3$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <n3>),
    node((0, 2),
      [*Node 4*\ $cal(D)_4$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <n4>),
    node((3, 2),
      [*Node 5*\ $cal(D)_5$],
      shape: rect,
      fill: green.lighten(70%),
      stroke: green.darken(20%) + 0.8pt,
      name: <n5>),

    // --- Peer-to-peer connections between nodes ---
    edge(<n1>, <n2>, marks: "-"),
    edge(<n2>, <n3>, marks: "-"),
    edge(<n3>, <n5>, marks: "-"),
    edge(<n5>, <n4>, marks: "-"),
    edge(<n4>, <n1>, marks: "-"),
    edge(<n1>, <n3>, marks: "-"),
    edge(<n2>, <n4>, marks: "-"),

    // --- Nodes → smart contract (model upload) ---
    edge(<n1>, <sc>,
      marks: "->",
      label: $theta_1^((t))$,
      label-side: left),
    edge(<n2>, <sc>,
      marks: "->",
      label: $theta_2^((t))$,
      label-side: left),
    edge(<n3>, <sc>,
      marks: "->",
      label: $theta_3^((t))$,
      label-side: right),
    edge(<n4>, <sc>,
      marks: "->",
      label: $theta_4^((t))$,
      label-side: right),
    edge(<n5>, <sc>,
      marks: "->",
      label: $theta_5^((t))$,
      label-side: right),
  ),
  caption: [
    Blockchain-based federated learning: nodes are interconnected in a
    peer-to-peer overlay and submit their local model parameters
    $theta_i^((t))$ to a smart contract, which performs aggregation
    and publishes the updated global model to all participants.
  ],
)

Most practical implementations
therefore resort to off-chain storage or aggregation, which
reintroduces trust assumptions and partially undermines the
decentralization objective @wang2021systematic. Finally, when
aggregation is delegated to a single node or a small committee
selected by the block validator, the system remains vulnerable to
centralization risks, contradicting the original motivation for
using a blockchain.

From a topological perspective, blockchain-based federated learning
relies on a globally accessible coordination layer when smart
contracts are used, as all participants interact through a shared
ledger. When off-chain aggregators are employed, the resulting
communication structure resembles a star topology, with the
aggregator acting as a temporary central node.

In summary, the high communication latency, storage overhead, and
consensus costs of blockchain systems are poorly aligned with the
iterative and approximate nature of distributed machine learning,
and the practical deployment of such systems remains an open
challenge @wang2021systematic.


==== Gossip learning

Gossip Learning @ormandi2013gossip is a fully decentralized learning paradigm in which nodes exchange models 
through randomized peer-to-peer interactions. At each communication round, a node selects 
one of its neighbors uniformly at random and sends its current local model to that neighbor. 
There is no central coordinator and no notion of a global aggregation phase.

Upon receiving a model from a neighbor, a node performs a local aggregation between the 
received model and its own local model, typically by computing a weighted or uniform average 
of their parameters. The resulting aggregated model is then refined by performing one or 
several local learning steps using the node’s private dataset. This interaction pattern is 
repeated asynchronously across the network, leading to a gradual diffusion of information.

In the most common formulation, aggregation is 
performed before the local learning step. An alternative variant applies a local learning 
update independently to both models before merging them, which can improve robustness in 
non-IID data settings. Another extreme variant removes aggregation altogether: the local 
model is simply replaced by the received model. In this case, models effectively perform 
random walks over the network, and learning corresponds to successive local updates applied 
along these trajectories.

#figure(
  diagram(
    node-stroke: 0.8pt,
    edge-stroke: 0.8pt,
    node-fill: white,
    spacing: 25mm,

    // --- Nodes ---
    node((0, 0),   [*1*\ $cal(D)_1$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n1>),
    node((0.3, 1), [*2*\ $cal(D)_2$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n2>),
    node((1, 1.5), [*3*\ $cal(D)_3$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n3>),
    node((1.8, 1), [*4*\ $cal(D)_4$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n4>),
    node((1.8, 0), [*5*\ $cal(D)_5$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n5>),

    // --- Topology edges ---
    edge(<n1>, <n2>, marks: "-"),
    edge(<n1>, <n5>, marks: "-"),
    edge(<n2>, <n3>, marks: "-"),
    edge(<n2>, <n5>, marks: "-"),
    edge(<n3>, <n4>, marks: "-"),
    edge(<n4>, <n5>, marks: "-"),

    // --- Gossip exchange (node 2 → node 5) ---
    edge(<n2>, <n5>,
      marks: "-->",
      stroke: blue.darken(10%) + 1pt,
      bend: 20deg,
      label: [$theta_2^((t))$],
      label-side: left),
  ),
  caption: [
    Gossip learning: nodes are connected in a random peer-to-peer
    overlay. At each round, a node selects a neighbor uniformly at
    random and sends its current local model.
  ],
)

Gossip learning is typically deployed over random graph topologies, where the randomized 
communication pattern ensures sufficient mixing properties. Aggregation remains strictly 
local, and no global model is ever explicitly computed. Nevertheless, under suitable 
assumptions on the learning rate, loss function, and network connectivity, the local models 
are known to converge toward a common global solution. This convergence, however, is 
significantly slower than in Federated Learning due to the absence of coordinated global 
synchronization and the limited bandwidth of local interactions.

Despite its slower theoretical convergence, gossip learning offers
strong advantages in terms of system robustness. The absence of any
central entity makes the scheme inherently resilient to node failures,
network partitions, and churn. Nodes can join or leave the system
dynamically without disrupting the learning process, provided the
underlying communication graph remains connected on average. These
properties make gossip learning particularly attractive for
large-scale, dynamic, and failure-prone environments where centralized
or hierarchical approaches are impractical. Importantly, empirical
results suggest that the gap with federated learning may be smaller
than theoretical bounds indicate: @hegedHus2021decentralized show
that gossip learning can match the convergence quality of federated
learning in practice, while operating without any central coordinator.

#align(center,
grid(columns: 2,
[#figure(
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
], caption: [Gossip Learning]
) <algo:gossip-learning>
],
[#figure(
pseudocode-list(
  booktabs: true,
  title: [Gossip Learning (background thread)],
)[
  - ML model: *model*
  - local dataset: *data*
  + *loop*
    + peer_model $arrow.l$ receive()
    + model $arrow.l$ merge(model, peer_model)
    + model.update(data)
], caption: [Gossip Learning (background thread)]
) <algo:gossip-learning-background>
])
)

Beyond the foundational work of @ormandi2013gossip, gossip learning
has attracted a substantial body of follow-up research aimed at
improving its convergence speed, robustness, and applicability to
diverse settings.

Several works address the efficiency of the gossip communication
pattern itself. @danner2018token propose a token-account approach
that improves convergence speed by better controlling the flow of
models across the network, and @danner2023improving further refine
the model merging strategy to amplify the benefits of token-based
flow control, reporting significant improvements over prior solutions
in simulations based on real-world smartphone availability traces.
@giaretta2019gossip extend the base algorithm to account for node
heterogeneity: since faster nodes send more models than slower ones,
they propose storing one model per neighbor and selecting from this
cache before merging, though this extension assumes a fixed neighbor
set. @wang2019matcha improve decentralized SGD by introducing a
matching decomposition sampling strategy that constructs better
communication topologies, while @koloskova2020unified provide a
unified theoretical framework for analyzing the convergence of
gossip-based SGD under changing topologies and local updates.

The algorithm has also been extended to non-standard learning tasks.
@berta2014lightning adapt gossip learning to $k$-means clustering,
demonstrating the generality of the paradigm beyond supervised
learning. @hu2019decentralized propose a segmented gossip approach in
which nodes exchange only a subset of model parameters rather than
the full model, reducing communication overhead, though their setting
is closer to a distributed cluster than a fully decentralized
peer-to-peer network.

A distinct line of work focuses on non-IID data settings and
personalization. @onoszko2021decentralized introduce PENS, a
performance-based neighbor selection algorithm in which nodes
evaluate received models on their local test set and preferentially
gossip with peers whose models perform best locally, effectively
steering communication toward nodes with similar data distributions.
In a related direction, @belal2022pepper argue that approximating
a global distribution is not always necessary, and propose PEPPER,
a gossip-based personalized recommender system in which each node
trains a model tailored to its own user rather than optimizing a
global objective.

==== Epidemic learning

Epidemic learning is a decentralized learning scheme in which each
node exchanges its local model with all of its neighbors at every
communication round @de2023epidemic. Contrary to classical
gossip learning, where interactions are pairwise and asynchronous,
this approach requires each node to wait for the models of all its
neighbors before performing aggregation. As a result, the learning
process is inherently synchronous.

#figure(
  diagram(
    node-stroke: 0.8pt,
    edge-stroke: 0.8pt,
    node-fill: white,
    spacing: 25mm,

    // --- Nodes ---
    node((0.9, 0.8), [*1*\ $cal(D)_1$], radius: 1.8em,
      fill: rgb("#EF9F27").lighten(50%),
      stroke: rgb("#BA7517") + 0.8pt,
      name: <n1>),
    node((0, 0),   [*2*\ $cal(D)_2$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n2>),
    node((0, 1.6), [*3*\ $cal(D)_3$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n3>),
    node((1.8, 0), [*4*\ $cal(D)_4$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n4>),
    node((1.8, 1.6), [*5*\ $cal(D)_5$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n5>),

    // --- Topology edges (non-neighbors of node 1) ---
    edge(<n2>, <n3>, marks: "-"),
    edge(<n4>, <n5>, marks: "-"),
    edge(<n2>, <n4>, marks: "-"),
    edge(<n3>, <n5>, marks: "-"),

    // --- Node 1 broadcasts to all neighbors ---
    edge(<n1>, <n2>,
      marks: "<-",
      stroke: blue.darken(10%) + 1.5pt,
      label: $theta_2^((t))$,
      label-side: left),
    edge(<n1>, <n3>,
      marks: "<-",
      stroke: blue.darken(10%) + 1.5pt,
      label: $theta_3^((t))$,
      label-side: left),
    edge(<n1>, <n4>,
      marks: "<-",
      stroke: blue.darken(10%) + 1.5pt,
      label: $theta_4^((t))$,
      label-side: right),
    edge(<n1>, <n5>,
      marks: "<-",
      stroke: blue.darken(10%) + 1.5pt,
      label: $theta_5^((t))$,
      label-side: right),
  ),
  caption: [
    Epidemic learning: node 1 (orange) collects the models
    $theta_2^((t)), dots, theta_5^((t))$ from all its neighbors
    simultaneously. Once all models are received, node 1 aggregates
    them and performs a local update on $cal(D)_1$.
  ],
)

At each round, a node broadcasts its current model to all adjacent
nodes and collects the models received from its neighborhood. Once
all expected models have been received, the node computes an
aggregation, typically by averaging the parameters of its own model
with those of its neighbors. The aggregated model is then updated
using a local learning step on the node's private dataset. This
process is repeated synchronously across the network.

Epidemic learning can be deployed over various network topologies.
On random graphs, it preserves some of the decentralization benefits
of gossip learning while accelerating convergence thanks to richer
local aggregation. On a fully connected topology, where every node
is connected to all others, the scheme becomes equivalent to a global
aggregation performed in a fully decentralized manner.

However, the increased degree of connectivity comes at a significant
cost. The communication and aggregation overhead grows linearly with
the number of neighbors, making the approach poorly scalable for
high-degree nodes. In fully connected networks, the communication
cost per round becomes prohibitive as the number of nodes increases.
Furthermore, the synchronous nature of the protocol makes it sensitive
to stragglers and node failures, as a single slow or unavailable
neighbor can delay the entire aggregation step.

While epidemic learning offers faster convergence than pairwise gossip
schemes, it sacrifices robustness and scalability. This trade-off
highlights the inherent tension between rich aggregation,
decentralization, and fault tolerance, and motivates the exploration
of adaptive aggregation strategies that balance these competing
objectives.

Epidemic learning has served as a foundation for a growing body of
work addressing practical limitations of the base protocol. These
extensions target a range of challenges including privacy, anonymity,
energy efficiency, data heterogeneity, scalability, and stragglers.

On the privacy and anonymity front, Zip-DL @biswas2024low introduces
resistance to privacy attacks by adding carefully calibrated noise to
model updates before transmission, while Shatter @biswas2024noiseless
takes a complementary approach by introducing the concept of virtual
nodes: instead of transmitting models under their true identity,
nodes split their model across virtual identities, thereby concealing
which physical node carries which model and preventing adversaries
from linking model updates to specific participants.

From an energy efficiency perspective, SkipTrain @de2024energy
proposes alternating between training phases and transmission phases,
allowing nodes to skip local training during transmission rounds.
This decoupling reduces the energy consumption of the protocol,
making epidemic learning more suitable for resource-constrained
environments such as mobile or edge devices.

The non-IID setting is addressed by Facade @biswas2025fair, which
adapts epidemic learning to heterogeneous data distributions by
clustering nodes according to the similarity of their local datasets.
By preferentially exchanging models within clusters of nodes sharing
similar data distributions, Facade mitigates the client drift problem
that arises when models trained on heterogeneous data are naively
averaged. DivShare @biswas2025boosting addresses a related challenge
by improving resilience to stragglers: when slow nodes delay the
aggregation step, DivShare adapts the protocol to tolerate late or
missing model transmissions without blocking the learning process.

Finally, two works address the scalability of epidemic learning at
larger network sizes. Plexus @dhasade2025practical selects a subset
of nodes at each cycle to participate in training and model
construction, reducing the per-round communication and computation
cost while preserving convergence properties, thereby enabling
epidemic learning to scale to larger networks. Mosaic Learning
@biswas2026mosaic fragments models into pieces and strategically
disseminates the fragments that differ most across nodes, exploiting
model diversity to accelerate convergence time.

==== Ring-based decentralized learning

Decentralized learning can also be implemented over a ring topology  @hua2024towards, although this approach 
is relatively uncommon in the machine learning literature. In a ring-based system, each node 
maintains connections with exactly two neighbors, typically referred to as its left and right neighbors, forming a closed cycle. This topology is simple, deterministic, and requires each node to store only a constant number of connections, which makes it attractive from a 
maintenance and routing perspective.

#figure(
  diagram(
    node-stroke: 0.8pt,
    edge-stroke: 0.8pt,
    node-fill: white,
    spacing: 22mm,

    // --- Nodes arranged in a ring ---
    node((1, 0),   [*1*\ $cal(D)_1$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n1>),
    node((2, 0.7), [*2*\ $cal(D)_2$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n2>),
    node((2, 1.8), [*3*\ $cal(D)_3$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n3>),
    node((1, 2.5), [*4*\ $cal(D)_4$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n4>),
    node((0, 1.8), [*5*\ $cal(D)_5$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n5>),
    node((0, 0.7), [*6*\ $cal(D)_6$], radius: 1.8em,
      fill: green.lighten(70%), stroke: green.darken(20%) + 0.8pt, name: <n6>),

    // --- Ring topology ---
    edge(<n1>, <n2>, marks: "-"),
    edge(<n2>, <n3>, marks: "-"),
    edge(<n3>, <n4>, marks: "-"),
    edge(<n4>, <n5>, marks: "-"),
    edge(<n5>, <n6>, marks: "-"),
    edge(<n6>, <n1>, marks: "-"),

    // --- Model circulation (circulating model highlighted) ---
    edge(<n1>, <n2>,
      marks: "->",
      stroke: blue.darken(10%) + 1.5pt,
      bend: 30deg,
      label: $theta^((t))$,
      label-side: left),
  ),
  caption: [
    Decentralized learning on a ring topology: nodes are connected
    to exactly two neighbors, forming a closed cycle. A model
    $theta^((t))$ circulates sequentially along the ring --- here
    from node 1 to node 2 --- and is updated at each node using
    its local dataset $cal(D)_i$ before being forwarded to the
    next neighbor.
  ],
)


Several aggregation strategies can be employed in a ring topology. A first approach consists 
in *local neighborhood aggregation*, where each node periodically exchanges model parameters 
or updates with its immediate neighbors and aggregates them, for instance by averaging its 
own model with those received from the left and right neighbors.

A second strategy relies on *model circulation*. In this approach, a single model is passed sequentially from node to node along the ring. Each node locally updates the received model using its own dataset before forwarding it to the next neighbor. 
After a full traversal of the ring, the model has effectively been trained on the data of all 
nodes, in a manner reminiscent of incremental or online learning. 

An illustrative example of a ring-based decentralized learning protocol is Fedlay @hua2024towards, which organizes nodes into *virtual rings*. In Fedlay, each node maintains connections to $2 ell$ neighbors across $ell$ distinct virtual rings, where $ell in NN^*$ is a configurable protocol parameter. At each training cycle, every node performs model aggregation by merging its local model with those received from its neighbors in each virtual ring, typically through weighted averaging. This multi-ring structure increases connectivity without sacrificing the simplicity of ring-based routing, allowing for more robust information propagation compared to a single-ring topology. However, the reliance on virtual rings still inherits some of the fundamental limitations of ring structures, particularly regarding latency and sensitivity to node churn.

Despite its conceptual simplicity, decentralized learning on a ring topology suffers from 
significant limitations. The rigid structure of the ring makes the system particularly vulnerable to 
failures and churn. The failure of a single node or link may break the ring and disconnect the 
network unless additional repair mechanisms are employed @hua2024towards. Frequent joins and leaves further 
complicate the maintenance of the ring structure and may disrupt the learning process.

==== Summary

The aggregation strategies surveyed in this section differ
fundamentally in their underlying network topology, which directly
shapes their convergence speed, scalability, and fault tolerance
properties. @tab:aggregation-strategies-topology summarises the main
strategies discussed, together with their associated topologies.

#figure(
table(
  columns: (1fr, 1fr),
  inset: 10pt,
  align: horizon,
  table.header(
    [*Aggregation strategy*], [*Associated topology*],
  ),
  [Federated learning],
  [Star (single central server)],
  [Multi-star federated learning],
  [Multiple stars],
  [Hierarchical federated learning],
  [Tree / hierarchical topology],
  [Blockchain-based federated learning],
  [Complete graph],
  [Gossip learning],
  [Random graph or complete graph],
  [Epidemic learning],
  [Random graph or complete graph],
  [Ring-based decentralized learning],
  [Ring],
),
  caption: [Main aggregation strategies and their associated network topologies.],
) <tab:aggregation-strategies-topology>

== Conclusion

This chapter has progressively built the conceptual and formal
foundations necessary to situate decentralized learning within the
broader landscape of machine learning. Starting from the classical
supervised learning framework --- loss functions, gradient descent,
and standard model classes --- we introduced a series of learning
paradigms of increasing decentralization: from centralized learning,
where a single entity holds all data and controls the entire training
process, through distributed approaches such as data parallelism,
model parallelism, and ensemble learning, to fully decentralized
schemes in which nodes operate autonomously on private local datasets
without any central coordinator.

Within this landscape, we formalized the decentralized learning
problem by grounding it in the peer-to-peer model of @chap:model:
a decentralized learning node is a peer-to-peer node enriched with
a local dataset and a local model, and the global learning objective
is to collectively minimize the aggregate loss $L_"global"$ without
any node ever observing the data of another. We characterized
convergence in terms of this global objective, and introduced
complementary performance metrics --- final accuracy and time to
accuracy --- that will serve as evaluation criteria throughout the
remainder of this thesis.

We then surveyed the main topology-driven aggregation strategies
proposed in the literature, ranging from the star-shaped architecture
of federated learning and its hierarchical extensions, to fully
decentralized schemes such as gossip learning and epidemic learning.
This survey revealed a fundamental tension that runs through the
field: centralized and hierarchical approaches such as federated
learning benefit from efficient coordination and fast convergence,
but rely on a central point of control that introduces fragility,
scalability limitations, and trust requirements. Fully decentralized
approaches such as gossip learning eliminate this central dependency
and offer strong resilience properties, but typically converge more
slowly due to the limited bandwidth of local pairwise interactions.

Bridging this gap --- combining the convergence efficiency of
federated learning with the robustness and decentralization
properties of gossip-based protocols --- remains an open challenge.
The following chapter presents our contribution to this problem.
We introduce a novel peer-to-peer protocol that operates without any
central coordinator, leverages the epidemic learning communication
pattern to achieve richer local aggregation, and is designed to
exhibit convergence properties competitive with federated learning
while retaining the fault tolerance and scalability of fully
decentralized systems.