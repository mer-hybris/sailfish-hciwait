# -*- Mode: makefile-gmake -*-

.PHONY: all release

#
# Required packages
#

PKGS = glib-2.0 gio-2.0 gio-unix-2.0 dbus-1 bluez-libs-devel
LIB_PKGS = $(PKGS)
#
# Default target
#

all: release

#
# Sources
#

SRC = \
 sailfish-hciwait.c

#
# Directories
#

SRC_DIR = src
BUILD_DIR = build
SPEC_DIR = .
RELEASE_BUILD_DIR = $(BUILD_DIR)/release

#
# Tools and flags
#

CC = $(CROSS_COMPILE)gcc
LD = $(CC)
WARNINGS = -Wall -Wno-unused-parameter
BASE_FLAGS = -fPIC $(CFLAGS)
FULL_CFLAGS = $(BASE_FLAGS) $(DEFINES) $(WARNINGS) $(INCLUDES) -MMD -MP \
  $(shell pkg-config --cflags $(PKGS))
LDFLAGS = $(BASE_FLAGS)
RELEASE_FLAGS = -g

RELEASE_CFLAGS = $(FULL_CFLAGS) $(RELEASE_FLAGS) -O2
RELEASE_LDFLAGS = $(LDFLAGS) $(RELEASE_FLAGS)

LIBS = $(shell pkg-config --libs $(LIB_PKGS))
RELEASE_LIBS = $(LIBS)

#
# Files
#
RELEASE_OBJS = \
  $(GEN_SRC:%.c=$(RELEASE_BUILD_DIR)/%.o) \
  $(SRC:%.c=$(RELEASE_BUILD_DIR)/%.o)

#
# Dependencies
#
ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(DEPS)),)
-include $(DEPS)
endif
endif

$(RELEASE_OBJS): | $(RELEASE_BUILD_DIR)

#
# Rules
#
EXE = sailfish-hciwait
RELEASE_EXE = $(RELEASE_BUILD_DIR)/$(EXE)

release: $(RELEASE_EXE)

clean:
	rm -fr $(BUILD_DIR) $(SRC_DIR)/*~

$(RELEASE_BUILD_DIR):
	mkdir -p $@

$(RELEASE_BUILD_DIR)/%.o : $(SRC_DIR)/%.c
	$(CC) -c $(RELEASE_CFLAGS) -MT"$@" -MF"$(@:%.o=%.d)" $< -o $@

$(RELEASE_EXE): $(RELEASE_EXE_DEPS) $(RELEASE_OBJS)
	$(LD) $(RELEASE_LDFLAGS) $(RELEASE_OBJS) $(RELEASE_LIBS) -o $@

#
# Install
#
install : $(RELEASE_EXE)
	mkdir -p $(DESTDIR)/usr/sbin
	mkdir -p $(DESTDIR)/usr/lib/systemd/system
	cp $(RELEASE_EXE) $(DESTDIR)/usr/sbin/
	cp $(SRC_DIR)/sailfish-hciwait.service $(DESTDIR)/usr/lib/systemd/system/
