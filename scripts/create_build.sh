#!/bin/bash

LUET_REPO="${LUET_REPO:-/root/repo}"
BUILD_LAYER_NAME="${BUILD_LAYER_NAME:-core-desktop-build}"
BUILD_LAYER_CATEGORY="${BUILD_LAYER_CATEGORY:-layer}"
BUILD_LAYER_VERSION="${BUILD_LAYER_VERSION:-0.1}"
JOBS=${JOBS:3}

gen_build() {
local f=$1

# use luet expansions
PACKAGE_NAME="$(/tmp/yq r $f name)"
PACKAGE_VERSION="$(/tmp/yq r $f version)"
PACKAGE_CATEGORY="$(/tmp/yq r $f category)"

basedir="$(dirname $f)"

if [ "${PORTAGE_ARTIFACTS}" == "true" ]; then
mottainai-cli task compile "$ROOT_DIR"/templates/emerge.build.yaml.tmpl \
                            -s LayerCategory="$BUILD_LAYER_CATEGORY" \
                            -s LayerVersion=$BUILD_LAYER_VERSION \
                            -s LayerName="$BUILD_LAYER_NAME" \
                            -s Binhost="true" \
                            -s Jobs="${JOBS}" \
                            -o $basedir/build.yaml
else
mottainai-cli task compile "$ROOT_DIR"/templates/emerge.build.yaml.tmpl \
                            -s LayerCategory="$BUILD_LAYER_CATEGORY" \
                            -s LayerVersion=$BUILD_LAYER_VERSION \
                            -s LayerName="$BUILD_LAYER_NAME" \
                            -s Jobs="${JOBS}" \
                            -o $basedir/build.yaml
fi
echo "Generated build definition for $PACKAGE_NAME-$PACKAGE_VERSION ($PACKAGE_CATEGORY) in $basedir/build.yaml"
}

clean() {
  rm -rf /tmp/yq
}

echo "Running builder creator script"

if [ ! -e "/tmp/yq" ]; then
wget 'https://github.com/mikefarah/yq/releases/download/2.4.1/yq_linux_amd64' -O /tmp/yq
chmod +x /tmp/yq
trap clean EXIT
fi

for f in $(find ${LUET_REPO} -name '*.yaml'); do gen_build $f; done

