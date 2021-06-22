/*
modified from original (which can be found at https://github.com/ataradov/mcu-starter-projects):
+ formal stack declaration (rather than just use the end of RAM)
+ entry point of "Reset_Handler" instead of "irq_handler_reset"
+ used Rowley convention of section names (i.e. "data_load" instead of "etext")
+ BOOT_FLASH size reduced to 1kByte (since bootloader must fit in this)
*/

/*
 * Copyright (c) 2016, Alex Taradov <alex@taradov.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

 
OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
SEARCH_DIR(.)

ENTRY(Reset_Handler)

SECTIONS
{
    .hardwareData (NOLOAD) :
    {
        . = ALIGN(4);
		KEEP(*(.hardwareData)) ;
    } > HWDATA_FLASH
    
    .userPage (NOLOAD):
    {
        KEEP(*(.userPageReserved));   
        . = __length_UserPageReserved;
        KEEP(*(.factoryCalibrationData));
    } > USERPAGE_FLASH

	.bootloader ORIGIN(BOOT_FLASH) (OVERLAY) : AT ( ORIGIN(BOOT_FLASH) )
	{	
		. = __origin_BootloaderVersionTag;
		KEEP(*(.bootloaderVersionTag)) ;

		. = __BOOTLOADER_SIZE__;
	} > BOOT_FLASH
     
    .text :
    {
        FILL(0xDEADC0DE)

        . = ALIGN(4);
        _sfixed = .;
        KEEP(*(.vectors .vectors.*))
        
		. = ALIGN(4);
        PROVIDE(__origin_versionTag = .);
		KEEP(*(.versionTag)) ;
		. = ALIGN(4);

        *(.text .text.* .gnu.linkonce.t.*)
        *(.glue_7t) *(.glue_7)
        *(.rodata .rodata* .gnu.linkonce.r.*)
        *(.ARM.extab* .gnu.linkonce.armextab.*)

        /* Support C constructors, and C destructors in both user code
           and the C library. This also provides support for C++ code. */
        . = ALIGN(4);
        KEEP(*(.init))
        . = ALIGN(4);
        __preinit_array_start = .;
        KEEP (*(.preinit_array))
        __preinit_array_end = .;

        . = ALIGN(4);
        __init_array_start = .;
        KEEP (*(SORT(.init_array.*)))
        KEEP (*(.init_array))
        __init_array_end = .;

        . = ALIGN(4);
        KEEP (*crtbegin.o(.ctors))
        KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
        KEEP (*(SORT(.ctors.*)))
        KEEP (*crtend.o(.ctors))

        . = ALIGN(4);
        KEEP(*(.fini))

        . = ALIGN(4);
        __fini_array_start = .;
        KEEP (*(.fini_array))
        KEEP (*(SORT(.fini_array.*)))
        __fini_array_end = .;

        KEEP (*crtbegin.o(.dtors))
        KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
        KEEP (*(SORT(.dtors.*)))
        KEEP (*crtend.o(.dtors))

        . = ALIGN(4);
        _efixed = .;            /* End of text section */
    } > TARGET_FLASH

    /* .ARM.exidx is sorted, so has to go in its own output section.  */
    PROVIDE_HIDDEN (__exidx_start = .);
    .ARM.exidx :
    {
      *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > TARGET_FLASH
    PROVIDE_HIDDEN (__exidx_end = .);


    . = ALIGN(4);
    _etext = .;
          
	.crc ORIGIN(TARGET_FLASH) + 0x1C (OVERLAY) :  AT ( ORIGIN(TARGET_FLASH) + 0x1C )
	{
		LONG( __imageSizeBytes );
		LONG( 0x0 );
	} > TARGET_FLASH

    .relocate : AT (_etext)
    {
        FILL(0xDEADBEEF)

        . = ALIGN(4);
        _srelocate = .;
        *(.ramfunc .ramfunc.*);
        *(.data .data.*);
        . = ALIGN(4);
        _erelocate = .;
    } > RAM

    .bkupram (NOLOAD):
    {
        . = ALIGN(8);
        _sbkupram = .;
        *(.bkupram .bkupram.*);
        . = ALIGN(8);
        _ebkupram = .;
    } > BACKUP_RAM

   /* NOTE: Not supporting this atm
   .qspi (NOLOAD):
    {
        . = ALIGN(8);
        _sqspi = .;
        *(.qspi .qspi.*);
        . = ALIGN(8);
        _eqspi = .;
    } > qspi
    */

    /* .bss section which is used for uninitialized data */
    .bss (NOLOAD) :
    {
        . = ALIGN(4);
        _sbss = . ;
        _szero = .;
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = . ;
        _ezero = .;
    } > RAM
  
    
	/* .stack_dummy section doesn't contains any symbols. It is only
	 * used for linker to calculate size of stack sections, and assign
	 * values to stack symbols later */
	.stack_dummy (COPY):
	{
        . = ALIGN(8);
        _sstack = .;
		*(.stack*)
        . = ALIGN(8);
        _estack = .;
	} > RAM
    
    /** We place resetMagic at the very end of memory i.e. Before the stack
    */
    __RAM_reset_magic__ = __end_RAM - 4;
    .resetMagic __RAM_reset_magic__ (NOLOAD) :
    {
        . = ALIGN(4);
        KEEP(*(.resetMagic)) ;
    } > RAM
    
	/* Set stack top to end of RAM, and stack limit move down by
	 * size of stack_dummy section */
	_estack = __end_RAM - SIZEOF(.resetMagic);
	_sstack = _estack - SIZEOF(.stack_dummy);
	PROVIDE(__stack = _estack);  

    . = ALIGN(4);
    _end = . ;

	/* Image size of flashed image TODO: May be a betetr way to determine this? */
	__imageSizeBytes = (_etext - ORIGIN(TARGET_FLASH)) + SIZEOF(.relocate);

}


/** TODO: Only valid for bootloader! ASSERT( __origin_versionTag == 0x24 + ORIGIN(TARGET_FLASH), "VersionTag address moved" )*/
ASSERT( __origin_CALDATA_FLASH == 0x804020, "Factory Calibration Data address moved" )
ASSERT( ORIGIN(HWDATA_FLASH) == 0x1FC0, "Hardware Data address moved" )
ASSERT( ORIGIN(APP_FLASH) == __APP_OFFSET__, "App-Image address moved" )
ASSERT(SIZEOF(.resetMagic) >= 4, "resetMagic Not used" )