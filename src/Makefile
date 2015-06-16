TOPLEVEL_DIR = $(CURDIR)/..

include ../Config.mk
include ../bare.mk

# Sources here are all *.c *.S
ARCH_SRCS := $(sort $(wildcard *.c))

# The objects built from the sources.
ARCH_OBJS := $(patsubst %.c,$(OBJ_DIR)/%.o,$(ARCH_SRCS))

ARCH_OBJS += hypercall.o

all: $(OBJ_DIR)/$(ARCH_LIB)

# $(HEAD_ARCH_OBJ) is only build here, needed on linking
# in ../../Makefile.
$(OBJ_DIR)/$(ARCH_LIB): $(ARCH_OBJS) $(OBJ_DIR)/$(HEAD_ARCH_OBJ)
	$(AR) rv $(OBJ_DIR)/$(ARCH_LIB) $(ARCH_OBJS)

clean:
	rm -f $(OBJ_DIR)/$(ARCH_LIB) $(ARCH_OBJS) $(OBJ_DIR)/$(HEAD_ARCH_OBJ)


