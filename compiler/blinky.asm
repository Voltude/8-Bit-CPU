jmp init

; Delay function
delay:
ldr r10, 200
ldi r11, 1
loop:
sub r10, r11
jnz loop
ret

; Shift through first 8 LEDs
init:
ldi r0, 0
str r0, led0
str r0, led1
ldi r0, 3
str r0, 200
ldi r0, 1
ldi r1, 0
loop1:
mov r2, r0
or r2, r1
str r2, led0
call delay
mov r1, r0
add r0, r0
jnz loop1
; Shift through last 8 LEDs
ldi r2, 1
str r1, led0
str r2, led1
call delay
ldi r1, 0
mov r3, r2
ldi r2, 2
mov r4, r2
or r4, r3
str r1, led0
str r4, led1
loop2:
mov r4, r2
or r4, r3
str r4, led1
call delay
mov r3, r2
add r2, r2
jnz loop2

ldi r0, 30
str r0, 200
ldi r0, 170
ldi r1, 10
loop3:
str r0, led0
str r0, led1
not r0
call delay
dec r1
jez init
jmp loop3