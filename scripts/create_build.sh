#!/bin/bash


LUET_REPO="${LUET_REPO:-/root/repo}"
BUILD_LAYER_NAME="${BUILD_LAYER_NAME:-core-desktop-build}"
BUILD_LAYER_CATEGORY="${BUILD_LAYER_CATEGORY:-layer}"
BUILD_LAYER_VERSION="${BUILD_LAYER_VERSION:->=0.1}"

gen_build() {
local f=$1

# use luet expansions
PACKAGE_NAME="$(/tmp/yq r $f name)"
PACKAGE_VERSION="$(/tmp/yq r $f version)"
PACKAGE_CATEGORY="$(/tmp/yq r $f category)"

basedir="$(dirname $f)"
cat <<EOF > $basedir/build.yaml
steps:
- emerge =\${PACKAGE_CATEGORY}/\${PACKAGE_NAME}-\${PACKAGE_VERSION}
requires:
- category: "$BUILD_LAYER_CATEGORY"
  version:  "$BUILD_LAYER_VERSION"
  name:     "$BUILD_LAYER_NAME"
EOF

if [ "${PORTAGE_ARTIFACTS}" == "true" ]; then
cat <<EOF >> $basedir/build.yaml
includes:
- /usr/portage/packages/.*
EOF
fi
echo "Generated build definition for $PACKAGE_NAME-$PACKAGE_VERSION ($PACKAGE_CATEGORY)"
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

