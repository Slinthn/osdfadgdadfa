STACK equ 0x7C00
KERNEL equ 0x7E00

[org 0x7C00]
[bits 16]
main:
        mov bp, STACK
        mov sp, bp

        mov al, 0x33
        mov bx, KERNEL
        call b16_disk_load

        call b16_switch_to_pm
        jmp $

DRIVE_ID:
        db 0

%include "print.s"
%include "disk.s"
%include "gdt.s"

[bits 32]
main_pm:
        call KERNEL
        jmp $

times 510-($-$$) db 0
dw 0xAA55
