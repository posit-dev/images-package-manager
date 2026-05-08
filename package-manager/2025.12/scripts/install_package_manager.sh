#!/bin/bash
set -eo pipefail

# Output delimiter
d="===="

apt-get update -yq

echo "$d Install Posit Package Manager 2025.12.0-14 $d"

RSTUDIO_INSTALL_NO_LICENSE_INITIALIZATION=1 apt-get install -yf rstudio-pm=2025.12.0-14
apt-mark hold rstudio-pm

PPM_CONFIG_FILE="/etc/rstudio-pm/rstudio-pm.gcfg"

if [ -n "$R_VERSION" ] && [ -n "$PYTHON_VERSION" ]
then
    # The default rstudio-pm.gcfg has an RVersion section already, let's comment that out.
    sed -i 's/RVersion =/;RVersion =/' $PPM_CONFIG_FILE

    echo "$d Setting R and Python version configuration $d"
    sed -i "0,/.*RVersion.*/s||RVersion = /opt/R/$R_VERSION\nPythonVersion = /opt/python/$PYTHON_VERSION/bin/python|" $PPM_CONFIG_FILE

    # Git package builds require R or Python and would otherwise fail because
    # Package Manager's process sandbox is unavailable in containers. Allow
    # unsandboxed Git builds so they work out of the box. This is gated on
    # R_VERSION/PYTHON_VERSION being set, which is true only for the Standard
    # variant -- Minimal users extending the image opt in by setting the
    # option themselves once they install R or Python.
    echo "$d Allowing unsandboxed Git builds $d"
    if grep -q '^\[Git\]' $PPM_CONFIG_FILE; then
        sed -i '/^\[Git\]/a AllowUnsandboxedGitBuilds = true' $PPM_CONFIG_FILE
    else
        printf '\n[Git]\nAllowUnsandboxedGitBuilds = true\n' >> $PPM_CONFIG_FILE
    fi
else
    echo "$d No R or Python version provided $d"
fi

# clean up
apt-get clean -yqq && \
rm -rf /var/lib/apt/lists/*
