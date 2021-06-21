
/** @{ PARTITIONS */
__BOOTLOADER_SIZE__ = DEFINED(__BOOTLOADER_SIZE__) ? __BOOTLOADER_SIZE__ : 6K;
__CALDATA_SIZE__ = DEFINED(__CALDATA_SIZE__) ? __CALDATA_SIZE__ : __length_UserPage - __length_UserPageReserved;
__HWDATA_SIZE__ = DEFINED(__HWDATA_SIZE__) ? __HWDATA_SIZE__ : 64;
__APP_SIZE__ = DEFINED(__APP_SIZE__) ? __APP_SIZE__ : __length_FLASH - __BOOTPROTECT_SIZE__; /* Whole storage space after boot-protection */
__APP_OFFSET__ =  DEFINED(__APP_OFFSET__) ? __APP_OFFSET__ : __BOOTPROTECT_SIZE__;
/** @} */

ASSERT( __origin_APP_FLASH >= __BOOTPROTECT_SIZE__, "App mustn't overlap with boot protection" )

/** @{ RAM */
__RESERVE_ETBSIZE__ = 32K; /* First 32K used by ETB trace */
/** @} */

/* Linker script to configure memory regions.
 * Need modifying for a specific board.
 *   APP_FLASH.ORIGIN: starting address of APP_FLASH
 *   APP_FLASH.LENGTH: length of APP_FLASH
 *   RAM.ORIGIN: starting address of RAM bank 0
 *   RAM.LENGTH: length of RAM bank 0
 */
MEMORY
{
  /* - NVM - */
  BOOT_FLASH (rx) : ORIGIN = __origin_FLASH, LENGTH = __BOOTPROTECT_SIZE__ - __HWDATA_SIZE__
  HWDATA_FLASH (rw) : ORIGIN = __BOOTPROTECT_SIZE__ - __HWDATA_SIZE__, LENGTH = __HWDATA_SIZE__
  APP_FLASH (rw) : ORIGIN = __APP_OFFSET__, LENGTH = __APP_SIZE__

  /* - USER page - */
  USERPAGE_FLASH (rw) : ORIGIN = __origin_UserPage, LENGTH = __length_UserPage

  /* - RAM - */
  RAM (rw) : ORIGIN = __origin_RAM + __RESERVE_ETBSIZE__, LENGTH = __length_RAM - __RESERVE_ETBSIZE__ /* First 32K used by ETB trace */
  BACKUP_RAM  (rwx) : ORIGIN = __origin_BackupRAM, LENGTH = __length_BackupRAM
  
    /* NOT supporting this for now: 
    qspi     (rwx) : ORIGIN = 0x04000000, LENGTH = 0x01000000
    */
}

__origin_APP_FLASH = ORIGIN(APP_FLASH);     
__length_APP_FLASH = LENGTH(APP_FLASH);
__origin_BOOT_FLASH = ORIGIN(BOOT_FLASH);   
__length_BOOT_FLASH = LENGTH(BOOT_FLASH);
__origin_HWDATA_FLASH = ORIGIN(HWDATA_FLASH);   
__length_HWDATA_FLASH = LENGTH(HWDATA_FLASH);
__origin_USERPAGE_FLASH = ORIGIN(USERPAGE_FLASH);   
__length_USERPAGE_FLASH = LENGTH(USERPAGE_FLASH);
__origin_CALDATA_FLASH = __origin_USERPAGE_FLASH + __length_UserPageReserved;
__length_CALDATA_FLASH = __length_USERPAGE_FLASH - __length_UserPageReserved;


__end_RAM = ORIGIN(RAM) + LENGTH(RAM);

