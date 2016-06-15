	.file	1 "core0.c"
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
	.frame	$sp,32,$31		# vars= 0, regs= 3/0, args= 16, gp= 0
	.mask	0x80030000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$17,24($sp)
	sw	$16,20($sp)
	move	$16,$0
	li	$17,312			# 0x138
$L2:
	jal	bcdWSt
	nop

	beq	$2,$0,$L2
	nop

	beq	$16,$0,$L6
	move	$6,$16

	li	$2,1			# 0x1
	li	$3,1			# 0x1
	move	$4,$0
	move	$5,$4
$L11:
	addu	$4,$4,$3
	addiu	$2,$2,1
	move	$3,$5
	sltu	$5,$6,$2
	beq	$5,$0,$L11
	move	$5,$4

	b	$L3
	nop

$L6:
	move	$4,$0
$L3:
	jal	bcdWWr
	addiu	$16,$16,1

	bne	$16,$17,$L2
	move	$2,$0

	lw	$31,28($sp)
	lw	$17,24($sp)
	lw	$16,20($sp)
	j	$31
	addiu	$sp,$sp,32

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 5.1.0"
