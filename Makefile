# Common Makefile for xzd_baremetal.
#

OBJ_DIR=$(CURDIR)
TOPLEVEL_DIR=$(CURDIR)

include Config.mk

include $(TOPLEVEL_DIR)/config/Bare.mk


DEF_CFLAGS += $(flags-y)

# Symlinks and headers that must be created before building the C files
GENERATED_HEADERS := $(ARCH_LINKS) include

EXTRA_DEPS += $(GENERATED_HEADERS)

# Include common mini-os makerules.
include bare.mk

# Set tester flags
# CFLAGS += -DBLKTEST_WRITE

# Define some default flags for linking.
LDLIBS := 
APP_LDLIBS := 
LDARCHLIB := -L$(OBJ_DIR)/$(TARGET_ARCH_DIR) -l$(ARCH_LIB_NAME)
LDFLAGS_FINAL := -T $(TARGET_ARCH_DIR)/xzd_bare.lds

# Prefix for global API names. All other symbols are localised before
# linking with EXTRA_OBJS.
GLOBAL_PREFIX := xenos_
EXTRA_OBJS =

TARGET := xzd_bare

# Subdirectories common to mini-os
SUBDIRS := lib xenbus console libfdt
FDT_SRC :=

# Need libgcc.a for division helpers
# LDLIBS += `$(CC) -print-libgcc-file-name`


# src-y += main.c


# The common mini-os objects to build.
APP_OBJS :=
OBJS := $(patsubst %.c,$(OBJ_DIR)/%.o,$(src-y))

.PHONY: default
default: $(OBJ_DIR)/$(TARGET)

# Create special architecture specific links. The function arch_links
# has to be defined in arch.mk (see include above).
ifneq ($(ARCH_LINKS),)
$(ARCH_LINKS):
	$(arch_links)
endif

include/list.h: include/minios-external/bsd-sys-queue-h-seddery include/minios-external/bsd-sys-queue.h
	perl $^ --prefix=minios  >$@.new
	$(call move-if-changed,$@.new,$@)

# Used by stubdom's Makefile
.PHONY: links
links: $(GENERATED_HEADERS)

include/xen:
	ln -sf ../../../xen/include/public $@

include/mini-os:
	ln -sf . $@

include/$(TARGET_ARCH_FAM)/mini-os:
	ln -sf . $@

.PHONY: arch_lib
arch_lib:
	$(MAKE) --directory=$(TARGET_ARCH_DIR) OBJ_DIR=$(OBJ_DIR)/$(TARGET_ARCH_DIR) || exit 1;

ifeq ($(CONFIG_LWIP),y)
# lwIP library
LWC	:= $(sort $(shell find $(LWIPDIR)/src -type f -name '*.c'))
LWC	:= $(filter-out %6.c %ip6_addr.c %ethernetif.c, $(LWC))
LWO	:= $(patsubst %.c,%.o,$(LWC))
LWO	+= $(OBJ_DIR)/lwip-arch.o
ifeq ($(CONFIG_NETFRONT),y)
LWO += $(OBJ_DIR)/lwip-net.o
endif

$(OBJ_DIR)/lwip.a: $(LWO)
	$(RM) $@
	$(AR) cqs $@ $^

OBJS += $(OBJ_DIR)/lwip.a
endif

OBJS := $(filter-out $(OBJ_DIR)/lwip%.o $(LWO), $(OBJS))

ifneq ($(APP_OBJS)-$(lwip),-y)
OBJS := $(filter-out $(OBJ_DIR)/daytime.o, $(OBJS))
endif

$(OBJ_DIR)/$(TARGET)_app.o: $(APP_OBJS) app.lds
	$(LD) -r -d $(LDFLAGS) -\( $^ -\) $(APP_LDLIBS) --undefined main -o $@

ifneq ($(APP_OBJS),)
APP_O=$(OBJ_DIR)/$(TARGET)_app.o 
endif

$(OBJ_DIR)/$(TARGET): $(OBJS) $(APP_O) arch_lib
	$(LD) -r $(LDFLAGS) $(HEAD_OBJ) $(APP_O) $(OBJS) $(LDARCHLIB) $(LDLIBS) -o $@.o
	$(OBJCOPY) -w -G $(GLOBAL_PREFIX)* -G _start $@.o $@.o
	$(LD) $(LDFLAGS) $(LDFLAGS_FINAL) $@.o $(EXTRA_OBJS) -o $@
ifeq ($(TARGET_ARCH_FAM),arm)
	$(OBJCOPY) -O binary $@ $@.img
else
	gzip -f -9 -c $@ >$@.gz
endif

.PHONY: clean arch_clean

arch_clean:
	$(MAKE) --directory=$(TARGET_ARCH_DIR) OBJ_DIR=$(OBJ_DIR)/$(TARGET_ARCH_DIR) clean || exit 1;

clean:	arch_clean
	for dir in $(addprefix $(OBJ_DIR)/,$(SUBDIRS)); do \
		rm -f $$dir/*.o; \
	done
	rm -f include/list.h
	rm -f ${FDT_SRC} libfdt/libfdt_internal.h
	rm -f $(OBJ_DIR)/*.o *~ $(OBJ_DIR)/core $(OBJ_DIR)/$(TARGET).elf $(OBJ_DIR)/$(TARGET).raw $(OBJ_DIR)/$(TARGET) $(OBJ_DIR)/$(TARGET).gz
	find . $(OBJ_DIR) -type l | xargs rm -f
	$(RM) $(OBJ_DIR)/lwip.a $(LWO)
	rm -f tags TAGS


define all_sources
     ( find . -follow -name SCCS -prune -o -name '*.[chS]' -print )
endef

.PHONY: cscope
cscope:
	$(all_sources) > cscope.files
	cscope -k -b -q
    
.PHONY: tags
tags:
	$(all_sources) | xargs ctags

.PHONY: TAGS
TAGS:
	$(all_sources) | xargs etags
