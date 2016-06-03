	.file	1 "core1.c"
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
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	beq	$4,$0,$L4
	li	$5,1			# 0x1

	move	$3,$0
	li	$6,1			# 0x1
$L3:
	addu	$2,$6,$3
	addiu	$5,$5,1
	move	$6,$3
	sltu	$7,$4,$5
	beq	$7,$0,$L3
	move	$3,$2

	j	$31
	nop

$L4:
	j	$31
	move	$2,$0

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
	li	$16,312			# 0x138
$L9:
	jal	bcdRSt
	nop

	move	$17,$2
	jal	print
	move	$4,$2

	bne	$17,$0,$L7
	nop

$L10:
	jal	print
	move	$4,$0

	jal	bcdRSt
	nop

	beq	$2,$0,$L10
	nop

$L7:
	jal	bcdRRd
	addiu	$16,$16,-1

	jal	fibonacci
	move	$4,$2

	bne	$16,$0,$L9
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
