# Contributing to Posit Package Manager container images

This guide covers how to build and test the Package Manager container images locally,
and how to perform common maintenance tasks. To build images directly with Docker,
Buildah, or Podman, see the [README](README.md#build). To deploy or run pre-built
images, see the [README](README.md#running-the-image).

## Build and test

### Prerequisites

| Tool | Install |
|---|---|
| [python](https://docs.astral.sh/uv/guides/install-python/) + [uv](https://docs.astral.sh/uv/getting-started/installation/) | Required for `bakery` |
| [docker buildx bake](https://github.com/docker/buildx#installing) | Required for builds |
| [just](https://just.systems/man/en/prerequisites.html) | Task runner |

```shell
# Install bakery and goss
just init

# Install pre-commit hooks
just setup
```

### Build

```shell
# Preview the build plan
bakery build --plan

# Build all images
bakery build

# Build a specific image version
bakery build --image-name package-manager --image-version 2025.12
```

### Test

```shell
# Run goss tests for all images
bakery run dgoss

# Run goss tests for a specific image
bakery run dgoss --image-name package-manager
```

### Re-render templates

After changing any file in a `template/` directory, re-render the version directories:

```shell
bakery update files
bakery update files --image-name package-manager --image-version 2025.12
```

## Maintainer tasks

Each section below has Package Manager-specific context and a concrete example. The
linked procedure in the [shared maintainer guide](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md)
covers the full workflow.

### Add a version

Package Manager versions are dispatched automatically from `rstudio/package-manager`
via the `posit-package-manager-automation` GitHub App, which triggers this repo's
`release.yml` workflow. Use manual steps only for hotfixes.

```bash
# Create a new version manually (e.g., a hotfix to 2025.12)
bakery create version 2025.12.1 --image-name package-manager
bakery update files --image-name package-manager --image-version 2025.12
```

→ [Shared procedure](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#add-a-version)

### Add an image

This repo has a single image (`package-manager`). Adding a new image requires
coordination with the Package Manager product team.

```bash
# Scaffold a new image directory and template
bakery create image <new-image-name>
```

→ [Shared procedure](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#add-an-image)

### Update dependencies

`package-manager` uses `dependencyConstraints: latest: true` for R and Python — bakery
resolves the current latest at build time.

```bash
# After changing dependencyConstraints in bakery.yaml, re-render
bakery update files --image-name package-manager
```

→ [Shared procedure](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#update-dependencies)

### Update older versions

```bash
# Edit the template, then re-render a specific edition
bakery update files --image-name package-manager --image-version 2025.12

# Build and test before opening a PR
bakery build --image-name package-manager --image-version 2025.12
bakery run dgoss --image-name package-manager --image-version 2025.12
```

→ [Shared procedure](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#update-older-versions)

### Footguns

**Package Manager has two dev streams.** `bakery.yaml` defines both `preview` and `daily` dev
version sources. A change to `dependencyConstraints` affects both streams.

→ [Shared footguns](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#footguns)

### Diagnose a build failure

| Workflow | Schedule | Builds |
|---|---|---|
| `production.yml` | Weekly Sun 01:15 UTC, push to main, dispatch | `package-manager` (excludes dev) → Docker Hub + GHCR |
| `development.yml` | Daily 07:45 UTC, push to main, dispatch | Dev stream (preview + daily) → ghcr.io/posit-dev/package-manager-preview |

Both workflows use `bakery-build-native.yml` (native amd64 + arm64 runners).

→ [Shared failure scenarios](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#diagnose-a-build-failure)
