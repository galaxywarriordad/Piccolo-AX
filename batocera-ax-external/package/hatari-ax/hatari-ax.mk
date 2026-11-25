################################################################################
#
# hatari-ax
#
################################################################################

HATARI_AX_VERSION = main
_AX_PROTO = https
_AX_HOST = github.com
HATARI_AX_SITE = $(_AX_PROTO)://$(_AX_HOST)/galaxywarriordad/Generation-X-AX.git
HATARI_AX_SITE_METHOD = git
HATARI_AX_LICENSE = GPL-2.0
HATARI_AX_LICENSE_FILES = engines/hatari/gpl.txt
HATARI_AX_SUPPORTS_IN_SOURCE_BUILD = NO

HATARI_AX_DEPENDENCIES = \
	host-pkgconf \
	ax-sdk \
	sdl2 \
	alsa-lib \
	libpng \
	zlib

HATARI_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

HATARI_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(HATARI_AX_AX_FLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(HATARI_AX_AX_FLAGS)" \
	-DCMAKE_EXE_LINKER_FLAGS="$(TARGET_LDFLAGS) -flto=thin -Wl,--build-id=sha1" \
	-DAX_FETCH_SDK=OFF \
	-DAX_SDK_DIR=$(STAGING_DIR)/usr \
	-DAX_BUILD_RMG=OFF \
	-DAX_BUILD_BLASTEM=OFF \
	-DAX_BUILD_CANNONBALL=OFF \
	-DAX_BUILD_EDUKE32=OFF \
	-DAX_BUILD_FRONTIER=OFF \
	-DAX_BUILD_FLYCAST=OFF \
	-DAX_BUILD_HATARI=ON \
	-DENABLE_HATARI=ON \
	-DENABLE_DSP_EMU=ON \
	-DENABLE_LIBRETRO=OFF \
	-DENABLE_TOOLS=OFF \
	-DENABLE_MAN_PAGES=OFF \
	-DENABLE_SDL3=OFF

define HATARI_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

define HATARI_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/engines/hatari/src/hatari $(TARGET_DIR)/usr/bin/hatari
	mkdir -p $(TARGET_DIR)/usr/share/hatari
	cp -r $(@D)/engines/hatari/share/* $(TARGET_DIR)/usr/share/hatari/ 2>/dev/null || true
endef

$(eval $(cmake-package))
