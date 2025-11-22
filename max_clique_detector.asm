# Maximum Clique Detection in MIPS Assembly
# Islam Zayed : 1230007
# Batol Abu Samhadana : 1230738
# Objective: Detects the maximum clique in an adjacency matrix
# - Flexible program for a matrix up to 5 vertices
# - Adjacency matrix validation ( nxn , 0/1 entries , matrix symmetry )
# - Brute force recursive approach to detect maximum clique
# Input : Request adjacency matrix input file
# Output : Writes maximum clique size and its vertices to console and to output.txt
################################# Data Segment ####################################
.data
# I/O buffers
# - buffers needed for file names
input_filename:  .space 64
output_filename: .asciiz  "output.txt"	#fixed output file
# - line buffer needed for reading 
byte_buffer: .space 1

# - converts int to ascii for printing
int_string_buffer:	.space 40 

# messages to display to user 
input_prompt_msg: .asciiz "Please enter the adjacency matrix input file name:\n"
file_error_msg: .asciiz "Error! Could not open input file!\n"
matrix_error_msg: .asciiz "Error! Invalid Adjacency Matrix!\n"
no_clique_msg: .asciiz "No clique found in the graph!\n"
max_size_msg: .asciiz "Maximum Clique Size: "
max_vertices_msg: .asciiz "Vertices in the Maximum Clique: "
newline: .asciiz "\n"

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
	li $t0, 0	
	
	li $v0, 10
	syscall
	
	
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
	sll $t2, $t2, 2 		# 4B * integer
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
	beqz $s2, EOF
	# if vertices check last row (as doesnt have LF)
	li $t0,-1
	beq $s3, $t0 ,set_n_last_row
	beq $s2, $s3, valid_final_row
	
	j exit
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
	li $t0, -1
	beq $s3, $t0, matrix_error		# incase no rows found
	# check if rows ,s1, = columns ,s3
	move $t1, $s1
	move $t2, $s3
	bne $t1, $t2, matrix_error 		# not nxn
	# if all valid exit and close file
	j exit
	
file_error:
	la $a0, file_error_msg		# $a0 = address of file_error_msg string
	li $v0, 4			# print file error message string
	syscall
	li $v0, 10			# exit program
	syscall
matrix_error:
	la $a0, matrix_error_msg	# $a0 = address of matrix_error_msg string
	li $v0, 4			# print matrix error message string
	syscall
	j exit
exit:
	li $v0, 10			# exit program
	syscall
	
