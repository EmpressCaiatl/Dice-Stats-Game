#  ###########################################################################
#  Name: Isabella Maffeo
#  Assignment: MIPS #4
#  Description:  Simulate rolling two dice and determining statistics around the rolls
#				 Prompt the user for a value between a given range. Roll as many times
#				 as user prompted. Determine average rolls stats.

#  CS 218
#  MIPS Assignment #4

#  MIPS assembly language program to simulate the rolling of two dice.

###########################################################
#  data segment

.data

hdr:		.ascii	"MIPS Assignment #4 \n"
		.asciiz	"Program to Simulate Rolling Two Dice. \n\n"

# -----
#  Dice Results Matrix

dice:	.word	0, 0, 0, 0, 0, 0
	.word	0, 0, 0, 0, 0, 0
	.word	0, 0, 0, 0, 0, 0
	.word	0, 0, 0, 0, 0, 0
	.word	0, 0, 0, 0, 0, 0
	.word	0, 0, 0, 0, 0, 0

rolls:	.word	0

# -----
#  Local variables for GetInput function.

MIN = 1
MAX = 100000

rd_hdr:	.asciiz	"\nDice Rolls Simulation Input Routine\n\n"
rd_rolls:	.asciiz	"Enter Number of Dice Rolls to Simulate: "
er_rolls:	.ascii	"\nError, rolls must be between 1 and 100000\n"
		.asciiz	"Please re-enter\n\n"

# -----
#  Local variables for random function.

s_tbl:	.word	47174, 64426, 21990, 28426, 63878
	.word	52330, 17190, 29642, 53958, 50474
	.word	18535,  8330, 17414, 58858, 26022
	.word	30026,     0

jptr:	.word	16
kptr:	.word	4

ltmp:	.word	0

# -----
#  Local variables for Result procedure.

r_hdr:	.ascii	"\n\n************************************\n\n"
		.asciiz	"Rolls: "

r_top:	.asciiz	"  ------- ------- ------- ------- ------- -------\n"
new_ln:	.asciiz	"\n"
bar:		.asciiz	" |"

blnks1:	.asciiz	" "
blnks2:	.asciiz	" "
blnks3:	.asciiz	"  "
blnks4:	.asciiz	"   "
blnks5:	.asciiz	"    "
blnks6:	.asciiz	"     "

colon:	.asciiz	":   "
colon2:	.asciiz	":  "

pctHdr:	.asciiz	"\n\nPercentages:\n"

hundred:	.float	100.0

sums:	.word	0		# 2s
	.word	0		# 3s
	.word	0		# 4s
	.word	0		# 5s
	.word	0		# 6s
	.word	0		# 7s
	.word	0		# 8s
	.word	0		# 9s
	.word	0		# 10s
	.word	0		# 11s
	.word	0		# 12s

###########################################################
#  text/code segment

.text

.globl main
.ent main
main:

# -----
#  Display main program header.

	la	$a0, hdr
	li	$v0, 4
	syscall					# print header

# -----
#  Get user input.

	jal	getInput
	sw	$v0, rolls

# -----
#  Throw the dice 'rolls' times, track results.

	la	$a0, dice
	lw	$a1, rolls
	jal	throwDice

# -----
#  Calculate totals, compute percentages, and display results

	la	$a0, dice
	lw	$a1, rolls
	jal	results

# -----
#  Done, terminate program.

	li	$v0, 10
	syscall

.end main


######################################################
#  Procedure to read a number between between 1 and 100,000.
#  Returns its result in $v0.

.globl	getInput
.ent	getInput
getInput:

	#--PRINT INSTRUCTIONS---#
	la	$a0, rd_hdr
	li	$v0, 4
	syscall

	rePrompt:
	la	$a0, rd_rolls
	li	$v0, 4
	syscall
	#-----------------------#
	#--READ FROM TERMINAL---#
	li $v0, 5				# call code for read integer
	syscall					# system call (result in $v0)
	move $s0, $v0

	ble $s0, MIN, ERROR		# check input greater than 1
	bge $s0, MAX, ERROR		# check input less than 100000

	b endFunc
	#--ERROR MESSAGES-------#
	ERROR:
	la	$a0, er_rolls
	li	$v0, 4
	syscall
	b rePrompt
	#-----------------------#
	endFunc:
	move $v0, $s0
	jr $ra

.end getInput
######################################################
#  Function to generate pseudo random numbers using
#  the lagged Fibonacci generator.
#  Since function, returns result in $v0.

#  Algorithm:
#	itmp  =  s_table(jptr) + s_table(kptr)
#	s_table(jptr)  =  itmp mod 2^16
#	jptr  =  jptr - 1
#	kptr  =  kptr - 1
#	if ( jptr < 0 )  jptr = 16
#	if ( kptr < 0 )  kptr = 16
#	rand_dice = ( itmp / 100 ) mod 6

# -----
#    Arguments:
#	none

#    Returns:
#	$v0


.globl	random
.ent	random
random:

	la $s5, s_tbl
	lw $t0, ltmp		
	lw $t1, jptr
	lw $t2, kptr
	li $t9, 0

	mul $t1, $t1, 4			# jptr * 4
	mul $t2, $t2, 4			# kptr * 4

	add $t3, $s5, $t1		# get address of sTable[jptr]
	lw $t8, ($t3)			# load value @ sTable[jptr]
	
	add $t4, $s5, $t2		# get address of sTable[kptr]
	lw $t9, ($t4)			# load value @ sTable[kptr]

	
	add $t0, $t8, $t9		# sTable[jptr] + sTable[kptr]
	sw $t0, ltmp			# save into ltmp

	rem $t0, $t0, 65536		# itmp % 2^16

	sw $t0, ($t3)			# sTable[jptr] = itmp % 2^16

	lw $t1, jptr			# grab jptr
	sub $t1, $t1, 1			# jptr = jptr - 1
	blt $t1, 0, setJ		# if jptr < 0, reset
	sw $t1, jptr			# else, save value

	contJ:
		lw $t1, kptr			# grab kptr
		sub $t1, $t1, 1			# kptr = kptr - 1
		blt $t1, 0, setK		# if kptr < 0, reset
		sw $t1, kptr			# else, save value
	
		b endFuncJK				# continue to last calc

	setJ:
		li $t1, 16				
		sw $t1, jptr			# jptr = 16
		b contJ

	setK:
		li $t1, 16
		sw $t1, kptr			# kptr = 16
		b endFuncJK	

	endFuncJK:
		lw $t1, ltmp			# grab itmp
		div $t1, $t1, 100		# itmp / 100
		rem $v0, $t1, 6			# ... % 6

	jr $ra

.end random

######################################################
#  Procedure to simulate the rolling of two dice n times.
#    Each die can show an integer value from 1 to 6, so the sum of
#    the values will vary from 2 to 12.
#    The results are stored in a two-dimension array.
#    Calls the Random() function.

# -----
#  Formula for multiple dimension array indexing:
#	addr(row,col) = base_address + (rowindex * col_size + colindex) * element_size

# -----
#  Arguments
#	$a0 - address of dice two-dimension array
#	$a1 - number of 'rolls'


.globl	throwDice
.ent	throwDice
throwDice:
	# push
	subu $sp, $sp, 36		# stack space			
	sw $s0, 0($sp)						
	sw $s1, 4($sp)						
	sw $s2, 8($sp)						
	sw $s3, 12($sp)						
	sw $s4, 16($sp)						
	sw $s5, 20($sp)						
	sw $s6, 24($sp)					
	sw $fp, 28($sp)						
	sw $ra, 32($sp)						
	addu $fp, $sp, 36					

	move $s0, $a0		# load value of address into s1
	li $t0, 0			# initialize for math
	li $s6, 0			# rows
	li $s7, 0			# columns
	move $s4, $a1		# counter

	rollDice:
		jal random				# get rowIndex
		move $s6, $v0	
		jal random				# get colIndex
		move $s7, $v0	

		mul $t0, $s6, 6			# rowIndex * colSize
		add $t0, $t0, $s7		# ... + colIndex
		mul $t0, $t0, 4			# ... * data_size

		move $s1, $s0			# move array address
		add $s1, $s1, $t0		# ... + baseAddr

		lw $s3, ($s1)			# grab number @ location in dice matrix
		addu $s3, $s3, 1		# increment
		sw $s3, ($s1)			# reset back to origin addr

		sub $s4, $s4, 1
	bne $s4, 0, rollDice		# if (rolls > 0), loop

	# pop
	lw $s0, 0($sp)				
	lw $s1, 4($sp)					
	lw $s2, 8($sp)					
	lw $s3, 12($sp)					
	lw $s4, 16($sp)					
	lw $s5, 20($sp)					
	lw $s6, 24($sp)					
	lw $fp, 28($sp)					
	lw $ra, 32($sp)					
	addu $sp, $sp, 36				

	jr $ra							

.end throwDice


######################################################
#  Procedure to calculate sums, percentages, and display the
#   two-dimensional matrix showing the results.

#  Arguments:
#	$a0 - starting address of dice matrix
#	$a1 - number of rolls

.globl	results
.ent	results
results:
	# push
	subu $sp, $sp, 40					
	sw $s0, 0($sp)						
	sw $s1, 4($sp)						
	sw $s2, 8($sp)						
	sw $s3, 12($sp)						
	sw $s4, 16($sp)						
	sw $s5, 20($sp)						
	sw $s6, 24($sp)						
	sw $s7, 28($sp)						
	sw $fp, 32($sp)						
	sw $ra, 36($sp)						
	addu $fp, $sp, 40					

	move $s7, $a0						# grab array address
	#---PRINT INSTRUCTIONS---#
	la	$a0, r_hdr
	li	$v0, 4
	syscall

	lw $a0, rolls			# prints roll amount
	li $v0, 1
	syscall 

	la	$a0, new_ln
	li	$v0, 4
	syscall
	#------------------------#
	#---TABLE PRINT----------#
	la	$a0, r_top
	li	$v0, 4
	syscall

	li $s1, 0
	li $s2, 0

	printBar:#-------------#
		la $a0, bar
		li $v0, 4
		syscall

	printNum:#-------------#
		la $a0, blnks4					
		li $v0, 4
		syscall
		
		b calcAddr
		contForm:

		lw $s3, ($s0)		# get value
		move $a0, $s3		# print value
		li $v0, 1
		syscall

		la $a0, bar
		li $v0, 4
		syscall

		b sumIt				# perform sum calculations
		contSum:

		add $s2, $s2, 1		# column++

		bne $s2, 6, printNum	# while columns < 6

	formatCont:
		la $a0, new_ln	
		li $v0, 4
		syscall

		add $s1, $s1, 1
		li $s2, 0
		bne $s1, 6, printBar	# if row is not last row, print another row
		
		#else continue

		la $a0, r_top
		li $v0, 4
		syscall	

		la $a0, pctHdr				
		li $v0, 4
		syscall			
		
		li $t0, 2				# loop counter
		li $t1, 12				# max
		la $s6, sums			# sum addr
	listPrint:
		la	$a0, blnks5				# insert 4 blanks for formatting
		li	$v0, 4
		syscall

		move $a0, $t0				# prints list number
		li $v0, 1
		syscall 
	
		blt $t0, 10, skipF			# if counter < 10, proceed with regular format
		
		#else, change format
		la	$a0, colon2				# inserts :
		li	$v0, 4
		syscall

		la	$a0, blnks1				# insert 3 blanks for formatting
		li	$v0, 4
		syscall

		b formatEnd					# skip regular format step

		skipF:
		la	$a0, colon				# inserts :
		li	$v0, 4
		syscall

		la	$a0, blnks2				# insert 4 blanks for formatting
		li	$v0, 4
		syscall

		formatEnd:

		b aveCalc					# go perform average calculation
		aveCont:

		mov.s $f12, $f0 			# display average calculation	
		li $v0, 2
		syscall							

		la	$a0, new_ln
		li	$v0, 4
		syscall

		addu $s6, $s6, 4				# sum addr
		addu $t0, $t0, 1			# counter++

		ble $t0, $t1, listPrint

	b endPrint

	#--JUMPS------------#
	calcAddr:
		mul $t0, $s1, 6		# row * colSize
		add $t0, $t0, $s2	# ... + col
		mul $t0, $t0, 4		# ... * 4 (word-size)
		move $s0, $s7
		add $s0, $s0, $t0	# new address

	b contForm

	sumIt:
		add $t9, $s1, $s2		# row + col
		add $t9, $t9, 2			# ... + 2
		mul $t9, $t9, 4			# ... * 4
		sub $t9, $t9, 8			# ... - base addr

		la $t8, sums			# grab sum list addr
		add $t8, $t8, $t9		# sumaddr = sumaddr + newsumaddr
		lw $t7, ($t8)			# get the value
		add $t7, $t7, $s3		# sum = sum + arr(r)(c)
		sw $t7, ($t8)			# save value into sum
	b contSum

	aveCalc:
		lw $t5, rolls			# grab roll value
		lw $t6, ($s6)			# grab sum value

		mtc1 $t5, $f0			# convert rolls to float
		cvt.s.w $f0, $f0

		mtc1 $t6, $f1			# convert sum value to float
		cvt.s.w $f1, $f1

		div.s $f0, $f1, $f0		# sum / rolls
		l.s $f2, hundred
		mul.s $f0, $f0, $f2		# sum * 100
		b aveCont
	#-----------------------#

	endPrint:
	# pop
	lw $s0, 0($sp)				
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	lw $fp, 32($sp)
	lw $ra, 36($sp)
	addu $sp, $sp, 40

	jr $ra

.end results

######################################################

