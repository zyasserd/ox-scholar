# Changelog

## v0.2.1
- feat: optional word count on the title page, following the CS Department's counting rules (`word-count`)
- feat: customisable word-count exclusion set (`word-count-exclude`)
- feat: `section()` wrapper so section files can be compiled on their own with full thesis styling, while staying bare when included in the main file
- feat: `section()` accepts an optional `bib` for resolving citations when compiled standalone
- feat: `section()` accepts an optional `quote` parameter for displaying an epigraph at the start of a chapter
- fix: title page no longer leaves a blank line when `college` is omitted

## v0.2.0
- feat: style headers with level 1 and 2 headings using hydra
- feat: first line paragraph indentation
- feat: option to enable line numbers
- chore: improve level 1 heading styling logic
- chore: improve default template content

## v0.1.1
- fix: thumbnail appearance in typst universe

## v0.1.0
- feat: add template
