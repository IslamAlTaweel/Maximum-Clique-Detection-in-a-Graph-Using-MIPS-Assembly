	.data
adjMatrix:	.word 0,1,1,1,1,
                      1,0,1,1,1,
                      1,1,0,1,1,
                      1,1,1,0,1,
                      1,1,1,1,0
currentSubset:	.word 0,0,0,0,0
maxCliqueSubset:.word 0,0,0,0,0
maxCliqueSize:  .word 0
numVertices:    .word 5

newline:	.asciiz "\n"
space:		.asciiz " "
msgStart:	.asciiz "START\n"
msgSize:	.asciiz "Max Clique Size: "
msgVertices:	.asciiz "Vertices: "

    .text
    .globl main

# --------------------
# main: iterate start vertices
main:
    # Print START
    li $v0,4
    la $a0,msgStart
    syscall

    lw $t0,numVertices      # number of vertices
    li $t1,0                # start vertex index

main_loop:
    bge $t1,$t0,print_result

    la $t2,currentSubset
    li $t3,0
    li $t4,5          # maximum array capacity (<=5)
clear_subset:
    bge $t3,$t4,subset_cleared
    sll $t5,$t3,2
    add $t6,$t2,$t5
    sw $zero,0($t6)
    addi $t3,$t3,1
    j clear_subset
subset_cleared:
    # -------------------------

    # initialize currentSubset[0] = t1
    la $t2,currentSubset
    sw $t1,0($t2)
    li $t3,1                # current subset size = 1

    move $a0,$t1            # lastVertex = t1
    move $a1,$t3            # currentSize = 1
    jal findMaxClique

    addi $t1,$t1,1
    j main_loop

# --------------------
# print_result: show max size and vertices
print_result:
    # Print max clique size message
    li $v0,4
    la $a0,msgSize
    syscall

    lw $a0,maxCliqueSize
    li $v0,1
    syscall

    # newline
    li $v0,4
    la $a0,newline
    syscall

    # Print vertices message
    li $v0,4
    la $a0,msgVertices
    syscall

    li $t0,0
print_loop:
    lw $t1,maxCliqueSize
    bge $t0,$t1,done_print

    la $t2,maxCliqueSubset
    sll $t3,$t0,2
    add $t4,$t2,$t3
    lw $a0,0($t4)
    li $v0,1
    syscall

    # space
    li $v0,4
    la $a0,space
    syscall

    addi $t0,$t0,1
    j print_loop

done_print:
    li $v0,10
    syscall

# --------------------
# isClique:
# Input: $a0 = subset size
# Uses: $s0,$s1 (saved/restored)
# Return: $v0 = 1 if currentSubset[0..a0-1] is clique, else 0
isClique:
    # save callee-saved and ra used here ($s0,$s1 and $ra)
    addi $sp,$sp,-12
    sw $ra,8($sp)
    sw $s0,4($sp)
    sw $s1,0($sp)

    li $t0,0          # i = 0
outer_loop:
    bge $t0,$a0,clique_yes   # all pairs checked => clique
    addi $t1,$t0,1           # j = i+1

inner_loop:
    bge $t1,$a0,next_i

    la $t2,currentSubset
    sll $t3,$t0,2
    add $t4,$t2,$t3
    lw $s0,0($t4)      # vertex i -> s0

    sll $t3,$t1,2
    add $t4,$t2,$t3
    lw $s1,0($t4)      # vertex j -> s1

    # adjacency check index = s0 * numVertices + s1
    la $t5,adjMatrix
    lw $t6,numVertices
    mult $s0,$t6
    mflo $t7             # t7 = s0 * numVertices
    add $t7,$t7,$s1
    sll $t7,$t7,2
    add $t8,$t5,$t7
    lw $t9,0($t8)
    beq $t9,$zero,not_clique

    addi $t1,$t1,1
    j inner_loop

next_i:
    addi $t0,$t0,1
    j outer_loop

clique_yes:
    li $v0,1
    # restore and return
    lw $ra,8($sp)
    lw $s0,4($sp)
    lw $s1,0($sp)
    addi $sp,$sp,12
    jr $ra

not_clique:
    li $v0,0
    lw $ra,8($sp)
    lw $s0,4($sp)
    lw $s1,0($sp)
    addi $sp,$sp,12
    jr $ra

# --------------------
# findMaxClique(lastVertex = $a0, currentSize = $a1)
# Recursively extend currentSubset
# Saves all callee-saved registers used
findMaxClique:
    addi $sp,$sp,-40
    sw $ra,36($sp)
    sw $s0,32($sp)
    sw $s1,28($sp)
    sw $s2,24($sp)
    sw $s3,20($sp)
    sw $s4,16($sp)
    sw $s5,12($sp)
    sw $s6,8($sp)
    sw $s7,4($sp)

    # update maxCliqueSize if currentSize > maxCliqueSize
    la $s0,maxCliqueSize
    lw $s1,0($s0)      # s1 = maxCliqueSize
    ble $a1,$s1,skip_update
    sw $a1,0($s0)      # maxCliqueSize = a1

    # copy currentSubset[0..a1-1] -> maxCliqueSubset
    la $s2,currentSubset
    la $s3,maxCliqueSubset
    li $s4,0
copy_loop:
    beq $s4,$a1,skip_update   # stop when index == size
    sll $s5,$s4,2
    add $s6,$s2,$s5
    lw $s7,0($s6)
    add $t0,$s3,$s5
    sw $s7,0($t0)
    addi $s4,$s4,1
    j copy_loop

skip_update:
    # try adding vertices > lastVertex
    addi $s4,$a0,1

next_vertex_loop:
    lw $t1,numVertices
    bge $s4,$t1,done_fn

    # currentSubset[a1] = s4
    la $t2,currentSubset
    sll $t3,$a1,2
    add $t4,$t2,$t3
    sw $s4,0($t4)

    # prepare arguments: isClique expects subset size in $a0
    addi $t0,$a1,1        # new subset size = a1 + 1
    move $a0,$t0
    jal isClique
    beq $v0,$zero,skip_recursive

    # if clique, recursively explore from this new last vertex s4
    move $a0,$s4          # lastVertex = s4
    move $a1,$t0          # currentSize = t0
    jal findMaxClique

skip_recursive:
    addi $s4,$s4,1
    j next_vertex_loop

done_fn:
    # restore registers and return
    lw $ra,36($sp)
    lw $s0,32($sp)
    lw $s1,28($sp)
    lw $s2,24($sp)
    lw $s3,20($sp)
    lw $s4,16($sp)
    lw $s5,12($sp)
    lw $s6,8($sp)
    lw $s7,4($sp)
    addi $sp,$sp,40
    jr $ra
