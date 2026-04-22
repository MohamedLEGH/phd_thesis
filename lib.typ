// global
#import "@preview/great-theorems:0.1.2": great-theorems-init
#import "@preview/hydra:0.6.0": hydra
#import "@preview/equate:0.3.0": equate
#import "@preview/i-figured:0.2.4": reset-counters, show-equation

#let template(  
  language: "fr",
  // file paths for logos etc.
  uni-logo: none,
  lab-logo: none,
  orga1-logo: none,
  orga2-logo: none,
  university: "Example University",
  doctoralschool: "Doctoral School",
  lab: "Example lab",
  title: "Title",
  subtitle: "Subtitle",
  author: (
    firstname: "Firstname",
    lastname: "Lastname",
  ),
  supervisors: (
    (
      titlecivility: "Prof./Mr/Mrs/Dr/etc.",
      firstname: "Firstname",
      lastname: "Lastname",
    ),
  ),
  degree: "Degree",
  speciality: "Speciality",
  date: datetime.today(),
  examboard: (
    (
      firstname: "Firstname",
      lastname: "Lastname",
      title: "Title",
      role: "Role"
    ),
  ),

  license-logo: none,
  license-text: "License-text",

  // formatting settings
  body-font: "Libertinus Serif",
  cover-font: "Libertinus Serif",

  // content that needs to be placed differently then normal chapters
  abstract: none,

  // colors
  cover-color: rgb("#800080"),
  heading-color: rgb("#0000ff"),
  link-color: rgb("#000000"),

  // equation settings
  equate-settings: none,
  equation-numbering-pattern: "(1.1)",

  // supervised by text
  supervised-by: "Encadrement de la Thèse",

  // the content of the thesis
  body
) = {
// ------------------- settings -------------------
set document(author: author.firstname + " " + author.lastname, title: title)
set heading(numbering: "1.1")  // Heading numbering
set enum(numbering: "(i)") // Enumerated lists
show link: set text(fill: link-color)
show ref: set text(fill: link-color)

// ------------------- Math equation settings -------------------

// either use equate if equate-settings is set or use i-figured if equate-settings is none
// i-figured settings
show math.equation: it => {
  if equate-settings == none {
    show-equation(prefix: "eq:", only-labeled: true, numbering: equation-numbering-pattern, it)
  } else {
    it
  }
}
set math.equation(supplement: none) if equate-settings == none

// equate settings
show: it => {
  if equate-settings != none {
    equate(..equate-settings, it)
  } else {
    it
  }
}
set math.equation(numbering: equation-numbering-pattern) if equate-settings != none

// Reference equations with parentheses (for equate)
// cf. https://forum.typst.app/t/how-can-i-set-numbering-for-sub-equations/1603/4
show ref: it => {
  let eq = math.equation
  let el = it.element

  let is-normal-equation = el != none and el.func() == eq
  let with-subnumbers = (
    equate-settings != none and
    equate-settings.keys().contains("sub-numbering") and
    equate-settings.sub-numbering
  )
  let is-sub-equation = el != none and el.func() == figure and el.kind == eq
  if equate-settings != none and is-normal-equation {
    link(el.location(), numbering(
      el.numbering,
      ..counter(eq).at(el.location())
    ))
  } else if equate-settings != none and not with-subnumbers and is-sub-equation {
    link(el.location(), numbering(
      el.numbering,
      counter(eq).at(el.location()).at(0) - 1
    ))
  } else if equate-settings != none and is-sub-equation {
    link(el.location(), numbering(
      el.numbering,
      ..el.body.value
    ))
  } else {
    it
  }
}

show math.equation: box  // no line breaks in inline math
show: great-theorems-init  // show rules for theorems


// ------------------- Settings for Chapter headings -------------------
show heading.where(level: 1): set heading(supplement: [Chapter])
show heading.where(
  level: 1,
): it => {
  if it.numbering != none {
    block(width: 100%)[
      #line(length: 100%, stroke: 0.6pt + heading-color)
      #v(0.1cm)
      #set align(left)
      #set text(22pt)
      #text(heading-color)[Chapter
      #counter(heading).display(
        "1:" + it.numbering
      )]

      #it.body
      #v(-0.5cm)
      #line(length: 100%, stroke: 0.6pt + heading-color)
    ]
  }
  else {
    block(width: 100%)[
      #line(length: 100%, stroke: 0.6pt + heading-color)
      #v(0.1cm)
      #set align(left)
      #set text(22pt)
      #it.body
      #v(-0.5cm)
      #line(length: 100%, stroke: 0.6pt + heading-color)
    ]
  }
}
// Automatically insert a page break before each chapter
show heading.where(
  level: 1
): it => {
  pagebreak(weak: true)
  it
}
// only valid for abstract and declaration
show heading.where(
  outlined: false,
  level: 2
): it => {
  set align(center)
  set text(18pt)
  it.body
  v(0.5cm, weak: true)
}
// Settings for sub-sub-sub-sections e.g. section 1.1.1.1
show heading.where(
  level: 4
): it => {
  it.body
  linebreak()
}
// same for level 5 headings
show heading.where(
  level: 5
): it => {
  it.body
  linebreak()
}

// reset counter from i-figured for section-based equation numbering
show heading: it => {
  if equate-settings == none {
    reset-counters(it)
  } else {
    it
  }
}
// ------------------- other settings -------------------
// Settings for Chapter in the outline
show outline.entry.where(
  level: 1,
  fill: line(length: 100%, stroke: (thickness: 1pt, dash: "loosely-dotted"))
): it => {
  v(14.75pt, weak: true)
  strong(it)
}

// table label on top and not below the table
show figure.where(
  kind: table
): set figure.caption(position: top)

// ------------------- Cover -------------------
set text(font: cover-font)  // cover font

// A function to represent a virtual image
let vimg(body) = {
    rect(width: 10mm, height: 5mm)[
        #text(body)
    ]
}

v(1fr)
//logos
  if uni-logo != none and lab-logo != none and orga1-logo != none and orga2-logo != none {
    align(center,
      grid(
        columns: (4),
        column-gutter: 66pt,
        grid.cell(
          colspan: 1,
          align: center,
          uni-logo,
        ),
        grid.cell(
          colspan: 1,
          align: center,
          lab-logo,
        ),
        grid.cell(
          colspan: 1,
          align: center,
          orga1-logo,
        ),
        grid.cell(
          colspan: 1,
          align: center,
          orga2-logo,
        )
      )
    )
  } else if uni-logo != none and lab-logo != none and orga1-logo != none and orga2-logo == none {
    align(center,
      grid(
        columns: (3),
        rows: (1),
        column-gutter: 114pt,
        grid.cell(
          colspan: 1,
          align: center,
          uni-logo,
        ),
        grid.cell(
          colspan: 1,
          align: center,
          lab-logo,
        ),
        grid.cell(
          colspan: 1,
          align: center,
          orga1-logo,
        )
      )
    )
  }
align(center, text(24.88pt, weight: 500, university))
align(center, text(12pt, weight: 500, doctoralschool))
align(center, text(12pt, weight: 500, style: "italic", lab))
v(1fr)
//title
align(center, text(17.28pt, weight: 700, title))
//subtitle
if subtitle != none {
  align(center, text(14.4pt, weight: 500, style: "italic", subtitle))
}

v(0.5fr)
//author
if language == "fr" {
  align(center, text(14.4pt, weight: 500, "Par " + author.firstname + " " + smallcaps(author.lastname)))
} else {
  align(center, text(14.4pt, weight: 500, "By " + author.firstname + " " + smallcaps(author.lastname)))
}

v(1fr)
//study speciality
align(center, text(1.3em, weight: 100, degree + " " + speciality))



// supervisors
if language == "fr" {
  supervised-by = "Dirigée par"
}

if supervisors.len() == 1 {
  align(center + bottom, text(1.3em, weight: 100, supervised-by + " " +
    supervisors.map(supervisor => {
      supervisor.titlecivility + " " + supervisor.firstname + " " + smallcaps(supervisor.lastname) + linebreak()
    }).join()
))
} else if supervisors.len() > 1 {
  align(center + bottom, text(1.3em, weight: 100, supervised-by + linebreak() +
  supervisors.map(supervisor => {
    supervisor.titlecivility + " " + supervisor.firstname + " " + smallcaps(supervisor.lastname) + linebreak()
  }).join()
))
}
  
// Publicly presented and defended on text
if language == "fr" {
  align(
    center, text(1.3em, weight: 100, "Présentée et soutenue publiquement le " + date.display("[day]/[month]/[year]"))
  )
  align(left, text(1.5em, weight: 500, "Devant un jury composé de :"))
} else {
  align(
    center, text(1.3em, weight: 100, "Publicly presented and defended on " + date.display("[day]/[month]/[year]"))
  )
  align(left, text(1.5em, weight: 500, "In front of the jury composed of:"))
}


// Jury members
align(center)[
  #table(
    columns: (2fr, 2fr, 2fr),
    align: (col, row) => (center, center, center, center).at(col),
    inset: 3pt,
    stroke: none,
    ..examboard
        .map(member => {
          (
            [#member.firstname],
            [#smallcaps([#member.lastname])],
            // [#member.title],
            [#member.role],
          )
        })
        .flatten()
  )
]

v(0.5fr)

// License
if license-logo != none {
  align(center,
    grid(
      columns: (2),
      rows: (1),
      column-gutter: 6pt,
      grid.cell(
        colspan: 1,
        align: right,
        license-logo,
      ),
      grid.cell(
        colspan: 1,
        align: left + horizon,
        license-text,
      )
    )
  )
} else {
  align(center, license-text)
}


pagebreak()

// ------------------- Abstract -------------------
set text(font: body-font)  // body font
if abstract != none{
  abstract
}


set page(
  numbering: "1",
  number-align: center,
  header: context {
    align(center, emph(hydra(1)))
    v(0.2cm)
  },
)  // Page numbering after cover & abstract => they have no page number
pagebreak()

// ------------------- Tables of ... -------------------

// Table of contents
outline(depth: 3, indent: 1em)
pagebreak()

// List of figures
outline(
  title: [List of Figures],
  target: figure.where(kind: image))
pagebreak()


// List of Tables
outline(
  title: [List of Tables],
  target: figure.where(kind: table))
pagebreak()



// ------------------- Content -------------------
body
}