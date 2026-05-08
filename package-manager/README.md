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
| `std` (Standard) | Opinionated image, runs out of the box |
| `min` (Minimal) | Small image you can extend with desired dependencies. Will not run unmodified. |

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

#### Option 3: Floating license server

```bash
docker run -e PPM_LICENSE_SERVER="http://license-server:8989" ...
```

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

| Mount Point           | Description               |
|-----------------------|---------------------------|
| `/var/lib/rstudio-pm` | Application data and database |
| `/etc/rstudio-pm`     | Configuration files       |

### Custom configuration

Mount a custom configuration file:

```bash
docker run -v /path/to/rstudio-pm.gcfg:/etc/rstudio-pm/rstudio-pm.gcfg ...
```

See the [configuration documentation](https://docs.posit.co/rspm/admin/appendix/configuration/) for available options.

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

To ensure proper license deactivation, use a sufficient stop timeout:

```bash
docker run -d \
  --stop-timeout 120 \
  -e PPM_LICENSE="your-license-key" \
  ...
```

For production deployments, use license files rather than license keys.

### Hardware locking

Hardware locks license state files to a specific machine. Changes to MAC addresses, hostnames, or container orchestration platforms, such as Kubernetes, can invalidate the license state, requiring reactivation.

## Documentation

- [Package Manager documentation](https://docs.posit.co/rspm/)
- [Admin Guide](https://docs.posit.co/rspm/admin/)
- [Configuration Reference](https://docs.posit.co/rspm/admin/appendix/configuration/)
