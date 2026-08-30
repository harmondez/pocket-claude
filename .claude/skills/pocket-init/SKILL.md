---
name: pocket-init
description: Explores this project and fills in CLAUDE.md's Commands, Architecture, and Testing placeholders with what it actually finds (real build/test/lint commands, real structure, real test setup) instead of leaving them empty. Use right after pocket-claude is copied into a new project, or whenever asked to fill in / update CLAUDE.md.
allowed-tools: Read Grep Glob Edit
---

Fill in the three `<!-- fill per project -->` placeholders in `CLAUDE.md`
(Commands, Architecture, Testing) with what this specific project actually
has — never guess, never invent a command that isn't confirmed in a real
file.

This is not the same job as the built-in `/init` command: `/init` writes a
generic CLAUDE.md from scratch and doesn't know pocket-claude's structure
exists. Never run `/init` on a project that already has pocket-claude's
CLAUDE.md — it can overwrite or duplicate the fixed sections. This skill
only ever touches the three placeholder sections and leaves the rest of the
file exactly as pocket-claude shipped it.

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
| `pom.xml` / `build.gradle` / `build.gradle.kts` | Java / Kotlin (JVM) |
| `*.csproj` / `*.sln` | .NET |
| `composer.json` | PHP |
| `pubspec.yaml` | Dart / Flutter |
| `mix.exs` | Elixir |
| `Package.swift` | Swift |
| `Makefile` (nothing else matched) | Generic |

## 2. Commands

Pull real commands from wherever they actually live: `package.json` scripts,
`pyproject.toml`/`tox.ini`/`Makefile` entries, standard `cargo`/`go`
subcommands if there's no custom wrapper, `Rakefile`/Gradle/MSBuild/Composer
tasks. Only list a command you found in an actual file.

## 3. Architecture

Glob the top one or two directory levels (don't read full file contents) and
note 2-3 lines on what isn't obvious from the tree — same length as the
example already in `CLAUDE.md`. If there's a database dependency (a
`docker-compose.yml` with a db service, a `migrations/` or `prisma/`
folder, a `.env.example` with a `DATABASE_URL`), say so in one line — it's
exactly the kind of environment quirk Claude can't guess by reading code.

## 4. Testing

Detect the test framework from its config (`jest.config.*`, `pytest.ini` /
`[tool.pytest]`, `cargo test` built in, `go test` built in, `dart test` /
`flutter test` built in, `mix test` (ExUnit) built in, `swift test`
(XCTest) built in, `.rspec`, a JUnit/Gradle test config, a `*.csproj` test
SDK reference, `phpunit.xml`) and the command to run it.

## 5. Edit CLAUDE.md

Replace only the content of the Commands, Architecture, and Testing
sections — leave the rest of the file untouched. If something genuinely
isn't there (e.g. no test framework configured), say so in one short line
instead of inventing content. Keep each section as terse as the existing
examples — concrete facts, not a tutorial.
