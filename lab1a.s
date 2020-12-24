# Assignment: extend this program to reverse the string "intext"
# and write the result to "outtext".	

            .text
            .set noreorder
main:       la    $t1, intext	# t1 points to start of intext
            la    $t2, outtext	# t2 points to start of outtext
	    li	  $t4, 0	# li - load immidiate, resets a register
            li    $t0, 0		# t0 used to count characters

seek_end:	lb    $t3, 0($t1)	# read character
            beq   $t3, 0, seek_end1 # check if 0 (end of string)
            addiu $t0, $t0, 1
            addiu $t1, $t1, 1
            b     seek_end

seek_end1:  addu  $t2, $t2, $t0	# t2 points to end of outtext
            sb    $t3, 0($t2)	# write 0 to terminate string
            la    $t1, intext	# t1 points to start of intext

###########################################################################################################

load:	        subu $t2, $t2, 1	# correct the index (12th instead of 13th)
		addu $a0, $a0, $t0 	# store value of counter $t0 to $a0
		add $a1, $a1, $t1	# store intext to $a1 
		add $a2, $a2, $t2	# store outtext to $a2

		bal rev			# store next instruction to $31 and branch to rev
		b stop			# the first return address loaded to the stack 

rev:		addiu $sp, $sp, -4	# make room for return address
      		sw    $31, 0($sp)	# push return address
      		addiu $sp, $sp, -4	# make space for frame pointer
      		sw    $fp, 0($sp)	# pushe the old frame pointer
      		move  $fp, $sp		# establish new frame pointer
      		addiu $sp, $sp, -12	# make room for parameters on the stack

		sw $a0, -4($fp)		# store parameters on the stack
		sw $a1, -8($fp)
		sw $a2, -12($fp)

  # everything above is called the "entry sequence".
  # the stack now looks like this.
  # YOU MUST SHOW US A DIAGRAM LIKE THIS, FOR ALL 
  # THE SUBROUTINES YOU WRITE IN LAB 1.
  #    
  #    +-------------------+
  #    |  old frame "$a2"  | -12($fp) <= $sp points here
  #    +-------------------+
  #    |  our return "$a1" | -8($fp) 
  #    +-------------------+
  #    | uninit, for "$a0" | -4($fp) 
  #    +-------------------+
  #    | old frame pointer |  0($fp) <= $fp points here
  #    +-------------------+
  #    |  our return addr  |  4($fp)
  #  --+-------------------+--
  #    |                   |
  #    |  caller's stack   |
  #    |                   |
		
if:		bne $a0, $zero, else

then:		b exit

else:		subu $a0, $a0, 1	# decrease counter
		addi $a1, $a1, 1	# increment intext address pointer one byte
		subu $a2, $a2, 1	# decrement outtext address pointer one byte
		
		bal rev			# store next instruction to $31 and branch back to rev
	
		lw $a1, -8($fp)		# load word from intext pointer	
		lw $a2, -12($fp)	# load word from outtext pointer

		lb $t0, 0($a1)		# load first byte (letter) from intext
		sb $t0, 0($a2)		# store first byte (letter) from intext to outtext
		
exit:		move  $sp, $fp		# all local var's gone: easy !
      		lw    $fp, 0($sp)	# restore old $fp
      		addiu $sp, $sp, 4	# and pop that word,
      		lw    $31, 0($sp)	# restore return address,
      		addiu $sp, $sp, 4	# and pop that word.
      		jr    $31		# return

stop:		b     stop

            .data
intext:		.string "!dlroW olleH"
            .align 4
outtext:	.string "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
