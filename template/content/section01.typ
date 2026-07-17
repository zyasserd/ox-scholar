#import "@preview/ox-scholar:0.2.1": section

#show: section.with(
  bib: bibliography("bibliography.bib"),
  quote: (
    quote: "... ἔοικα γοῦν τούτου γε σμικρῷ τινι αὐτῷ τούτῳ σοφώτερος εἶναι, ὅτι ἃ μὴ οἶδα οὐδὲ οἴομαι εἰδέναι.",
    author: "Plato"
  )
)

= Section Title

== Subsection Title
#lorem(30) Example citation @article1.

=== Subsection Title
#lorem(50)

#lorem(150)

=== Subsection Title
#lorem(50)

#lorem(50) Example citation @article2.
