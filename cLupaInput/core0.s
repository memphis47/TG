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
	.frame	$sp,40,$31		# vars= 0, regs= 6/0, args= 16, gp= 0
	.mask	0x801f0000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-40
	sw	$31,36($sp)
	sw	$20,32($sp)
	sw	$19,28($sp)
	sw	$18,24($sp)
	sw	$17,20($sp)
	sw	$16,16($sp)
	li	$20,3			# 0x3
	li	$16,1836253184			# 0x6d730000
	ori	$16,$16,0xe55f
	b	$L2
	li	$19,45			# 0x2d

$L13:
	slt	$2,$3,3
$L17:
	bne	$2,$0,$L3
	nop

	srl	$5,$3,31
	addu	$5,$5,$3
	sra	$5,$5,1
	slt	$2,$5,2
	bne	$2,$0,$L4
	li	$2,2			# 0x2

$L5:
	bne	$2,$0,1f
	div	$0,$3,$2
	break	7
1:
	mfhi	$4
	beq	$4,$0,$L3
	addiu	$2,$2,1

	slt	$4,$5,$2
	beq	$4,$0,$L5
	nop

$L4:
	slt	$2,$17,$3
	bne	$2,$0,$L11
	nop

$L3:
	addiu	$3,$3,1
	bne	$3,$16,$L17
	slt	$2,$3,3

	b	$L6
	nop

$L11:
	move	$17,$3
$L6:
	jal	print
	move	$4,$17

	jal	print
	li	$4,10			# 0xa

	jal	clkcount
	addiu	$18,$18,1

	jal	print
	move	$4,$2

	beq	$18,$19,$L8
	nop

$L10:
	slt	$2,$18,$16
	bne	$2,$0,$L13
	move	$3,$18

	b	$L6
	nop

$L8:
	addiu	$20,$20,-1
	beq	$20,$0,$L9
	move	$2,$0

$L2:
	move	$18,$0
	b	$L10
	move	$17,$0

$L9:
	lw	$31,36($sp)
	lw	$20,32($sp)
	lw	$19,28($sp)
	lw	$18,24($sp)
	lw	$17,20($sp)
	lw	$16,16($sp)
	j	$31
	addiu	$sp,$sp,40

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 5.1.0"
