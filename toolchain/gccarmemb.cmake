set(TOOLCHAIN_TARGET arm-none-eabi)

set(CMAKE_CROSSCOMPILING TRUE )
set(CMAKE_SYSTEM_NAME "Generic")
set(CMAKE_SYSTEM_PROCESSOR "arm")

SET(CMAKE_C_COMPILER_TARGET ${TOOLCHAIN_TARGET})
set(CMAKE_C_COMPILER ${TOOLCHAIN_TARGET}-gcc)

SET(CMAKE_ASM_COMPILER_TARGET ${TOOLCHAIN_TARGET})
set(CMAKE_ASM_COMPILER ${CMAKE_C_COMPILER})

SET(CMAKE_CXX_COMPILER_TARGET ${TOOLCHAIN_TARGET})
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_TARGET}-g++)

set(CMAKE_CXX_FLAGS_DEBUG_INIT "-O0 -DDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "-Os -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "-Os -g3 -DNDEBUG")

set(CMAKE_CXX_FLAGS_DEBUG_INIT "-O0 -DDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "-Os -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "-Os -g3 -DNDEBUG")


function( setLangFlagsInit lang )
set(CMAKE_${lang}_FLAGS_DEBUG " -g -DDEBUG" CACHE STRING "")
set(CMAKE_${lang}_FLAGS_MINSIZEREL " -Os -DNDEBUG" CACHE STRING "")
set(CMAKE_${lang}_FLAGS_RELEASE " -O3 -DNDEBUG" CACHE STRING "")
set(CMAKE_${lang}_FLAGS_RELWITHDEBINFO " -O2 -g -DNDEBUG" CACHE STRING "")
endfunction()
setLangFlagsInit("C")
setLangFlagsInit("ASM")
setLangFlagsInit("CXX")

#set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Assembler flags common to all targets
set(TOOLCHAIN_COMMON_FLAGS ) #-MP -MD -O3 -g3  -D__HEAP_SIZE=8192 -D__STACK_SIZE=8192
set(TOOLCHAIN_DATA_FLAGS 
	-ffunction-sections 
	-fdata-sections 
	#-fno-strict-aliasing
	-fshort-enums #This option tells the compiler to allocate as many bytes as needed for enumerated types.
	"-D__ASSERT_FUNC=((char*)0)" # Remove 'function name' from assert details to reduce binary size
	#-fmacro-prefix-map={build.path}\sketch\=  #TODO: used on Ardunino custom BSP but not needed here?
	#-fdebug-prefix-map={build.path}\sketch={build.source.path}   #TODO: used on Ardunino custom BSP but not needed here?
)
set(TOOLCHAIN_WARN_FLAGS 
	-Wall
	# -Wextra -Wno-attributes -Wno-format @TODO  -Werror
) 

set(TOOLCHAIN_ARCH_FLAGS 
	-mcpu=cortex-m4 
	-mthumb
	-mfloat-abi=hard 
	-mfpu=fpv4-sp-d16
	-mabi=aapcs 
)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

SET(CMAKE_C_FLAGS  
	#-v
	-Wstrict-prototypes
	${TOOLCHAIN_ARCH_FLAGS}
	${TOOLCHAIN_C_FLAGS} 
	${TOOLCHAIN_COMMON_FLAGS}
	${TOOLCHAIN_WARN_FLAGS} 
	${TOOLCHAIN_DATA_FLAGS}
)
SET(CMAKE_ASM_FLAGS   
	#-v
	-x assembler-with-cpp
	${TOOLCHAIN_ASM_FLAGS}
	${CMAKE_C_FLAGS} 
)
SET(CMAKE_CXX_FLAGS  
	#-v
	-Wno-volatile # Erroneous warning accessing CPU Registers using `REG |= val` with "'volatile'-qualified left operand is deprecated"
	-fno-exceptions
	-fno-rtti 
	-fno-threadsafe-statics
	${TOOLCHAIN_ARCH_FLAGS} 
	${TOOLCHAIN_CPP_FLAGS} 
	${TOOLCHAIN_COMMON_FLAGS}
	${TOOLCHAIN_WARN_FLAGS}
	${TOOLCHAIN_DATA_FLAGS}
)
SET(CMAKE_EXE_LINKER_FLAGS  
	#-v
	${TOOLCHAIN_ARCH_FLAGS}
	-Wl,--print-memory-usage,-Map=memory.map -Wl,--start-group -lm -Wl,--end-group
	-Wl,--gc-sections,--check-sections,--unresolved-symbols=report-all
	-Wl,--warn-common,--warn-section-align
	-specs=nosys.specs -specs=nano.specs
	-Xlinker --defsym=__BOOTPROTECT_SIZE__=8K
)

# Format settings as strings - allows us to construct argiuments as Cmake lists for easier Git-diff etc
string(REPLACE ";" " " CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
string(REPLACE ";" " " CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS}")
string(REPLACE ";" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
string(REPLACE ";" " " CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")

# Binaries  have .ELF suffix extension 
set(CMAKE_EXECUTABLE_SUFFIX ".ELF")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)