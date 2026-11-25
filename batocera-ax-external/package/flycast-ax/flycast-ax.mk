################################################################################
#
# flycast-ax
#
################################################################################

FLYCAST_AX_VERSION = main
_AX_PROTO = https
_AX_HOST = github.com
FLYCAST_AX_SITE = $(_AX_PROTO)://$(_AX_HOST)/galaxywarriordad/Generation-X-AX.git
FLYCAST_AX_SITE_METHOD = git
FLYCAST_AX_LICENSE = GPL-2.0
FLYCAST_AX_LICENSE_FILES = engines/flycast/LICENSE
FLYCAST_AX_SUPPORTS_IN_SOURCE_BUILD = NO

FLYCAST_AX_DEPENDENCIES = \
	host-pkgconf \
	ax-sdk \
	sdl2 \
	alsa-lib \
	libcurl \
	vulkan-headers \
	vulkan-loader \
	libzip \
	zlib

FLYCAST_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

FLYCAST_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(FLYCAST_AX_AX_FLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(FLYCAST_AX_AX_FLAGS)" \
	-DCMAKE_EXE_LINKER_FLAGS="$(TARGET_LDFLAGS) -flto=thin -Wl,--build-id=sha1" \
	-DAX_FETCH_SDK=OFF \
	-DAX_SDK_DIR=$(STAGING_DIR)/usr \
	-DAX_BUILD_RMG=OFF \
	-DAX_BUILD_BLASTEM=OFF \
	-DAX_BUILD_CANNONBALL=OFF \
	-DAX_BUILD_EDUKE32=OFF \
	-DAX_BUILD_FRONTIER=OFF \
	-DAX_BUILD_HATARI=OFF \
	-DAX_BUILD_FLYCAST=ON \
	-DUSE_VULKAN=ON \
	-DUSE_ALSA=ON \
	-DUSE_OPENMP=OFF \
	-DUSE_PULSEAUDIO=OFF \
	-DUSE_LIBAO=OFF \
	-DUSE_DISCORD=OFF \
	-DUSE_BREAKPAD=OFF \
	-DUSE_HOST_SDL=ON \
	-DENABLE_CTEST=OFF

define FLYCAST_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

define FLYCAST_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/engines/flycast/flycast $(TARGET_DIR)/usr/bin/flycast
endef

$(eval $(cmake-package))
