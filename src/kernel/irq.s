%include "irq_handler.s"


idt_descriptor:
        dw idt_end - idt_start - 1
        dd MEMORY(idt_start)

        
idt_start:
        times 32 dq 0
        times 16 dq 0x00008E0000080000
        times (256 - 48) dq 0
        
idt_end:


irq_list:
        dd MEMORY(irq0)
        dd MEMORY(irq1)
        dd MEMORY(irq2)
        dd MEMORY(irq3)
        dd MEMORY(irq4)
        dd MEMORY(irq5)
        dd MEMORY(irq6)
        dd MEMORY(irq7)
        dd MEMORY(irq8)
        dd MEMORY(irq9)
        dd MEMORY(irq10)
        dd MEMORY(irq11)
        dd MEMORY(irq12)
        dd MEMORY(irq13)
        dd MEMORY(irq14)
        dd MEMORY(irq15)
        
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

        mov ebx, 0
        mov ecx, 0
        mov edx, 0
.fillmemory:
        mov ebx, ecx
        shl ebx, 2
        mov eax, [ebx + MEMORY(irq_list)]

        shl ebx, 1
        mov word[ebx + MEMORY(idt_start) + 32*8 + 0], ax
        shr eax, 16
        mov word[ebx + MEMORY(idt_start) + 32*8 + 6], ax

        inc ecx
        cmp ecx, 16
        jne .fillmemory         ; end .fillmemory loop
        
        lidt [MEMORY(idt_descriptor)]
        sti
        
        mov al, 0xD4
        out 0x64, al
        mov al, 0xF4
        out 0x60, al
        
.loop0:
        in al, 0x60
        cmp al, 0xFA
        jne .loop0              ; end .loop0 loop

.loop1:        
        in al, 0x60
        cmp al, 0xFA
        jne .loop1                 ; end loop1 loop

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
