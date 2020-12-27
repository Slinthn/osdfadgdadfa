%include "irq_handler.s"
        
idt_init:
        push ebp
        mov ebp, esp
        
        mov al, 0x11            ; remapping the PCI
        out 0x20, al
        out 0xA0, al

        mov al, 0x20
        out 0x21, al

        mov al, 0x28
        out 0xA1, al
        
        mov al, 4
        out 0x21, al

        mov al, 2
        out 0xA1, al

        mov al, 1
        out 0x21, al
        out 0xA1, al

        xor al, al
        out 0x21, al
        out 0xA1, al            ; finished remapping

        push irq15              ; push irq callbacks to stack for convenience later
        push irq14
        push irq13
        push irq12
        push irq11
        push irq10
        push irq9
        push irq8
        push irq7
        push irq6
        push irq5
        push irq4
        push irq3
        push irq2
        push irq1
        push irq0

        mov ecx, 0
.memloop0:
        push dword 0
        push dword 0

        inc ecx
        cmp ecx, (256-16-32)
        jne .memloop0           ; end .memloop0

        
        mov ecx, 0
.memloop1:
        mov edx, ebp
        mov ebx, ecx
        shl ebx, 2
        add ebx, 4
        sub edx, ebx
        mov eax, [edx]          ; getting irq callbacks from stack

        mov ebx, eax            ; tmp ebx to get higher bits of eax
        shr ebx, 16

        push bx                 ; this part/struct is flipped around, since as the stack grows, esp decreases
        push word 0x8E00
        push word 0x8
        push ax

        inc ecx
        cmp ecx, 16
        jne .memloop1           ; end .memloop1


        mov ecx, 0
.memloop2:
        push dword 0
        push dword 0

        inc ecx
        cmp ecx, 32
        jne .memloop2

        push dword esp          ; push idt descriptor (once again, flipped)
        push word 256*8

        lidt [esp]
        sti
        
        mov al, 0xD4
        out 0x64, al
        mov al, 0xF4
        out 0x60, al
        
.loop0:
        in al, 0x60
        cmp al, 0xFA
        jne .loop0              ; end .loop0

.loop1:        
        in al, 0x60
        cmp al, 0xFA
        jne .loop1              ; end loop1

        mov al, 0x20
        out 0x64, al

        in al, 0x60
        or al, 0x2
        
        push ax
        mov al, 0x60
        out 0x64, al

        pop ax
        out 0x60, al

        mov esp, ebp
        pop ebp


        mov bx, 0
        mov cl, 'C'
        mov ch, 0xD
        call printc
        ret
