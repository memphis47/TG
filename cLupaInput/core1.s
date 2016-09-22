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
	li	$17,311			# 0x137
	li	$16,168			# 0xa8
$L2:
	jal	bcdRSt
	nop

	beq	$2,$0,$L2
	nop

	jal	bcdRRd
	nop

	andi	$4,$17,0xffff
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
	andi	$18,$16,0x3f
	jal	print
	move	$4,$18

	sll	$4,$18,2
	sll	$2,$18,4
	subu	$2,$2,$4
	subu	$2,$2,$18
	sll	$4,$2,4
	jal	cmips_delay
	addu	$4,$2,$4

	b	$L2
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 5.1.0"
