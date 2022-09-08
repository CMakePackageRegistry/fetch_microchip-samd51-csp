set(CPM_DOWNLOAD_VERSION 0.35.0)

if(CPM_SOURCE_CACHE)
  set(CPM_DOWNLOAD_LOCATION "${CPM_SOURCE_CACHE}/cpm/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
elseif(DEFINED ENV{CPM_SOURCE_CACHE})
  set(CPM_DOWNLOAD_LOCATION "$ENV{CPM_SOURCE_CACHE}/cpm/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
else()
  set(CPM_DOWNLOAD_LOCATION "${CMAKE_BINARY_DIR}/cmake/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
endif()

if(NOT (EXISTS ${CPM_DOWNLOAD_LOCATION}))
    message(STATUS "Downloading CPM.cmake to ${CPM_DOWNLOAD_LOCATION}")

    set(url "https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CPM_DOWNLOAD_VERSION}/CPM.cmake")
    set(destination_file ${CPM_DOWNLOAD_LOCATION} )
    file(DOWNLOAD  ${url}  ${destination_file} STATUS result LOG download_log )
  
    list(GET result 0 result_code)
    if (NOT result_code EQUAL 0)
        # Cmake leaves an empty file if the download failed
        file(REMOVE ${destination_file} )
        list(GET result 1 result_message)
        message(FATAL_ERROR "Failed to download from ${url}.\n${download_log}Error code: ${result_code}\n${result_message}")
    endif()
endif()

include(${CPM_DOWNLOAD_LOCATION})
