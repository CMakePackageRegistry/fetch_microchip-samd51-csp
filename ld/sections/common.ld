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
        . = __length_UserPageReserved - 4;
        KEEP(*(.hardwareVersion)); 
        . = __length_UserPageReserved;
        KEEP(*(.factoryCalibrationData));
    } > USERPAGE_FLASH

	.bootloader ORIGIN(BOOT_FLASH) (OVERLAY) : AT ( ORIGIN(BOOT_FLASH) )
	{	
		. = __origin_BootloaderVersionTag;
		KEEP(*(.bootloaderVersionTag)) ;

		. = __BOOTLOADER_SIZE__;
	} > BOOT_FLASH
 
    /****************************/
    /*      PROGRAM CODE        */
    /****************************/
    .text :
    {
        FILL(0xDEADC0DE)

        . = ALIGN(4);
        _sfixed = .;
        _svectors = _sfixed;
        KEEP(*(.vectors .vectors.*))
        _evectors = .;
        
        /*. = ALIGN(4);*/
        PROVIDE(__sversionTag = .);
		KEEP(*(.versionTag .applicationFwVersionTag .applicationMetaData)) ;
        PROVIDE(__eversionTag = .);

        . = ALIGN(4);
         *(.text .text* .gnu.linkonce.t.*)  /* .text* sections (code) */
        *(.glue_7 .glue_7t) /* glue_7= Glue ARM to Thumb code, glue_7t= Glue Thumb to ARM code */
        *(.eh_frame)
        
        /* Note: The function ‘.text.Reset_Handler’ is one of the *(.text*) sections */
        KEEP (*(.init))
        KEEP (*(.fini))
        
        . = ALIGN(4);
        _etext = .;        /* Define a global symbol at end of code */
    } > TARGET_FLASH

    /****************************/
    /*      CONSTANT DATA       */
    /****************************/
    .rodata :
    {
        . = ALIGN(4);
        *(.rodata .rodata* .gnu.linkonce.r.*) /* .rodata* sections (constants, strings, etc.) */
        . = ALIGN(4);
    } > TARGET_FLASH
    
    .preinit_array :
    {
        . = ALIGN(4);
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP (*(.preinit_array*))
        PROVIDE_HIDDEN (__preinit_array_end = .);
        . = ALIGN(4);
    } > TARGET_FLASH
        
    .init_array :
    {
        . = ALIGN(4);
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP (*(SORT(.init_array.*)))
        KEEP (*(.init_array*))
        PROVIDE_HIDDEN (__init_array_end = .);
        . = ALIGN(4);
    } > TARGET_FLASH
        
    .ctors :
    {
        . = ALIGN(4);
        KEEP (*crtbegin.o(.ctors))
        KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
        KEEP (*(SORT(.ctors.*)))
        KEEP (*crtend.o(.ctors))
    } > TARGET_FLASH
    
    .fini_array :
    {    
        . = ALIGN(4);
        __fini_array_start = .;
        KEEP (*(.fini_array))
        KEEP (*(SORT(.fini_array.*)))
        __fini_array_end = .;
    } > TARGET_FLASH

    .dtors :
    {
        . = ALIGN(4);
        KEEP (*crtbegin.o(.dtors))
        KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
        KEEP (*(SORT(.dtors.*)))
        KEEP (*crtend.o(.dtors))
    } > TARGET_FLASH
        
    . = ALIGN(4);
    _efixed = .;            /* End of text section */
        
    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } > TARGET_FLASH
        
    /* .ARM.exidx is sorted, so has to go in its own output section.  */
    PROVIDE_HIDDEN (__exidx_start = .);
	.ARM.exidx :
	{
		*(.ARM.exidx* .gnu.linkonce.armexidx.*)
	} > TARGET_FLASH
    PROVIDE_HIDDEN (__exidx_end = .);

        
	/* Location counter can end up 2byte aligned with narrow Thumb code but
	   _etext is assumed by startup code to be the LMA of a section in RAM
	   which must be 4byte aligned */	
    . = ALIGN(4);
    _etext = .;
          
	.crc ORIGIN(TARGET_FLASH) + 0x1C (OVERLAY) :  AT ( ORIGIN(TARGET_FLASH) + 0x1C )
	{
		LONG( __imageSizeBytes );
		LONG( 0x0 );
	} > TARGET_FLASH
        
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
    
    /****************************/
    /*    INITIALIZED DATA      */
    /****************************/
    _sidata = LOADADDR(.relocate);
    .relocate :  AT (_etext)
    {
        FILL(0xDEADF00D)

        . = ALIGN(4);
        _sdata = .;        /* create a global symbol at data start */
        _srelocate = _sdata;
        
        *(.ramfunc .ramfunc.*);
        *(.data)           /* .data sections */
        *(.data*)          /* .data* sections */

        . = ALIGN(4);
        _edata = .;        /* define a global symbol at data end */
        _erelocate = _edata;

    } > RAM 
    /*AT > TARGET_FLASH*/

    /****************************/
    /*    UNINITIALIZED DATA    */
    /****************************/
    .bss (NOLOAD) :
    {
        FILL(0xDEADBEEF)

        . = ALIGN(4);
        _sbss = .;         /* define a global symbol at bss start */
        __bss_start__ = _sbss;
        _szero = _sbss;
        *(.bss .bss*)
        *(COMMON)

        . = ALIGN(4);
        _ebss = .;         /* define a global symbol at bss end */
        __bss_end__ = _ebss;
        _ezero = _ebss;
        end = _ebss;
    } > RAM

     /****************************/
    /* USER_HEAP_STACK SECTION  */
    /****************************/
    /* User_heap_stack section, used to check that there is enough RAM left */
   /* TODO:
   ._user_heap_stack :
    {
        . = ALIGN(8);
        PROVIDE ( end = . );
        PROVIDE ( _end = . );
        . = . + _Min_Heap_Size;
        . = . + _Min_Stack_Size;
        
        . = ALIGN(8);
    } > RAM
    */
    

	/* .stack_dummy section doesn't contains any symbols. It is only
	 * used for linker to calculate size of stack sections, and assign
	 * values to stack symbols later */
	.stack_dummy (COPY):
	{
		KEEP(*(.stack*))
	} > RAM
    
    /** We place resetMagic at the very end of memory i.e. Before the stack
    */
    __RAM_reset_magic__ = __end_RAM - 4;    
    .resetMagic __RAM_reset_magic__ (NOLOAD) :
    {
        _sresetMagic = .;
        KEEP(*(.resetMagic)) ;
        _eresetMagic = .;
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


/** TODO: Only valid for bootloader! */
/* ASSERT( __sversionTag == 0x24 + ORIGIN(TARGET_FLASH), "VersionTag address moved" ) */
/** TODO: Only valid for Application with full .vectors table!*/
ASSERT( __sversionTag == 0x264 + ORIGIN(TARGET_FLASH), "VersionTag address moved" )
/* 
ASSERT( __eversionTag - __sversionTag > 4, "VersionTag is not set" )
*/

ASSERT( _evectors - _svectors >= 0x24, "vectors Not set!" ) 
ASSERT( __origin_CALDATA_FLASH == 0x804020, "Factory Calibration Data address moved" )
ASSERT( ORIGIN(HWDATA_FLASH) == 0x1FC0, "Hardware Data address moved" )
ASSERT( ORIGIN(APP_FLASH) == __APP_OFFSET__, "App-Image address moved" )
ASSERT( SIZEOF(.resetMagic) == 4, "resetMagic shall be 4 bytes" )
ASSERT( _eresetMagic == __end_RAM, "resetMagic not at __end_RAM-4" )

