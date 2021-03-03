STACK equ 0x7C00
KERNEL equ 0x7E00

PAGE_TABLE equ 0x1000
PAGE_PRESENT equ 0x1
PAGE_WRITE equ 0x2
        
[org 0x7C00]
[bits 16]
main:
  mov bp, STACK
  mov sp, bp
  
  mov  al, 0x33
  mov  ah, 0x2
  mov  bx, KERNEL
  mov  ch, 0x0
  mov  cl, 0x2
  mov  dh, 0x0
  int 0x13
  
  in al, 0x92 ; enable A20 port
  or al, 2
  out 0x92, al
  
  cli
  
  mov edi, PAGE_TABLE
  mov cr3, edi
  xor eax, eax
  mov ecx, 0x1000
  rep stosd
  
  mov edi, PAGE_TABLE
  mov dword [edi], PAGE_TABLE + 0x1000|PAGE_PRESENT|PAGE_WRITE
  mov dword [edi + 0x1000], PAGE_TABLE + 0x2000|PAGE_PRESENT|PAGE_WRITE
  mov dword [edi + 0x2000], PAGE_TABLE + 0x3000|PAGE_PRESENT|PAGE_WRITE
  add edi, 0x3000
  
  mov ebx, 3
  mov ecx, 512
.setentry:
  mov dword [edi], ebx
  add ebx, 0x1000
  add edi, 8
  dec ecx
  jnz .setentry

  mov eax, cr4
  or eax, 1 << 5
  mov cr4, eax

  mov ecx, 0xC0000080
  rdmsr
  or eax, 1 << 8
  wrmsr

  mov eax, cr0
  or eax, 1|(1 << 31)
  mov cr0, eax

  lgdt [gdt.pointer]
  jmp CODE_SEG:main_lm

[bits 64]
main_lm:
  jmp KERNEL
  jmp $

        
CODE_SEG equ gdt.code - gdt.start
DATA_SEG equ gdt.data - gdt.start

gdt:
.start:
.null:
  dd 0
  dd 0

.code:
  dw 0
  dw 0
  db 0
  db 10011000b
  db 00100000b
  db 0

.data:
  dw 0
  dw 0
  db 0
  db 10000000b
  db 0
  db 0

.end:
.pointer:
  dw gdt.end - gdt.start - 1
  dd gdt.start

        
times 510-($-$$) db 0
dw 0xAA55
