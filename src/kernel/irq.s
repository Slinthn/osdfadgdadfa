%include "irq_handler.s"

irq_list:
        dd irq0
        dd irq1
        dd irq2
        dd irq3
        dd irq4
        dd irq5
        dd irq6
        dd irq7
        dd irq8
        dd irq9
        dd irq10
        dd irq11
        dd irq12
        dd irq13
        dd irq14
        dd irq15
        
idt_init:
        mov al, 0x11
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
        out 0xA1, al

        mov eax, esp
        sub eax, 256*8 + 6
        
        push dword eax          ; push idt descriptor
        push word 256*8
        
        sub esp, 256*8

        mov byte[esp - 1], 0xFF
        
        mov ecx, 0
.memloop0:                      ; fill first 32 entries with 0
        mov [esp], dword 0
        add esp, 4
        mov [esp], dword 0
        add esp, 4

        inc ecx
        cmp ecx, 32
        jne .memloop0           ; end .memloop0

        
        mov ecx, 0
.memloop1:                      ; fill 16 entries with pointers to irq functions
        mov ebx, ecx
        shl ebx, 2
        mov eax, [ebx + irq_list]

        mov [esp], ax
        add esp, 2

        mov [esp], word 0x8
        add esp, 2
        
        mov [esp], byte 0
        add esp, 1

        mov [esp], byte 0x8E
        add esp, 1

        shr eax, 16
        mov [esp], ax
        add esp, 2
        
        inc ecx
        cmp ecx, 16
        jne .memloop1           ; end .memloop1
        
        mov ecx, 0
.memloop2:                      ; fill the rest of the 256 entries with 0
        mov [esp], dword 0
        add esp, 4
        mov [esp], dword 0
        add esp, 4

        inc ecx
        cmp ecx, (256-32-16)
        jne .memloop2           ; end .memloop2

        lidt [esp]
        sti

        add esp, 6              ; pop idt descriptor
        
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
        
        ret

irq1:
        pusha
        call irq_keyboard
        popa
        iret


irq12:
        pusha
        call irq_mouse
        popa
        iret

irq0:   
irq2:
irq3:
irq4:
irq5:
irq6:
irq7:
        pusha
        mov al, 0x20
        out 0x20, al
        popa
        iret

irq8:
irq9:
irq10:
irq11:
irq13:
irq14:
irq15:
        pusha
        mov al, 0x20
        out 0xA0, al
        mov al, 0x20
        out 0x20, al
        popa
        iret
