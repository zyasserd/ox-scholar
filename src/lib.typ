#import "title.typ": title-page
#import "frontmatter.typ": frontmatter-page
#import "bibliography.typ": bibliography-page
#import "utils.typ": make-footer, make-header
#import "@preview/wordometer:0.1.5": word-count as wordometer-count



// Elements excluded from the word count to match the CS Dep specifications:
//
// Word count does not include:
// - Table of contents
// - All mathematical equations and symbols
// - Diagrams
// - Tables
// - Bibliography
// - Texts of computer programs
// - Headings that are included on the top of each page (in the ‘Header’ field).
// - Acknowledgements (not in the preface)
// - Algorithm pseudocode if it is part of a table or a figure
//
// Word count includes:
// - Preface
// - Footnotes
// - Appendices
// - Captions for the diagrams and tables
// - Headings
// - Algorithm pseudocode if it is part of the text/ narrative
// - Text from a mathematical proof
//
// Elements excluded from the word count to match the University of
// Equations, symbols, images/diagrams, citations and the bibliography
// are already excluded by wordometer's defaults, so this set
// adds the remaining cases:
//   - "figure-body": drops the contents of figures (diagrams, tables,
//     images, algorithm pseudocode inside a figure) while KEEPING their
//     captions, which Oxford counts.
//   - table: drops the contents of bare (non-figure) tables.
//   - outline: drops the table of contents.
//   - raw.where(block: true): drops the text of computer programs
//     (fenced code blocks). Inline `raw` is left in, as it is usually
//     part of the narrative.
#let OXFORD_WORD_COUNT_EXCLUDE = (
  "figure-body",
  table,
  outline,
  bibliography
  // raw.where(block: true),
)

// State marker set while inside `thesis()`. A standalone `section()`
// checks this to decide whether to apply the full page/text styling
// itself (when compiled alone) or stay bare (when `include`d into the
// thesis, where `thesis()` already provides the styling).
#let _in-thesis = state("ox-scholar-in-thesis", false)

// Word-count configuration broadcast from `thesis()` to the `section()`
// wrappers in the included files. `none` means word counting is off; when
// on it holds `(exclude: <array>)`.
//
// The counting MUST happen inside each `section()`'s `context` block (see
// `section()`), not at the `thesis()` level. wordometer counts by walking
// the raw content tree, and a `#show: section` turns a whole section into
// an opaque `context` element whose text is invisible to that walk. So a
// word-count show rule wrapped around the sections from the outside counts
// zero — the text only becomes concrete once we are *inside* the context.
#let _word-count = state("ox-scholar-word-count", none)


// 1. Define the state globally outside your template function
#let chapter-quote = state("chapter-quote", none)

/// Shared document styling used by both the full thesis and standalone
/// section files. Applied as a show rule: `#show: thesis-styles.with(..)`.
#let thesis-styles(draft: false, body) = {
  set page(
    paper: "a4",
    margin: (
      inside: 3.6cm,
      outside: 2.6cm,
      top: 4cm,
      bottom: 2.5cm,
    ),
    header: make-header(),
    footer: make-footer(),
  )

  set par(
    first-line-indent: 1.5em,
    justify: true,
    leading: 1.5em,
  )

  // Show line numbers if draft mode is enabled
  set par.line(
    numbering: if draft { "1" } else { none },
  )

  set text(
    font: "New Computer Modern",
    size: 12pt,
  )

  // Suppress header, footers and numbering on
  // empty pages
  show selector.or(
    pagebreak.where(to: "odd"),
    pagebreak.where(to: "even"),
  ): set page(
    header: none,
    footer: none,
    numbering: none,
  )

  // Heading styling
  set heading(numbering: "1.1.1")
  // Add some spacing above and below headings
  show heading: it => {
    v(1em)
    it
    v(1em)
  }
  // Style level 1 headings
  show heading.where(level: 1): it => {
    // Place level 1 headings on a new odd page
    pagebreak(weak: true, to: "odd")
    
    // 2. Add the context block to read the state and render the quote
    context {
      let q = chapter-quote.get()
      if q != none {
        // Enforce left alignment for the quote block
        // align(left)[
        //   #text(style: "italic", size: 11pt)[#q.quote]
        //   #if q.at("author", default: none) != none [
        //     \ --- #q.author
        //   ]
        // ]
        set text(
          font: "New Computer Modern",
          size: 12pt,
          weight: "regular",
          style: "italic"
        )
        block(width: 60%)[
          #quote(block: true, attribution: q.author)[#q.quote]
        ]
        v(-2.5cm)

        // Reset state so it doesn't leak to the next chapter
        chapter-quote.update(none)
      }
    }

    // 3. Keep your original heading styling aligned to the right
    set align(right)
    v(2.5cm)
    // Only show heading number if numbering is set
    if it.numbering != none {
      v(1.5cm)
      let num = counter(heading).display()
      text(size: 90pt, weight: 900, fill: gray)[#num]
      linebreak()
    }
    text(size: 24pt, weight: 100)[#it.body]
    v(1em)
  }

  body
}

/// Wrapper for an individual thesis section/chapter file.
///
/// When the file is `include`d into the main thesis, `thesis()` has
/// already applied all styling, so this just emits the body unchanged.
/// When the file is compiled on its own, it applies `thesis-styles` so
/// it still looks like part of the thesis.
///
/// Usage at the top of a section file:
/// ```typ
/// #import "@preview/ox-scholar:0.2.1": section
/// #show: section
///
/// = My Section
/// ...
/// ```
///
/// If the section cites sources, pass a bibliography so it can resolve
/// citations when compiled on its own (it is ignored when included):
/// ```typ
/// #show: section.with(bib: bibliography("refs.bib"))
/// ```
///
/// - draft (bool): Show line numbers when compiled standalone.
/// - bib (content): Optional bibliography for standalone compilation.
#let section(draft: false, quote: none, bib: none, body) = context {
  chapter-quote.update(quote)

  if _in-thesis.get() {
    // Included in the thesis: styling already applied upstream, and
    // the thesis provides the bibliography, so emit the body as-is.
    // If word counting is on, count `body` here — inside this context,
    // where the text is concrete — accumulating into wordometer's global
    // `total-words` state (see `_word-count`).
    let wc = _word-count.get()
    if wc != none {
      wordometer-count(body, exclude: wc.exclude)
    } else {
      body
    }
  } else {
    // Compiled standalone: apply the shared styling and number pages.
    set page(numbering: "1")
    show: thesis-styles.with(draft: draft)
    body
    // Resolve any citations against a local bibliography if provided.
    if bib != none { bib }
  }
}

/// Generates the thesis layout
#let thesis(
  title: none,
  author: none,
  college: none,
  degree: "Doctor of Philosophy",
  submission-term: none,
  acknowledgements: none,
  abstract: none,
  logo: none,
  show-toc: true,
  bib: none,
  draft: false,
  word-count: false,
  word-count-exclude: OXFORD_WORD_COUNT_EXCLUDE,
  body,
) = {
  // Validate inputs
  assert(title != none, message: "Thesis title must be provided")
  assert(author != none, message: "Thesis author must be provided")

  // =========== Document settings ===========
  set document(
    title: title,
    author: author,
  )

  // Mark that we are inside the full thesis, so that any `section()`
  // wrappers in included files stay bare instead of re-applying styling.
  _in-thesis.update(true)

  // Turn on word counting for the sections. This must be set before the
  // sections render, because `section()` reads it with `.get()`. The
  // counting itself happens inside each section (see `_word-count`).
  if word-count {
    _word-count.update((exclude: word-count-exclude))
  }

  // Apply the shared document styling.
  show: thesis-styles.with(draft: draft)

  // If word counting is enabled, count the main body (see below) and
  // wrap it so wordometer's global `total-words` state is populated.
  // The counter is applied only to `body`, so front matter, headings,
  // and bibliography are excluded from the reported figure.

  // ============== Title page ==============
  title-page(
    title: title,
    author: author,
    college: college,
    degree: degree,
    submission-term: submission-term,
    logo: logo,
    word-count: word-count,
  )
  // Skip a page after title
  pagebreak(to: "odd")

  // ============== Frontmatter =============
  // Set latin page numbering
  set page(numbering: "i")
  counter(page).update(1)

  // Acknowledgements
  if acknowledgements != none {
    frontmatter-page(title: "Acknowledgements")[
      #acknowledgements
    ]
  }

  // Abstract
  if abstract != none {
    frontmatter-page(title: "Abstract")[
      #abstract
    ]
  }

  // Table of contents
  if show-toc {
    outline(
      title: "Contents",
      indent: 2em,
      depth: 2,
    )
    pagebreak(weak: true, to: "odd")
  }

  // ============== Main body ==============
  // Page numbering
  set page(numbering: "1")
  counter(page).update(1)

  // Count words in the main body only (excludes front matter and the
  // bibliography). `total-words` on the title page reads this value.
  // The exclude set applies Oxford's counting rules (see
  // OXFORD_WORD_COUNT_EXCLUDE).
  if word-count {
    show: wordometer-count.with(exclude: word-count-exclude)
    body
  } else {
    body
  }

  // ============ Bibliography =============
  if bib != none {
    bibliography-page(bib)
  }
}
