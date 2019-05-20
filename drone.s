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
    extern    STKSIZE
    extern    rand_in_range
    extern    rand_angle
    extern    rand_distance
    extern    rand_distance_var
    global    resume

section .data
    curr_x: dd 0.0
    curr_y: dd 0.0
    curr_angle: dd 0.0
    targets_dest: dd 0
    curr_distance: dd 0
    sin_angle: dd 0
    cos_angle: dd 0
    tan_angle: dd 0


section .text
    resume:
        mov eax , [curr_drone]
        mov ebx,  STKSIZE
        imul ebx
        mov ebx , [stacks]
        add ebx , eax
        mov eax, dword [ebx]
        mov dword [curr_angle], eax
        add ebx, 4
        mov eax , dword [ebx]
        mov dword [curr_x], eax
        add ebx, 4
        mov eax , dword [ebx]
        mov dword [curr_y], eax
        add ebx, 4
        mov eax , dword [ebx]
        mov dword [targets_dest], eax
        pushad
        call rand_in_range
        call rand_distance
        popad
        finit
        fld dword [rand_angle]
        fld dword [curr_angle]
        faddp 
        ;need to do %360
        fst dword [curr_angle]
        fcos
        fld dword [rand_distance_var]
        fmulp
        fld dword [curr_x]
        faddp 
        fstp dword [curr_x]
        ;need to % 100
        fld dword [curr_angle]
        fsin
        fld dword [rand_distance_var]
        fmulp
        fld dword [curr_y]
        faddp
        fstp dword [curr_y]
        ;need to % 100
        call may_destroy

    may_destroy:
        


        
        



       

