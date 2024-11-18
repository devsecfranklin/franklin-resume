# Assembly Testing

* [how to enable the 'OK' or 'ACT' LED on the Raspberry Pi](https://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/os/ok01.html)
* [using as](https://sourceware.org/binutils/docs/as/)
* [ARM Assembly Programming with the Raspberry Pi](https://satyria.de/arm/index.php?title=English)
* [](https://personal.utdallas.edu/~pervin/RPiA/RPiA.pdf)
* [assembly primer](https://mariokartwii.com/armv8/)

## Hints

* The linter in codium looks for files with a `.asm` extension so that should be used.

## nasm

```sh
nasm -f elf asm_hello.asm
nasm -f elf hello_world.asm && ld -m elf_i386 hello_world.o -o hello_world
```

## as

* a great Assembler with the abilities to specify the Cortex A-57 CPU (Nintendo Switch CPU)

```sh
sudo apt-get update && sudo apt-get install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu binutils-aarch64-linux-gnu-dbg
aarch64-linux-gnu-as --help ## test the install
aarch64-linux-gnu-as src/hello_arm64.asm -o src/asm64.o && ld src/asm64.o -o src/asm64-2
```

## yasm

```sh
yasm  -felf64  -gdwarf2 src/asm_hello.asm
ld -g -o hello src/asm_hello.o
```
