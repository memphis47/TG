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
	li	$17,177			# 0xb1
$L2:
	jal	bcdWSt
	nop

	beq	$2,$0,$L2
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
	andi	$16,$17,0x3f
	sll	$2,$16,2
	sll	$3,$16,4
	subu	$2,$3,$2
	subu	$2,$2,$16
	sll	$16,$2,4
	addu	$16,$2,$16
	jal	cmips_delay
	move	$4,$16

	jal	bcdWWr
	move	$4,$16

	b	$L2
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 5.1.0"
