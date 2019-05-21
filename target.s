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
    extern    rand_target
    extern    resume
    global    creat_target


    creat_target:
        call rand_target
        call resume
        ret

