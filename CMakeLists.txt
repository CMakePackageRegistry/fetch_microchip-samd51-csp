cmake_minimum_required(VERSION 3.18) #FetchContent

# TODO: Check toolchain matches this target during build etc?
message(STATUS "Using toolchain file: ${CMAKE_TOOLCHAIN_FILE}")

# Only supported for target cross-compiled build
if ( NOT CMAKE_CROSSCOMPILING )
    return()
endif()

include(FetchContent)

set(SAMD51HeaderVersion "1" CACHE STRING "Samd51 DFP Header-API revision where v1 headers are Atmel format add_compile_definitions v2 are Microchip" )

# TODO: Latest version AtmelStudio uses is Atmel.SAMD51_DFP.1.2.139.atpack

if( ${SAMD51HeaderVersion} EQUAL 2)
    FetchContent_Declare(
        samd51-csp
        URL https://packs.download.microchip.com/Microchip.SAMD51_DFP.3.4.91.atpack
        URL_HASH       SHA256=321150D1EEF152D95070B6D7129A7133DE1E2CEE2C20BFC8520A70A70DA76290
    )
else()
    FetchContent_Declare(
        samd51-csp
        URL https://packs.download.microchip.com/Microchip.SAMD51_DFP.2.0.15.atpack
        URL_HASH       SHA256=42558ADAB4AE41E3E9FF7F7D0712C7763FF6BF4923D020C3E45ABFA46B5CFF8E
    )
endif()

set(FETCHCONTENT_QUIET FALSE)
FetchContent_GetProperties(samd51-csp)
if(NOT samd51-csp_POPULATED)

    FetchContent_Populate(samd51-csp)

    # Inject and use samd51-csp.cmake 
    write_file( ${samd51-csp_SOURCE_DIR}/CMakeLists.txt "include(${CMAKE_CURRENT_LIST_DIR}/samd51-csp.cmake)" )

    add_subdirectory(${samd51-csp_SOURCE_DIR} ${samd51-csp_BINARY_DIR})
endif()
    