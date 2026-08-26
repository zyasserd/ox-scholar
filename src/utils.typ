#import "@preview/hydra:0.6.2": hydra

/// Detects if the location contains a heading of the
/// specified level
#let page-has-heading = (loc, level: 1) => {
  query(heading.where(level: level)).any(h => (
    h.location().page() == loc.page()
  ))
}

/// A contents list for one chapter, holding only the sub-headings that
/// sit under it.
///
/// `outline()` cannot express this: its `target` selector is
/// document-wide, so it has no way to say "level-2 headings belonging to
/// *this* chapter". We therefore query the headings ourselves, taking
/// those that lie between this chapter's heading and the next level-1
/// heading.
///
/// The bound is positional rather than numeric on purpose. Matching on
/// the heading counter instead would break the moment a document resets
/// it, as an appendix does: with `counter(heading).update(0)` the first
/// appendix is numbered 1 again, so Chapter 1 would list Appendix A's
/// sections alongside its own.
///
/// Intended to be emitted from the level-1 heading show rule.
///
/// - cfg (dictionary): Configuration, defaulting per key as in
///   `CHAPTER_TOC_DEFAULTS`: `title` (none | content), `depth` (int),
///   `indent` (length), `gap` (length) between entries, and `style`, a
///   content-to-content function applied to the finished list.
#let chapter-outline(cfg) = context {
  let title = cfg.at("title", default: none)
  let depth = cfg.at("depth", default: 2)
  let indent = cfg.at("indent", default: 1.5em)
  let gap = cfg.at("gap", default: 0.5em)
  let style = cfg.at("style", default: it => it)

  let start = here()
  // This chapter runs until the next level-1 heading, or to the end of
  // the document if it is the last one.
  let following = query(heading.where(level: 1).after(start, inclusive: false))
  let within = if following.len() > 0 {
    selector(heading).after(start, inclusive: false).before(
      following.first().location(),
      inclusive: false,
    )
  } else {
    selector(heading).after(start, inclusive: false)
  }

  let entries = query(within).filter(entry => (
    entry.level >= 2
      and entry.level <= depth
      and entry.numbering != none
  ))

  if entries.len() > 0 {
    // The baseline. Emitted from inside the heading show rule, so this
    // also undoes the heading's own bold and indentation. It sits
    // *outside* the `style` call below, because the nearer `set` rule
    // wins: were it inside, a caller could never override any of it.
    set par(first-line-indent: 0em, leading: 0.65em, justify: false)
    set text(size: 10pt, weight: "regular")
    style(align(left, block(width: 100%, above: 0.5em, below: 2em, {
      if title != none {
        strong(title)
        v(0.4em, weak: true)
      }
      for entry in entries {
        let loc = entry.location()
        let num = numbering(entry.numbering, ..counter(heading).at(loc))
        let page-numbering = loc.page-numbering()
        let page-num = if page-numbering == none {
          str(loc.page())
        } else {
          numbering(page-numbering, ..counter(page).at(loc))
        }
        block(above: gap, below: gap, pad(
          left: indent * (entry.level - 2),
          link(loc)[
            #num #h(0.5em) #entry.body
            #box(width: 1fr, repeat[.])
            #page-num
          ],
        ))
      }
    })))
  }
}

/// Builds the header content. If the page has an h1 heading,
/// it suppresses the header. Otherwise, the content depends
/// on page parity. If the page is odd, it returns the latest
/// h1 title on the left and the page number on the right. If
/// the page is even, it returns the page number on the left
/// and the latest h2 on the right (or the latest h1 if the
/// no h2 exists yet).
#let make-header() = context {
  // If page has h1, suppress header
  if page-has-heading(here()) {
    return none
  }
  let latest-h1 = hydra(1)
  let latest-h2 = hydra(2)
  let page-display-num = counter(page).display()
  set text(style: "italic")
  if calc.odd(here().page()) {
    // Odd page: heading title --- page number
    latest-h1
    h(1fr)
    page-display-num
  } else {
    // Even page: page number --- heading title
    page-display-num
    h(1fr)
    if latest-h2 != none { latest-h2 } else { latest-h1 }
  }
}

/// Builds the footer content. If the page has an h1 heading
/// it returns a centre-aligned, italic page number.
/// Otherwise, it returns none.
#let make-footer() = context {
  set align(center)
  set text(style: "italic")
  if page-has-heading(here()) {
    counter(page).display()
  } else { none }
}
