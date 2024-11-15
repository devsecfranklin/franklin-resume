# Test

## ARM64

* [Running Arm Binaries on x86 with QEMU-User](https://azeria-labs.com/arm-on-x86-qemu-user/)
* [Running and Building ARM Docker Containers on x86](https://www.stereolabs.com/docs/docker/building-arm-container-on-x86)

```sh
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y qemu-user qemu-user-static gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu binutils-aarch64-linux-gnu-dbg build-essential
```

```sh
franklin@node0:~/workspace/DEV-TEST/testing-assembly/test $ aarch64-linux-gnu-gcc -static -o hello64 test_arm64.c
franklin@node0:~/workspace/DEV-TEST/testing-assembly/test $ ./hello64
Hello, I'm executing ARM64 instructions!
```

## ARM32

```sh
sudo apt install gcc-arm-linux-gnueabihf binutils-arm-linux-gnueabihf binutils-arm-linux-gnueabihf-dbg
```
