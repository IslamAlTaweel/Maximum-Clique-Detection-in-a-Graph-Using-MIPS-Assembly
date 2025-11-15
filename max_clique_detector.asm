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
line_buffer: .space 64

# - converts int to ascii for printing
int_string_buffer .space 40 

# messages to display to user 
input_prompt_msg: .asciiz "Please enter the adjacency matrix input file name:\n"
file_error_msg: .asciiz "Error! Could not open input file!\n"
matrix_error_msg: .asciiz "Error! Invalid Adjacency Matrix!\n"
no_clique_msg: .asciiz "No clique found in the graph!\n"
max_size_msg: .asciiz "Maximum Clique Size: "
max_vertices_msg: .asciiz "Vertices in the Maximum Clique: "
newline: .asciiz "\n"

# constants and arrays
MAX_VERTICES .word 5 			# maximum allowable n number of vertices
adj_matrix .space 5*5*4 		#(nxn ints for n <=5)
current_subset .space 5*4
max_clique_subset .space 5*4
num_matrix_vertices .word 0
max_clique_size .word 0

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
	
	# call load_input_file(input_filename) to load matrix (exits on error)
	la $a0, input_filename		# $a0 = address of input_filename
	jal load_input_file
	
	
	
	
	
	
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
	move $s0, $v0 			# $s0 = file descriptor
	bltz $s0, file_error		# if $s0 < 0 true indicates an error in opening file 
	
	# read header line row of the matrix
	move $a0, $s0 			# $a0 = file descriptor
	la $a1, line_buffer   		# $a1 = address of input buffer
	li $a2, 64			# $a2 = maximum number of characters to read
	li $v0, 14			# Return number of characters read in $v0
	syscall
	move $s1, $v0			# $s0 = bytes read
	blez $s1, matrix_error
	# null terminate the buffer holding the header line
	la $t0, line_buffer 		# $t0 = address of start of buffer
	add $t0, $t0, $s1               # $t0 = address of start of buffer + bytes read to move past all chars read
	sb  $zero, 0($t0) 		# store a NULL character
	
	# parse header tokens to count columns
	la $t0, line_buffer
	li $t1, 0			# initialize token count
header_row_scan:
	
	
	
	
	
	
file_error
	la $a0, file_error_msg		# $a0 = address of file_error_msg string
	li $v0, 4			# print file error message string
	syscall
	li $v0, 10			# exit program
	syscall
matrix_error
	la $a0, matrix_error_msg	# $a0 = address of matrix_error_msg string
	li $v0, 4			# print matrix error message string
	syscall
	li $v0, 10			# exit program
	syscall
