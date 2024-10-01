variable registry {
  default = "docker.io"
}

variable namespace {
  default = "posit"
}

variable "GIT_SHA" {
  default = "$GIT_SHA"
}

target "_" {
  labels = {
    "org.opencontainers.image.created" = timestamp()
    "org.opencontainers.image.authors" = "Ian H. Pittwood <ian.pittwood@posit.co>"
    "org.opencontainers.image.source" = "github.com/rstudio/proto-posit-images-package-manager"
    "org.opencontainers.image.revision" = GIT_SHA
    "org.opencontainers.image.vendor" = "Posit Software, PBC"
  }
  context = "."
}
