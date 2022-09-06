# microchip-samd51-csp
CMake FetchContent module for (Atmel) Microchip SAM D5x/E5x Family Chip Support Package

This CMakeFetchContent module will auto download+configure the Device-Family-Pack for supported Samd51 chips:
- samd51g19a
- samd51j18a
- samd51j19a
- samd51j20a
- samd51n19a
- samd51n20a
- samd51p19a
- samd51p20a

# Dependencies
- arm::cmsis_5 (**TODO: Automated fetch etc?**)

# How to use the module

## Client Code
Modules can be included as submodules or... **TODO: Document usage via FetchContent?**

## Module Development
Add https://github.com/CMakeFetchContent/microchip-samd51-csp.git as Submodule to your reposuitory and `add_subdirectory` 

# About this Module

# Cmake Targets
- microchip::samd51::csp (ALIAS microchip-samd51-csp)

# Cmake options
- `MCU_SAM_HeaderVersion` either [1,2] where v1 is Atmel style and v2 is Microchip style (i.e. After acquisition and remoes the bit-struct registers types but has all latest features)
- `MCU_ID` either [samd51g19a,samd51j18a,samd51j19a,samd51j20a,samd51n19a,samd51n20a,samd51p19a,samd51p20a] specifying the taregt MCU_ID being compiled for
- `MCU_RunsFrom` either [flash,sram] **TODO: only flash tesed on samd51j19a target**
- `MCU_FlashPartition` either [app,boot] determining flash storage partition from boot (0x0) or app (0x2000) for bootloader based target **TODO: Configure app/bootloader address**