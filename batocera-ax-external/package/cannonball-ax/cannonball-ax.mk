################################################################################
#
# cannonball-ax
#
################################################################################

CANNONBALL_AX_VERSION = master
CANNONBALL_AX_SITE = https://github.com/djyt/cannonball.git
CANNONBALL_AX_SITE_METHOD = git
CANNONBALL_AX_SUBDIR = cmake
CANNONBALL_AX_LICENSE = Non-Commercial / MAME-compatible
CANNONBALL_AX_LICENSE_FILES = docs/license.txt

CANNONBALL_AX_DEPENDENCIES = \
	ax-sdk \
	boost \
	sdl2 \
	libgl

CANNONBALL_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DTARGET=linux.cmake \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) -march=skylake"

define CANNONBALL_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/cmake/cannonball $(TARGET_DIR)/usr/bin/cannonball
	mkdir -p $(TARGET_DIR)/usr/share/cannonball
	cp -r $(@D)/res $(TARGET_DIR)/usr/share/cannonball/
endef

$(eval $(cmake-package))
