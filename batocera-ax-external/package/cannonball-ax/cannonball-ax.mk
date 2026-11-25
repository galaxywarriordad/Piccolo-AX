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

CANNONBALL_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

CANNONBALL_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DTARGET=linux.cmake \
	-DAX_SDK_DIR=$(STAGING_DIR)/usr \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(CANNONBALL_AX_AX_FLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(CANNONBALL_AX_AX_FLAGS)" \
	-DCMAKE_EXE_LINKER_FLAGS="$(TARGET_LDFLAGS) -flto=thin -Wl,--build-id=sha1"

define CANNONBALL_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

define CANNONBALL_AX_INSTALL_TARGET_CMDS
	if [ -x "$(@D)/build/cannonball" ]; then \
		$(INSTALL) -D -m 0755 $(@D)/build/cannonball $(TARGET_DIR)/usr/bin/cannonball; \
	elif [ -x "$(@D)/cmake/cannonball" ]; then \
		$(INSTALL) -D -m 0755 $(@D)/cmake/cannonball $(TARGET_DIR)/usr/bin/cannonball; \
	else \
		$(INSTALL) -D -m 0755 $(@D)/cannonball $(TARGET_DIR)/usr/bin/cannonball; \
	fi
	mkdir -p $(TARGET_DIR)/usr/share/cannonball
	if [ -d "$(@D)/../res" ]; then \
		cp -r $(@D)/../res $(TARGET_DIR)/usr/share/cannonball/; \
	elif [ -d "$(@D)/res" ]; then \
		cp -r $(@D)/res $(TARGET_DIR)/usr/share/cannonball/; \
	fi
endef

$(eval $(cmake-package))
