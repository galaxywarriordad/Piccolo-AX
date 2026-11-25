################################################################################
#
# eden-ax
#
################################################################################

EDEN_AX_VERSION = master
EDEN_AX_SITE = https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX.git
EDEN_AX_SITE_METHOD = git
EDEN_AX_GIT_SUBMODULES = YES
EDEN_AX_LICENSE = GPL-3.0-or-later
EDEN_AX_LICENSE_FILES = LICENSE.txt
EDEN_AX_DEPENDENCIES = ax-sdk sdl3 vulkan-headers vulkan-loader ffmpeg zlib zstd

EDEN_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

EDEN_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DENABLE_AX_SDK=ON \
	-DAX_SDK_DIR=$(STAGING_DIR)/usr \
	-DENABLE_QT=OFF \
	-DYUZU_USE_BUNDLED_SDL3=OFF \
	-DENABLE_WEB_SERVICE=OFF \
	-DYUZU_USE_BUNDLED_VCPKG=OFF \
	-DYUZU_TESTS=OFF \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(EDEN_AX_AX_FLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(EDEN_AX_AX_FLAGS)" \
	-DCMAKE_EXE_LINKER_FLAGS="$(TARGET_LDFLAGS) -flto=thin -Wl,--build-id=sha1"

define EDEN_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

$(eval $(cmake-package))
