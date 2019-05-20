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
    global printer


section .rodata
    f_string: db "%s", 10, 0	; format string
    f_float_target: db "%g,%g",10 , 0	; format string to the target
    f_float_drone: db "%d,%f,%f,%f,%f",10 , 0	; format string to the target

section .data
    iter_drone : dd 0
    print_x : dd 0.0
    print_y : dd 0.0
    print_angle : dd 0.0
    print_kills : dd 0
    offset: dd 0

section .text

printer:
        push ebp              		; save Base Pointer (bp) original value
        mov ebp, esp         		; use Base Pointer to access stack contents (do_Str(...) activation frame)
        pushad                   	; push all signficant registers onto stack (backup registers values)
;       mov ecx, dword [ebp+8]		; get function argument on stack
;       pushad
        push [target_x]
        push [target_y]
        push f_float_target
        call printf
        add esp, 164 ;to check how much to add because of target_x&target_y
        popad
    loop_printer:
        mov edx , [iter_drone]
        cmp dword [num_of_drones], edx
        je finish_print
        mov eax , STKSIZE
        mul edx
        add eax , dword [stacks]
        fld dword [eax]
        fstp dword [print_x]
        add eax , 80
        fld dword [eax]
        fstp dword [print_y]
        add eax , 80
        fld dword [eax]
        fstp dword [print_angle]
        add eax , 4
        mov ebx , dword [eax]
        mov [print_kills], ebx
        pushad
        push dword [iter_drone]
        push dword [print_x]
        push dword [print_y]
        push dword [print_angle]
        push dword [print_kills]
        push f_float_drone
        call printf
        add esp , 252  ;check how much to add
        popad
        inc dword [iter_drone]
        jmp loop_printer

    finish_print:
        mov dword [iter_drone], 0
        popad                    	; restore all previously used registers
        mov esp, ebp			; free function activation frame
        pop ebp				; restore Base Pointer previous value (to returnt to the activation frame of main(...))
        ret				; returns from printer(...) function

