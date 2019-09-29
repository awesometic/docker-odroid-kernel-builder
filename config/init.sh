#!/usr/bin/env bash

msg() {
    echo -e "${TEXT_BOLD}"
    echo -e "/* $1 */"
    echo -e "${TEXT_RESET}"
}

MEDIA_BOOT=False
MEDIA_ROOTFS=False
OUTPUT_DIR=False

[ -n "$(ls -A /media/boot)" ] && MEDIA_BOOT=True
[ -n "$(ls -A /media/rootfs)" ] && MEDIA_ROOTFS=True
[ -n "$(ls -A /output)" ] && OUTPUT_DIR=True

MAKE=$(( $(nproc) + 1 ))

# Display environment variables
echo -e "Variables:
\\t- SBC=${SBC,,}
\\t- MAKE_ARGS=${MAKE_ARGS,,}
\\t- MEDIA_BOOT=${MEDIA_BOOT,,}
\\t- MEDIA_ROOT=${MEDIA_ROOTFS,,}
\\t- OUTPUT_DIR=${OUTPUT_DIR,,}
\\t- AUTO_INSTALL=${AUTO_INSTALL,,}"

msg "Set environment variables for ${SBC,,}..."
if [ "${SBC,,}" = "xu3" ]; then
    export ARCH=arm
    export CROSS_COMPILE=arm-eabi-
    export PATH=/toolchains/arm-eabi-4.6/bin:$PATH
    export DEFCONFIG="odroidxu3_defconfig"
    export BOOT_FILES=(
        "/kernel/arch/arm/boot/zImage"
        "/kernel/arch/arm/boot/dts/exynos5422-odroidxu3.dtb"
    )
elif [ "${SBC,,}" = "xu4" ]; then
    export ARCH=arm
    export CROSS_COMPILE=arm-linux-gnueabihf-
    export PATH=/toolchains/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf/bin:$PATH
    export DEFCONFIG="odroidxu4_defconfig"
    export BOOT_FILES=(
        "/kernel/arch/arm/boot/zImage"
        "/kernel/arch/arm/boot/dts/exynos5422-odroidxu4.dtb"
        "/kernel/arch/arm/boot/dts/exynos5422-odroidxu4-kvm.dtb"
    )
elif [ "${SBC,,}" = "c1" ]; then
    export ARCH=arm
    export CROSS_COMPILE=arm-linux-gnueabihf-
    export PATH=/toolchains/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin:$PATH
    export DEFCONFIG="odroidc_defconfig"
    export BOOT_FILES=(
        "/kernel/arch/arm/boot/uImage"
        "/kernel/arch/arm/boot/dts/meson8b_odroidc.dtb"
    )
elif [ "${SBC,,}" = "c2" ]; then
    export ARCH=arm64
    export CROSS_COMPILE=aarch64-linux-gnu-
    export PATH=/toolchains/gcc-linaro-aarch64-linux-gnu-4.9-2014.09_linux/bin:$PATH
    export DEFCONFIG="odroidc2_defconfig"
    export BOOT_FILES=(
        "/kernel/arch/arm64/boot/Image"
        "/kernel/arch/arm64/boot/dts/meson64_odroidc2.dtb"
    )
elif [ "${SBC,,}" = "n2" ]; then
    export ARCH=arm64
    export CROSS_COMPILE=aarch64-linux-gnu-
    export PATH=/toolchains/gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu/bin:$PATH
    export DEFCONFIG="odroidn2_defconfig"
    export BOOT_FILES=(
        "/kernel/arch/arm64/boot/Image.gz"
        "/kernel/arch/arm64/boot/dts/amlogic/meson64_odroidn2.dtb"
    )
else
    msg "You have to specify what ODROID SBC you will build a kernel."
    msg "This image is confirmed on { ODROID : KERNEL }"
    msg "  - XU3: 3.10, 4.9"
    msg "  - XU4: 4.14"
    msg "  - C1 : 3.10"
    msg "  - C2 : 3.14, 3.16"
    msg "  - N2 : 4.9"
    msg "Program will be terminated."
    exit
fi

if [ "${MAKE_ARGS,,}" = "clean" ]; then
    msg "Clean up the workspace..."
    make -j "$MAKE" clean
elif [ "${MAKE_ARGS,,}" = "distclean" ]; then
    msg "Clean up the workspace to back to the initial state..."
    make -j "$MAKE" distclean
elif [ "${MAKE_ARGS,,}" = "defconfig" ]; then
    msg "Do make $DEFCONFIG..."
    make -j "$MAKE" "$DEFCONFIG"
elif [ "${MAKE_ARGS,,}" = "menuconfig" ]; then
    msg "Do make menuconfig..."
    make -j "$MAKE" "menuconfig"
else
    if [ -z "${MAKE_ARGS,,}" ]; then
        msg "Do make..."
        make -j "$MAKE"

        if [ "$SBC" == "c1" ]; then
            make -j "$MAKE" uImage
        fi
    else
        msg "Do make ${MAKE_ARGS,,}..."
        make -j "$MAKE" "${MAKE_ARGS,,}"
    fi

    if [ "${AUTO_INSTALL,,}" = "true" ]; then
        if [ "${MEDIA_BOOT,,}" = "true" ]; then
            msg "Move new kernel files to boot media..."
            
            for FILE in "${BOOT_FILES[@]}"; do
                cp -vf "$FILE" /media/boot && sync
            done
        fi

        if [ "${MEDIA_ROOTFS,,}" = "true" ]; then
            msg "Do make modules_install..."
            make -j "$MAKE" modules_install ARCH=$ARCH INSTALL_MOD_PATH=/media/rootfs && sync
        fi
    fi

    if [ "${OUTPUT_DIR,,}" = "true" ]; then
        msg "Copy the result files to output directory..."
        for FILE in "${BOOT_FILES[@]}"; do
            cp -vf "$FILE" /output
        done
    fi

    sync
fi

msg "All processes are done!"
