OUTPUT_ARCH(mips)
ENTRY(_start)

MEMORY
{
        rom (rx)  : ORIGIN = 0x00000000, /* x_INST_BASE_ADDR */
                    LENGTH = 0x00004000, /* x_INST_MEM_SZ */
        ram (!rx) : ORIGIN = 0x00040000, /* x_DATA_BASE_ADDR */
                    LENGTH = 0x00040000  /* x_DATA_MEM_SZ */
}

SECTIONS
{
       .text :
       {
          *(.text .text.*)
          _etext = . ;         /* end of text constant (from Xinu) */

       }                                   > rom

       .rodata  : { *(.rodata .rodata.*) } > ram
       .rodata1 : { *(.rodata1) }          > ram
       .data ALIGN(0x10) : 
       {
          *(.data .data.*) 
          _edata = . ;         /* end of data constant  (from Xinu) */
       }                                   > ram
       .data1   : { *(.data1) }            > ram
       .sdata   : { *(.sdata .sdata.*) }   > ram
       .lit8    : { *(.lit8) }             > ram
       .lit4    : { *(.lit4) }             > ram
       .sbss    : { *(.sbss .sbss.*) *(.scommon .scommon.*) }  > ram
       .bss ALIGN(0x10) :
       {
          *(.bss .bss.*) *(COMMON) 
          _end = . ;           /* end of image constant  (from Xinu) */

       }                                   > ram
}
