# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
#
# This is based on the original scripts/dtc/Makefile, but has been revised to
# work with an insane submodule situation.

hostprogs-y	:= dtc-aosp
always		:= $(hostprogs-y)

dtc-aosp-objs	:=  \
	checks.o \
	data.o \
	dtc.o \
	flattree.o \
	fstree.o \
	livetree.o \
	srcpos.o \
	treesource.o \
	util.o
dtc-aosp-objs	+= dtc-lexer.lex.o dtc-parser.tab.o

# We're working with a submodule, so make these all relative to that.
dtc-aosp-objs	:= $(addprefix dtc/,$(dtc-aosp-objs))

HOSTCFLAGS_DTC := -I$(src)/dtc -I$(src)/dtc/libfdt -I$(obj)/dtc -DNO_YAML

HOSTCFLAGS_checks.o := $(HOSTCFLAGS_DTC)
HOSTCFLAGS_data.o := $(HOSTCFLAGS_DTC)
HOSTCFLAGS_dtc.o := $(HOSTCFLAGS_DTC)
HOSTCFLAGS_flattree.o := $(HOSTCFLAGS_DTC)
HOSTCFLAGS_fstree.o := $(HOSTCFLAGS_DTC)
HOSTCFLAGS_livetree.o := $(HOSTCFLAGS_DTC)
HOSTCFLAGS_srcpos.o := $(HOSTCFLAGS_DTC)
HOSTCFLAGS_treesource.o := $(HOSTCFLAGS_DTC)
HOSTCFLAGS_util.o := $(HOSTCFLAGS_DTC)

HOSTCFLAGS_dtc-lexer.lex.o := $(HOSTCFLAGS_DTC)
HOSTCFLAGS_dtc-parser.tab.o := $(HOSTCFLAGS_DTC)

# Dependencies on generated files need to be listed explicitly.
$(obj)/dtc/dtc-lexer.lex.o: $(obj)/dtc/dtc-parser.h

# The kernel's ordinary makefile doesn't have or require flex or bison,
# and in fact, upstream chooses to just have _shipped versions of the files.
# This is gross, so we add the build rules ourselves. We also make the
# header output .h instead of .tab.h for bison, because aosp is broken.
LEX = flex
BISON = bison
ECHO = echo "	"

%.lex.c: %.l
	@$(ECHO) LEX $@
	$(LEX) -o$@ $<
%.tab.c %.h: %.y
	@$(ECHO) BISON   $@
	$(BISON) -d --output=$(@D)/$(notdir $(<:.y=.tab.c)) --defines=$(@D)/$(notdir $(<:.y=.h)) -Wno-conflicts-sr $<

# Generated files need to be cleaned explicitly.
clean-files	:= dtc/dtc-lexer.lex.c dtc/dtc-parser.tab.c dtc/dtc-parser.h
no-clean-files := dtc/
