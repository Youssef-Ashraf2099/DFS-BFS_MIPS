.data
# Representation 1: Level-order representation
rep1: .word 4, 9, 10, 10, 15, 2, 3
rep1Length: .word 7

# Representation 2: Pre-order representation
rep2: .word 4, 9, 10, 15, 10, 2, 3
rep2Length: .word 7

# Values to search
value: .word 15

# Output arrays for converted representations
rep1ToRep2: .space 28  # 7 words * 4 bytes
rep2ToRep1: .space 28  # 7 words * 4 bytes

.text
.globl main

main:
    # Convert Representation 1 to Representation 2
    la $a0, rep1        # Load base address of rep1
    lw $a1, rep1Length  # Load length of rep1
    la $a2, rep1ToRep2  # Load base address of output rep2
    la $t0, convertRepresentation1To2
    jalr $t0

    # Convert Representation 2 to Representation 1
    la $a0, rep2        # Load base address of rep2
    lw $a1, rep2Length  # Load length of rep2
    la $a2, rep2ToRep1  # Load base address of output rep1
    la $t0, convertRepresentation2To1
    jalr $t0

    # Perform breadth-first search on Representation 1
    la $t0, rep1        # Load base address of rep1
    lw $t2, rep1Length  # Load length of rep1
    lw $t3, value       # Load value to search
    la $t4, brdthSearch
    jalr $t4
    move $t8, $v0       # Store the result in $t8

    # Perform breadth-first search on Representation 2
    la $t0, rep2        # Load base address of rep2
    lw $t2, rep2Length  # Load length of rep2
    lw $t3, value       # Load value to search
    la $t4, breadthFirstSearchRep2
    jalr $t4
    move $t9, $v0       # Store the result in $t9

    # Print the results
    li $v0, 4
    la $a0, msg1
    syscall

    li $v0, 1
    move $a0, $t8
    syscall

    li $v0, 4
    la $a0, msg2
    syscall

    li $v0, 1
    move $a0, $t9
    syscall

    li $v0, 10
    syscall

.data
msg1: .asciiz "Breadth-first search result on Representation 1: "
msg2: .asciiz "\nBreadth-first search result on Representation 2: "

#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
#procedure 1
convertRepresentation1To2:
    # Input: $a0 = rep1 base address, $a1 = rep1 length, $a2 = rep2 base address
    addi $sp, $sp, -12       # make space in the stack 
    sw $ra, 8($sp)           # Save return address
    sw $a0, 4($sp)           # Save rep1 base address
    sw $a1, 0($sp)           # Save rep1 length

    move $t0, $zero          # Initialize output index to 0
    move $t1, $zero          # Initialize root index to 0

    la $t2, levelOrderToPreOrder
    jalr $t2                 # Call the recursive conversion function

    lw $ra, 8($sp)           
    lw $a0, 4($sp)           
    lw $a1, 0($sp)           
    addi $sp, $sp, 12        # delete elements from the stack
    
    move $v0, $a2      
    jr $ra
###############################################################################
levelOrderToPreOrder: #VVVVVVVVVVVVVVVIIIIIIIIIIIIPPPPPPPPPPPPPPPPPP
    addi $sp, $sp, -16   # Make space on the stack
    sw $ra, 12($sp)      # Save return address
    sw $t0, 8($sp)       # Save output index
    sw $t1, 4($sp)       # Save root index
    sw $a0, 0($sp)       # Save input array base address
    
    # Check if rootIndex is out of bounds as a2 represent the length
    bge $t1, $a2, exit1
  
    # Process current root
    sll $t2, $t1, 2      # Calculate offset: rootIndex * 4
    add $t3, $a0, $t2    # Calculate address: base + offset
    lw $t4, 0($t3)       # Load value from input array
    sll $t5, $t0, 2      # Calculate offset for output: outputIndex * 4
    add $t6, $a1, $t5    # Calculate address: base + offset
    sw $t4, 0($t6)       # Store value in output array
    addi $t0, $t0, 1     # Increment output index
    
    # Process left child
    sll $t7, $t1, 1      # Calculate left child index: 2 * rootIndex
    addi $t7, $t7, 1     # Left child index = 2 * rootIndex + 1
    move $t1, $t7        # Set new root index to left child
    la $t8, levelOrderToPreOrder
    jalr $t8             # Recursively process left child
    
    # Restore root index
    lw $t1, 4($sp)
    
    # Process right child
    sll $t7, $t1, 1      # Calculate right child index: 2 * rootIndex
    addi $t7, $t7, 2     # Right child index = 2 * rootIndex + 2
    move $t1, $t7        # Set new root index to right child
    la $t9, levelOrderToPreOrder
    jalr $t9             # Recursively process right child
    
    # Restore root index and output index
    lw $t1, 4($sp)
    lw $t0, 8($sp)

exit1:
    lw $ra, 12($sp)      # Restore return address
    lw $a0, 0($sp)       # Restore input array base address
    addi $sp, $sp, 16    # Restore stack pointer
    jr $ra               # Return to caller
##### EEEEEEENNNNNNNNNNDDDDDDDDDDDDD 111111111
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# PROCEDURE 2
convertRepresentation2To1:
    # Input: $a0 = rep2 base address, $a1 = rep2 length, $a2 = rep1 base address
    addi $sp, $sp, -12       # Allocate stack space
    sw $ra, 8($sp)           # Save return address
    sw $a0, 4($sp)           # Save rep2 base address
    sw $a1, 0($sp)           # Save rep2 length

    move $t8, $zero          # Initialize index to 0
    
Loop:
    bge $t8, $a1, End        # if index >= rep2 length, end loop
    sll $t7, $t8, 2          # Calculate offset
    add $t6, $a2, $t7        # Calculate address (using rep1 base address in $a2)
    li $t9, -1               # Load -1
    sw $t9, 0($t6)           # Store -1 at calculated address
    addi $t8, $t8, 1         # Increment index
    j Loop       
End:

    move $t6, $zero          # Initialize preOrderindex to 0
    move $t7, $zero          # Initialize levelOrderindex to 0
    move $t3, $a1            # rep2 length in t3
    move $t5, $a1            # rep1 length in t5
    
    jal preOrderToLevelOrder # Call the recursive function

    lw $ra, 8($sp)           # Restore return address
    addi $sp, $sp, 12        # Delete elements from the stack 
    jr $ra                   # Return to caller

preOrderToLevelOrder:
    addi $sp, $sp, -16       # Allocate stack space
    sw $ra, 12($sp)          # Save return address
    sw $t3, 8($sp)           # Save rep2 length
    sw $t6, 4($sp)           # Save preOrderIndex
    sw $a0, 0($sp)           # Save input array base address
    
    # Check if preOrderIndex is out of bounds
    bge $t6, $t3, exit       # If preOrderIndex >= rep2 length, exit

    # Process current root
    sll $t2, $t6, 2          # Calculate offset: preOrderIndex * 4
    add $t1, $a0, $t2        # Calculate address: base + offset
    lw $t4, 0($t1)           # Load value from input array
    
    sll $t8, $t7, 2          # Calculate offset for output: levelOrderIndex * 4
    add $t5, $a2, $t8        # Calculate address: base + offset
    sw $t4, 0($t5)           # Store value in output array
    
    addi $t6, $t6, 1         # Increment preOrderIndex
    addi $t7, $t7, 1         # Increment levelOrderIndex

    # Process left child
    move $a0, $t4            # Save current root value
    jal preOrderToLevelOrder # Recursively process left child
    
    # Restore preOrderIndex
    lw $t6, 4($sp)
    
    # Process right child
    move $a0, $t4            # Save current root value
    jal preOrderToLevelOrder # Recursively process right child
    
    # Restore preOrderIndex and levelOrderIndex
    lw $t6, 4($sp)
    lw $t7, 8($sp)

exit:
    lw $ra, 12($sp)          # Restore return address
    lw $a0, 0($sp)           # Restore input array base address
    addi $sp, $sp, 16        # Restore stack pointer
    jr $ra                   # Return to caller

##### EEEEEEEEEEENNNNNNNNNNNNNNNDDDDDDDDDDDDDD 222222222
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

brdthSearch:
    # Assuming $a0 = array base address, $t2 = array length, $t3 = value to search
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $t0, 0($sp)

    li $v0, -1 # Default to not found
    move $t1, $zero # Initialize index to 0

loop1:
    bge $t1, $t2, end1 # If index >= length, exit loop
    sll $t4, $t1, 2    # Calculate offset: index * 4
    add $t5, $a0, $t4  # Calculate address: base + offset
    lw $t6, 0($t5)     # Load value from array
    beq $t6, $t3, found # If value == search value, found
    addi $t1, $t1, 1   # Increment index
    j loop1            # Repeat loop

found:
    move $v0, $t1 # Return index

end1:
    lw $ra, 4($sp)
    lw $t0, 0($sp)
    addi $sp, $sp, 8
    jr $ra

#####EEEEEEEEEEEEENNNNNNNNNNNNNNNNNDDDDDDDDDDD 333333333
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

breadthFirstSearchRep2:
    # Assuming $a0 = array base address, $t2 = array length, $t3 = value to search
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $t0, 0($sp)

    li $v0, -1 # Default to not found
    move $t1, $zero # Initialize index to 0

loop2:
    bge $t1, $t2, end2 # If index >= length, exit loop
    sll $t4, $t1, 2    # Calculate offset: index * 4
    add $t5, $a0, $t4  # Calculate address: base + offset
    lw $t6, 0($t5)     # Load value from array
    beq $t6, $t3, found2 # If value == search value, found
    addi $t1, $t1, 1   # Increment index
    j loop2            # Repeat loop

found2:
    move $v0, $t1 # Return index

end2:
    lw $ra, 4($sp)
    lw $t0, 0($sp)
    addi $sp, $sp, 8
    jr $ra

#####EEEEEEEEEEEEEEEENNNNNNNNNNNNNNNNNNNNNNDDDDDDDDDDD 44444444444444