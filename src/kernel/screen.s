VGA_SCREEN_CTRL equ 0x3D4
VGA_SCREEN_DATA equ 0x3D5
        
VGA_WIDTH equ 80 ; width of the screen
VGA_HEIGHT equ 25 ; height of the screen
MAX_CHARS equ VGA_WIDTH*VGA_HEIGHT ; maximum characters which can appear on the screen
VGA_TEXT equ 0xB8000 ; pointer to start of text output

        
; modifies : ax, dx
; return bx : cursor offset
get_cursor_position:
  mov dx, VGA_SCREEN_CTRL ; dx == 0x3D4
  mov ax, 0xE ; higher byte command
  out dx, al ; request higher byte of offset
 
  inc dx ; dx == VGA_SCREEN_DATA (0x3D5)
  in al, dx ; get higher byte of cursor offset
  mov bh, al ; move byte from al to higher byte of bx
 
  dec dx ; dx == VGA_SCREEN_CTRL (0x3D4)
  mov al, 0xF ; lower byte command
  out dx, al ; request lower byte of offset
 
  inc dx ; dx == VGA_SCREEN_DATA (0x3D5)
  in al, dx ; get lower byte of cursor offset
  mov bl, al ; move byte from al to lower byte of bx
  ret

        
; modifies : ax, dx
; param bx : cursor offset
set_cursor_position:
  mov dx, VGA_SCREEN_CTRL ; dx == 0x3D4
  mov ax, 0xE ; higher byte cursor offset command
  out dx, al ; request to output higher byte of offset

  inc dx ; dx == VGA_SCREEN_DATA (0x3D5)
  mov al, bh ; move higher byte of input parameter to al
  out dx, al ; output offset higher byte from input parameter

  dec dx ; dx == VGA_SCREEN_CTRL (0x3D4)
  mov al, 0xF ; lower byte cursor offset command
  out dx, al ; request to output lower byte of offset

  inc dx ; dx == VGA_SCREEN_DATA (0x3D5)
  mov al, bl ; move lower byte of input parameter to al
  out dx, al ; output offset lower byte from input parameter
  ret

        
; modifies : dx, al
; param bl : bits 0-4 : cursor height
;          : bit 5 : cursor visibility (0 = enabled, 1 = disabled)
;          : bits 6-7 : unused
set_cursor_state:
  mov dx, VGA_SCREEN_CTRL ; dx == 0x3D4
  mov al, 0xA ; cursor status command
  out dx, al ; request to change cursor status

  inc dx ; dx == VGA_SCREEN_DATA (0x3D5)
  mov al, bl ; move input parameter into al for output
  out dx, al ; output change in cursor state
  ret

        
; modifies : ax, ebx, cx, dx
clear:
  mov ebx, VGA_TEXT ; ebx will be a pointer to where we are currently writing to
  mov cx, MAX_CHARS ; cx will be a counter for how many times we have to write
.loop:
  mov word[ebx], 0x0F00 ; clear word at memory so no character displays but is still white
  add ebx, 2 ; move to next word

  dec cx ; decrease counter
  jnz .loop ; if the counter is not 0, loop again

  xor bx, bx ; bx == 0
  call set_cursor_position ; set cursor offset to 0 (bx)
  ret

        
; modifies : ax, ebx, dx
; param ebx : cursor offset in characters
; param cl : character
; param ch : attribute
printc:
  shl ebx, 1 ; every screen character is 2 bytes, so lets double this
             ; to get the offset in memory to write at
  mov word[ebx + VGA_TEXT], cx ; output character

  shr ebx, 1 ; shift back to normal character offsets to output the cursor offset
  inc ebx ; go to next character
  call set_cursor_position ; update cursor offset
  ret

  
; modifies : ax, bx, ecx, dx
; param ebx : cursor offset in characters
; param ecx : pointer to null-terminated string
; param dh : attrib
print:
  shl ebx, 1 ; every screen character is 2 bytes, so lets double this
             ; to get the offset in memory to write at
.loop:
  mov dl, byte[ecx] ; read the character at the memory location
  cmp dl, 0 ; if the character is a null-terminator,
  je .done ; stop printing

  mov word[ebx + VGA_TEXT], dx ; output the character with the attrib (dx) to the memory offset
  inc ecx ; go to next character from input parameter
  add ebx, 2 ; go to next screen character (each character is 2 bytes)
  jmp .loop ; loop back
.done:
  shr ebx, 1 ; shift back to normal character offsets to output the cursor offset
  call set_cursor_position ; update cursor offset
  ret

        
; modifies : ax, bx, cx, dx
newline:
  call get_cursor_position ; find where the cursor is currently

  xor dx, dx ; dx == 0
  mov cx, VGA_WIDTH ; put the width into cx
  div cx ; ax / cx

  sub dx, VGA_WIDTH ; dx is the remainder, so subtract the width to see
                    ; how many characters we need to move forward by
  sub bx, dx ; dx will always be negative, so instead of add, subtract.
             ; we're just adding the offset to move it by to bx, which was
             ; set by the get_cursor_position to where the cursor currently is
  call set_cursor_position
  ret
