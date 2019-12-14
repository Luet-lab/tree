#!/bin/bash

set -e


version=$(wget -4 -O -  http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-systemd.txt --quiet | tail -n 1 | awk 'match($1, /^[0-9]+/)  { print substr($1, RSTART, RLENGTH) }')

echo "Generating base layer spec for $version"
basedir=$ROOT_DIR/layers/amd64/base/0.$version

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
