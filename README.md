# ox-scholar
[![Typst Universe](https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fox-scholar&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&label=universe&logo=typst&color=39cccc)](https://typst.app/universe/package/ox-scholar)
[![Repo](https://img.shields.io/badge/GitHub-repo-blue)](https://github.com/fcelli/ox-scholar)
[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)
![Release](https://img.shields.io/github/v/release/fcelli/ox-scholar)
[![Tests](https://github.com/fcelli/ox-scholar/actions/workflows/tests.yml/badge.svg)](https://github.com/fcelli/ox-scholar/actions/workflows/tests.yml)

Unofficial Typst template for an Oxford DPhil thesis.

<p align="center">
  <picture>
    <img src="thumbnail.png" style="width: 300px; height: auto;">
  </picture>
</p>

## Getting Started
To get started with Typst, please refer to the official [installation guide](https://github.com/typst/typst?tab=readme-ov-file#installation).

Once the Typst CLI is installed on your system, you can set up a new project using this template:
```shell
typst init @preview/ox-scholar:0.2.1
```

The template includes a pre-filled example demonstrating the basic layout. You can compile it to PDF with:
```shell
typst compile main.typ
```

For live preview while editing:
```shell
typst watch main.typ
```

A preview of the latest version of the default template is available on the ox-scholar [wiki](https://github.com/fcelli/ox-scholar/wiki#gallery).

### Thesis Function Documentation
The template provides a `thesis()` function that generates the thesis layout. You can use it with the parameters in the table below.

| Parameter |        Type       |        Description        | Default |
|-----------|-------------------|---------------------------|---------|
| `body`    | `content`         | The thesis content        |    —    |
| `title`   | `content \| none` | Full title of the thesis  | `none`  |
| `author`  | `content \| none` | Author’s full name        | `none`  |
| `college` | `content \| none` | Author’s college          | `none`  |
| `degree`  | `content`         | The degree being pursued  | `Doctor of Philosophy` |
| `submission-term` | `content \| none` | The term and year of submission (e.g., “Trinity Term, 2025”) | `none` |
| `acknowledgements` | `content \| none` | Content for the acknowledgements page | `none` |
| `abstract` | `content \| none` | Content for the abstract page | `none` |
| `logo`     | `image \| none`   | Image for the University or college logo | `none` |
| `toc`      | `dictionary \| none` | Table of contents: `none` omits it, otherwise the keys override `TOC_DEFAULTS` (`title`, `indent`, `depth`, `style`); anything else is passed on to `outline()` | `(:)` |
| `chapter-toc` | `dictionary \| none` | Per-chapter contents list after each chapter heading: `none` omits it, otherwise the keys override `CHAPTER_TOC_DEFAULTS` (`title`, `depth`, `indent`, `gap`, `style`) | `none` |
| `bib`      | `content \| none` | Content for the bibliography | `none` |
| `draft`    | `bool`            | Whether to show line numbers | `false` |
| `word-count` | `bool`          | Whether to show the body word count on the title page | `false` |
| `word-count-exclude` | `array` | Elements excluded from the word count (see [Word count](#word-count)) | Oxford's rules |

Example usage:
```typ
#import "@preview/ox-scholar:0.2.1": *

#show: thesis.with(
  title: "Thesis Title",
  author: "Author",
  college: "College",
  degree: "Doctor of Philosophy",
  submission-term: "Submission Term, Year",
  acknowledgements: include "content/acknowledgements.typ",
  abstract: include "content/abstract.typ",
  logo: image("assets/beltcrest.png", width: 4.5cm),
  toc: (depth: 2),
  chapter-toc: (
    title: [In this chapter],
    // `style` is applied to the finished list, like a show rule.
    style: it => { set text(size: 9pt); it },
  ),
  bib: bibliography(
    "content/bibliography.bib",
    title: "References",
  ),
  word-count: true
)

#include "content/section01.typ"
```

## Tables of contents
Both `toc` and `chapter-toc` take the same three shapes: `none` omits the
contents entirely, `(:)` uses the defaults, and a dictionary overrides
individual keys of the defaults, leaving the rest alone.

```typ
toc: none                  // no contents page
toc: (:)                   // contents page, as TOC_DEFAULTS has it
toc: (depth: 2)            // ... but only down to level 2
```

`chapter-toc` puts a second, smaller contents list under each numbered chapter
heading, covering that chapter alone. It is off by default.

The defaults live in two exported dictionaries:

| | `TOC_DEFAULTS` | `CHAPTER_TOC_DEFAULTS` |
|---|---|---|
| `title`  | `"Contents"` | `none` |
| `depth`  | `3` | `2` |
| `indent` | `2em` | `1.5em` |
| `gap`    | — | `0.5em` (between entries) |
| `style`  | `it => it` | `it => it` |

For `toc`, only `style` is consumed by the template; every other key is passed
straight to `outline()`, so its full API — `fill`, `target` and the rest — is
reachable the same way. For `chapter-toc`, the list is built by hand and all
five keys are consumed.

### Styling
`style` is a content-to-content function applied to the finished contents, in
the same shape as a show rule:

```typ
toc: (
  depth: 3,
  style: it => {
    set par(leading: 0.65em, spacing: 0.9em)
    it
  },
),
```

It is applied *inside* the template's own styling, so a `set` rule in `style`
is the nearer one and wins. That is what makes the per-chapter list adjustable
at all: it starts from a 10pt, regular-weight baseline that a `style` of
`it => { set text(size: 8pt); it }` overrides cleanly.

For the document-wide `toc` this is a convenience rather than a necessity,
since the result is a real `outline` element that ordinary show rules in
`main.typ` can target anyway:

```typ
#show outline.entry.where(level: 1): strong
```

The per-chapter list is hand-built content with no such element to select, so
there `style` is the only hook.

## Splitting the Thesis into Files
For longer theses it is convenient to keep each chapter in its own file and
`#include` them from `main.typ`. The `section()` wrapper lets such a file be
compiled on its own — with the full thesis styling — while staying plain when
included in the main document (where `thesis()` already provides the styling).

Add this to the top of a chapter file:
```typ
#import "@preview/ox-scholar:0.2.1": section
#show: section

= My Chapter
...
```

Compiled on its own, the file gets the thesis page layout, fonts, headers and
heading styling. Included from `main.typ`, it is emitted unchanged and inherits
the thesis styling. The `section()` function accepts:

| Parameter | Type              | Description | Default |
|-----------|-------------------|-------------|---------|
| `body`    | `content`         | The section content | — |
| `draft`   | `bool`            | Show line numbers when compiled standalone | `false` |
| `bib`     | `content \| none` | Bibliography for resolving citations when compiled standalone (ignored when included) | `none` |
| `chapter-toc` | `dictionary \| none` | Per-chapter contents list when compiled standalone (ignored when included, where the setting on `thesis()` governs) | `none` |
| `quote`   | `dictionary \| none` | Optional epigraph displayed at the start of the chapter; a dict with `quote` (text) and optionally `author` keys | `none` |

For example, a chapter that is the third in the thesis and cites sources:
```typ
#import "@preview/ox-scholar:0.2.1": section
#show: section.with(
  bib: bibliography("bibliography.bib"),
  quote: (
    quote: "... ἔοικα γοῦν τούτου γε σμικρῷ τινι αὐτῷ τούτῳ σοφώτερος εἶναι, ὅτι ἃ μὴ οἶδα οὐδὲ οἴομαι εἰδέναι.",
    author: "Plato"
  )
)

= Third Chapter
...
```

## Word count
Setting `word-count: true` on `thesis()` prints the word count of the main body
on the title page. The count follows the University of Oxford's
[guidance](https://www.ox.ac.uk/) on what to include and exclude: it counts the
preface, footnotes, appendices, captions, headings and narrative text, and
excludes the table of contents, equations and symbols, diagrams, tables,
bibliography, computer program text, running headers, and the acknowledgements
(which live outside the counted body).

```typ
#show: thesis.with(
  title: "Thesis Title",
  author: "Author",
  word-count: true,
  ...
)
```

The exclusion set can be overridden per document with `word-count-exclude`,
which accepts the same values as
[wordometer](https://typst.app/universe/package/wordometer)'s `exclude`
option (element functions, names, `where`-selectors or labels). For example, to
also exclude inline code:
```typ
#show: thesis.with(
  word-count: true,
  word-count-exclude: ("figure-body", table, outline, raw),
  ...
)
```

The word count depends on the
[wordometer](https://typst.app/universe/package/wordometer) package, which is
resolved automatically.

## Disclaimer
This template was developed after the submission of the author’s thesis. The author does not guarantee that a thesis prepared using this template will be accepted by the University of Oxford. However, the template is designed to conform to the University’s prescribed formatting and styling requirements.

## Acknowledgements
This template was heavily inspired by the [OxThesis](https://github.com/mcmanigle/OxThesis) LaTeX template, which served as a valuable reference in creating this Typst version.

## Contributions
If you encounter any issues using the template, please open an issue on this repository. Contributions are also welcome - if you develop useful extensions or make improvements, we would be happy to accept pull requests.
