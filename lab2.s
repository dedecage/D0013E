# ----------------------------------------------------------
#  Group 87's "underlag" for Lab 1
#  Pseudo-instructions may be used for Lab 1.
# ----------------------------------------------------------
 
 
 
# Group 87's Codeword Generator Subroutine (pseudocode)
#  (remember:  "seed" is a global variable, UNSIGNED INTEGER;
#              you may implement local variables in registers or on the stack;
#              result returned in v0; preserve all except t regs)
#
# FUNCTION codgen(): UNSIGNED INTEGER;
#  LOCAL SIGNED INTEGER   n;
#  LOCAL UNSIGNED INTEGER x, y;
#  BEGIN
#    n := [count the number of 1's in word "seed"];
#    x := [multiply "seed" by the constant 8];
#    y := [shift "seed" right-ARITHMETIC by 6 bits];
#    seed := (x - y) - n;  [ignore overflow condition]
#   RETURN( seed XOR 0x141703d1 );
#  END;
# 
# hint:  if "seed" is initialized to 0x159c7e36,
#        the first five calls will generate these values
#        :0xb89a7c76, 0x71aec4f7, 0x382051d2, 0x751eb112, 0x12de6c91, ...
# your code is to be written farther down (see comment below).
 
 
# Group 87's Recursive Decoding Subroutine (pseudocode)
#  (for "decode", all four local variables must be implemented ON THE
#              STACK, and NOT in registers; implement the code literally,.
#              no optimizations.  We're trying to teach you something.
#   remember:  result returned in v0; preserve all except t regs)
#
# FUNCTION decode( wordarr, bytearr ): UNSIGNED INTEGER;
#    (wordarr, bytearr passed by reference)
#  LOCAL UNSIGNED INTEGER m, r, x, y;
#  BEGIN
#    x := ONE'S-COMPLEMENT of codgen();
#    IF ([contents of word at "wordarr"] = 0) THEN  
#      [byte pointed to by "bytearr"] := 0;
#      r := x;
#    ELSE
#      y := decode( wordarr+, bytearr+ );  # "k+" means "successor in k"
#      m := ( x - y ) XOR [contents of word at "wordarr"];
#      [byte pointed to by "bytearr"] := [the eight bits at "m"<14:7>];
#      r := TWO'S-COMPLEMENT OF codgen();
#      r := x + y + m + r + 5;
#    ENDIF;
#    RETURN( r );
#  END;
 
 
# ----------------------------------------------------------
# The following are the ONLY lines that may appear in the
# ".data" section of the code.  You may add NO other lines.
# NO additional global variables.
# ----------------------------------------------------------
 
 
	.data
plain:	.space	92		# room for 92 characters
 
	.align 4
seed:	.word       0			# 32-bit UNSIGNED INTEGER.
 
abc:	.word	0xc02079a8	# string "abc", encoded
	.word	0xaf6edb26
	.word	0xb140ef3b
	.word	    0
coded:	.word	0x2423ba45	# the real encoded data
	.word	0xed2b33da
	.word	0x3ba9b055
	.word	0x66030460
	.word	0x9c3b4ac3
	.word	0xf6032806
	.word	0xb08fc508
	.word	0x35fd8d21
	.word	0x3e29f9f6
	.word	0x19f93fce
	.word	0x4ac7a8be
	.word	0x0b728d1b
	.word	0xd1221039
	.word	0xb6beea72
	.word	0xc78e6063
	.word	0x0902dd86
	.word	0xb689b9f6
	.word	0x51059f42
	.word	0xb3ea35aa
	.word	0x22952190
	.word	0xbfd3da46
	.word	0x13214603
	.word	0x46ab0843
	.word	0x0d340894
	.word	0xd2507ae5
	.word	0x406e97ba
	.word	0xfe5c252e
	.word	0xa594d349
	.word	0xcc8a4054
	.word	0x27afdc04
	.word	0xd023495c
	.word	0x54d57774
	.word	0x9c48db5b
	.word	0x0898a707
	.word	0x57338f62
	.word	0xc9f92107
	.word	0x4a1ecf20
	.word	0xd8da221c
	.word	0x022592ca
	.word	0x9cd08223
	.word	0xd4eda1b8
	.word	0xa4e28d51
	.word	0x95a304c0
	.word	0xcd09320a
	.word	0x0a33d007
	.word	0x0de249e3
	.word	0x81299661
	.word	0xc4cc280f
	.word	0xa722cade
	.word	0x40a22b7a
	.word	0xf505dff8
	.word	0xbcbc709c
	.word	0x32b66fa7
	.word	0x6b236033
	.word	0x422e5e25
	.word	0x4c4721be
	.word	0x185d3b95
	.word	0x4d83bcc6
	.word	0x9c7547c8
	.word	0xf994e8ea
	.word	0xa9953837
	.word	0xb3961566
	.word	0x326a4b7e
	.word	0xf68cd5f1
	.word	0x18e3753d
	.word	0x2751866b
	.word	0x8e7a52f4
	.word	0xe2cfd602
	.word	0x963469ea
	.word	0x359a65fe
	.word	0xf88ae342
	.word	0x31834ede
	.word	0x1bdd5109
	.word	0x977c4409
	.word	0xc5c40afd
	.word	0x997dbb48
	.word	0xbecb39e9
	.word	0x8e7f85a8
	.word	0x2bf37cd4
	.word	0xc6e4a3d6
	.word	0xad67c4ec
	.word	0x5abfec40
	.word	0x1e99d558
	.word	0x6b18317c
	.word	0x6f7805f4
	.word	0x6532bc4c
	.word	0x9ec3ca86
	.word	0x4ddbd53f
	.word	0x803661b5
	.word	0x46793769
	.word	0x89d45b84
	.word	    0
 
 
# ----------------------------------------------------------
# The following is the main program.  You may not change this.
# You may only add your subroutines AFTER the "infinite end loop" instruction here.
# You MUST have two subroutines named "codgen" and "decode".
# BOTH must adhere to our calling conventions; 
# both MUST preserve all registers except v-regs and t-regs;
# we are going to TEST for this when we run your code.
# ----------------------------------------------------------
 
 
	.text
	.set noreorder

main:	lui	$s0, 0x4fa9	# initialize "seed"
	ori	$s0, 0x17e0

	lui	$s1, 0		# initialize "seed"
	addiu	$s1, $s1, 4192

	sw	$s0, 0($s1)

	lui	$a0, 0		# address of start of coded words
	addiu	$a0, coded

	lui	$a1, 0		# address of start of decoded bytes
	addiu	$a1, plain

	bal	decode		# outer call to recursive "decode"
	nop

end:	b       end             # infinite loop; plaintext now in "plain".
	nop
 
 
# ----------------------------------------------------------
# Group 87's assembly code for Function CodGen :
# ----------------------------------------------------------

	# your activation record diagram here.
   	#    +-------------------+
   	#    | old frame pointer |  0($fp) <= $fp points here
   	#    +-------------------+
   	#    |  our return addr  |  4($fp)
   	#  --+-------------------+--
   	#    |                   |
   	#    |  caller's stack   |
   	#    |                   |

codgen: addiu 	$sp, $sp, -4
        sw    	$31, 0($sp)		# push the return addr
        addiu 	$sp, $sp, -4
        sw    	$fp, 0($sp)		# push the old frame pointer
       	move  	$fp, $sp		# establish new frame pointer.

	lui   	$t7, 0
	addiu 	$t7, $t7, 4192		# loads the address pointing to seed

	lw    	$t0, 0($t7)
	li    	$t2, 0			# Resetting the counter
	   
count:  beq   	$t0, $zero, break 	# Counts amount of 1's in seed based on the hint given in the instructions
	nop
	subu  	$t1, $t0, 1	
    	and   	$t0, $t0, $t1
	b     	count
    	addiu 	$t2, $t2, 1

break:  lw 	$t0, 0($t7)		# load word from seed
	nop
	sll 	$t3, $t0, 3		# x ($t3) = seed shifted left 3 times to multiply by 8
	sra 	$t4, $t0, 6		# y ($t4) = sra by 6 bits
	subu 	$t5, $t3, $t4		# (x - y)
	subu 	$t0, $t5, $t2		# (x - y) - n

	xor 	$v0, $t0, 0x141703d1
	sw  	$t0, 0($t7)		# Stores the new seed
      	j exit

# ----------------------------------------------------------
# Group 87's assembly code for Function DeCode :
# ----------------------------------------------------------

	# your activation record diagram here.
  #    +-------------------+
  #    |  uninit, for "m"  | -24($fp) <= $sp points here
  #    +-------------------+
  #    |  uninit, for "y"  | -20($fp) 
  #    +-------------------+
  #    |  uninit, for "r"  | -16($fp) 
  #    +-------------------+
  #    | uninit, for "$a1" | -12($fp) 
  #    +-------------------+
  #    | uninit, for "$a0" | -8($fp) 
  #    +-------------------+
  #    |  uninit, for "x"  | -4($fp) 
  #    +-------------------+
  #    | old frame pointer |  0($fp) <= $fp points here
  #    +-------------------+
  #    |  our return addr  |  4($fp)
  #  --+-------------------+--
  #    |                   |
  #    |  caller's stack   |
  #    |                   |

decode:	addiu $sp, $sp, -4
	sw    $31, 0($sp)	# pushes the return address
       	addiu $sp, $sp, -4
        sw    $fp, 0($sp)	# pushes the old frame pointer
        move  $fp, $sp		# establishes the new frame pointer
	bal codgen		# Retrieve value from codgen
	addiu $sp, $sp, -24 	# 6 slots: m,r,x,y,wordarr,bytearr

	addiu  $t0, $v0, 0
	not   $t0, $t0		# Creating 1's complement of codgen value
	sw    $t0, -4($fp)	
	sw    $a0, -8($fp)	
	sw    $a1, -12($fp)	# Store necessary values (x, wordarr, bytearr) onto the stack

if:	lw $t0, 0($a0)		# Enter exit sequence when we've reached the end of wordarr (zeroes)
	nop
	bne $t0, $zero, else
	nop

then:	lw $t0, -4($fp)	
	sb $zero, 0($a1)	 	
	sw $t0, -16($fp)	
	b exit
	addiu $v0, $t0, 0

else:	addiu $a0, $a0, 4	# Next word
	bal decode		# Reach the base case
	addiu $a1, $a1, 1	# Next byte
	addiu $t0, $v0, 0	
	sw $t0, -20($fp)	
	
	lw $t0, -4($fp)		# Load all necessary variables from the stack
	lw $t1, -8($fp)	 	
	lw $t2, -20($fp)	
	lw $t3, 0($t1)		

	subu $t4, $t0, $t2	# $t4 = (x - y)
	xor $t5, $t4, $t3	# $t5 = (x - y) xor wordarr
	sw $t5, -24($fp)

	lw $t0, -12($fp)
	srl $t5, $t5, 7		# Shift right to start at seventh bit
	bal codgen		# Again, retrieve value from codgen
	sb $t5, 0($t0)	

	addiu $t0, $v0, 0
	not $t0, $t0		# One's complement (invert)
	addiu $t0, $t0, 1	# Two's complement

	lw $t1, -4($fp)		# Addition sequence
	lw $t2, -20($fp)	
	lw $t3, -24($fp)	
	addu $t0, $t0, $t1	
	addu $t0, $t0, $t2	
	addu $t0, $t0, $t3	
	addiu $t0, $t0, 5	
	sw $t0, -16($fp)	
	addiu $v0, $t0, 0

exit:	move  $sp, $fp		# all local var's gone: easy !
      	lw    $fp, 0($sp)	# restore old $fp
      	addiu $sp, $sp, 4	# and pop that word,
      	lw    $31, 0($sp)	# restore return address,
      	addiu $sp, $sp, 4	# and pop that word.
      	jr    $31		# return
	
# QUESTIONS AND ANSWERS

# How many cycles did lab1b take to execute, running in the no-pipe mode? - 21587 cycles

# How many cycles did lab2 take to execute without the interrupts and running in the 
# pipeline mode? - 25374 cycles

# Compute the speed-up factor according to the following formula:
# Give at least 3 decimal places. If you didn't get a speed-up of exactly 4, explain why.
# - The speed-up factor was calculated to 3,403. A higher speed-up factor was not achieved due to branch delay instructions.

# How many cycles did lab 2 take to execute with timer interrupts, running in the extended mode? Explain 
# the extra clock cycles. - 25670 cycles. The extra cycles can be explained partly by the added code in the initialize-code-sequence and by the timer interrupts.

# How many cycles did lab 2 take to execute with timer and input interrupts, running in the extended mode? 
# Explain the extra clock cycles. - 25968 cycles. The extra cycles compared to the last example can be
# explained by the added interrupts from user input.

# end of file.
