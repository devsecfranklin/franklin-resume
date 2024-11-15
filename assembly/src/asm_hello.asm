;asm00.s

section .data
    msg       db     'Hello world!'
    nl        db     0x0a
    msgLen    equ    $-msg
section .text
global _start
_start:
    mov rax, 1
; asm_hello.asm:10: error: instruction not supported in 32-bit mode
; asm_hello.asm:11: error: instruction not supported in 32-bit mode
; asm_hello.asm:12: error: instruction not supported in 32-bit mode
; asm_hello.asm:13: error: instruction not supported in 32-bit mode
; asm_hello.asm:16: error: instruction not supported in 32-bit mode
; asm_hello.asm:17: error: instruction not supported in 32-bit mode
    mov rdi, 1
    mov rsi, msg
    mov rdx, msgLen
    syscall

    mov rax, 60
    mov rdi, 0
    syscall
