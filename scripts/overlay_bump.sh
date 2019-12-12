#!/bin/bash

set -e

# Create a temporary directory and store its name in a variable ...
TMPDIR=$(mktemp -d)

# Bail out if the temp directory wasn't created successfully.
if [ ! -e $TMPDIR ]; then
    >&2 echo "Failed to create temp directory"
    exit 1
fi

# Make sure it gets removed even if the script exits abnormally.
trap "exit 1"           HUP INT PIPE QUIT TERM
trap 'rm -rf "$TMPDIR"' EXIT

git clone https://github.com/Sabayon/sabayon-distro $TMPDIR
pushd $TMPDIR
SHA=$(git rev-parse origin/master)
popd

rm -rf $TMPDIR
mkdir -p $TMPDIR
git clone https://github.com/Sabayon/for-gentoo $TMPDIR
pushd $TMPDIR
SHA2=$(git rev-parse origin/master)
popd

d=`date +%Y%m%d`

echo "Generating overlays spec for $d - $SHA $SHA2"
basedir=$ROOT_DIR/overlays/sabayon-build-overlays/sabayon-overlay/0.$d

mkdir -p $basedir
cp -rfv $ROOT_DIR/overlays/sabayon-build-overlays/sabayon-overlay/portage_config.sh $basedir/

mottainai-cli task compile "$ROOT_DIR"/templates/sabayon-overlay.yaml.tmpl \
                            -s ForGentooCommit="$SHA2" \
                            -s DistroCommit="$SHA" \
                            -s LayerVersion="0.1" \
                            -s PortageVersion="0.1" \
                            -o $basedir/build.yaml

mottainai-cli task compile "$ROOT_DIR"/templates/definition.yaml.tmpl \
                                -s PackageCategory="layer" \
                                -s PackageVersion="0.$d" \
                                -s PackageName="build-sabayon-overlay" \
                                -o $basedir/definition.yaml


basedir=$ROOT_DIR/overlays/sabayon-overlay/0.$d

mkdir -p $basedir

mottainai-cli task compile "$ROOT_DIR"/templates/sabayon-overlay-naive.yaml.tmpl \
                            -s ForGentooCommit="$SHA2" \
                            -s DistroCommit="$SHA" \
                            -s LayerVersion="0.1" \
                            -o $basedir/build.yaml

mottainai-cli task compile "$ROOT_DIR"/templates/definition.yaml.tmpl \
                                -s PackageCategory="layer" \
                                -s PackageVersion="0.$d" \
                                -s PackageName="sabayon-overlay" \
                                -o $basedir/definition.yaml


 #Bump build layer - just pin our overlay and latest available from portage
basedir=$ROOT_DIR/layers/amd64/build-sabayon-overlays/0.$d

mkdir -p $basedir

mottainai-cli task compile "$ROOT_DIR"/templates/buildlayer.tmpl \
                            -s PortageVersion="0.1" \
                            -s OverlayVersion="0.$d" \
                            -o $basedir/build.yaml

mottainai-cli task compile "$ROOT_DIR"/templates/definition.yaml.tmpl \
                                -s PackageCategory="layer" \
                                -s PackageVersion="0.$d" \
                                -s PackageName="build-sabayon-overlays" \
                                -o $basedir/definition.yaml
