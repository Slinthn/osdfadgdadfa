SCREEN_CTRL equ 0x3D4           ; SCREEN_DATA equ 0x3D5 (inc + dec instructions to dl register)
VGA_WIDTH equ 80
VGA_HEIGHT equ 25
MAX_CHARS equ VGA_WIDTH*VGA_HEIGHT
VGA_TEXT equ 0xB8000            ; pointer to start of text output
        
        ;; modifies : al, dx
        ;; return bx : cursor offset
get_cursor:        
        mov dx, 0x3D4
        mov al, 0xE             ; request higher byte
        out dx, al

        inc dx
        in al, dx
        mov bh, al              ; move byte from al to higher byte of bh

        dec dx
        mov al, 0xF             ; request lower byte
        out dx, al
        
        inc dx
        in al, dx
        mov bl, al              ; move byte from al to lower byte of bh
        ret

        ;; modifies : al, dx
        ;; param bx : cursor offset
set_cursor:        
        mov dx, 0x3D4
        mov al, 0xE             ; output higher byte
        out dx, al

        inc dl
        mov al, bh
        out dx, al

        dec dl
        mov al, 0xF             ; output lower byte
        out dx, al

        inc dl
        mov al, bl
        out dx, al              ; screen data port
        ret

        ;; modifies : al, ebx, cx, dx
clear:
        mov ebx, VGA_TEXT
        mov cx, MAX_CHARS
.loop:
        cmp cx, 0
        je .done

        mov word[ebx], 0x0F00
        add ebx, 2

        dec cx
        jmp .loop
        
.done:
        xor bx, bx
        call set_cursor
        ret

        ;; modifies : al, ebx, dx
        ;; param bx : cursor offset
        ;; param cl : character
        ;; param ch : attribute
printc:
        shl bx, 1               ; each char is 2 bytes, 0: char, 1: attrib
        mov word[ebx + VGA_TEXT], cx

        shr bx, 1
        inc bx
        call set_cursor
        ret

        ;; modifies : al, ebx, ecx, dx
        ;; param bx : cursor offset
        ;; param ecx : pointer to null-terminated string
        ;; param dh : attrib
print:
        shl bx, 1
.loop:
        mov dl, byte[ecx]
        cmp dl, 0
        je .done

        mov word[VGA_TEXT + ebx], dx
        inc ecx
        add ebx, 2
        jmp .loop
.done:
        shr bx, 1
        call set_cursor
        ret

        ;; modifies : ax, bx, cx, dx
newline:
        call get_cursor
        push bx

        xor dx, dx
        mov cx, VGA_WIDTH
        div cx

        sub dx, 80
        neg dx
        mov bx, dx
        pop ax
        add bx, ax
        call set_cursor
        ret
