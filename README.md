# Posit Package Manager Container Images

Container images for [Posit Package Manager](https://docs.posit.co/rspm/).

> [!NOTE]
> These images are in preview as Posit migrates container images from [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products). The existing images remain supported.

## Prerequisites

| Tool | Required for | Install |
|------|-------------|---------|
| [Docker](https://docs.docker.com/get-docker/) | Running containers locally | [Get Docker](https://docs.docker.com/get-docker/) |
| [Helm](https://helm.sh/docs/intro/install/) | Deploying on Kubernetes | [Install Helm](https://helm.sh/docs/intro/install/) |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | Deploying on Kubernetes | [Install kubectl](https://kubernetes.io/docs/tasks/tools/) |
| Product license | Running Package Manager | [Licensing FAQ](https://docs.posit.co/licensing/licensing-faq.html) |

## Images

| Image | Docker Hub | GitHub Container Registry |
|:------|:-----------|:--------------------------|
| [package-manager](./package-manager/) | [`docker.io/posit/package-manager`](https://hub.docker.com/r/posit/package-manager) | [`ghcr.io/posit-dev/package-manager`](https://github.com/posit-dev/images-package-manager/pkgs/container/package-manager) |

Additional Posit container images are published to [Docker Hub](https://hub.docker.com/u/posit) and [GitHub Container Registry](https://github.com/orgs/posit-dev/packages).

## Running the Image

The fastest way to get started is to pull and run a pre-built image.

- [Posit Package Manager](./package-manager/) — Quick Start, configuration, and environment variables

See the [Package Manager installation guide](https://docs.posit.co/rspm/admin/getting-started/installation/) for full setup instructions.

## Deploying on Kubernetes

Use the [Posit Package Manager Helm chart](https://docs.posit.co/helm/charts/rstudio-pm/README.html) to deploy on Kubernetes. These instructions work for both ARM and x86_64 (AMD64) Kubernetes nodes.

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
  tag: "2026.04.0"

license:
  file:
    secret: posit-package-manager-license
```

Install Package Manager with Helm:

```bash
helm upgrade --install package-manager rstudio/rstudio-pm --values values.yaml
```

See the [full chart documentation](https://docs.posit.co/helm/charts/rstudio-pm/README.html) for all available values.

## Building from Source

You can interact with this repository in multiple ways:

* [Build container images directly](#build) from the Containerfile.
* [Use the `bakery` CLI](#using-bakery) to manage and build container images.
* Extend the functionality by using the Minimal base image (see [examples](https://github.com/posit-dev/images-examples)).

## Build

You can build OCI container images from the definitions in this repository using one of the following container build tools:

* [buildah](https://github.com/containers/buildah/blob/main/install.md)
* [docker buildx](https://github.com/docker/buildx#installing)

The root of the bakery project is used as the build context for each Containerfile.
Here, the [`bakery.yaml`](https://github.com/posit-dev/images-shared/blob/main/posit-bakery/CONFIGURATION.md#bakery-configuration) file, or project, is in the root of this repository.

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

## Using `bakery`

The structure and contents of this repository were created following the steps in [bakery usage](https://github.com/posit-dev/images-shared/tree/main/posit-bakery#usage).

Additional documentation:
- [Configuration Reference](https://github.com/posit-dev/images-shared/blob/main/posit-bakery/CONFIGURATION.md) — `bakery.yaml` schema and options
- [Templating Reference](https://github.com/posit-dev/images-shared/blob/main/posit-bakery/TEMPLATING.md) — Jinja2 macros for Containerfile templates
- [CI Workflows](https://github.com/posit-dev/images-shared/blob/main/CI.md) — Shared GitHub Actions workflows for building and pushing images

### Prerequisites

Build prerequisites

* [python](https://docs.astral.sh/uv/guides/install-python/)
* [uv](https://docs.astral.sh/uv/getting-started/installation/)
* [docker buildx bake](https://github.com/docker/buildx#installing)
* [just](https://just.systems/man/en/prerequisites.html)
* [gh](https://github.com/cli/cli#installation) (required while repositories are private)
* `bakery`

    ```shell
    just install bakery
    ```

* `goss` and `dgoss` for running image validation tests

    ```shell
    just install-goss
    ```

### Build with `bakery`

By default, bakery creates an ephemeral JSON [bakefile](https://docs.bakefile.org/en/latest/language.html) to render all containers in parallel.

```shell
bakery build
```

You can view the bake plan using `bakery build --plan`.

You can use CLI flags to build only a subset of images in the project.

### Test images

After building the container images, run the test suite for all images:

```shell
bakery run dgoss
```

You can use CLI flags to limit the tests to run against a subset of images.

## Related Repositories

This repository is part of the [Posit Container Images](https://github.com/posit-dev/images) ecosystem. To extend the Minimal image with additional languages or system dependencies, see the [extending examples](https://github.com/posit-dev/images-examples/tree/main/extending). For shared build tooling and CI workflows, see [images-shared](https://github.com/posit-dev/images-shared).

## Share your Feedback

We invite you to join us on [GitHub Discussions](https://github.com/posit-dev/images/discussions) to ask questions and share feedback.

## Issues

If you encounter any issues or have any questions, please [open an issue](https://github.com/posit-dev/images-package-manager/issues). We appreciate your feedback.

## Code of Conduct

We expect all contributors to adhere to the project's [Code of Conduct](CODE_OF_CONDUCT.md) and create a positive and inclusive community.

## License

Posit Container Images and associated tooling are licensed under the [MIT License](LICENSE.md)
