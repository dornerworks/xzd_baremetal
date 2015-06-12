DEF_ASFLAGS += -march=armv8-a
ARCH_CFLAGS  := -march=armv8-a -mcpu=generic -mgeneral-regs-only -fms-extensions -D__aarch64__


TARGET_ARCH_FAM := arm

TARGET_ARCH_DIR := arm64

DEF_CPPFLAGS += -isystem $(TOPLEVEL_DIR)/include