#!/usr/bin/env bash

msg() {
    echo -e "${TEXT_BOLD}"
    echo -e "/* $1 */"
    echo -e "${TEXT_RESET}"
}

export MAKE_JOBS="$(( $(nproc) * 6 / 5 ))"
export MAKE_AGRS="${MAKE_ARGS,,}"
export SBC="${SBC,,}"
export AUTO_INSTALL="${AUTO_INSTALL,,}"
[ -z $USER_UID ] && USER_UID=1000
[ -z $USER_GID ] && USER_GID=1000
[ -n "$(ls -A /media/boot)" ] && MEDIA_BOOT=true || MEDIA_BOOT=false
[ -n "$(ls -A /media/rootfs)" ] && MEDIA_ROOTFS=true || MEDIA_BOOT=false

# Display environment variables
echo -e "Variables:
\\t- USER_UID=$USER_UID
\\t- USER_GID=$USER_GID
\\t- SBC=$SBC
\\t- MAKE_ARGS=$MAKE_ARGS
\\t- MEDIA_BOOT=$MEDIA_BOOT
\\t- MEDIA_ROOTFS=$MEDIA_ROOTFS
\\t- AUTO_INSTALL=$AUTO_INSTALL"

msg "Set environment variables for $SBC..."
if [ "$SBC" = "xu3" ]; then
    export ARCH=arm
    export CROSS_COMPILE=arm-eabi-
    export PATH=/toolchains/arm-eabi-4.6/bin:$PATH
    export DEFCONFIG="odroidxu3_defconfig"
    export BOOT_FILES=(
        "/kernel/arch/arm/boot/zImage"
        "/kernel/arch/arm/boot/dts/exynos5422-odroidxu3.dtb"
    )
elif [ "$SBC" = "xu4" ]; then
    export ARCH=arm
    export CROSS_COMPILE=arm-linux-gnueabihf-
    export PATH=/toolchains/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf/bin:$PATH
    export DEFCONFIG="odroidxu4_defconfig"
    export OVERLAYS_DIR="/kernel/arch/arm/boot/dts/overlays"
    export BOOT_FILES=(
        "/kernel/arch/arm/boot/zImage"
        "/kernel/arch/arm/boot/dts/exynos5422-odroidxu4.dtb"
        "/kernel/arch/arm/boot/dts/exynos5422-odroidxu4-kvm.dtb"
    )
elif [ "$SBC" = "c1" ]; then
    export ARCH=arm
    export CROSS_COMPILE=arm-linux-gnueabihf-
    export PATH=/toolchains/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin:$PATH
    export DEFCONFIG="odroidc_defconfig"
    export BOOT_FILES=(
        "/kernel/arch/arm/boot/uImage"
        "/kernel/arch/arm/boot/dts/meson8b_odroidc.dtb"
    )
elif [ "$SBC" = "c2" ]; then
    export ARCH=arm64
    export CROSS_COMPILE=aarch64-linux-gnu-
    export PATH=/toolchains/gcc-linaro-aarch64-linux-gnu-4.9-2014.09_linux/bin:$PATH
    export DEFCONFIG="odroidc2_defconfig"
    export BOOT_FILES=(
        "/kernel/arch/arm64/boot/Image"
        "/kernel/arch/arm64/boot/dts/meson64_odroidc2.dtb"
    )
elif [ "$SBC" = "n2" ]; then
    export ARCH=arm64
    export CROSS_COMPILE=aarch64-linux-gnu-
    export PATH=/toolchains/gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu/bin:$PATH
    export DEFCONFIG="odroidn2_defconfig"
    export OVERLAYS_DIR="/kernel/arch/arm64/boot/dts/amlogic/overlays-n2"
    export BOOT_FILES=(
        "/kernel/arch/arm64/boot/Image.gz"
        "/kernel/arch/arm64/boot/dts/amlogic/meson64_odroidn2.dtb"
    )
elif [ "$SBC" = "c4" ]; then
    export ARCH=arm64
    export CROSS_COMPILE=aarch64-linux-gnu-
    export PATH=/toolchains/gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu/bin:$PATH
    export DEFCONFIG="odroidg12_defconfig"
    export OVERLAYS_DIR="/kernel/arch/arm64/boot/dts/amlogic/overlays-c4"
    export BOOT_FILES=(
        "/kernel/arch/arm64/boot/Image.gz"
        "/kernel/arch/arm64/boot/dts/amlogic/meson64_odroidc4.dtb"
    )
else
    msg "You have to specify what ODROID SBC you will build a kernel."
    msg "This image is confirmed on { ODROID : KERNEL }"
    msg "  - XU3: 3.10, 4.9"
    msg "  - XU4: 4.14"
    msg "  - C1 : 3.10"
    msg "  - C2 : 3.14, 3.16"
    msg "  - N2 : 4.9"
    msg "  - C4 : 4.9"
    msg "Program will be terminated."
    exit
fi

if [ "$MAKE_ARGS" = "cleanbuild" ]; then
    msg "Clean up the workspace then build from the scratch..."
    make -j "$MAKE_JOBS" distclean
    make -j "$MAKE_JOBS" "$DEFCONFIG"
    make -j "$MAKE_JOBS"
    make -j "$MAKE_JOBS" modules_install ARCH=$ARCH INSTALL_MOD_PATH=/output && sync
elif [ "$MAKE_ARGS" = "clean" ]; then
    msg "Clean up the workspace..."
    make -j "$MAKE_JOBS" clean
elif [ "$MAKE_ARGS" = "distclean" ]; then
    msg "Clean up the workspace to back to the initial state..."
    make -j "$MAKE_JOBS" distclean
elif [ "$MAKE_ARGS" = "defconfig" ]; then
    msg "Do make $DEFCONFIG..."
    make -j "$MAKE_JOBS" "$DEFCONFIG"
elif [ "$MAKE_ARGS" = "menuconfig" ]; then
    msg "Do make menuconfig..."
    make -j "$MAKE_JOBS" "menuconfig"
elif [ -z "$MAKE_ARGS" ]; then
    msg "Do make..."
    make -j "$MAKE_JOBS"
    if [ "$SBC" == "c1" ]; then
        make -j "$MAKE_JOBS" uImage
    fi
    msg "Do make modules_install to the output directory..."
    make -j "$MAKE_JOBS" modules_install ARCH=$ARCH INSTALL_MOD_PATH=/output && sync
else
    msg "Do make $MAKE_ARGS..."
    make -j "$MAKE_JOBS" "$MAKE_ARGS"
fi

msg "Copy the result files to the output directory. Check if you have given a output directory..."
for FILE in "${BOOT_FILES[@]}"; do
    cp -afv "$FILE" /output
done
if [ -n "$OVERLAYS_DIR" ] && [ -d "$OVERLAYS_DIR" ]; then
    [ -d "/output/overlays" ] || mkdir -p /output/overlays
    cp -vf "$OVERLAYS_DIR"/*.dtbo /output/overlays
fi

if [ "$AUTO_INSTALL" = "true" ]; then
    if [ "$MEDIA_BOOT" = "true" ]; then
        msg "Move the new kernel files to the boot media's boot partition..."
        for FILE in "${BOOT_FILES[@]}"; do
            cp -vf "$FILE" /media/boot && sync
        done
        if [ -n "$OVERLAYS_DIR" ] && [ -d "$OVERLAYS_DIR" ]; then
            [ -d "/media/boot/overlays" ] || mkdir -p /media/boot/overlays
            cp -vf "$OVERLAYS_DIR"/*.dtbo /media/boot/overlays
        fi
    fi
    if [ "$MEDIA_ROOTFS" = "true" ]; then
        msg "Move the new module files to the boot media's rootfs partition..."
        rsync -avz /output/lib/modules/ /media/rootfs/lib/modules/ && sync
    fi
fi

msg "Change ownership..."
chown -R "$USER_UID":"$USER_GID" /kernel
chown -R "$USER_UID":"$USER_GID" /output

sync
msg "All processes are done!"
