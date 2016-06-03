	.file	1 "core0.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=32
	.module	nooddspreg
	.text
	.align	2
	.globl	findPrimo
	.set	nomips16
	.set	nomicromips
	.ent	findPrimo
	.type	findPrimo, @function
findPrimo:
	.frame	$sp,32,$31		# vars= 0, regs= 3/0, args= 16, gp= 0
	.mask	0x80030000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$17,24($sp)
	blez	$4,$L6
	sw	$16,20($sp)

	move	$17,$4
	move	$16,$0
$L5:
	jal	print
	move	$4,$16

	slt	$2,$16,3
	bne	$2,$0,$L3
	srl	$5,$16,31

	addu	$5,$5,$16
	sra	$5,$5,1
	slt	$2,$5,2
	bne	$2,$0,$L2
	li	$2,2			# 0x2

$L4:
	bne	$2,$0,1f
	div	$0,$16,$2
	break	7
1:
	mfhi	$3
	beq	$3,$0,$L3
	addiu	$2,$2,1

	slt	$3,$5,$2
	beq	$3,$0,$L4
	nop

	b	$L10
	move	$2,$16

$L3:
	addiu	$16,$16,1
	bne	$17,$16,$L5
	nop

	b	$L2
	move	$16,$17

$L6:
	move	$16,$0
$L2:
	move	$2,$16
$L10:
	lw	$31,28($sp)
	lw	$17,24($sp)
	lw	$16,20($sp)
	j	$31
	addiu	$sp,$sp,32

	.set	macro
	.set	reorder
	.end	findPrimo
	.size	findPrimo, .-findPrimo
	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$sp,32,$31		# vars= 0, regs= 4/0, args= 16, gp= 0
	.mask	0x80070000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$18,24($sp)
	sw	$17,20($sp)
	sw	$16,16($sp)
	move	$16,$0
	li	$18,312			# 0x138
$L14:
	jal	bcdWSt
	nop

	move	$17,$2
	jal	print
	move	$4,$2

	bne	$17,$0,$L12
	nop

$L15:
	jal	print
	li	$4,12			# 0xc

	jal	print
	move	$4,$0

	jal	print
	li	$4,12			# 0xc

	jal	bcdWSt
	nop

	beq	$2,$0,$L15
	nop

$L12:
	jal	findPrimo
	move	$4,$16

	move	$17,$2
	jal	print
	li	$4,10			# 0xa

	jal	print
	move	$4,$17

	jal	print
	li	$4,10			# 0xa

	jal	bcdWWr
	move	$4,$17

	addiu	$16,$16,1
	bne	$16,$18,$L14
	move	$2,$0

	lw	$31,28($sp)
	lw	$18,24($sp)
	lw	$17,20($sp)
	lw	$16,16($sp)
	j	$31
	addiu	$sp,$sp,32

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 5.1.0"
