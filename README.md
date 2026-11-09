# Tower Defence Final Project

A Level 4 individual project at the University of Glasgow: a Flutter and
Flame tower-defence game used to study runtime-loaded game logic with
`dart_eval`.

## What is where

```text
README.md                this file
Makefile                 builds the PDFs and wiki pages (run `make`)
scripts/publish-wiki.sh  pushes the wiki pages to GitHub (`make publish-wiki`)

docs/                    ALL documentation sources: edit only these
  plan.md                schedule and phases
  architecture.md        game structure and architecture decisions (AD-1, ...)
  decision-log.md        project decisions and reasoning (written by hand, no AI)
  project-direction.md   research options and directions
  timelog.md             hours spent
  requirements/          functional requirements (LaTeX)
  meetings/              supervisor meeting minutes (LaTeX) and template
  research/              early research notes and references
  wiki-home.md           source of the wiki home page

build/                   GENERATED: never edit
  pdf/                   compiled PDFs (committed so they can be read on GitHub)
  wiki/                  generated wiki pages (not committed)

tower_defence_code/      the Flutter game
dissertation/            dissertation (to come)
presentation/            presentation (to come)
```

## Everyday workflow

1. Edit a source file in `docs/`.
2. Run `make` to rebuild the PDFs and wiki pages.
3. Commit the source file and any changed PDFs in `build/pdf/`.
4. Run `make publish-wiki` to update the GitHub wiki.

The wiki and `build/` are output only. If the publish script finds local edits
in the wiki clone, it stops so they are not overwritten.

## Running the game

```bash
cd tower_defence_code
flutter pub get
flutter run
flutter analyze && flutter test
```
