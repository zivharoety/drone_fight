section .text
    extern    num_of_drones
    extern    targets_to_win
    extern    drone_steps_till_print
    extern    beta
    extern    max_distance
    extern    seed
    extern    stacks
    extern    CORS
    extern    curr_drone
    extern    printf
    extern    target_x
    extern    target_y
    extern    STKSIZE
    global    printer


section .rodata
    f_string: db "%s", 10, 0	; format string
    f_float_target: db "%.2f,%.2f",10 , 0	; format string to the target
    f_float_drone: db "%d,%.2f,%.2f,%.2f,%d",10 , 0	; format string to the target

section .data
    iter_drone : dd 0
    print_kills : dd 0
    offset: dd 0

section .text

printer:
        push ebp              		; save Base Pointer (bp) original value
        mov ebp, esp         		; use Base Pointer to access stack contents (do_Str(...) activation frame)
       pushad                   	; push all signficant registers onto stack (backup registers values)
;       mov ecx, dword [ebp+8]		; get function argument on stack
       pushad
        sub esp , 8
        mov ebx , target_x
        fld dword [ebx]
        fstp qword [esp]
        sub esp , 8
        mov ebx , target_y
        fld dword [ebx]
        fstp qword [esp]
        push f_float_target
        call printf
        add esp, 20 ;to check how much to add because of target_x&target_y
        popad
        mov dword [iter_drone] , 0
    loop_printer:
        mov edx , dword [iter_drone]
        cmp dword [num_of_drones], edx
      ; cmp dword[iter_drone], 1
        je finish_print

        ; /////// new print
        mov eax, dword [STKSIZE]
        mov edx ,dword [iter_drone]
        mul edx
        add eax, dword [stacks]
        add eax , 12
        mov ebx , dword [eax]
        mov dword [print_kills], ebx
        push dword [print_kills]
        finit
        sub eax ,12 ; to alpha
        fld dword [eax]
        sub esp , 8
        fstp qword [esp]
        add eax , 8 ; to y
        fld dword [eax]
        sub esp , 8
        fstp qword [esp]
        sub eax , 4
        fld dword [eax]
        sub esp , 8
        fstp qword [esp]
        push dword [iter_drone]
        push f_float_drone
        call printf
        add esp , 36  ;check how much to add
     ;   popad
        inc dword [iter_drone]
        jmp loop_printer

    finish_print:
        mov dword [iter_drone], 0
        popad                    	; restore all previously used registers
        mov esp, ebp			; free function activation frame
        pop ebp				; restore Base Pointer previous value (to returnt to the activation frame of main(...))
        ret				; returns from printer(...) function

