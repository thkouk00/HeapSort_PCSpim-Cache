.data
	A: .byte 6, 14, 2, 10, 3, 5, 1, 30, 8

.text
	.globl __start
__start:
	li $t0, 0x10010000		# address of A
	li $t1, 9				# number of elements of A				
	div $s1, $t1, 2			# length/2
	mflo $s2				# take div as index
	# addi $s5, $s2, -1		# register to retrieve s2
for:
	addi $s2, $s2, -1
	# add $s2, $s5, $zero
	blt $s2, $zero, end


	jal left_child			# offset of left child
	jal right_child			# offset of right child

	# j swap 
	jal swap
	j for
end:
	li $v0,10				# end
	syscall


swap:
	bge $t2, $t1, for					# if left child is out of bounds 

	add $s3, $t0, $s2					# address of A[i]
	lb $s4, ($s3)						# s4 = A[i] temp			
	
	add $t4, $t0, $t2					# address of A[i*2+1]
	lb $t5, ($t4)						# A[i*2+1], left child
	
	bge $t3, $t1, compare_left			# if right child is out of bounds

	add $t6, $t0, $t3					# address of A[i*2+2]
	lb $t7, ($t6)						# A[i*2+2], right child
	
	blt $t5, $t7, compare_left			# left child < right child
	j compare_right						# left child > right child

swap_ret_left:
	addiu $sp, $sp, -8
	sw $ra, ($sp)
	sw $s2, 4($sp)

	sub $s2, $t4, $t0
	jal heapify
	j for

swap_ret_right:
	addiu $sp, $sp, -8
	sw $ra, ($sp)
	sw $s2, 4($sp)

	sub $s2, $t6, $t0
	jal heapify
	j for


swap_left:
	sb $t5, ($s3)						# A[i] = A[i*2+1]
 	sb $s4, ($t4)						# A[i*2+1] = s4 where s4 is the A[i] 
 	
	# add $s5, $s2, $zero
 # 	sub $s2, $t4, $t0
 # 	jal heapify
 	
 	j swap_ret_left
 	# j for
 	# j end

swap_right:
	sb $t7, ($s3)						# A[i] = A[i*2+2]
 	sb $s4, ($t6)						# A[i*2+2] = s4 where s4 is the A[i] 
 	
 	# add $s5, $s2, $zero
 	# sub $s2, $t6, $t0
 	# jal heapify
 	# j end
 	# j for
 	j swap_ret_right

heapify:
	jal left_child
	jal right_child
	bge $t2, $t1, out_of_bounds					# if left child is out of bounds 

	add $s3, $t0, $s2					# address of A[i]
	lb $s4, ($s3)						# s4 = A[i] temp			
	
	add $t4, $t0, $t2					# address of A[i*2+1]
	lb $t5, ($t4)						# A[i*2+1], left child
	
	bge $t3, $t1, compare_left1			# if right child is out of bounds

	add $t6, $t0, $t3					# address of A[i*2+2]
	lb $t7, ($t6)						# A[i*2+2], right child
	
	blt $t5, $t7, compare_left1			# left child < right child
	j compare_right1						# left child > right child

compare_left:
	blt $t5, $s4, swap_left				# A[i*2+1] < A[i] 
	j for
	# j end

compare_right:
	blt $t7, $s4, swap_right			# A[i*2+2] < A[i] 
	j for
	# j end

compare_left1:
	blt $t5, $s4, swap_left				# A[i*2+1] < A[i] 
	j out_of_bounds
	# j end

compare_right1:
	blt $t7, $s4, swap_right			# A[i*2+2] < A[i] 
	j out_of_bounds
	# j end

left_child:
	sll $t2, $s2, 1						# index * 2 
	addi $t2, $t2, 1					# left child index*2 + 1
	jr $ra

right_child:
	sll $t3, $s2, 1						# index * 2 
	addi $t3, $t3, 2					# left child index*2 + 2
	jr $ra

out_of_bounds:
	lw $ra, ($sp)
	lw $s2, 4($sp)
	addiu $sp, $sp, 8
	jr $ra