# docker-odroid-kernel-builder

## What is this

This image is written for easy compile on development of **ODROID Linux kernel**.

This has each toolchain of the ODROID boards in advance. So you can compile with only **git cloning source code** and **pulling this image**.

## Is this run on macOS or Windows

Unfortunately, **partly not**.

This image runs on Ubuntu Linux based, which means that it runs on Linux kernel. In macOS or Windows, this Docker will run this image on Linux VM due to the absence of the Linux kernel on them.

So that performance is tooooo slower than the native Linux machine does. In my case, on macOS 10.14 with E3-1230v3 processor, it takes more than 2 hours for compiling XU4 kernel.

For further information, please refer to [References](#References) section of this documents.

## How to use

Basic usage is,

```bash
docker run -it --rm \
-v /kernel/source/path:/kernel \
-v /path/to/output:/output \
-v /boot/media/boot/partition:/media/boot \
-v /boot/media/root/partition:/media/root \
-e SBC={ name of the sbc without the prefix word odroid } \
-e MAKE_ARGS={ make arguments you would like to use } \
-e AUTO_INSTALL={ install automatically to the boot media after complete building kernel } \
awesometic/odroid-kernel-builder
```

### Choose a type of SBC

You have to put your ODROID device name as a value of **SBC** environment variable. Current supported list with board and its supported kernel versions is here.

* **XU3**: 3.10, 4.9
* **XU4**: 4.14
* **C1**: 3.10
* **C2**: 3.14, 3.16
* **N2**: 4.9

**WIP:** I confirmed that it works for XU4 with 4.14 kernel, but in the other boards, it will need more tests.

### Parameters for make command

You can put your custom parameters for make command as a value of **MAKE_ARGS** environment variable. Here is the confirmed operations.

* **defconfig** for `make odroid?_defconfig`
* **menuconfig** for `make menuconfig`
* **clean** for `make clean`
* **No arguments** for `make`

### Install automatically to your boot media

If you want to **install kernel/modules to your boot media automatically**, make sure that your boot media mounted in advance to pass its partitions to container as the volumes. Then give the environment variable **AUTO_INSTALL true**. In most of the Linux DISTROs, boot media is mounted under **/media/$USER** directory once you have inserted that.

If **OUTPUT_DIR** is set, compiled files copied to **/output** directory.

### Other imformations

* The volumes for boot/root partition can be omitted so that only the kernel will be compiled.

* Do not run this image as a daemon. Will be terminated if it doesn't have any jobs.

## References

### HARDKERNEL

* [Official Websites](https://www.hardkernel.com)
* [Wiki](https://wiki.odroid.com)
* [Forum](https://forum.odroid.com)

### General

* [Documents of "docker run"](https://docs.docker.com/engine/reference/commandline/run/)
* [EXT4 on macOS](https://apple.stackexchange.com/questions/140536/how-do-i-mount-ext4-using-os-x-fuse)
* [Why performance is slow on macOS/Windows](https://www.reddit.com/r/docker/comments/7xvlye/docker_for_macwindows_performances_vs_linux/)

## Author

[Awesometic](awesometic.lab@gmail.com)
