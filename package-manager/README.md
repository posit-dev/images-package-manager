# Posit Package Manager container image

This container image provides [Package Manager](https://docs.posit.co/rspm/), a repository management server that organizes and centralizes R and Python packages across teams, departments, or organizations.

> [!NOTE]
> These images are in preview as Posit migrates container images from [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products). The previous images remain supported.

## Quick start

```bash
PPM_VERSION="2026.04.1"
PPM_IMAGE="ghcr.io/posit-dev/package-manager"  # or docker.io/posit/package-manager
PPM_LICENSE="/path/to/license.lic"
docker run -d \
  --name package-manager \
  -p 4242:4242 \
  -v ${PPM_LICENSE}:/etc/rstudio-pm/license.lic \
  ${PPM_IMAGE}:${PPM_VERSION}
```

Access Package Manager at `http://localhost:4242`.

> [!NOTE]
> This example does not mount a data volume. Application data will not persist when the container stops. See [Volume mounts](#volume-mounts) for persistent storage.

## Image variants

Two variants are available:

| Variant | Description |
|---------|-------------|
| `std` (Standard) | Opinionated image, runs out of the box. Bundles one R version and one Python version alongside Package Manager. |
| `min` (Minimal) | Small image you can extend with desired dependencies. Will not run unmodified. |

Each tagged image bundles a fixed set of dependencies. Both variants ship the `YYYY.MM` release of Package Manager at the latest patch release available when the image was built. The `std` variant additionally ships one R version and one Python version, locked to the latest available at build time. The Containerfiles in this repository under `package-manager/<version>/` document the exact versions in any tag.

Package Manager is not particular about which R or Python version is installed. See [R and Python installation requirements](https://docs.posit.co/rspm/admin/getting-started/requirements.html#r-and-python-installation-requirements) in the Package Manager admin guide for details.

See [extending examples](https://github.com/posit-dev/images-examples/tree/main/extending) for how to build on the Minimal image.

## Image tags

Posit publishes images to:
- Docker Hub: `docker.io/posit/package-manager`
- GitHub Container Registry: `ghcr.io/posit-dev/package-manager`

Ubuntu 24.04 is the default OS.

Tag formats:
- `2026.04.1` - Latest OS, standard variant
- `2026.04.1-ubuntu-24.04` - Explicit OS, standard variant
- `2026.04.1-ubuntu-24.04-std` - Explicit OS and variant
- `2026.04.1-ubuntu-24.04-min` - Minimal variant
- `latest` - Latest version, default OS, standard variant

## Configuration

### License activation

Package Manager requires a [product license](https://docs.posit.co/licensing/licensing-faq.html). Posit recommends activating with a license file. Choose one method:

#### Option 1: License file (recommended)

```bash
docker run -v /path/to/license.lic:/etc/rstudio-pm/license.lic ...
```

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

### Environment variables

| Variable                | Description                                                   |
|-------------------------|---------------------------------------------------------------|
| `PPM_LICENSE`           | License key for activation                                    |
| `PPM_LICENSE_SERVER`    | URL of floating license server                                |
| `PPM_LICENSE_FILE_PATH` | Path to license file (default: `/etc/rstudio-pm/license.lic`) |
| `PPM_STARTUP_DEBUG`     | Set to `1` for verbose startup logging                        |

#### Legacy environment variables

| Legacy Variable          | Preferred Equivalent    | Notes         |
|--------------------------|-------------------------|---------------|
| `RSPM_LICENSE`           | `PPM_LICENSE`           | Same behavior |
| `RSPM_LICENSE_SERVER`    | `PPM_LICENSE_SERVER`    | Same behavior |
| `RSPM_LICENSE_FILE_PATH` | `PPM_LICENSE_FILE_PATH` | Same behavior |

> [!NOTE]
> Posit supports legacy RSPM_ variables but plans to deprecate them after 2026. For more details and updates, see the [Package Manager release notes](https://docs.posit.co/rspm/news/). For future deployments, always use the PPM_ prefix to ensure forward compatibility.

### Volume mounts

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

### Custom configuration

Mount a custom configuration file:

```bash
docker run -v /path/to/rstudio-pm.gcfg:/etc/rstudio-pm/rstudio-pm.gcfg ...
```

See the [configuration documentation](https://docs.posit.co/rspm/admin/appendix/configuration/) for available options.

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

## Exposed ports

| Port | Description |
|------|-------------|
| 4242 | HTTP web interface and API |

## User

Runs as the rstudio-pm user with user ID (UID) and group ID (GID) 999.

## Differences from rstudio/rstudio-package-manager

This image differs from the legacy [`rstudio/rstudio-package-manager`](https://hub.docker.com/r/rstudio/rstudio-package-manager) image:

| Aspect           | This Image                             | rstudio/rstudio-package-manager                               |
|------------------|----------------------------------------|---------------------------------------------------------------|
| Registry         | `posit/package-manager`                | `rstudio/rstudio-package-manager`                             |
| License env vars | `PPM_` prefix                          | `RSPM_` prefix                                                |
| Variants         | `std` (with R/Python), `min` (minimal) | Single variant; multiple tags for different R/Python versions |
| Base OS options  | Ubuntu 24.04, Ubuntu 22.04             | Ubuntu 22.04                                                  |

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

## Getting help

- [Package Manager documentation](https://docs.posit.co/rspm/) — setup, configuration, and admin reference
- [Posit Community Forum](https://forum.posit.co/c/posit-professional-hosted/package-manager/21) — community questions and answers
- [Posit Support](https://support.posit.co/hc/en-us) — for licensed customers
- [Image issues](https://github.com/posit-dev/images-package-manager/issues) — bugs or requests for this container image
- [Image discussions](https://github.com/posit-dev/images/discussions) — questions about Posit container images generally
