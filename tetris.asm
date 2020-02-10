  ;; game state memory location
  .equ T_X, 0x1000                  ; falling tetrominoe position on x
  .equ T_Y, 0x1004                  ; falling tetrominoe position on y
  .equ T_type, 0x1008               ; falling tetrominoe type
  .equ T_orientation, 0x100C        ; falling tetrominoe orientation
  .equ SCORE,  0x1010               ; score
  .equ GSA, 0x1014                  ; Game State Array starting address
  .equ SEVEN_SEGS, 0x1198           ; 7-segment display addresses
  .equ LEDS, 0x2000                 ; LED address
  .equ RANDOM_NUM, 0x2010           ; Random number generator address
  .equ BUTTONS, 0x2030              ; Buttons addresses

  ;; type enumeration
  .equ C, 0x00
  .equ B, 0x01
  .equ T, 0x02
  .equ S, 0x03
  .equ L, 0x04

  ;; GSA type
  .equ NOTHING, 0x0
  .equ PLACED, 0x1
  .equ FALLING, 0x2

  ;; orientation enumeration
  .equ N, 0
  .equ E, 1
  .equ So, 2
  .equ W, 3
  .equ ORIENTATION_END, 4

  ;; collision boundaries
  .equ COL_X, 4
  .equ COL_Y, 3

  ;; Rotation enumeration
  .equ CLOCKWISE, 0
  .equ COUNTERCLOCKWISE, 1

  ;; Button enumeration
  .equ moveL, 0x01
  .equ rotL, 0x02
  .equ reset, 0x04
  .equ rotR, 0x08
  .equ moveR, 0x10
  .equ moveD, 0x20

  ;; Collision return ENUM
  .equ W_COL, 0
  .equ E_COL, 1
  .equ So_COL, 2
  .equ OVERLAP, 3
  .equ NONE, 4

  ;; start location
  .equ START_X, 6
  .equ START_Y, 1

  ;; game rate of tetrominoe falling down (in terms of game loop iteration)
  .equ RATE, 5

  ;; standard limits
  .equ X_LIMIT, 12
  .equ Y_LIMIT, 8


; BEGIN:main:
main:

addi sp,zero,0x1500
addi s2, zero, RATE

call store
call reset_game
call load


big_loop:

little_loop:

add t0,zero,zero

while_rate:

beq t0, s2, end_while_rate
addi sp,sp,-4
stw t0, 0(sp)

addi sp, sp, -4
stw v0, 0(sp)
call store
call draw_gsa
call load
ldw v0, 0(sp)
addi sp, sp, 4

call display_score

call wait


addi a0,zero ,NOTHING

call store
call draw_tetromino
call load

addi sp, sp, -4
stw v0, 0(sp)
call store
call draw_gsa
call load
ldw v0, 0(sp)
addi sp, sp, 4





call get_input
beq v0,zero, no_input
add a0,zero,v0

call store
call act
call load

addi a0,zero,FALLING

call store
call draw_tetromino
call load

addi sp, sp, -4
stw v0, 0(sp)
call store
call draw_gsa
call load
ldw v0, 0(sp)
addi sp, sp, 4



no_input:

addi a0,zero,FALLING
call store
call draw_tetromino
call load

addi sp, sp, -4
stw v0, 0(sp)
call store
call draw_gsa
call load
ldw v0, 0(sp)
addi sp, sp, 4



ldw t0, 0(sp)
addi sp,sp,4
addi t0,t0,1
jmpi while_rate

end_while_rate:

addi a0,zero ,NOTHING

call store
call draw_tetromino
call load

addi a0, zero, moveD

call store
call act
call load

addi a0,zero,FALLING

call store
call draw_tetromino
call load

addi sp, sp, -4
stw v0, 0(sp)
call store
call draw_gsa
call load
ldw v0, 0(sp)
addi sp, sp, 4


beq v0,zero, little_loop

addi a0,zero,PLACED

call store
call draw_tetromino
call load


addi sp, sp, -4
stw v0, 0(sp)
call store
call draw_gsa
call load
ldw v0, 0(sp)
addi sp, sp, 4



while_full_line:

addi t1, zero ,8

addi sp,sp,-4
stw t1, 0(sp)

call store
call detect_full_line
call load

ldw t1, 0(sp)
addi sp,sp,4
beq v0,t1, no_full_line
add a0,v0,zero

call store

call remove_full_line
call load

call increment_score
;call display_score

jmpi while_full_line

no_full_line:

call generate_tetromino
addi a0, zero,OVERLAP

call store
call detect_collision
call load

addi t0  ,zero ,NONE
bne  v0, t0 ,loser

addi a0, zero, FALLING
call store
call draw_tetromino
call load

addi sp, sp, -4
stw v0, 0(sp)
call store
call draw_gsa
call load
ldw v0, 0(sp)
addi sp, sp, 4


jmpi big_loop

loser:

jmpi main



; END:main:




; BEGIN:helper


store:
addi sp, sp,-44
stw t0, 0(sp)
stw t1, 4(sp) 
stw t2, 8(sp) 
stw t3, 12(sp) 
stw t4, 16(sp) 
stw t5, 20(sp) 
stw t6, 24(sp) 
stw t7, 28(sp)
stw a0, 32(sp) 
stw a1, 36(sp) 
stw a2, 40(sp) 
ret

load:
ldw t0, 0(sp)
ldw t1, 4(sp) 
ldw t2, 8(sp) 
ldw t3, 12(sp) 
ldw t4, 16(sp) 
ldw t5, 20(sp) 
ldw t6, 24(sp) 
ldw t7, 28(sp)
ldw a0, 32(sp) 
ldw a1, 36(sp) 
ldw a2, 40(sp) 
addi sp, sp,44
ret


; END:helper



; BEGIN:clear_leds:
clear_leds:
stw zero, LEDS(zero);
stw zero,LEDS + 4(zero);
stw zero, LEDS + 8(zero);
ret

; END:clear_leds:

; BEGIN:set_pixel:
set_pixel:  ;
addi t0, r0, 0x03 ; Mask of last 3 bits
and t1, a0, t0 ; get last 3 bits of x
slli t1, t1, 3 ;multiply col of x times 8

add t1, t1, a1; ;; add y ---
srli t0, a0, 2 ;compute which led to work with ---
addi t2, r0, 1; ;;mask of 1
sll t2, t2, t1; ;;shift mask to add one ---
slli t0 ,t0, 2
ldw t3,  LEDS(t0); ;;get current led
or t3, t3, t2 ;modify led
stw t3, LEDS(t0) ;; store led
ret

; END:set_pixel:

; BEGIN:wait
wait:
addi t0, r0, 1 ;
slli t0, t0, 20 ;; init couter to 2 power 2â€¡



wait_helper:
addi t0, t0, -1 ;; decrease counter
bne r0, t0, wait_helper;
ret

; END:wait

; BEGIN:in_gsa

in_gsa:
addi v0, r0, 0;
cmplti t0, a0, 0;; if x < 0
bne t0, r0, fin;
cmplti t0, a1, 0;; if y < 0
bne t0, r0, fin;
cmpgei t0, a0, 12; if x >= 12
bne t0, r0, fin;
cmpgei t0, a1, 8; if y >= 8
bne t0, r0, fin;

ret

fin:
addi v0, r0, 1;
ret

; END:in_gsa

; BEGIN:get_gsa

get_gsa:


slli t0, a0, 3 ;; multiply x by 8
add t0, t0, a1  ;; add y
slli t0, t0, 2
ldw v0, GSA(t0)

ret

; END:get_gsa


; BEGIN:set_gsa
set_gsa:
slli t0, a0, 3 ; multiply x by 8
add t0, t0, a1 ;  add y
slli t0, t0,2
stw a2, GSA(t0)
ret

; END:set_gsa



; BEGIN:draw_gsa

draw_gsa:
addi sp, sp, -4
stw ra, 0(sp)
call clear_leds


addi s0, r0, 0
addi s1,zero,96

draw_gsa_loop:

beq s0, s1, draw_gsa_end
andi t1, s0, 0x7 ; y
srli t2, s0 , 0x3 ; x
addi a0, t2, 0 ; x
addi a1, t1, 0 ; y

call store
call get_gsa ;get current state
call load

addi s0, s0, 1 ;
beq v0, r0, draw_gsa_loop ; if cuurent is zero skip
call set_pixel ; if not draw it

jmpi draw_gsa_loop

draw_gsa_end:
ldw ra, 0(sp)
addi sp, sp, 4
ret

; END:draw_gsa

; BEGIN:generate_tetromino
generate_tetromino:

draw_random:
ldw t0, RANDOM_NUM(zero) ; prend le random  aa remettrte
addi t1, zero ,6 ;position initiale
addi t2,zero,1

andi t0, t0, 7

addi t3,zero,5
bge t0, t3, draw_random ; si plus grand que 4 on redraw  / a remettre
 

stw t1,T_X(zero)
stw t2, T_Y(zero)
stw zero,T_orientation(zero)
stw  t0 , T_type(zero)
ret


; END:generate_tetromino

; BEGIN:detect_collision
detect_collision:

addi sp, sp , -16
stw ra, 0(sp)
stw s0, 4(sp)
stw s1, 8(sp)
stw a0, 12(sp)



addi s0, zero,-1; t1 pour bouger tx et t2 our bouger ty
add s1, zero,zero
beq a0, zero, col_debut ;check une collision west

addi t0 ,zero,E_COL ; t0  utilisé pour savoir quel type de colision

addi s0, zero,1; t1 pour bouger tx et t2 our bouger ty
add s1, zero,zero
beq a0, t0 ,col_debut ; check une collision est

addi t0, zero,So_COL

addi s0, zero,0 ; t1 pour bouger tx et t2 our bouger ty
addi s1, zero,1
beq a0, t0, col_debut ; check une collision sud


;reste que les overlap dans qule cas on ne bouge rien on teste juste si qqchose du tetromino touche qqchose
add s0, zero,zero
add s1,zero,zero

col_debut:

addi a2,zero , FALLING
ldw t0, T_type(r0); get type
slli t0, t0, 4 ; times 16
ldw t1, T_orientation(r0); get orientation
slli t1, t1, 2 ; times 4
add t0, t0, t1 ; add both

ldw t2, DRAW_Ax(t0); pos of x coordinates
ldw t3, DRAW_Ay(t0); pos of y coordinates
addi t7, r0, 3 ; counter

addi sp, sp, -12
stw t2, 0(sp)
stw t3, 4(sp)
stw t7, 8(sp)

col_loop:

ldw t7, 8(sp)
ldw t3, 4(sp)
ldw t2, 0(sp)

beq t7, r0, col_fin
addi t7, t7, -1 ; decrease counter
stw t7, 8(sp)
add t6, r0, t7 ; assign counter
slli t6, t6, 2 ; counter times 4 to compute next address offset
add t5, t6, t2 ; add offset to start of address of x
ldw t0, 0(t5); get x coordinate offset
add t5, t6, t3 ; add offset to the other address of y
ldw t1, 0(t5); get y coordinate offset
ldw t2, T_X(r0); get anchor x
ldw t3, T_Y(r0); get anchor y
add t0, t0, t2 ;add ofset x plus anchor x
add t1, t1, t3 ; add offset y plus anchor y

add a0, r0, t0 ; set second argument (x)
add a1, r0, t1 ; set third argument (y)

add a0, a0,s0
add a1, a1,s1

call in_gsa ; teste si sort du cadre
bne v0, zero, ya_col_loop

call store
call get_gsa ;get current state
call load

addi s5, t0, 0

addi t0,zero,PLACED
beq v0, t0, ya_col_loop

addi t0, s5, 0
jmpi col_loop


col_fin:

addi sp, sp, 12
ldw t2, T_X(r0); get anchor x
ldw t3, T_Y(r0); get anchor y
add a0, r0, t2 ; set second argument (x) for anchor
add a1, r0, t3 ; set third argument (y) for anchor

add a0, a0,s0
add a1, a1,s1

call in_gsa ; teste si sort du cadre
bne v0, zero, ya_col
call store
call get_gsa ;get current state
call load

addi s5, t0, 0

addi t0,zero,1
beq v0, t0, ya_col
addi t0, s5, 0

jmpi pas_col


pas_col: ;pas de colision

ldw ra, 0(sp)
ldw s0, 4(sp)
ldw s1, 8(sp)
ldw a0, 12(sp)
addi sp, sp,16

addi v0, zero, NONE
add s0, zero,zero
add s1,zero,zero
ret

ya_col_loop:

addi sp, sp, 12
ldw t2, T_X(r0); get anchor x
ldw t3, T_Y(r0); get anchor y
add a0, r0, t2 ; set second argument (x) for anchor
add a1, r0, t3 ; set third argument (y) for anchor

ldw ra, 0(sp)
ldw s0, 4(sp)
ldw s1, 8(sp)
ldw a0, 12(sp)
addi sp, sp,16
add v0, a0,zero
add s0, zero,zero
add s1,zero,zero
ret


ya_col: ;ya colision
ldw ra, 0(sp)
ldw s0, 4(sp)
ldw s1, 8(sp)
ldw a0, 12(sp)
addi sp, sp,16
add v0, a0,zero

ret
; END:detect_collision




; BEGIN:remove_full_line

remove_full_line:
addi sp,sp, -4
stw ra, 0(sp)

add a1,zero,a0 ;ligne
add a0,zero,zero;colonne

addi a2,zero,0 ;valeur a mettre
call switch_line
call store
call draw_gsa
call load
call wait


addi a2,zero,1
call switch_line
call store
call draw_gsa
call load
call wait

addi a2,zero,0 ;valeur a mettre

call switch_line
call store
call draw_gsa
call load
call wait


addi a2,zero,1
call switch_line
call store
call draw_gsa
call load
call wait

addi a2,zero,0 ;valeur a mettre

call switch_line
call store
call draw_gsa
call load
call wait



move_down:

addi t0, a1, 0
addi t2,zero, 12

y_loop:

beq t0, r0, end_move_down
addi t0, t0, -1 ; y
addi t1, zero,11 ; x

x_loop:

addi a0, t1, 0
addi a1, t0, 0
call store
call get_gsa ;get current state
call load
addi a2, v0, 0
addi a1, a1, 1
call store
call set_gsa
call load

beq t1, zero, y_loop
addi t1, t1, -1
jmpi x_loop

end_move_down:

add a0,zero,zero
add a1,zero,zero
add a2,zero,zero
call switch_line
call store
call draw_gsa
call load

ldw ra, 0(sp)
addi sp,sp,4
ret




switch_line:

addi sp,sp ,-4
stw ra, 0(sp)
add t0,zero,zero ;counter pour les x de la ligne
addi t1,zero,12 ; < que 11

switch_line_loop:
beq t0, t1,switch_line_fin
add a0, zero,t0 ;faut que changer la valeur des x

addi sp,sp,-4
stw t0, 0(sp)
call store
call set_gsa
call load
ldw t0, 0(sp)
addi sp,sp,4
addi t0,t0,1
jmpi switch_line_loop

switch_line_fin:

ldw ra, 0(sp)
addi sp,sp,4
ret

; END:remove_full_line







; BEGIN:draw_tetromino

draw_tetromino:

addi sp, sp, -8
stw ra, 0(sp)
stw v0, 4(sp)

addi a2, a0, 0
ldw t0, T_type(r0); get type
slli t0, t0, 4 ; times 16
ldw t1, T_orientation(r0); get orientation
slli t1, t1, 2 ; times 4
add t0, t0, t1 ; add both

ldw t2, DRAW_Ax(t0); pos of x coordinates
ldw t3, DRAW_Ay(t0); pos of y coordinates
addi t7, r0, 3 ; counter

addi sp, sp, -12
stw t2, 0(sp)
stw t3, 4(sp)
stw t7, 8(sp)

loop_tetrominoz:

ldw t7, 8(sp)
ldw t3, 4(sp)
ldw t2, 0(sp)

beq t7, r0, finzz
addi t7, t7, -1 ; decrease counter
stw t7, 8(sp)
add t6, r0, t7 ; assign counter
slli t6, t6, 2 ; counter times 4 to compute next address offset
add t5, t6, t2 ; add offset to start of address of x
ldw t0, 0(t5); get x coordinate offset
add t5, t6, t3 ; add offset to the other address of y
ldw t1, 0(t5); get y coordinate offset
ldw t2, T_X(r0); get anchor x
ldw t3, T_Y(r0); get anchor y
add t0, t0, t2 ;add ofset x plus anchor x
add t1, t1, t3 ; add offset y plus anchor y
add a0, r0, t0 ; set second argument (x)
add a1, r0, t1 ; set third argument (y)



call store
call set_gsa
call load

jmpi loop_tetrominoz

finzz:
addi sp, sp, 12
ldw t2, T_X(r0); get anchor x
ldw t3, T_Y(r0); get anchor y
add a0, r0, t2 ; set second argument (x) for anchor
add a1, r0, t3 ; set third argument (y) for anchor

call store
call set_gsa
call load



ldw v0, 4(sp)
ldw ra, 0(sp)
addi sp, sp, 8
ret

; END:draw_tetromino


; BEGIN:rotate_tetromino

rotate_tetromino:
addi t0, zero, CLOCKWISE
beq a0, t0, rot_R

ldw t0, T_orientation(zero)
addi t1, r0, N
beq t0, t1 , set_west

addi t0, t0, -1
stw t0, T_orientation(r0)
ret

set_west:
addi t0, zero, W
stw t0, T_orientation(r0)
ret

rot_R:
ldw t0, T_orientation(zero)
addi t0, t0, 1
andi t0, t0, 0x3
stw t0, T_orientation(r0)
ret

; END:rotate_tetromino

; BEGIN:act
act:
addi sp, sp, -16
ldw t1, T_Y(r0)
stw t1, 0(sp) ;save tY on stack
ldw t1, T_X(r0)
stw t1, 4(sp) ;save tx on stack
ldw t1, T_orientation(r0)
stw t1, 8(sp) ;save tx on stack
stw ra, 12(sp)

addi v0, r0, 1


addi t0, r0, moveL
bne t0, a0, next

addi a0, r0, W_COL

call store
call detect_collision
call load

beq a0, v0, end_not_worked

ldw t1, T_X(r0)
addi t1, t1, -1
stw t1, T_X(r0)
addi v0, r0, 0
jmpi end1

next:

addi t0, r0, moveR
bne t0, a0, next1

addi a0, r0, E_COL

call store
call detect_collision
call load

beq a0, v0, end_not_worked

ldw t1, T_X(r0)
addi t1, t1, 1
stw t1, T_X(r0)
addi v0, r0, 1
jmpi end1

next1:

addi t0, r0, moveD
bne t0, a0, next2
addi a0, r0, So_COL
call store
call detect_collision
call load
beq a0, v0, end_not_worked
ldw t1, T_Y(r0)
addi t1, t1, 1
stw t1, T_Y(r0)
addi v0, r0, 0
jmpi end1

next2:

addi t0, r0, reset
bne t0, a0, next3
call store
call reset_game
call load
addi v0, r0, 0
jmpi end1

next3: ;its rotation need to save current rotation state

addi a0, a0, -8 ;
call rotate_tetromino

addi t0, r0, 1 ; max move counter if overlap
addi a0, r0, OVERLAP
call store
call detect_collision
call load
beq a0, v0, move ; if overlaps
addi v0, r0, 0 ; v0 = 0 because succeded
jmpi end1

move:
addi t1, r0, moveR
ldw t2, T_X(r0) ;current x coordinate ;check if should move right or left
addi t3, r0, 6
blt t2, t3, compute ;check if moveleft or moverright
addi t1, r0, moveL

compute:
addi t3, t0, -3 ;if t0 = 3
beq t3, r0, not_work

cmpeqi t5, t1, moveL
bne t5, r0, update_y

update_x: ;update x coordintae +1 or +2
add t3, t2, t0
stw t3, T_X(r0)
jmpi continue

update_y:  ;update x coordintae -1 or -2
sub t3, t2, t0
stw t3, T_X(r0)

continue:

addi t0, t0, 1
addi a0, r0, OVERLAP

call store
call detect_collision
call load

;cmpeqi t3, t0, 3 ;remove!!!!!
;bne t3, r0, end1  ;remove!!!!!

bne v0, a0, end1
jmpi compute


not_work:

addi v0, zero, 1
ldw t1, 0(sp)
ldw t2, 4(sp)
ldw t3, 8(sp)
stw t1, T_Y(r0)
stw t2, T_X(r0)
stw t3, T_orientation(r0)

end_not_worked:
addi v0, zero, 1

end1:

ldw ra, 12(sp)
addi sp, sp, 16
ret


; END:act

; BEGIN:reset_game

reset_game:

addi sp, sp, -4
stw ra, 0(sp)


stw zero, SCORE(zero)
call display_score


call generate_tetromino

add t0,zero, zero ; counter pour les x
add t1,zero,zero ; counter pour les y
addi t2, zero, 12
addi t3, zero, 8
add a2, zero, zero ;pour mettre des 0 partout

zero_loop:
beq t0, t2, zero_next_line
beq t1, t3, zero_loop_fin
add a0,zero,t0
add a1,t1,zero

call store
call set_gsa
call load

addi t0, t0,1
jmpi zero_loop

zero_next_line:
add t0,zero,zero
addi t1,t1,1
jmpi zero_loop

zero_loop_fin:

addi a0,zero,FALLING

call store
call draw_tetromino
call load

call store
call draw_gsa
call load

ldw ra, 0(sp)
addi sp,sp,4

ret

; END:reset_game






; BEGIN:detect_full_line

detect_full_line:

addi sp,sp,-4
stw ra ,0(sp)


add t1, zero,zero ;counter pour les y
add t0, zero, zero ; counter pour les x

addi t2, zero, 8 ;pour tester y
addi t3, zero ,12 ; pour tester x
addi t4, zero,11

add v0,zero,t2

detect_loop:

beq t0, t3,detect_loop_fin
beq t1,t2, detect_fin

add a0, zero, t0 ;met x
add a1,zero ,t1 ;met y

add t5,zero,v0
call store
call get_gsa ;get current state
call load
add  t6, v0,zero
add v0,t5,zero
addi t7 , zero, PLACED
bne t6, t7, detect_loop_fin ;s'il y a rien change de ligne

beq t0, t4, update_full_line ;si le dernier bit est 1 on retourne la ligne

addi t0, t0, 1
jmpi detect_loop


detect_loop_fin:

add t0,zero,zero
addi t1,t1,1
jmpi detect_loop

update_full_line:
add v0,zero,t1

jmpi detect_fin

detect_fin:


ldw ra, 0(sp)
addi sp,sp,4
ret

; END:detect_full_line


; BEGIN:get_input

get_input:

ldw t0, BUTTONS + 4(r0); get value in buttons
andi t0, t0, 0x1F ; get last 5 bits
add v0,r0, r0 ;set v0 to zero
beq t0, r0, end_ ; finidh if t0 = zero

andi t1, t0, 0x01
addi v0, r0, moveL
bne t1, r0, end_

srli t0, t0, 1 ;shift t0
andi t1, t0, 0x01 ;get msb
addi v0, r0, rotL
bne t1, r0, end_ ;check if one

srli t0, t0, 1
andi t1, t0, 0x01
addi v0, r0, reset
bne t1, r0, end_

srli t0, t0, 1
andi t1, t0, 0x01
addi v0, r0, rotR
bne t1, r0, end_

addi v0, r0, moveR
bne t1, r0, end_

end_:
stw r0, BUTTONS + 4(r0)
ret

; END:get_input


; BEGIN:increment_score

increment_score:
ldw t0, SCORE(r0)


addi t1, t0, 0
andi t2, t1, 0xFF
cmpeqi t3, t2, 9 ;if equal to 9
bne t3, zero, next_ ;if true
addi t1, t1, 1
stw t1, SCORE(r0)

jmpi fin__

next_:

srli t2, t0, 8 ; shift by 8 to the right
andi t2, t2, 0xFF ; get last byte
cmpeqi t3, t2, 9 ;if equal to 9
bne t3, zero, next_2
srli t2, t0, 8 ; shift by 8 to the right
addi t2, t2, 1
slli t2, t2, 8
stw t2, SCORE(r0)
jmpi fin__


next_2:

srli t2, t0, 16  ; shift by 16 to the right
andi t2, t2, 0xFF ; get last byte
cmpeqi t3, t2,  9 ;if equal to 9
bne t3, zero, next_3
srli t2, t0, 16 ; shift by 8 to the right
addi t2, t2, 1
slli t2, t2, 16
stw t2, SCORE(r0)
jmpi fin__

next_3:

srli t2, t0, 24; shift by 24 to the right
andi t2, t2, 0xFF; get last byte
cmpeqi t3, t2,  9 ;if equal to 9
bne t3, zero, fin__
srli t2, t0, 24 ; shift by 8 to the right
addi t2, t2, 1
slli t2, t2, 24
stw t2, SCORE(r0)

fin__:
ret

; END:increment_score

; BEGIN:display_score

display_score:

ldw t0,font_data(zero)


ldw t1, SCORE(r0)

andi t2, t1, 0xFF
slli t2,t2, 2
ldw t3, font_data(t2)
stw t3, SEVEN_SEGS + 12(r0)

srli t1, t1, 8
andi t2, t1, 0xFF
slli t2,t2, 2
ldw t3, font_data(t2)
stw t3, SEVEN_SEGS + 8(r0)

srli t1, t1, 8
andi t2, t1, 0xFF
slli t2,t2, 2
ldw t3, font_data(t2)
stw t3, SEVEN_SEGS + 4(r0)

srli t1, t1, 8
andi t2, t1, 0xFF
slli t2,t2, 2
ldw t3, font_data(t2)
stw t3, SEVEN_SEGS(r0)

ret

; END:display_score





font_data:
    .word 0xFC  ; 0
    .word 0x60  ; 1
    .word 0xDA  ; 2
    .word 0xF2  ; 3
    .word 0x66  ; 4
    .word 0xB6  ; 5
    .word 0xBE  ; 6
    .word 0xE0  ; 7
    .word 0xFE  ; 8
    .word 0xF6  ; 9

C_N_X:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

C_N_Y:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0xFFFFFFFF

C_E_X:
  .word 0x01
  .word 0x00
  .word 0x01

C_E_Y:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

C_So_X:
  .word 0x01
  .word 0x00
  .word 0x01

C_So_Y:
  .word 0x00
  .word 0x01
  .word 0x01

C_W_X:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0xFFFFFFFF

C_W_Y:
  .word 0x00
  .word 0x01
  .word 0x01

B_N_X:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0x02

B_N_Y:
  .word 0x00
  .word 0x00
  .word 0x00

B_E_X:
  .word 0x00
  .word 0x00
  .word 0x00

B_E_Y:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0x02

B_So_X:
  .word 0xFFFFFFFE
  .word 0xFFFFFFFF
  .word 0x01

B_So_Y:
  .word 0x00
  .word 0x00
  .word 0x00

B_W_X:
  .word 0x00
  .word 0x00
  .word 0x00

B_W_Y:
  .word 0xFFFFFFFE
  .word 0xFFFFFFFF
  .word 0x01

T_N_X:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

T_N_Y:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0x00

T_E_X:
  .word 0x00
  .word 0x01
  .word 0x00

T_E_Y:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

T_So_X:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

T_So_Y:
  .word 0x00
  .word 0x01
  .word 0x00

T_W_X:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0x00

T_W_Y:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

S_N_X:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

S_N_Y:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

S_E_X:
  .word 0x00
  .word 0x01
  .word 0x01

S_E_Y:
  .word 0xFFFFFFFF
  .word 0x00
  .word 0x01

S_So_X:
  .word 0x01
  .word 0x00
  .word 0xFFFFFFFF

S_So_Y:
  .word 0x00
  .word 0x01
  .word 0x01

S_W_X:
  .word 0x00
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

S_W_Y:
  .word 0x01
  .word 0x00
  .word 0xFFFFFFFF

L_N_X:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0x01

L_N_Y:
  .word 0x00
  .word 0x00
  .word 0xFFFFFFFF

L_E_X:
  .word 0x00
  .word 0x00
  .word 0x01

L_E_Y:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0x01

L_So_X:
  .word 0xFFFFFFFF
  .word 0x01
  .word 0xFFFFFFFF

L_So_Y:
  .word 0x00
  .word 0x00
  .word 0x01

L_W_X:
  .word 0x00
  .word 0x00
  .word 0xFFFFFFFF

L_W_Y:
  .word 0x01
  .word 0xFFFFFFFF
  .word 0xFFFFFFFF

DRAW_Ax:                        ; address of shape arrays, x axis
    .word C_N_X
    .word C_E_X
    .word C_So_X
    .word C_W_X
    .word B_N_X
    .word B_E_X
    .word B_So_X
    .word B_W_X
    .word T_N_X
    .word T_E_X
    .word T_So_X
    .word T_W_X
    .word S_N_X
    .word S_E_X
    .word S_So_X
    .word S_W_X
    .word L_N_X
    .word L_E_X
    .word L_So_X
    .word L_W_X

DRAW_Ay:                        ; address of shape arrays, y_axis
    .word C_N_Y
    .word C_E_Y
    .word C_So_Y
    .word C_W_Y
    .word B_N_Y
    .word B_E_Y
    .word B_So_Y
    .word B_W_Y
    .word T_N_Y
    .word T_E_Y
    .word T_So_Y
    .word T_W_Y
    .word S_N_Y
    .word S_E_Y
    .word S_So_Y
    .word S_W_Y
    .word L_N_Y
    .word L_E_Y
    .word L_So_Y
    .word L_W_Y



