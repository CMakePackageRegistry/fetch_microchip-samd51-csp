# This Cmake will be injected into the root folder of FetchContent for https://packs.download.microchip.com/Microchip.SAMD51_DFP.3.4.91.atpack
cmake_minimum_required(VERSION 3.18)

project( microchip-samd51-csp LANGUAGES  C ASM)

# MCU_ID can be any of: samd51g19a,samd51j18a,samd51j19a,samd51j20a,samd51n19a,samd51n20a,samd51p19a,samd51p20a
set(MCU_ID "samd51j19a" CACHE STRING "samd51::csp MCU_ID to build against")
set_property(CACHE MCU_ID PROPERTY STRINGS 
    samd51g18a 
    samd51g19a 
    samd51j18a 
    samd51j19a
    samd51j20a
    samd51n19a
    samd51n20a
    samd51p19a
    samd51p20a )

set(MCU_RunsFrom "flash" CACHE STRING "Atmel Samd51 Mcu executes from flash or sram")
# @TODO: Add Vector+ISR from RAM option
set_property(CACHE MCU_RunsFrom PROPERTY STRINGS 
    flash 
    sram
)

set(MCU_FlashPartition "app" CACHE STRING "Atmel Samd51 MCU flash storage partition from boot (0x0) or app (0x2000)")
set_property(CACHE MCU_FlashPartition PROPERTY STRINGS 
    app
    boot 
)

string( TOUPPER ${MCU_ID} MCU_UPPERCASE)

set( microchip-samd51-csp_GCC_LD  
    ${CMAKE_CURRENT_LIST_DIR}/ld/${MCU_ID}_${MCU_FlashPartition}_${MCU_RunsFrom}.ld
    # DFP = $<$<CXX_COMPILER_ID:GNU>:${CMAKE_CURRENT_SOURCE_DIR}/samd51a/gcc/gcc/${MCU_ID}_${MCU_RunsFrom}.ld
)

## Add all LD files to project source for development
set( microchip-samd51-csp_GCC_LD_SOURCES 
    ${microchip-samd51-csp_GCC_LD}
    ${CMAKE_CURRENT_LIST_DIR}/ld/memory/common.ld
    ${CMAKE_CURRENT_LIST_DIR}/ld/memory/${MCU_ID}.ld
    ${CMAKE_CURRENT_LIST_DIR}/ld/sections/common.ld
    ${CMAKE_CURRENT_LIST_DIR}/ld/sections/${MCU_FlashPartition}.ld
)

add_library(microchip-samd51-csp)
set_target_properties( microchip-samd51-csp PROPERTIES
    C_STANDARD 11
)

# TODO: doens't appear to cause rebuild as expected to :S'
set_property(TARGET microchip-samd51-csp PROPERTY 
    INTERFACE_LINK_DEPENDS  
    ${microchip-samd51-csp_GCC_LD_SOURCES}
)

target_compile_definitions(microchip-samd51-csp
    PUBLIC
        __SAMD51__=1
        __${MCU_UPPERCASE}__=1
)
message( INFO "Targetting ${MCU_UPPERCASE}")

set(MCU_Cmake ${CMAKE_CURRENT_LIST_DIR}/${MCU_ID}.cmake CACHE STRING "MCU specific Cmake file" )
if ( EXISTS ${MCU_Cmake} )
    include(${MCU_Cmake})
else()
    message( WARN " - No MCU specific cmake source file: ${MCU_Cmake}")
endif()

target_include_directories( microchip-samd51-csp
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/samd51a/include
)

if( NOT ${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU" )
    message( WARNING "NOT GNU Compiler ${CMAKE_CXX_COMPILER_ID}")
endif()


target_sources( microchip-samd51-csp 
    PRIVATE
         $<$<CXX_COMPILER_ID:GNU>:${CMAKE_CURRENT_SOURCE_DIR}/samd51a/gcc/system_$<IF:$<EQUAL:${MCU_SAM_HeaderVersion},2>,${MCU_ID},samd51>.c>
         $<$<CXX_COMPILER_ID:GNU>:${CMAKE_CURRENT_SOURCE_DIR}/samd51a/gcc/gcc/startup_$<IF:$<EQUAL:${MCU_SAM_HeaderVersion},2>,${MCU_ID},samd51>.c>
         $<$<CXX_COMPILER_ID:GNU>:${microchip-samd51-csp_GCC_LD_SOURCES}>
)

include(CPM)
CPMAddPackage("gh:CMakeFetchContent/arm-cmsis_5#develop")

target_link_libraries( microchip-samd51-csp
    PUBLIC
        arm::cmsis_5
)

target_link_options( microchip-samd51-csp  PUBLIC 
	$<$<CXX_COMPILER_ID:GNU>:-L${CMAKE_CURRENT_SOURCE_DIR}/samd51a/gcc/gcc/>
	$<$<CXX_COMPILER_ID:GNU>:-L${CMAKE_CURRENT_LIST_DIR}/ld/>
    $<$<CXX_COMPILER_ID:GNU>:-T${microchip-samd51-csp_GCC_LD}>
)

# TODO: Using |Toolchain as these settings only inheritted by dependent libraries
# TODO: --param max-inline-insns-single=500 
# TODO: What is -MMD ?
#target_compile_options( microchip-samd51-csp 
#    INTERFACE        
#        #-flto 
#        -mthumb 
#        #-mabi=aapcs
#        -mcpu=cortex-m4
#        -mfloat-abi=hard
#        -mfpu=fpv4-sp-d16
#       # -nostdlib 
#       # -nostartfiles
#        $<$<COMPILE_LANGUAGE:CXX>:-fno-rtti -fno-threadsafe-statics>   
#        $<$<COMPILE_LANGUAGE:C>:-std=gnu99 -Wstrict-prototypes>
#        $<$<COMPILE_LANGUAGE:ASM>:-x assembler-with-cpp>
#        -mlong-calls -Wall -c -MD -MP -MF 
#        -Wno-address-of-packed-member 
#        -fno-diagnostics-show-caret        
#        -fdata-sections -ffunction-sections
#        -funsigned-char -funsigned-bitfields
#        -fpic
#)

target_compile_features( microchip-samd51-csp
    PUBLIC
        cxx_noexcept# TODO: We should use exceptions ideally as it is low/no cost on ARm runtime but increases binary size....
)

# TODO: Using |Toolchain as these settings only inheritted by dependent libraries
#target_link_options( microchip-samd51-csp  
#    INTERFACE 
#        -v
#        #-flto 
#        -mthumb 
#        #-mabi=aapcs
#        -mcpu=cortex-m4
#        -mfloat-abi=hard
#        -mfpu=fpv4-sp-d16
#        #-nostdlib
#       # -nostartfiles
#       -O3
#        #-Wl,-z,relro,-z,now # Increase startup times but miticate Relocation attachs https://systemoverlord.com/2017/03/19/got-and-plt-for-pwning.html
#        -Wl,--print-memory-usage,-Map=memory.map -Wl,--start-group -lm -Wl,--end-group
#        -Wl,--gc-sections,--check-sections,--unresolved-symbols=report-all
#        -Wl,--warn-common,--warn-section-align
#        -specs=nosys.specs -specs=nano.specs
#        -Xlinker --defsym=__BOOTPROTECT_SIZE__=8K
#)

# Alias name
add_library( microchip::samd51::csp ALIAS microchip-samd51-csp )