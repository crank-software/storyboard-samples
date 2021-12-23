# Set this variable to the engine directory (Storyboard_Engine/<build_id>/ under where you installed Storyboard Suite.  
# If building on Windows, you make need to put the path in "'s
#SB_INSTALL=

# This is needed so that the build targets are setup properely for when you are building on Windows or for Unix.  If building
# for Windows then setup build type to WIN.  If building for Linux/Android/Mac/QNX set the build type to UNIX
#BUILD_TYPE=

# HOST SYSTEM CONFIGURATIONS 
# Use a host system configuration if you are building for use in the simulator or looking to run a sample on 
# a typical x86 machine. 

# If building for Windows
# You should be able to set CC to cl.exe after running the vcvarsall.bat script that come with Visual Studio. 
# You will also need to install a version of GNU make (MinGW or Cywin are projects that provide this) in order 
# to use this make file on Windows. 

#CFLAGS+=/nologo -DWIN32 -DLUA_BUILD_AS_DLL /MD -DLUA_LIB
#LDFLAGS+= /nologo /INCREMENTAL:NO /MANIFEST /DLL  
#SB_ROOT=$(SB_INSTALL)/win32-x86-opengles_2.0-obj
#SB_TARGET_DIR=win32-x86
#CC=cl.exe

#
# If building for MacOS 
# You should be able to CC to the default compiler that is used on MacOS. 
#CFLAGS += -fPIC
#LDFLAGS+= -shared -flat_namespace -undefined suppress -install_name $(TARGET)
#SB_ROOT=$(SB_INSTALL)/macos-x86_64-opengles_2.0-obj
#SB_TARGET_DIR=macos-x86_64
#CC=gcc

#
# If building for Generic Linux/Unix x86_64
# You should be able to set CC to the default 64 bit compiler that you use on Linux
#CFLAGS += -fPIC
#LDFLAGS+= -shared
#SB_TARGET_DIR=linux-x86_64
#SB_ROOT=$(SB_INSTALL)/linux-x86_64-opengles_2.0-x11-obj
#CC=gcc

# TARGET SYSTEM CONFIGURATIONS 
# Use a target system configuration if you are building for deployment to a end target system
#
# If building for a target
# You should be able to set CC to the cross compiler that you are using to compile binaries for your target
# For the SB_ROOT directory, choose the OS that matches your target os, such as Linux, QNX or Android, 
# The compiler type that matches your target, for exmple imx6yocto or fsl, the CPU that matches your target such
# as armle, and the render manager that you are using on the target. 
# For the SB_TARGET directory us the OS name, such as linux or andriod, followed by the CPU type, such as armle
#CFLAGS += Add the cflags for your target compiler here
#LDFLAGS+= Add the ldflags for your target compiler here
#SB_TARGET_DIR=<OS>-<CPU>
#SB_ROOT=$(SB_INSTALL)/<OS>-<COMPILER_TYPE>-<CPU>-<RENDER_MGR>-obj
#CC=<CROSS-COMPILER>


#ERRORS:  IF YOU ARE GETTING ONE OF THESE ERRORS THEN YOU HAVEN'T SETUP YOUR CONFIGURATION COMPLETELY
ifndef SB_INSTALL
$(error You must set the SB_INSTALL variable for your target in the Makefile before you can build this library)
endif

ifndef BUILD_TYPE
$(error You must set the BUILD_TYPE variable for your target in the Makefile before you can build this library)
endif

ifndef SB_ROOT
$(error You must set the SB_ROOT variable for your target in the Makefile before you can build this library)
endif

ifndef SB_TARGET_DIR
$(error You must set the SB_TARGET_DIR variable for your target in the Makefile before you can build this library)
endif

#
# Should not require changes past this line
#

ifeq ($(BUILD_TYPE),WIN)

TARGET=sbmodule.dll
SRCS=sbmodule.c
OBJS=${SRCS:.c=.obj}

SB_INC=/I$(SB_ROOT)/include /I$(SB_ROOT)/include/lua
SB_LIB=/LIBPATH:$(SB_ROOT)/lib libsblua.lib

$(TARGET) : $(OBJS)
	link.exe $(LDFLAGS) /OUT:$@ $^ $(SB_LIB) user32.lib Gdi32.lib Msimg32.lib Kernel32.lib Wtsapi32.lib
	mt.exe -nologo -manifest $(TARGET).manifest -outputresource:$(TARGET)\;2   

%.obj:%.c
	$(CC) $(CFLAGS) $(SB_INC) /c /Fo$@ $^

clean:
	rm -fr $(OBJS)
	rm -fr $(TARGET)

xfer:
	mkdir -p ../scripts/$(SB_TARGET_DIR)
	cp $(TARGET) ../scripts/$(SB_TARGET_DIR)/$(TARGET)

else
TARGET=sbmodule.so
SRCS=sbmodule.c
OBJS=${SRCS:.c=.o}

SB_INC=-I$(SB_ROOT)/include -I$(SB_ROOT)/include/lua
SB_LIB=-L$(SB_ROOT)/lib -lsblua

$(TARGET) : $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(SB_INC) -o $@ $^ $(SB_LIB)

%.o:%.c
	$(CC) $(CFLAGS) $(SB_INC) -c -o $@ $^

clean:
	rm -fr $(OBJS)
	rm -fr $(TARGET)

xfer:
	mkdir -p ../scripts/$(SB_TARGET_DIR)
	cp $(TARGET) ../scripts/$(SB_TARGET_DIR)/$(TARGET)
endif
