DISK_LOAD_ERROR:
  db "Error loading from disk", 0

SECTOR_LOAD_ERROR:
  db "Incorrect number of sectors loaded from disk (loaded-requested)", 0

; al = number of sectors to read
[bits 16]
b16_disk_load:
  pusha
  push ax
  
  mov ah, 0x2
  mov ch, 0x0
  mov cl, 0x2
  mov dh, 0x0
  int 0x13

  jc b16_disk_load.error0
  pop dx
  cmp dl, al
  jne b16_disk_load.error1

  popa
  ret

b16_disk_load.error0:
  mov bx, DISK_LOAD_ERROR
  call b16_print_string

  mov dx, 0x0
  mov dl, ah
  call b16_print_hex
  jmp $

b16_disk_load.error1:
  mov bx, SECTOR_LOAD_ERROR
  call b16_print_string
  
  mov dh, 0x0
  call b16_print_hex

  mov dl, al
  call b16_print_hex
  jmp $
