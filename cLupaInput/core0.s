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
	.frame	$sp,40,$31		# vars= 8, regs= 4/0, args= 16, gp= 0
	.mask	0x80070000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-40
	sw	$31,36($sp)
	sw	$18,32($sp)
	sw	$17,28($sp)
	sw	$16,24($sp)
	li	$17,311			# 0x137
	li	$16,177			# 0xb1
	andi	$4,$17,0xffff
$L6:
	sll	$2,$4,2
	sll	$3,$4,4
	addu	$2,$2,$3
	sll	$3,$2,3
	subu	$2,$3,$2
	sll	$3,$2,5
	addu	$2,$2,$3
	addu	$2,$2,$4
	sll	$2,$2,3
	addu	$2,$2,$4
	srl	$17,$17,16
	addu	$17,$2,$17
	jal	print
	move	$4,$17

	andi	$2,$16,0xffff
	sll	$4,$2,4
	sll	$2,$2,6
	addu	$3,$4,$2
	sll	$2,$3,4
	subu	$2,$2,$3
	sll	$3,$2,4
	subu	$2,$3,$2
	srl	$16,$16,16
	addu	$16,$2,$16
	jal	print
	move	$4,$16

	andi	$18,$16,0x3f
	jal	print
	move	$4,$18

	jal	print
	move	$4,$18

	jal	print
	li	$4,1			# 0x1

	jal	print
	li	$4,1			# 0x1

	sll	$4,$18,3
	sll	$2,$18,5
	subu	$2,$2,$4
	addu	$2,$2,$18
	sll	$4,$2,4
	jal	cmips_delay
	subu	$4,$4,$2

	jal	print
	li	$4,1			# 0x1

$L2:
	jal	bcdWSt
	nop

	sw	$2,16($sp)
	lw	$2,16($sp)
	nop
	beq	$2,$0,$L2
	nop

	jal	print
	li	$4,1			# 0x1

	jal	bcdWWr
	li	$4,1			# 0x1

	b	$L6
	andi	$4,$17,0xffff

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 5.1.0"
