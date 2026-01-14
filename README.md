# Posit Package Manager Container Images

Container images for [Posit Package Manager](https://docs.posit.co/rspm/).

> [!IMPORTANT]
> These images are under active development and testing and are not yet supported by Posit.
>
> Please see [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products) for officially supported images.

## Images

| Image | Docker Hub | GitHub Container Registry |
|:------|:-----------|:--------------------------|
| [package-manager](./package-manager/) | `docker.io/posit/package-manager` | [`ghcr.io/posit-dev/package-manager`](https://github.com/posit-dev/images-package-manager/pkgs/container/package-manager) |

Additional Posit container images are published to [Docker Hub](https://hub.docker.com/u/posit) and [GitHub Container Registry](https://github.com/orgs/posit-dev/packages).

## Getting Started

You can interact with this repository in multiple ways:

* Run on Kuberentes [using Helm](#helm).
* [Build container images directly](#build) from the Containerfile.
* [Use the `bakery` CLI](#using-bakery) to manage and build container images.
* Extend the functionality by using the Minimal base image (see [examples](https://github.com/posit-dev/images-examples)).

## Helm

You can run Package Package manager on Kubernetes using the [Package Manager helm chart](https://docs.posit.co/helm/charts/rstudio-pm/README.html).

These instructions will work for both ARM and x86_64 (AMD64) Kubernetes nodes.

1. Add the `rstudio` helm repository and update to recieve the latest charts.

    ```shell
    helm repo add rstudio https://helm.rstudio.com
    helm repo update
    ```

2. Include the following image information in the [values file](https://docs.posit.co/helm/charts/rstudio-pm/README.html#values):

    ```yaml
    image:
      # Can also use  docker.io/posit/package-manager
      repository: ghcr.io/posit-dev/package-manager
      tag: 2025.12.0-ubuntu-24.04
      # Tags use a different structure compared to rstudio-docker-products builds
      tagPrefix: ""
    ```

3. Install Package Manager with Helm

    ```shell
    helm upgrade --install \
        --values values.yaml \
        package-manager
        rstudio/rstudio-pm
    ```

## Build

You can build OCI container images from the defitions in this repository using one of the following container build tools:

* [buildah](https://github.com/containers/buildah/blob/main/install.md)
* [docker buildx](https://github.com/docker/buildx#installing)

The root of the bakery project is used as the build context for each Containerfile.
Here, the `bakery.yaml` file, or project, is in the root of this repository.

```shell
PPM_VERSION="2025.12"

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

The structure and contents of this reposity were created following the steps in [bakery usage](https://github.com/posit-dev/images-shared/tree/main/posit-bakery#usage).

### Prerequisites

Build prerequisites

* [python](https://docs.astral.sh/uv/guides/install-python/)
* [pipx](https://pipx.pypa.io/stable/installation/)
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

By default, bakery creates a ephemeral JSON [bakefile](https://docs.bakefile.org/en/latest/language.html) to render all containers in parallel.

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

## Share your Feedback

We invite you to join us on [GitHub Discussions](https://github.com/posit-dev/images/discussions) to ask questions and share feedback.

## Issues

If you encounter any issues or have any questions, please [open an issue](https://github.com/posit-dev/images-package-manager/issues). We appreciate your feedback.

## Code of Conduct

We expect all contributors to adhere to the project's [Code of Conduct](CODE_OF_CONDUCT.md) and create a positive and inclusive community.

## License

Posit Container Images and associated tooling are licensed under the [MIT License](LICENSE.md)
