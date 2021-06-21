# This Cmake will be injected into the root folder of FetchContent for https://packs.download.microchip.com/Microchip.SAMD51_DFP.3.4.91.atpack
cmake_minimum_required(VERSION 3.18)

project( microchip-samd51-csp LANGUAGES  C ASM)

# MCU can be any of: samd51g19a,samd51j18a,samd51j19a,samd51j20a,samd51n19a,samd51n20a,samd51p19a,samd51p20a
set(MCU "samd51j19a" CACHE STRING "samd51::csp MCU to build against")
set_property(CACHE MCU PROPERTY STRINGS 
    samd51g18a 
    samd51g19a 
    samd51j18a 
    samd51j19a
    samd51j20a
    samd51n19a
    samd51n20a
    samd51p19a
    samd51p20a )

set(MCURunsFrom "flash" CACHE STRING "Atmel Samd51 MCU executes from flash or sram")
set_property(CACHE MCURunsFrom PROPERTY STRINGS 
    flash 
    sram
)

set(MCUFlashPartition "app" CACHE STRING "Atmel Samd51 MCU flash storage partition from boot (0x0) or app (0x2000)")
set_property(CACHE MCUFlashPartition PROPERTY STRINGS 
    app
    boot 
)

string( TOUPPER ${MCU} MCU_UPPERCASE)

set( samd51-csp_GCC_LD  
    ${CMAKE_CURRENT_LIST_DIR}/ld/${MCU}_${MCUFlashPartition}_${MCURunsFrom}.ld
    # DFP = $<$<CXX_COMPILER_ID:GNU>:${CMAKE_CURRENT_SOURCE_DIR}/samd51a/gcc/gcc/${MCU}_${MCURunsFrom}.ld
)

## Add all LD files to project source for development
set( samd51-csp_GCC_LD_SOURCES 
    ${samd51-csp_GCC_LD}
    ${CMAKE_CURRENT_LIST_DIR}/ld/memory.ld
    ${CMAKE_CURRENT_LIST_DIR}/ld/sections.ld
)

add_library(microchip-samd51-csp)
set_target_properties( microchip-samd51-csp PROPERTIES
    C_STANDARD 11
)

# TODO: doens't appear to cause rebuild as expected to :S'
set_property(TARGET microchip-samd51-csp PROPERTY 
    INTERFACE_LINK_DEPENDS  
    ${samd51-csp_GCC_LD}
    ${CMAKE_CURRENT_LIST_DIR}/ld/memory.ld
    ${CMAKE_CURRENT_LIST_DIR}/ld/sections.ld
)


target_compile_definitions(microchip-samd51-csp
    PUBLIC
        __SAMD51__=1
        __${MCU_UPPERCASE}__=1
)
message( INFO "Targetting ${MCU_UPPERCASE}")

target_include_directories( microchip-samd51-csp
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/samd51a/include
)

if( NOT ${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU" )
    message( WARNING "NOT GNU Compiler ${CMAKE_CXX_COMPILER_ID}")
endif()


target_sources( microchip-samd51-csp 
    PUBLIC
         $<$<CXX_COMPILER_ID:GNU>:${CMAKE_CURRENT_SOURCE_DIR}/samd51a/gcc/system_$<IF:$<EQUAL:${SAMD51HeaderVersion},2>,${MCU},samd51>.c>
         $<$<CXX_COMPILER_ID:GNU>:${CMAKE_CURRENT_SOURCE_DIR}/samd51a/gcc/gcc/startup_$<IF:$<EQUAL:${SAMD51HeaderVersion},2>,${MCU},samd51>.c>
         $<$<CXX_COMPILER_ID:GNU>:${samd51-csp_GCC_LD_SOURCES}>
)

target_link_libraries( microchip-samd51-csp
    PUBLIC
        arm::cmsis_5
)

target_link_options( microchip-samd51-csp  PUBLIC 
	$<$<CXX_COMPILER_ID:GNU>:-L${CMAKE_CURRENT_SOURCE_DIR}/samd51a/gcc/gcc/>
	$<$<CXX_COMPILER_ID:GNU>:-L${CMAKE_CURRENT_LIST_DIR}/ld/>
    $<$<CXX_COMPILER_ID:GNU>:-T${samd51-csp_GCC_LD}>
)

# TODO: These options should be defined in their respetive places
# TODO: --param max-inline-insns-single=500 
# TODO: What is -MMD ?
target_compile_options( microchip-samd51-csp 
    PUBLIC        
        -mthumb 
        -Og -ffunction-sections 
        $<$<COMPILE_LANGUAGE:CXX>:-fno-rtti -fno-threadsafe-statics>   
        $<$<COMPILE_LANGUAGE:C>:-std=gnu99 -Wstrict-prototypes>
        $<$<COMPILE_LANGUAGE:ASM>:-x assembler-with-cpp>
        -mlong-calls -g3 -Wall -mcpu=cortex-m4 -c -MD -MP -MF 
        -Wno-address-of-packed-member 
        -fno-diagnostics-show-caret        
        -fdata-sections -ffunction-sections
        -funsigned-char -funsigned-bitfields
        -fpic
)

target_compile_features( microchip-samd51-csp
    PUBLIC
        cxx_noexcept# TODO: We should use exceptions ideally as it is low/no cost on ARm runtime but increases binary size....
)

target_link_options( microchip-samd51-csp  
    PUBLIC 
        -v
	    -mthumb
        -Wl,-z,relro,-z,now # Increase startup times but miticate Relocation attachs https://systemoverlord.com/2017/03/19/got-and-plt-for-pwning.html
        -Wl,--print-memory-usage,-Map=memory.map -Wl,--start-group -lm  -Wl,--end-group
        -Wl,--gc-sections,--check-sections,--unresolved-symbols=report-all
        -Wl,--warn-common,--warn-section-align
        --specs=nano.specs
        -mcpu=cortex-m4
        -Xlinker --defsym=__BOOTPROTECT_SIZE__=8K
)

# Alias name
add_library( microchip::samd51::csp ALIAS microchip-samd51-csp )