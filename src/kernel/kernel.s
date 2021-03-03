[bits 64]
kmain:
  call clear

  mov bl, 0b1110
  call set_cursor_state

  mov ebx, 0
  call get_cursor_position
  mov ecx, HELLO_WORLD
  mov dh, 0xD
  call print
  jmp $


HELLO_WORLD:
  db "Hello, world!", 0

%include "screen.s"
