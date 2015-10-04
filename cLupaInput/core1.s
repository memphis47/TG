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
	.frame	$sp,72,$31		# vars= 16, regs= 10/0, args= 16, gp= 0
	.mask	0xc0ff0000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-72
	sw	$31,68($sp)
	sw	$fp,64($sp)
	sw	$23,60($sp)
	sw	$22,56($sp)
	sw	$21,52($sp)
	sw	$20,48($sp)
	sw	$19,44($sp)
	sw	$18,40($sp)
	sw	$17,36($sp)
	sw	$16,32($sp)
	li	$2,262144			# 0x40000
	addiu	$2,$2,512
	lui	$3,%hi(img)
	sw	$2,%lo(img)($3)
	li	$fp,3			# 0x3
	lui	$2,%hi(zoomCfg)
	sw	$2,16($sp)
	addiu	$2,$2,%lo(zoomCfg)
	sw	$2,20($sp)
	lui	$2,%hi(contrastecfg)
	addiu	$2,$2,%lo(contrastecfg)
	sw	$2,24($sp)
	move	$17,$3
	lui	$19,%hi(mem)
$L12:
	lw	$4,20($sp)
	jal	readInt
	nop

	lw	$4,24($sp)
	jal	readInt
	nop

	lw	$2,16($sp)
	nop
	lw	$16,%lo(zoomCfg)($2)
	nop
	bne	$16,$0,$L13
	move	$23,$0

	li	$18,65536			# 0x10000
	addiu	$18,$18,11264
$L15:
	jal	bcdRSt
	nop

	bne	$2,$0,$L3
	nop

$L16:
	jal	bcdRSt
	nop

	beq	$2,$0,$L16
	nop

$L3:
	jal	bcdRRd
	nop

	lw	$3,%lo(img)($17)
	nop
	addu	$3,$3,$16
	sw	$3,%lo(mem)($19)
	addiu	$16,$16,4
	bne	$16,$18,$L15
	sw	$2,0($3)

	b	$L25
	li	$6,19200			# 0x4b00

$L9:
	jal	bcdRSt
	nop

	bne	$2,$0,$L7
	nop

$L17:
	jal	bcdRSt
	nop

	beq	$2,$0,$L17
	nop

$L7:
	jal	bcdRRd
	nop

	lw	$3,%lo(img)($17)
	nop
	addu	$3,$3,$16
	sw	$2,0($3)
	lw	$3,%lo(img)($17)
	nop
	addu	$3,$3,$16
	sw	$2,4($3)
	lw	$3,%lo(img)($17)
	nop
	addu	$3,$3,$16
	addu	$3,$3,$18
	sw	$2,0($3)
	addu	$4,$20,$16
	lw	$3,%lo(img)($17)
	nop
	addu	$3,$3,$4
	sw	$3,%lo(mem)($19)
	addiu	$16,$16,8
	bne	$21,$16,$L9
	sw	$2,0($3)

	addiu	$22,$22,320
	li	$2,19360			# 0x4ba0
	bne	$22,$2,$L2
	addiu	$23,$23,320

	b	$L6
	li	$6,19200			# 0x4b00

$L13:
	li	$22,160			# 0xa0
$L2:
	sll	$16,$23,2
	sll	$21,$22,2
	subu	$18,$22,$23
	sll	$18,$18,2
	b	$L9
	addiu	$20,$18,4

$L6:
$L25:
	li	$5,4			# 0x4
	li	$4,262144			# 0x40000
	jal	dmaVGA_init
	addiu	$4,$4,512

	jal	dmaVGA_st
	nop

	beq	$2,$0,$L10
	nop

$L14:
	jal	dmaVGA_st
	nop

	bne	$2,$0,$L14
	nop

$L10:
	addiu	$fp,$fp,-1
	bne	$fp,$0,$L12
	nop

	jal	dmaVGA_closeFile
	nop

	move	$2,$0
	lw	$31,68($sp)
	lw	$fp,64($sp)
	lw	$23,60($sp)
	lw	$22,56($sp)
	lw	$21,52($sp)
	lw	$20,48($sp)
	lw	$19,44($sp)
	lw	$18,40($sp)
	lw	$17,36($sp)
	lw	$16,32($sp)
	j	$31
	addiu	$sp,$sp,72

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main

	.comm	contrastecfg,4,4

	.comm	zoomCfg,4,4

	.comm	mem,4,4

	.comm	img,4,4
	.ident	"GCC: (GNU) 5.1.0"
