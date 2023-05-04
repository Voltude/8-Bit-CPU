call main

init:
ldi r0, 0
str r0, led0
str r0, led1
str r0, dsp0
str r0, dsp1
ret

debounce:
push r0
ldi r0, 5
delay_loop:
dec r0
jnz delay_loop
pop r0
ret

next_state:
push r0
push r1
ldi r1, 128
wait_off:
ldr r0, sw1
and r0, r1
jnz wait_off
wait_on:
ldr r3, sw0
str r3, led0
str r3, dsp0
ldr r0, sw1
and r0, r1
jez wait_on
call debounce
pop r1
pop r0
ret

main:
call init
main_loop:
ldi r0, 128
str r0, led1
call next_state
mov r10, r3
ldi r0, 64
str r0, led1
call next_state
mov r11, r3
ldi r0, 32
str r0, led1
call next_state

ldi r0, 16
str r0, led1
; Mask off first 2 bits
ldi r0, 3
and r3, r0
; ADD if opcode is 11
mov r1, r3
sub r1, r0
jez comp_and
; OR if opcode is 10
dec r0
mov r1, r3
sub r1, r0
jez comp_or
; SUB if opcode is 01
dec r0
mov r1, r3
sub r1, r0
jez comp_sub
; ADD if opcode is 00
jmp comp_add

comp_and:
and r10, r11
jmp display

comp_or:
or r10, r11
jmp display

comp_sub:
sub r10, r11
jmp display

comp_add:
add r10, r11
jmp display

display:
str r10, dsp0
jmp restart

restart:
ldi r1, 128
sw_off:
ldr r0, sw1
and r0, r1
jnz sw_off
sw_on:
ldr r0, sw1
and r0, r1
jez sw_on
jmp main