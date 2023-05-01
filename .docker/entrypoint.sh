#!/bin/sh

set -e
SCRIPTNAME=$(basename $0)

startup_error() {
    echo "${SCRIPTNAME}: ${1:-"Unknown Startup Error"}" 1>&2
    exit 1
}

if test -z "${DEFAULT_PROTOC_VERSION}"; then
  startup_error "$LINENO: Missing environment variable: \$DEFAULT_PROTOC_VERSION"
fi

if test -z "${PROTOC_INSTALL_VERSIONS}"; then
  export PROTOC_INSTALL_VERSIONS=${DEFAULT_PROTOC_VERSION}
fi

#
# Execute init scripts on startup.
#
# The scripts are sorted. To determine the execution order, simply prefix the script with a number.
# For example: 1-first-script.sh, 2-second-script.sh etc.
#
scripts=$(find "/opt/docker/init" -name '*.sh' | sort)
for script in $scripts; do
  bash "$script"
done

exec "$@"
