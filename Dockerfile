FROM amd64/ubuntu:bionic
LABEL maintainer="Awesometic <awesometic.lab@gmail.com>" \
      description="An image to make ODROID kernel build much easier."

# Visible environments
ENV SBC="" \
    MAKE_ARGS=""

# Install dependencies
# It is divided into each command to prevent from barely caused download fail
RUN dpkg --add-architecture i386
RUN apt-get update && apt-get -y -q upgrade
RUN apt-get -y -q install vim
RUN apt-get -y -q install wget
RUN apt-get -y -q install git
RUN apt-get -y -q install gcc
RUN apt-get -y -q install bc
RUN apt-get -y -q install lzop
RUN apt-get -y -q install u-boot-tools
RUN apt-get -y -q install build-essential
RUN apt-get -y -q install kmod
RUN apt-get -y -q install libssl-dev
RUN apt-get -y -q install libncurses5-dev
RUN apt-get -y -q install libqt4-dev
RUN apt-get -y -q install lib32z1
RUN apt-get -y -q install libc6-i386
RUN apt-get -y -q install lib32stdc++6
RUN apt-get -y -q install zlib1g:i386
RUN apt-get clean

# Create directories to use
RUN mkdir -p /toolchains

# Add shell scripts
ADD config/init.sh /
ADD config/prepare_toolchains.sh /
RUN chmod a+x /*.sh

# Add toolchains from the internet
RUN /prepare_toolchains.sh

WORKDIR /kernel
VOLUME [ "/kernel", "/media/boot", "/media/root" ]
ENTRYPOINT [ "/init.sh" ]
