.data
adjMatrix:    .word   0,0,0,0,0,
                      0,0,1,1,1,
                      0,1,0,1,1,
                      0,1,1,0,1,
                      0,1,1,1,0
currentSubset:    .word 0,0,0,0,0
maxCliqueSubset:  .word 0,0,0,0,0
maxCliqueSize:    .word 0
numVertices:      .word 5

newline:    .asciiz "\n"
space:      .asciiz " "
msgStart:   .asciiz "START\n"
msgSize:    .asciiz "Max Clique Size: "
msgVertices:.asciiz "Vertices: "

.text
.globl main

main:
    # just printing the start message
    li $v0,4
    la $a0,msgStart
    syscall

    # reset max clique to 0
    sw $zero,maxCliqueSize
    
   

    # clear currentSubset before each run
    la $t2,currentSubset
    li $t3,0
    lw $t4,numVertices
clear_subset:
    bge $t3,$t4,subset_cleared
    sll $t5,$t3,2
    add $t6,$t2,$t5
    sw $zero,0($t6)
    addi $t3,$t3,1
    j clear_subset

subset_cleared:
 
    li $a0, -1
    li $a1,0          # size = 1 (one vertex so far)
    jal findMaxClique


print_result:
    # print size of max clique
    li $v0,4
    la $a0,msgSize
    syscall

    lw $a0,maxCliqueSize
    li $v0,1
    syscall

    li $v0,4
    la $a0,newline
    syscall

    # print the vertices of the max clique
    li $v0,4
    la $a0,msgVertices
    syscall

    li $t0,0
    lw $t1,maxCliqueSize
    beq $t1,$zero,done_print

print_loop:
    bge $t0,$t1,done_print
    la $t2,maxCliqueSubset
    sll $t3,$t0,2
    add $t4,$t2,$t3
    lw $a0,0($t4)
    li $v0,1
    syscall

    li $v0,4
    la $a0,space
    syscall

    addi $t0,$t0,1
    j print_loop

done_print:
    li $v0,4
    la $a0,newline
    syscall

    li $v0,10
    syscall


# checks if the subset of size a0 is a clique
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

    la $t1,currentSubset
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
    la $t5,adjMatrix
    lw $t6,numVertices
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
    la $s2,maxCliqueSize
    lw $s3,0($s2)
    ble $s1,$s3,findMax_continue

    sw $s1,0($s2)

    # copy currentSubset into maxCliqueSubset
    la $s4,currentSubset
    la $s5,maxCliqueSubset
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
    lw $t0,numVertices
    bge $s6,$t0,findMax_done

    la $t1,currentSubset
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
