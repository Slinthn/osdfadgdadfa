CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

gdt_start:
gdt_null:
        dd 0x0
        dd 0x0

gdt_code:
        dw 0xFFFF
        dw 0x0
        db 0x0
        db 10011010b
        db 11001111b
        db 0x0

gdt_data:
        dw 0xFFFF
        dw 0x0
        db 0x0
        db 10010010b
        db 11001111b
        db 0x0

gdt_end:
gdt_descriptor:
        dw gdt_end - gdt_start - 1
        dd gdt_start

[bits 16]
b16_switch_to_pm:
        cli
        lgdt [gdt_descriptor]
        mov eax, cr0
        or eax, 0x1
        mov cr0, eax

        jmp CODE_SEG:init_pm

[bits 32]
init_pm:
        mov ax, DATA_SEG
        mov ds, ax
        mov ss, ax
        mov es, ax
        mov fs, ax
        mov gs, ax

        mov ebp, STACK
        mov esp, ebp

        jmp main_pm
