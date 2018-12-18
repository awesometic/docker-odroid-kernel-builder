#!/usr/bin/env bash

msg() {
    echo -e "- MSG: $1"
}

if [ -d "/media/boot" ]; then
    MEDIA_BOOT=True
else
    MEDIA_BOOT=False
fi

if [ -d "/media/root" ]; then
    MEDIA_ROOT=True
else
    MEDIA_ROOT=False
fi

# Display environment variables
echo -e "Variables:
\\t- SBC=$SBC
\\t- MAKE_ARGS=$MAKE_ARGS
\\t- MEDIA_BOOT=$MEDIA_BOOT
\\t- MEDIA_ROOT=$MEDIA_ROOT"

msg "Set environment variables for $SBC..."
if [ "$SBC" = "XU3" ] || [ "$SBC" = "xu3" ]; then
    export ARCH=arm
    export CROSS_COMPILE=arm-eabi-
    export PATH=/toolchains/arm-eabi-4.6/bin:$PATH
    export DEFCONFIG="odroidxu3_defconfig"
    export BOOT_FILES="arch/arm/boot/zImage arch/arm/boot/dts/exynos5422-odroidxu3.dtb"
elif [ "$SBC" = "XU4" ] || [ "$SBC" = "xu4" ]; then
    export ARCH=arm
    export CROSS_COMPILE=arm-linux-gnueabihf-
    export PATH=/toolchains/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf/bin:$PATH
    export DEFCONFIG="odroidxu4_defconfig"
    export BOOT_FILES="arch/arm/boot/zImage arch/arm/boot/dts/meson8b_odroidxu?.dtb"
elif [ "$SBC" = "C1" ] || [ "$SBC" = "c1" ]; then
    export ARCH=arm
    export CROSS_COMPILE=arm-linux-gnueabihf-
    export PATH=/toolchains/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin:$PATH
    export DEFCONFIG="odroidc_defconfig"
    export BOOT_FILES="arch/arm/boot/uImage arch/arm/boot/dts/meson8b_odroidc.dtb"
elif [ "$SBC" = "C2" ] || [ "$SBC" = "c2" ]; then
    export ARCH=arm64
    export CROSS_COMPILE=aarch64-linux-gnu-
    export PATH=/toolchains/gcc-linaro-aarch64-linux-gnu-4.9-2014.09_linux/bin:$PATH
    export DEFCONFIG="odroidc2_defconfig"
    export BOOT_FILES="arch/arm64/boot/Image arch/arm64/boot/dts/meson64_odroidc2.dtb"
else
    msg "You have to specify what ODROID SBC you will build a kernel."
    msg "This image supports { only ODROID: KERNEL }"
    msg "  - XU3: 3.10, 4.9"
    msg "  - XU4: 4.14"
    msg "  - C1 : 3.10"
    msg "  - C2 : 3.14, 3.16"
    msg "Program will be terminated."
    exit
fi

if [ "$MAKE_ARGS" = "clean" ]; then
    msg "Clean up the workspace..."
    make -j "$(nproc)" clean
elif [ "$MAKE_ARGS" = "defconfig" ]; then
    msg "Do make $DEFCONFIG..."
    make -j "$(nproc)" "$DEFCONFIG"
else
    if [ -z "$MAKE_ARGS" ]; then
        msg "Do make..."
        make -j "$(nproc)"
    else
        msg "Do make $MAKE_ARGS..."
        make -j "$(nproc)" "$MAKE_ARGS"
    fi

    if [ -d "/media/boot" ]; then
        msg "Move new kernel files to boot media..."
        cp -f "$BOOT_FILES" /media/boot && sync
    fi

    if [ -d "/media/root" ]; then
        msg "Do make modules_install..."
        make -j "$(nproc)" modules_install ARCH=$ARCH INSTALL_MOD_PATH=/media/root && sync
    fi
fi

msg "All processes are done!"
