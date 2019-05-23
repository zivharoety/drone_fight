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
global    to_print
global    rand_target
extern    function


section .rodata
    f_string: db "%s", 10, 0	    ; format string
    f_int: db "%d",10 , 0	        ; format string
    f_float_target: db "%.2f",10 , 0	; format float

    err_arguments: db 'Error: Not enough arguments', 0
    STKSIZE equ 16*1024             ;16 Kb
    CODEP equ 0                     ; offset of pointer to co-routine function in co-routine struct
    SPP equ 4                       ; offset of pointer to co-routine stack in co-routine struct 
    alpha_off equ 0
    x_off equ 4
    y_off equ 8
    target_off equ 12
    max_short: dd 65535
    one_twenty: dd  120
    minus_sixty: dd 60
    hundred: dd 100
    fifty: dd 50
    temp: dd 4.0
    three_sisxty: dd 360
    


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
    to_print: dd 0.0
    new_drone_x: dd 0.0
    new_drone_y: dd 0.0
    new_drone_angle: dd 0.0
   

    ;scheduler:  dd schedule                    ;;;;;to recheck!
                dd STK_schduler+STKSIZE
    ;printer:    dd print
                dd STK_printer+STKSIZE
    ;target:     dd creat_target
                dd STK_target+STKSIZE


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
callc_debug:
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
    mov ecx , 0

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

mov eax ,0
mov ecx , stacks
mov ebx , 0
mov edx, 0
loop_random_loc_drone:
    cmp eax , [num_of_drones]
    je end_loop_rand_loc
    pushad
    call rand_loc_drone
    popad
    mov edx, ecx
    mov ebx , dword [new_drone_angle]
    mov dword [edx] , ebx
    add edx , 4
    mov ebx , dword [new_drone_x]
    mov dword [edx] , ebx
    add edx , 4
    mov ebx , dword [new_drone_y]
    mov dword [edx] , ebx
    add ecx , STKSIZE
    inc eax
    jmp loop_random_loc_drone
    
end_loop_rand_loc:
;mov eax , 0            
;loop_init:
;    cmp eax , [num_of_drones]
;    je end_loop_init
;    initCo eax
;    inc eax
;    jmp loop_init
;end_loop_init:
mov dword [curr_drone] , 0
pushad
call rand_target
popad
ziv_debug:
    pushad
    call function
    popad
    ;inc dword [curr_drone]
    jmp ziv_debug

call rand_in_range
guy_debug:
    mov edx , dword [rand_angle]
    mov dword [to_print] , edx
    pushad
    call print_top
    popad
    jmp end
   




print_top:
    pushad
    sub esp, 8
    mov ebx , to_print
    fld dword [ebx]
    fstp qword [esp]
    push f_float_target
    call printf
    add esp , 12
    popad
    ret 



rand_in_range:
    push ebp
    mov ebp, esp
    pushad
    call rand_float
    popad
    finit
    fild dword [seed]
  ;  mov ecx , dword [max_short]
    fild dword [max_short]
    fdivp
    fild dword [one_twenty]
    fmulp
    fild dword [minus_sixty]
    fsubp
    fstp dword [rand_angle]
    mov esp , ebp
    pop ebp
    ret

rand_distance:
    push ebp
    mov ebp, esp
    pushad
    call rand_float
    popad
    finit
    fld dword [seed]
    fild dword [max_short]
    fdivp
    fild dword [fifty]
    fmulp
    fstp dword [rand_distance_var]
    mov esp , ebp
    pop ebp
    ret
    

rand_float:
    push ebp
    mov ebp, esp
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
        mov esp , ebp
        pop ebp
        ret     ;to check again how to return from a function
    

rand_target:
    push ebp
    mov ebp, esp
    pushad
    call rand_float
    popad
    finit
    fild dword [seed]
    fild dword [max_short]
    fdivp
    fild dword [hundred]
    fmulp
    fstp dword [target_x]
    pushad
    call rand_float
    popad
    finit
    fild dword [seed]
    fild dword [max_short]
    fdivp
    fild dword [hundred]
    fmulp
    fstp dword [target_y]
    mov esp , ebp
    pop ebp
    ret

rand_loc_drone:
    push ebp
    mov ebp, esp
    mov dword [new_drone_x] , 0
    mov dword [new_drone_y] , 0
    mov dword [new_drone_angle], 0
    pushad
    call rand_float
    popad
    finit
    fild dword [seed]
    fild dword [max_short]
    fdivp
    fild dword [hundred]
    fmulp
    fstp dword [new_drone_x]
    pushad
    call rand_float
    popad
    finit
    fild dword [seed]
    fild dword [max_short]
    fdivp
    fild dword [hundred]
    fmulp
    fstp dword [new_drone_y]
    pushad
    call rand_float
    popad
    finit
    fild dword [seed]
    fild dword [max_short]
    fdivp
    fild dword [three_sisxty]
    fmulp
    fstp dword [new_drone_angle]
    mov esp , ebp
    pop ebp
    ret
error1:
    pushad
    push err_arguments
    push f_string
    call printf
    add esp , 8
    popad
end:
    mov eax , 1
    mov ebx , 0
    int 0x80
      
        
	

