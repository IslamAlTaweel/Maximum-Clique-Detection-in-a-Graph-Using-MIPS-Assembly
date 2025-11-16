.data
adjMatrix:       .word 0,1,1,0,0, 1,0,1,1,0, 1,1,0,1,0, 0,1,1,0,1, 0,0,0,1,0
currentSubset:   .word 0,0,0,0,0
maxCliqueSubset: .word 0,0,0,0,0
maxCliqueSize:   .word 0
numVertices:     .word 5

newline:         .asciiz "\n"
space:           .asciiz " "
msgStart:        .asciiz "START\n"
msgSize:         .asciiz "Max Clique Size: "
msgVertices:     .asciiz "Vertices: "

.text
.globl main

main:
    # Print START
    li $v0,4
    la $a0,msgStart
    syscall

    lw $t0,numVertices
    li $t1,0              # start vertex
main_loop:
    bge $t1,$t0,print_result

    # initialize currentSubset with just vertex t1
    la $t2,currentSubset
    sw $t1,0($t2)
    li $t3,1              # subset size
    move $a0,$t1          # lastVertex
    move $a1,$t3          # currentSize
    jal findMaxClique

    addi $t1,$t1,1
    j main_loop

# --------------------
print_result:
    # Print max clique size
    li $v0,4
    la $a0,msgSize
    syscall
    lw $a0,maxCliqueSize
    li $v0,1
    syscall

    # Newline
    li $v0,4
    la $a0,newline
    syscall

    # Print vertices
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
# Check if subset is clique
# $a0 = subset size
# Returns 1 in $v0 if clique, else 0
isClique:
    li $t0,0              # i
outer_loop:
    bge $t0,$a0,clique_yes
    addi $t1,$t0,1        # j = i+1
inner_loop:
    bge $t1,$a0,next_i
    la $t2,currentSubset
    sll $t3,$t0,2
    add $t4,$t2,$t3
    lw $s0,0($t4)         # vertex i
    sll $t3,$t1,2
    add $t4,$t2,$t3
    lw $s1,0($t4)         # vertex j

    # adjacency check
    la $t5,adjMatrix
    lw $t6,numVertices
    mul $t7,$s0,$t6
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
    jr $ra
not_clique:
    li $v0,0
    jr $ra

# --------------------
# findMaxClique(lastVertex=a0, currentSize=a1)
findMaxClique:
    addi $sp,$sp,-8
    sw $ra,4($sp)
    sw $s0,0($sp)

    # update maxCliqueSize if needed
    la $s0,maxCliqueSize
    lw $s1,0($s0)
    ble $a1,$s1,skip_update
    sw $a1,0($s0)

    # copy currentSubset to maxCliqueSubset
    la $s2,currentSubset
    la $s3,maxCliqueSubset
    li $s4,0
copy_loop:
    bge $s4,$a1,skip_update
    sll $s5,$s4,2
    add $s6,$s2,$s5
    lw $s7,0($s6)
    add $t0,$s3,$s5
    sw $s7,0($t0)
    addi $s4,$s4,1
    j copy_loop
skip_update:
    addi $s4,$a0,1
next_vertex_loop:
    lw $t1,numVertices
    bge $s4,$t1,done_fn
    la $t2,currentSubset
    sll $t3,$a1,2
    add $t4,$t2,$t3
    sw $s4,0($t4)

    addi $t0,$a1,1
    move $a0,$s4
    move $a1,$t0
    jal isClique
    beq $v0,$zero,skip_recursive

    move $a0,$s4
    move $a1,$t0
    jal findMaxClique
skip_recursive:
    addi $s4,$s4,1
    j next_vertex_loop
done_fn:
    lw $ra,4($sp)
    lw $s0,0($sp)
    addi $sp,$sp,8
    jr $ra
