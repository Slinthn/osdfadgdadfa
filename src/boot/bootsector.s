STACK equ 0x7C00
KERNEL equ 0x7E00

[org 0x7C00]
[bits 16]
main:
        mov bp, STACK
        mov sp, bp

        mov al, 0x33
        mov ah, 0x2
        mov bx, KERNEL
        mov ch, 0x0
        mov cl, 0x2
        mov dh, 0x0
        int 0x13

        call b16_switch_to_pm
        jmp $

%include "gdt.s"
        
[bits 32]
main_pm:
        call KERNEL
        jmp $

times 510-($-$$) db 0
dw 0xAA55
