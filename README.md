# docker-odroid-kernel-builder

## What is this

This image is written for easy compile on development of **ODROID Linux kernel**.

This has each toolchain of the ODROID boards in advance. So you can compile with only **git cloning source code** and **pulling this image**.

## Is this run on macOS or Windows

Unfortunately, **nope**.

This image runs on Ubuntu Linux, which means that it runs on Linux kernel. In macOS or Windows, this Docker runs this image on Linux VM due to the absence of the kernel on them.

For further information, please refer to [References](#References) section of this documents.

## How to use

Basic usage is,

```bash
docker run -it --rm \
-v /kernel/source/path:/kernel \
-v /boot/media/boot/partition:/media/boot \
-v /boot/media/root/partition:/media/root \
-e SBC=name of sbc without odroid prefix
-e MAKE_ARGS=make arguments you would like to use \
awesometic/odroid-kernel-builder
```

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
