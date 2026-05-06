# AGENTS.md — Analyse du dépôt de thèse

> Ce document synthétise la compréhension du dépôt, la structure du code Typst,
> le contenu scientifique du manuscrit, et une évaluation critique en tant que rapporteur.

---

## 1. Structure du dépôt

```
phd_thesis/
├── main.typ                              # Point d'entrée : métadonnées + inclusion des chapitres
├── lib.typ                               # Template Typst : page de garde, TOC, en-têtes, numérotation
├── thesis_flatV11.typ                    # Version aplatie (mono-fichier) du manuscrit (~520 Ko)
├── diff9to11_fixed.typ                   # Diff entre versions v9 et v11
├── typst_flatten.py                      # Script Python pour aplatir les includes en un seul .typ
├── Phd_thesis_typdiff_v9_to_v11.pdf      # PDF du diff visuel entre v9 et v11
├── template/
│   ├── References.bib                    # Bibliographie BibTeX (167 entrées, 1532 lignes)
│   ├── customization/
│   │   ├── colors.typ                    # Palette de couleurs (cover, headings, liens)
│   │   └── great-theorems-customized.typ # Personnalisation du package great-theorems
│   ├── chapter/
│   │   ├── abstract.typ                  # Abstract en anglais (35 lignes)
│   │   ├── remerciements.typ             # Remerciements (74 lignes)
│   │   ├── resume_fr.typ                 # Résumé en français (257 lignes)
│   │   ├── introduction.typ              # Introduction générale (78 lignes, ~3 500 mots)
│   │   ├── model.typ                     # Chap. 2 : Modèle formel (693 lignes, ~6 800 mots)
│   │   ├── overlay.typ                   # Chap. 3 : État de l'art overlays P2P (862 lignes, ~15 100 mots)
│   │   ├── elevator.typ                  # Chap. 4 : Elevator & Lift (1 372 lignes, ~14 600 mots)
│   │   ├── machine_learning.typ          # Chap. 5 : État de l'art ML décentralisé (1 485 lignes, ~8 500 mots)
│   │   ├── heal.typ                      # Chap. 6 : HEAL & FLAIR (1 559 lignes, ~12 500 mots)
│   │   ├── conclusions_outlook.typ       # Chap. 7 : Conclusions et perspectives (341 lignes, ~4 000 mots)
│   │   ├── publications.typ              # Liste des publications (27 lignes)
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
│   └── 1_ieIdnYcxt4kS71uA1QsFGw_arpanet.webp  # Image ARPANET (intro)
├── Logos/
│   ├── SORBONNE UNIVERSITÉ/
│   ├── LIP6/
│   ├── CNRS/
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
- La date de soutenance est mise à `01/01/1970` (placeholder)
- Le jury contient des noms génériques `"Prénom Nom"` (à compléter)
- Les figures sont toutes en PDF vectoriel (sauf une image webp ARPANET)

---

## 3. Synthèse scientifique du manuscrit

### 3.1 Question de recherche

> *Peut-on construire un système d'apprentissage décentralisé qui égale l'efficacité du federated learning centralisé, tout en étant entièrement décentralisé et résilient aux pannes et aux participants malveillants ?*

### 3.2 Contributions

| # | Contribution | Chapitre | Publication |
|---|---|---|---|
| 1 | **Elevator** — Protocole d'overlay P2P à émergence de hubs par attachement préférentiel | 4 | OUI (conf. internationale) |
| 2 | **Lift** — Extension byzantine-résiliente d'Elevator (redistribution déterministe via PRNG) | 4 | OUI (Outstanding Paper Award) |
| 3 | **HEAL** — Apprentissage fédéré décentralisé hiérarchique sur Elevator | 6 | OUI (conf. internationale + nationale) |
| 4 | **FLAIR** — Adaptation de HEAL aux réseaux sans fil (clustering LEACH-like) | 6 | Non publié (preuve de concept de modularité) |

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
| Références bibliographiques | 167 |
| Figures / Images | ~373 |
| Définitions formelles | 74+ |
| Propositions / Preuves | 17+ (chapitre Elevator) |
| Publications issues de la thèse | 5 (dont 1 Outstanding Paper Award) |
| Langue du manuscrit | Anglais (sauf remerciements, résumé FR) |

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

3. **Benchmarks ML datés** — LeNet5/MNIST (2010) et régression logistique/Spambase (1994) sont en deçà des standards 2024-2026. L'abstract mentionne « text classification » sans évaluation correspondante dans les chapitres.

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

1. L'abstract mentionne « image and text classification tasks » mais l'évaluation HEAL ne couvre que Spambase (binaire) et MNIST (image). Pas de tâche de classification de texte.
2. La date de soutenance est `01/01/1970` (placeholder).
3. Les membres du jury sont des placeholders (`"Prénom Nom"`, `"Titre"`).
4. Le chapitre FLAIR mentionne CIFAR-10 dans les figures (`normal_accuracy_Cifar_10_color.pdf`) mais le texte ne semble pas évaluer sur CIFAR-10.
5. Le chapitre `simulators.typ` est commenté mais son contenu est référencé indirectement dans le résumé français et l'appendice.

---

*Dernière mise à jour : 2026-05-06*
