#!/bin/bash
set -eo pipefail

# Output delimiter
d="===="

apt-get update -yq

echo "$d Install Posit Package Manager 2024.04.4-35 $d"

RSTUDIO_INSTALL_NO_LICENSE_INITIALIZATION=1 apt-get install -yf rstudio-pm=2024.04.4-35

PPM_CONFIG_FILE="/etc/rstudio-pm/rstudio-pm.gcfg"

if [ -n "$R_VERSION" ] && [ -n "$PYTHON_VERSION" ]
then
    # The default rstudio-pm.gcfg has an RVersion section already, let's comment that out.
    sed -i 's/RVersion =/;RVersion =/' $PPM_CONFIG_FILE

    echo "$d Setting R and Python version configuration $d"
    cat << EOF >> $PPM_CONFIG_FILE
[Server]
; provided during automated install
RVersion = /opt/R/$R_VERSION
PythonVersion = /opt/python/cpython-$PYTHON_VERSION-linux-x86_64-gnu/bin/python
EOF
else
    echo "$d No R or Python version provided $d"
fi

# clean up
apt-get clean -yqq && \
rm -rf /var/lib/apt/lists/*
