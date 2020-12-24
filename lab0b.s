# Assignment: extend this program to reverse the string "intext"
# and write the result to "outtext".	

            .text
            .set noreorder
main:       la    $t1, intext	# t1 points to start of intext
            la    $t2, outtext	# t2 points to start of outtext
		
            li    $t0, 0		# t0 used to count characers
seek_end:	lb    $t3, 0($t1)	# read character
            beq   $t3, 0, seek_end1 # check if 0 (end of string)
            addiu $t0, $t0, 1
            addiu $t1, $t1, 1
            b     seek_end
seek_end1:  addu  $t2, $t2, $t0	# t2 points to end of outtext
            sb    $t3, 0($t2)	# write 0 to terminate string
            la    $t1, intext	# t1 points to start of intext
copy:

loop:
	subu $t2, $t2, 1  	# skifta t2 bak
	lb $t5, 0($t1)    	# läser in första byten från $t1
	sb $t5, 0($t2)    	# lagrar denna byte på adressen sparad i $t2
	addiu $t1, $t1, 1 	# skifta t1 fram
	bgtz $t5, loop 


stop:		b     stop

            .data
intext:		.string "!dlroW olleH"
            .align 4
outtext:	.string "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

