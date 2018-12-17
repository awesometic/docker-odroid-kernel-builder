FROM amd64/ubuntu:bionic
LABEL maintainer="Awesometic <awesometic.lab@gmail.com>" \
      description="An image to make ODROID kernel build much easier."

# Environments
ENV SBC="" \
    MAKE_J="1" \
    MAKE_MENUCONFIG="false" \
    MEDIA_BOOT="" \
    MEDIA_ROOT=""

# Install dependencies
# It is divided into each command to prevent from barely caused download fail
RUN apt-get update && apt-get -y -q upgrade
RUN apt-get -y -q install vim
RUN apt-get -y -q install git
RUN apt-get -y -q install gcc
RUN apt-get -y -q install bc
RUN apt-get -y -q install lzop
RUN apt-get -y -q install u-boot-tools
RUN apt-get -y -q install build-essential
RUN apt-get -y -q install libssl-dev
RUN apt-get -y -q install libncurses5-dev
RUN apt-get -y -q install libqt4-dev
RUN apt-get -y -q install lib32z1
RUN apt-get -y -q install libc6-i386
RUN apt-get -y -q install lib32stdc++6
# RUN apt-get -y -q install zlib1g:i386
RUN apt-get clean

# Create directories to use
RUN mkdir -p /host /opt/toolchains

# Add toolchains
ADD config/toolchains/arm-eabi-4.6.tar.gz /toolchains
ADD config/toolchains/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf.tar.xz /toolchains
ADD config/toolchains/gcc-linaro-aarch64-linux-gnu-4.9-2014.09_linux.tar.xz /toolchains
ADD config/toolchains/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz /toolchains

# Add a shell script for entry point
ADD config/init.sh /
RUN chmod a+x /init.sh

VOLUME [ "/kernel" ]
WORKDIR /kernel
ENTRYPOINT [ "/init.sh" ]
