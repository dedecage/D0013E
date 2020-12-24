# First section:  user data,
# each process has its own "private" area.

        .data        
glob1:  .byte   'A'
        .space  999
glob2:  .byte   '0'
        .space  999
glob3:  .byte   'a'
        .space  999

# Second section: user code.
#
# The first instructions initializes IO and Timer.
# The last instruction in main are only used for start
# up, they initialize the first process.

        .text
        .set noreorder
main:
        li    $t0, 0xFFFF0010   # address to Timer registers:
                                # +0: Timer control register
                                # +4: Timer count register
                                # +8: Timer compare register

        li    $t1, 0
        sw    $t1, 4($t0)       # reset counter register

        li    $t1, 63           # count from 0 to 63
        sw    $t1, 8($t0)       # compare register := 63

        li    $t1, 0b101001     # "101001": compare interrupt enable,
                                #           compare reset enable,
                                #           timer start
        sw    $t1, 0($t0)       # control register := "101001"

        li    $t0, 0xFFFF0000   # address to I/O registers:
                                # +0: Input control register
 
        li    $t1, 0b10         # "10": interrupt enable
        sw    $t1, 0($t0)       # control register := "10"

        li    $t0, 0x0C03       # enable HW Interrupt 1 (input):  bit 11
                                # enable HW Interrupt 1 (timer):  bit 10
                                # set user mode:      1 (user):   bit 1
                                # enable interrupts   1 (enable): bit 0

        mtc0  $t0, $12          # CP0 status := 0x0C03

        la    $gp, glob1        # dirty setup for process 1

proc1:  # ++++++++++ first process +++++++++

        # Description: proc1 reads the byte stored at 0($gp),
        # prints it, increments to the next character,
        # saving that back into 0($gp).  After printing 'Z',
        # this process should then start over again with 'A', in
        # an endless loop.  The symbol "glob1" may not be used.

        # Error check
        #li      $t0, -1       # 1111 1111 - Min negative integer
        #srl     $t0, $t0, 1   # 0111 1111 - Max positive integer
        #addi    $t0, $t0, 1   # Cannot go over max positive value, error (crashes the program!)

print1:	lb	$a0, 0($gp)	# Load character
	li 	$v0, 0x102	# Set to output service

	#li	$v0, 0x103	# Error check

	SYSCALL

	beq	$a0, 90, reset1
	addiu 	$a0, $a0, 1	# Increment
	sb	$a0, 0($gp)	# Store new value
	j	proc1

reset1:	li	$a0, 65	
	j	proc1
	sb	$a0, 0($gp)


proc2: # ++++++++++ second process +++++++++

        # Description: almost identical to the code of proc1 above,
        # only 2-3 lines should differ.  Prints '0' through '9' in
        # an endless loop. The symbol "glob2" may not be used.

print2:	lb	$a0, 0($gp)	# Load character
	li 	$v0, 0x102	# Set to output service
	SYSCALL

	beq	$a0, 57, reset2
	addiu 	$a0, $a0, 1	# Increment
	sb	$a0, 0($gp)	# Store new value
	j	proc2

reset2:	li	$a0, 48
	j	proc2
	sb	$a0, 0($gp)


proc3:  # +++++++++ third process ++++++++++

        # Description: almost identical to the code of proc1 above,
        # only 2-3 lines should differ.  Prints 'a' through 'z' in
        # an endless loop. The symbol "glob3" may not be used.

print3:	lb	$a0, 0($gp)	# Load character
	li 	$v0, 0x102	# Set to output service
	SYSCALL

	beq	$a0, 122, reset3
	addiu 	$a0, $a0, 1	# Increment
	sb	$a0, 0($gp)	# Store new value
	j	proc3

reset3:	li	$a0, 97
	j	proc3
	sb	$a0, 0($gp)

# Third section: data structures for the kernel:
# Process Control Block (PCB) consists of three words:
# pcb: .word  (next Program Counter for this process)
#      .word  (contents of $gp for this process)
#      .word  (contents of $sp for this process)
# All other context is saved on the process' own stack
# during exception handling and SYSCALL.

        .section .kdata
curpcb: .word  pcb1
pcb1:   .word  0, 0, 0 # $sp set on boot/reset (reload in SyncSim)
pcb2:   .word  proc2, glob2, 0x7fffbf94 
pcb3:   .word  proc3, glob3, 0x7fff7f94

# Fourth section: kernel code.

        .section .ktext , "xa"
        .set noreorder

exception_handling: 			# exception handling from the instructions

	### Check bits [5:2] of ECR
	mfc0    $k0, $13            	# Get Exception Cause Register
        li      $k1, 0x8
        andi  	$k0, $k0, 0x003c	# Mask out all but ExcCode (3c = 111100 in binary)
	srl 	$k0, $k0, 2
	beq	$k0, $zero, ext_int	# Now also detects external interrupt
	nop
	bne 	$k0, $k1, kernel_loop	# Branch to kernel loop if not syscall
	nop

sys:	
	### Check service request
        li      $k1, 0x102
        bne     $v0, $k1, return
        nop

	### Write the character from $a0
	li	$k0, 0xFFFF0000
	sw	$a0, 8($k0)

return:
	### Load the exception address and jump + 4
        mfc0    $k1, $14
        nop                        
        addiu   $k1, $k1, 4         
        jr      $k1
        rfe

ext_int:
	mfc0 	$k0, $13		# Get Exception Cause Register
	nop
	sll	$k0, 16			# Remove all bits except 15:10
	srl	$k0, 26
	li	$k1, 0x1		# Load 1 since int0 is a timer interrupt
	bne 	$k0, $k1, kernel_loop	# If not timer interrupt  
	nop

	# Clear Timer Interrupt (from lab 2)
	li      $k0, 0xFFFF0010
	li      $k1, 0b101001
	sw      $k1, 0($k0)

	# Load from current pcb.
	la	$k0, curpcb
	lw	$k1, 0($k0)	# Load current pcb address
	
store_pcb:
	mfc0 	$k0, $14	# Load program counter
	sw	$gp, 4($k1)	# Store global pointer
	sw 	$k0, 0($k1)	# Store interrupted process address
	sw	$sp, 8($k1) 	# Store stack pointer

store_stack:

  #    +-------------------+
  #    |       $at         | -108($sp) 
  #    +-------------------+
  #    |       $vX         | -100($sp) to -104($sp) 
  #    +-------------------+
  #    |       $aX         | -84($sp) to -96($sp) 
  #    +-------------------+
  #    |       $tX         | -44($sp) to -80($sp) 
  #    +-------------------+
  #    |       $sX         | -12($sp) to -40($sp)
  #    +-------------------+
  #    |       $fp         | -8($sp)
  #    +-------------------+
  #    |       $ra         | -4($sp)
  #    +-------------------+
  #    |                   | 0($sp) <= $sp points here 
  #    +-------------------+

	sw   	$ra, -4($sp)
	sw	$fp, -8($sp)

	sw	$s0, -12($sp)	# s registers
	sw	$s1, -16($sp)
	sw	$s2, -20($sp)
	sw	$s3, -24($sp)
	sw	$s4, -28($sp)
	sw	$s5, -32($sp)
	sw	$s6, -36($sp)
	sw	$s7, -40($sp)

	sw	$t0, -44($sp)	# t registers
	sw	$t1, -48($sp)
	sw	$t2, -52($sp)
	sw	$t3, -56($sp)
	sw	$t4, -60($sp)
	sw	$t5, -64($sp)
	sw	$t6, -68($sp)
	sw	$t7, -72($sp)
	sw	$t8, -76($sp)
	sw	$t9, -80($sp)

	sw	$a0, -84($sp)	# a registers
	sw	$a1, -88($sp)
	sw	$a2, -92($sp)
	sw	$a3, -96($sp)
	
	sw	$v0, -100($sp)	# v registers
	sw	$v1, -104($sp)

.set noat
	sw 	$at, -108($sp)	# at register
.set at

pcb_loop:
	# Loop through pcb:s until we reach the final one, then reset
	la	$k0, pcb3			# Load final pcb
	beq	$k0, $k1, reset_pcb		# Reset if at final pcb

	addiu	$k1, $k1, 12			# Next pcb
	la	$k0, curpcb
	b 	restore_regs
	sw	$k1, 0($k0)			# Store new pcb as current pcb

reset_pcb:	
	la	$k1, pcb1			# Load first address
	la	$k0, curpcb
	sw	$k1, 0($k0)			# Set current address as first address

restore_regs:

	lw    	$sp, 8($k1)	
	lw    	$gp, 4($k1)
	lw    	$k0, 0($k1) 

	lw   	$ra, -4($sp)
	lw	$fp, -8($sp)

	lw	$s0, -12($sp)	# s registers
	lw	$s1, -16($sp)
	lw	$s2, -20($sp)
	lw	$s3, -24($sp)
	lw	$s4, -28($sp)
	lw	$s5, -32($sp)
	lw	$s6, -36($sp)
	lw	$s7, -40($sp)

	lw	$t0, -44($sp)	# t registers
	lw	$t1, -48($sp)
	lw	$t2, -52($sp)
	lw	$t3, -56($sp)
	lw	$t4, -60($sp)
	lw	$t5, -64($sp)
	lw	$t6, -68($sp)
	lw	$t7, -72($sp)
	lw	$t8, -76($sp)
	lw	$t9, -80($sp)

	lw	$a0, -84($sp)	# a registers
	lw	$a1, -88($sp)
	lw	$a2, -92($sp)
	lw	$a3, -96($sp)
	
	lw	$v0, -100($sp)	# v registers
	lw	$v1, -104($sp)

.set noat
	lw 	$at, -108($sp)	# at register
.set at

	jr    $k0
	rfe

kernel_loop:
        b kernel_loop
        nop
