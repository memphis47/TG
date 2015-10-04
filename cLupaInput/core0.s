	.file	1 "core0.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=32
	.module	nooddspreg
	.text
	.align	2
	.globl	contrasteVerde
	.set	nomips16
	.set	nomicromips
	.ent	contrasteVerde
	.type	contrasteVerde, @function
contrasteVerde:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	srl	$2,$4,24
	sra	$5,$4,16
	andi	$5,$5,0xff
	addu	$2,$5,$2
	sll	$2,$2,1
	addu	$2,$2,$5
	sra	$3,$4,8
	andi	$3,$3,0xff
	addu	$4,$2,$3
	li	$2,7			# 0x7
	bne	$2,$0,1f
	div	$0,$4,$2
	break	7
1:
	mflo	$4
	nop
	nop
	mult	$4,$5
	mflo	$4
	li	$2,255			# 0xff
	nop
	bne	$2,$0,1f
	divu	$0,$4,$2
	break	7
1:
	mflo	$4
	mflo	$2
	sltu	$4,$4,127
	beq	$4,$0,$L2
	nop

	move	$2,$0
$L2:
	sll	$2,$2,16
	j	$31
	ori	$2,$2,0xff

	.set	macro
	.set	reorder
	.end	contrasteVerde
	.size	contrasteVerde, .-contrasteVerde
	.align	2
	.globl	contrasteVermelho
	.set	nomips16
	.set	nomicromips
	.ent	contrasteVermelho
	.type	contrasteVermelho, @function
contrasteVermelho:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	srl	$2,$4,24
	sra	$3,$4,16
	andi	$5,$3,0xff
	addu	$3,$5,$2
	sll	$3,$3,1
	addu	$3,$3,$5
	sra	$4,$4,8
	andi	$4,$4,0xff
	addu	$4,$3,$4
	li	$3,6			# 0x6
	bne	$3,$0,1f
	div	$0,$4,$3
	break	7
1:
	mflo	$4
	nop
	nop
	mult	$4,$2
	mflo	$4
	li	$2,255			# 0xff
	nop
	bne	$2,$0,1f
	divu	$0,$4,$2
	break	7
1:
	mflo	$2
	sll	$2,$2,24
	j	$31
	ori	$2,$2,0xff

	.set	macro
	.set	reorder
	.end	contrasteVermelho
	.size	contrasteVermelho, .-contrasteVermelho
	.align	2
	.globl	contrasteCinza
	.set	nomips16
	.set	nomicromips
	.ent	contrasteCinza
	.type	contrasteCinza, @function
contrasteCinza:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	sra	$2,$4,16
	andi	$3,$2,0xff
	sra	$2,$4,8
	andi	$2,$2,0xff
	addu	$2,$3,$2
	srl	$4,$4,24
	addu	$4,$2,$4
	li	$2,3			# 0x3
	bne	$2,$0,1f
	div	$0,$4,$2
	break	7
1:
	mflo	$4
	sll	$2,$4,24
	sll	$3,$4,16
	or	$2,$2,$3
	ori	$2,$2,0xff
	sll	$4,$4,8
	j	$31
	or	$2,$2,$4

	.set	macro
	.set	reorder
	.end	contrasteCinza
	.size	contrasteCinza, .-contrasteCinza
	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$sp,80,$31		# vars= 24, regs= 10/0, args= 16, gp= 0
	.mask	0xc0ff0000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-80
	sw	$31,76($sp)
	sw	$fp,72($sp)
	sw	$23,68($sp)
	sw	$22,64($sp)
	sw	$21,60($sp)
	sw	$20,56($sp)
	sw	$19,52($sp)
	sw	$18,48($sp)
	sw	$17,44($sp)
	sw	$16,40($sp)
	li	$23,3			# 0x3
	lui	$fp,%hi(zoomCfg)
	addiu	$2,$fp,%lo(zoomCfg)
	sw	$2,16($sp)
	lui	$19,%hi(contrastecfg)
	addiu	$2,$19,%lo(contrastecfg)
	sw	$2,20($sp)
	li	$2,262144			# 0x40000
	addiu	$2,$2,512
	sw	$2,24($sp)
	lui	$18,%hi(img)
	sw	$2,28($sp)
	li	$2,65536			# 0x10000
	addiu	$2,$2,11264
	sw	$2,32($sp)
$L24:
	lw	$4,16($sp)
	jal	readInt
	nop

	lw	$4,20($sp)
	jal	readInt
	nop

	li	$6,19200			# 0x4b00
	lw	$4,24($sp)
	jal	dmaUSB_init
	li	$5,4			# 0x4

	jal	dmaUSB_st
	nop

	beq	$2,$0,$L6
	nop

$L30:
	jal	dmaUSB_st
	nop

	bne	$2,$0,$L30
	nop

$L6:
	lw	$2,28($sp)
	nop
	sw	$2,%lo(img)($18)
	lw	$16,%lo(zoomCfg)($fp)
	nop
	bne	$16,$0,$L26
	li	$17,19680			# 0x4ce0

	li	$20,2			# 0x2
	li	$17,3			# 0x3
$L27:
	jal	bcdWSt
	nop

	bne	$2,$0,$L9
	nop

$L28:
	jal	bcdWSt
	nop

	beq	$2,$0,$L28
	nop

$L9:
	lw	$2,%lo(img)($18)
	nop
	addu	$2,$2,$16
	lw	$4,0($2)
	lw	$2,%lo(contrastecfg)($19)
	nop
	beq	$2,$20,$L12
	nop

	beq	$2,$17,$L13
	li	$3,1			# 0x1

	bne	$2,$3,$L11
	nop

	jal	contrasteVermelho
	nop

	b	$L11
	move	$4,$2

$L12:
	jal	contrasteVerde
	nop

	b	$L11
	move	$4,$2

$L13:
	jal	contrasteCinza
	nop

	move	$4,$2
$L11:
	jal	bcdWWr
	addiu	$16,$16,4

	lw	$2,32($sp)
	nop
	bne	$16,$2,$L27
	nop

	b	$L39
	addiu	$23,$23,-1

$L23:
	jal	bcdWSt
	nop

	bne	$2,$0,$L17
	nop

$L29:
	jal	bcdWSt
	nop

	beq	$2,$0,$L29
	nop

$L17:
	lw	$2,%lo(img)($18)
	nop
	addu	$2,$2,$16
	lw	$4,0($2)
	lw	$2,%lo(contrastecfg)($19)
	nop
	beq	$2,$20,$L20
	nop

	beq	$2,$21,$L21
	nop

	bne	$2,$22,$L19
	nop

	jal	contrasteVermelho
	nop

	b	$L19
	move	$4,$2

$L20:
	jal	contrasteVerde
	nop

	b	$L19
	move	$4,$2

$L21:
	jal	contrasteCinza
	nop

	move	$4,$2
$L19:
	jal	bcdWWr
	addiu	$16,$16,4

	bne	$16,$17,$L23
	li	$2,58080			# 0xe2e0

	addiu	$17,$17,640
	bne	$17,$2,$L8
	nop

	b	$L16
	addiu	$23,$23,-1

$L26:
	li	$20,2			# 0x2
	li	$21,3			# 0x3
	li	$22,1			# 0x1
$L8:
	b	$L23
	addiu	$16,$17,-320

$L16:
$L39:
	bne	$23,$0,$L24
	nop

$L37:
	b	$L37
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main

	.comm	img,4,4

	.comm	contrastecfg,4,4

	.comm	zoomCfg,4,4

	.comm	totalPixelImg,4,4
	.ident	"GCC: (GNU) 5.1.0"
