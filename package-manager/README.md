# Posit Package Manager container image

This container image provides [Package Manager](https://docs.posit.co/rspm/), a repository management server that organizes and centralizes R and Python packages across teams, departments, or organizations.

![Docker Pulls](https://img.shields.io/docker/pulls/posit/package-manager)
![Docker Image Size](https://img.shields.io/docker/image-size/posit/package-manager/latest)

> [!NOTE]
> These images are in preview as Posit migrates container images from [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products). The previous images remain supported.

> [!TIP]
> Deploying on Kubernetes? Try the [Posit Package Manager Helm chart](https://docs.posit.co/helm/charts/rstudio-pm/README.html)!

## Quick reference

| | |
|---|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Maintained by** | [the Posit Docker team](https://github.com/posit-dev/images)                                                                                                                                                                                                                                   |
| **Where to get help** | [GitHub Issues](https://github.com/posit-dev/images-package-manager/issues), [Images Discussion Board](https://github.com/posit-dev/images/discussions), [the Posit Community Forum](https://forum.posit.co/c/posit-professional-hosted/5), [Posit Support](https://support.posit.co/hc/en-us) |
| **Where to file issues** | [https://github.com/posit-dev/images-package-manager/issues](https://github.com/posit-dev/images-package-manager/issues)                                                                                                                                                                       |
| **Source** | [https://github.com/posit-dev/images-package-manager](https://github.com/posit-dev/images-package-manager)                                                                                                                                                                                     |
| **License** | [MIT](https://github.com/posit-dev/images-package-manager/blob/main/LICENSE.md)                                                                                                                                                                                                                |

## How to use this image

### Quick start

```bash
PPM_VERSION="2026.04.1"
PPM_IMAGE="ghcr.io/posit-dev/package-manager"  # or docker.io/posit/package-manager
PPM_LICENSE_FILE_HOST_PATH="/path/to/license.lic"
PPM_LICENSE_FILE_PATH="/etc/rstudio-pm/license.lic"
PPM_DATA_HOST_PATH="/data/rstudio-pm"
docker run -d \
  --name package-manager \
  -p 4242:4242 \
  -e PPM_LICENSE_FILE_PATH=${PPM_LICENSE_FILE_PATH} \
  -v ${PPM_LICENSE_FILE_HOST_PATH}:${PPM_LICENSE_FILE_PATH} \
  -v ${PPM_DATA_HOST_PATH}:/var/lib/rstudio-pm \
  ${PPM_IMAGE}:${PPM_VERSION}
```

Access Package Manager at `http://localhost:4242`.

The data volume above persists application data between container restarts. See [Volume mounts](#volume-mounts) for additional mount points such as configuration overrides.

### With a custom configuration file

```bash
PPM_VERSION="2026.04.1"
PPM_IMAGE="ghcr.io/posit-dev/package-manager"  # or docker.io/posit/package-manager
PPM_LICENSE_FILE_HOST_PATH="/path/to/license.lic"
PPM_LICENSE_FILE_PATH="/etc/rstudio-pm/license.lic"
PPM_DATA_HOST_PATH="/data/rstudio-pm"
PPM_CONFIG_HOST_PATH="/path/to/rstudio-pm.gcfg"
docker run -d \
  --name package-manager \
  -p 4242:4242 \
  -e PPM_LICENSE_FILE_PATH=${PPM_LICENSE_FILE_PATH} \
  -v ${PPM_LICENSE_FILE_HOST_PATH}:${PPM_LICENSE_FILE_PATH} \
  -v ${PPM_DATA_HOST_PATH}:/var/lib/rstudio-pm \
  -v ${PPM_CONFIG_HOST_PATH}:/etc/rstudio-pm/rstudio-pm.gcfg:ro \
  ${PPM_IMAGE}:${PPM_VERSION}
```

### With Docker Compose

```yaml
services:
  package-manager:
    image: ghcr.io/posit-dev/package-manager:latest
    ports:
    - "4242:4242"
    environment:
      PPM_LICENSE_FILE_PATH: /etc/rstudio-pm/license.lic
    volumes:
    - /path/to/license.lic:/etc/rstudio-pm/license.lic
    - /path/to/rstudio-pm.gcfg:/etc/rstudio-pm/rstudio-pm.gcfg:ro
    - package-manager-data:/var/lib/rstudio-pm
    restart: unless-stopped

volumes:
  package-manager-data:
```

## Image variants

Two variants are available:

| Variant          | Description                                                                                                                                                                  |
|------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Standard (`std`) | Opinionated image, runs out of the box. Bundles one R version and one Python version alongside Package Manager.                                                              |
| Minimal (`min`)  | Small image you can extend with desired dependencies. Does not include R or Python — Package Manager requires both for full functionality with features such as Git sources. |

Each tagged image bundles a fixed set of dependencies. Both variants ship the `YYYY.MM` release of Package Manager at the latest patch release available when the image was built. The `std` variant additionally ships one R version and one Python version, locked to the latest available at build time. The Containerfiles in this repository under `package-manager/<version>/` document the exact versions in any tag. No arguments are overridden at build time.

Package Manager is not particular about which R or Python version is installed. See [R and Python installation requirements](https://docs.posit.co/rspm/admin/getting-started/requirements.html#r-and-python-installation-requirements) in the Package Manager admin guide for details.

See [extending examples](https://github.com/posit-dev/images-examples/tree/main/extending) for how to build on the Minimal image.

## Image tags

Posit publishes images to:
- Docker Hub: `docker.io/posit/package-manager`
- GitHub Container Registry: `ghcr.io/posit-dev/package-manager`

Ubuntu 24.04 is the default OS.

Tag formats where `YYYY.MM.P` is any supported Package Manager version:
- `YYYY.MM.P` - Latest OS, standard variant
- `YYYY.MM.P-ubuntu-24.04` - Explicit OS, standard variant
- `YYYY.MM.P-ubuntu-24.04-std` - Explicit OS and variant
- `YYYY.MM.P-ubuntu-24.04-min` - Minimal variant
- `latest` - Latest version, default OS, standard variant

## Supported Tags and Respective `Dockerfile` Links

- [`2026.04.1`, `2026.04.1-ubuntu-24.04`, `latest`, `std`, `ubuntu-24.04`](https://github.com/posit-dev/images-package-manager/blob/main/package-manager/2026.04/Containerfile.ubuntu2404.std)
- [`2025.12.0`, `2025.12.0-14`, `2025.12.0-ubuntu-24.04`](https://github.com/posit-dev/images-package-manager/blob/main/package-manager/2025.12/Containerfile.ubuntu2404.std)
- [`2025.09.0`, `2025.09.0-7`, `2025.09.0-ubuntu-22.04`](https://github.com/posit-dev/images-package-manager/blob/main/package-manager/2025.09/Containerfile.ubuntu2204.std)
- [`2025.04.4`, `2025.04.4-13`, `2025.04.4-ubuntu-22.04`](https://github.com/posit-dev/images-package-manager/blob/main/package-manager/2025.04/Containerfile.ubuntu2204.std)
- [`2024.11.0`, `2024.11.0-7`, `2024.11.0-ubuntu-22.04`](https://github.com/posit-dev/images-package-manager/blob/main/package-manager/2024.11/Containerfile.ubuntu2204.std)
- [`2026.04.1-min`, `2026.04.1-ubuntu-24.04-min`, `min`, `ubuntu-24.04-min`](https://github.com/posit-dev/images-package-manager/blob/main/package-manager/2026.04/Containerfile.ubuntu2404.min)
- [`2026.04.1-ubuntu-22.04`, `ubuntu-22.04`](https://github.com/posit-dev/images-package-manager/blob/main/package-manager/2026.04/Containerfile.ubuntu2204.std)
- [`2026.04.1-ubuntu-22.04-min`, `ubuntu-22.04-min`](https://github.com/posit-dev/images-package-manager/blob/main/package-manager/2026.04/Containerfile.ubuntu2204.min)

For a full list of available tags, see the [Tags tab](https://hub.docker.com/r/posit/package-manager/tags) on Docker Hub.

## Architectures

Posit publishes multi-arch images for both `linux/amd64` and `linux/arm64`. Pull the same tag from either platform; Docker selects the matching manifest automatically.

## Environment variables

| Variable                | Description                                                   |
|-------------------------|---------------------------------------------------------------|
| `PPM_LICENSE`           | License key for activation                                    |
| `PPM_LICENSE_SERVER`    | URL of floating license server                                |
| `PPM_LICENSE_FILE_PATH` | Path to license file (default: `/etc/rstudio-pm/license.lic`) |
| `PPM_STARTUP_DEBUG`     | Set to `1` for verbose startup logging                        |

If you are migrating from `rstudio/rstudio-package-manager`, see [Environment variables](#environment-variables-1) under the migration guide for the legacy `RSPM_` names and deprecation timeline.

## Exposed ports

| Port | Description |
|------|-------------|
| 4242 | HTTP web interface and API |

## Volumes

For persistent data, add these volume mounts to your `docker run` command:

```bash
-v /data/rstudio-pm:/var/lib/rstudio-pm \
-v /data/rstudio-pm-config:/etc/rstudio-pm
```

| Mount Point           | Description                   |
|-----------------------|-------------------------------|
| `/var/lib/rstudio-pm` | Application data and database |
| `/etc/rstudio-pm`     | Configuration files           |

The data path is set by the `Server.DataDir` option in `rstudio-pm.gcfg` (default `/var/lib/rstudio-pm`). If you change this option in a custom configuration, mount the persistent volume to the new path.

## Configuration

### License activation

Package Manager requires a [product license](https://docs.posit.co/licensing/licensing-faq.html). Posit recommends activating with a license file. Choose one method:

#### Option 1: License file (recommended)

Mount the license file to any path in the container and set `PPM_LICENSE_FILE_PATH` to that path. The default search path is `/etc/rstudio-pm/license.lic`, so mounting to that path does not require setting the environment variable. The environment variable is only included for illustrative purposes below.

```bash
docker run -v /path/to/license.lic:/etc/rstudio-pm/license.lic -e PPM_LICENSE_FILE_PATH=/etc/rstudio-pm/license.lic ...
```

or mount to a path Package Manager will natively search for license files in, either `/home/rstudio-pm/.rstudio-pm/license.lic` or `/var/lib/rstudio-pm/license.lic`:

```bash
docker run -v /path/to/license.lic:/home/rstudio-pm/.rstudio-pm/license.lic ...
```

If the container is unable to activate the license, ensure the file has correct permissions (`0600`) and is owned by the `rstudio-pm` user (UID 999).

#### Option 2: License key

```bash
docker run -e PPM_LICENSE="your-license-key" ...
```

License key activations can leak when a container shuts down ungracefully, consuming an activation slot that cannot be recovered through normal means. To help preserve license state across container restarts, mount these directories to persistent storage:

- `/home/rstudio-pm/.local`
- `/home/rstudio-pm/.prof`
- `/home/rstudio-pm/.rstudio-pm`

State files are hardware-locked and not transferable between hosts. Mounting these paths reduces the chance of a leak but does not eliminate it. To avoid the leak risk entirely, use a license file (Option 1). See the [License keys](#license-keys) caveat for more detail.

#### Option 3: Floating license server

```bash
docker run -e PPM_LICENSE_SERVER="http://license-server:8989" ...
```

Floating license activations can also leak on ungraceful shutdown. To help preserve license state across container restarts, mount this directory to persistent storage:

- `/home/rstudio-pm/.TurboFloat`

State files are hardware-locked and not transferable between hosts. To avoid the leak risk entirely, use a license file (Option 1).

### Custom configuration

Mount a custom configuration file:

```bash
docker run -v /path/to/rstudio-pm.gcfg:/etc/rstudio-pm/rstudio-pm.gcfg ...
```

See the [configuration documentation](https://docs.posit.co/rspm/admin/appendix/configuration/) for available options.

## Healthcheck

Package Manager exposes an unauthenticated health endpoint at `/__ping__` on port `4242` that returns `200 OK` once the application is ready to serve traffic.

```bash
curl http://localhost:4242/__ping__
```

The image declares a Docker `HEALTHCHECK` against this endpoint:

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -fsS http://localhost:4242/__ping__ || exit 1
```

Both variants inherit the same directive. The `min` variant will report unhealthy until extended with R and Python, since Package Manager does not run without them. To disable the directive in a derived image, add `HEALTHCHECK NONE`.

For Kubernetes liveness and readiness probes, or load balancer health checks, hit the same endpoint directly rather than relying on the Docker healthcheck.

## User

Runs as the rstudio-pm user with user ID (UID) and group ID (GID) 999.

## Examples

### Adding a Workbench-built package

Workbench can build a source tarball you publish through Package Manager. This example assumes a Package Manager container running per [Quick start](#quick-start).

Build the package in Workbench. The build pane writes the tarball on the host (e.g. `data/pwb/rstudio/demo1_0.1.0.tar.gz`).

Find the Package Manager container ID:

```bash
docker ps
# CONTAINER ID   IMAGE
# b8ae944b7f2d   ghcr.io/posit-dev/package-manager:2026.04.1
```

Copy the tarball into the container and open a shell:

```bash
docker cp data/pwb/rstudio/demo1_0.1.0.tar.gz b8ae944b7f2d:/tmp
docker exec -it b8ae944b7f2d /bin/bash
```

Create a local source, repository, and subscription:

```bash
rspm create source --name=demopkgs
rspm add --source=demopkgs --path=/tmp/demo1_0.1.0.tar.gz
rspm create repo --name=demopkgs --description="demo package repo"
rspm subscribe --repo=demopkgs --source=demopkgs
```

Install the package from R:

```r
install.packages("demo1", repos = "http://localhost:4242/demopkgs/latest")
```

See the [Package Manager admin guide](https://docs.posit.co/rspm/admin/getting-started/configuration.html) for managing repositories.

## Migrating from rstudio/rstudio-package-manager

This image replaces the legacy [`rstudio/rstudio-package-manager`](https://hub.docker.com/r/rstudio/rstudio-package-manager) image. Package Manager itself is unchanged — the application reads `rstudio-pm.gcfg`, listens on `4242`, persists data to `Server.DataDir`, and runs as the `rstudio-pm` user (UID/GID `999`). Existing data and configuration volumes mount unchanged. The differences are in how the image is published and configured.

### Image references

The legacy image was published as `rstudio/rstudio-package-manager` on Docker Hub and `ghcr.io/rstudio/rstudio-package-manager` on GHCR, tagged by OS (`jammy`, `ubuntu2204`, `jammy-<version>`, `ubuntu2204-<version>`) for `linux/amd64` only. Update your image reference to one of the new locations and pick a tag that pins to your desired Package Manager version, OS, and variant. See [Image tags](#image-tags) and [Architectures](#architectures).

### Variants

The legacy image shipped a single variant containing two versions of R and Python and many extraneous system packages not explicitly required for Package Manager's functionality. The Standard (`std`) variant is closest to the legacy image, containing one version of R and Python and a reduced set of system packages required for Package Manager to run. The new Minimal (`min`) variant image has no equivalent. See [Image variants](#image-variants).

### Environment variables

License and debug environment variables now use the `PPM_` prefix:

| New variable            | Legacy variable          |
|-------------------------|--------------------------|
| `PPM_LICENSE`           | `RSPM_LICENSE`           |
| `PPM_LICENSE_SERVER`    | `RSPM_LICENSE_SERVER`    |
| `PPM_LICENSE_FILE_PATH` | `RSPM_LICENSE_FILE_PATH` |
| `PPM_STARTUP_DEBUG`     | `STARTUP_DEBUG_MODE`     |

The image accepts the legacy `RSPM_` license names as a fallback during the deprecation window. `STARTUP_DEBUG_MODE` is not honored — switch to `PPM_STARTUP_DEBUG`.

> [!NOTE]
> Posit supports legacy RSPM_ variables but plans to deprecate them after 2026. For more details and updates, see the [Package Manager release notes](https://docs.posit.co/rspm/news/). For future deployments, always use the PPM_ prefix to ensure forward compatibility.

### Git package builds

The `std` variant now sets `AllowUnsandboxedGitBuilds = true` so Git package builds work in containers. The legacy image did not set this option. See [Git package builds](#git-package-builds) under Caveats for the rationale and how to override.

### What did not change

- Application port (`4242`)
- Configuration file path (`/etc/rstudio-pm/rstudio-pm.gcfg`)
- Persistent data path (`Server.DataDir`, default `/var/lib/rstudio-pm`)
- Service user (`rstudio-pm`, UID/GID `999`)
- `rspm` CLI commands and on-disk repository layout

## Caveats

### Security

Review these images before using them in production. Organizations with specific Common Vulnerabilities and Exposures (CVE) or vulnerability requirements should rebuild these images to meet their security standards.

Posit rebuilds published images weekly for Posit Product editions under active support to pull in operating system patches.

### License keys

License keys used in containers risk activation slot loss if containers are not gracefully stopped. The license deactivates on container exit, but ungraceful shutdowns (crashes, `docker kill`) can leave the activation slot consumed on the Posit license server.

To ensure proper license deactivation, use a sufficient stop timeout for both `docker run` and `docker stop`:

```bash
docker run -d --stop-timeout 120 -e PPM_LICENSE="your-license-key" ...
docker stop --time 120 <container>
```

For production deployments, use license files rather than license keys.

### Hardware locking

Hardware locks license state files to a specific machine. Changes to MAC addresses, hostnames, or container orchestration platforms, such as Kubernetes, can invalidate the license state, requiring reactivation.

### Git package builds

Package Manager refuses Git package builds when its [process sandbox](https://docs.posit.co/rspm/admin/process-management/) is unavailable. Containers cannot use the sandbox, so the `std` variant enables `AllowUnsandboxedGitBuilds = true` in the `[Git]` configuration section to support Git builds out of the box.

The `min` variant does not enable this option. Git builds require R or Python, which `min` does not ship, and customers extending the image may not want unsandboxed builds. To enable Git builds in an extension, install R or Python and add `AllowUnsandboxedGitBuilds = true` to the `[Git]` section of `rstudio-pm.gcfg`. Customers who require sandboxed Git builds should run Package Manager outside a container or in an environment that supports sandboxing.
