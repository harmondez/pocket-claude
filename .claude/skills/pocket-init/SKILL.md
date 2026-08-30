---
name: pocket-init
description: Explores this project and fills in CLAUDE.md's Commands, Architecture, and Testing placeholders with what it actually finds (real build/test/lint commands, real structure, real test setup) instead of leaving them empty. Use right after pocket-claude is copied into a new project, or whenever asked to fill in / update CLAUDE.md.
---

Fill in the three `<!-- fill per project -->` placeholders in `CLAUDE.md`
(Commands, Architecture, Testing) with what this specific project actually
has — never guess, never invent a command that isn't confirmed in a real
file.

## 1. Detect ecosystem(s)

Look for whichever of these exist at the project root (a project can match
more than one):

| File | Ecosystem |
|---|---|
| `package.json` | Node |
| `pyproject.toml` / `requirements.txt` / `setup.py` | Python |
| `Cargo.toml` | Rust |
| `go.mod` | Go |
| `Gemfile` / `Rakefile` | Ruby |
| `pom.xml` / `build.gradle` | Java |
| `*.csproj` / `*.sln` | .NET |
| `composer.json` | PHP |
| `Makefile` (nothing else matched) | Generic |

## 2. Commands

Pull real commands from wherever they actually live: `package.json` scripts,
`pyproject.toml`/`tox.ini`/`Makefile` entries, standard `cargo`/`go`
subcommands if there's no custom wrapper, `Rakefile`/Gradle/MSBuild/Composer
tasks. Only list a command you found in an actual file.

## 3. Architecture

Glob the top one or two directory levels (don't read full file contents) and
note 2-3 lines on what isn't obvious from the tree — same length as the
example already in `CLAUDE.md`.

## 4. Testing

Detect the test framework from its config (`jest.config.*`, `pytest.ini` /
`[tool.pytest]`, `cargo test` built in, `go test` built in, `.rspec`, a
JUnit/Gradle test config, a `*.csproj` test SDK reference, `phpunit.xml`)
and the command to run it.

## 5. Edit CLAUDE.md

Replace only the content of the Commands, Architecture, and Testing
sections — leave the rest of the file untouched. If something genuinely
isn't there (e.g. no test framework configured), say so in one short line
instead of inventing content. Keep each section as terse as the existing
examples — concrete facts, not a tutorial.
