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

All commands are run from `tower_defence_code/`.

```bash
flutter pub get          # install dependencies (after cloning or changing pubspec.yaml)
flutter run              # start the game
```

## Checks before every commit

```bash
dart format .            # apply the standard Dart formatting
flutter analyze          # static analysis: must report "No issues found!"
flutter test             # all tests: must report "All tests passed!"
```

GitHub Actions runs the same three checks on every push and pull request
(`.github/workflows/flutter.yml`); there formatting is only checked, not
applied, so unformatted code fails the build. Tests mirror the `lib/` folders:
`lib/model/game_map.dart` is tested in `test/model/game_map_test.dart`.

## Generated files and cleanup

| Generated | By | Committed? | Clean with |
| --- | --- | --- | --- |
| `build/pdf/` | `make pdfs` (needs `latexmk`) | yes | not cleaned |
| `build/wiki/` | `make wiki` (needs `pandoc`) | no | `make clean` |
| `tower_defence_code/build/`, `.dart_tool/` | Flutter | no | `flutter clean` |
| `tower_defence_code/pubspec.lock` | `flutter pub get` | yes: pins exact versions | never delete |

Run `flutter clean` (then `flutter pub get`) when a build behaves strangely
after changing Flutter versions or moving the project folder.
