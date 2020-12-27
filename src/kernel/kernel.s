[bits 32]
kmain:
        call clear
        mov ebx, 0

        call get_cursor
        mov cl, 'C'
        mov ch, 0xA
        call printc

        call newline

        call get_cursor
        mov ecx, str
        mov dh, 0xE
        call print

        call newline
        

        call idt_init

        call get_cursor
        mov ecx, str
        mov dh, 0xA
        call print

        call newline
        jmp $

str:    db "Hello, World!", 0
        
%include "irq.s"
%include "screen.s"
