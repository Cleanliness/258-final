# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.data

# global variables
displayAddress: .word 0x10008000
grassColor: .word 0x004caf4f
roadColor: .word 0x009e9e9e
waterColor: .word 0x002195f3
frogColor: .word 0x00ccdc39
carColor: .word 0x00d50000
tireColor: .word 0x00000000

# ===========================================
# =--------------- game data ---------------=
# ===========================================
gameclock: .word 0 # counter of how many ticks

# hazard speeds
lane1Speed: .word 1 # road lower
lane2Speed: .word -1 # road top
lane3Speed: .word 1 # log bottom
lane4Speed: .word -1 # log mid
lane5Speed: .word 1 # log top

# x position of hazards
lane1x: .word 10
lane2x: .word 3
lane3x: .word 2
lane4x: .word 10
lane5x: .word 15

# finish zones occupied? 1 = yes, 0 = no
fz1_full: .word 0
fz2_full: .word 0
fz3_full: .word 0
fz4_full: .word 0

# frog data
frogx: .word 14
frogy: .word 28 # starting position
lives: .word 3 # number of lives
completed: .word 0 # num frogs reached finish point

.text
main: # entry point
	# ------ handle keyboard input for frog -----
	lw $t8, 0xffff0000
	beq $t8, 1, handle_input
	
	# check if frog is in completion region
	jal check_completed
	
	# update game clock
	lw $t0, gameclock # ticks
	la $t3, gameclock # address
	addi $t1, $t0, 1 # ticks += 1
	sw $t1 0($t3) # write value
	
	# check for every fifth tick
	li $t0 5
	div $t1, $t0 # ticks mod 5
	mfhi $t1
	beq $t1, $zero, update_environment
	
	# sleep
	li $v0, 32
	li $a0, 30
	syscall
	
	j main # game loop
	
	# ============== update environment ================
	update_environment:
	jal drawScene
	
	li $t0, 32 # screen width
	
	# update lane 1 position
	la $t3, lane1x # address
	lw $t1, lane1x # lane 1
	lw $t2, lane1Speed # add speed
	add $t1, $t1, $t2
	div $t1, $t0 # x mod 32
	mfhi $t1
	sw $t1 0($t3)
	
	# update lane 2 position
	lw $t1, lane2x # lane 1
	la $t3, lane2x # address
	lw $t2, lane2Speed
	add $t1, $t1, $t2
	div $t1, $t0 # x mod 32
	mfhi $t1
	sw $t1 0($t3)

	# update lane 3 position
	lw $t1, lane3x # lane 1
	la $t3, lane3x # address
	lw $t2, lane3Speed
	add $t1, $t1, $t2
	div $t1, $t0 # x mod 32
	mfhi $t1
	sw $t1 0($t3) 

	# update lane 4 position
	lw $t1, lane4x # lane 1
	la $t3, lane4x # address
	lw $t2, lane4Speed
	add $t1, $t1, $t2
	div $t1, $t0 # x mod 32
	mfhi $t1
	sw $t1 0($t3)

 	# update lane 5 position
	lw $t1, lane5x # lane 1
	la $t3, lane5x # address
	lw $t2, lane5Speed
	add $t1, $t1, $t2
	div $t1, $t0 # x mod 32
	mfhi $t1
	sw $t1 0($t3)
	
		
	# ---- drawing logs ----
	lw $t0, lane3x # x1
	lw $t1, lane4x # x2
	lw $t2, lane5x # x3
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawLogs
	
	# ------------ drawing cars --------------
	lw $t0, lane1x # x1
	lw $t1, lane2x # x2
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	addi $sp, $sp, -8
	jal drawCars
	
	# ------ draw frog -------
	lw $t0, frogx # x
	lw $t1, frogy # y
	li $t2, 0x00ccdc39 # color
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawFrog
	
	# ==== UI elements ====
	jal drawLives
	
	j main # game loop
Exit:
li $v0, 10 # terminate the program gracefully
syscall

check_completed: # check_completed() -> null
# check if the frog reached a valid completion region
	
	# --- check if frog y is valid ---
	la $t3, frogy
	lw $t0, frogy
					
	li $t2, 4 # t2 = completion region y
	blt $t0, $t2, check_completion_x # if frog y < 4, check x

	end_check_completed:
	jr $ra # return from check_completed()
	
	check_completion_x: # check if frog x is valid
		la $t3, frogx
		lw $t0, frogx
		
		# check left x coordinates in finish zones
		# ----- finish zone 1 -----
		li $t2, 1 # t2 = 1
		bge $t0, $t2, check_fz1 # if frog x >= 1
		not_fz1: # jump here if frog not in fz1
		
		# ----- finish zone 2 -----
		li $t2, 9 
		bge $t0, $t2, check_fz2 # if frog x >= 9
		not_fz2: # jump here if frog not in fz2
		
		# ----- finish zone 3 -----
		li $t2, 17
		bge $t0, $t2, check_fz3 # if frog x >= 17
		not_fz3: # jump here if frog not in fz2
		
		# ----- finish zone 4 -----
		li $t2, 25
		bge $t0, $t2, check_fz4 # if frog x >= 25
		not_fz4: # jump here if frog not in fz2
		
		# reached if in x is no finish zones
		j reduce_lives
		
		# check right x coordinates in finish zones
		check_fz1:
			li $t2, 3
			ble $t0, $t2, in_fz1 # if x <= 4, then frog is in fz1
			j not_fz1
		
		check_fz2:
			li $t2, 11
			ble $t0, $t2, in_fz2 # if x <= 11, then frog is in fz2
			j not_fz2

		check_fz3:
			li $t2, 19
			ble $t0, $t2, in_fz3 # if x <= 19, then frog is in fz3
			j not_fz3
			
		check_fz4:
			li $t2, 27
			ble $t0, $t2, in_fz4 # if x <= 19, then frog is in fz3
			j not_fz4
					
		# ------- update game data if in FZ -------
		in_fz1: # frog in finish zone 1 = true
			lw, $t0, fz1_full
			la, $t1, fz1_full
			li $t2, 1
			beq $t0, $t2, reduce_lives # lose life if zone occupied
			li $t0, 1 # otherwise mark zone as occupied
			sw $t0, 0($t1)
			j reset_frog_pos
		
		in_fz2: # frog in finish zone 2 = true
			lw, $t0, fz2_full
			la, $t1, fz2_full
			li $t2, 1
			beq $t0, $t2, reduce_lives # lose life if zone occupied
			li $t0, 1 # otherwise mark zone as occupied
			sw $t0, 0($t1)
			j reset_frog_pos
			
		in_fz3: # frog in finish zone 3 = true
			lw, $t0, fz3_full
			la, $t1, fz3_full
			li $t2, 1
			beq $t0, $t2, reduce_lives # lose life if zone occupied
			li $t0, 1 # otherwise mark zone as occupied
			sw $t0, 0($t1)
			j reset_frog_pos
		
		in_fz4: # frog in finish zone 4 = true
			lw, $t0, fz4_full
			la, $t1, fz4_full
			li $t2, 1
			beq $t0, $t2, reduce_lives # lose life if zone occupied
			li $t0, 1 # otherwise mark zone as occupied
			sw $t0, 0($t1)
			j reset_frog_pos
		
		reduce_lives: # reduce number of frog lifes
			lw $t0, lives
			la $t1, lives
			
			addi $t0, $t0, -1
			sw $t0, 0($t1)
			
		reset_frog_pos: # reset frog position
			li $t3, 14 # x
			la $t0, frogx
			
			li $t4, 28 # y
			la $t5, frogy
			
			# reset frog position to initial
			sw $t3, 0($t0) # x
			sw $t4, 0($t5) # y
			j end_check_completed
			
handle_input: # handle_input() -> null
# handle's user keyboard input for the game. Assume that a key has already been pressed
	lw $t2, 0xffff0004 # t2 = keyboard value
	li $t4, 32 #t4 = 32
	beq $t2, 0x61, respond_to_A # check if 'a' is pressed
	beq $t2, 0x73, respond_to_S  # check if 's' is pressed
	beq $t2, 0x77, respond_to_W  # check if 'w' is pressed
	beq $t2, 0x64, respond_to_D  # check if 'D' is pressed
	end_handle_input:
	jr $ra # return from handle_input
	
	# ------ movement buttons pressed ------
	respond_to_A: # go left
		la $t3 frogx
		lw $t0 frogx
		
		li $t2 4 # t2 = frog width
		blt $t0, $t2 x_left_overflow # if frogx < t2
	
		addi $t0, $t0, -4 # x -= 4
		div $t0, $t4 # x mod 32
		mfhi $t0
		sw $t0, 0($t3) # update frogx
		j end_handle_input
		
		x_left_overflow: # handle frog x going too far left
			li $t4, 0
			sw $t4, 0($t3)
			j end_handle_input
	
	respond_to_S: # go down
		la $t3 frogy
		lw $t0 frogy
					
		li $t2 28 # t2 = starting y
		bge $t0, $t2 y_down_overflow # if frog y >= 28
	
		addi $t0, $t0, 4 # y += 4
		divu $t0, $t4 # x mod 32
		mfhi $t0
		sw $t0, 0($t3) # update frog y
		j end_handle_input

		
		y_down_overflow: # handle frog x going too far down
			li $t4, 28
			sw $t4, 0($t3)
			j end_handle_input
		
	respond_to_W: # go up
		la $t3 frogy
		lw $t0 frogy
	
		addi $t0, $t0, -4 # y -= 4
		divu $t0, $t4 # x mod 32
		mfhi $t0
		sw $t0, 0($t3) # update frog y
		j end_handle_input
	
	respond_to_D: # go right
		la $t3 frogx
		lw $t0 frogx
		
		li $t2 24 # t2 = 24
		bgt $t0, $t2 x_right_overflow # if frogx > t2
	
		addi $t0, $t0, 4 # x -= 4
		div $t0, $t4 # x mod 32
		mfhi $t0
		sw $t0, 0($t3) # update frog x
		j end_handle_input
		
		x_right_overflow: # handle frog x going too far right
			li $t4, 28
			sw $t4, 0($t3)
			j end_handle_input
	
drawRect: # drawRect(x, y, height, width, color) -> null
# draw a rectangle given top left point, height, width, color

	# initialization
	addi $sp, $sp, 4
	lw $a0 0($sp) # a0 = color
	lw $a1 4($sp) # a1 = width
	lw $a2 8($sp) # a2 = height
	lw $a3 12($sp) # a3 = y coord
	lw $t0 16($sp) # t0 = x coord
	addi $sp, $sp, 16 # decrease stack size
	
	li $t2, 0 # t2 = current pixel y
	li $t1, 0 # t1 = current pixel x
	lw $t6, displayAddress # t6 = displayAddress
	
	
	rect_row_loop: # for each row
		beq $t2, $a2, rect_row_loop_end # if curr y = height: end
		li $t1, 0 # reset curr x
		rect_pix_loop: # for each pixel
			beq $t1, $a1, rect_pix_loop_end # if curr x = width: end
			sll $t3, $t1, 2 # t3 = curr x*4
			sll $t7, $t0, 2 # t7 = x coord*4 (get x offset)
			add $t3, $t3, $t7 # add offset to curr x
			li $t7 128 # t7 = 128
			divu $t3, $t7 # x mod 128
			mfhi $t3 # get result of x mod 128
			sll $t4, $t2, 7 # t4 = curr y*128
			add $t5, $t3, $t4 # t5 = raw position of pixel
			sll $t4, $a3, 7 # t4 = y coord*128
			
			# adding x and y coords to offsets
			add $t5, $t5, $t4
			
			add $t5, $t6, $t5 # add pos to display address
			sw $a0, 0($t5) # draw pixel at position
			addi $t1, $t1, 1 # curr x += 1
			j rect_pix_loop
		rect_pix_loop_end: # end of pixel loop
		addi $t2, $t2, 1 # curr y += 1
		j rect_row_loop
	
	rect_row_loop_end: # end of row loop
	jr $ra # return from draw rect


drawLives: # draw number of lives remaining
	
	# push return address
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
	# ====== draw lives as a rect =====
	li $t0, 0 # x
	li $t1, 30 # y
	lw $t3, lives # width
	li $t2, 1 # height
	li $t4, 0x0000ff00 # color
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	sw $t3 -12($sp)
	sw $t4 -16($sp)
	addi $sp, $sp, -20
	jal drawRect
	
	# retrieve return address
	addi $sp, $sp, 4
	lw $ra 0($sp)
	jr $ra
drawScene: # draws background objects of game

	# push return address
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
	# ---- drawing lower safe point ----
	li $t0, 0 # x
	li $t1, 28 # y
	li $t3, 32 # width
	li $t2, 4 # height
	li $t4, 0x004caf4f # color
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	sw $t3 -12($sp)
	sw $t4 -16($sp)
	addi $sp, $sp, -20
	jal drawRect
	
	# ---- drawing middle safe point ----
	li $t0, 0 # x
	li $t1, 16 # y
	li $t3, 32 # width
	li $t2, 4 # height
	li $t4, 0x004caf4f # color
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	sw $t3 -12($sp)
	sw $t4 -16($sp)
	addi $sp, $sp, -20
	jal drawRect
	
	# ---- drawing road ----
	li $t0, 0 # x
	li $t1, 20 # y
	li $t3, 32 # width
	li $t2, 8 # height
	li $t4, 0x009e9e9e # color
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	sw $t3 -12($sp)
	sw $t4 -16($sp)
	addi $sp, $sp, -20
	jal drawRect
	
	# ---- drawing water ----
	li $t0, 0 # x
	li $t1, 0 # y
	li $t3, 32 # width
	li $t2, 16 # height
	li $t4, 0x002195f3 # color
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	sw $t3 -12($sp)
	sw $t4 -16($sp)
	addi $sp, $sp, -20
	jal drawRect
	
	# ---- drawing finish zones ----
	li $t0, 2 # x
	li $t1, 0 # y
	li $t3, 4 # width
	li $t2, 4 # height
	li $t4, 0x004caf4f # color
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	sw $t3 -12($sp)
	sw $t4 -16($sp)
	addi $sp, $sp, -20
	jal drawRect
	
	li $t0, 10 # x
	li $t1, 0 # y
	li $t3, 4 # width
	li $t2, 4 # height
	li $t4, 0x004caf4f # color
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	sw $t3 -12($sp)
	sw $t4 -16($sp)
	addi $sp, $sp, -20
	jal drawRect

	li $t0, 18 # x
	li $t1, 0 # y
	li $t3, 4 # width
	li $t2, 4 # height
	li $t4, 0x004caf4f # color
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	sw $t3 -12($sp)
	sw $t4 -16($sp)
	addi $sp, $sp, -20
	jal drawRect

	li $t0, 26 # x
	li $t1, 0 # y
	li $t3, 4 # width
	li $t2, 4 # height
	li $t4, 0x004caf4f # color
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	sw $t3 -12($sp)
	sw $t4 -16($sp)
	addi $sp, $sp, -20
	jal drawRect
	
	# ------ draw frogs in finish zones -------
	
	# --finish zone 1--
	lw, $t0, fz1_full
	li $t2, 0
	beq $t0, $t2, skip_frog_in_fz1 # skip drawing if empty
	
	li $t0, 2 # x
	li $t1, 0 # y
	li $t2, 0x00ccdc39 # color
	
	# drawing fz1 frog
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawFrog
	skip_frog_in_fz1:
	
	# --finish zone 2--
	lw, $t0, fz2_full
	li $t2, 0
	beq $t0, $t2, skip_frog_in_fz2 # skip drawing if empty
	
	li $t0, 10 # x
	li $t1, 0 # y
	li $t2, 0x00ccdc39 # color
	
	# drawing fz2 frog
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawFrog
	skip_frog_in_fz2:
	
	# --finish zone 3--
	lw, $t0, fz3_full
	li $t2, 0
	beq $t0, $t2, skip_frog_in_fz3 # skip drawing if empty
	
	li $t0, 18 # x
	li $t1, 0 # y
	li $t2, 0x00ccdc39 # color
	
	# drawing fz3 frog
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawFrog
	skip_frog_in_fz3:
	
	# --finish zone 4--
	lw, $t0, fz4_full
	li $t2, 0
	beq $t0, $t2, skip_frog_in_fz4 # skip drawing if empty
	
	li $t0, 26 # x
	li $t1, 0 # y
	li $t2, 0x00ccdc39 # color
	
	# drawing fz4 frog
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawFrog
	skip_frog_in_fz4:
	
	end_draw_scene:
	# retrieve return address
	addi $sp, $sp, 4
	lw $ra 0($sp)
	jr $ra # return from draw scene

drawCar: # drawCar(x, y, color) -> null
# draw a car given x y position and color

	# initialization
	addi $sp, $sp, 4
	lw $a0 0($sp) # color
	lw $a1 4($sp) # y coord
	lw $a2 8($sp) # x coord
	
	# push return address
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
	# ---- drawing body ----
	addi $t1, $a1, 1 # y
	li $t3, 6 # width
	li $t2, 2 # height
	
	sw $a2 0($sp) # x
	sw $t1 -4($sp) # y
	sw $t2 -8($sp) # height
	sw $t3 -12($sp) # width
	sw $a0 -16($sp) # color
	addi $sp, $sp, -20
	jal drawRect
	
	# ---- drawing tires ----
	# reload x and y from stack
	lw $a1 8($sp) # y coord
	lw $a2 12($sp) # x coord
	
	# top left
	li $t3, 2 # width
	li $t2, 1 # height
	li $t4, 0x00000000 # color
	
	sw $a2 0($sp) # x
	sw $a1 -4($sp) # y
	sw $t2 -8($sp) # height
	sw $t3 -12($sp) # width
	sw $t4 -16($sp) # color
	addi $sp, $sp, -20
	jal drawRect
	
	# reload x and y from stack
	lw $a1 8($sp) # y coord
	lw $a2 12($sp) # x coord
	
	# reload x and y from stack
	addi $t0, $a2, 4
	li $t3, 2 # width
	li $t2, 1 # height
	li $t4, 0x00000000 # color
	
	sw $t0 0($sp) # x
	sw $a1 -4($sp) # y
	sw $t2 -8($sp) # height
	sw $t3 -12($sp) # width
	sw $t4 -16($sp) # color
	addi $sp, $sp, -20
	jal drawRect
	
	# reload x and y from stack
	lw $a1 8($sp) # y coord
	lw $a2 12($sp) # x coord
	
	# bottom right
	addi $t0, $a2, 4 # x
	addi $t1, $a1, 3 # y
	li $t3, 2 # width
	li $t2, 1 # height
	li $t4, 0x00000000 # color
	
	sw $t0 0($sp) # x
	sw $t1 -4($sp) # y
	sw $t2 -8($sp) # height
	sw $t3 -12($sp) # width
	sw $t4 -16($sp) # color
	addi $sp, $sp, -20
	jal drawRect
	
	# reload x and y from stack
	lw $a1 8($sp) # y coord
	lw $a2 12($sp) # x coord
	
	# bottom left
	addi $t1, $a1, 3 # y
	li $t3, 2 # width
	li $t2, 1 # height
	li $t4, 0x00000000 # color
	
	sw $a2 0($sp) # x
	sw $t1 -4($sp) # y
	sw $t2 -8($sp) # height
	sw $t3 -12($sp) # width
	sw $t4 -16($sp) # color
	addi $sp, $sp, -20
	jal drawRect

	
	# pop return address
	addi $sp, $sp, 4
	lw $ra 0($sp)
		
	addi $sp, $sp, 8 # decrease stack size
	
	jr $ra # return from draw car

drawLog: # drawLog(x, y, width) -> null
# draw a log given x y position and width

	# initialization
	lw $a1 8($sp) # y coord
	lw $a2 12($sp) # x coord
	lw $a3 4($sp) # width
	
	# push return address
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
	# ---- drawing edges ----
	li $t9, 0x00543d36 # color
	li $t3, 12 # width
	li $t2, 4 # height
	
	sw $a2 0($sp) # x
	sw $a1 -4($sp) # y
	sw $t2 -8($sp) # height
	sw $a3 -12($sp) # width
	sw $t9 -16($sp) # color
	addi $sp, $sp, -20
	jal drawRect
		
	# ---- drawing body ----
	# reload x and y from stack
	lw $a1 12($sp) # y coord
	lw $a2 16($sp) # x coord
	lw $a3 8($sp) # width
	add $a1, $a1, 1 # y += 1
	
	li $t2, 2
	li $t3, 12
	li $t9, 0x00795548
	
	sw $a2 0($sp) # x
	sw $a1 -4($sp) # y
	sw $t2 -8($sp) # height
	sw $a3 -12($sp) # width
	sw $t9 -16($sp) # color
	addi $sp, $sp, -20
	jal drawRect
	
	# pop return address
	addi $sp, $sp, 4
	lw $ra 0($sp)
		
	addi $sp, $sp, 12 # decrease stack size
	
	jr $ra # return from draw log
	
drawFrog: # drawFrog(x, y, color) -> null
# draw a frog given x y position and color

	# initialization
	addi $sp, $sp, 4
	lw $a0 0($sp) # color
	lw $a1 4($sp) # y coord
	lw $a2 8($sp) # x coord
	
	# push return address
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
	# ---- drawing body ----
	addi $t1, $a1, 1 # y
	addi $t4, $a2, 1 # x
	li $t3, 2 # width
	li $t2, 2 # height
	
	sw $t4 0($sp) # x
	sw $t1 -4($sp) # y
	sw $t2 -8($sp) # height
	sw $t3 -12($sp) # width
	sw $a0 -16($sp) # color
	addi $sp, $sp, -20
	jal drawRect
	
	# ---- drawing legs ----
	# reload x and y from stack
	lw $a1 8($sp) # y coord
	lw $a2 12($sp) # x coord
	
	# top left
	li $t3, 1 # width
	li $t2, 1 # height
	
	sw $a2 0($sp) # x
	sw $a1 -4($sp) # y
	sw $t2 -8($sp) # height
	sw $t3 -12($sp) # width
	sw $a0 -16($sp) # color
	addi $sp, $sp, -20
	jal drawRect
	
	# reload x and y from stack
	lw $a1 8($sp) # y coord
	lw $a2 12($sp) # x coord
	
	# reload x and y from stack
	addi $t0, $a2, 3
	li $t3, 1 # width
	li $t2, 1 # height
	
	sw $t0 0($sp) # x
	sw $a1 -4($sp) # y
	sw $t2 -8($sp) # height
	sw $t3 -12($sp) # width
	sw $a0 -16($sp) # color
	addi $sp, $sp, -20
	jal drawRect
	
	# reload x and y from stack
	lw $a1 8($sp) # y coord
	lw $a2 12($sp) # x coord
	
	# bottom right
	addi $t0, $a2, 3 # x
	addi $t1, $a1, 2 # y
	li $t3, 1 # width
	li $t2, 2 # height
	
	sw $t0 0($sp) # x
	sw $t1 -4($sp) # y
	sw $t2 -8($sp) # height
	sw $t3 -12($sp) # width
	sw $a0 -16($sp) # color
	addi $sp, $sp, -20
	jal drawRect
	
	# reload x and y from stack
	lw $a1 8($sp) # y coord
	lw $a2 12($sp) # x coord
	
	# bottom left
	addi $t1, $a1, 2 # y
	li $t3, 1 # width
	li $t2, 2 # height
	
	sw $a2 0($sp) # x
	sw $t1 -4($sp) # y
	sw $t2 -8($sp) # height
	sw $t3 -12($sp) # width
	sw $a0 -16($sp) # color
	addi $sp, $sp, -20
	jal drawRect

	
	# pop return address
	addi $sp, $sp, 4
	lw $ra 0($sp)
		
	addi $sp, $sp, 8 # decrease stack size
	
	jr $ra # return from draw car
	
drawLogs: # drawLogs(x1, x2, x3) -> None
# draw logs given x position of each lane

	# initialization
	
	# push return address
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
	# --------- lane 1 ----------			
	# lane 1 log 1 (left)
	lw $t0, 16($sp) # x1 from funct arg
	li $t1, 12 # y
	li $t2, 12 # width
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawLog
	
	# lane 1 log 2 (right)
	lw $t0, 16($sp) # x1 from funct arg
	addi $t0, $t0, 15
	li $t1, 12 # y
	li $t2, 8 # width
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawLog
	
	# --------- lane 2 ----------	
	# lane 2 log 1
	lw $t0, 12($sp) # x2 from funct arg
	li $t1, 8 # y
	li $t2, 8 # width
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawLog
	
	# lane 2 log 2
	lw $t0, 12($sp) # x2 from funct arg
	addi $t0, $t0, 18
	li $t1, 8 # y
	li $t2, 8 # width
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawLog

	# --------- lane 3 ----------	
	# lane 3 log 1
	lw $t0, 8($sp) # x3 from funct arg
	li $t1, 4 # y
	li $t2, 8 # width
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawLog
	
	# lane 3 log 2
	lw $t0, 8($sp) # x3 from funct arg
	addi $t0, $t0 12
	li $t1, 4 # y
	li $t2, 10 # width
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawLog
	
	# pop return address
	addi $sp, $sp, 4
	lw $ra 0($sp)
		
	addi $sp, $sp, 12 # decrease stack size
	
	jr $ra # return from draw logs

drawCars: #drawCars(x1, x2) -> null
# draw cars given x position of each lane

	# initialization
	# push return address
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
	# --------- lane 1 ----------
	# car 1 in lane 1
	lw $t0, 12($sp) # x1
	li $t1, 24 # y
	li $t2, 0x00ff0000# color
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawCar
	
	# car 2 in lane 1
	lw $t0, 12($sp) # x1
	addi $t0, $t0, 16 # offset of second car
	li $t1, 24 # y
	li $t2, 0x00ff0000# color
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawCar
	
	# --------- lane 2 ----------
	# car 1 in lane 2
	lw $t0, 8($sp) # x2
	li $t1, 20 # y
	li $t2, 0x00ff0000# color
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawCar
	
	# car 2 in lane 2
	lw $t0, 8($sp) # x2
	addi $t0, $t0, 12
	li $t1, 20 # y
	li $t2, 0x00ff0000# color
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawCar
	
	# pop return address
	addi $sp, $sp, 4
	lw $ra 0($sp)
		
	addi $sp, $sp, 8 # decrease stack size
	
	jr $ra # return from draw cars
	
	
