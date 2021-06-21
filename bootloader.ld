
__BOOTPROTECT_SIZE__ = DEFINED(__BOOTPROTECT_SIZE__) ? __BOOTPROTECT_SIZE__ : 8K;

__origin_nvm = 0x0;
__origin_ram = 0x20000000;
__origin_Backupram = 0x47000000;
__origin_userpage = 0x00804000;

__length_nvm = 512K; /** @todo Configure per device */
__length_ram = 192K; /** @todo Configure per device */
__length_Backupram = 8K; /** @todo Configure per device */
__length_userpage = 512; /** @todo Configure per device */
__length_userpagereserved = 32; /** First eight 32-bit words (32 Bytes) are reserved  @todo Configure per device @todo 3-words are unused on SAMD51 */
__origin_BootloaderVersionTag = 0x24;

/** @{ PARTITIONS */
__BOOTLOADER_SIZE__ = DEFINED(__BOOTLOADER_SIZE__) ? __BOOTLOADER_SIZE__ : 6K;
__HWDATA_SIZE__ = DEFINED(__HWDATA_SIZE__) ? __HWDATA_SIZE__ : 2K;
__CALDATA_SIZE__ = DEFINED(__CALDATA_SIZE__) ? __CALDATA_SIZE__ : __length_userpage - __length_userpagereserved;
__APP_SIZE__ = DEFINED(__APP_SIZE__) ? __APP_SIZE__ : __length_nvm - __BOOTPROTECT_SIZE__; /* Whole storage space after boot-protection */
__APP_OFFSET__ =  DEFINED(__APP_OFFSET__) ? __APP_OFFSET__ : __BOOTPROTECT_SIZE__;
/** @} */


/** @{ ram */
__RESERVE_ETBSIZE__ = 32K; /* First 32K used by ETB trace */
/** @} */

/* Linker script to configure memory regions.
 * Need modifying for a specific board.
 *   rom.ORIGIN: starting address of rom
 *   rom.LENGTH: length of rom
 *   ram.ORIGIN: starting address of ram bank 0
 *   ram.LENGTH: length of ram bank 0
 */
MEMORY
{
  /* - NVM - */
  boot (rx) : ORIGIN = __origin_nvm, LENGTH = __BOOTLOADER_SIZE__
  hwdata (rx) : ORIGIN = __origin_nvm + __BOOTLOADER_SIZE__, LENGTH = __HWDATA_SIZE__

  rom (rw) : ORIGIN = __APP_OFFSET__, LENGTH = __APP_SIZE__

  /* - USER page - */
  userpage (rw) : ORIGIN = __origin_userpage, LENGTH = __length_userpage

  /* - ram - */
  ram (rw) : ORIGIN = __origin_ram + __RESERVE_ETBSIZE__, LENGTH = __length_ram - __RESERVE_ETBSIZE__ /* First 32K used by ETB trace */
}

__origin_rom = ORIGIN(rom);     
__length_rom = LENGTH(rom);
__origin_boot = ORIGIN(boot);   
__length_boot = LENGTH(boot);
__origin_hwdata = ORIGIN(hwdata);   
__length_hwdata = LENGTH(hwdata);

__origin_caldata = __origin_userpage + __length_userpagereserved;
__length_caldata = __length_userpage - __length_userpagereserved;

__end_ram = ORIGIN(ram) + LENGTH(ram);

ASSERT( __origin_boot + __length_boot <= __origin_nvm + __BOOTPROTECT_SIZE__, "Boot must be within boot protection" )
ASSERT( __origin_hwdata + __length_hwdata <= __origin_nvm + __BOOTPROTECT_SIZE__, "Hwdata must be within boot protection" )
ASSERT( __origin_rom >= __origin_nvm + __BOOTPROTECT_SIZE__, "App mustn't overlap with boot protection" )


SECTIONS
{	
	.bootloader (NOLOAD):
	{	
		. = __origin_BootloaderVersionTag;
		KEEP(*(.bootloaderVersionTag)) ;

		. = __BOOTLOADER_SIZE__;
	} > boot

    .hardwareData (NOLOAD) :
    {
        . = ALIGN(4);
		KEEP(*(.hardwareData)) ;
    } > hwdata

	.crc __origin_rom + 0x1C (OVERLAY) : AT ( __origin_rom + 0x1C )
	{
		LONG( __imageSizeBytes );
		LONG( 0x0 );
	} > rom 


	/* Image size of flashed image TODO: May be a betetr way to determine this? */
	__imageSizeBytes = SIZEOF(.text) + SIZEOF(.got) + SIZEOF(.got.plt);
}