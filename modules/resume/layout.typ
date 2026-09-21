#import "content.typ" as c

#set document(title: c.name + " - Resume", author: c.name)
#set page(paper: "a4", margin: (x: 1.5cm, y: 1.4cm))
#set text(font: "New Computer Modern", size: 10.5pt, lang: "en", ligatures: false, hyphenate: false)
#set par(justify: true, leading: 0.55em)
#set list(indent: 0.6em, spacing: 0.55em)

#show heading.where(level: 1): it => block(above: 1em, below: 1em)[
  #set text(size: 12pt, weight: "bold")
  #smallcaps(it.body)
  #v(-0.5em)
  #line(length: 100%, stroke: 0.5pt + black)
]

#show link: it => text(fill: black, it)

#align(center)[
  #text(size: 20pt, weight: "bold")[#c.name]
  #v(0.5em, weak: true)
  #text(size: 13pt)[#c.title]
  #v(0.5em, weak: true)
  #c.contacts.map(x => if x.url == none { x.text } else { link(x.url)[#x.text] }).join([ | ])
]

= Summary
#c.summary

= Experience
#let entry(e) = block(above: 1.5em, breakable: false)[
  #grid(
    columns: (1fr, auto),
    [*#e.org* --- _#e.role;_ --- _#e.location;_],
    align(right)[#e.dates],
  )
  #if e.intro != none [
    #v(1em, weak: true)
    #e.intro
  ]
  #v(1em, weak: true)
  #list(..e.bullets)
  #if e.stack != none [
    #v(1em, weak: true)
    *Stack:* #e.stack
  ]
]
#for e in c.experience { entry(e) }

= Education
#for ed in c.education [
  #grid(
    columns: (1fr, auto),
    [*#ed.school* --- #ed.degree],
    align(right)[#ed.dates],
  )
]

