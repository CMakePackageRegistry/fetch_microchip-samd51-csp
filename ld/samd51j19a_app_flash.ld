__BOOTPROTECT_SIZE__ = DEFINED(__BOOTPROTECT_SIZE__) ? __BOOTPROTECT_SIZE__ : 8K;

__origin_FLASH = 0x0;
__origin_RAM = 0x20000000;
__origin_BackupRAM = 0x47000000;
__origin_UserPage = 0x00804000;

__length_FLASH = 512K; /** @todo Configure per device */
__length_RAM = 192K; /** @todo Configure per device */
__length_BackupRAM = 8K; /** @todo Configure per device */
__length_UserPage = 512; /** @todo Configure per device */
__length_UserPageReserved = 32; /** First eight 32-bit words (32 Bytes) are reserved  @todo Configure per device @todo 3-words are unused on SAMD51 */
__origin_BootloaderVersionTag = 0x24;

INCLUDE memory.ld

REGION_ALIAS("TARGET_FLASH", APP_FLASH );

INCLUDE sections.ld