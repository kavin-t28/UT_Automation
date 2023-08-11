# ensure that no built-in rules are defined
$(if $(findstring r, $(MAKEFLAGS)), , $(error ABORTING: use option --no-builtin-rules))
# ensure that no built-in variables are defined
$(if $(findstring R, $(MAKEFLAGS)), , $(error ABORTING: use option --no-builtin-variables))

################################################################################
## CONFIGURATION
################################################################################
BUILD_DIR     = build
GENERATED_DIR = $(BUILD_DIR)/generated
COMMON_DIR    = .
MAKE_DIR      = $(COMMON_DIR)/src/mk
SUBCOMMON_DIR = $(COMMON_DIR)/sub/subcommon
SUBMAKE_DIR   = $(SUBCOMMON_DIR)/mk
SCIOPTA_DIR   = $(SUBCOMMON_DIR)/sub/sciopta
SEA2_DIR      = $(COMMON_DIR)/sub/sea2

TARGET   = $(BUILD_DIR)/common.elf
LD_FILE  = $(BUILD_DIR)/tmp.dld
MAP_FILE = $(BUILD_DIR)/kernel.map

CC = dcc
LD = dcc
AS = dcc
DDUMP = ddump
GITBASH = "C:\Program Files\Git\bin\bash.exe"
SCONFEXE = $(SCIOPTA_DIR)/bin/win32/sconf.exe

BUILDTYPE = beta

include $(MAKE_DIR)/colours.mk

################################################################################
## SOURCES
################################################################################
include $(MAKE_DIR)/sources.mk
SCIOPTA_SRCS += $(GENERATED_DIR)/sconf.c
INC_DIRS     += $(GENERATED_DIR)
LD_SCRIPT    = src/cfg/ktmpc5744dbug.dld
SCONF_XML    = src/cfg/sconf_project.xml
BUILDTYPE_SH = src/mk/buildtype.sh
GITSTATUS_SH = src/mk/gitstatus.sh
LINKINFO_SH  = src/mk/linkinfo.sh
BUILDTYPE_SRC_C    = build/generated/Cfg/BuildType.c
GITSTATUS_SRC_C    = build/generated/Cfg/Git.c
LINKINFO_SRC_C     = build/generated/LinkInfo.c
LINKDATETIME_SRC_C = src/common/LinkDateTime.c
INCLUDE_PATHS_INC  = $(BUILD_DIR)/include_paths.inc


################################################################################
## VARIABLES
################################################################################
HWC_SRCS_C  = $(filter %.c, $(HWC_SRCS))
HWC_SRCS_AS = $(filter %.S, $(HWC_SRCS))
SCIOPTA_SRCS_C  = $(filter %.c, $(SCIOPTA_SRCS))
SCIOPTA_SRCS_AS = $(filter %.S, $(SCIOPTA_SRCS))
HWC_NO_STACK_SRCS_C  = $(filter %.c, $(HWC_NO_STACK_SRCS))
HWC_NO_STACK_SRCS_AS = $(filter %.S, $(HWC_NO_STACK_SRCS))
SCIOPTA_NO_STACK_SRCS_C  = $(filter %.c, $(SCIOPTA_NO_STACK_SRCS))
SCIOPTA_NO_STACK_SRCS_AS = $(filter %.S, $(SCIOPTA_NO_STACK_SRCS))
MODEL_SRCS_C  = $(filter %.c, $(MODEL_SRCS))
MODEL_SRCS_AS = $(filter %.S, $(MODEL_SRCS))
SRCS_C      = $(HWC_SRCS_C)  $(SCIOPTA_SRCS_C)  $(HWC_NO_STACK_SRCS_C)  $(SCIOPTA_NO_STACK_SRCS_C)  $(MODEL_SRCS_C)
SRCS_AS     = $(HWC_SRCS_AS) $(SCIOPTA_SRCS_AS) $(HWC_NO_STACK_SRCS_AS) $(SCIOPTA_NO_STACK_SRCS_AS) $(MODEL_SRCS_AS)

HWC_OBJS_C  = $(addprefix $(BUILD_DIR)/,$(HWC_SRCS_C:.c=.o))
HWC_OBJS_AS = $(addprefix $(BUILD_DIR)/,$(HWC_SRCS_AS:.S=.o))
SCIOPTA_OBJS_C  = $(addprefix $(BUILD_DIR)/,$(SCIOPTA_SRCS_C:.c=.o))
SCIOPTA_OBJS_AS = $(addprefix $(BUILD_DIR)/,$(SCIOPTA_SRCS_AS:.S=.o))
HWC_NO_STACK_OBJS_C  = $(addprefix $(BUILD_DIR)/,$(HWC_NO_STACK_SRCS_C:.c=.o))
HWC_NO_STACK_OBJS_AS = $(addprefix $(BUILD_DIR)/,$(HWC_NO_STACK_SRCS_AS:.S=.o))
SCIOPTA_NO_STACK_OBJS_C  = $(addprefix $(BUILD_DIR)/,$(SCIOPTA_NO_STACK_SRCS_C:.c=.o))
SCIOPTA_NO_STACK_OBJS_AS = $(addprefix $(BUILD_DIR)/,$(SCIOPTA_NO_STACK_SRCS_AS:.S=.o))
MODEL_OBJS_C  = $(addprefix $(BUILD_DIR)/,$(MODEL_SRCS_C:.c=.o))
MODEL_OBJS_AS = $(addprefix $(BUILD_DIR)/,$(MODEL_SRCS_AS:.S=.o))

BUILDTYPE_OBJ_C = $(addprefix $(BUILD_DIR)/,$(BUILDTYPE_SRC_C:.c=.o))
GITSTATUS_OBJ_C = $(addprefix $(BUILD_DIR)/,$(GITSTATUS_SRC_C:.c=.o))
LINKINFO_OBJ_C = $(addprefix $(BUILD_DIR)/,$(LINKINFO_SRC_C:.c=.o))
LINKDATETIME_OBJ_C = $(addprefix $(BUILD_DIR)/,$(LINKDATETIME_SRC_C:.c=.o))

HWC_OBJS = $(HWC_OBJS_C) $(HWC_OBJS_AS)
SCIOPTA_OBJS = $(SCIOPTA_OBJS_C) $(SCIOPTA_OBJS_AS)
HWC_NO_STACK_OBJS = $(HWC_NO_STACK_OBJS_C) $(HWC_NO_STACK_OBJS_AS)
SCIOPTA_NO_STACK_OBJS = $(SCIOPTA_NO_STACK_OBJS_C) $(SCIOPTA_NO_STACK_OBJS_AS)
MODEL_OBJS = $(MODEL_OBJS_C) $(MODEL_OBJS_AS)

OBJS = $(MODEL_OBJS) $(SCIOPTA_OBJS) $(HWC_OBJS) $(SCIOPTA_NO_STACK_OBJS) $(HWC_NO_STACK_OBJS)
DEPS = $(patsubst %.o,%.d,$(OBJS))


################################################################################
## FLAGS
################################################################################
TARGET_FLAG = -tPPCE200Z4251N3VFS:simple

CPPFLAGS =
CPPFLAGS += -@$(INCLUDE_PATHS_INC)
CPPFLAGS += -DTOOL_FAMILY=diab
CPPFLAGS += -DTOOL=diab

CFLAGS  =
CFLAGS  += $(TARGET_FLAG)
CFLAGS  += -g
CFLAGS  += -Xdebug-dwarf3
CFLAGS  += -stop-on-warning
CFLAGS  += -Xc-new
CFLAGS  += -Ws
CFLAGS  += -Xdialect-c99
CFLAGS  += -ef5844 # failure 5844: function XXX has no prototype
CFLAGS  += -ef4940
CFLAGS  += -ef4223
CFLAGS  += -ef4188
CFLAGS  += -ef4167 # failure 4167: argument of type "XXX" is incompatible with parameter of type "YYY"
CFLAGS  += -Xforce-prototypes
CFLAGS  += -Xkill-reorder=0x100000   # TCDIAB-13012

ASFLAGS =
ASFLAGS += $(TARGET_FLAG)
ASFLAGS += -Wa,-Xasm-debug-on
ASFLAGS += -Xpreprocess-assembly
ASFLAGS += -Wa,-Xsemi-is-newline
ASFLAGS += -Wa,-Xno-optim
ASFLAGS += -Wa,-Xstrip-locals
ASFLAGS += -Wa,-Xdebug-dwarf2

LDFLAGS =
LDFLAGS += $(TARGET_FLAG)
LDFLAGS += -Ws -Wmtmp.dld -Wl,-m2
LDFLAGS += -Wl,-Xremove-unused-sections

    HWC_CFLAGS  =
    HWC_CFLAGS  += -Xlint
    HWC_CFLAGS  += -ei5386 # ignore 5386: implicit conversion of a 64-bit integral type to a smaller integral type (potential portability problem)
    HWC_CFLAGS  += -ei5387 # ignore 5387: explicit conversion of a 64-bit integral type to a smaller integral type (potential portability problem)
SCIOPTA_CFLAGS  =
SCIOPTA_CFLAGS  += -ei1824 # ignore 1824: explicit cast from 'ptr-to-volatie struct' to 'void' discards volatile qualifier
  MODEL_CFLAGS  =
  MODEL_CFLAGS  += -ei5386 # ignore 5386: implicit conversion of a 64-bit integral type to a smaller integral type (potential portability problem)
  MODEL_CFLAGS  += -ei5387 # ignore 5387: explicit conversion of a 64-bit integral type to a smaller integral type (potential portability problem)
  MODEL_CFLAGS  += -ei4188 # ignore 4188: enumerated type mixed with another type

    HWC_ASFLAGS =
SCIOPTA_ASFLAGS =
  MODEL_ASFLAGS =

   STACK_CFLAGS = -Xstack-probe

LINKER_FILE_FLAGS =
ifeq ($(DONTFILLROM),1)
	LINKER_FILE_FLAGS += -DLINKER_DONT_FILL_ROM
endif

################################################################################
## VERBOSITY
################################################################################
ifneq ($(V),1)
	Q = @
else
	Q =
endif


################################################################################
## FUNCTIONS
################################################################################
include $(MAKE_DIR)/functions.mk


################################################################################
## CHECK CONFIG
################################################################################
$(if $(BUILD_DIR),,$(error BUILD_DIR is empty!))
$(if $(GENERATED_DIR),,$(error GENERATED_DIR is empty!))
$(if $(MAKE_DIR),,$(error GENERATED_DIR is empty!))


################################################################################
## CHECK SOURCES
################################################################################
$(call check_duplicate,$(SRCS_C),duplicate C file)
$(call check_duplicate,$(SRCS_AS),duplicate AS file)
$(call check_duplicate,$(basename $(SRCS_C) $(SRCS_AS)),duplicate AS and C file)


################################################################################
## DEFAULT RULE
################################################################################
.PHONY : all
all : $(GENERATED_DIR)/sconf.h $(TARGET)


################################################################################
## DEPENDENCIES
################################################################################
-include $(DEPS)


################################################################################
## RULES
################################################################################

# ------------------------------------------------------------------------------
# target
# ------------------------------------------------------------------------------
$(TARGET) : $(OBJS) $(LD_FILE) | $(INCLUDE_PATHS_INC)
	$(call create_buildtype,$(BUILDTYPE_SRC_C),$(BUILDTYPE_SH), $(BUILDTYPE))
	$(call create_gitstatus,$(GITSTATUS_SRC_C),$(GITSTATUS_SH))
	$(call create_linkinfo,$(LINKINFO_SRC_C),$(LINKINFO_SH))
	$(call compile_c,$(BUILDTYPE_OBJ_C),$(BUILDTYPE_SRC_C),$(HWC_CFLAGS))
	$(call compile_c,$(GITSTATUS_OBJ_C),$(GITSTATUS_SRC_C),$(HWC_CFLAGS))
	$(call compile_c,$(LINKINFO_OBJ_C),$(LINKINFO_SRC_C),$(HWC_CFLAGS))
	$(call compile_c,$(LINKDATETIME_OBJ_C),$(LINKDATETIME_SRC_C),$(HWC_CFLAGS))
	$(call link_objects,$@,$(OBJS) $(LINKINFO_OBJ_C) $(BUILDTYPE_OBJ_C) $(GITSTATUS_OBJ_C) $(LINKDATETIME_OBJ_C),$(LD_FILE),$(MAP_FILE))
	$(call strip_elf,$(basename $@)_stripped.elf,$@)

$(LD_FILE) : $(LD_SCRIPT)
	$(call compile_linkerfile,$@,$(LD_SCRIPT),$(LINKER_FILE_FLAGS))

# ------------------------------------------------------------------------------
# object files
# ------------------------------------------------------------------------------
$(HWC_OBJS_C) : $(BUILD_DIR)/%.o : %.c | $(INCLUDE_PATHS_INC)
	$(call compile_c,$@,$<,$(HWC_CFLAGS) $(STACK_CFLAGS))

$(HWC_OBJS_AS) : $(BUILD_DIR)/%.o : %.S | $(INCLUDE_PATHS_INC)
	$(call compile_as,$@,$<,$(HWC_ASFLAGS))

$(SCIOPTA_OBJS_C) : $(BUILD_DIR)/%.o : %.c | $(INCLUDE_PATHS_INC)
	$(call compile_c,$@,$<,$(SCIOPTA_CFLAGS) $(STACK_CFLAGS))

$(SCIOPTA_OBJS_AS) : $(BUILD_DIR)/%.o : %.S | $(INCLUDE_PATHS_INC)
	$(call compile_as,$@,$<,$(SCIOPTA_ASFLAGS))

$(HWC_NO_STACK_OBJS_C) : $(BUILD_DIR)/%.o : %.c | $(INCLUDE_PATHS_INC)
	$(call compile_c,$@,$<,$(HWC_CFLAGS))

$(HWC_NO_STACK_OBJS_AS) : $(BUILD_DIR)/%.o : %.S | $(INCLUDE_PATHS_INC)
	$(call compile_as,$@,$<,$(HWC_ASFLAGS))

$(SCIOPTA_NO_STACK_OBJS_C) : $(BUILD_DIR)/%.o : %.c | $(INCLUDE_PATHS_INC)
	$(call compile_c,$@,$<,$(SCIOPTA_CFLAGS))

$(SCIOPTA_NO_STACK_OBJS_AS) : $(BUILD_DIR)/%.o : %.S | $(INCLUDE_PATHS_INC)
	$(call compile_as,$@,$<,$(SCIOPTA_ASFLAGS))

$(MODEL_OBJS_C) : $(BUILD_DIR)/%.o : %.c | $(INCLUDE_PATHS_INC)
	$(call compile_c,$@,$<,$(MODEL_CFLAGS))

$(MODEL_OBJS_AS) : $(BUILD_DIR)/%.o : %.S | $(INCLUDE_PATHS_INC)
	$(call compile_as,$@,$<,$(MODEL_ASFLAGS))

# ------------------------------------------------------------------------------
# pseudo objects
# ------------------------------------------------------------------------------
#  These rules allow to call 'make src/HWC.o' to generate 'build/src/HWC.o'.
# ------------------------------------------------------------------------------
$(HWC_SRCS_C:.c=.o)      : %.o : $(BUILD_DIR)/%.o
$(HWC_SRCS_AS:.S=.o)     : %.o : $(BUILD_DIR)/%.o
$(SCIOPTA_SRCS_C:.c=.o)  : %.o : $(BUILD_DIR)/%.o
$(SCIOPTA_SRCS_AS:.S=.o) : %.o : $(BUILD_DIR)/%.o
$(HWC_NO_STACK_SRCS_C:.c=.o)      : %.o : $(BUILD_DIR)/%.o
$(HWC_NO_STACK_SRCS_AS:.S=.o)     : %.o : $(BUILD_DIR)/%.o
$(SCIOPTA_NO_STACK_SRCS_C:.c=.o)  : %.o : $(BUILD_DIR)/%.o
$(SCIOPTA_NO_STACK_SRCS_AS:.S=.o) : %.o : $(BUILD_DIR)/%.o
$(MODEL_SRCS_C:.c=.o)    : %.o : $(BUILD_DIR)/%.o
$(MODEL_SRCS_AS:.S=.o)   : %.o : $(BUILD_DIR)/%.o

# ------------------------------------------------------------------------------
# special source
# ------------------------------------------------------------------------------
$(GENERATED_DIR)/sconf.c $(GENERATED_DIR)/sconf.h : $(SCONF_XML)
	$(call generate_sconf,$@,$<)

# ------------------------------------------------------------------------------
# IncludePaths
# ------------------------------------------------------------------------------
$(INCLUDE_PATHS_INC): src/mk/sources.mk
	$(call print_command,echo, ,-o, $@ ,)
	@mkdir -p $(patsubst %/,%,$(dir $@))
	@echo $(addprefix -I,$(INC_DIRS)) | sed -e 's/ /\n/g' > $@

# ------------------------------------------------------------------------------
# clean
# ------------------------------------------------------------------------------
.PHONY : clean
clean :
	$(call delete_files,$(BUILD_DIR))
