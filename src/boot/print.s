; bx = pointer to beginning of null-terminated string in memory
[bits 16]
b16_print_string:
  pusha
  mov ah, 0xE

b16_print_string.loop:
  mov al, [bx]
  cmp al, 0x0
  je b16_print_string.done
  
  int 0x10
  inc bx
  jmp b16_print_string.loop

b16_print_string.done:
  popa
  ret

[bits 16]
B16_HEX_PRINT:
  db "0x0000", 0

; dx = number to output as a hexadecimal string
b16_print_hex:
  pusha
  mov cx, 4

b16_print_hex.loop:
  cmp cx, 0
  je b16_print_hex.done

  mov ax, dx
  and ax, 0xF

  cmp ax, 0x9
  jle b16_print_hex.print
  add ax, 0x7

b16_print_hex.print:
  add ax, 0x30
  
  mov bx, B16_HEX_PRINT
  add bx, 1
  add bx, cx
  mov [bx], al

  dec cx
  shr dx, 0x4
  jmp b16_print_hex.loop

b16_print_hex.done:
  mov bx, B16_HEX_PRINT
  call b16_print_string
  popa
  ret
