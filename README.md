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
- arm::cmsis_5 (**WIP: Automated fetch etc?**)

# Usage

## Client Code
Modules can be included as submodules or... **WIP: Document usage via FetchContent?**

## Module Development
Add https://github.com/CMakeFetchContent/microchip-samd51-csp.git as Submodule to your reposuitory and `add_subdirectory` 