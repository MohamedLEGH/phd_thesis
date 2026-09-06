#set heading(numbering: none)  // Heading numbering

#set text(
  hyphenate: true,
  lang: "fr",
)

= Résumé en français <chap:resume>

Les systèmes distribués à grande échelle sont aujourd'hui omniprésents,
qu'il s'agisse de réseaux de diffusion de contenu, de systèmes de
stockage décentralisés, ou plus récemment de plateformes d'apprentissage
automatique collaboratif. Dans ce contexte, les architectures pair à
pair occupent une place particulière : elles permettent de coordonner
un grand nombre de nœuds sans recourir à une autorité centrale, ce qui
les rend intrinsèquement résistantes aux pannes, extensibles,
et respectueuses de la confidentialité des données. Cependant, concevoir
des protocoles pair à pair qui soient à la fois efficaces, robustes aux
défaillances, et capables de supporter des charges applicatives
complexes comme l'apprentissage automatique reste un défi ouvert.

Cette thèse s'inscrit dans ce contexte et propose une architecture en
couches pour l'apprentissage décentralisé, qui sépare le substrat de
communication de la logique d'apprentissage. Sa contribution principale
est une architecture composée d'une couche overlay, responsable de la
topologie du réseau, et d'une couche d'apprentissage fédéré
décentralisé construite au-dessus. La couche overlay est instanciée
par Elevator, un protocole de gestion de topologie pair à pair basé
sur l'élection dynamique de nœuds hubs, formant une structure
d'overlay hiérarchique à deux niveaux ; Elevator est complété par
Lift, qui renforce sa robustesse face aux nœuds byzantins. La couche
d'apprentissage est instanciée par HEAL (Hub Enhanced Adaptive
Learning), un cadre d'apprentissage fédéré décentralisé construit sur
Elevator, qui tire parti de la structure hub pour accélérer la
convergence des modèles tout en préservant les propriétés de robustesse
de l'overlay sous-jacent. Nous proposons également d'adapter cette
architecture aux contraintes des réseaux sans fil physiques avec FLAIR
(Federated Learning with Adaptive Integrity-preserving Randomness).

La thèse débute par l'introduction d'un modèle formel du système
qui sert de socle à l'ensemble des contributions. Ce modèle définit
les abstractions fondamentales utilisées tout au long du manuscrit :
la notion de nœud, de voisinage, de vue partielle, et de cycle de
communication. Le réseau est modélisé comme un graphe dynamique dont
la topologie évolue au fil du temps sous l'effet des entrées et
sorties de nœuds, des pannes franches, et des décisions protocolaires.

Le modèle de pannes adopté couvre trois scénarios distincts. Les
pannes franches correspondent à l'arrêt définitif d'un nœud sans
préavis. Le churn désigne la dynamique continue d'arrivées et de
départs de nœuds, caractéristique des réseaux pair à pair ouverts.
Les nœuds byzantins, enfin, représentent des participants malveillants
capables d'envoyer des messages arbitraires ou incorrects dans le but
de perturber le protocole. Ce dernier modèle de faute est le plus
général et le plus difficile à tolérer.

Le chapitre suivant dresse un panorama de l'état de l'art sur les
réseaux overlay pair à pair, en se concentrant sur les aspects
pertinents pour les contributions de la thèse. Les réseaux overlay
sont des réseaux logiques construits par-dessus un réseau physique
sous-jacent, dans lesquels chaque nœud maintient une vue partielle
de ses voisins et communique exclusivement avec eux. Deux grandes
familles de protocoles sont distinguées : les overlays structurés,
dans lesquels la topologie obéit à des invariants précis (comme dans
Chord ou Kademlia), et les overlays non structurés, dans lesquels
les connexions sont établies de manière aléatoire ou épidémique.

Les protocoles de peer sampling, qui permettent à chaque nœud
d'obtenir un sous-ensemble représentatif et frais de l'ensemble
du réseau, occupent une place centrale dans ce panorama. Des
protocoles comme Cyclon, Newscast, ou HyParView sont présentés et
analysés selon leur résistance au churn, la qualité de la vue
partielle qu'ils maintiennent, et leur capacité à s'auto-réparer
après une partition. Ces propriétés constituent les critères
d'évaluation qui seront repris pour Elevator.

L'état de l'art sur la gestion de topologies hiérarchiques et
l'élection de super-pairs est également couvert. Les approches
existantes, qu'elles soient basées sur la capacité des nœuds, sur
leur degré de connectivité, ou sur des mécanismes d'élection
distribués, sont passées en revue. Cette revue met en évidence
les limites des approches actuelles en matière de dynamicité et
de tolérance aux fautes byzantines, et motive la conception
d'Elevator comme une alternative plus robuste et plus flexible.

Elevator est ensuite introduit, la première contribution
originale de la thèse. Elevator est un protocole d'overlay pair à
pair qui organise le réseau en une structure à deux niveaux : un
ensemble de nœuds hubs, élus dynamiquement, et un ensemble de nœuds
génériques qui se connectent à ces hubs.
L'élection des hubs est au cœur du protocole. Elevator repose sur
un mécanisme d'élection entièrement décentralisé et émergent, qui
ne requiert ni coordination explicite ni connaissance globale du
réseau. À chaque cycle, chaque nœud observe ses voisins à distance
deux et établit ses connexions sortantes de manière préférentielle :
parmi ses $c$ connexions totales, il en consacre $h$ aux nœuds qui
présentent le plus grand nombre de connexions entrantes dans sa vue
locale, et maintient $c - h$ connexions choisies aléatoirement. Ce
mécanisme de connexion préférentielle, inspiré des processus
d'attachement préférentiel étudiés dans la littérature sur les
réseaux complexes, crée une dynamique de renforcement : les nœuds
les plus connectés attirent davantage de connexions, ce qui accroît
encore leur degré entrant. En quelques cycles seulement, cette
dynamique fait émerger spontanément $h$ nœuds hubs auxquels la
quasi-totalité des nœuds du réseau est directement connectée. Le
statut de hub n'est pas attribué explicitement : il est la
conséquence observable d'un processus collectif décentralisé,
piloté uniquement par les paramètres globaux $c$ et $h$.

La tolérance aux fautes byzantines est adressée par un protocole
complémentaire, Lift, conçu pour s'exécuter par-dessus Elevator.
Dans Elevator seul, le mécanisme de connexion préférentielle est
aveugle à la nature des nœuds : un nœud byzantin qui parvient à
accumuler un grand nombre de connexions entrantes peut s'imposer
comme hub et ainsi occuper une position privilégiée dans le réseau.
Lift modifie le processus d'élection en s'appuyant sur un générateur
de nombres pseudo-aléatoires partagé. Les identifiants des $h$ hubs
courants sont utilisés comme graine de ce générateur ; comme tous
les nœuds du réseau disposent de la même graine, ils peuvent tous
dériver indépendamment et de manière identique un nouvel ensemble
de $h$ identifiants, qui désignent les prochains hubs. Ce mécanisme
retire aux nœuds byzantins toute capacité d'influence sur l'élection :
un attaquant ne peut pas manipuler le résultat du générateur sans
contrôler les identifiants qui servent de graine, et ces identifiants
sont déterminés par le processus Elevator sous-jacent. Lift conserve
ainsi l'ensemble des propriétés topologiques d'Elevator tout en
offrant des garanties de robustesse renforcées en présence
d'attaquants actifs.

L'évaluation d'Elevator est conduite selon trois axes complémentaires.
Une analyse théorique établit d'abord les propriétés formelles du
protocole : convergence vers une topologie hub stable, conditions de
stabilité en fonction des paramètres $c$ et $h$, et borne sur le
temps de convergence en nombre de cycles. Ces résultats analytiques
fournissent des garanties sur le comportement asymptotique du
protocole indépendamment de toute hypothèse sur l'implémentation.
Des simulations à grande échelle réalisées sur PeerSim permettent
ensuite d'évaluer empiriquement les propriétés topologiques de
l'overlay — diamètre, connectivité, stabilité du hub set — sous
différentes conditions de churn et de taille de réseau allant jusqu'à
1 000 nœuds, et de confronter les prédictions théoriques au
comportement observé. Enfin, une évaluation sur un réseau TCP/IP
réel est conduite pour mesurer les performances du protocole dans
des conditions de déploiement effectives, en termes de latence de
reconfiguration et de volume de messages échangés.

Le cinquième chapitre introduit les fondements théoriques de
l'apprentissage automatique et de l'apprentissage fédéré
décentralisé, et constitue le pont entre la partie réseau et la
partie applicative de la thèse.
L'apprentissage fédéré est présenté dans sa formulation
canonique centralisée, telle qu'elle a été introduite par FedAvg.
Cette approche, bien qu'efficace, repose sur un serveur central qui
agrège les mises à jour des clients à chaque ronde, ce qui en limite
le passage à l'échelle et la résistance aux pannes.

L'apprentissage fédéré décentralisé est ensuite introduit comme
alternative naturelle. Dans ce paradigme, il n'existe plus de
serveur central : chaque nœud agrège les modèles de ses voisins
directs, et la convergence vers un modèle global émerge des échanges
épidémiques entre pairs. L'apprentissage par bavardage et
l'apprentissage épidémique sont présentés comme les représentants
les plus aboutis de cette approche. Leurs propriétés de convergence,
leur comportement sous hétérogénéité des données, et leurs limites
en termes de vitesse de convergence sont analysés en détail.

La revue de la littérature met en évidence un manque important :
les protocoles d'apprentissage décentralisé existants n'exploitent
pas la structure du réseau superposé pour accélérer la propagation
des modèles. C'est précisément cette lacune que HEAL vient combler.

Le sixième chapitre présente HEAL et FLAIR, les contributions
applicatives de la thèse. HEAL est un cadre d'apprentissage fédéré
décentralisé qui s'appuie sur la structure hub d'Elevator pour
organiser l'agrégation des modèles en plusieurs phases successives.
L'architecture de HEAL est organisée en quatre couches. La couche
réseau prend en charge la communication de bas niveau entre les nœuds.
La couche overlay, fournie par Elevator, détermine la topologie du
réseau et l'identité des hubs à chaque cycle. La couche d'agrégation
définit le protocole d'échange et de fusion des modèles entre nœuds.
La couche applicative interface HEAL avec la tâche d'apprentissage
concrète — classification d'images, classification de texte — via
une abstraction de modèle local.

Le protocole HEAL se déroule en cinq phases à chaque cycle.
Premièrement, chaque nœud effectue une mise à jour locale de son
modèle sur ses données privées. Deuxièmement, les nœuds génériques
envoient leur modèle à leur hub de rattachement. Troisièmement, chaque
hub agrège les modèles reçus de ses nœuds génériques. Quatrièmement,
les hubs échangent leurs modèles agrégés entre eux et réalisent une
seconde agrégation au niveau inter-hub. Cinquièmement, chaque hub
rediffuse le modèle global agrégé vers ses nœuds génériques. Cette
structure en deux niveaux d'agrégation — intra-hub puis inter-hub —
est la propriété fondamentale qui distingue HEAL des approches de
gossip learning à plat, et qui lui permet d'atteindre une convergence
plus rapide en réduisant le nombre de cycles nécessaires à la
propagation d'une mise à jour à travers l'ensemble du réseau.

L'évaluation expérimentale de HEAL est conduite sur plusieurs tâches
d'apprentissage — MNIST, Spambase — et sous trois scénarios de fautes : absence de pannes, pannes
franches statiques, et churn. Les résultats montrent que HEAL converge
systématiquement plus vite que les baselines de gossip learning et
d'epidemic learning, et qu'il maintient une précision élevée même en
présence de churn significatif.

FLAIR est introduit en fin de chapitre comme un protocole
complémentaire à HEAL, conçu pour les contraintes des réseaux sans
fil physiques. FLAIR s'appuie sur LEACH, un protocole d'élection de
têtes de grappe (cluster heads) initialement développé pour les
réseaux de capteurs. Dans FLAIR, l'élection des têtes de grappe
repose sur un score calculé à partir des capacités physiques de
chaque nœud (bande passante disponible, puissance de calcul, mémoire, etc.). Les nœuds présentant les meilleures capacités sont élus
têtes de grappe et assument le rôle d'agrégateurs de modèles pour
leur grappe respective. Cette approche permet d'adapter
naturellement la charge d'agrégation aux nœuds les plus capables
du réseau, tout en limitant le volume de communications nécessaires
à la convergence. FLAIR est évalué sur le simulateur ns-3, qui
modélise fidèlement les conditions de propagation et d'interférence
d'un réseau sans fil réel.

Un chapitre en annexe documente l'ensemble de l'infrastructure de
simulation développée au cours de la thèse. Cette infrastructure,
largement invisible dans les chapitres principaux, a nécessité un
investissement considérable et constitue une contribution
d'ingénierie significative en elle-même.
Le simulateur PeerSim a été profondément modifié pour les besoins
de la thèse : migration du contrôle de version de SVN vers Git,
introduction de Gradle pour la gestion des dépendances,
conteneurisation via Docker, pipeline CI/CD sur GitLab,
parallélisation du moteur de simulation, implémentation des modèles
de fautes et des attaques byzantines, et ajout de plusieurs
protocoles d'overlay. Pour la simulation de l'apprentissage
décentralisé, une approche hybride combinant PeerSim pour la
topologie et Gossipy pour la couche d'apprentissage a été adoptée
après une évaluation approfondie des alternatives disponibles —
Flower, OMNeT++, NS-3, decentralizepy — dont les limitations
respectives sont documentées. L'ensemble du workflow expérimental,
de la génération des topologies à la production des figures, est
entièrement automatisé et reproductible.

Les travaux présentés dans cette thèse montrent qu'il est possible
de concevoir un protocole d'overlay pair à pair qui soit à la fois
dynamique, robuste aux fautes byzantines, et exploitable comme
substrat pour l'apprentissage fédéré décentralisé. Elevator et HEAL
forment un système cohérent dans lequel les propriétés topologiques
de l'overlay se traduisent directement en propriétés de convergence
de l'apprentissage.

Plusieurs directions de recherche restent ouvertes. Sur le plan
protocolaire, l'extension de HEAL à des scénarios d'apprentissage
personnalisé, dans lesquels chaque nœud cherche à optimiser un
modèle adapté à sa distribution locale plutôt qu'un modèle global
partagé, constitue une piste naturelle. La gestion de l'hétérogénéité
des données — scénario non-IID — reste un défi pour les protocoles
de gossip learning en général, et HEAL n'échappe pas à cette
limitation. Des mécanismes d'agrégation robuste à l'hétérogénéité,
intégrés dans la couche hub d'Elevator, pourraient atténuer ce
problème. Sur le plan de l'infrastructure, le simulateur unifié
en cours de développement en fin de thèse, qui intègre topologie
dynamique, apprentissage décentralisé, et modèles de fautes dans
un cadre unique entièrement en Python, ouvre la voie à des
expérimentations plus systématiques et à une meilleure reproductibilité
des résultats dans la communauté.
