// global
#import "lib.typ": template

//local
#import "template/customization/colors.typ": *


#show: template.with(
  language: "en",
  uni-logo: image("Logos/SORBONNE UNIVERSITÉ/SORBONNE_UNIVERSITE.svg", height: 32pt),
  lab-logo: image("Logos/LIP6/LIP6.svg", height: 32pt),
  orga1-logo: image("Logos/CNRS/CNRS.svg", height: 32pt),
  orga2-logo: image("Logos/logoSuppl.png", height: 32pt),
  university: "Sorbonne Université",
  doctoralschool: "École Doctorale Informatique, Télécommunications et Électronique (ED130)",
  lab: "Laboratoire d'Informatique de Paris 6",
  title: "Efficient and Resilient Decentralized Learning Protocols",
  subtitle: "Theory, Design and Evaluation",
  author: (
    firstname: "Mohamed Amine",
    lastname: "LEGHERABA",
  ),
  degree: "PhD Thesis",
  speciality: "of Computer Science",
  supervisors: (
    (
      titlecivility: "",
      firstname: "Prénom",
      lastname: "Nom"
    ),
  ),
  date: datetime.today(),
  examboard: (
    (
      firstname: "Prénom",
      lastname: "Nom",
      title: "Titre",
      role: "Directrice de thèse"
    ),
    (
      firstname: "Prénom",
      lastname: "Nom",
      title: "Titre",
      role: "Directeur de thèse"
    ),
    (
      firstname: "Prénom",
      lastname: "Nom",
      title: "Titre",
      role: "Rapporteur⸱euse"
    ),
    (
      firstname: "Prénom",
      lastname: "Nom",
      title: "Titre",
      role: "Rapporteur⸱euse"
    ),
    (
      firstname: "Prénom",
      lastname: "Nom",
      title: "Titre",
      role: "Examinateur·rice"
    ),
    (
      firstname: "Prénom",
      lastname: "Nom",
      title: "Titre",
      role: "Examinateur·rice"
    ),
    (
      firstname: "Prénom",
      lastname: "Nom",
      title: "Titre",
      role: "Invité·e"
    ),
  ),
  license-logo: image("Logos/LICENSE/by-nc-nd.eu.svg", height: 32pt),
  license-text: (
    "Except where otherwise noted, this work is licensed under " +
    linebreak() +
    text(weight: "bold", link("https://creativecommons.org/licenses/by-nc-nd/4.0/"))
  ),


  // file paths for logos etc.
 
  // formatting settings
  body-font: "Libertinus Serif",
  cover-font: "Libertinus Serif",

  // chapters that need special placement
  abstract: include "template/chapter/abstract.typ",

  // equation settings
  equate-settings: (breakable: true, sub-numbering: true, number-mode: "label"),
	equation-numbering-pattern: "(1.1)",

  // colors
  cover-color: color1,
  heading-color: color2,
  link-color: color3
)

// ------------------- content -------------------
#include "template/chapter/introduction.typ"
#include "template/chapter/model.typ"
#include "template/chapter/peertopeer.typ"
#include "template/chapter/elevator.typ"
#include "template/chapter/decentralized_learning.typ"
#include "template/chapter/heal.typ"
#include "template/chapter/heterogeneous_network.typ"
#include "template/chapter/variants_heal.typ"
#include "template/chapter/simulators.typ"
#include "template/chapter/conclusions_outlook.typ"
#include "template/chapter/appendix.typ"

// ------------------- bibliography -------------------
#bibliography("template/References.bib")

// ------------------- declaration -------------------
#include "template/chapter/declaration.typ"