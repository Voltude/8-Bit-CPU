jmp main

delay:
str r0, 200
ldi r0, 30
delay_loop:
dec r0
jnz delay_loop
ldr r0, 200
ret

init:
ldi r0, 0
ldi r1, 1
ldi r2, 0
ldi r3, 0
ret

main:
call init
main_loop:
add r0, r1
jca increment
jmp continue
increment:
inc r2
continue:
add r2, r3
jca main
str r0, led0
str r2, led1
str r0, dsp0
str r2, dsp1

mov r4, r0
mov r0, r1
mov r1, r4
mov r4, r2
mov r2, r3
mov r3, r4

call delay
jmp main_loop