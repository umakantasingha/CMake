SET(CMAKE_LIBRARY_PATH_FLAG "-LIBPATH:")
SET(CMAKE_LINK_LIBRARY_FLAG "")

SET(CMAKE_START_TEMP_FILE "@<<\n")
SET(CMAKE_END_TEMP_FILE "\n<<")
# uncomment these out to debug makefiles
#SET(CMAKE_START_TEMP_FILE "")
#SET(CMAKE_END_TEMP_FILE "")
#SET(CMAKE_VERBOSE_MAKEFILE 1)

# create a shared C++ library
SET(CMAKE_CXX_CREATE_SHARED_LIBRARY 
 "link /nologo ${CMAKE_START_TEMP_FILE}  /out:<TARGET> /dll  <LINK_FLAGS> <OBJECTS> <LINK_LIBRARIES> ${CMAKE_END_TEMP_FILE}")

SET(CMAKE_CXX_CREATE_SHARED_MODULE ${CMAKE_CXX_CREATE_SHARED_LIBRARY})

# create a C shared library
SET(CMAKE_C_CREATE_SHARED_LIBRARY ${CMAKE_CXX_CREATE_SHARED_LIBRARY})

# create a C shared module just copy the shared library rule
SET(CMAKE_C_CREATE_SHARED_MODULE ${CMAKE_C_CREATE_SHARED_LIBRARY})


# create a C++ static library
SET(CMAKE_CXX_CREATE_STATIC_LIBRARY  "lib /nologo /out:<TARGET> <OBJECTS> ")

# create a C static library
SET(CMAKE_C_CREATE_STATIC_LIBRARY ${CMAKE_CXX_CREATE_STATIC_LIBRARY})

# compile a C++ file into an object file
SET(CMAKE_CXX_COMPILE_OBJECT
    "<CMAKE_CXX_COMPILER>  ${CMAKE_START_TEMP_FILE} /nologo -DWIN32 /Fo<OBJECT> <FLAGS> -c <SOURCE>${CMAKE_END_TEMP_FILE}")

# compile a C file into an object file
SET(CMAKE_C_COMPILE_OBJECT
    "<CMAKE_C_COMPILER> ${CMAKE_START_TEMP_FILE} /nologo -DWIN32 /Fo<OBJECT>  <FLAGS> -c <SOURCE>${CMAKE_END_TEMP_FILE}")


SET(CMAKE_C_LINK_EXECUTABLE
    "<CMAKE_C_COMPILER> /nologo ${CMAKE_START_TEMP_FILE} <FLAGS> <OBJECTS> /Fe<TARGET> -link <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <LINK_LIBRARIES>${CMAKE_END_TEMP_FILE}")

SET(CMAKE_COMPILE_RESOURCE "rc <FLAGS> /fo<OBJECT> <SOURCE>")

SET(CMAKE_CXX_LINK_EXECUTABLE
    "<CMAKE_CXX_COMPILER> /nologo ${CMAKE_START_TEMP_FILE} <FLAGS> <OBJECTS> /Fe<TARGET> -link <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <LINK_LIBRARIES>${CMAKE_END_TEMP_FILE}")

SET(CMAKE_CREATE_WIN32_EXE /subsystem:windows)
# default to Debug builds
SET(CMAKE_BUILD_TYPE_INIT Debug)
SET (CMAKE_CXX_FLAGS_INIT "/W3 /Zm1000 /GX /GR")
SET (CMAKE_CXX_FLAGS_DEBUG_INIT "/MDd /Zi /Od /GZ")
SET (CMAKE_CXX_FLAGS_MINSIZEREL_INIT "/MD /O1")
SET (CMAKE_CXX_FLAGS_RELEASE_INIT "/MD /O2")
SET (CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "/MD /Zi /O2")
SET (CMAKE_C_FLAGS_INIT "/W3 /Zm1000")
SET (CMAKE_C_FLAGS_DEBUG_INIT "/MDd /Zi /Od /GZ")
SET (CMAKE_C_FLAGS_MINSIZEREL_INIT "/MD /O1")
SET (CMAKE_C_FLAGS_RELEASE_INIT "/MD /O2")
SET (CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "/MD /Zi /O2")


SET (CMAKE_STANDARD_LIBRARIES "kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib  kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib" CACHE STRING 
     "Libraries linked by defalut with all applications.")
MARK_AS_ADVANCED(CMAKE_STANDARD_LIBRARIES)

IF(CMAKE_GENERATOR MATCHES "Visual Studio 6")
   SET (CMAKE_NO_BUILD_TYPE 1)
ENDIF(CMAKE_GENERATOR MATCHES "Visual Studio 6")
IF(CMAKE_GENERATOR MATCHES "Visual Studio 7")
  SET (CMAKE_CONFIGURATION_TYPES "Debug Release MinSizeRel RelWithDebInfo" CACHE STRING 
     "Space separated list of supported configuration types, only supports Debug, Release, MinSizeRel, and RelWithDebInfo, anything else will be ignored.")
  SET (CMAKE_CXX_WARNING_LEVEL "3" CACHE STRING
       "Size of stack for programs.")
  SET (CMAKE_CXX_STACK_SIZE "10000000" CACHE STRING
       "Size of stack for programs.")
  MARK_AS_ADVANCED(CMAKE_CONFIGURATION_TYPES CMAKE_CXX_STACK_SIZE CMAKE_CXX_WARNING_LEVEL)
  SET (CMAKE_NOT_USING_CONFIG_FLAGS 1)
ENDIF(CMAKE_GENERATOR MATCHES "Visual Studio 7")


# executable linker flags
SET (CMAKE_LINK_DEF_FILE_FLAG "/DEF:")
SET (CMAKE_EXE_LINKER_FLAGS_INIT "/STACK:10000000 /machine:I386 /INCREMENTAL:YES")
SET (CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT "/debug /pdbtype:sept")
SET (CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO_INIT "/debug /pdbtype:sept")
SET (CMAKE_SHARED_LINKER_FLAGS_INIT ${CMAKE_EXE_LINKER_FLAGS_INIT})
SET (CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT ${CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT})
SET (CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO_INIT ${CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT})
SET (CMAKE_MODULE_LINKER_FLAGS_INIT ${CMAKE_SHARED_LINKER_FLAGS}
SET (CMAKE_MODULE_LINKER_FLAGS_DEBUG_INIT ${CMAKE_MODULE_LINKER_FLAGS_DEBUG})
SET (CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO_INIT ${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO_INIT})
