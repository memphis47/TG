	.file	1 "core0.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=32
	.module	nooddspreg
	.text
	.align	2
	.globl	fibonacci
	.set	nomips16
	.set	nomicromips
	.ent	fibonacci
	.type	fibonacci, @function
fibonacci:
	.frame	$sp,32,$31		# vars= 0, regs= 3/0, args= 16, gp= 0
	.mask	0x80030000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	slt	$2,$4,2
	bne	$2,$0,$L3
	nop

	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$17,24($sp)
	sw	$16,20($sp)
	move	$16,$4
	jal	fibonacci
	addiu	$4,$4,-1

	move	$17,$2
	jal	fibonacci
	addiu	$4,$16,-2

	b	$L2
	addu	$2,$17,$2

$L3:
	j	$31
	move	$2,$4

$L2:
	lw	$31,28($sp)
	lw	$17,24($sp)
	lw	$16,20($sp)
	j	$31
	addiu	$sp,$sp,32

	.set	macro
	.set	reorder
	.end	fibonacci
	.size	fibonacci, .-fibonacci
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
	li	$17,200			# 0xc8
$L9:
	jal	bcdWSt
	nop

	bne	$2,$0,$L7
	nop

$L10:
	jal	bcdWSt
	nop

	beq	$2,$0,$L10
	nop

$L7:
	jal	fibonacci
	move	$4,$16

	jal	bcdWWr
	move	$4,$2

	addiu	$16,$16,1
	bne	$16,$17,$L9
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
