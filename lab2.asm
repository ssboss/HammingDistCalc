section .data
    ; Prompts and messages
    prompt1 db "Enter first string: ", 0
    prompt1_len equ $ - prompt1
    prompt2 db "Enter second string: ", 0
    prompt2_len equ $ - prompt2
    result_msg db "Hamming distance: ", 0
    result_msg_len equ $ - result_msg
    newline db 10, 0
    
section .bss
    ; Buffers for input strings
    string1 resb 256
    string2 resb 256
    
    ; Output buffer for result
    output_buffer resb 12

section .text
    global _start

_start:
    ; Display first prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt1
    mov edx, prompt1_len
    int 0x80
    
    ; Read first string
    mov eax, 3
    mov ebx, 0
    mov ecx, string1
    mov edx, 255
    int 0x80
    
    ; Display second prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt2
    mov edx, prompt2_len
    int 0x80
    
    ; Read second string
    mov eax, 3
    mov ebx, 0
    mov ecx, string2
    mov edx, 255
    int 0x80
    
    ; Calculate Hamming distance
    call calculate_hamming
    ; Result is in eax
    
    ; Display result message
    mov ebx, eax                ; Save hamming distance
    mov eax, 4
    mov ecx, result_msg
    mov edx, result_msg_len
    push ebx
    mov ebx, 1
    int 0x80
    pop ebx
    
    ; Convert result to string and display
    mov eax, ebx                ; Restore hamming distance
    call display_result
    
    ; Display newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    ; Exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80

; Procedure to calculate Hamming distance
calculate_hamming:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ; Initialize
    xor ecx, ecx                ; ecx = hamming distance counter
    xor esi, esi                ; esi = index for strings
    
compare_loop:
    ; Load characters from both strings
    movzx eax, byte [string1 + esi]
    movzx edx, byte [string2 + esi]
    
    ; Check if first string ended (null or newline)
    cmp al, 0
    je done_comparing
    cmp al, 10
    je done_comparing
    
    ; Check if second string ended (null or newline)
    cmp dl, 0
    je done_comparing
    cmp dl, 10
    je done_comparing
    
    ; Compare bit by bit using XOR
    push ecx
    
    xor eax, edx
    
    mov ecx, 8
    
bit_loop:
    test eax, 1
    jz bit_is_zero
    
    ; Bit is 1, increment hamming distance
    pop ebx                     ; Get hamming counter
    inc ebx
    push ebx                    ; Save it back
    
bit_is_zero:
    shr eax, 1                  ; Shift to next bit
    loop bit_loop
    
    pop ecx                     ; Restore hamming counter
    
    ; Move to next character
    inc esi
    jmp compare_loop
    
done_comparing:
    ; Store result in eax
    mov eax, ecx
    
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

; Procedure to convert number in eax to string and display it
display_result:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ; Clear output buffer
    mov edi, output_buffer
    mov ecx, 12
    xor al, al
clear_loop:
    mov byte [edi], al
    inc edi
    loop clear_loop
    
    mov eax, [esp + 20]
    
    ; Convert number to string
    mov edi, output_buffer
    add edi, 10
    mov ebx, 10
    xor ecx, ecx
    
    ; Handle special case of 0
    cmp eax, 0
    jne convert_loop
    mov byte [edi], '0'
    inc ecx
    jmp done_convert
    
convert_loop:
    cmp eax, 0
    je done_convert
    
    xor edx, edx
    div ebx
    add dl, '0'
    mov byte [edi], dl
    dec edi
    inc ecx
    jmp convert_loop
    
done_convert:
    inc edi                     ;
    
    ; Display the number
    push eax
    push ebx
    mov eax, 4
    mov ebx, 1
    mov ecx, edi

    mov edx, [esp + 32]
    push edx
    and edx, 0xFF
    pop edx
    mov edx, ecx
    sub edx, edi
    neg edx
    

    push ecx
    mov ecx, edi
    pop edx
    int 0x80
    pop ebx
    pop eax
    
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
