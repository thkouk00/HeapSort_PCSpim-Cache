.data
	A: .byte 6, 14, 2, 10, 3, 5, 1, 30, 8, 50, 0, -1, -5

.text
	.globl __start
__start:
	li $t0, 0x10010000					# address of A
	li $t1, 13							# number of elements of A				
	div $s1, $t1, 2						# length/2
	mflo $s2							# take div as index

for:
	addi $s2, $s2, -1
	blt $s2, $zero, end


	jal left_child						# offset of left child
	jal right_child						# offset of right child

	jal swap
	j for
end:
	jal sort

done:
	li $v0,10							# end
	syscall


sort:
	add $t8, $t0, $t1					
	addi $t8, $t8, -1					# last element's position
	lb $s5, ($t8)						# take last element
	lb $t9, ($t0)						# take first element
	sb $s5, ($t0) 						# store last element as first 
	sb $t9, ($t8)						# store first element as last
	addi $t1, $t1, -1					# reduce array size
	beq $t1, $zero, done  
	# calculate again
	div $s1, $t1, 2						# length/2
	mflo $s2							# take div as index
	addi $s2, $s2, -1
	blt $s2, $zero, end


	jal left_child						# offset of left child
	jal right_child						# offset of right child
	jal swap
	j sort


swap:
	bge $t2, $t1, for					# if left child is out of bounds 

	add $s3, $t0, $s2					# address of A[i]
	lb $s4, ($s3)						# s4 = A[i] temp			
	
	add $t4, $t0, $t2					# address of A[i*2+1]
	lb $t5, ($t4)						# A[i*2+1], left child
	
	bge $t3, $t1, compare_left			# if right child is out of bounds

	add $t6, $t0, $t3					# address of A[i*2+2]
	lb $t7, ($t6)						# A[i*2+2], right child
	
	bgt $t5, $t7, compare_left			# left child < right child
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
	
 	j swap_ret_left

swap_right:
	sb $t7, ($s3)						# A[i] = A[i*2+2]
 	sb $s4, ($t6)						# A[i*2+2] = s4 where s4 is the A[i] 
 	j swap_ret_right

heapify:
	jal left_child
	jal right_child
	bge $t2, $t1, out_of_bounds			# if left child is out of bounds 

	add $s3, $t0, $s2					# address of A[i]
	lb $s4, ($s3)						# s4 = A[i] temp			
	
	add $t4, $t0, $t2					# address of A[i*2+1]
	lb $t5, ($t4)						# A[i*2+1], left child
	
	bge $t3, $t1, compare_left1			# if right child is out of bounds

	add $t6, $t0, $t3					# address of A[i*2+2]
	lb $t7, ($t6)						# A[i*2+2], right child
	
	bgt $t5, $t7, compare_left1			# left child < right child
	j compare_right1					# left child > right child

compare_left:
	bgt $t5, $s4, swap_left				# A[i*2+1] < A[i] 
	j for

compare_right:
	bgt $t7, $s4, swap_right			# A[i*2+2] < A[i] 
	j for

compare_left1:
	bgt $t5, $s4, swap_left				# A[i*2+1] < A[i] 
	j out_of_bounds

compare_right1:
	bgt $t7, $s4, swap_right			# A[i*2+2] < A[i] 
	j out_of_bounds

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

################################################################################################
swap2:
	bge $t2, $t1, sort					# if left child is out of bounds 

	add $s3, $t0, $s2					# address of A[i]
	lb $s4, ($s3)						# s4 = A[i] temp			
	
	add $t4, $t0, $t2					# address of A[i*2+1]
	lb $t5, ($t4)						# A[i*2+1], left child
	
	bge $t3, $t1, compare_left2			# if right child is out of bounds

	add $t6, $t0, $t3					# address of A[i*2+2]
	lb $t7, ($t6)						# A[i*2+2], right child
	
	bgt $t5, $t7, compare_left2			# left child < right child
	j compare_right2						# left child > right child

swap_ret_left2:
	addiu $sp, $sp, -8
	sw $ra, ($sp)
	sw $s2, 4($sp)

	sub $s2, $t4, $t0
	jal heapify2
	j sort

swap_ret_right2:
	addiu $sp, $sp, -8
	sw $ra, ($sp)
	sw $s2, 4($sp)

	sub $s2, $t6, $t0
	jal heapify2
	j sort


swap_left2:
	sb $t5, ($s3)						# A[i] = A[i*2+1]
 	sb $s4, ($t4)						# A[i*2+1] = s4 where s4 is the A[i] 
	
 	j swap_ret_left2

swap_right2:
	sb $t7, ($s3)						# A[i] = A[i*2+2]
 	sb $s4, ($t6)						# A[i*2+2] = s4 where s4 is the A[i] 
 	j swap_ret_right2

heapify2:
	jal left_child
	jal right_child
	bge $t2, $t1, out_of_bounds			# if left child is out of bounds 

	add $s3, $t0, $s2					# address of A[i]
	lb $s4, ($s3)						# s4 = A[i] temp			
	
	add $t4, $t0, $t2					# address of A[i*2+1]
	lb $t5, ($t4)						# A[i*2+1], left child
	
	bge $t3, $t1, compare_left3			# if right child is out of bounds

	add $t6, $t0, $t3					# address of A[i*2+2]
	lb $t7, ($t6)						# A[i*2+2], right child
	
	bgt $t5, $t7, compare_left3			# left child < right child
	j compare_right3					# left child > right child

compare_left2:
	bgt $t5, $s4, swap_left2				# A[i*2+1] < A[i] 
	j sort

compare_right2:
	bgt $t7, $s4, swap_right2			# A[i*2+2] < A[i] 
	j sort

compare_left3:
	bgt $t5, $s4, swap_left2				# A[i*2+1] < A[i] 
	j out_of_bounds

compare_right3:
	bgt $t7, $s4, swap_right2			# A[i*2+2] < A[i] 
	j out_of_bounds
