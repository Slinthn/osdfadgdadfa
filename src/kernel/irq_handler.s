keyboard_map_start:
        db 0, 27, "1234567890-=", 10
        db 11, "qwertyuiop[]", 15
        db 0, "asdfghjkl;'`"
        db 0, "\zxcvbnm,./", 0

keyboard_map_end:

irq1:                           ; keyboard
        pusha
        xor ebx, ebx
        call get_cursor
        push ebx
        
        mov dx, 0x60
        in al, dx

        mov ebx, keyboard_map_start
        add ebx, eax
        
        cmp ebx, keyboard_map_end
        mov cl, byte[ebx]
        pop ebx
        jg .done

        mov ch, 0xC
        call printc

.done:
        mov al, 0x20
        out 0x20, al
        popa
        iret

irq12:                          ; mouse
        pusha
        mov al, 0x20
        out 0xA0, al
        out 0x20, al
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
