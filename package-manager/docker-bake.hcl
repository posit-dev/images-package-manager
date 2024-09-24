variable image_name {
  default = "package-manager"
}

function get_safe_version {
  params = [version]
  result = replace(version, "+", "-")
}

function get_clean_version {
    params = [version]
    result = regex_replace(version, "[+|-].*", "")
}

function get_suffix {
  params = [type]
  result = type == "std" ? "" : "-${type}"
}

function get_tags {
  params = [version, os, type, mark_latest]
  result = concat(
    [
      "${registry}/${namespace}/${image_name}:${os}-${get_clean_version(version)}",
      "${registry}/${namespace}/${image_name}:${os}-${get_clean_version(version)}${get_suffix(type)}",
      "${registry}/${namespace}/${image_name}:${os}-${get_safe_version(version)}",
      "${registry}/${namespace}/${image_name}:${os}-${get_safe_version(version)}${get_suffix(type)}",
    ],
      mark_latest ? ["${registry}/${namespace}/${image_name}:latest${get_suffix(type)}", "${registry}/${namespace}/${image_name}:${os}${get_suffix(type)}"] :
      []
  )
}

group "default" {
  targets = [
    "std",
    "min"
  ]
}

target "std" {
  inherits = ["_"]
  matrix = build_matrix
  name = "${builds.os}-${replace(get_clean_version(builds.version), ".", "-")}-std"
  tags = get_tags(builds.version, builds.os, "std", builds.mark_latest)
  labels = {
    "co.posit.image.type" = "std"
    "co.posit.image.os" = "${builds.os}"
    "co.posit.image.version" = "${builds.version}"
    "co.posit.image.name" = "${image_name}"
    "co.posit.internal.goss.test.wait" = "10"
    "co.posit.internal.goss.test.path" = "${image_name}/${builds.version}/test"
    "co.posit.internal.goss.test.deps" = "${image_name}/${builds.version}/deps"
  }
  dockerfile = "${image_name}/${builds.version}/Containerfile.${builds.os}.std"
  args = {
    "BASE_IMAGE_REGISTRY" = registry
  }
}

target "min" {
  inherits = ["_"]
  matrix = build_matrix
  name = "${builds.os}-${replace(get_clean_version(builds.version), ".", "-")}-min"
  tags = get_tags(builds.version, builds.os, "min", builds.mark_latest)
  labels = {
    "co.posit.image.type" = "min"
    "co.posit.image.os" = "${builds.os}"
    "co.posit.image.version" = "${builds.version}"
    "co.posit.image.name" = "${image_name}"
    "co.posit.internal.goss.test.wait" = "0"
    "co.posit.internal.goss.test.path" = "${image_name}/${builds.version}/test"
    "co.posit.internal.goss.test.deps" = "${image_name}/${builds.version}/deps"
  }
  dockerfile = "${image_name}/${builds.version}/Containerfile.${builds.os}.min"
  args = {
    "BASE_IMAGE_REGISTRY" = registry
  }
}
