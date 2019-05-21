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
    extern    printer
    extern    function
    global    resume

section .data
    drone_steps: dd 0

resume:
    .game_loop:
        mov eax, dword [drone_steps_till_print]
        cmp dword [drone_steps], eax                 ;checks if we need to print the board
        jne resume.dont_call_printer
        pushad
        call printer
        popad
        mov dword [drone_steps] , 0
    .dont_call_printer:
        mov eax , [curr_drone]
        mov ebx , 8
        mul ebx
        mov ebx , [CORS+eax]            ;to recheck
        call function
        inc dword [curr_drone]
        inc dword [drone_steps]
        mov edx , [num_of_drones]
        cmp edx , dword [curr_drone]
        je resume.reset_curr_drone
        jmp resume.game_loop
    .reset_curr_drone:
        mov dword [curr_drone], 0
        jmp resume.game_loop   

    ret