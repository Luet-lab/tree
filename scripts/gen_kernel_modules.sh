#!/bin/bash
# Kernel module bump

MODULES=(net-vpn@wireguard@0.0.20190406-r1)
KERNELS=$(ls $ROOT_DIR/sys-kernel/linux-sabayon)

for i in $KERNELS;
do
    for m in $MODULES;
    do
        parts=($(echo $m | tr "@" "\n"))
        cat=${parts[0]}
        pn=${parts[1]}
        ver=${parts[2]}
        echo "Generating spec for kernel $i, package $cat $pn $ver"
        basedir=$DESTINATION/kernel-modules/"$pn"/"$ver"/"$i"
        mkdir -p $basedir

        if [ "${PORTAGE_ARTIFACTS}" == "true" ]; then
        mottainai-cli task compile "$DESTINATION"/templates/modules.build.yaml.tmpl \
                                    -s LayerCategory="sys-kernel" \
                                    -s LayerVersion=$i \
                                    -s LayerName="linux-sabayon" \
                                    -s PackageName="$pn" \
                                    -s Binhost="true" \
                                    -o $basedir/build.yaml

        else
        mottainai-cli task compile "$DESTINATION"/templates/modules.build.yaml.tmpl \
                                    -s LayerCategory="sys-kernel" \
                                    -s LayerVersion=$i \
                                    -s LayerName="linux-sabayon" \
                                    -s PackageName="$pn" \
                                    -s Binhost="true" \
                                    -o $basedir/build.yaml
        fi

        mottainai-cli task compile "$DESTINATION"/templates/definition.yaml.tmpl \
                                    -s PackageCategory="$cat-$i" \
                                    -s PackageVersion="$ver" \
                                    -s PackageName="$pn" \
                                    -o $basedir/definition.yaml
    done
done
