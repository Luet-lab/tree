#!/bin/bash
# Kernel module bump

MODULES=(
"net-vpn@wireguard@0.0.20190406-r1"
"app-emulation@virtualbox-guest-additions@6.0.14"
"app-emulation@virtualbox-modules@6.0.14"
"app-laptop@tp_smapi@0.43"
"media-video@v4l2loopback@0.12.1"
"net-firewall@rtsp-conntrack@4.18"
"net-wireless@broadcom-sta@6.30.223.271-r6"
"sys-fs@vhba@20190410"
"sys-fs@zfs-kmod@0.8.2"
"sys-power@acpi_call@3.17"
"sys-power@bbswitch@0.8-r2"
"x11-drivers@nvidia-drivers@430.26"
"x11-drivers@nvidia-drivers@390.87-r2"
"x11-drivers@nvidia-drivers@340.107-r1"
)

KERNELS=$(ls $ROOT_DIR/sys-kernel/linux-sabayon)

for i in $KERNELS;
do
    for m in ${MODULES[@]};
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
                                    -s PackageCategory="$cat" \
                                    -s Binhost="true" \
                                    -o $basedir/build.yaml

        else
        mottainai-cli task compile "$DESTINATION"/templates/modules.build.yaml.tmpl \
                                    -s LayerCategory="sys-kernel" \
                                    -s LayerVersion=$i \
                                    -s LayerName="linux-sabayon" \
                                    -s PackageName="$pn" \
                                    -s PackageCategory="$cat" \
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
