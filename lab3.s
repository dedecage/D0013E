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

        li    $t0, 0x0003       # enable HW Interrupt 1 (input):  bit 11
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

print:	lb	$a0, 0($gp)	# Load character
	li 	$v0, 0x102	# Set to output service

	#li	$v0, 0x103	# Error check

	SYSCALL

	beq	$a0, 90, reset
	addiu 	$a0, $a0, 1	# Increment
	sb	$a0, 0($gp)	# Store new value
	j	proc1

reset:	li	$a0, 65	
	j	proc1
	sb	$a0, 0($gp)



proc2: # ++++++++++ second process +++++++++

        # Description: almost identical to the code of proc1 above,
        # only 2-3 lines should differ.  Prints '0' through '9' in
        # an endless loop. The symbol "glob2" may not be used.

        j proc2
        nop


proc3:  # +++++++++ third process ++++++++++

        # Description: almost identical to the code of proc1 above,
        # only 2-3 lines should differ.  Prints 'a' through 'z' in
        # an endless loop. The symbol "glob3" may not be used.

        j proc3
        nop

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
	mfc0    $k0, $13            # Move ECR
        li      $k1, 0x8
        andi  	$k0, $k0, 0x003c	# mask out all but ExcCode (3c = 111100 in binary)
	srl 	$k0, $k0, 2
	bne 	$k0, $k1, kernel_loop

	### Check service request
        li      $k1, 0x102
        bne     $v0, $k1, return
        nop

	### Write the character from $a0
	li	$k0, 0xFFFF0000
	sw	$a0, 8($k0)


return:
	### Load the exception address and jump + 4
        mfc0    $k0, $14
        nop                        
        addiu   $k0, $k0, 4         
        jr      $k0
        rfe

kernel_loop:
        b kernel_loop
        nop

