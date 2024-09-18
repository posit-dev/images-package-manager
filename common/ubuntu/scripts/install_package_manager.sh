#!/bin/bash
set -eo pipefail

# Output delimiter
d="===="

PYTHON_VERSION=${PYTHON_VERSION}
R_VERSION=${R_VERSION}
SCRIPTS_DIR=${SCRIPTS_DIR:-/opt/positscripts}
PACKAGE_MANAGER_VERSION=${PACKAGE_MANAGER_VERSION}

echo "$d Fetching Posit Package Manager package $d"

# fetch latest deb package
curl -fsSL "https://cdn.posit.co/package-manager/deb/amd64/rstudio-pm_${PACKAGE_MANAGER_VERSION}_amd64.deb" -o /tmp/rstudio-pm.deb

echo "$d Verify Posit Package Manager package $d"
# Verify the deb package
gpg --keyserver keys.openpgp.org --recv-keys 51C0B5BB19F92D60
dpkg-sig --verify /tmp/rstudio-pm.deb

echo "$d Install Posit Package Manager $d"
# install latest deb package, dont initialize
RSTUDIO_INSTALL_NO_LICENSE_INITIALIZATION=1 apt-get install -yf /tmp/rstudio-pm.deb

PPM_CONFIG_FILE="/etc/rstudio-pm/rstudio-pm.gcfg"

if [ -n "$R_VERSION" ] && [ -n "$PYTHON_VERSION" ]
then
    # The default rstudio-pm.gcfg has an RVersion section already, let's comment that out.
    sed -i 's/RVersion =/;RVersion =/' $PPM_CONFIG_FILE

    echo "$d Setting R and Python version configuration $d"
    cat << EOF >> $PPM_CONFIG_FILE
[Server]
; provided during automated install
RVersion = /opt/R/${R_VERSION}
PythonVersion = /opt/python/${PYTHON_VERSION}/bin/python
EOF
else
    echo "$d No R or Python version provided $d"
fi

# clean up
rm /tmp/rstudio-pm.deb
