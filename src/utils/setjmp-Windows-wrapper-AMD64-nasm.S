; Netwide Assembler (NASM) implementation of the __setjmp_wrapper and __longjmp_wrapper
; https://www.nasm.us/

bits 64

segment .text
global __setjmp_wrapper
global __longjmp_wrapper

__setjmp_wrapper:
    mov    rdx,QWORD [rsp] ; rta
    mov    rax,QWORD gs:[0] ; SEH
    mov    QWORD [rcx+0],rax
    mov    QWORD [rcx+8],rbx
    mov    QWORD [rcx+16],rsp
    mov    QWORD [rcx+24],rbp
    mov    QWORD [rcx+32],rsi
    mov    QWORD [rcx+40],rdi
    mov    QWORD [rcx+48],r12
    mov    QWORD [rcx+56],r13
    mov    QWORD [rcx+64],r14
    mov    QWORD [rcx+72],r15
    mov    QWORD [rcx+80],rdx ; rip
    mov    QWORD [rcx+88],0
    movaps [rcx+96],xmm6
    movaps [rcx+112],xmm7
    movaps [rcx+128],xmm8
    movaps [rcx+144],xmm9
    movaps [rcx+160],xmm10
    movaps [rcx+176],xmm11
    movaps [rcx+192],xmm12
    movaps [rcx+208],xmm13
    movaps [rcx+224],xmm14
    movaps [rcx+240],xmm15
    xor    rax,rax ; return 0
    ret

__longjmp_wrapper:
    mov    rax,QWORD [rcx+0]
    mov    rbx,QWORD [rcx+8]
    mov    rsp,QWORD [rcx+16]
    mov    rbp,QWORD [rcx+24]
    mov    rsi,QWORD [rcx+32]
    mov    rdi,QWORD [rcx+40]
    mov    r12,QWORD [rcx+48]
    mov    r13,QWORD [rcx+56]
    mov    r14,QWORD [rcx+64]
    mov    r15,QWORD [rcx+72]
    mov    r8, QWORD [rcx+80]
    movaps xmm6,[rcx+96]
    movaps xmm7,[rcx+112]
    movaps xmm8,[rcx+128]
    movaps xmm9,[rcx+144]
    movaps xmm10,[rcx+160]
    movaps xmm11,[rcx+176]
    movaps xmm12,[rcx+192]
    movaps xmm13,[rcx+208]
    movaps xmm14,[rcx+224]
    movaps xmm15,[rcx+240]
    mov    QWORD gs:[0],rax
    mov    eax,edx ; move arg2 to return
    test   eax,eax
    jne    a
    inc    eax
a:  mov    QWORD [rsp],r8
    ret