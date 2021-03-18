# docker-odroid-kernel-builder

![](https://img.shields.io/docker/automated/awesometic/odroid-kernel-builder)
![](https://img.shields.io/docker/build/awesometic/odroid-kernel-builder)
![](https://img.shields.io/microbadger/image-size/awesometic/odroid-kernel-builder)
![](https://img.shields.io/microbadger/layers/awesometic/odroid-kernel-builder)
![](https://img.shields.io/docker/pulls/awesometic/odroid-kernel-builder)
![](https://img.shields.io/docker/stars/awesometic/odroid-kernel-builder)

## What is this

This image is written for easy compile on development of **Odroid Linux kernel**.

This has all the toolchain the Odroid boards requires in advance. So you can compile your custom Linux kernel by just **downloading Odroid kernel source tree** and **running this image**.

## Performance on Windows and macOS

Unfortunately, **it should be too slow**.

This image runs on Ubuntu Linux based, which means that it runs on Linux Kernel. In macOS or Windows, their Docker uses the specific virtual engine provided by each OS to emulate the Linux environment.

So that the performance is tooooo slower than the native Linux machine does. In my case, on macOS 10.14 with E3-1230v3 processor, it takes more than 2 hours for compiling XU4 kernel. This might be acceptable for someone but it may not in most cases.

Thus, it should work on any Docker supported system but the performance will be very slow.

For further information, please refer to [References](#References) section of this documents.

### WSL 2 (Windows Subsystem for Linux)

However, if you use Windows 20h1 or higher, you can build as fast as on the Linux system thanks to the WSL 2 that is introduced in modern Windows 10.

In my experience, that difference is only a few minutes between native Linux and WSL 2. Probably it can be just a few seconds for the powerful system.

You can refer to this link to know about [Docker WSL2 backend](https://docs.docker.com/docker-for-windows/wsl-tech-preview/).

## Only supports Hardkernel official Ubuntu image

It is not suitable for third party images like Android kernel, @tobetter's Debian/Ubuntu, and Armbian, DietPi. All these images have different kernel source tree and also has differed boot directory structure.

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
* **XU4**: 4.14, 5.4
* **C1**: 3.10
* **C2**: 3.14, 3.16
* **N2**: 4.9
* **C4/HC4**: 4.9

### Parameters for make command

You can put your parameters for the make command as a value of **MAKE_ARGS** environment variable. Here are the confirmed operations.

* **defconfig**:`make odroid???_defconfig` for the given SBC environment value
* **menuconfig**: `make menuconfig`
* **clean**: `make clean`
* **distclean**: `make distclean`
* **cleanbuild**: `make distclean; make odroid???_defconfig; make`
* **Given nothing**: `make`

The building process will use all the available CPU cores by using `"$(nproc) * 6 / 5"` fomula.

### Install automatically to your boot media

If you want to **install the kernel image/dtb/modules to your boot media automatically**, make sure that your boot media mounted in advance to pass its partitions to container as the volumes. Then give the environment variable **AUTO_INSTALL=true**. In most of the Linux DISTROs, after inserting the boot media then that will be mounted to under **/media/$USER** directory

### Do not treat it as a daemon mode

Do not run this image as a daemon. Promptly to be terminated because it doesn't have any jobs to do.

## References

* [Documents of "docker run"](https://docs.docker.com/engine/reference/commandline/run/)
* [EXT4 on macOS](https://apple.stackexchange.com/questions/140536/how-do-i-mount-ext4-using-os-x-fuse)
* [Why performance is slow on macOS/Windows](https://www.reddit.com/r/docker/comments/7xvlye/docker_for_macwindows_performances_vs_linux/)
* [Docker WSL2 backend](https://docs.docker.com/docker-for-windows/wsl-tech-preview/)

## Author

Deokgyu Yang (<secugyu@gmail.com>)
