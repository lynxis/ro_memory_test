/*---------------------------------------------------------------------------
  Author : Christoph Thelen

           Hilscher GmbH, Copyright (c) 2010, All Rights Reserved

           Redistribution or unauthorized use without expressed written 
           agreement from the Hilscher GmbH is forbidden
---------------------------------------------------------------------------*/

ENTRY(start)

MEMORY
{
	ASSERT_EMPTY(rwx)	: ORIGIN = 0x00000000, LENGTH = 0

	INTRAM2_ITCM(rwx)	: ORIGIN = 0x00020000, LENGTH = 0x00010000
	INTRAM0_DTCM(rwx)	: ORIGIN = 0x04000000, LENGTH = 0x00010000
	INTRAM3_DTCM(rwx)	: ORIGIN = 0x04030000, LENGTH = 0x00010000
	SQIROM(rx)		: ORIGIN = 0x09000000, LENGTH = 0x00400000
}


/* Section Definitions */
SECTIONS
{
	/* These sections must be empty, put them in a memory with a size of
	 * 0 bytes
	 */
	.assert_empty (NOLOAD) :
	{
		/* NOTE: include all sections here which should be empty.
		 */
		*(.data)
		*(.glue*)
		*(.vfp11_veneer)
		*(.v4_bx)
	} >ASSERT_EMPTY

	.code_xip ORIGIN(SQIROM)+0x40 :
	{
		*(.init_code)
	} >SQIROM

	.code_ram ORIGIN(INTRAM2_ITCM) : AT(ORIGIN(SQIROM)+0x40+SIZEOF(.code_xip))
	{
		__copy_start__ = . ;

		*(.text)

		__copy_end__ = . ;
	} >INTRAM2_ITCM
	__copy_loadaddr__ = LOADADDR(.code_ram) ;


	.rodata ORIGIN(SQIROM)+0x40+SIZEOF(.code_xip)+SIZEOF(.code_ram) :
	{
		/* The PRN data must be DWORD aligned. */ 
		. = ALIGN(4);
		*(.prn_rodata)
		
		*(.rodata*)
	} >SQIROM


	.serial_vectors ORIGIN(INTRAM0_DTCM)+LENGTH(INTRAM0_DTCM)-0x10 :
	{
		tSerialVectors = . ;
		. = . + 0x10;
	} >INTRAM0_DTCM


	.bss :
	{
		/* zero-initialized data */

		__bss_start__ = . ;

		*(.bss)
		*(COMMON)

		__bss_end__ = . ;
	} >INTRAM3_DTCM


	/* set the top of the stack to the end of INTRAM1 */
	stack_top = ORIGIN(INTRAM3_DTCM) + LENGTH(INTRAM3_DTCM) ;


	/* Stabs debugging sections.  */
	.stab          0 : { *(.stab) }
	.stabstr       0 : { *(.stabstr) }
	.stab.excl     0 : { *(.stab.excl) }
	.stab.exclstr  0 : { *(.stab.exclstr) }
	.stab.index    0 : { *(.stab.index) }
	.stab.indexstr 0 : { *(.stab.indexstr) }
	.comment       0 : { *(.comment) }
	/* DWARF debug sections.
		Symbols in the DWARF debugging sections are relative to the beginning
		of the section so we begin them at 0.  */
	/* DWARF 1 */
	.debug          0 : { *(.debug) }
	.line           0 : { *(.line) }
	/* GNU DWARF 1 extensions */
	.debug_srcinfo  0 : { *(.debug_srcinfo) }
	.debug_sfnames  0 : { *(.debug_sfnames) }
	/* DWARF 1.1 and DWARF 2 */
	.debug_aranges  0 : { *(.debug_aranges) }
	.debug_pubnames 0 : { *(.debug_pubnames) }
	/* DWARF 2 */
	.debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
	.debug_abbrev   0 : { *(.debug_abbrev) }
	.debug_line     0 : { *(.debug_line) }
	.debug_frame    0 : { *(.debug_frame) }
	.debug_str      0 : { *(.debug_str) }
	.debug_loc      0 : { *(.debug_loc) }
	.debug_macinfo  0 : { *(.debug_macinfo) }
	/* SGI/MIPS DWARF 2 extensions */
	.debug_weaknames 0 : { *(.debug_weaknames) }
	.debug_funcnames 0 : { *(.debug_funcnames) }
	.debug_typenames 0 : { *(.debug_typenames) }
	.debug_varnames  0 : { *(.debug_varnames) }
}

