#!/bin/bash

set -e
if [[ "${PPM_STARTUP_DEBUG:-0}" -eq 1 ]]; then
  set -x
fi

# Deactivate license when it exists
deactivate() {
    echo "Deactivating license ..."
    is_deactivated=0
    retries=0
    while [[ $is_deactivated -ne 1 ]] && [[ $retries -le 3 ]]; do
      /opt/rstudio-pm/bin/license-manager deactivate --userspace >/dev/null 2>&1
      is_deactivated=1
      ((retries+=1))
      # TODO: this may not longer be necessary, but I need more context for why it's here first.
      if [ -d /home/rstudio-pm/.local ]; then
        # shellcheck disable=SC2045
        for file in $(ls -A /home/rstudio-pm/.local); do
          if [ -s "/home/rstudio-pm/.local/$file" ]; then
            if [[ $retries -lt 3 ]]; then
              echo "License did not deactivate, retry ${retries}..."
              is_deactivated=0
            else
              echo "Unable to deactivate license. If you encounter issues activating your product in the future, please contact Posit support."
            fi
            continue
          fi
        done
      fi
    done
}
trap deactivate EXIT

# Backward compatibility: fall back to RSPM_ prefixed variables if PPM_ not set
PPM_LICENSE=${PPM_LICENSE:-$RSPM_LICENSE}
PPM_LICENSE_SERVER=${PPM_LICENSE_SERVER:-$RSPM_LICENSE_SERVER}
PPM_LICENSE_FILE_PATH=${PPM_LICENSE_FILE_PATH:-$RSPM_LICENSE_FILE_PATH}

# Activate License
PPM_LICENSE_FILE_PATH=${PPM_LICENSE_FILE_PATH:-/etc/rstudio-pm/license.lic}
/opt/rstudio-pm/bin/license-manager initialize --userspace || true
if ! [ -z "$PPM_LICENSE" ]; then
    /opt/rstudio-pm/bin/license-manager activate "$PPM_LICENSE" --userspace
elif ! [ -z "$PPM_LICENSE_SERVER" ]; then
    /opt/rstudio-pm/bin/license-manager license-server "$PPM_LICENSE_SERVER" --userspace
elif test -f "$PPM_LICENSE_FILE_PATH"; then
    /opt/rstudio-pm/bin/license-manager activate-file "$PPM_LICENSE_FILE_PATH" --userspace
elif ls /var/lib/rstudio-pm/*.lic >/dev/null 2>&1; then
    echo "Detected a license file in /var/lib/rstudio-pm/*.lic."
elif ls /home/rstudio-pm/.rstudio-pm/*.lic >/dev/null 2>&1; then
    echo "Detected a license file in /home/rstudio-pm/.rstudio-pm/*.lic."
fi

# ensure these cannot be inherited by child processes
unset PPM_LICENSE
unset PPM_LICENSE_SERVER
unset PPM_LICENSE_FILE_PATH
unset RSPM_LICENSE
unset RSPM_LICENSE_SERVER
unset RSPM_LICENSE_FILE_PATH

# Start RStudio Package Manager
/opt/rstudio-pm/bin/rstudio-pm --config /etc/rstudio-pm/rstudio-pm.gcfg
