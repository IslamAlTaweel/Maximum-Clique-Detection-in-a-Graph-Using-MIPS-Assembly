# Maximum Clique Detection in MIPS Assembly
# Islam Zayed : 1230007
# Batol Abu Samhadana : 1230738
# Objective: Detects the maximum clique in an adjacency matrix
# - Flexible program for a matrix up to 5 vertices
# - Adjacency matrix validation ( nxn , 0/1 entries , matrix symmetry )
# - Brute force recursive approach to detect maximum clique
# Input : Request adjacency matrix input file with matrix such as sample matrix :
	# matrix shouldn't have labels on rows or columns
	# 0 1 1 0 0
	# 1 0 1 1 0
	# 1 1 0 1 0
	# 0 1 1 0 1
	# 0 0 0 1 0
# Output : Writes maximum clique size and its vertices to console and to output.txt
################################# Data Segment ####################################
.data
# I/O buffers
# - buffers needed for file names
input_filename:  .space 64
output_filename: .asciiz  "output.txt"	# fixed output file
# - line buffer needed for reading 
byte_buffer: .space 1

# - converts int to ascii for printing
int_string_buffer:	.space 40 

# messages to display to user 
input_prompt_msg: .asciiz "Please enter the adjacency matrix input file name:\n"
file_error_msg: .asciiz "Error! Could not open input file!\n"
output_file_error_msg: .asciiz "Error! Could not open output file!\n"
matrix_error_msg: .asciiz "Error! Invalid Adjacency Matrix!\n"
no_clique_msg: .asciiz "No clique found in the graph!\n"
max_size_msg: .asciiz "Maximum Clique Size: "
max_vertices_msg: .asciiz "\nVertices in the Maximum Clique: "
newline: .asciiz "\n"
space: .asciiz " "

# constants and arrays
MAX_VERTICES: .word 5 			# maximum allowable n number of vertices
adj_matrix: .space 100 			#(nxn ints for n <=5) 5 * 5 * 4
current_subset: .space 20 		# 5 * 4
max_clique_subset: .space 20		# 5 * 4
num_matrix_vertices: .word 0	
max_clique_size: .word 0


################################# Code Segment ####################################
.text
.globl main
main:
	# prompt user for input file	# display prompt string:
	la $a0, input_prompt_msg	# - $a0 = address of input_prompt_msg
	li $v0, 4			# - print string input_prompt_msg
	syscall
	# read input file name from user
	la $a0, input_filename		# #a0 = address of input_filename
	li $a1, 64			# $a1 = max string length
	li $v0, 8			# read string 
	syscall
	# strip newline from filename
	la $t0, input_filename		#t0 = address of input_filename
strip_newline:
	lb $t1, 0($t0)			# $t1 = character at address in t0
	beqz $t1, newline_strip_done	# if char is NULL its ready to branch to open file
	li $t2, 10			# $t2 = ASCII value of newline
	beq $t1, $t2, null_terminate	# if t2 = newline branch
	li $t2, 13			# $t2 = ASCII value of newline
	beq $t1, $t2, null_terminate
	addi $t0, $t0, 1		# point to next char
	j strip_newline			# loop back to check next char
null_terminate:
	sb $zero, 0($t0)		# make address ($t0) = 0
newline_strip_done:		
	# call load_input_file(input_filename) to load matrix (exits on error)
	la $a0, input_filename		# $a0 = address of input_filename
	jal load_input_file
	lw $t0, num_matrix_vertices	
	ble $t0, $zero,print_to_console

	la $t2, current_subset
	li $t3,0
	lw $t4, num_matrix_vertices
clear_subset_init:
	bge $t3, $t4, subset_cleared_init
	sll $t5, $t3, 2
	add $t6, $t2, $t5
	sw $zero, 0($t6)
	addi $t3, $t3, 1
	j clear_subset_init
subset_cleared_init:
	
   	li $a0, -1
    	li $a1,0          # size = 1 (one vertex so far)
    	jal findMaxClique	
	
print_to_console:
# check if clique found
	lw $t0, max_clique_size
	li $t1, 1
	ble $t0, $t1, handle_no_clique
	# display output string of max clique size to console
	la $a0, max_size_msg		# - $a0 = address of max_size_msg
	li $v0, 4			# - print string max_size_msg
	syscall
	lw $a0, max_clique_size
	li $v0, 1			# - print max_clique_size
	syscall
	# display output string of max clique vertices to console
	la $a0, max_vertices_msg	# - $a0 = address of max_vertices_msg
	li $v0, 4			# - print string max_vertices_msg
	syscall
	lw $t1, max_clique_size		#t1 = max clique size
	la $t2, max_clique_subset       # base address of max clique subset
	li $t0, 0			# loop index = 0
console_vertex_loop:
	bge $t0, $t1, console_vertex_done
	sll $t3, $t0, 2
	add $t3, $t2, $t3
	lw $a0, 0($t3)
	li $v0, 1			# - print  integer
	syscall
	la $a0, space
	li $v0,4
	syscall
	addi $t0, $t0, 1
	j console_vertex_loop
console_vertex_done:
	j print_to_file
handle_no_clique:
	la $a0, no_clique_msg
	li $v0,4
	syscall
	move $a0, $s6
	la $a1, no_clique_msg
	li $a2, 40
	li $v0, 15
	syscall
	j exit
	j print_to_file
print_to_file:	
	la $a0, output_filename		# filename pointer
	li $a1, 1
	li $a2, 0
	li $v0,13
	syscall				# open the output file
	move $s6, $v0			# s6  = file descriptor
	bltz $s6, output_file_error
	
	# set arguments of system call to write to file
	# write Maximum clique size string message to file
	move $a0, $s6			# a0 = file descriptor
	la $a1, max_size_msg		# - $a1 = address of max_vertices_msg
	li $a2, 22			# length of the string (num of chars to write)
	li $v0, 15			# write to file 
	syscall
	# write the actual max clique size value 
	lw $t7, max_clique_size		# load value
	move $a0, $t7
	jal int_to_string		# convert to ASCII
	move $a1, $v0			# return pointer
	# compute string length
	move $t0, $v0
length_loop_s:
	lb $t1, 0($t0)
	beqz  $t1, length_done_s
	addi $t0, $t0,1
	j length_loop_s
length_done_s:
	sub $a2, $t0, $v0		# the length of the string
	move $a0, $s6			# a0 = file desciptor
	li $v0, 15			# print max clique value to file
	syscall
	# write max clique vertices message to the output file
	move $a0, $s6
	la $a1, max_vertices_msg
	li $a2, 33			# length of the message 
	li $v0, 15			# write to file
	syscall
# write max clique vertices
	lw $t1, max_clique_size
	la $t2, max_clique_subset
	li $t0,0 			# loop index = 0
vertex_print_loop:
	bge $t0, $t1, end_vertex_print
	sll $t3, $t0, 2
	add $t3, $t2, $t3
	lw $t4, 0($t3)
	jal int_to_string
	move $a1, $v0		# a1 = address of string buffer
	# compute string length
	move $t5, $v0		# t5 = start of string
length_loop_v:
	lb $t6, 0($t5)
	beqz  $t6, length_done_v
	addi $t5, $t5,1
	j length_loop_v
length_done_v:
	sub $a2, $t5, $v0		# the length of the string
	move $a0, $s6			# a0 = file desciptor
	li $v0, 15			# print max clique value to file
	syscall
	move $a0, $s6
	la $a1, space
	li $a2, 1
	li $v0, 15
	syscall
	addi $t0, $t0,1
	j vertex_print_loop
end_vertex_print:
	#close output file
	blez $s6, skip_close
	move $a0, $s6
	li $v0,16
	syscall
skip_close:
	
exit:
	li $v0, 10			# exit program
	syscall
	
output_file_error:
	la $a0, output_file_error_msg
	li $v0, 4
	syscall
	j exit
	
int_to_string:
	la $t0, int_string_buffer
	addi $t0, $t0, 39		# move to end of the buffer
	sb $zero, ($t0)			# null terminate
	addi $t0, $t0, -1
int_to_string_loop:
	beqz $a0, int_to_string_finished
	li $t1, 10
	div $a0, $t1
	mfhi $t2		# remainder reg
	mflo $a0		# quotient
	addi $t2, $t2, 48	# convert to ASCII
	sb $t2, 0($t0)
	addi $t0, $t0, -1
	j int_to_string_loop
int_to_string_finished:
# if a0 = 0
	li $t1, 48
	lw $t3, max_clique_size
	bne $t3, $zero, not_zero_clique_size
	lb $t3,input_filename
	bnez $t3,not_zero_clique_size
	lb $t3, 0($t0)
	bnez $t3,not_zero_clique_size
	sb $t1, 0($t0)
not_zero_clique_size:
	addi $t0,$t0, 1
	move $v0, $t0		# return pointer to start of the string
	jr $ra			# return to caller

	
	
# Load input file
# - $a0 points to the input file name
# - num_matrix vertices and adj_matrix are set/filled
# - exists if error in file/invalid adjacency matrix is detected	
load_input_file:
	addiu $sp, $sp, -32 		# allocate frame = 32 B
	sw $ra, 28($sp)  		# save register values
	sw $s0, 24($sp)
	sw $s1, 20($sp)
	sw $s2, 16($sp)
	sw $s3, 12($sp)
	sw $s4, 8($sp)
	sw $s5, 4($sp)
	
	# open the input file		# $a0 = address of the filename string
	move $a1, $zero			# set flags to read only
	li $v0, 13 			# Return file descriptor in $v0 (negative if error)
	syscall
	move $s0, $v0			# $s0 = file descriptor
	bltz $v0, file_error		# if $s0 < 0 true indicates an error in opening file 
	#set counters
	li $s1, 0			# s1 = row index 
	li $s2, 0			# s2 = column count of current row
	li $s3, -1			# s3 = expected columns (isto be set from n in row one)
read_byte:
	# read 1B from input file
	move $a0, $s0 			# $a0 = file descriptor
	la $a1, byte_buffer   		# $a1 = address of input buffer
	li $a2, 1			# $a2 = maximum number of characters to read
	li $v0, 14			# Return number of characters read in $v0
	syscall
	blez $v0, EOF_handler		# indicates error or EOF
	# load byte read
	la $t0, byte_buffer 		# $t0 = address of start of buffer
	lb $t4, 0($t0)			# t4 = the byte
	# ignore carriage return (ASCII 13)
	li $t1, 13
	beq $t4, $t1, read_byte
	# if line feed (ASCII 10) we've reached end of the row
	li $t1, 10
	beq $t4, $t1, end_of_row
	# ignore space (ASCII 32) or tab(ASCII 9)
	li $t1, 32
	beq $t4, $t1, read_byte
	li $t1, 9
	beq $t4, $t1, read_byte
	# otherwise check if 0 or 1
	li $t1, 48			# ASCII value for 0
	sub $t2, $t4, $t1		# t2 = byte read - '0'
	bltz $t2, matrix_error		# if byte isn't 0 or 1 handle error
	li $t1, 1
	bgt $t2, $t1, matrix_error	# if byte isn't 0 or 1 handle error
	# else its a valid digit ( 0 or 1 )
	#store t2 (the matrix value) into adj_matrix
	# calculates index = s1 * MAXV + s2 = row index * 5 + column
	lw $t3, MAX_VERTICES		# t3 = MAXVERTICES = 5
	mul $t4, $s1, $t3		# t4 = row * 5
	add $t4, $t4, $s2		# t4 = row*5 + column
	sll $t4, $t4, 2 		# *4 offset
	la $t5, adj_matrix		# base of matrix
	add $t5, $t5, $t4
	sw $t2, 0($t5)			# store matrix value
	addi $s2, $s2, 1		# increment column count of current row
	j read_byte			# continue in row
end_of_row:
	# enters if newline was reached
	# if 1st row set expected n 
	li $t0, -1
	beq $s3, $t0, set_expected_n	# if n is still unset go set it
	# reset column index for next row
	li $t5, 0
	# else if n is set compare column count in (s2) of current row with expected n in (s3)
	beq $s2, $s3, valid_row
	# else row consists invalid number of vertices
	j matrix_error
set_expected_n:
	move $s3, $s2			# expected n = n of current row (the 1st row will only enter this)
valid_row:
	# current row found valid so move to next row to verify
	addi $s1, $s1, 1		# increment row index (s1)
	li $s2, 0			# reset column count of current row
	j read_byte
EOF_handler:
	# v0 <=0 indicates EOF or error so check for vertices
	beqz $s2, EOF		# if last row empty
	# if vertices check last row (as doesnt have LF)
	li $t0,-1
	beq $s3, $t0 ,set_n_last_row
	beq $s2, $s3, valid_final_row
	j matrix_error
set_n_last_row:
	move $s3, $s2
	addi $s1, $s1, 1
	j done_all_rows
valid_final_row:	
	addi $s1, $s1, 1
	j done_all_rows
EOF:
	j done_all_rows
done_all_rows:
	# s1 = num of rows and s3 = n verify nxn
	sw $s1, num_matrix_vertices
	li $t0, -1
	beq $s3, $t0, matrix_error		# incase no rows found
	# check if rows ,s1, = columns ,s3
	move $t1, $s1
	move $t2, $s3
	bne $t1, $t2, matrix_error 		# not nxn
	# if all valid exit and close file
	j check_symmetry
	
check_symmetry:
	# s1 = row index
	# s3 = column index (n)
	move $t6, $s3			# t6 = n
	li $t0, 0			# i = 0
symmetric_i_loop:
	bge $t0, $t6, symmetric		# branch if finished with all rows
	li $t1, 0		# j = 0
symmetric_j_loop:
	bge $t1, $t6, next_i
	# load adj_matrix[i][j]
	la $t2, adj_matrix
	mul $t3, $t0, $t6	# row * n
	add $t3, $t3, $t1	# (row * n) + column
	sll $t3, $t3, 2 	# t3 * 4B offset
	add $t3, $t2, $t3
	lw $t4,0($t3)
	# load adj_matrix[j][i]
	la $t2, adj_matrix
	mul $t3, $t1, $t6	# row = j
	add $t3, $t3, $t0	# column = i
	sll $t3, $t3, 2 	# t3 * 4B offset
	add $t3, $t2, $t3
	lw $t5,0($t3)
	# if not symmetric handle error
	bne $t4, $t5, matrix_error
	addi $t1, $t1, 1 	# increment j if no error
	j symmetric_j_loop
next_i:
	addi $t0, $t0, 1 		# increment i
	j symmetric_i_loop
symmetric:
	# the matrix has been verified to be symmetric
	lw $ra, 28($sp)  		# save register values
	lw $s0, 24($sp)
	lw $s1, 20($sp)
	lw $s2, 16($sp)
	lw $s3, 12($sp)
	lw $s4, 8($sp)
	lw $s5, 4($sp)
	addiu $sp, $sp, 32 
	jr $ra
	
file_error:
	la $a0, file_error_msg		# $a0 = address of file_error_msg string
	li $v0, 4			# print file error message string
	syscall
	j exit
matrix_error:
	la $a0, matrix_error_msg	# $a0 = address of matrix_error_msg string
	li $v0, 4			# print matrix error message string
	syscall
	j exit
isClique:
    addi $sp,$sp,-16
    sw $ra,12($sp)
    sw $s0,8($sp)
    sw $s1,4($sp)
    sw $s2,0($sp)

    move $s2,$a0

    # size 0 or 1 is always clique
    li $v0,1
    ble $s2,1,isClique_done

    li $s0,0           # i index
isClique_outer:
    addi $t0,$s2,-1
    bge $s0,$t0,isClique_yes

    la $t1,current_subset
    sll $t2,$s0,2
    add $t3,$t1,$t2
    lw $s1,0($t3)      # vertex i

    addi $s3,$s0,1     # j = i+1
isClique_inner:
    bge $s3,$s2,isClique_next_i

    sll $t2,$s3,2
    add $t3,$t1,$t2
    lw $t4,0($t3)      # vertex j

    # check if adj[i][j] = 1
    la $t5,adj_matrix
    lw $t6,num_matrix_vertices
    mult $s1,$t6
    mflo $t7
    add $t7,$t7,$t4
    sll $t7,$t7,2
    add $t8,$t5,$t7
    lw $t9,0($t8)

    beq $t9,$zero,isClique_no

    addi $s3,$s3,1
    j isClique_inner

isClique_next_i:
    addi $s0,$s0,1
    j isClique_outer

isClique_yes:
    li $v0,1
    j isClique_done

isClique_no:
    li $v0,0

isClique_done:
    lw $ra,12($sp)
    lw $s0,8($sp)
    lw $s1,4($sp)
    lw $s2,0($sp)
    addi $sp,$sp,16
    jr $ra


# tries to extend the current subset into bigger cliques
findMaxClique:
    addi $sp,$sp,-36
    sw $ra,32($sp)
    sw $s0,28($sp)
    sw $s1,24($sp)
    sw $s2,20($sp)
    sw $s3,16($sp)
    sw $s4,12($sp)
    sw $s5,8($sp)
    sw $s6,4($sp)

    move $s0,$a0     # last vertex
    move $s1,$a1     # current size

    move $a0,$s1
    jal isClique
    beq $v0,$zero,findMax_done   # if it's not a clique, stop

    # update max clique if this one is bigger
    la $s2,max_clique_size
    lw $s3,0($s2)
    ble $s1,$s3,findMax_continue

    sw $s1,0($s2)

    # copy currentSubset into maxCliqueSubset
    la $s4,current_subset
    la $s5,max_clique_subset
    li $s6,0

copy_max_loop:
    bge $s6,$s1,findMax_continue
    sll $t0,$s6,2
    add $t1,$s4,$t0
    lw $t2,0($t1)
    add $t3,$s5,$t0
    sw $t2,0($t3)
    addi $s6,$s6,1
    j copy_max_loop

findMax_continue:
    addi $s6,$s0,1     # try next vertices

findMax_vertex_loop:
    lw $t0,num_matrix_vertices
    bge $s6,$t0,findMax_done

    la $t1,current_subset
    sll $t2,$s1,2
    add $t3,$t1,$t2
    sw $s6,0($t3)
    
    move $a0, $s1
    addi $a0, $a0,1
    jal isClique
    beq $v0, $zero, findMax_next_vertex

    move $a0,$s6
    addi $a1,$s1,1
    jal findMaxClique
findMax_next_vertex:

    addi $s6,$s6,1
    j findMax_vertex_loop

findMax_done:
    lw $ra,32($sp)
    lw $s0,28($sp)
    lw $s1,24($sp)
    lw $s2,20($sp)
    lw $s3,16($sp)
    lw $s4,12($sp)
    lw $s5,8($sp)
    lw $s6,4($sp)
    addi $sp,$sp,36
    jr $ra
