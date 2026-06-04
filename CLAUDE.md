# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Posit Package Manager container image built with [Posit Bakery](https://github.com/posit-dev/images-shared/tree/main/posit-bakery). Contains `package-manager` (Standard/Minimal variants). Supports multi-platform builds (amd64/arm64).

## Sibling Repositories

This project is part of a multi-repo ecosystem for Posit container images. Sibling repos
are configured as additional directories (see `.claude/settings.json`). **Read the CLAUDE.md
in each affected sibling repo before making changes there.**

- `../images-shared/` - Posit Bakery CLI tool for building, testing, and managing container images. Jinja2 templates, macros, and shared build tooling.
- `../images/` - Meta repository with documentation, design principles, and links across all image repos.
- `../images-examples/` - Examples for using and extending Posit container images.
- `../helm/` - Helm charts for Posit products: Connect, Workbench, Package Manager, and Chronicle.

### Worktrees for Cross-Repo Changes

When making changes across repositories, use worktrees to isolate work from `main`. Multiple
sessions may be running concurrently, so never work directly on `main` in any repo.

- **Primary repo:** Use `EnterWorktree` with a descriptive name.
- **Sibling repos:** Create worktrees via `git worktree add` before making changes. Store
  them in `.claude/worktrees/<name>` within each repo (matching the `EnterWorktree` convention).

```bash
# Create a worktree in a sibling repo
git -C ../images-shared worktree add .claude/worktrees/<name> -b <branch-name>
```

Read and write files via the worktree path (e.g., `../images-shared/.claude/worktrees/<name>/`)
instead of the repo root. Clean up when finished:

```bash
git -C ../images-shared worktree remove .claude/worktrees/<name>
```

> **Note:** The `additionalDirectories` in `.claude/settings.json` point to the sibling repo
> roots, not to worktree paths. File reads and writes via those directories will access the
> repo root (typically on `main`). Always use the full worktree path when reading or writing
> files in a sibling worktree.

## Product Naming

| Current Name | Legacy Name | ENV Prefix | Legacy Prefix |
|---|---|---|---|
| Posit Package Manager | RStudio Package Manager | `PPM_` | `RSPM_` |
| Posit Connect | RStudio Connect | `PCT_` | `RSC_` |
| Posit Workbench | RStudio Workbench | `PWB_` | `RSW_`, `RSP_` |

## Image: package-manager

Two variants:

- **Standard** (`std`, primary) — includes R and Python. Goss tests with 10s startup wait.
- **Minimal** (`min`) — base image for customers to extend.

Supports multi-platform builds: `linux/amd64` and `linux/arm64`.

**Key env vars** (set in Containerfile, consumed by `startup.sh`):
- `PPM_LICENSE` — license key (falls back to `RSPM_LICENSE`)
- `PPM_LICENSE_SERVER` — floating license server URL (falls back to `RSPM_LICENSE_SERVER`)
- `PPM_LICENSE_FILE_PATH` — path to license file, default `/etc/rstudio-pm/license.lic` (falls back to `RSPM_LICENSE_FILE_PATH`)
- `PPM_STARTUP_DEBUG` — set to `1` for verbose startup logging

All license env vars are unset after activation to prevent child process inheritance.

## Template Pipeline

**Always edit Jinja2 templates in `template/`, never rendered files in version directories.**

After changing templates, re-render: `bakery update files`

```
package-manager/
├── template/                          # EDIT THESE
│   ├── Containerfile.ubuntu2204.jinja2
│   ├── Containerfile.ubuntu2404.jinja2
│   ├── deps/
│   │   ├── python_requirements.txt.jinja2
│   │   ├── ubuntu2204_packages.txt.jinja2
│   │   └── ubuntu2404_packages.txt.jinja2
│   ├── scripts/
│   │   ├── install_package_manager.sh.jinja2
│   │   └── startup.sh.jinja2
│   └── test/goss.yaml.jinja2
├── 2025.12/                           # Rendered (do not edit)
├── 2025.09/
└── ...
```

Rendered version directories contain `.min` and `.std` variants of each Containerfile
(e.g., `Containerfile.ubuntu2404.min`, `Containerfile.ubuntu2404.std`).

### Macros imported in templates

```jinja2
{%- import "apt.j2" as apt -%}
{%- import "python.j2" as python -%}
{%- import "r.j2" as r -%}
```

No `quarto.j2` — Package Manager doesn't ship Quarto.

### Template variables

- `Image.Version`, `Image.Variant`, `Image.OS`, `Image.IsDevelopmentVersion`
- `Dependencies.python`, `Dependencies.R` (lists of version strings)
- `Path.Version`, `Path.Image`

## Build and Test

```bash
# Install bakery and goss
just init

# Preview the build plan
bakery build --plan

# Build all images
bakery build

# Build a specific version/variant
bakery build --image-name package-manager --image-version 2025.12.0 --image-variant Standard

# Build for a specific platform
bakery build --image-name package-manager --image-platform linux/arm64

# Run goss tests
bakery run dgoss

# Re-render templates after changes
bakery update files
```

## CI Workflows

All workflows call shared reusable workflows from `images-shared`:

| Workflow | What it builds | Shared workflow |
|---|---|---|
| `production.yml` | Production versions (excludes dev) | `bakery-build-native.yml` |
| `development.yml` | Dev versions only (preview + daily streams) | `bakery-build-native.yml` |

Both workflows use `bakery-build-native.yml` for native multi-platform builds (amd64 + arm64).
Images push to `docker.io/posit` and `ghcr.io/posit-dev` on main merges and scheduled runs.
Dev images push to AWS ECR.

For CI failure diagnosis, see [CONTRIBUTING.md](CONTRIBUTING.md#diagnose-a-build-failure).

## Helm Integration

The corresponding Helm chart is `rstudio-pm` in `../helm/charts/rstudio-pm/`.

- Chart `appVersion` in `Chart.yaml` drives the default image tag
- Image tag pattern: `{appVersion}-{os}` (e.g., `2025.12.0-ubuntu-24.04`)
- `values.yaml` references `ghcr.io/posit-dev/package-manager`

When bumping image versions, coordinate updates to the helm chart's `appVersion`.
