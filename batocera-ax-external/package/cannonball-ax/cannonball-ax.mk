################################################################################
#
# cannonball-ax
#
################################################################################

CANNONBALL_AX_VERSION = main
_AX_PROTO = https
_AX_HOST = github.com
CANNONBALL_AX_SITE = $(_AX_PROTO)://$(_AX_HOST)/galaxywarriordad/Generation-X-AX.git
CANNONBALL_AX_SITE_METHOD = git
CANNONBALL_AX_SUBDIR = engines/cannonball/cmake
CANNONBALL_AX_LICENSE = GPL-3.0
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
