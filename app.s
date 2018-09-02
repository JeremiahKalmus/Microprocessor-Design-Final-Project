# Lab 6 - Test Application

	.data	# Data declaration section

Result:	.word	0

	.text

main:		# Start of code section

	add  $s0, $zero, $zero
	addi $s7, $zero, 0x1000
	sll  $s7, $s7, 16    
	addi $s2, $zero, 0x0888
line2:	sll  $s1, $s0, 2
	sll  $s1, $s1, 2  
	add  $s1, $s1, $s7       
	sll  $s2, $s2, 1       
	sw   $s0, 0($s1)
	sw   $s2, 4($s1)
	sll  $s3, $s2, 2   
	sw   $s3, 8($s1)
	sub  $s4, $s3, $s2
	sw   $s4, 12($s1)
	addi $s0, $s0, 1       
	addi $s5, $zero, 5   
	sub  $s6, $s5, $s0
	bne  $s6, $zero, line2
	lw   $s7, 0($s1)
stop:	beq  $zero, $zero, stop

# END OF PROGRAM