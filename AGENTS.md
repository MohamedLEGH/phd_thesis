# AGENTS.md — Analyse du dépôt de thèse

> Ce document synthétise la compréhension du dépôt, la structure du code Typst,
> le contenu scientifique du manuscrit, et une évaluation critique en tant que rapporteur.

---

## 1. Structure du dépôt

```
phd_thesis/
├── main.typ                              # Point d'entrée : métadonnées + inclusion des chapitres
├── main.pdf / main_corrected.pdf         # PDF compilés du manuscrit (corrected : conformité PDF/A-1a)
├── lib.typ                               # Template Typst : page de garde, TOC, en-têtes, numérotation
├── thesis_flatV11.typ                    # Version aplatie (mono-fichier) du manuscrit (~520 Ko)
├── diff9to11_fixed.typ                   # Diff entre versions v9 et v11
├── typst_flatten.py                      # Script Python pour aplatir les includes en un seul .typ
├── flatten_opacity.py                    # Script de traitement d'opacité des figures
├── fix_pdf.sh (et .old)                  # Scripts de correction des PDF compilés
├── resume.typ / resume.pdf               # Résumé étendu du manuscrit en français (10-15 pages)
├── "typst - facile.pdf" / "typst - print.pdf"  # Versions d'impression / lecture du manuscrit
├── Phd_thesis_typdiff_v9_to_v11.pdf      # PDF du diff visuel entre v9 et v11
├── AGENTS.md                             # Ce fichier — analyse du dépôt, du manuscrit, note
├── presentation/
│   ├── slides.typ                        # Présentation Touying pour la soutenance (thème university)
│   ├── slides.pdf                        # PDF compilé de la présentation (61 pages)
│   └── (assets)                          # Figures SVG/PDF/PNG, architecture.tex, ref.bib, plot_classification.py
├── template/
│   ├── References.bib                    # Bibliographie BibTeX (169 entrées)
│   ├── customization/
│   │   ├── colors.typ                    # Palette de couleurs (cover, headings, liens)
│   │   └── great-theorems-customized.typ # Personnalisation du package great-theorems
│   ├── chapter/
│   │   ├── abstract.typ                  # Abstract en anglais (~28 lignes)
│   │   ├── remerciements.typ             # Remerciements (66 lignes, sur une page)
│   │   ├── resume_fr.typ                 # Résumé en français (263 lignes)
│   │   ├── introduction.typ              # Introduction générale (140 lignes, ~3 500 mots)
│   │   ├── model.typ                     # Chap. 2 : Modèle formel (690 lignes, ~6 800 mots)
│   │   ├── overlay.typ                   # Chap. 3 : État de l'art overlays P2P (861 lignes, ~15 100 mots)
│   │   ├── elevator.typ                  # Chap. 4 : Elevator & Lift (1 381 lignes, ~14 600 mots)
│   │   ├── machine_learning.typ          # Chap. 5 : État de l'art ML décentralisé (1 481 lignes, ~8 500 mots)
│   │   ├── heal.typ                      # Chap. 6 : HEAL & FLAIR (1 585 lignes, ~12 500 mots)
│   │   ├── conclusions_outlook.typ       # Chap. 7 : Conclusions et perspectives (341 lignes, ~4 000 mots)
│   │   ├── publications.typ              # Liste des publications (29 lignes)
│   │   ├── appendix.typ                  # Annexes (2 676 lignes, ~19 000 mots)
│   │   ├── simulators.typ                # Chapitre sur les simulateurs (commenté, non inclus)
│   │   └── variants_heal.typ             # Variantes de HEAL (commenté, non inclus)
│   └── images/                           # (logo placeholder)
├── Images/
│   ├── models/                           # Figures pour l'analyse théorique d'Elevator
│   ├── HEAL/                             # Figures d'évaluation de HEAL (accuracy, crash, churn)
│   ├── FLAIR/                            # Figures d'évaluation de FLAIR
│   ├── Victor/                           # Figures de graphes (collaboration stagiaire)
│   ├── TON/                              # Figures pour l'article TON (simulation PeerSim)
│   ├── CANDAR/                           # Figures Elevator normal + byzantin (conf. CANDAR)
│   ├── Dataset/                          # Jeux de données (ex. MNIST_dataset_example.png)
│   ├── Elevator/                         # Figures Elevator supplémentaires (crash, churn, ...)
│   └── 1_ieIdnYcxt4kS71uA1QsFGw_arpanet.webp  # Image ARPANET (intro)
├── Logos/
│   ├── SORBONNE UNIVERSITÉ/
│   ├── LIP6/
│   ├── CNRS/
│   ├── LINCS/                            # Logo LINCS (LINCS.png, LINCS_WHITE.png)
│   ├── logoSuppl.png
│   └── LICENSE/
└── .git/
```

---

## 2. Stack technique Typst

### Packages utilisés

| Package | Version | Usage |
|---|---|---|
| `great-theorems` | 0.1.2 | Environnements theorem, definition, proposition, proof, assumption, remark, example |
| `hydra` | 0.6.0 | En-têtes de page (running heads) |
| `equate` | 0.3.0 | Numérotation des équations avec sous-numéros |
| `i-figured` | 0.2.4 | Numérotation des équations par section (fallback si equate désactivé) |
| `fletcher` | 0.5.8 | Diagrammes de graphes (nœuds, arêtes) inline |
| `lovelace` | 0.3.0 | Pseudocode algorithmique (`pseudocode-list`) |
| `theorion` | 0.4.1 | Rendu avancé des environnements mathématiques |
| `cetz` | 0.4.2 | Dessins vectoriels (architecture en couches, Venn diagrams, schémas) |

### Architecture du template (`lib.typ`)

- **Page de garde** : grille de logos, titre, sous-titre, auteur, directeurs, jury, licence CC BY-NC-ND
- **Page de garde dynamique** : s'adapte au nombre de logos (3 ou 4), nombre de directeurs (1 ou 2), langue (fr/en)
- **En-têtes** : heading de niveau 1 stylisé avec filets horizontaux et couleur
- **Numérotation** : équations numérotées par chapitre (pattern `(1.1)`), sous-équations supportées
- **TOC** : table des matières + liste des figures + liste des tableaux
- **Compteurs** : `reset-counters` (i-figured) ou `equate` selon la configuration
- **Personnalisation** : couleurs de couverture, titres, liens via `colors.typ`

### Conventions de code

- Chaque chapitre importe ses propres packages (fletcher, lovelace, theorion, cetz) — pas d'import centralisé
- Les chapitres commentés (`simulators.typ`, `variants_heal.typ`) sont exclus du build via `// #include`
- La date de soutenance est `07/09/2026` (page de garde, `main.typ`)
- Le jury est complet sur la page de garde : 8 membres (directrice, co-directeur, 2 rapporteurs, 4 examinateurs) + 2 invitées (Megumi Kaneko, Kenza Harkouken Saiah)
- Orthographe : anglais américain uniformisé dans tous les chapitres (pas de formes britanniques `-ise`/`behaviour`) ; les fichiers français (`remerciements.typ`, `resume_fr.typ`) sont en français
- Les figures du chap. 6 (FLAIR) sont en PDF ; ailleurs SVG/PDF/PNG mélangés (~143 blocs `figure` dans les chapitres)

---

## 2b. Présentation de soutenance (`presentation/slides.typ`)

### Stack technique

| Composant | Version | Usage |
|---|---|---|
| `touying` | 0.6.1 | Moteur de slides (navigation, overlay, animations) |
| `themes.university` | (inclus dans touying) | Thème de présentation (header + footer 3 couleurs, barre de progression) |
| `fletcher` | 0.5.8 | Diagrammes de graphes inline (utilisé : plusieurs `fletcher-diagram`, reducer actif) |
| `lovelace` | 0.3.0 | Pseudocode algorithmique (`pseudocode-list`, `pseudocode`) |
| `cetz` | 0.4.2 | Dessins vectoriels |
| `great-theorems` | 0.1.2 | Environnements théorèmes |

### Thème et style

- **Thème** : `university` (couleurs par défaut : primary `#04364A`, secondary `#176B87`, tertiary `#448C95`)
- **Config** : `university-theme.with(aspect-ratio: "16-9", config-info(title/short-title/author/institution/date))` — config-info : titre de la thèse, author « Mohamed Amine Legheraba », institution « LIP6 · Sorbonne Université », date « September 7, 2026 »
- **Police** : aucune fonte déclarée (polices par défaut du système)
- **Ratio** : 16:9
- **Footer** : actif (3 cellules colorées : auteur / titre / date+numéro de slide) — fourni par le thème
- **Date de soutenance** : *September 7, 2026* (config-info)

### Structure des slides (61 pages PDF compilées)

Le PDF compilé fait **61 pages** — certains `#slide[...]` multi-blocs `][` génèrent plusieurs frames. Sections (`==`) principales (hors appendix, lignes ~74-1145) :

| Section | Contenu |
|---|---|
| `== Context` | Contexte NEMO/IA + image `nemo_stack_clean.png` |
| `== Supervised Classification` | Définitions ML supervisé |
| `== Federated Learning` | FL centralisé (+ citation McMahan) |
| `== Structured vs Unstructured networks` | 2 diagrammes fletcher côte à côte (grid) |
| `== Gossip Learning` | Diagramme fletcher + pseudocode (grid 2 colonnes) |
| `== Architecture`, `== Peer sampling`, `== Metrics`, `== Failures` | Cadre général |
| `== Elevator`, `== LIFT`, `== Hub-based topology`, ... | Contributions overlay |
| `== Hub Learning Protocol (HEAL)`, `== Datasets & Models` | Contributions apprentissage |
| `== FLAIR architecture/algorithm/results` | FLAIR |
| `== Conclusion`, `== Perspectives`, `== Publications` | Clôture (Publications inclut FLAIR NETYS 2026) |
| `= Appendix` (l. ~1146+) | Backup : algorithmes hub learning, simulation, métriques, FL, etc. (contenu en double/archivé) |

### Commande de compilation

```bash
typst compile --root . presentation/slides.typ presentation/slides.pdf
```

> ⚠️ Le flag `--root .` est obligatoire car les figures référencent `../Images/` en dehors du dossier `presentation/`.

### Pièges de code (Touying)

- **Pas de `][` dans les `#slide[...]`** : Touying utilise `][` comme séparateur de blocs de contenu — chaque bloc devient une frame séparée. Un `#grid(columns: ..)[cell1][cell2]` à l'intérieur d'un `#slide[]` sera interprété comme deux blocs de slide séparés. Utiliser `#grid(...)` avec les contenus comme arguments (sans `#` dans le contexte code, comme `fletcher-diagram(...)`, `pseudocode-list(...)`) pour les mises en page multi-cellules.
- **Pas de syntaxe LaTeX en mode math** : `\delta` → `delta`, `\subseteq` → `subset.eq`, `\log` → `log`, `\text{...}` → `"..."`, `\frac{a}{b}` → `a/b`, etc.
- **`str()` n'accepte pas le contenu** : pour les labels numériques dans les grilles, utiliser `str(num)` pour les entiers mais pas pour le contenu Typst.
- **Warning touying 0.6.1** : à la compilation, un warning apparaît sur `@preview/touying:0.6.1/src/pdfpc.typ` (query `<pdfpc>`) — sans conséquence sur le PDF généré.
- **Images** : les chemins sont relatifs au dossier `presentation/` (ex: `Elevator_normal_1000_100xp_indegree_color.svg`). Beaucoup de figures sont en SVG dans `presentation/` lui-même.

---

## 3. Synthèse scientifique du manuscrit

### 3.1 Question de recherche

> *Peut-on construire un système d'apprentissage décentralisé qui égale l'efficacité du federated learning centralisé, tout en étant entièrement décentralisé et résilient aux pannes et aux participants malveillants ?*

**Cadre de la thèse (révisé)** : la contribution principale est présentée comme une **architecture en couches pour l'apprentissage décentralisé** (abstract, introduction, résumé FR) — une couche overlay (Elevator) et une couche d'apprentissage fédéré décentralisé (HEAL), avec Lift en extension byzantine et FLAIR comme adaptation aux réseaux sans fil.

### 3.2 Contributions

| # | Contribution | Chapitre | Publication |
|---|---|---|---|
| 1 | **Elevator** — Protocole d'overlay P2P à émergence de hubs par attachement préférentiel | 4 | OUI (conf. internationale) |
| 2 | **Lift** — Extension byzantine-résiliente d'Elevator (redistribution déterministe via PRNG) | 4 | OUI (Outstanding Paper Award) |
| 3 | **HEAL** — Apprentissage fédéré décentralisé hiérarchique sur Elevator | 6 | OUI (conf. internationale + nationale) |
| 4 | **FLAIR** — Adaptation de HEAL aux réseaux sans fil (clustering LEACH-like) | 6 | OUI — accepté/présenté à NETYS 2026 (`boutebicha2026netys`, à paraître ; version arXiv `boutebicha2026flair` dans le .bib) |

### 3.3 Architecture en couches

```
┌─────────────────────────┐
│   Application Layer     │  Modèle ML (SVM, NN, ...)
├─────────────────────────┤
│   Aggregation Layer     │  FedAvg / moyennage intra/inter-hub
├─────────────────────────┤
│   Overlay Layer         │  Elevator (hub election) / LEACH (FLAIR)
├─────────────────────────┤
│   Network Layer         │  TCP/IP (HEAL) / WiFi 802.11 (FLAIR)
└─────────────────────────┘
```

### 3.4 Résultats clés d'Elevator

- Convergence en O(log N) cycles vers h hubs stables
- Diamètre ≈ 2 après convergence (graphe hub-and-spoke)
- Résilient aux crashs et au churn (réélection automatique des hubs)
- Déployé et validé sur réseau TCP/IP réel
- Modèle logistique pour le temps de convergence (ajustement empirique, RMSE < modèle géométrique)

### 3.5 Résultats clés de HEAL

- Accuracy comparable au Federated Learning centralisé en conditions nominales
  - Spambase : 0.90 (FL : 0.91, Gossip : 0.83)
  - MNIST : 0.97 (FL : 0.97, Gossip : 0.71)
- Convergence rapide : 0.95 accuracy en 76 cycles (MNIST), vs 91 pour FL
- Résilient aux crashs (même crash de tous les hubs simultanément)
- Résilient au churn (10-30%), récupération quasi-immédiate après fin du churn
- Overhead communication : 210 messages/cycle (vs 198 pour FL, 1000 pour Epidemic)

### 3.6 Résultats clés de FLAIR

- Validé sur simulateur ns-3 (réseau WiFi ad-hoc)
- Classification binaire uniquement (Spambase, Plants dataset)
- CH rotation assure le mixage global progressif sans coordination inter-clusters
- Résilient aux pannes de CH (réélection chaque round)

---

## 4. Statistiques du manuscrit

| Métrique | Valeur |
|---|---|
| Mots totaux (chapters + appendix) | ~84 000 |
| Lignes de code Typst | ~10 000 |
| Références bibliographiques | 169 |
| Figures / Images | 518 fichiers image dans `Images/` (PDF/SVG/PNG) ; ~143 blocs `figure` dans les chapitres |
| Définitions formelles | 74+ |
| Propositions / Preuves | 17+ (chapitre Elevator) |
| Publications issues de la thèse | 7 (dont 1 Outstanding Paper Award) |
| Langue du manuscrit | Anglais américain (uniformisé), sauf remerciements et résumé en français |

---

## 5. Évaluation critique (rôle de rapporteur)

### 5.1 Qualités remarquables

1. **Qualité rédactionnelle exceptionnelle** — L'introduction est magistrale, tissant un fil narratif entre histoire des réseaux, éthique de l'IA et question de recherche. Style fluide, précis, d'une maturité rare. L'une des meilleures plumes vues dans une thèse d'informatique.

2. **Programme de recherche cohérent** — La progression est implacable : modèle → état de l'art overlays → Elevator → état de l'art ML → HEAL → FLAIR. Chaque chapitre se justifie par les lacunes du précédent.

3. **Architecture en couches élégante** — La modularité Network/Overlay/Aggregation/Application est validée par FLAIR : substitution de deux couches donne un protocole fonctionnel pour un contexte radicalement différent.

4. **Pont inter-disciplinaire** — Relie les communautés P2P et ML avec un vocabulaire et un cadre formel communs. 74+ définitions formalisent le terrain d'entente.

5. **Évaluation multi-niveaux d'Elevator** — Théorie + simulation PeerSim + déploiement TCP/IP réel. Méthodologie solide et trop rare dans le domaine P2P.

6. **Honnêteté intellectuelle** — La section *Limitations* est exemplaire de lucidité. L'auteur identifie précisément les faiblesses sans chercher à les minimiser.

7. **Résumé français de qualité** — Clair, structuré, fidèle au contenu.

### 5.2 Faiblesses identifiées

1. **Profondeur théorique insuffisante** — Les « preuves » de convergence d'Elevator sont des arguments de plausibilité, pas des preuves au sens mathématique. Les approximations d'indépendance, les majorations informelles, et le modèle logistique comme ajustement de courbe (pas une dérivation) créent un décalage avec le formalisme affiché (44 définitions dans le chapitre Modèle).

2. **Échelle expérimentale modeste** — Elevator : 1 000 nœuds (la communauté P2P valide à 10K–100K). HEAL : 100 nœuds seulement. Seulement **5 runs** par configuration, sans barres d'erreur ni écart-type.

3. **Benchmarks ML datés** — LeNet5/MNIST (2010) et régression logistique/Spambase (1994) sont en deçà des standards 2024-2026.

4. **Absence de garantie de convergence pour HEAL** — La convergence est purement empirique. Aucun théorème, même sous hypothèses IID simplifiées. C'est un manque théorique significatif.

5. **Résilience byzantine limitée** — Lift protège uniquement l'overlay. Le seuil de tolérance (10% collusion) est faible. Le PRNG utilisé (LCG Java) est cryptographiquement faible sans discussion.

6. **Déséquilibre entre chapitres** — L'état de l'art overlays (15 100 mots) est disproportionné par rapport à l'évaluation de HEAL. Des protocoles écartés immédiatement sont détaillés sur plusieurs paragraphes.

7. **FLAIR : contribution secondaire** — Évaluation limitée à la classification binaire sur ns-3. Pas de comparaison directe avec HEAL dans les mêmes conditions. Plus une preuve de concept de modularité qu'une contribution à part entière.

8. **Hypothèse IID omniprésente** — Invalide largement la pertinence pratique. Dans les déploiements réels, les données sont non-IID par construction.

9. **Synchronisation implicite des hubs** — HEAL suppose une synchronisation pour la phase inter-hub, ce qui réintroduit une forme de coordination globale en tension avec l'objectif de décentralisation totale.

### 5.3 Grille d'évaluation

| Critère | Note (/4) | Commentaire |
|---|---|---|
| Qualité scientifique | 3 | Problème bien posé, méthodologie multi-niveaux, mais théorie insuffisamment rigoureuse |
| Originalité | 3.5 | Approche cross-layer genuinely novel ; émergence de hubs par attachement préférentiel originale |
| Maîtrise du domaine | 3.5 | État de l'art impressionnant en P2P et ML, quelques lacunes en théorie des probabilités |
| Qualité rédactionnelle | 4 | Exceptionnelle |
| Rigueur expérimentale | 2.5 | Échelle limitée, 5 runs, benchmarks datés, métriques incomplètes |
| Portée et impact | 3 | Publications solides (dont un award), ouverture d'un nouveau territoire |
| Autonomie et recul | 3.5 | Section Limitations exemplaire, perspectives bien argumentées |

### 5.4 Note globale

## **15 / 20** — *Mention Très Honorable*

**Justification :**

- Au-dessus de la moyenne (12-14) grâce à : l'écriture exceptionnelle, la cohérence du programme de recherche, l'originalité de l'approche cross-layer, les publications reconnues (award), et l'honnêteté intellectuelle sur les limites.

- En-deçà de l'excellence (16-18) à cause de : les preuves théoriques qui sont des arguments de plausibilité, l'échelle expérimentale en retrait (100 nœuds, 5 runs, LeNet5/MNIST), l'absence de garantie de convergence pour HEAL, l'hypothèse IID qui limite la portée pratique, et FLAIR comme contribution modeste.

- La note pourrait évoluer vers 16 si la soutenance démontre une profondeur théorique non apparente dans le manuscrit, ou présente des résultats complémentaires (échelle supérieure, benchmarks plus ambitieux, garanties de convergence).

---

## 6. Points de vigilance pour l'agent

### Zones du code à manipuler avec précaution

- `lib.typ` : le template est complexe (300+ lignes) avec de la logique conditionnelle sur les logos, le jury, les équations. Modifier un bloc peut casser la mise en page.
- `elevator.typ` : contient des figures Fletcher (graphes orientés) et des tableaux de RMSE/MAE fragiles.
- `heal.typ` : les diagrammes d'architecture (cetz) sont positionnés manuellement — les coordonnées sont hard-coded.
- `machine_learning.typ` : les diagrammes de Venn et de partitionnement de données utilisent des coordonnées absolues.
- `References.bib` : les clés de citation sont utilisées dans les chapitres via `@key` — renommer une clé casse les références croisées.

### Chapitres commentés mais existants

- `simulators.typ` : documentation de l'infrastructure de simulation (PeerSim, Gossipy, Docker). Contenu substantiel mais non inclus dans le manuscrit final.
- `variants_heal.typ` : 7 lignes seulement, pratiquement vide.

### Incohérences détectées

1. ~~L'abstract mentionne « image and text classification tasks » mais l'évaluation HEAL ne couvre que Spambase et MNIST~~ — **résolu** : Spambase est une tâche de classification de texte (emails) et MNIST d'images ; l'abstract révisé (architecture en couches) est cohérent avec l'introduction et le résumé FR.
2. ~~La date de soutenance est `01/01/1970` (placeholder)~~ — **résolu** : `07/09/2026` (page de garde, cohérent avec les slides).
3. ~~Les membres du jury sont des placeholders (`"Prénom Nom"`, `"Titre"`)~~ — **résolu** : jury complet (8 membres + 2 invitées) sur la page de garde.
4. ~~Le chapitre FLAIR mentionne CIFAR-10 dans les figures~~ — **résolu** : le fichier `Images/HEAL/normal_accuracy_Cifar_10_color.{svg,pdf}` existe toujours mais `heal.typ` ne le référence plus (aucune mention « cifar » dans les chapitres).
5. Le chapitre `simulators.typ` est commenté mais son contenu est référencé indirectement dans le résumé français et l'appendice.
6. `presentation/slides.typ` : thème `university` (commit `5d7fe10`), sections restructurées — certaines sections en double subsistent dans l'appendix ; l'ancienne section « Blockchain-based Federated Learning » et « == Me » sont commentées (pas supprimées).

---

*Dernière mise à jour : 2026-09-06 — alignement sur l'état final du manuscrit (abstract/intro/résumé FR « architecture en couches », orthographe US, date 07/09/2026, jury complet, FLAIR accepté NETYS 2026) et de la présentation (thème university, 61 pages)*
