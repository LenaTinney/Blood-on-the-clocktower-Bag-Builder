.syntax unified
.global seat_assigner


.type seat_assigner %function
seat_assigner:
@seat_assigner has 4 parts 
@ 1 -> turning player count into role count 
@ 2 -> assiging roles randomly to a bit map
@ 3 -> putting charichters into seats (non ranodomly)
@ 4 -> shuffle the seats around
push {lr}
bl rnd_starter
@ PART 1
ldr r2, =player_count
ldr r2, [r2]
bl role_count
@ PART 2
bl minion
bl outsider
bl town
@ PART 3
ldr r7, =seat_one
ldr r6, =0
ldr r2, =22
bl seat_adder
@PART 4
ldr r5, =10
bl seat_shuffler
pop {lr}
bx lr
role_count: 
    ldr r5, =town_count
    ldr r6, =minion_count
    ldr r7, =outsider_count
    push {lr}
    cmp r2, #7
    beq setup_7
    cmp r2, #8
    beq setup_8
    cmp r2, #9
    beq setup_9
    cmp r2, #10
    beq setup_10
    cmp r2, #11
    beq setup_11
    cmp r2, #12
    beq setup_12
    cmp r2, #13
    beq setup_13
    cmp r2, #14
    beq setup_14
    cmp r2, #15
    beq setup_15
        setup_7:
            ldr r1, =#5
            str r1, [r5,#0] 
            ldr r1, =#1
            str r1, [r6]
            ldr r1, =#0
            str r1, [r7]
            B end

        setup_8:
            ldr r1, =#5
            str r1, [r5]
            ldr r1, =#1
            str r1, [r6]
            ldr r1, =#1
            str r1, [r7]
            B end

        setup_9:
            ldr r1, =#5
            str r1, [r5]
            ldr r1, =#1
            str r1, [r6]
            ldr r1, =#2
            str r1, [r7]
            B end

        setup_10:
            ldr r1, =#7
            str r1, [r5]
            ldr r1, =#2
            str r1, [r6]
            ldr r1, =#0
            str r1, [r7]
            B end

        setup_11:
            ldr r1, =#7
            str r1, [r5]
            ldr r1, =#2
            str r1, [r6]
            ldr r1, =#1
            str r1, [r7]
            B end

        setup_12:
            ldr r1, =#7
            str r1, [r5]
            ldr r1, =#2
            str r1, [r6]
            ldr r1, =#2
            str r1, [r7]
            B end

        setup_13:
            ldr r1, =#9
            str r1, [r5]
            ldr r1, =#3
            str r1, [r6]
            ldr r1, =#0
            str r1, [r7]
            B end

        setup_14:
            ldr r1, =#9
            str r1, [r5]
            ldr r1, =#3
            str r1, [r6]
            ldr r1, =#1
            str r1, [r7]
            B end

        setup_15:
            ldr r1, =#9
            str r1, [r5]
            ldr r1, =#3
            str r1, [r6]
            ldr r1, =#2
            str r1, [r7]
            B end
    end:
    pop {lr}
    bx lr
minion:
    @takes the number of minions and generates that many & adds it to bit map
    @NOTABLE unlike other generators this one has a condtion for a certain charichter
    @as baron causes [+2 outsider] we need to check for it (this is also why minon generate first)
    push {lr}
    bl random_numb
    mov r2, r0
    ldr r0, =#8549945
    mul r2, r0, r2
    ldr r0, = minion_count
    ldr r0, [r0]
    ldr r1, =0b11110  @ enables random gen of psnr, spy, baron, scar
    bl random_assignement
    ldr r2, = set_up_roles
    ldr r3, [r2]
    add r0, r0, r3
    str r0, [r2]
    @BARON LOGIC
    mov r0, r2
    ldr r1, =#0
    ldr r2, =#3
    bl read_bit
    cmp r0, #1
    beq baron_count
    pop {lr}
    bx lr
            baron_count:
            @+2 outsider -2 townsfolk its not that hard really
            ldr r1, =town_count
            ldr r0, [r1]
            sub r0, r0, #2
            str r0, [r1,#0]
            ldr r1, =outsider_count
            ldr r0, [r1]
            add r0, r0, #2
            str r0, [r1,#0]
            pop {lr}
            bx lr

outsider:
@ genreates a number of outsiders equal to [outsider_count] this is then added to the charichter bit map
    push {lr}
    bl random_numb
    mov r2, r0
    ldr r0, =#8543289
    mul r2, r0, r2
    ldr r0, = outsider_count
    ldr r0, [r0]
    ldr r1, =0b111100000  @ enables random gen of butler saint recluse sweetheart
    bl random_assignement
    ldr r2, = set_up_roles
    ldr r3, [r2]
    add r0, r0, r3
    str r0, [r2]
    pop {lr}
    bx lr
town:
@ genreates a number of outsiders equal to [town_count] this is then added to the charichter bit map
    push {lr}
    bl random_numb
    mov r2, r0
    ldr r0, =#3849498
    mul r2, r0, r2
    ldr r0, = town_count
    ldr r0, [r0]
    ldr r1, =0b1111111111111000000000  @ enables random gen of all townsfolk
    bl random_assignement
    ldr r2, = set_up_roles
    ldr r3, [r2]
    add r0, r0, r3
    str r0, [r2]
    pop {lr}
    bx lr
     
seat_adder:
    @this function recursivly goes throught the bit map created by minion, town, outsider
    @and if the bit is one it assignes that charichter to a seat
    @   notably: this is done in town, outsider, minion, demon order
    @r2 number of charichters possible to be in play
    @r6 0, it must be zero
    @r7 register address for seat 1
    cmp r2, #0
    beq stackaddender  
    sub r2, r2, #1 
    ldr r1, =set_up_roles
    ldr r1, [r1]
    lsl r1, r1, #10
    lsl r1, r1, r6
    lsr r1, r1, #31
    add r6, r6, #1
    @ do we add charichter
    cmp r1, #1
    beq seat_push
    bne seat_nopush

    seat_push:
    @we use washer woman as our base register as she is at the top of the script,
    @and is at the top of charichter memory registers
    @we then go down 4 addresses for each additonal chairchter
    ldr r3, =wash
    ldr r0, [r3,r5]
    add r5, r5, #4
    str r0, [r7]
    add r7, r7, 0x4
    b seat_adder
    seat_nopush:
    add r5, r5, #4
    b seat_adder

    stackaddender:
    bx lr



  seat_shuffler:
  @this is a bad shuffling alortythem 
  @ it takes a random number between 0-15
  @ checks if that number is in range for the player count
  @ if it is it swaps seat one and that seat 
  @ eg. rng = 7   seat_one:= seat_seven & vise versa
  @ this is then repeted 1000 times to shuffle charichters
   push {lr}
    @number of swaps
    ldr r5, =#1000
    @player count
    ldr r6, =player_count
    ldr r6, [r6]

    seat_shuffler_main:
        bl random_numb
        lsr r3, r0, #4
        @check if in player count range
        cmp r6, r3
        bls seat_shuffler_main
        @ getting the nth seat to swap with seat one
        ldr r0, =#4
        mul r3, r3, r0
        ldr r0, =seat_one
        add r1, r0, r3
        bl swapper
        @decremnt r5 and if r5=0 exit shuffle
        sub r5, r5, #1
        cmp r5, #0
        beq shuffler_exit
        b seat_shuffler_main
        swapper:
        @takes 2 addresses and swaps their values
        ldr r2, [r0,#0]
        ldr r3, [r1,#0]
        str r3, [r0,#0]
        str r2, [r1,#0]
        bx lr


    shuffler_exit:
    pop {lr}
    bx lr

.type random_assignement, %function
    random_assignement:
    @WHAT THIS DOSE
    @ takes a bitmap of allowed charichters to generate and a number to generate then it generates random charichters (1) in that bit map
    @   r0 number of bits to set
    @   r1 allowed bits map
    @   r2 random number
    @ Output:
    @   r0 result

    @r3 is where the temp results are stored, r5 is the amount of bits left to generate
    push {lr}
    ldr r3, =#0         @ result accumulator
    mov r5, r0         @ bit counter

    @if u call with no bit map it wont loop forever
    cmp     r1, #0        
    beq     done

loop_start:
    @are we done yet?
    cmp r5, #0
    beq done
    @takes the lowest bit index of r2 and shifts it left
    and r7, r2, #31   
    mov r6, #1
    lsl r6, r6, r7 
    @ is this bit allowed by bit map?
    tst     r1, r6         
    beq     rotate_random  
    @ is this bit already set?
    tst     r3, r6         
    bne     rotate_random 
    @sets bit into result
    orr     r3, r3, r6     @ set bit in result
    subs    r5, r5, #1     @ decrement counter

rotate_random:
    @randomises the random numebr more
    ror     r2, r2, #5     @ rotate randomness for next bit
    push {r0}
    push {r1}
    push {r2}
    bl random_numb
    pop {r2}
    add r2, r0, r2
    pop {r1}
    pop {r0}
    
    b loop_start

done:
    @move temp result into r0 for output
    mov r0, r3    
    pop {lr}
    bx lr