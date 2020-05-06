# docker-odroid-kernel-builder

![](https://img.shields.io/docker/automated/awesometic/odroid-kernel-builder)
![](https://img.shields.io/docker/build/awesometic/odroid-kernel-builder)
![](https://img.shields.io/microbadger/image-size/awesometic/odroid-kernel-builder)
![](https://img.shields.io/microbadger/layers/awesometic/odroid-kernel-builder)
![](https://img.shields.io/docker/pulls/awesometic/odroid-kernel-builder)
![](https://img.shields.io/docker/stars/awesometic/odroid-kernel-builder)

## What is this

This image is written for easy compile on development of **Odroid Linux kernel**.

This has each toolchain of the Odroid boards in advance, respectively. So you can compile with only **download Odroid kernel source code** and **pulling/running this image**.

## Is this run on macOS or Windows

Unfortunately, **partly not**.

This image runs on Ubuntu Linux based, which means that it runs on Linux Kernel. In macOS or Windows, their Docker will run this image on Linux VM due to the absence of the native Linux kernel on them.

So that the performance is tooooo slower than the native Linux machine does. In my case, on macOS 10.14 with E3-1230v3 processor, it takes more than 2 hours for compiling XU4 kernel.

For further information, please refer to [References](#References) section of this documents.

### WSL 2 (Windows Subsystem for Linux)

However, if you use Windows 20h1 or higher, you can build as fast as on the Linux system. In my experience, that difference is only a few minutes, probably it can be seconds for the powerful system.

You can refer to this link to know about [Docker WSL2 backend](https://docs.docker.com/docker-for-windows/wsl-tech-preview/).

## How to use

The basic usage is,

```bash
docker run -it --rm \
-v { Kernel source path }:/kernel \
-v { Path to receive output kernel binaries from the image }:/output \
-v { Path to boot media's boot partition }:/media/boot \
-v { Path to boot media's rootfs partition }:/media/rootfs \
-e USER_UID={ UID to correct ownership, set 1000 by default } \
-e USER_GID={ GID to correct ownership, set 1000 by default } \
-e SBC={ The name of your SBC without the prefix word Odroid } \
-e MAKE_ARGS={ make arguments you about to use } \
-e AUTO_INSTALL={ Install automatically to the boot media after complete building kernel } \
awesometic/odroid-kernel-builder
```

Looks quite complicate. The examples in the below.

* Just check build time

```bash
docker run -it --rm \
-v $(pwd):/kernel \
-e USER_UID=$UID \
-e USER_GID=$GID \
-e SBC=n2 \
-e MAKE_ARGS=cleanbuild \
awesometic/odroid-kernel-builder
```

* Save the built kernel results to the shared folder

```bash
docker run -it --rm \
-v $(pwd):/kernel \
-v ~/kernel-outputs:/output \
-e USER_UID=$UID \
-e USER_GID=$GID \
-e SBC=n2 \
-e MAKE_ARGS=cleanbuild \
awesometic/odroid-kernel-builder
```

* Install automatically to your boot media

```bash
docker run -it --rm \
-v $(pwd):/kernel \
-v /media/boot:/media/boot \
-v /media/rootfs:/media/rootfs \
-e USER_UID=$UID \
-e USER_GID=$GID \
-e SBC=n2 \
-e MAKE_ARGS=cleanbuild \
-e AUTO_INSTALL=true \
awesometic/odroid-kernel-builder
```

### Choose a type of SBC


You have to put your Odroid device name as a value of **SBC** environment variable. Current supported list with board and its supported U-Boot versions is here.

* **XU3**: 3.10, 4.9
* **XU4**: 4.14
* **C1**: 3.10
* **C2**: 3.14, 3.16
* **N2**: 4.9
* **C4**: 4.9

Operation confirmed on **XU4, C1, C2, N2**.

### Parameters for make command

You can put your parameters for the make command as a value of **MAKE_ARGS** environment variable. Here are the confirmed operations.

* **defconfig** for `make odroid$SBC_defconfig` repectively
* **menuconfig** for `make menuconfig`
* **clean** for `make clean`
* **distclean** for `make distclean`
* **cleanbuild** for `make distclean; make odroid$SBC_defconfig; make`
* **{no args}** for `make`

### Install automatically to your boot media

If you want to **install the kernel image/dtb/modules to your boot media automatically**, make sure that your boot media mounted in advance to pass its partitions to container as the volumes. Then give the environment variable **AUTO_INSTALL=true**. In most of the Linux DISTROs, after inserting the boot media then that will be mounted to under **/media/$USER** directory

### No Daemon mode

Do not run this image as a daemon. Promptly to be terminated because it doesn't have any jobs to do.

## References

### HARDKERNEL

* [Official Websites](https://www.hardkernel.com)
* [Wiki](https://wiki.odroid.com)
* [Forum](https://forum.odroid.com)

### General

* [Documents of "docker run"](https://docs.docker.com/engine/reference/commandline/run/)
* [EXT4 on macOS](https://apple.stackexchange.com/questions/140536/how-do-i-mount-ext4-using-os-x-fuse)
* [Why performance is slow on macOS/Windows](https://www.reddit.com/r/docker/comments/7xvlye/docker_for_macwindows_performances_vs_linux/)
* [Docker WSL2 backend](https://docs.docker.com/docker-for-windows/wsl-tech-preview/)

## Author

[Yang Deokgyu](secugyu@gmail.com)
