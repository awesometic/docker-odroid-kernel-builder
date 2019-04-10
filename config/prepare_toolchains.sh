#!/usr/bin/env bash

msg() {
    echo -e "- MSG: $1"
}

# Toolchain download links
TC_URLS=(
    # XU3 (3.10, 4.9)
    "http://dn.odroid.com/ODROID-XU/compiler/arm-eabi-4.6.tar.gz"
    # XU4 (4.14)
    "https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/arm-linux-gnueabihf/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf.tar.xz"
    # C1 (3.10)
    "http://releases.linaro.org/archive/14.09/components/toolchain/binaries/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz"
    # C2 (3.14, 3.16)
    "http://releases.linaro.org/archive/14.09/components/toolchain/binaries/gcc-linaro-aarch64-linux-gnu-4.9-2014.09_linux.tar.xz"
    # N2 (4.9)
    "https://releases.linaro.org/components/toolchain/binaries/6.3-2017.02/aarch64-linux-gnu/gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu.tar.xz"
)

# Extract to /toolchains directory
for URL in "${TC_URLS[@]}"; do
    FILE="$(echo "$URL" | sed "s/.*\///")"

    msg "Download from $URL..."
    wget -nv "$URL" -P /toolchains

    msg "Extract $FILE"...
    if [[ $URL == *"tar.gz" ]]; then
        tar xfz /toolchains/"$FILE" -C /toolchains
    elif [[ $URL == *"tar.xz" ]]; then
        tar xfJ /toolchains/"$FILE" -C /toolchains
    elif [[ $URL == *"tar.bz2" ]]; then
        tar xfj /toolchains/"$FILE" -C /toolchains
    fi
done

msg "Toolchains got ready."
