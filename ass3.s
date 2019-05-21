global    num_of_drones
global    targets_to_win
global    drone_steps_till_print
global    beta
global    max_distance
global    seed
global    stacks
global    CORS
global    curr_drone
global    STKSIZE
global    target_x
global    target_y
global    game_over
global    rand_in_range
global    rand_angle
global    rand_distance
global    rand_distance_var
global    rand_target
extern    resume



section .rodata
    f_string: db "%s", 10, 0	    ; format string
    f_int: db "%d",10 , 0	        ; format string
    f_float_target: db "%f",10 , 0	; format float

    err_arguments: db 'Error: Not enough arguments', 0
    STKSIZE equ 16*1024             ;16 Kb
    CODEP equ 0                     ; offset of pointer to co-routine function in co-routine struct
    SPP equ 4                       ; offset of pointer to co-routine stack in co-routine struct 
    alpha_off equ 0
    x_off equ 4
    y_off equ 8
    target_off equ 12
    


section .bss			; we define (global) uninitialized variables in .bss section
    SPT: resd 1         ;temporary stack pointer
    SPMAIN: resd 1      ; stack pointer of main
    STK_schduler: resb STKSIZE
    STK_printer: resb STKSIZE
    STK_target: resb STKSIZE

section .data
    num_of_drones: dd 0
    targets_to_win: dd 0
    drone_steps_till_print: dd 0
    beta: dd 0
    max_distance: dd 0
    seed: dd 0
    stacks: dd 0
    CORS: dd 0
    curr_drone: dd 0
    target_x: dd 0.0
    target_y: dd 0.0
    game_over: dd 0
    rand_angle: dd 0.0
    rand_distance_var: dd 0.0
    max_short: dd 65535
    one_twenty: dd  120
    hundred: dd 100
    minus_sixty: dd 60
    temp: dd 4
    fifty: dd 50
    x: dd 10.00
    y: dd 20.00



section .text
  align 16
     global main 
     extern printf
     extern fprintf
     extern sscanf
     extern calloc 
     extern free 

%macro initCo 1
    mov ebx , %1                ; get co-routine ID number
    mov ebx, [8*ebx + CORS]     ; get pointer to COi struct
    mov eax, [ebx+CODEP]        ; get initial EIP value – pointer to CO%1 function
    mov [SPT], esp              ; save esp value
    mov esp , [ebx+SPP]         ; get initial ESP value – pointer to CO%1 stack
    push eax                    ; push initial “return” address
    pushfd                      ; push flags
    pushad                      ; push all other registers
    mov [ebx+SPP], esp          ; save new SPi value (after all the pushes)
    mov ESP, [SPT]              ; restore ESP value 
%endmacro


;------------------------START OF MAIN----------------------------------------------;
main:
    push ebp                            ; updating the command line arguments to the vars.
    mov ebp , esp
    mov eax , dword [esp+8]             ; points to nomOfArguments
    cmp eax , 7 
    jl error1
    mov eax , dword [esp+12]            ; points to the 1st argument
    add eax, 4
    mov ebx , dword [eax]
    pushad
    push num_of_drones
    push f_int
    push ebx
    call sscanf
    add esp, 12
    popad
    add eax , 4
    mov ebx , dword [eax]             ; points to the 2nd argument  
    pushad
    push targets_to_win
    push f_int
    push ebx
    call sscanf
    add esp, 12
    popad
    add eax , 4                        ; points to the 3rd argument
    mov ebx , dword [eax]
    pushad
    push drone_steps_till_print
    push f_int
    push ebx
    call sscanf
    add esp, 12
    popad
    add eax , 4                         ; points to the 4th argument
    mov ebx , dword [eax]
    pushad
    push beta
    push f_int
    push ebx
    call sscanf
    add esp, 12
    popad
    add eax , 4                         ; points to the 5th argument
    mov ebx , dword [eax]
    pushad
    push max_distance
    push f_int
    push ebx
    call sscanf
    add esp, 12
    popad
    add eax , 4                         ; points to the 6th argument
    mov ebx , dword [eax]
    pushad
    push seed
    push f_int
    push ebx
    call sscanf
    add esp, 12
    popad


    mov eax , [num_of_drones]       ;allocating an array for the satcks of the drones 
    mov ebx, STKSIZE
    mul ebx
    pushad
    push eax
    call calloc
    add esp, 4
    mov [stacks], eax        
    popad

    mov eax , [num_of_drones]       ;allocating an array for the struct of the drones
    mov ebx , 8
    mul ebx
    pushad
    push eax
    call calloc
    add esp, 4
    mov [CORS], eax        
    popad

    mov eax , 0
    mov ebx , 4
    mov ecx , STKSIZE

loop_set_drones_stacks:
    cmp eax, [num_of_drones]
    je end_loop_set
    mov edx ,dword [stacks+ecx] 
    mov dword [CORS+ebx] , edx
    add ebx , 8
    add ecx , STKSIZE
    inc eax
    jmp loop_set_drones_stacks
end_loop_set:

;mov eax , 0            
;loop_init:
;    cmp eax , [num_of_drones]
;    je end_loop_init
;    initCo eax
;    inc eax
;    jmp loop_init
;end_loop_init:


    ;call resume


rand_in_range:
    call rand_float
    finit
    fld dword [seed]
    fld dword [max_short]
    fdivp
    fld dword [one_twenty]
    fmulp
    fld dword [minus_sixty]
    fsubp
    fstp dword [rand_angle]
    ret

rand_distance:
    call rand_float
    finit
    fld dword [seed]
    fld dword [max_short]
    fdivp
    fld dword [fifty]
    fmulp
    fstp dword [rand_distance_var]
    ret

rand_target:
    call rand_float
    finit
    fild dword [seed]
    fild dword [max_short]
    fdivp
    fild dword [hundred]
    fmulp
    fstp dword [target_x]
    call rand_float
    finit
    fild dword [seed]
    fild dword [max_short]
    fdivp
    fild dword [hundred]
    fmulp
    fstp dword [target_y]
    ret
    


    

rand_float:
    mov eax , 0
    mov ecx , 0
    mov eax , [seed]
    .16_bit:
        shr eax , 1
        jc rand_float.xor_16
        shr eax , 1
        jmp rand_float.14_bit
    .xor_16:
        xor cl, 1
        shr eax , 1
        jmp rand_float.14_bit
    .14_bit:
        shr eax,1
        jc rand_float.xor_14
        jmp rand_float.13_bit
    .xor_14:
        xor cl , 1
    .13_bit:
        shr eax ,1
        jc rand_float.xor_13
        shr eax , 1
        jmp rand_float.11_bit
    .xor_13:
        xor cl ,1
        shr eax , 1
        jmp rand_float.11_bit
    .11_bit:
        shr eax , 1
        jc rand_float.xor_11
        jmp rand_float.finish_rand
    .xor_11:
        xor cl, 1
        jmp rand_float.finish_rand
    .finish_rand:
        mov eax ,dword [seed]
        shr eax , 1
        cmp cl , 0
        je rand_float.modify_seed
        add eax , 32768
    .modify_seed:
        mov dword [seed], eax
        ret     ;to check again how to return from a function
    


    


error1:
    pushad
    push err_arguments
    push f_string
    call printf
    add esp , 8
    popad
    mov eax , 0
    mov ebx , 1
    int 0x80
      
        
	

