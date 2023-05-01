#!/bin/sh

if test -z "${PROTOC_INSTALL_VERSIONS}"; then
  export PROTOC_INSTALL_VERSIONS=${DEFAULT_PROTOC_VERSION}
fi

cd /opt/ || exit 1

for PROTOC_VERSION in $PROTOC_INSTALL_VERSIONS; do
  if [ -n "${PROTOC_VERSION}" ]; then
    install_dir="${PROTOC_HOME:-/opt/protoc}/releases/${PROTOC_VERSION}"
    # Check if release is already installed
    if [ ! -d "$install_dir" ]; then
        mkdir -p "$install_dir"

        # Download protoc release
        zipfile="protoc-${PROTOC_VERSION}-linux-x86_64.zip"
        wget "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/$zipfile"
        if [ ! -f "$zipfile" ]; then
          echo "The version ${PROTOC_VERSION} seems to be invalid. Check out the available releases on github. See: https://github.com/protocolbuffers/protobuf/releases"
          exit 1
        fi

        unzip "$zipfile" -d "$install_dir"
        chmod ug+x "$install_dir/bin/*"
        rm "$zipfile"
    fi
  fi
done

default_protoc_dir="${PROTOC_HOME:-/opt/protoc}/releases/${DEFAULT_PROTOC_VERSION}"
if [ ! -d "$default_protoc_dir" ]; then
  echo "The default protoc version is not installed! Add '${DEFAULT_PROTOC_VERSION}' to the PROTOC_INSTALL_VERSIONS environment variable."
  exit 1
fi

if [ ! -d "${PROTOC_HOME:-/opt/protoc}/bin" ]; then
  mkdir "${PROTOC_HOME:-/opt/protoc}/bin"
fi

# Remove existing symlink if exists
if [ -f "${PROTOC_HOME:-/opt/protoc}/bin/protoc" ]; then
  rm "${PROTOC_HOME:-/opt/protoc}/bin/protoc"
fi

# Create symlink
ln -s "$default_protoc_dir/bin/protoc" "${PROTOC_HOME:-/opt/protoc}/bin/protoc"