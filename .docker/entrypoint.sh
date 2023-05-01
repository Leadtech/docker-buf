#!/bin/sh

set -e

#
# Execute init scripts on startup.
#
# The scripts are sorted. To determine the execution order, simply prefix the script with a number.
# For example: 1-first-script.sh, 2-second-script.sh etc.
#
scripts=$(find "$APP_HOME/.docker/bin/init" -name '*.sh' | sort)
for script in $scripts; do
  bash "$script"
done

exec "$@"
