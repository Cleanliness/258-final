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
displayAddress: .word 0x10008000
grassColor: .word 0x004caf4f
roadColor: .word 0x009e9e9e
waterColor: .word 0x002195f3
frogColor: .word 0x00ccdc39
carColor: .word 0x00d50000
tireColor: .word 0x00000000

.text
main: # entry point
	jal drawScene
	
	# --------- drawing logs -------------
	# log 1
	li $t0, 15 # x
	li $t1, 12 # y
	li $t2, 12 # width
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawLog
	
	# log 2
	li $t0, 2 # x
	li $t1, 12 # y
	li $t2, 8 # width
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawLog
	
	# log 3
	li $t0, 8 # x
	li $t1, 8 # y
	li $t2, 8 # width
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawLog
	
	# log 4
	li $t0, 12 # x
	li $t1, 4 # y
	li $t2, 8 # width
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawLog
	
	# ------------ drawing cars --------------
	# car 1
	li $t0, 20 # x
	li $t1, 20 # y
	li $t2, 0x00ff0000# color
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawCar
	
	# car 2
	li $t0, 3 # x
	li $t1, 20 # y
	li $t2, 0x00ff0000# color
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawCar
	
	# car 3
	li $t0, 13 # x
	li $t1, 24 # y
	li $t2, 0x00ff0000# color
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	addi $sp, $sp, -12
	jal drawCar


Exit:
li $v0, 10 # terminate the program gracefully
syscall

procedure:
# test procedure a0 = color
	lw $t9, displayAddress
	sw $a0, 32($t9)
	jr $ra # return

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
			sll $t4, $t2, 7 # t4 = curr y*128
			add $t5, $t3, $t4 # t5 = raw position of pixel
			sll $t3, $t0, 2 # t3 = x coord*4
			sll $t4, $a3, 7 # t4 = y coord*128
			
			# adding x and y coords to offsets
			add $t5, $t5, $t3
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
		
	addi $sp, $sp, 8 # decrease stack size
	
	jr $ra # return from draw car
	
	