	.file	1 "cMIPSio.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=32
	.module	nooddspreg
	.text
	.align	2
	.globl	print
	.set	nomips16
	.set	nomicromips
	.ent	print
	.type	print, @function
print:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	j	$31
	sw	$4,0($2)

	.set	macro
	.set	reorder
	.end	print
	.size	print, .-print
	.align	2
	.globl	to_stdout
	.set	nomips16
	.set	nomicromips
	.ent	to_stdout
	.type	to_stdout, @function
to_stdout:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	andi	$4,$4,0x00ff
	li	$2,251658240			# 0xf000000
	j	$31
	sw	$4,32($2)

	.set	macro
	.set	reorder
	.end	to_stdout
	.size	to_stdout, .-to_stdout
	.align	2
	.globl	from_stdin
	.set	nomips16
	.set	nomicromips
	.ent	from_stdin
	.type	from_stdin, @function
from_stdin:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	lw	$2,68($2)
	nop
	bne	$2,$0,$L5
	li	$3,251658240			# 0xf000000

	lw	$3,64($3)
	nop
	sb	$3,0($4)
$L5:
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	from_stdin
	.size	from_stdin, .-from_stdin
	.align	2
	.globl	readInt
	.set	nomips16
	.set	nomicromips
	.ent	readInt
	.type	readInt, @function
readInt:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	lw	$2,100($2)
	nop
	bne	$2,$0,$L8
	li	$3,251658240			# 0xf000000

	lw	$3,96($3)
	nop
	sw	$3,0($4)
$L8:
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	readInt
	.size	readInt, .-readInt
	.align	2
	.globl	writeInt
	.set	nomips16
	.set	nomicromips
	.ent	writeInt
	.type	writeInt, @function
writeInt:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	j	$31
	sw	$4,128($2)

	.set	macro
	.set	reorder
	.end	writeInt
	.size	writeInt, .-writeInt
	.align	2
	.globl	writeClose
	.set	nomips16
	.set	nomicromips
	.ent	writeClose
	.type	writeClose, @function
writeClose:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$3,1			# 0x1
	li	$2,251658240			# 0xf000000
	j	$31
	sw	$3,132($2)

	.set	macro
	.set	reorder
	.end	writeClose
	.size	writeClose, .-writeClose
	.align	2
	.globl	dumpRAM
	.set	nomips16
	.set	nomicromips
	.ent	dumpRAM
	.type	dumpRAM, @function
dumpRAM:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$3,1			# 0x1
	li	$2,251658240			# 0xf000000
	j	$31
	sb	$3,135($2)

	.set	macro
	.set	reorder
	.end	dumpRAM
	.size	dumpRAM, .-dumpRAM
	.align	2
	.globl	readStats
	.set	nomips16
	.set	nomicromips
	.ent	readStats
	.type	readStats, @function
readStats:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	readStats
	.size	readStats, .-readStats
	.align	2
	.globl	memcpy
	.set	nomips16
	.set	nomicromips
	.ent	memcpy
	.type	memcpy, @function
memcpy:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$3,-2147483648			# 0xffffffff80000000
	addiu	$3,$3,3
	and	$3,$5,$3
	bgez	$3,$L14
	move	$2,$4

	addiu	$3,$3,-1
	li	$4,-4			# 0xfffffffffffffffc
	or	$3,$3,$4
	addiu	$3,$3,1
$L14:
	blez	$3,$L27
	slt	$4,$6,4

	blez	$6,$L35
	move	$7,$2

	addu	$3,$2,$3
$L20:
	lb	$8,0($5)
	nop
	sb	$8,0($7)
	addiu	$6,$6,-1
	addiu	$7,$7,1
	bne	$7,$3,$L17
	addiu	$5,$5,1

	b	$L33
	slt	$4,$6,4

$L27:
	move	$3,$2
$L33:
	beq	$4,$0,$L34
	andi	$7,$3,0x3

	b	$L19
	nop

$L17:
	bne	$6,$0,$L20
	nop

$L37:
	j	$31
	nop

$L25:
	andi	$7,$3,0x3
$L34:
	bne	$7,$0,$L22
	andi	$7,$3,0x1

	lw	$7,0($5)
	b	$L23
	sw	$7,0($3)

$L22:
	bne	$7,$0,$L24
	nop

	lh	$7,0($5)
	nop
	sh	$7,0($3)
	lh	$7,2($5)
	b	$L23
	sh	$7,2($3)

$L24:
	lb	$7,0($5)
	nop
	sb	$7,0($3)
	lh	$7,1($5)
	nop
	sh	$7,1($3)
	lb	$7,3($5)
	nop
	sb	$7,3($3)
$L23:
	addiu	$6,$6,-4
	addiu	$5,$5,4
	slt	$7,$6,4
	beq	$7,$0,$L25
	addiu	$3,$3,4

$L19:
	blez	$6,$L37
	addu	$6,$3,$6

$L26:
	lb	$7,0($5)
	nop
	sb	$7,0($3)
	addiu	$3,$3,1
	bne	$6,$3,$L26
	addiu	$5,$5,1

	j	$31
	nop

$L35:
	beq	$4,$0,$L25
	move	$3,$2

	j	$31
	nop

	.set	macro
	.set	reorder
	.end	memcpy
	.size	memcpy, .-memcpy
	.align	2
	.globl	memset
	.set	nomips16
	.set	nomicromips
	.ent	memset
	.type	memset, @function
memset:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$3,-2147483648			# 0xffffffff80000000
	addiu	$3,$3,3
	and	$3,$4,$3
	bgez	$3,$L39
	move	$2,$4

	addiu	$3,$3,-1
	li	$4,-4			# 0xfffffffffffffffc
	or	$3,$3,$4
	addiu	$3,$3,1
$L39:
	blez	$3,$L48
	nop

	blez	$6,$L41
	move	$7,$2

	addu	$3,$2,$3
$L42:
	sb	$5,0($7)
	addiu	$7,$7,1
	beq	$7,$3,$L40
	addiu	$6,$6,-1

	bne	$6,$0,$L42
	nop

$L55:
	j	$31
	nop

$L48:
	move	$3,$2
$L40:
	sll	$7,$5,8
	sll	$8,$5,16
	or	$8,$7,$8
	or	$7,$8,$5
	sll	$8,$5,24
	slt	$4,$6,4
	bne	$4,$0,$L44
	or	$8,$7,$8

$L45:
	sw	$8,0($3)
	addiu	$6,$6,-4
	slt	$7,$6,4
	beq	$7,$0,$L45
	addiu	$3,$3,4

$L44:
	blez	$6,$L55
	addu	$6,$3,$6

$L46:
	sb	$5,0($3)
	addiu	$3,$3,1
	bne	$6,$3,$L46
	nop

	j	$31
	nop

$L41:
	sll	$3,$5,16
	sll	$4,$5,8
	or	$3,$3,$4
	or	$3,$3,$5
	sll	$8,$5,24
	or	$8,$3,$8
	slt	$4,$6,4
	beq	$4,$0,$L45
	move	$3,$2

	j	$31
	nop

	.set	macro
	.set	reorder
	.end	memset
	.size	memset, .-memset
	.align	2
	.globl	startCounter
	.set	nomips16
	.set	nomicromips
	.ent	startCounter
	.type	startCounter, @function
startCounter:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	bne	$5,$0,$L57
	li	$3,-2147483648			# 0xffffffff80000000

	move	$3,$0
$L57:
	li	$2,1073676288			# 0x3fff0000
	ori	$2,$2,0xffff
	and	$4,$4,$2
	li	$2,1073741824			# 0x40000000
	or	$4,$4,$2
	or	$4,$4,$3
	li	$2,251658240			# 0xf000000
	j	$31
	sw	$4,160($2)

	.set	macro
	.set	reorder
	.end	startCounter
	.size	startCounter, .-startCounter
	.align	2
	.globl	stopCounter
	.set	nomips16
	.set	nomicromips
	.ent	stopCounter
	.type	stopCounter, @function
stopCounter:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$4,251658240			# 0xf000000
	lw	$3,160($4)
	li	$2,-1073807360			# 0xffffffffbfff0000
	ori	$2,$2,0xffff
	and	$2,$3,$2
	j	$31
	sw	$2,160($4)

	.set	macro
	.set	reorder
	.end	stopCounter
	.size	stopCounter, .-stopCounter
	.align	2
	.globl	readCounter
	.set	nomips16
	.set	nomicromips
	.ent	readCounter
	.type	readCounter, @function
readCounter:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	lw	$2,160($2)
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	readCounter
	.size	readCounter, .-readCounter
	.align	2
	.globl	bcdWWr
	.set	nomips16
	.set	nomicromips
	.ent	bcdWWr
	.type	bcdWWr, @function
bcdWWr:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	j	$31
	sw	$4,352($2)

	.set	macro
	.set	reorder
	.end	bcdWWr
	.size	bcdWWr, .-bcdWWr
	.align	2
	.globl	bcdWSt
	.set	nomips16
	.set	nomicromips
	.ent	bcdWSt
	.type	bcdWSt, @function
bcdWSt:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	lw	$2,352($2)
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	bcdWSt
	.size	bcdWSt, .-bcdWSt
	.align	2
	.globl	bcdRRd
	.set	nomips16
	.set	nomicromips
	.ent	bcdRRd
	.type	bcdRRd, @function
bcdRRd:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	lw	$2,384($2)
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	bcdRRd
	.size	bcdRRd, .-bcdRRd
	.align	2
	.globl	bcdRSt
	.set	nomips16
	.set	nomicromips
	.ent	bcdRSt
	.type	bcdRSt, @function
bcdRSt:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	lw	$2,388($2)
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	bcdRSt
	.size	bcdRSt, .-bcdRSt
	.align	2
	.globl	dmaUSB_init
	.set	nomips16
	.set	nomicromips
	.ent	dmaUSB_init
	.type	dmaUSB_init, @function
dmaUSB_init:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	sw	$4,416($2)
	mult	$5,$6
	mflo	$5
	addiu	$5,$5,-1
	sw	$5,420($2)
	j	$31
	sw	$0,424($2)

	.set	macro
	.set	reorder
	.end	dmaUSB_init
	.size	dmaUSB_init, .-dmaUSB_init
	.align	2
	.globl	dmaUSB_st
	.set	nomips16
	.set	nomicromips
	.ent	dmaUSB_st
	.type	dmaUSB_st, @function
dmaUSB_st:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	lw	$2,416($2)
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	dmaUSB_st
	.size	dmaUSB_st, .-dmaUSB_st
	.align	2
	.globl	dmaVGA_init
	.set	nomips16
	.set	nomicromips
	.ent	dmaVGA_init
	.type	dmaVGA_init, @function
dmaVGA_init:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	sw	$4,448($2)
	mult	$5,$6
	mflo	$5
	addiu	$5,$5,-1
	sw	$5,452($2)
	j	$31
	sw	$0,456($2)

	.set	macro
	.set	reorder
	.end	dmaVGA_init
	.size	dmaVGA_init, .-dmaVGA_init
	.align	2
	.globl	dmaVGA_st
	.set	nomips16
	.set	nomicromips
	.ent	dmaVGA_st
	.type	dmaVGA_st, @function
dmaVGA_st:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	lw	$2,448($2)
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	dmaVGA_st
	.size	dmaVGA_st, .-dmaVGA_st
	.align	2
	.globl	dmaVGA_closeFile
	.set	nomips16
	.set	nomicromips
	.ent	dmaVGA_closeFile
	.type	dmaVGA_closeFile, @function
dmaVGA_closeFile:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	lw	$2,460($2)
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	dmaVGA_closeFile
	.size	dmaVGA_closeFile, .-dmaVGA_closeFile
	.ident	"GCC: (GNU) 5.1.0"
