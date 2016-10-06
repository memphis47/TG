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
	li	$18,311			# 0x137
	li	$17,101			# 0x65
$L2:
	jal	bcdRSt
	nop

	beq	$2,$0,$L2
	nop

	jal	bcdRRd
	nop

	andi	$4,$18,0xffff
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
	srl	$18,$18,16
	addu	$18,$2,$18
	andi	$2,$17,0xffff
	sll	$4,$2,4
	sll	$2,$2,6
	addu	$3,$4,$2
	sll	$2,$3,4
	subu	$2,$2,$3
	sll	$3,$2,4
	subu	$2,$3,$2
	srl	$17,$17,16
	addu	$17,$2,$17
	andi	$16,$17,0x1f
	sll	$2,$16,2
	sll	$3,$16,4
	subu	$3,$3,$2
	subu	$3,$3,$16
	sll	$2,$3,4
	addu	$3,$3,$2
	bne	$3,$0,$L7
	sll	$2,$16,2

	li	$16,1			# 0x1
	sll	$2,$16,2
$L7:
	sll	$3,$16,4
	subu	$2,$3,$2
	subu	$2,$2,$16
	sll	$16,$2,4
	addu	$16,$2,$16
	jal	print
	move	$4,$16

	jal	cmips_delay
	move	$4,$16

	b	$L2
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 5.1.0"
