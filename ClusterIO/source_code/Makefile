# This Makefile is provided as an example of how to build a process that can
# communicate with a Storyboard application.  It may require modifications in
# order to build on your host system.  Please see ReadMe.html for a complete
# explanation

SB_ROOT=<path to runtime>
SB_INC=-I$(SB_ROOT)/include
SB_LIB=-L$(SB_ROOT)/lib -lgreio

# Linux users add this 
#CFLAGS+= -DGRE_TARGET_OS_linux
#SB_LIB+=-lpthread -ldl

all: cluster_update

cluster_update: cluster_update.c
	$(CC) $(CFLAGS) $(SB_INC) -o $@ $^ $(SB_LIB)
