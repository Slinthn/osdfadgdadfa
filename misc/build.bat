@echo off
cls
if not exist ..\build mkdir ..\build

pushd ..\src\boot
nasm bootsector.s -f bin -o ..\..\build\bootsector.bin
popd

pushd ..\src\kernel
rem gcc kernel.c -ffreestanding -c -o ..\..\build\kernel.obj
nasm kernel.s --prefix _ -f elf -o ..\..\build\skernel.obj
popd

pushd ..\build
rem ld -o kernel.tmp skernel.obj kernel.obj
ld -Ttext 0x7e00 -T ..\misc\link.ld -o kernel.tmp skernel.obj
objcopy -O binary kernel.tmp kernel.bin
type bootsector.bin kernel.bin > image.bin
rem start cmd /c gdb -ex "target remote localhost:1234" -x "symbol-file o:/build/kernel.obj"
rem -d int
qemu-system-x86_64 -fda image.bin -M q35
popd
