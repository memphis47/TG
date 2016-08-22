	.file	1 "core1.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=32
	.module	nooddspreg
	.text
	.align	2
	.globl	rand
	.set	nomips16
	.set	nomicromips
	.ent	rand
	.type	rand, @function
rand:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	lw	$7,0($4)
	nop
	andi	$8,$7,0xffff
	sll	$2,$8,2
	sll	$3,$8,4
	addu	$2,$2,$3
	sll	$6,$2,3
	subu	$2,$6,$2
	sll	$3,$2,5
	addu	$3,$2,$3
	addu	$3,$3,$8
	sll	$3,$3,3
	addu	$3,$3,$8
	sra	$2,$7,16
	addu	$2,$3,$2
	sw	$2,0($4)
	lw	$7,0($5)
	nop
	andi	$3,$7,0xffff
	sll	$2,$3,4
	sll	$3,$3,6
	addu	$3,$2,$3
	sll	$2,$3,4
	subu	$3,$2,$3
	sll	$6,$3,4
	subu	$6,$6,$3
	sra	$3,$7,16
	addu	$3,$6,$3
	sw	$3,0($5)
	lw	$2,0($4)
	nop
	sll	$2,$2,16
	j	$31
	addu	$2,$2,$3

	.set	macro
	.set	reorder
	.end	rand
	.size	rand, .-rand
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
$L3:
	jal	bcdRSt
	nop

	beq	$2,$0,$L3
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

	b	$L3
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 5.1.0"
