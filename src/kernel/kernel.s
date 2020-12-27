%define MEMORY(x) (x - 0x401000 + 0x7E00)

[bits 32]
kmain:
        call idt_init
        call clear
        mov ebx, 0

        call get_cursor
        mov cl, 'C'
        mov ch, 0xA
        call printc

        call newline

        call get_cursor
        mov ecx, MEMORY(STR)
        mov dh, 0xE
        call print

        call newline
        
        call get_cursor
        mov ecx, MEMORY(STR)
        mov dh, 0xA
        call print

        call newline
        jmp $

STR:    db "Hello, World!", 0
        
%include "port.s"
%include "irq.s"
%include "screen.s"
