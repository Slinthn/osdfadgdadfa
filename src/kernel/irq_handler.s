keyboard_map_start:
        db 0, 27, "1234567890-=", 10
        db 11, "qwertyuiop[]", 15
        db 0, "asdfghjkl;'`"
        db 0, "\zxcvbnm,./", 0

keyboard_map_end:

irq_keyboard:
        xor ebx, ebx
        call get_cursor
        push ebx
        
        mov dx, 0x60
        in al, dx

        mov ebx, MEMORY(keyboard_map_start)
        add ebx, eax
        
        cmp ebx, MEMORY(keyboard_map_end)
        mov cl, byte[ebx]
        pop ebx
        jg .done

        mov ch, 0xC
        call printc

.done:
        mov al, 0x20
        out 0x20, al
        ret

        irq_mouse:
        mov al, 0x20
        out 0xA0, al
        out 0x20, al
        ret
