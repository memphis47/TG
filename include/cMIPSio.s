	.file	1 "cMIPSio.c"
	.section .mdebug.abi32
	.previous
	.text
	.align	2
	.globl	print
	.set	nomips16
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
	.ent	to_stdout
	.type	to_stdout, @function
to_stdout:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	sll	$4,$4,24
	sra	$4,$4,24
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
	.ent	from_stdin
	.type	from_stdin, @function
from_stdin:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	lw	$3,64($2)
	lw	$2,68($2)
	nop
	bne	$2,$0,$L5
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
	.ent	readInt
	.type	readInt, @function
readInt:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	lw	$3,96($2)
	lw	$2,100($2)
	nop
	bne	$2,$0,$L8
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
	.globl	startCounter
	.set	nomips16
	.ent	startCounter
	.type	startCounter, @function
startCounter:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	beq	$5,$0,$L13
	move	$2,$0

	li	$2,-2147483648			# 0xffffffff80000000
$L13:
	andi	$4,$4,0xffff
	li	$3,1073741824			# 0x40000000
	or	$4,$4,$3
	or	$4,$4,$2
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
	.ent	stopCounter
	.type	stopCounter, @function
stopCounter:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$2,251658240			# 0xf000000
	lw	$4,160($2)
	li	$3,-1073807360			# 0xffffffffbfff0000
	ori	$3,$3,0xffff
	and	$3,$4,$3
	j	$31
	sw	$3,160($2)

	.set	macro
	.set	reorder
	.end	stopCounter
	.size	stopCounter, .-stopCounter
	.align	2
	.globl	readCounter
	.set	nomips16
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
	.globl	readStats
	.set	nomips16
	.ent	readStats
	.type	readStats, @function
readStats:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	li	$3,251658240			# 0xf000000
	addiu	$2,$3,256
	lw	$3,256($3)
	nop
	sw	$3,0($4)
	lw	$3,4($2)
	nop
	sw	$3,4($4)
	lw	$3,8($2)
	nop
	sw	$3,8($4)
	lw	$3,12($2)
	nop
	sw	$3,12($4)
	lw	$3,16($2)
	nop
	sw	$3,16($4)
	lw	$2,20($2)
	j	$31
	sw	$2,20($4)

	.set	macro
	.set	reorder
	.end	readStats
	.size	readStats, .-readStats
	.align	2
	.globl	bcdWWr
	.set	nomips16
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
	.ident	"GCC: (GNU) 4.8.1"
