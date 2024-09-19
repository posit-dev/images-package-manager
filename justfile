#!/usr/bin/env just --justfile

init-venv:
  #!/bin/bash
  set -ex
  rm -rf .venv
  python3 -m venv .venv

install-templater:
  #!/bin/bash
  {{justfile_directory()}}/.venv/bin/pip3 install {{justfile_directory()}}/../posit-images-shared/image-templater

install-goss:
  #!/bin/bash
  curl -fsSL https://github.com/goss-org/goss/releases/latest/download/goss-linux-amd64 -o {{justfile_directory()}}/tools/goss
  chmod +rx {{justfile_directory()}}/tools/goss
  curl -fsSL https://github.com/goss-org/goss/releases/latest/download/dgoss -o {{justfile_directory()}}/tools/dgoss
  chmod +rx {{justfile_directory()}}/tools/dgoss

init: init-venv install-templater install-goss

alias generate := render
render image product_version r_version python_version:
  {{ justfile_directory() }}/.venv/bin/templater render \
    {{image}} \
    {{product_version}} \
    --value r_version={{r_version}} \
    --value python_version={{python_version}} \
    --value rel_path={{ image }}/{{ product_version }}

alias bake := build
build target export_options="--load" override_file="docker-bake.override.hcl":
  #!/bin/bash
  set -ex
  if [ -f "{{override_file}}" ]; then
    docker buildx bake -f {{justfile_directory()}}/docker-bake.hcl -f {{target}}/docker-bake.hcl -f {{override_file}} {{export_options}}
  else
    docker buildx bake -f {{justfile_directory()}}/docker-bake.hcl -f {{target}}/docker-bake.hcl {{export_options}}
  fi

test image version type os='ubuntu' os_version='22.04' registry='docker.io':
  #!/bin/bash
  set -x
  suffix=""
  if [[ "{{type}}" != "std" ]]; then
    suffix="-{{type}}"
  fi
  GOSS_SLEEP=10 \
  GOSS_PATH={{justfile_directory()}}/tools/goss \
  GOSS_FILES_PATH={{justfile_directory()}}/{{image}}/{{version}}/test \
    {{justfile_directory()}}/tools/dgoss run \
    -e IMAGE_TYPE="{{type}}" \
    -v {{justfile_directory()}}/common/{{os}}/{{os_version}}:/tmp/deps \
    {{registry}}/posit/{{image}}:{{os}}{{replace(os_version, ".", "")}}-{{replace_regex(version, "[+].*", "")}}${suffix} \
    /opt/rstudio-pm/bin/rstudio-pm --config /etc/rstudio-pm/rstudio-pm.gcfg
