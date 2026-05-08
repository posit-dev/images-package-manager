<a href="https://posit.co/products/enterprise/package-manager">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://cdn.posit.co/platform/containers/logos/logo_pkgmgrtag-reverse.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://cdn.posit.co/platform/containers/logos/logo_pkgmgrtag-fullcolor.svg">
  <img alt="Posit Package Manager Logo" src="https://cdn.posit.co/platform/containers/logos/logo_pkgmgrtag-fullcolor.svg">
</picture>
</a>

# Posit Package Manager container images

Container images for [Package Manager](https://docs.posit.co/rspm/).

[![Production CI Build Status](https://github.com/posit-dev/images-package-manager/actions/workflows/production.yml/badge.svg?branch=main)](https://github.com/posit-dev/images-package-manager/actions/workflows/production.yml)
[![Development CI Build Status](https://github.com/posit-dev/images-package-manager/actions/workflows/development.yml/badge.svg?branch=main)](https://github.com/posit-dev/images-package-manager/actions/workflows/development.yml)
[![Latest Version](https://img.shields.io/docker/v/posit/package-manager?sort=semver&label=latest)](https://hub.docker.com/r/posit/package-manager/tags)

> [!NOTE]
> Posit is migrating container images from [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products). The previous images remain supported.

## Prerequisites

| Tool | Required for | Install |
|------|-------------|---------|
| [Docker](https://docs.docker.com/get-docker/) | Running containers locally | [Get Docker](https://docs.docker.com/get-docker/) |
| [Helm](https://helm.sh/docs/intro/install/) | Deploying on Kubernetes | [Install Helm](https://helm.sh/docs/intro/install/) |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | Deploying on Kubernetes | [Install kubectl](https://kubernetes.io/docs/tasks/tools/) |
| Product license | Running Package Manager | [Licensing FAQ](https://docs.posit.co/licensing/licensing-faq.html), [Request a trial license](https://posit.co/trial-license/) |

## Images

| Image | Docker Hub | GitHub Container Registry |
|:------|:-----------|:--------------------------|
| [package-manager](./package-manager/) | [`docker.io/posit/package-manager`](https://hub.docker.com/r/posit/package-manager) | [`ghcr.io/posit-dev/package-manager`](https://github.com/posit-dev/images-package-manager/pkgs/container/package-manager) |

Posit publishes additional container images to [Docker Hub](https://hub.docker.com/u/posit) and [GitHub Container Registry](https://github.com/orgs/posit-dev/packages).

## Running the image

The fastest way to get started is to pull and run a pre-built image.

- [Package Manager](./package-manager/): Quick start, configuration, and environment variables

See the [Package Manager installation guide](https://docs.posit.co/rspm/admin/getting-started/installation/) for full setup instructions.

## Deploying on Kubernetes

Use the [Package Manager Helm chart](https://docs.posit.co/helm/charts/rstudio-pm/README.html) to deploy on Kubernetes. These instructions work for both ARM and x86_64 (AMD64) Kubernetes nodes.

```bash
helm repo add rstudio https://helm.rstudio.com
helm repo update
```

Create a Kubernetes secret from your license file, then configure the chart in your `values.yaml`:

```bash
kubectl create secret generic posit-package-manager-license \
  --from-file=license.lic=/path/to/license.lic
```

```yaml
image:
  repository: ghcr.io/posit-dev/package-manager
  tag: "2026.04.1"  # Replace with desired tag/version

license:
  file:
    secret: posit-package-manager-license
```

Install Package Manager with Helm:

```bash
helm upgrade --install package-manager rstudio/rstudio-pm --values values.yaml
```

See the [full chart documentation](https://docs.posit.co/helm/charts/rstudio-pm/README.html) for all available values.

## Build

You can build Open Container Initiative (OCI) container images from the definitions in this repository using one of the following container build tools:

* [docker buildx](https://github.com/docker/buildx#installing)
* [buildah](https://github.com/containers/buildah/blob/main/install.md)
* [podman](https://podman.io/docs/installation)

Each Containerfile uses the root of the repository as the build context.

```shell
PPM_VERSION="2026.04"

# Build the standard Package Manager image using docker
docker buildx build \
    --tag package-manager:${PPM_VERSION} \
    --file package-manager/${PPM_VERSION}/Containerfile.ubuntu2404.std \
    .

# Build the minimal Package Manager image using buildah
buildah build \
    --tag package-manager:${PPM_VERSION} \
    --file package-manager/${PPM_VERSION}/Containerfile.ubuntu2404.min \
    .

# Build the minimal Package Manager image using podman
podman build \
    --tag package-manager:${PPM_VERSION} \
    --file package-manager/${PPM_VERSION}/Containerfile.ubuntu2404.min \
    .
```

## Contributing

To build images with `bakery` or run the test suite, see the [contributing guide](CONTRIBUTING.md).

## Related repositories

This repository is part of the [Posit Container Images](https://github.com/posit-dev/images) ecosystem. To extend the Minimal image with additional languages or system dependencies, see the [extending examples](https://github.com/posit-dev/images-examples/tree/main/extending). For shared build tooling and CI workflows, see [images-shared](https://github.com/posit-dev/images-shared).

## Share your feedback

We invite you to join us on [GitHub Discussions](https://github.com/posit-dev/images/discussions) to ask questions and share feedback.

## Issues

If you encounter any issues or have any questions, [open an issue](https://github.com/posit-dev/images-package-manager/issues). We appreciate your feedback.

## Code of Conduct

We expect all contributors to adhere to the project's [Code of Conduct](CODE_OF_CONDUCT.md) and create a positive and inclusive community.

## License

Posit Container Images and associated tooling are licensed under the [MIT License](LICENSE.md)
