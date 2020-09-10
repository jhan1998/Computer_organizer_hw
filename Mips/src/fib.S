main:
    addi $a0, $zero, 10 # n = 10
    jal fib          # call fib(10)
    j exit

fib:
    addi $sp, $sp, -4
    sw $ra, 0x0($sp)    # Save $ra register into stack

    #--------------------------------------#
    addi $t0 $zero 0
    addi $t1 $zero 1
    addi $t2 $zero 1 #count
    loop:
    add $v0 $t0 $t1
    add $t0 $t1 $zero
    add $t1 $v0 $zero
    addi $t2 $t2 1
    bne $a0 $t2 loop
    
    #--------------------------------------#

    lw $ra, 0x0($sp)    # Load $ra register from stack
    addi $sp, $sp, 4
    jr $ra

exit:
