#!/bin/bash

set -e


version=$(wget -4 -O -  http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-systemd.txt --quiet | tail -n 1 | awk 'match($1, /^[0-9]+/)  { print substr($1, RSTART, RLENGTH) }')

echo "Generating base layer spec for $version"
basedir=$ROOT_DIR/layers/amd64/base/0.$version

if [ ! -d $basedir ]; then
mkdir -p $basedir
cp -rf $ROOT_DIR/layers/amd64/base/build.sh $basedir/
mottainai-cli task compile "$ROOT_DIR"/templates/baselayer.tmpl \
                            -s StageVersion="$version" \
                            -o $basedir/build.yaml

mottainai-cli task compile "$ROOT_DIR"/templates/definition.yaml.tmpl \
                                -s PackageCategory="layer" \
                                -s PackageVersion="0.$version" \
                                -s PackageName="base" \
                                -o $basedir/definition.yaml

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

git clone https://github.com/gentoo/gentoo $TMPDIR
pushd $TMPDIR
SHA=$(git rev-parse origin/master)
popd

d=`date +%Y%m%d`

sed -i "s|layer/portage-0.* |layer/portage-0.$d |g" $ROOT_DIR/.travis.yml
echo "Generating portage spec for $d - $SHA"
basedir=$ROOT_DIR/overlays/portage/0.$d

mkdir -p $basedir

mottainai-cli task compile "$ROOT_DIR"/templates/portage.yaml.tmpl \
                            -s LayerCategory="layer" \
                            -s LayerVersion=0.$version \
                            -s LayerName="base" \
                            -s Commit="$SHA" \
                            -o $basedir/build.yaml

mottainai-cli task compile "$ROOT_DIR"/templates/definition.yaml.tmpl \
                                -s PackageCategory="layer" \
                                -s PackageVersion="0.$d" \
                                -s PackageName="portage" \
                                -o $basedir/definition.yaml
fi