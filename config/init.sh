#!/usr/bin/env bash

msg() {
    echo -E "$1"
}

# Display environment variables
echo -e "Variables:
\\t- SBC=${SBC}
\\t- MAKE_J=${MAKE_J}
\\t- MAKE_MENUCONFIG=${MAKE_MENUCONFIG}
\\t- MEDIA_BOOT=${MEDIA_BOOT}
\\t- MEDIA_ROOT=${MEDIA_ROOT}"

# Aliases
alias make="make -j $MAKE_J"
alias move_to_kernel_dir="cd /kernel"

msg "Move to /kernel directory..."
move_to_kernel_dir

msg "Set environment variables for $SBC..."
if [ "$SBC" = "XU3" ] || [ "$SBC" = "xu3" ]; then
    export ARCH=arm
    export PATH=/opt/toolchains/arm-eabi-4.6/bin/:$PATH
    export CROSS_COMPILE=arm-eabi-
    export DEFCONFIG="odroidxu3_defconfig"
elif [ "$SBC" = "XU4" ] || [ "$SBC" = "xu4" ]; then
    export ARCH=arm
    export CROSS_COMPILE=arm-linux-gnueabihf-
    export PATH=/opt/toolchains/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf/bin/:$PATH
    export DEFCONFIG="odroidxu4_defconfig"
elif [ "$SBC" = "C1" ] || [ "$SBC" = "c1" ]; then
    export ARCH=arm
    export CROSS_COMPILE=arm-linux-gnueabihf-
    export PATH=/opt/toolchains/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin/:$PATH
    export DEFCONFIG="odroidc_defconfig"
elif [ "$SBC" = "C2" ] || [ "$SBC" = "c2" ]; then
    export ARCH=arm64
    export CROSS_COMPILE=aarch64-linux-gnu-
    export PATH=/opt/toolchains/gcc-linaro-aarch64-linux-gnu-4.9-2014.09_linux/bin/:$PATH
    export DEFCONFIG="odroidc2_defconfig"
else
    if [ -n "$SBC" ]; then
        msg "You have to specify what ODROID SBC you will build a kernel."
    else
        msg "This image supports only ODROID XU3, XU4, C1, C2."
    fi

    msg "Program will be terminated."
    exit
fi

msg "Do make $DEFCONFIG..."
make "$DEFCONFIG" -j "$MAKE_J"

if [ "$MAKE_MENUCONFIG" = "true" ]; then
    msg "Do make menuconfig..."
    make menuconfig -j "$MAKE_J"

    msg "Program will be terminated."
    exit
fi
