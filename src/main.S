.syntax unified
.global main
@ GPIOTE Constants
.set GPIOTE_EVENTS_IN0, 0x40006100
.set GPIOTE_EVENTS_IN1, 0x40006104
.set GPIOTE_INTENSET, 0x40006304
.set GPIOTE_CONFIG0, 0x40006510
.set GPIOTE_CONFIG1, 0x40006514


@ NVIC Constants
.set NVIC_ISER0, 0xE000E100
.set NVIC_ISER1, 0xE000E104


.type main, %function
main:
  @Initialize LEDs   
  bl init_leds

  @Configure GPIOTE_CONFIG0 (for Button A, Pin 14)
  @ mode = 1 (event), pin = 14 (Button A), port = 0 (P0.14), polarity = 1 (LoToHi)
  ldr r0, =GPIOTE_CONFIG0
  ldr r1, =(1 | 14 << 8 | 0 << 13 | 1 << 16) @ Pin 14 (Button A), LoToHi
   str r1, [r0]

  @Configure GPIOTE_CONFIG (for Button B, Pin 23)
  @ mode = 1 (event), pin = 23 (Button B), port = 0 (P0.23), polarity = 1 (LoToHi)
  ldr r0, =GPIOTE_CONFIG1
  ldr r1, =(1 | 23 << 8 | 0 << 13 | 1 << 16) @ Pin 23 (Button B), LoToHi
  str r1, [r0]


  @Enable Interrupts for GPIOTE[0] (Button A&B)
  ldr r0, =GPIOTE_INTENSET
  ldr r1, =0b11          
  str r1, [r0]

  @Enable GPIOTE interrupt in NVIC
  ldr r0, =NVIC_ISER0
  ldr r1, =(1 << 6)          
  str r1, [r0]
  @Enable GPIOTE interrupt in NVIC
  ldr r0, =NVIC_ISER1
  ldr r1, =(1 << 6)          
  str r1, [r0]    
  b scan_handeler



  scan_handeler:
  @ vestigial call of an old system (everthing breaks when removed)
    B scanner

  scanner:
    @r0 = 0b01010 01100...00111 0 11 1111 
    @ takes the 5 5 bit booleans and turns them on and off over and over again
    @ this scans over the 25 bits
    @ --perameters--
    @ r0: charichter/led states (looks over and preserves char info)
    ldr r0, =scan_head
    ldr r0, [r0]
    push {r0}
    push {r0}
    
    @top row 
    ldr r0, = 0b1
    bl write_row_pins_natural
    pop {r0}
    bl write_column_pins_natural
    pop {r0}
    ROR r0, #5
    push {r0}
    push {r0}


    ldr r0, = 0b0
    bl write_column_pins_natural

    @2nd row 
    ldr r0, = 0b10
    bl write_row_pins_natural
    pop {r0}
    bl write_column_pins_natural
    pop {r0}
    ROR r0, #5 
    push {r0}
    push {r0}

    ldr r0, = 0b0
    bl write_column_pins_natural
    @3rd row 
    ldr r0, = 0b100
    bl write_row_pins_natural
    pop {r0}
    bl write_column_pins_natural
    pop {r0}
    ROR r0, #5
    push {r0}
    push {r0}
    
    ldr r0, = 0b0
    bl write_column_pins_natural
    @4th row 
    ldr r0, = 0b1000
    bl write_row_pins_natural
    pop {r0}
    bl write_column_pins_natural
    pop {r0}
    ROR r0, #5   
    push {r0}
    push {r0}
    
    ldr r0, = 0b0
    bl write_column_pins_natural

    @5th row 
    ldr r0, = 0b10000
    bl write_row_pins_natural
    pop {r0}
    pop {r0}
    bl write_column_pins_natural

    ldr r0, = 0b0
    bl write_column_pins_natural
    b scanner




.global GPIOTE_IRQHandler
.type GPIOTE_IRQHandler, %function
GPIOTE_IRQHandler:
  @ takes the gpiote_events_in signals works out which one of button A and B is being pressed then braches to a or b
  push {lr}
  @this is hardcoded delay because the buttons are bad
  ldr r0, =0x4FFFFF
  bl delay
  @clear button A
  ldr r0, =GPIOTE_EVENTS_IN0
  ldr r1, =0
  ldr r6, =1
  ldr r2, [r0]
  str r1, [r0]
  @was A pressed??
  cmp r2, #1
  beq a_button 
  @clear button B
  ldr r0, =GPIOTE_EVENTS_IN1
  ldr r2, [r0]
  ldr r1, =0
  str r1, [r0]
  ldr r6, =9
  @was B pressed??
  cmp r2, #1
  beq b_button
  @idk how u got here but if all else fails just go back to scanner
  b scan_handeler


a_button:
  @informs where to branch to based on game state
  ldr r6, =2
  ldr r0, =game_state
  ldr r0, [r0]
  cmp r0, #0
  @player num select
  beq GameStarter
  @charichter distrobution/story teller grimrour
  bne seat_cycler
  

b_button:
  ldr r0, =game_state
  ldr r0, [r0,#0]
  cmp r0, #0
  beq game_starter
  bne game_restarter
  b terminator






    game_restarter:
    @this resets the game dunno if i can be less obvious
    ldr r0, =#0
    ldr r1, =seat_one
    str r0, [r1,0]
    ldr r1, =seat_two
    str r0, [r1,0]
    ldr r1, =seat_three
    str r0, [r1,0]
    ldr r1, =seat_four
    str r0, [r1,0]
    ldr r1, =seat_five
    str r0, [r1,0]
    ldr r1, =seat_six
    str r0, [r1,0]
    ldr r1, =seat_seven
    str r0, [r1,0]
    ldr r1, =seat_eight
    str r0, [r1,0]
    ldr r1, =seat_nine
    str r0, [r1,0]
    ldr r1, =seat_ten
    str r0, [r1,0]
    ldr r1, =seat_eleven
    str r0, [r1,0]
    ldr r1, =seat_twelve
    str r0, [r1,0]
    ldr r1, =seat_thirteen @omg house md reference
    str r0, [r1,0]
    ldr r1, =seat_fourteen
    str r0, [r1,0]
    ldr r1, =seat_fithteen
    str r0, [r1,0]

    ldr r1, =town_count
    str r0, [r1,0]
    ldr r1, =outsider_count
    str r0, [r1,0]
    ldr r1, =minion_count
    str r0, [r1,0]
    ldr r1, =game_state
    str r0, [r1,0]

    ldr r0, = 1
    ldr r1, = set_up_roles
    str r0, [r1,#0]

    ldr r0, = 7
    ldr r1, = player_count
    str r0, [r1,#0]

    ldr r0, = 0b00000001111000010001000010000100
    ldr r1, = set_up_roles
    str r0, [r1,#0]
    @ i could have wrote this better but i chose to write it poorly because its 12:49pm on monday n idk i want this to be over
    b terminator


    game_starter:
    @ this calls the hell file that is gen.S
    @ then dose the easy work of like incrementing game state n assiging scan_head
    bl seat_assigner
    ldr r0, =game_state
    ldr r1, =#1
    str r1, [r0,#0]
    ldr r0, =scan_head
    ldr r1, =one
    ldr r1, [r1]
    str r1, [r0,#0]




    b terminator

  seat_cycler: 
  @seat cycler takes memory registers and decides between 3 branches
  @ 1: looped through all seats -> reset the loop
  @ 2: odd game state           -> display number
  @ 3: even game state          -> display charichter
  ldr r2, =game_state
  ldr r0, [r2]
  add r0, r0, #1
  str r0, [r2,#0]
  ldr r1, =player_count
  ldr r1, [r1]
  ldr r2, =#2
  mul r1, r1, r2
  add r1, r1, #1
  cmp r0, r1
  beq game_looper
  tst r0, #1 @will test if even or odd
  bne odd
  beq even
    odd:
    @odd n even are basically the same function, take game state do maths to game state 
    @apply that number to registers to get the image and apply to scan head
    @imports
    ldr r3, = one
    ldr r5, =scan_head
    @takes game state ie 1,3,5,7 (all numbers) then subtracts one and loads 4n steps along the memory bus,
    @eg. gamestate=7 -> 3 being shown and anothe a button press will show charichter at 3
    sub r0, r0, #1
    udiv r0, r0, r2
    ldr r2,= #4
    mul r0, r0, r2
    ldr r3, [r3]
    str r3, [r5,#0]
    @incremtent game state
    
    b terminator
    even:
    @odd n even are basically the same function, take game state do maths to game state 
    @apply that number to registers to get the image and apply to scan head
    @imports
    ldr r3, = seat_one
    ldr r5, =scan_head
    @takes game state ie 2,4,6,8 (all numbers) loads 4n steps along the memory bus from seat one,
    @eg. gamestate=7 -> 3 being shown and anothe a button press will show charichter at 3
    udiv r0, r0, r2 
    sub r0, r0, #1
    ldr r2,= #4
    mul r0, r0, r2
    add r3, r0
    ldr r3, [r3]
    str r3, [r5,#0]
    @incremtent game state
    b terminator

    game_looper:
    @loops the players and thier roles idea is first time is for players n times after is for story tellers
    ldr r0, =game_state
    ldr r1, =#1
    str r1, [r0,#0]
    ldr r0, =scan_head
    ldr r1, =one
    ldr r1, [r1]
    str r1, [r0,#0]
    
  
GameStarter:
@takes the start of game and incremtns the numbner on backend and for player by 1 
  @imports
  ldr r6, =3
  ldr r2, =seven
  ldr r1, =player_count
  ldr r1, [r1]
  @if r1=15 reset loop
  cmp r1, #15
  Beq gamestarter_looper
  Bne gamestarter_nonlooper
  
  

gamestarter_nonlooper:
  @when chosing players takes number on screen, makes it go up by 1 (very inovative ik)
   @stores new player count
  add r1, r1, #1
  ldr r3, =player_count
  str r1, [r3,#0]

  @gets the new number to display from memory
  sub r1, r1, #7
  ldr r3, =0x4
  mul r3, r1, r3
  
  add r2, r2, r3
  ldr r0, [r2]
  ldr r2, =scan_head
  str r0, [r2,#0]
  b terminator
  

gamestarter_looper:
@ if number on screen is 15 then make number 7 because those are the bounds of playercount 
@resets player_count to 7 and then sends 7 to the scanner
  ldr r6, =5
  ldr r1, =0x7
  ldr r2, =player_count
  str r1, [r2,#0]
  ldr r0, =seven
  ldr r0, [r0]
  ldr r2, =scan_head
  str r0, [r2,#0]
  b terminator 


terminator:
pop {lr}
bx lr
.size GPIOTE_IRQHandler, .-GPIOTE_IRQHandler
@ just a buncha stuff to store in memory(not very interesting)
.global seat_one, town_count, minion_count, outsider_count, set_up_roles, player_count, imp, wash, seat_fithteen
.data 
  wash:
  .word 0x7EF694   @0x20000000
  libr:
  .word 0x5E97BDE  @0x20000004
  invt:
  .word 0x88A3041 @0x20000008
  chef:
  .word 0xCEFFDCE @0x2000001B
  epth:
  .word 0x10A8C544 @0x20000010
  fort:  
  .word 0x14E8C5DB @0x20000014
  undr:
  .word 0x18E211CE @0x20000018
  monk:
  .word 0x1C4F9084 @0x2000001B
  rven:
  .word 0x200D9000 @0x20000020
  vrgn:
  .word 0x248A28A2 @0x20000024
  slyr:
  .word 0x28417C44 @0x20000028
  sldr:
  .word 0x2DFFFDC4 @0x2000002B
  myor:
  .word 0x30EFA95F @0x20000030
  @outsider roles
  btlr:
  .word 0x40077C00 @0x20000034
  rcls:
  .word 0x444728AE  @0x20000038
  sant:
  .word 0x491DB880 @0x2000003B
  swht: 
  .word 0x4CAAB89B @0x20000040
  @minion roles
  psnr:
  .word 0x80052944 @0x20000068
  spy:
  .word 0x84EAD7E0 @0x20000072
  scar:
  .word 0x880745C0 @0x20000076
  barn:
  .word 0x8CE73BE0 @0x20000080
  @demon roles
  imp:
  .word 0xFF5AFC84 @0x20000088
  one:
  .word 0b00000000010001100001000010001110 @0x20000092
  two:
  .word 0b00000000111000010011100100001110 @0x20000096
  three:
  .word 0b00000000111000010011100001001110 @0x200000A0
  four:
  .word 0b00000000101001010011100001000010 @0x200000A4
  five:
  .word 0b00000000111001000011100001001110 @0x200000A8
  six: 
  .word 0b00000000111001000011100101001110 @0x200000B2
  seven:
  .word 0b00000001111000010001000010000100 @0x200000B6
  eight:
  .word 0b00000000111001010011100101001110 @0x200000C0
  nine:
  .word 0b00000000111001010011100001001110 @0x200000C4
  ten:
  .word 0b00000001011110101101011010110111 @0x200000c8
  eleven: 
  .word 0b00000001001010010100101001010010 @0x200000D2
  twelve:
  .word 0b00000001011110001101111010010111 @0x200000D6
  thirteen:
  .word 0b00000001011110001101111000110111 @0x200000E0
  fourteen:
  .word 0b00000001010110101101111000110001 @0x200000E4
  fithteen:
  .word 0b00000001011110100101111000110111 @0x200000E8
  seat_one:
  .word 0b00000000000000000000000000000000 @0x200000F2
  seat_two:
  .word 0b00000000000000000000000000000000 @0x200000F6
  seat_three:
  .word 0b00000000000000000000000000000000 @0x20000100
  seat_four:
  .word 0b00000000000000000000000000000000 @0x20000104
  seat_five:
  .word 0b00000000000000000000000000000000 @0x20000108
  seat_six:
  .word 0b00000000000000000000000000000000 @0x20000112
  seat_seven:
  .word 0b00000000000000000000000000000000 @0x20000116
  seat_eight:
  .word 0b00000000000000000000000000000000 @0x20000120
  seat_nine:
  .word 0b00000000000000000000000000000000 @0x20000124
  seat_ten:
  .word 0b00000000000000000000000000000000 @0x20000128
  seat_eleven:
  .word 0b00000000000000000000000000000000 @0x20000132
  seat_twelve:
  .word 0b00000000000000000000000000000000 @0x20000136
  seat_thirteen:
  .word 0b00000000000000000000000000000000 @0x20000140
  seat_fourteen:
  .word 0b00000000000000000000000000000000 @0x20000144
  seat_fithteen:
  .word 0b00000000000000000000000000000000 @0x20000148
  player_count: 
  .word 0x7 @0x200001
  game_state: 
  .word 0b00000000000000000000000000000000 @0x20000148
  scan_head:
  .word 0b00000001111000010001000010000100 @0x20000148
  minion_count:
  .word 0b00000000000000000000000000000000
  outsider_count:
  .word 0b00000000000000000000000000000000
  town_count:
  .word 0b00000000000000000000000000000000
  set_up_roles:
  .word 0b00000000000000000000000000000001 @0b0000000000000 0000 0000 1 if 1 then in play else not in play (town) (outsiders) (minions) (imp)

