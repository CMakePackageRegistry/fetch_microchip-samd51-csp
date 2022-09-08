cmake_minimum_required(VERSION 3.18) #FetchContent

# TODO: Check toolchain matches this target during build etc?
message(STATUS "Using toolchain file: ${CMAKE_TOOLCHAIN_FILE}")

if ( NOT CMAKE_TOOLCHAIN_FILE )
    message( FATAL_ERROR "microchip-samd51-csp is intended for cross-compiling Toolchain")
endif()

# Only supported for target cross-compiled build
if ( NOT CMAKE_CROSSCOMPILING )
    return()
endif()

set(MCU_SAM_HeaderVersion "1" CACHE STRING "Samd51 DFP Header-API revision where v1 headers are Atmel format add_compile_definitions v2 are Microchip" )

# TODO: Latest version AtmelStudio uses is Atmel.SAMD51_DFP.1.2.139.atpack
if( ${MCU_SAM_HeaderVersion} EQUAL 2)   
    set(URL "https://packs.download.microchip.com/Microchip.SAMD51_DFP.3.6.120.atpack")
    set(URL_HASH "SHA256=0fce096695dbd34914804dfb76a049db341097a169b1b8de6eac98b04faded8a")
else()
    set(URL "https://packs.download.microchip.com/Microchip.SAMD51_DFP.2.0.15.atpack")
    set(URL_HASH "SHA256=42558ADAB4AE41E3E9FF7F7D0712C7763FF6BF4923D020C3E45ABFA46B5CFF8E")
endif()
 
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake")
include(CPM)

CPMAddPackage(
    NAME microchip-samd51-dfp
    URL ${URL}
    URL_HASH ${URL_HASH}
    DOWNLOAD_ONLY YES
)

if(microchip-samd51-dfp_ADDED)
    # Inject and use samd51-csp.cmake 
    write_file( ${microchip-samd51-dfp_SOURCE_DIR}/CMakeLists.txt "include(${CMAKE_CURRENT_LIST_DIR}/samd51-csp.cmake)" )
    add_subdirectory(${microchip-samd51-dfp_SOURCE_DIR}/ ${microchip-samd51-dfp_BINARY_DIR}/)
endif()
    