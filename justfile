#!/usr/bin/env just --justfile

BAKERY_VERSION := "0.2.0.dev0"
GITHUB_TOKEN := `gh auth token`

init-venv:
  #!/bin/bash
  set -ex
  rm -rf .venv
  python3 -m venv .venv

install-bakery:
  #!/bin/bash
  # TODO: Update this after package is published somewhere
  pipx install 'git+ssh://git@github.com/posit-dev/images-shared.git@main#egg=posit-bakery&subdirectory=posit-bakery'

install-goss:
  #!/bin/bash
  mkdir -p tools
  curl -fsSL https://github.com/goss-org/goss/releases/latest/download/goss-linux-amd64 -o {{justfile_directory()}}/tools/goss
  chmod +rx {{justfile_directory()}}/tools/goss
  curl -fsSL https://github.com/goss-org/goss/releases/latest/download/dgoss -o {{justfile_directory()}}/tools/dgoss
  chmod +rx {{justfile_directory()}}/tools/dgoss

init: init-venv install-bakery install-goss

download-pti:
  mkdir -p {{justfile_directory()}}/tools
  curl -sSL \
      -H 'Accept: application/octet-stream' \
      -H "Authorization: Bearer {{GITHUB_TOKEN}}" \
      https://api.github.com/repos/posit-dev/pti/releases/assets/220659328 \
      -o {{justfile_directory()}}/tools/pti

new product base_image="posit/base":
  bakery new {{product}} --context {{ justfile_directory() }} --image-base {{base_image}} --image-type "product"

alias generate := render
render product version r_version python_version *OPTS:
  bakery render {{product}} {{version}} \
    --value r_version={{r_version}} \
    --value python_version={{python_version}} {{OPTS}}

alias bake := build
build *OPTS:
  just download-pti
  bakery build --context {{ justfile_directory() }} {{OPTS}}

alias dgoss := test
test *OPTS:
  bakery dgoss --context {{ justfile_directory() }} {{OPTS}}
