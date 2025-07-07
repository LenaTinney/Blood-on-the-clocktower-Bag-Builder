.syntax unified
.global random_numb, rnd_starter
.set TASKS_START, 0x4000D000
.set VALUE, 0x4000D508

.type rnd_starter %function 
@starts the rng (this was hell to figure out)
rnd_starter:
@starts and stops rng,
 push {lr}
@starts rng
 ldr r2, =0x1
 ldr r1, =TASKS_START
 str r2, [r1,#0]
  pop {lr} 
bx lr

.type random_numb %function 
random_numb:
@idk what u want it outputs a random number
@output: 
@r0 random 8 bit number
 push {lr}
@starts rng
 ldr r1, =VALUE
 ldr r0, [r1,#0]
  pop {lr} 
bx lr