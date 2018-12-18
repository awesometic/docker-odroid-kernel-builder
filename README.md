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
-v /boot/media/boot/partition:/media/boot \
-v /boot/media/root/partition:/media/root \
-e SBC=name of the sbc without the prefix odroid \
-e MAKE_ARGS=make arguments you would like to use \
awesometic/odroid-kernel-builder
```

Make sure that your boot media mounted in advance to pass its partitions to container as the volumes. In most of the Linux DISTROs, boot media is mounted under **/media/$USER** directory if you have inserted that.

You can put your ODROID device name as a value of **SBC** environment variable. Current supported list with board and its kernel is here.

* **XU3**: 3.10, 4.9
* **XU4**: 4.14 (confirmed)
* **C1**: 3.10
* **C2**: 3.14, 3.16 (confirmed)

You can build 3.10 or 4.9 kernel for your **XU4**, but you have to put **XU3** to compile/install properly.

You can put your custom parameters for make command as a value of **MAKE_ARGS** environment variable. Here is the confirmed operations.

* **defconfig** for `make odroid*_defconfig`{.bash}
* **menuconfig** for `make menuconfig`{.bash}
* **clean** for `make clean`{.bash}
* **No arguments** for `make`{.bash}

You can't use modules_install seperately, but you can just compile source code with cached data to do that.

The volumes for boot/root partition can be omitted so that only the kernel will be compiled.

Do not run this image as a daemon. Will be terminated if it doesn't have any jobs.

## References

### HARDKERNEL

* [Official Websites](https://www.hardkernel.com)
* [Wiki](https://wiki.odroid.com)
* [Forum](https://forum.odroid.com)

### General

* [Documents of "docker run"](https://docs.docker.com/engine/reference/commandline/run/#attach-to-stdinstdoutstderr--a)
* [EXT4 on macOS](https://apple.stackexchange.com/questions/140536/how-do-i-mount-ext4-using-os-x-fuse)
* [Why performance is slow on macOS/Windows](https://www.reddit.com/r/docker/comments/7xvlye/docker_for_macwindows_performances_vs_linux/)

## Author

Awesometic (Yang Deokgyu)
