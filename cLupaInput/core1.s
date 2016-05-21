	.file	1 "core1.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=32
	.module	nooddspreg
	.text
	.align	2
	.globl	primo
	.set	nomips16
	.set	nomicromips
	.ent	primo
	.type	primo, @function
primo:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	slt	$2,$4,3
	bne	$2,$0,$L4
	srl	$5,$4,31

	addu	$5,$5,$4
	sra	$5,$5,1
	slt	$2,$5,2
	bne	$2,$0,$L5
	nop

	li	$2,2			# 0x2
$L3:
	bne	$2,$0,1f
	div	$0,$4,$2
	break	7
1:
	mfhi	$3
	beq	$3,$0,$L6
	nop

	addiu	$2,$2,1
	slt	$3,$5,$2
	beq	$3,$0,$L3
	nop

	j	$31
	li	$2,1			# 0x1

$L4:
	j	$31
	move	$2,$0

$L5:
	j	$31
	li	$2,1			# 0x1

$L6:
	j	$31
	move	$2,$0

	.set	macro
	.set	reorder
	.end	primo
	.size	primo, .-primo
	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$sp,24,$31		# vars= 0, regs= 2/0, args= 16, gp= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-24
	sw	$31,20($sp)
	sw	$16,16($sp)
$L11:
	jal	bcdRSt
	nop

	bne	$2,$0,$L9
	nop

$L12:
	jal	bcdRSt
	nop

	beq	$2,$0,$L12
	nop

$L9:
	jal	bcdRRd
	nop

	move	$16,$2
	jal	print
	move	$4,$2

	jal	primo
	move	$4,$16

	jal	print
	move	$4,$2

	b	$L11
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 5.1.0"
