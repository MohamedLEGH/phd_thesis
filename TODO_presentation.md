# TODO — Présentation de soutenance (slides.typ)

Travail à faire sur la présentation, à traiter élément par élément.

1. ~~Améliorer l'aspect graphique de la slide sur le supervised learning.~~ ✅ **FAIT** — titres du diagramme (Training, Data, Labels, Model, Prediction, Trained Model) mis en gras.
2. ~~Améliorer la slide sur le federated learning (ajouter un court pseudo-code).~~ ✅ **FAIT** — schéma agrandi + 2 pseudo-codes (Server/Client) en vrai pseudocode (affectations `←`, loop), citation McMahan en bas de slide.
3. ~~Ajouter une slide de comparaison gossip learning vs federated learning.~~ ✅ **FAIT** — slide activée avec figure `gossip_results.png` + citation Hegedűs et al. 2021 (JPDC).
4. ~~Rajouter le plan sur la slide architecture.~~ ✅ **FAIT** — slide « Contributions » : canvas 4 couches + « Outline » (Elevator/Lift/HEAL/FLAIR).
5. Revoir le code de FLAIR pour comprendre en détails les simu.
6. ~~Mettre les axes sur les figures.~~ ✅ **FAIT** (réglé par l'utilisateur).
7. Faire une animation pour Elevator.
8. ~~Rajouter Lift.~~ ✅ **FAIT** — slides : pseudo-code attaquants colludants, figure attaque réussie (5% hubs capturés), pseudo-code Lift (redistribution déterministe).
9. ~~Rajouter les 3 slides pour la partie théorique.~~ ✅ **FAIT** — slides Stability / Convergence (définition + Idea of the proof) / Speed of convergence (modèles géométrique + logistique, figure Nsize).
10. ~~Rajouter un tableau qui résume l'état de l'art.~~ ✅ **FAIT** — slide « State of the Art Summary » : tableau ✓/✗ (centralized, federated, decentralized/structured, gossip, local learning) avec colonnes Decentralized / Local data / Fast convergence / Fault-tolerant / No overlay overhead + mention « no generalizing model » pour local learning ; conclusion « No single solution is fully satisfactory ».
11. ~~Rajouter un tableau à la fin qui explique notre apport.~~ ✅ **FAIT** — slide « Overview » (ex-Conclusion) : tableau récapitulatif (Elevator / Elevator+Lift / Elevator+HEAL / FLAIR) avec colonnes Decentralized / Fast convergence / Fault-tolerant / Resistant to colluding / Learning / Network type (P2P vs Wireless).
12. ~~Rajouter une slide limitations.~~ ✅ **FAIT** — slide « Limitations » (après Overview) : 2 points (modèles ML simples ; explosion combinatoire des paramètres) + lien « feasibility trade-offs ».
13. ~~Mettre les logos (Sorbonne Université, LIP6, CNRS…) sur la première page (slide titre).~~ ✅ **FAIT** — title-slide standard restaurée + logo Sorbonne Université (config-info.logo, haut-droite) + superviseurs (authors).

Il y a d'autres choses ensuite, mais on commence par cette todo.

---
Fait en cours de route (hors numérotation) :
- Passage au thème university
- Slide Gossip Learning en grille 2 colonnes
- Slide Structured vs Unstructured : 2 diagrammes côte à côte
- Citations des titres de section déplacées en bas des slides (corps + appendix)
- Citations arXiv → conf/journal (Elevator → NCA 2024 ; survey blockchain → Huang IEEE Network 2023)
