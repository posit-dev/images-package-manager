# Posit Package Manager Container Images

Container images for [Posit Package Manager](https://docs.posit.co/rspm/).

## Images

| Image | Docker Hub | GitHub Container Registry |
|:------|:-----------|:--------------------------|
| `package-manager` | [`docker.io/posit/package-manager`](https://hub.docker.com/repository/docker/posit/package-manager/tags) | [`ghcr.io/posit-dev/package-manager`](https://github.com/posit-dev/images-package-manager/pkgs/container/package-manager) |

Additional Posit container images are published to [Docker Hub](https://hub.docker.com/u/posit) and [GitHub Container Registry](https://github.com/orgs/posit-dev/packages).

## Getting Started

You can interact with this repository in multiple ways:

* [Build container images](#build) directly from the Containerfile.
* Manage and build container images using the [bakery](https://github.com/posit-dev/images-shared/tree/main/posit-bakery) CLI.
* Extend the functionality by using the Minimal base image ([examples](https://github.com/posit-dev/images-examples))

## Build

You can build OCI container images from the defitions in this repository using one of the following container build tools:

* [buildah](https://github.com/containers/buildah/blob/main/install.md)
* [docker buildx](https://github.com/docker/buildx#installing)

The root of the repository is used as the build context for each Containerfile.

```shell
# Download the pti binary
# TODO: Delete when we have fully removed `pti` usage
just download-pti
```

```shell
PPM_VERSION="2025.04"

# Build the standard Package Manager image using docker
docker buildx build \
    --tag package-manager:${PPM_VERSION} \
    --file package-manager/${PPM_VERSION}/Containerfile.ubuntu2204.std \
    .

# Build the minimal Package Manager image using buildah
buildah build \
    --tag package-manager:${PPM_VERSION} \
    --file package-manager/${PPM_VERSION}/Containerfile.ubuntu2204.min \
    .
```

## Issues

If you encounter any issues or have any questions, please [open an issue](https://github.com/posit-dev/images-package-manager/issues). We appreciate your feedback.

## Code of Conduct

We expect all contributors to adhere to the project's [Code of Conduct](CODE_OF_CONDUCT.md) and create a positive and inclusive community.

## License

Posit Container Images and associated tooling are licensed under the [MIT License](LICENSE.md)
