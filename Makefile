﻿.PHONY: debug release all clean install uninstall configure service service_debug test test_debug

ifndef GCC_VERSION_SUFFIX
GCC_VERSION_SUFFIX=GCC520
endif

ifndef FBC_VERSION_SUFFIX
FBC_VERSION_SUFFIX=FBC1.08.1
endif

ifeq ($(PERFORMANCE_TESTING_FLAG),true)
PERFORMANCE_TESTING_DEFINED=-d PERFORMANCE_TESTING
PERFORMANCE_TESTING_SUFFIX=PT
LIBRARIES_GMONITOR=-lgmon
else
PERFORMANCE_TESTING_DEFINED=
PERFORMANCE_TESTING_SUFFIX=WoPT
LIBRARIES_GMONITOR=
endif

ifeq ($(WITHOUT_CRITICAL_SECTIONS_FLAG),true)
WITHOUT_CRITICAL_SECTIONS_DEFINED=-d WITHOUT_CRITICAL_SECTIONS
WITHOUT_CRITICAL_SECTIONS_SUFFIX=WoCr
else
WITHOUT_CRITICAL_SECTIONS_DEFINED=
WITHOUT_CRITICAL_SECTIONS_SUFFIX=Cr
endif

ifeq ($(UNICODE_FLAG),true)
UNICODE_DEFINED=-d UNICODE
UNICODE_SUFFIX=W
else
UNICODE_DEFINED=
UNICODE_SUFFIX=A
endif

ifeq ($(WITHOUT_RUNTIME_FLAG),true)
WITHOUT_RUNTIME_DEFINED=-d WITHOUT_RUNTIME
GUIDS_WITHOUT_MINGW_DEFINED=-d GUIDS_WITHOUT_MINGW
WITHOUT_RUNTIME_SUFFIX=WoRt
GUIDS_WITHOUT_MINGW_SUFFIX=WoMingw
OBJECTFILES_CRUNTIME_ST=
OBJECTFILES_CRUNTIME_MT=
LIBRARIES_FBRUNTIME_ST=
LIBRARIES_FBRUNTIME_MT=
LIBRARIES_GCCRUNTIME=
else
WITHOUT_RUNTIME_DEFINED=
GUIDS_WITHOUT_MINGW_DEFINED=
WITHOUT_RUNTIME_SUFFIX=Rt
GUIDS_WITHOUT_MINGW_SUFFIX=Mingw
OBJECTFILES_CRUNTIME_ST="$(COMPILER_LIB_PATH)\crt2.o" "$(COMPILER_LIB_PATH)\crtbegin.o" "$(COMPILER_LIB_PATH)\crtend.o" "$(COMPILER_LIB_PATH)\fbrt0.o"
OBJECTFILES_CRUNTIME_MT=$(OBJECTFILES_CRUNTIME_ST) "$(COMPILER_LIB_PATH)\gcrt2.o"
LIBRARIES_FBRUNTIME_ST=-lfb
LIBRARIES_FBRUNTIME_MT=-lfbmt
LIBRARIES_GCCRUNTIME=-lgcc -lmingw32 -lmingwex -lmoldname -lgcc_eh
endif

ifeq ($(MULTITHREAD_RUNTIME_FLAG),true)
LIBRARIES_FBRUNTIME=$(LIBRARIES_FBRUNTIME_MT)
OBJECTFILES_CRUNTIME=$(OBJECTFILES_CRUNTIME_MT)
else
LIBRARIES_FBRUNTIME=$(LIBRARIES_FBRUNTIME_ST)
OBJECTFILES_CRUNTIME=$(OBJECTFILES_CRUNTIME_ST)
endif

FILE_SUFFIX_BASE=_$(GCC_VERSION_SUFFIX)_$(FBC_VERSION_SUFFIX)_$(PERFORMANCE_TESTING_SUFFIX)$(WITHOUT_RUNTIME_SUFFIX)$(WITHOUT_CRITICAL_SECTIONS_SUFFIX)$(GUIDS_WITHOUT_MINGW_SUFFIX)$(UNICODE_SUFFIX)
FILE_SUFFIX_CONSOLE=_Console$(FILE_SUFFIX_BASE)
FILE_SUFFIX_GUI=_GUI$(FILE_SUFFIX_BASE)
FILE_SUFFIX_SERVICE=_Service$(FILE_SUFFIX_BASE)
FILE_SUFFIX_TEST=_Test$(FILE_SUFFIX_BASE)

CODE_GENERATION_BACKEND=gcc
# CODE_GENERATION_BACKEND=gas
# CODE_GENERATION_BACKEND=gas64
# CODE_GENERATION_BACKEND=llvm

# C_COMPILER=gcc
# C_COMPILER=clang
# C_COMPILER=msvc
# GCC_ASSEMBLER=as
# GCC_ASSEMBLER=fasm
# GCC_ASSEMBLER=masm
# GCC_LINKER=ld

# REM set UseThreadSafeRuntime=-mt
# REM set EnableShowIncludes=-showincludes
# REM set EnableVerbose=-v
# REM set EnableRuntimeErrorChecking=-e
# REM set EnableFunctionProfiling=-profile

BIN_DEBUG_DIR_64=bin\Debug\x64
BIN_RELEASE_DIR_64=bin\Release\x64
OBJ_DEBUG_DIR_64=obj\Debug\x64
OBJ_RELEASE_DIR_64=obj\Release\x64

BIN_DEBUG_DIR_86=bin\Debug\x86
BIN_RELEASE_DIR_86=bin\Release\x86
OBJ_DEBUG_DIR_86=obj\Debug\x86
OBJ_RELEASE_DIR_86=obj\Release\x86

ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)

ifndef FREEBASIC_COMPILER
FREEBASIC_COMPILER="$(ProgramFiles)\FreeBASIC\fbc.exe"
endif
ifndef GCC_COMPILER
GCC_COMPILER=      "$(ProgramFiles)\FreeBASIC\bin\win64\gcc.exe"
endif
ifndef GCC_ASSEMBLER
GCC_ASSEMBLER=     "$(ProgramFiles)\FreeBASIC\bin\win64\as.exe"
endif
ifndef GCC_LINKER
GCC_LINKER=        "$(ProgramFiles)\FreeBASIC\bin\win64\ld.exe"
endif
ifndef ARCHIVE_COMPILER
ARCHIVE_COMPILER=  "$(ProgramFiles)\FreeBASIC\bin\win64\ar.exe"
endif
ifndef DLL_TOOL
DLL_TOOL=          "$(ProgramFiles)\FreeBASIC\bin\win64\dlltool.exe"
endif
ifndef RESOURCE_COMPILER
RESOURCE_COMPILER= "$(ProgramFiles)\FreeBASIC\bin\win64\GoRC.exe"
endif
ifndef COMPILER_LIB_PATH
COMPILER_LIB_PATH= $(ProgramFiles)\FreeBASIC\lib\win64
endif
ifndef FB_EXTRA
FB_EXTRA=          "$(ProgramFiles)\FreeBASIC\lib\win64\fbextra.x"
endif

GCC_ARCHITECTURE=-m64 -march=x86-64
TARGET_ASSEMBLER_ARCH=--64
ifeq ($(WITHOUT_RUNTIME_FLAG),true)
ENTRY_POINT_PARAM=-e ENTRYPOINT
else
ENTRY_POINT_PARAM=
endif
PE_FILE_FORMAT=i386pep
ResourceCompilerBitFlag=/machine X64
BIN_DEBUG_DIR=$(BIN_DEBUG_DIR_64)
BIN_RELEASE_DIR=$(BIN_RELEASE_DIR_64)
OBJ_DEBUG_DIR=$(OBJ_DEBUG_DIR_64)
OBJ_RELEASE_DIR=$(OBJ_RELEASE_DIR_64)

else

ifndef FREEBASIC_COMPILER
FREEBASIC_COMPILER="$(ProgramFiles)\FreeBASIC\fbc.exe"
endif
ifndef GCC_COMPILER
GCC_COMPILER=      "$(ProgramFiles)\FreeBASIC\bin\win32\gcc.exe"
endif
ifndef GCC_ASSEMBLER
GCC_ASSEMBLER=     "$(ProgramFiles)\FreeBASIC\bin\win32\as.exe"
endif
ifndef GCC_LINKER
GCC_LINKER=        "$(ProgramFiles)\FreeBASIC\bin\win32\ld.exe"
endif
ifndef ARCHIVE_COMPILER
ARCHIVE_COMPILER=  "$(ProgramFiles)\FreeBASIC\bin\win32\ar.exe"
endif
ifndef DLL_TOOL
DLL_TOOL=          "$(ProgramFiles)\FreeBASIC\bin\win32\dlltool.exe"
endif
ifndef RESOURCE_COMPILER
RESOURCE_COMPILER= "$(ProgramFiles)\FreeBASIC\bin\win32\GoRC.exe"
endif
ifndef COMPILER_LIB_PATH
COMPILER_LIB_PATH= $(ProgramFiles)\FreeBASIC\lib\win32
endif
ifndef FB_EXTRA
FB_EXTRA=          "$(ProgramFiles)\FreeBASIC\lib\win32\fbextra.x"
endif

GCC_ARCHITECTURE=
TARGET_ASSEMBLER_ARCH=--32
ifeq ($(WITHOUT_RUNTIME_FLAG),true)
ENTRY_POINT_PARAM=-e _ENTRYPOINT@0
else
ENTRY_POINT_PARAM=
endif
PE_FILE_FORMAT=i386pe
ResourceCompilerBitFlag=/nw
BIN_DEBUG_DIR=$(BIN_DEBUG_DIR_86)
BIN_RELEASE_DIR=$(BIN_RELEASE_DIR_86)
OBJ_DEBUG_DIR=$(OBJ_DEBUG_DIR_86)
OBJ_RELEASE_DIR=$(OBJ_RELEASE_DIR_86)

endif

FREEBASIC_PARAMETERS_BASE=-gen $(CODE_GENERATION_BACKEND) -r -maxerr 1 -w all -i Classes -i Headers -i Interfaces -i Modules -i Forms $(UNICODE_DEFINED) $(WITHOUT_CRITICAL_SECTIONS_DEFINED) $(WITHOUT_RUNTIME_DEFINED) $(GUIDS_WITHOUT_MINGW_DEFINED) $(PERFORMANCE_TESTING_DEFINED)
FREEBASIC_PARAMETERS_RELEASE=$(FREEBASIC_PARAMETERS_BASE) -O 0
FREEBASIC_PARAMETERS_DEBUG=  $(FREEBASIC_PARAMETERS_BASE) -O 0 -g

FREEBASIC_PARAMETERS_RELEASE_GUI=    $(FREEBASIC_PARAMETERS_RELEASE) -s gui     -d WINDOWS_GUI
FREEBASIC_PARAMETERS_DEBUG_GUI=      $(FREEBASIC_PARAMETERS_DEBUG)   -s gui     -d WINDOWS_GUI
FREEBASIC_PARAMETERS_RELEASE_CONSOLE=$(FREEBASIC_PARAMETERS_RELEASE) -s console -d WINDOWS_CONSOLE
FREEBASIC_PARAMETERS_DEBUG_CONSOLE=  $(FREEBASIC_PARAMETERS_DEBUG)   -s console -d WINDOWS_CONSOLE
FREEBASIC_PARAMETERS_RELEASE_SERVICE=$(FREEBASIC_PARAMETERS_RELEASE) -s console -d WINDOWS_SERVICE
FREEBASIC_PARAMETERS_DEBUG_SERVICE=  $(FREEBASIC_PARAMETERS_DEBUG)   -s console -d WINDOWS_SERVICE
FREEBASIC_PARAMETERS_RELEASE_TEST=   $(FREEBASIC_PARAMETERS_RELEASE) -s console -d WINDOWS_TEST
FREEBASIC_PARAMETERS_DEBUG_TEST=     $(FREEBASIC_PARAMETERS_DEBUG)   -s console -d WINDOWS_TEST

# -Wno-unused-but-set-variable
# -fwrapv
# -Wno-format
# -Wextra
GCC_COMPILER_WARNINGS=-Wall -Werror -Wno-unused-label -Wno-unused-function -Wno-unused-variable -Wno-main -Werror-implicit-function-declaration
# -fdata-sections
GCC_COMPILER_OPTIMIZATIONS=-ffunction-sections -mno-stack-arg-probe -fno-stack-check -fno-stack-protector -fno-unwind-tables -fno-asynchronous-unwind-tables
GCC_COMPILER_PARAMETERS_BASE=$(GCC_COMPILER_WARNINGS) -nostdlib -nostdinc -fno-strict-aliasing -frounding-math -fno-math-errno -fno-exceptions -fno-ident
GCC_COMPILER_PARAMETERS_RELEASE_03=$(GCC_COMPILER_PARAMETERS_BASE) $(GCC_ARCHITECTURE) $(GCC_COMPILER_OPTIMIZATIONS) -masm=intel -S -Ofast
GCC_COMPILER_PARAMETERS_RELEASE_O0=$(GCC_COMPILER_PARAMETERS_BASE) $(GCC_ARCHITECTURE) $(GCC_COMPILER_OPTIMIZATIONS) -masm=intel -S -O0
GCC_COMPILER_PARAMETERS_DEBUG=   $(GCC_COMPILER_PARAMETERS_BASE) $(GCC_ARCHITECTURE) -masm=intel -S -g -Og                                                            
GCC_COMPILER_PARAMETERS_DEBUG_O0=$(GCC_COMPILER_PARAMETERS_BASE) $(GCC_ARCHITECTURE) -masm=intel -S -g -O0

GCC_ASSEMBLER_PARAMETERS_RELEASE=$(TARGET_ASSEMBLER_ARCH) --strip-local-absolute
GCC_ASSEMBLER_PARAMETERS_DEBUG=  $(TARGET_ASSEMBLER_ARCH)

GCC_LINKER_PARAMETERS_BASE=-m $(PE_FILE_FORMAT)         -subsystem console $(ENTRY_POINT_PARAM) --stack 1048576,1048576 --major-image-version 1 --minor-image-version 0 --no-seh --nxcompat -L "$(COMPILER_LIB_PATH)" -L "." $(OBJECTFILES_CRUNTIME)
# --print-gc-sections
GCC_LINKER_PARAMETERS_RELEASE=$(GCC_LINKER_PARAMETERS_BASE) -s --gc-sections
GCC_LINKER_PARAMETERS_DEBUG=  $(GCC_LINKER_PARAMETERS_BASE)

GCC_LINKER_PARAMETERS_BASE_CONSOLE=-m $(PE_FILE_FORMAT) -subsystem console $(ENTRY_POINT_PARAM) --stack 1048576,1048576 --major-image-version 1 --minor-image-version 0 --no-seh --nxcompat -L "$(COMPILER_LIB_PATH)" -L "." $(OBJECTFILES_CRUNTIME)
GCC_LINKER_PARAMETERS_BASE_CONSOLE=-m $(PE_FILE_FORMAT) -subsystem console $(ENTRY_POINT_PARAM) --stack 1048576,1048576 --major-image-version 1 --minor-image-version 0 --no-seh --nxcompat -L "$(COMPILER_LIB_PATH)" -L "." $(OBJECTFILES_CRUNTIME)
GCC_LINKER_PARAMETERS_BASE_GUI=    -m $(PE_FILE_FORMAT) -subsystem windows $(ENTRY_POINT_PARAM) --stack 1048576,1048576 --major-image-version 1 --minor-image-version 0 --no-seh --nxcompat -L "$(COMPILER_LIB_PATH)" -L "." $(OBJECTFILES_CRUNTIME)
GCC_LINKER_PARAMETERS_BASE_GUI=    -m $(PE_FILE_FORMAT) -subsystem windows $(ENTRY_POINT_PARAM) --stack 1048576,1048576 --major-image-version 1 --minor-image-version 0 --no-seh --nxcompat -L "$(COMPILER_LIB_PATH)" -L "." $(OBJECTFILES_CRUNTIME)
GCC_LINKER_PARAMETERS_RELEASE_CONSOLE=$(GCC_LINKER_PARAMETERS_BASE_CONSOLE) -s --gc-sections
GCC_LINKER_PARAMETERS_DEBUG_CONSOLE=  $(GCC_LINKER_PARAMETERS_BASE_CONSOLE)
GCC_LINKER_PARAMETERS_RELEASE_GUI=    $(GCC_LINKER_PARAMETERS_BASE_GUI) -s --gc-sections
GCC_LINKER_PARAMETERS_DEBUG_GUI=      $(GCC_LINKER_PARAMETERS_BASE_GUI)

OUTPUT_FILE_NAME_CONSOLE=ColorLines$(FILE_SUFFIX_CONSOLE).exe
OUTPUT_FILE_NAME_GUI=ColorLines$(FILE_SUFFIX_GUI).exe

LIBRARIES_UUID=-luuid
LIBRARIES_WINAPI=-ladvapi32 -lcomctl32 -lcomdlg32 -lcrypt32 -lgdi32 -lgdiplus -limm32 -lkernel32 -lmsimg32 -lmsvcrt -lmswsock -lole32 -loleaut32 -lshell32 -lshlwapi -luser32 -lversion -lwinmm -lwinspool -lws2_32
LIBRARIES_BASE=$(LIBRARIES_GCCRUNTIME) $(LIBRARIES_FBRUNTIME) $(LIBRARIES_WINAPI) $(LIBRARIES_UUID) $(LIBRARIES_GMONITOR)
LIBRARIES_ALL=$(LIBRARIES_BASE)

OBJECTFILES_RELEASE_GUI_MODULES=    $(OBJ_RELEASE_DIR)\DisplayError$(FILE_SUFFIX_GUI).o $(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_GUI).o $(OBJ_RELEASE_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).o $(OBJ_RELEASE_DIR)\GameModel$(FILE_SUFFIX_GUI).o $(OBJ_RELEASE_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).o $(OBJ_RELEASE_DIR)\ResourceManager$(FILE_SUFFIX_GUI).o $(OBJ_RELEASE_DIR)\Scene$(FILE_SUFFIX_GUI).o $(OBJ_RELEASE_DIR)\Stage$(FILE_SUFFIX_GUI).o
OBJECTFILES_DEBUG_GUI_MODULES=      $(OBJ_DEBUG_DIR)\DisplayError$(FILE_SUFFIX_GUI).o   $(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_GUI).o   $(OBJ_DEBUG_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).o   $(OBJ_DEBUG_DIR)\GameModel$(FILE_SUFFIX_GUI).o   $(OBJ_DEBUG_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).o   $(OBJ_DEBUG_DIR)\ResourceManager$(FILE_SUFFIX_GUI).o   $(OBJ_DEBUG_DIR)\Scene$(FILE_SUFFIX_GUI).o   $(OBJ_DEBUG_DIR)\Stage$(FILE_SUFFIX_GUI).o
OBJECTFILES_RELEASE_CONSOLE_MODULES=$(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).o  
OBJECTFILES_DEBUG_CONSOLE_MODULES=  $(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).o   

OBJECTFILES_RELEASE_GUI_RESOURCES=    $(OBJ_RELEASE_DIR)\Resources$(FILE_SUFFIX_BASE).obj
OBJECTFILES_DEBUG_GUI_RESOURCES=  $(OBJ_DEBUG_DIR)\Resources$(FILE_SUFFIX_BASE).obj
OBJECTFILES_RELEASE_CONSOLE_RESOURCES=$(OBJ_RELEASE_DIR)\Resources$(FILE_SUFFIX_BASE).obj
OBJECTFILES_DEBUG_CONSOLE_RESOURCES=  $(OBJ_DEBUG_DIR)\Resources$(FILE_SUFFIX_BASE).obj

OBJECTFILES_RELEASE_GUI_BASE=    $(OBJECTFILES_RELEASE_GUI_MODULES)     $(OBJECTFILES_RELEASE_GUI_RESOURCES)
OBJECTFILES_DEBUG_GUI_BASE=      $(OBJECTFILES_DEBUG_GUI_MODULES)       $(OBJECTFILES_DEBUG_GUI_RESOURCES)
OBJECTFILES_RELEASE_CONSOLE_BASE=$(OBJECTFILES_RELEASE_CONSOLE_MODULES) $(OBJECTFILES_RELEASE_CONSOLE_RESOURCES)
OBJECTFILES_DEBUG_CONSOLE_BASE=  $(OBJECTFILES_DEBUG_CONSOLE_MODULES)   $(OBJECTFILES_DEBUG_CONSOLE_RESOURCES)

OBJECTFILES_RELEASE_GUI=    $(OBJECTFILES_RELEASE_GUI_BASE)     $(OBJ_RELEASE_DIR)\WinMain$(FILE_SUFFIX_GUI).o        
OBJECTFILES_DEBUG_GUI=      $(OBJECTFILES_DEBUG_GUI_BASE)       $(OBJ_DEBUG_DIR)\WinMain$(FILE_SUFFIX_GUI).o          
OBJECTFILES_RELEASE_CONSOLE=$(OBJECTFILES_RELEASE_CONSOLE_BASE) $(OBJ_RELEASE_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).o
OBJECTFILES_DEBUG_CONSOLE=  $(OBJECTFILES_DEBUG_CONSOLE_BASE)   $(OBJ_DEBUG_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).o  


$(BIN_RELEASE_DIR)\$(OUTPUT_FILE_NAME_GUI): $(OBJECTFILES_RELEASE_GUI)
	$(GCC_LINKER) $(GCC_LINKER_PARAMETERS_RELEASE_GUI) $(OBJECTFILES_RELEASE_GUI) -L "$(OBJ_RELEASE_DIR)" -( $(LIBRARIES_ALL) -) -o "$(BIN_RELEASE_DIR)\$(OUTPUT_FILE_NAME_GUI)"

$(BIN_DEBUG_DIR)\$(OUTPUT_FILE_NAME_GUI):   $(OBJECTFILES_DEBUG_GUI)
	$(GCC_LINKER) $(GCC_LINKER_PARAMETERS_DEBUG_GUI) $(OBJECTFILES_DEBUG_GUI)     -L "$(OBJ_DEBUG_DIR)"   -( $(LIBRARIES_ALL) -lgcc -lmingw32 -lmingwex -lmoldname -lgcc_eh -) -o "$(BIN_DEBUG_DIR)\$(OUTPUT_FILE_NAME_GUI)"


$(BIN_RELEASE_DIR)\$(OUTPUT_FILE_NAME_CONSOLE): $(OBJECTFILES_RELEASE_CONSOLE) 
	$(GCC_LINKER) $(GCC_LINKER_PARAMETERS_RELEASE_CONSOLE) $(OBJECTFILES_RELEASE_CONSOLE) -L "$(OBJ_RELEASE_DIR)" -( $(LIBRARIES_ALL) -) -o "$(BIN_RELEASE_DIR)\$(OUTPUT_FILE_NAME_CONSOLE)"

$(BIN_DEBUG_DIR)\$(OUTPUT_FILE_NAME_CONSOLE):   $(OBJECTFILES_DEBUG_CONSOLE)   
	$(GCC_LINKER) $(GCC_LINKER_PARAMETERS_DEBUG_CONSOLE) $(OBJECTFILES_DEBUG_CONSOLE)     -L "$(OBJ_DEBUG_DIR)"   -( $(LIBRARIES_ALL) -lgcc -lmingw32 -lmingwex -lmoldname -lgcc_eh -) -o "$(BIN_DEBUG_DIR)\$(OUTPUT_FILE_NAME_CONSOLE)"


release: $(BIN_RELEASE_DIR)\$(OUTPUT_FILE_NAME_GUI)

debug: $(BIN_DEBUG_DIR)\$(OUTPUT_FILE_NAME_GUI)

clean:
	echo del %AllFileWithExtensionC% %AllFileWithExtensionAsm% %AllObjectFiles%

configure:
	mkdir "$(BIN_DEBUG_DIR_64)"
	mkdir "$(BIN_RELEASE_DIR_64)"
	mkdir "$(OBJ_DEBUG_DIR_64)"
	mkdir "$(OBJ_RELEASE_DIR_64)"
	mkdir "$(BIN_DEBUG_DIR_86)"
	mkdir "$(BIN_RELEASE_DIR_86)"
	mkdir "$(OBJ_DEBUG_DIR_86)"
	mkdir "$(OBJ_RELEASE_DIR_86)"


$(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_GUI).o: $(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_RELEASE) $(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_GUI).asm -o $(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_GUI).o

$(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_GUI).o:   $(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_GUI).asm -o $(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_GUI).o

$(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_GUI).asm: $(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_RELEASE_03) $(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_GUI).c -o $(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_GUI).asm

$(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_GUI).asm:   $(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_GUI).c -o $(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_GUI).asm

$(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_GUI).c: Modules\EntryPoint.bas Modules\EntryPoint.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_RELEASE_GUI) "Modules\EntryPoint.bas"
	move /y Modules\EntryPoint.c $(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_GUI).c

$(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_GUI).c:   Modules\EntryPoint.bas Modules\EntryPoint.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_DEBUG_GUI) "Modules\EntryPoint.bas"
	move /y Modules\EntryPoint.c $(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_GUI).c



$(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).o: $(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_RELEASE) $(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).asm -o $(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).o

$(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).o:   $(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).asm -o $(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).o

$(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).asm: $(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_RELEASE_03) $(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).c -o $(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).asm

$(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).asm:   $(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).c -o $(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).asm

$(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).c: Modules\EntryPoint.bas Modules\EntryPoint.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_RELEASE_CONSOLE) "Modules\EntryPoint.bas"
	move /y Modules\EntryPoint.c $(OBJ_RELEASE_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).c

$(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).c:   Modules\EntryPoint.bas Modules\EntryPoint.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_DEBUG_CONSOLE) "Modules\EntryPoint.bas"
	move /y Modules\EntryPoint.c $(OBJ_DEBUG_DIR)\EntryPoint$(FILE_SUFFIX_CONSOLE).c



$(OBJ_RELEASE_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).o: $(OBJ_RELEASE_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_RELEASE) $(OBJ_RELEASE_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).asm -o $(OBJ_RELEASE_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).o

$(OBJ_DEBUG_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).o:   $(OBJ_DEBUG_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).asm -o $(OBJ_DEBUG_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).o

$(OBJ_RELEASE_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).asm: $(OBJ_RELEASE_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_RELEASE_03) $(OBJ_RELEASE_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).c -o $(OBJ_RELEASE_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).asm

$(OBJ_DEBUG_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).asm:   $(OBJ_DEBUG_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).c -o $(OBJ_DEBUG_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).asm

$(OBJ_RELEASE_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).c: Modules\ConsoleMain.bas Modules\ConsoleMain.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_RELEASE_CONSOLE) "Modules\ConsoleMain.bas"
	move /y Modules\ConsoleMain.c $(OBJ_RELEASE_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).c

$(OBJ_DEBUG_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).c:   Modules\ConsoleMain.bas Modules\ConsoleMain.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_DEBUG_CONSOLE) "Modules\ConsoleMain.bas"
	move /y Modules\ConsoleMain.c $(OBJ_DEBUG_DIR)\ConsoleMain$(FILE_SUFFIX_CONSOLE).c



$(OBJ_RELEASE_DIR)\WinMain$(FILE_SUFFIX_GUI).o: $(OBJ_RELEASE_DIR)\WinMain$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_RELEASE) $(OBJ_RELEASE_DIR)\WinMain$(FILE_SUFFIX_GUI).asm -o $(OBJ_RELEASE_DIR)\WinMain$(FILE_SUFFIX_GUI).o

$(OBJ_DEBUG_DIR)\WinMain$(FILE_SUFFIX_GUI).o:   $(OBJ_DEBUG_DIR)\WinMain$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\WinMain$(FILE_SUFFIX_GUI).asm -o $(OBJ_DEBUG_DIR)\WinMain$(FILE_SUFFIX_GUI).o

$(OBJ_RELEASE_DIR)\WinMain$(FILE_SUFFIX_GUI).asm: $(OBJ_RELEASE_DIR)\WinMain$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_RELEASE_03) $(OBJ_RELEASE_DIR)\WinMain$(FILE_SUFFIX_GUI).c -o $(OBJ_RELEASE_DIR)\WinMain$(FILE_SUFFIX_GUI).asm

$(OBJ_DEBUG_DIR)\WinMain$(FILE_SUFFIX_GUI).asm:   $(OBJ_DEBUG_DIR)\WinMain$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\WinMain$(FILE_SUFFIX_GUI).c -o $(OBJ_DEBUG_DIR)\WinMain$(FILE_SUFFIX_GUI).asm

$(OBJ_RELEASE_DIR)\WinMain$(FILE_SUFFIX_GUI).c: Modules\WinMain.bas Modules\WinMain.bi Resources.RH Modules\DisplayError.bi Forms\MainFormWndProc.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_RELEASE_GUI) "Modules\WinMain.bas"
	move /y Modules\WinMain.c $(OBJ_RELEASE_DIR)\WinMain$(FILE_SUFFIX_GUI).c

$(OBJ_DEBUG_DIR)\WinMain$(FILE_SUFFIX_GUI).c:   Modules\WinMain.bas Modules\WinMain.bi Resources.RH Modules\DisplayError.bi Forms\MainFormWndProc.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_DEBUG_GUI) "Modules\WinMain.bas"
	move /y Modules\WinMain.c $(OBJ_DEBUG_DIR)\WinMain$(FILE_SUFFIX_GUI).c



$(OBJ_RELEASE_DIR)\DisplayError$(FILE_SUFFIX_GUI).o: $(OBJ_RELEASE_DIR)\DisplayError$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_RELEASE) $(OBJ_RELEASE_DIR)\DisplayError$(FILE_SUFFIX_GUI).asm -o $(OBJ_RELEASE_DIR)\DisplayError$(FILE_SUFFIX_GUI).o

$(OBJ_DEBUG_DIR)\DisplayError$(FILE_SUFFIX_GUI).o:   $(OBJ_DEBUG_DIR)\DisplayError$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\DisplayError$(FILE_SUFFIX_GUI).asm -o $(OBJ_DEBUG_DIR)\DisplayError$(FILE_SUFFIX_GUI).o

$(OBJ_RELEASE_DIR)\DisplayError$(FILE_SUFFIX_GUI).asm: $(OBJ_RELEASE_DIR)\DisplayError$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_RELEASE_03) $(OBJ_RELEASE_DIR)\DisplayError$(FILE_SUFFIX_GUI).c -o $(OBJ_RELEASE_DIR)\DisplayError$(FILE_SUFFIX_GUI).asm

$(OBJ_DEBUG_DIR)\DisplayError$(FILE_SUFFIX_GUI).asm:   $(OBJ_DEBUG_DIR)\DisplayError$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\DisplayError$(FILE_SUFFIX_GUI).c -o $(OBJ_DEBUG_DIR)\DisplayError$(FILE_SUFFIX_GUI).asm

$(OBJ_RELEASE_DIR)\DisplayError$(FILE_SUFFIX_GUI).c: Modules\DisplayError.bas Modules\DisplayError.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_RELEASE_GUI) "Modules\DisplayError.bas"
	move /y Modules\DisplayError.c $(OBJ_RELEASE_DIR)\DisplayError$(FILE_SUFFIX_GUI).c

$(OBJ_DEBUG_DIR)\DisplayError$(FILE_SUFFIX_GUI).c:   Modules\DisplayError.bas Modules\DisplayError.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_DEBUG_GUI) "Modules\DisplayError.bas"
	move /y Modules\DisplayError.c $(OBJ_DEBUG_DIR)\DisplayError$(FILE_SUFFIX_GUI).c



$(OBJ_RELEASE_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).o: $(OBJ_RELEASE_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_RELEASE) $(OBJ_RELEASE_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).asm -o $(OBJ_RELEASE_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).o

$(OBJ_DEBUG_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).o:   $(OBJ_DEBUG_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).asm -o $(OBJ_DEBUG_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).o

$(OBJ_RELEASE_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).asm: $(OBJ_RELEASE_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_RELEASE_03) $(OBJ_RELEASE_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).c -o $(OBJ_RELEASE_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).asm

$(OBJ_DEBUG_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).asm:   $(OBJ_DEBUG_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).c -o $(OBJ_DEBUG_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).asm

$(OBJ_RELEASE_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).c: Forms\MainFormWndProc.bas Forms\MainFormWndProc.bi Resources.RH Modules\DisplayError.bi Classes\Scene.bi Classes\Stage.bi Classes\GameModel.bi Classes\GdiMatrix.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_RELEASE_GUI) "Forms\MainFormWndProc.bas"
	move /y Forms\MainFormWndProc.c $(OBJ_RELEASE_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).c

$(OBJ_DEBUG_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).c:   Forms\MainFormWndProc.bas Forms\MainFormWndProc.bi Resources.RH Modules\DisplayError.bi Classes\Scene.bi Classes\Stage.bi Classes\GameModel.bi Classes\GdiMatrix.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_DEBUG_GUI) "Forms\MainFormWndProc.bas"
	move /y Forms\MainFormWndProc.c $(OBJ_DEBUG_DIR)\MainFormWndProc$(FILE_SUFFIX_GUI).c



$(OBJ_RELEASE_DIR)\GameModel$(FILE_SUFFIX_GUI).o: $(OBJ_RELEASE_DIR)\GameModel$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_RELEASE) $(OBJ_RELEASE_DIR)\GameModel$(FILE_SUFFIX_GUI).asm -o $(OBJ_RELEASE_DIR)\GameModel$(FILE_SUFFIX_GUI).o

$(OBJ_DEBUG_DIR)\GameModel$(FILE_SUFFIX_GUI).o:   $(OBJ_DEBUG_DIR)\GameModel$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\GameModel$(FILE_SUFFIX_GUI).asm -o $(OBJ_DEBUG_DIR)\GameModel$(FILE_SUFFIX_GUI).o

$(OBJ_RELEASE_DIR)\GameModel$(FILE_SUFFIX_GUI).asm: $(OBJ_RELEASE_DIR)\GameModel$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_RELEASE_03) $(OBJ_RELEASE_DIR)\GameModel$(FILE_SUFFIX_GUI).c -o $(OBJ_RELEASE_DIR)\GameModel$(FILE_SUFFIX_GUI).asm

$(OBJ_DEBUG_DIR)\GameModel$(FILE_SUFFIX_GUI).asm:   $(OBJ_DEBUG_DIR)\GameModel$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\GameModel$(FILE_SUFFIX_GUI).c -o $(OBJ_DEBUG_DIR)\GameModel$(FILE_SUFFIX_GUI).asm

$(OBJ_RELEASE_DIR)\GameModel$(FILE_SUFFIX_GUI).c: Classes\GameModel.bas Classes\GameModel.bi Classes\Stage.bi Classes\Scene.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_RELEASE_GUI) "Classes\GameModel.bas"
	move /y Classes\GameModel.c $(OBJ_RELEASE_DIR)\GameModel$(FILE_SUFFIX_GUI).c

$(OBJ_DEBUG_DIR)\GameModel$(FILE_SUFFIX_GUI).c:   Classes\GameModel.bas Classes\GameModel.bi Classes\Stage.bi Classes\Scene.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_DEBUG_GUI) "Classes\GameModel.bas"
	move /y Classes\GameModel.c $(OBJ_DEBUG_DIR)\GameModel$(FILE_SUFFIX_GUI).c



$(OBJ_RELEASE_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).o: $(OBJ_RELEASE_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_RELEASE) $(OBJ_RELEASE_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).asm -o $(OBJ_RELEASE_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).o

$(OBJ_DEBUG_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).o:   $(OBJ_DEBUG_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).asm -o $(OBJ_DEBUG_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).o

$(OBJ_RELEASE_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).asm: $(OBJ_RELEASE_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_RELEASE_03) $(OBJ_RELEASE_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).c -o $(OBJ_RELEASE_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).asm

$(OBJ_DEBUG_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).asm:   $(OBJ_DEBUG_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).c -o $(OBJ_DEBUG_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).asm

$(OBJ_RELEASE_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).c: Classes\GdiMatrix.bas Classes\GdiMatrix.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_RELEASE_GUI) "Classes\GdiMatrix.bas"
	move /y Classes\GdiMatrix.c $(OBJ_RELEASE_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).c

$(OBJ_DEBUG_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).c:   Classes\GdiMatrix.bas Classes\GdiMatrix.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_DEBUG_GUI) "Classes\GdiMatrix.bas"
	move /y Classes\GdiMatrix.c $(OBJ_DEBUG_DIR)\GdiMatrix$(FILE_SUFFIX_GUI).c



$(OBJ_RELEASE_DIR)\ResourceManager$(FILE_SUFFIX_GUI).o: $(OBJ_RELEASE_DIR)\ResourceManager$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_RELEASE) $(OBJ_RELEASE_DIR)\ResourceManager$(FILE_SUFFIX_GUI).asm -o $(OBJ_RELEASE_DIR)\ResourceManager$(FILE_SUFFIX_GUI).o

$(OBJ_DEBUG_DIR)\ResourceManager$(FILE_SUFFIX_GUI).o:   $(OBJ_DEBUG_DIR)\ResourceManager$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\ResourceManager$(FILE_SUFFIX_GUI).asm -o $(OBJ_DEBUG_DIR)\ResourceManager$(FILE_SUFFIX_GUI).o

$(OBJ_RELEASE_DIR)\ResourceManager$(FILE_SUFFIX_GUI).asm: $(OBJ_RELEASE_DIR)\ResourceManager$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_RELEASE_03) $(OBJ_RELEASE_DIR)\ResourceManager$(FILE_SUFFIX_GUI).c -o $(OBJ_RELEASE_DIR)\ResourceManager$(FILE_SUFFIX_GUI).asm

$(OBJ_DEBUG_DIR)\ResourceManager$(FILE_SUFFIX_GUI).asm:   $(OBJ_DEBUG_DIR)\ResourceManager$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\ResourceManager$(FILE_SUFFIX_GUI).c -o $(OBJ_DEBUG_DIR)\ResourceManager$(FILE_SUFFIX_GUI).asm

$(OBJ_RELEASE_DIR)\ResourceManager$(FILE_SUFFIX_GUI).c: Classes\ResourceManager.bas Classes\ResourceManager.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_RELEASE_GUI) "Classes\ResourceManager.bas"
	move /y Classes\ResourceManager.c $(OBJ_RELEASE_DIR)\ResourceManager$(FILE_SUFFIX_GUI).c

$(OBJ_DEBUG_DIR)\ResourceManager$(FILE_SUFFIX_GUI).c:   Classes\ResourceManager.bas Classes\ResourceManager.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_DEBUG_GUI) "Classes\ResourceManager.bas"
	move /y Classes\ResourceManager.c $(OBJ_DEBUG_DIR)\ResourceManager$(FILE_SUFFIX_GUI).c




$(OBJ_RELEASE_DIR)\Scene$(FILE_SUFFIX_GUI).o: $(OBJ_RELEASE_DIR)\Scene$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_RELEASE) $(OBJ_RELEASE_DIR)\Scene$(FILE_SUFFIX_GUI).asm -o $(OBJ_RELEASE_DIR)\Scene$(FILE_SUFFIX_GUI).o

$(OBJ_DEBUG_DIR)\Scene$(FILE_SUFFIX_GUI).o:   $(OBJ_DEBUG_DIR)\Scene$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\Scene$(FILE_SUFFIX_GUI).asm -o $(OBJ_DEBUG_DIR)\Scene$(FILE_SUFFIX_GUI).o

$(OBJ_RELEASE_DIR)\Scene$(FILE_SUFFIX_GUI).asm: $(OBJ_RELEASE_DIR)\Scene$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_RELEASE_03) $(OBJ_RELEASE_DIR)\Scene$(FILE_SUFFIX_GUI).c -o $(OBJ_RELEASE_DIR)\Scene$(FILE_SUFFIX_GUI).asm

$(OBJ_DEBUG_DIR)\Scene$(FILE_SUFFIX_GUI).asm:   $(OBJ_DEBUG_DIR)\Scene$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\Scene$(FILE_SUFFIX_GUI).c -o $(OBJ_DEBUG_DIR)\Scene$(FILE_SUFFIX_GUI).asm

$(OBJ_RELEASE_DIR)\Scene$(FILE_SUFFIX_GUI).c: Classes\Scene.bas Classes\Scene.bi Classes\Stage.bi Classes\GdiMatrix.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_RELEASE_GUI) "Classes\Scene.bas"
	move /y Classes\Scene.c $(OBJ_RELEASE_DIR)\Scene$(FILE_SUFFIX_GUI).c

$(OBJ_DEBUG_DIR)\Scene$(FILE_SUFFIX_GUI).c:   Classes\Scene.bas Classes\Scene.bi Classes\Stage.bi Classes\GdiMatrix.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_DEBUG_GUI) "Classes\Scene.bas"
	move /y Classes\Scene.c $(OBJ_DEBUG_DIR)\Scene$(FILE_SUFFIX_GUI).c




$(OBJ_RELEASE_DIR)\Stage$(FILE_SUFFIX_GUI).o: $(OBJ_RELEASE_DIR)\Stage$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_RELEASE) $(OBJ_RELEASE_DIR)\Stage$(FILE_SUFFIX_GUI).asm -o $(OBJ_RELEASE_DIR)\Stage$(FILE_SUFFIX_GUI).o

$(OBJ_DEBUG_DIR)\Stage$(FILE_SUFFIX_GUI).o:   $(OBJ_DEBUG_DIR)\Stage$(FILE_SUFFIX_GUI).asm
	$(GCC_ASSEMBLER) $(GCC_ASSEMBLER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\Stage$(FILE_SUFFIX_GUI).asm -o $(OBJ_DEBUG_DIR)\Stage$(FILE_SUFFIX_GUI).o

$(OBJ_RELEASE_DIR)\Stage$(FILE_SUFFIX_GUI).asm: $(OBJ_RELEASE_DIR)\Stage$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_RELEASE_03) $(OBJ_RELEASE_DIR)\Stage$(FILE_SUFFIX_GUI).c -o $(OBJ_RELEASE_DIR)\Stage$(FILE_SUFFIX_GUI).asm

$(OBJ_DEBUG_DIR)\Stage$(FILE_SUFFIX_GUI).asm:   $(OBJ_DEBUG_DIR)\Stage$(FILE_SUFFIX_GUI).c
	$(GCC_COMPILER) $(GCC_COMPILER_PARAMETERS_DEBUG) $(OBJ_DEBUG_DIR)\Stage$(FILE_SUFFIX_GUI).c -o $(OBJ_DEBUG_DIR)\Stage$(FILE_SUFFIX_GUI).asm

$(OBJ_RELEASE_DIR)\Stage$(FILE_SUFFIX_GUI).c: Classes\Stage.bas Classes\Stage.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_RELEASE_GUI) "Classes\Stage.bas"
	move /y Classes\Stage.c $(OBJ_RELEASE_DIR)\Stage$(FILE_SUFFIX_GUI).c

$(OBJ_DEBUG_DIR)\Stage$(FILE_SUFFIX_GUI).c:   Classes\Stage.bas Classes\Stage.bi
	$(FREEBASIC_COMPILER) $(FREEBASIC_PARAMETERS_DEBUG_GUI) "Classes\Stage.bas"
	move /y Classes\Stage.c $(OBJ_DEBUG_DIR)\Stage$(FILE_SUFFIX_GUI).c




$(OBJ_RELEASE_DIR)\Resources$(FILE_SUFFIX_BASE).obj: Resources.RC Resources.RH ColorLines.exe.manifest icon.ico
	$(RESOURCE_COMPILER)         /ni $(ResourceCompilerBitFlag)  /o /fo Resources.obj Resources.RC
	move /y Resources.obj $(OBJ_RELEASE_DIR)\Resources$(FILE_SUFFIX_BASE).obj

$(OBJ_DEBUG_DIR)\Resources$(FILE_SUFFIX_BASE).obj:   Resources.RC Resources.RH ColorLines.exe.manifest icon.ico
	$(RESOURCE_COMPILER) /d DEBUG /ni $(ResourceCompilerBitFlag) /o /fo Resources.obj Resources.RC
	move /y Resources.obj $(OBJ_DEBUG_DIR)\Resources$(FILE_SUFFIX_BASE).obj
