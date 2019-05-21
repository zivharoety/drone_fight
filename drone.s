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
    extern    target_x
    extern    target_y
    extern    create_target
    extern    printf
    global    resume
    global    function

section .data
    curr_x: dd 0.0
    curr_y: dd 0.0
    curr_angle: dd 0.0
    targets_dest: dd 0
    curr_distance: dd 0
    new_x: dd 0.0
    new_y: dd 0.0
    gamma: dd 0.0
    first_flag: dd 0
    second_flag: dd 0
    sin_angle: dd 0
    cos_angle: dd 0
    tan_angle: dd 0

section .rodata
        f_format_winning: db "%s,%d","%s",10 , 0	; format string to the target
        winning_msg_1: db 'Drone id ', 0
        winning_msg_2: db ': I am a winner' ,0
        three_sisxty: dd 360
        hundred: dd 100



section .text
     
    function:
        mov eax , [curr_drone]              ;getting the curr drone stack
        mov ebx,  STKSIZE
        imul ebx
        mov ebx , [stacks]
        add ebx, eax                
        mov eax, dword [ebx]        
        mov dword [curr_angle], eax         ;getting the curr angle
        add ebx, 4
        mov eax , dword [ebx]
        mov dword [curr_x], eax             ;getting the curr x
        add ebx, 4
        mov eax , dword [ebx]
        mov dword [curr_y], eax             ;getting the curr y
        add ebx, 4
        mov eax , dword [ebx]
        mov dword [targets_dest], eax       ;getting the curr targets_dest
        pushad
        call rand_in_range                  ;generating a new angle
        call rand_distance                  ;generating a new distance
        popad
    .ziv_debug2:
        finit
        fld dword [rand_angle]
        fld dword [curr_angle]
        faddp     
        fild dword [three_sisxty]
        fcomip
        jg function.next
        fstp dword [first_flag]
        fild dword [three_sisxty]
        fld dword [curr_angle]
        fsubp
    .next:
        fst dword [curr_angle]
        fcos
        fld dword [rand_distance_var]
        fmulp
        fld dword [curr_x]
        faddp 
        fst dword [curr_x]
        fild dword [hundred]
        fcomip
        jg function.next2
        fstp dword [first_flag]
        fild dword [hundred]
        fld dword [curr_x]
        fsubp
        fstp dword [curr_x]
    .next2:
        fld dword [curr_angle]
        fsin
        fld dword [rand_distance_var]
        fmulp
        fld dword [curr_y]
        faddp
        fst dword [curr_y]
        fild dword [hundred]
        fcomip
        jg function.next3
        fstp dword [first_flag]
        fild dword [hundred]
        fld dword [curr_y]
        fsubp
        fstp dword [curr_y]
    .next3:
        call may_destroy

    may_destroy:
        finit
        fld dword [target_y]
        fld dword [curr_y]
        fsubp
        fstp dword [new_y]      ;calculating y2-y1 
        fld dword [target_x]
        fld dword [curr_x]
        fsubp
        fstp dword [new_x]         ;calculating x2-x1
        fld dword [new_y]
        fld dword [new_x]
        fpatan
        fstp dword [gamma]              ;calculating arctan2(y2-y1,x2-x1)
        fld dword [curr_angle]
        fld dword [gamma]
        fsubp
        fabs
        fld dword [beta]
        fcomi                       
        jl may_destroy.cant_destroy
        ffree
        finit
        fld dword [new_x]
        fld dword [new_x]
        fmulp
        fld dword [new_y]
        fld dword [new_y]
        fmulp
        faddp
        fsqrt
        fild dword [max_distance]
        fcomi
        jg may_destroy.cant_destroy    

    .can_destroy:
        mov eax, dword [targets_dest]
        add dword eax , 1
        mov [targets_dest] , dword eax
        cmp eax , dword [targets_to_win]
        je may_destroy.i_am_the_winner
        call create_target     ;TODO: need to implement the target co-routine 

    .cant_destroy:
        ret
       

    .i_am_the_winner:
        pushad
        push winning_msg_1
        push dword [curr_drone]
        push winning_msg_2
        push f_format_winning
        call printf
        add esp, 16
        popad
        mov eax , 1
        mov ebx , 0
        int 0x80

                


        
        



       

