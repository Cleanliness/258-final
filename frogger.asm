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
testColor: .word 0x00ff0000
testColor2: .word 0x00ffff00
testPos: .word 120
testarr: .word 0x00ff00, 0x0000ff


.text

main: # entry point

	li $t0, 30 # t0 = x = 2
	li $t1, 10 # t1 = y = 10
	li $t3, 10 # t3 = height = 5
	li $t2, 5 # t2 = width = 5
	li $t4, 0x00ff0000 # t4 = color = red
	
	# push function arguments on stack
	sw $t0 0($sp)
	sw $t1 -4($sp)
	sw $t2 -8($sp)
	sw $t3 -12($sp)
	sw $t4 -16($sp)
	addi $sp, $sp, -16
	jal drawRect

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
	lw $a0 0($sp) # a0 = color
	lw $a1 4($sp) # a1 = width
	lw $a2 8($sp) # a2 = height
	lw $a3 12($sp) # a3 = y coord
	lw $t0 16($sp) # t0 = x coord
	addi $sp, $sp, 20 # decrease stack size
	
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
	
	
