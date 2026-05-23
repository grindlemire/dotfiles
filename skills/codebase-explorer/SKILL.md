---
name: codebase-explorer
description: Use when the user wants to understand how a codebase works, how its parts fit together, or needs a visual overview of a project's architecture. Triggered by /codebase-explorer or when the user asks to explore, map, document, or explain a codebase's structure and patterns.
---

# Codebase Explorer

## Overview

Systematically explore a codebase and produce a visual, easy-to-digest report. The report prioritizes ASCII diagrams, UML, and tables over walls of text. The goal is to help a visual learner quickly build a mental model of how the code works and fits together.

## Workflow

```
1. Scope       What directory/repo? Any focus areas?
2. Survey      Explore structure, dependencies, entry points
3. Analyze     Identify architecture, patterns, data flow
4. Report      Generate visual report to a markdown file
```

## Step 1: Scope

When invoked as `/codebase-explorer [optional-path]`:

- If a path argument is provided, use it. Otherwise use the current working directory.
- Ask the user with AskUserQuestion:
  - **Focus**: "What would you like to understand?" with options:
    - "Full overview" (the whole codebase)
    - "Specific area" (a subsystem, module, or feature)
    - "Data flow" (how data moves through the system)
    - "Entry points" (where execution starts, how things get triggered)
- If "Specific area", ask what area to focus on.
- Ask where to write the report file (default: `CODEBASE.md` in the target directory).

## Step 2: Survey

Use the Explore agent (subagent_type=Explore, thoroughness "very thorough") to gather:

1. **Directory tree**: Glob for all source files, build an annotated tree
2. **Entry points**: Find main files, CLI commands, HTTP handlers, exported APIs
3. **Dependencies**: Check go.mod, package.json, requirements.txt, Cargo.toml, etc.
4. **Key types**: Grep for struct/class/interface/type definitions
5. **Configuration**: Find config files, env vars, constants

Launch multiple Explore agents in parallel for independent queries (e.g., one for structure, one for types, one for entry points).

## Step 3: Analyze

Read the key files identified in the survey. Look for:

- **Layering**: How is the code organized? (e.g., handler -> service -> repository)
- **Data flow**: How does data enter, transform, and exit the system?
- **Patterns**: What design patterns are used? (factory, observer, middleware, etc.)
- **Interfaces**: What are the key abstractions and contracts?
- **State**: Where is state held? How does it change?
- **Error handling**: How are errors propagated?

## Step 4: Generate Report

Write the report to the chosen file. The report MUST be heavily visual. Follow the template below.

## Report Template

The report uses this structure. Every section MUST include at least one visual element (diagram, table, or annotated code block). Prefer visuals over prose. When prose is needed, keep it to 1-2 sentences per concept.

````markdown
# Codebase Report: <project name>

> <One-line description of what the project does>

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | ... |
| Framework | ... |
| Storage | ... |
| Build | ... |

## Architecture

```
┌─────────────────────────────────────────────┐
│                   CLI / API                  │
├─────────────┬──────────────┬────────────────┤
│  Handler A  │  Handler B   │  Handler C     │
├─────────────┴──────────────┴────────────────┤
│              Service Layer                   │
├──────────────────┬──────────────────────────┤
│   Repository     │     External APIs        │
├──────────────────┴──────────────────────────┤
│              Storage / DB                    │
└─────────────────────────────────────────────┘
```

<1-2 sentences explaining the high-level flow>

## Directory Map

```
project/
├── cmd/                # Entry points
│   └── server/         # HTTP server main
├── internal/           # Private packages
│   ├── handler/        # HTTP handlers (routes)
│   ├── service/        # Business logic
│   └── repo/           # Data access
├── pkg/                # Public libraries
└── config/             # Configuration
```

Annotate each directory with a short comment explaining its role.

## Key Types

| Type | Package | Role |
|------|---------|------|
| `App` | `main` | Application root, lifecycle |
| `UserService` | `service` | Business logic for users |
| `UserRepo` | `repo` | Database access for users |

Include the most important 10-20 types. Link role to the architecture diagram.

## Data Flow

Show how data moves through the system for the primary use case:

```
Request ──▶ Router ──▶ Handler ──▶ Service ──▶ Repository ──▶ DB
                                      │
                                      ▼
                                  Validator
                                      │
Response ◀── Handler ◀── Service ◀────┘
```

For each arrow, one short label or note if the transformation is non-obvious.

## Component Relationships

UML-style class/module diagram using ASCII:

```
┌──────────────┐       ┌──────────────┐
│   Handler    │       │   Service    │
├──────────────┤       ├──────────────┤
│ +ServeHTTP() │──────▶│ +Create()    │
│ +List()      │       │ +Get()       │
└──────────────┘       │ +Delete()    │
                       └──────┬───────┘
                              │ uses
                              ▼
                       ┌──────────────┐
                       │  Repository  │
                       ├──────────────┤
                       │ +Insert()    │
                       │ +FindByID()  │
                       └──────────────┘
```

Show the 3-5 most important relationships. Use `──▶` for "calls/uses", `──▷` for "implements", `──── ` dashed for "optional".

## Interfaces & Contracts

| Interface | Methods | Implemented By | Purpose |
|-----------|---------|---------------|---------|
| `Store` | `Get`, `Put`, `Delete` | `SQLStore`, `MemStore` | Storage abstraction |

## Design Patterns

| Pattern | Where | Why |
|---------|-------|-----|
| Repository | `internal/repo` | Separates data access from business logic |
| Middleware | `internal/handler` | Cross-cutting concerns (auth, logging) |
| Factory | `NewService()` | Dependency injection via constructors |

For each pattern, one sentence on WHY it's used, not just what it is.

## Entry Points

| Entry Point | File | What It Does |
|-------------|------|-------------|
| `main()` | `cmd/server/main.go` | Starts HTTP server |
| `CLI` | `cmd/cli/main.go` | Command-line interface |

## Sequence: <Primary Use Case>

```
User          Handler        Service       Repository      DB
 │               │              │              │            │
 │──GET /items──▶│              │              │            │
 │               │──GetItems()─▶│              │            │
 │               │              │──FindAll()──▶│            │
 │               │              │              │──SELECT───▶│
 │               │              │              │◀───rows────│
 │               │              │◀──[]Item─────│            │
 │               │◀──JSON───────│              │            │
 │◀──200 OK──────│              │              │            │
```

Pick the most representative use case. Show the full request/response cycle.

## State Management

Where state lives and how it changes:

```
┌─────────────┐    mutation    ┌─────────────┐    persist    ┌──────┐
│  In-Memory  │◀──────────────│   Service    │─────────────▶│  DB  │
│   Cache     │──────────────▶│   Layer      │◀─────────────│      │
└─────────────┘    read       └─────────────┘    load       └──────┘
```

## Error Handling

How errors propagate:

```
Repository ──error──▶ Service ──wrap──▶ Handler ──HTTP status──▶ Client
```

Describe the error strategy in 1-2 sentences (e.g., "Errors are wrapped with context at each layer using fmt.Errorf and unwrapped at the handler for status code mapping").

## Reading Guide

Suggested order for reading the codebase:

| Order | File(s) | Why Start Here |
|-------|---------|---------------|
| 1 | `cmd/server/main.go` | See how everything boots up |
| 2 | `internal/handler/router.go` | Understand all available routes |
| 3 | `internal/service/user.go` | Core business logic example |
| 4 | `internal/repo/user.go` | How data is persisted |
````

## Diagram Style Guide

Follow these conventions for all ASCII diagrams in the report:

### Box Characters
```
┌──┐  Top corners
│  │  Sides
├──┤  Section dividers
└──┘  Bottom corners
```

### Arrows
```
──▶   Calls / uses / sends
──▷   Implements (open arrow)
◀──   Returns / responds
- - ▶ Optional / async (dashed)
```

### Flow Direction
- Architecture diagrams: top to bottom (layers)
- Data flow: left to right
- Sequence diagrams: top to bottom (time)

### Sizing
- Keep diagrams under 70 characters wide (fits most terminals)
- Use consistent box widths within a diagram
- Align arrows vertically when possible

## Adapting to Codebase Size

- **Small** (< 20 files): Include all files in the directory map. Show all types.
- **Medium** (20-100 files): Group by package/module. Show top 15-20 types.
- **Large** (100+ files): Focus on the public API surface and key internal modules. Use the "Specific area" focus to break into multiple reports if needed.

## Common Mistakes

- Writing paragraphs where a diagram would be clearer
- Making diagrams too wide (over 70 chars) so they wrap in terminals
- Listing every file instead of focusing on the important ones
- Describing patterns without explaining WHY they're used
- Forgetting the Reading Guide (it's the most actionable section for a newcomer)
