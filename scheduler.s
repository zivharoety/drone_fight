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
    extern    resume
    extern    game_over


    game_loop:
        cmp dword [game_over] , 1
        je finish_game
        mov eax, dword [drone_steps_till_print]
        cmp dword [curr_drone], eax                 ;checks if we need to print the board
        jne dont_call_printer
        pushad
        call printer
        pop ad
    dont_call_printer:
        mov eax , [curr_drone]
        mov ebx , 8
        mul ebx
        mov ebx , [CORS+eax]            ;to recheck
        call resume



        inc dword [curr_drone]
        mov edx , [num_of_drones]
        cmp edx , dword [curr_drone]
        je reset_curr_drone
        jmp game_loop
    reset_curr_drone:
        mov dword [curr_drone], 0
        jmp game_loop

    finish_game:       ;should we return back to main or just end the program?
        


