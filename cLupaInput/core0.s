	.file	1 "core0.c"
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
	.globl	findPrimo
	.set	nomips16
	.set	nomicromips
	.ent	findPrimo
	.type	findPrimo, @function
findPrimo:
	.frame	$sp,32,$31		# vars= 0, regs= 4/0, args= 16, gp= 0
	.mask	0x80070000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$18,24($sp)
	sw	$17,20($sp)
	blez	$4,$L11
	sw	$16,16($sp)

	move	$17,$4
	move	$16,$0
	li	$18,1			# 0x1
$L10:
	jal	primo
	move	$4,$16

	beq	$2,$18,$L14
	move	$2,$16

	addiu	$16,$16,1
	bne	$17,$16,$L10
	nop

	b	$L9
	move	$16,$17

$L11:
	move	$16,$0
$L9:
	move	$2,$16
$L14:
	lw	$31,28($sp)
	lw	$18,24($sp)
	lw	$17,20($sp)
	lw	$16,16($sp)
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
	.frame	$sp,48,$31		# vars= 8, regs= 5/0, args= 16, gp= 0
	.mask	0x800f0000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-48
	sw	$31,44($sp)
	sw	$19,40($sp)
	sw	$18,36($sp)
	sw	$17,32($sp)
	sw	$16,28($sp)
	move	$19,$0
	move	$18,$0
	li	$17,312			# 0x138
$L16:
	jal	bcdWSt
	nop

	sw	$2,16($sp)
	lw	$2,16($sp)
	nop
	beq	$2,$0,$L16
	slt	$2,$19,312

	beq	$2,$0,$L17
	move	$16,$19

$L21:
	jal	print
	move	$4,$16

	slt	$2,$16,3
	bne	$2,$0,$L18
	srl	$4,$16,31

	addu	$4,$4,$16
	sra	$4,$4,1
	slt	$2,$4,2
	bne	$2,$0,$L19
	li	$2,2			# 0x2

$L20:
	bne	$2,$0,1f
	div	$0,$16,$2
	break	7
1:
	mfhi	$3
	beq	$3,$0,$L18
	addiu	$2,$2,1

	slt	$3,$4,$2
	beq	$3,$0,$L20
	nop

$L19:
	slt	$2,$18,$16
	bne	$2,$0,$L23
	nop

$L18:
	addiu	$16,$16,1
	bne	$16,$17,$L21
	nop

	b	$L17
	nop

$L23:
	move	$18,$16
$L17:
	jal	print
	move	$4,$18

	jal	bcdWWr
	move	$4,$18

	addiu	$19,$19,1
	bne	$19,$17,$L16
	move	$2,$0

	lw	$31,44($sp)
	lw	$19,40($sp)
	lw	$18,36($sp)
	lw	$17,32($sp)
	lw	$16,28($sp)
	j	$31
	addiu	$sp,$sp,48

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 5.1.0"
