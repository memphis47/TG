	.file	1 "core1.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=32
	.module	nooddspreg
	.text
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
	li	$16,48			# 0x30
$L2:
	jal	bcdRSt
	nop

	beq	$2,$0,$L2
	nop

	jal	print
	li	$4,15			# 0xf

	jal	bcdRRd
	nop

	slt	$3,$2,3
	bne	$3,$0,$L3
	nop

	srl	$5,$2,31
	addu	$5,$5,$2
	sra	$5,$5,1
	slt	$3,$5,2
	bne	$3,$0,$L3
	nop

	li	$3,2			# 0x2
$L4:
	bne	$3,$0,1f
	div	$0,$2,$3
	break	7
1:
	mfhi	$4
	beq	$4,$0,$L3
	nop

	addiu	$3,$3,1
	slt	$4,$5,$3
	beq	$4,$0,$L4
	nop

$L3:
	addiu	$16,$16,-1
	bne	$16,$0,$L2
	move	$2,$0

	lw	$31,20($sp)
	lw	$16,16($sp)
	j	$31
	addiu	$sp,$sp,24

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 5.1.0"
