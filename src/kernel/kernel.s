%define MEMORY(x) (x - 0x401000 + 0x7E00)

TMP:    dd 0
;;; everything is fucked. newline does not work when setting eax register beforehand? irq is fucked? just... ugh
;;; fixed ax regiser shit, still don't undersand y tho
;;; nvm everything is ok now
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
        mov ecx, MEMORY(STR)
        mov dh, 0xE
        call print

        call newline
        

        call idt_init

        call get_cursor
        mov ecx, MEMORY(STR)
        mov dh, 0xA
        call print

        call newline
        jmp $

STR:    db "Hello, World!", 0
        
%include "irq.s"
%include "screen.s"
