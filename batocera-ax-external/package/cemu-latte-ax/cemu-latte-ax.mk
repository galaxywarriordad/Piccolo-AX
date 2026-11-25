################################################################################
#
# cemu-latte-ax
#
################################################################################

CEMU_LATTE_AX_VERSION = main
CEMU_LATTE_AX_SITE = https://github.com/galaxywarriordad/Cemu-Latte-AX.git
CEMU_LATTE_AX_SITE_METHOD = git
CEMU_LATTE_AX_GIT_SUBMODULES = YES
CEMU_LATTE_AX_LICENSE = MPL-2.0
CEMU_LATTE_AX_LICENSE_FILES = LICENSE.txt

CEMU_LATTE_AX_DEPENDENCIES = \
	ax-sdk \
	boost \
	curl \
	fmt \
	glm \
	libpng \
	libzip \
	openssl \
	pugixml \
	sdl3 \
	vulkan-headers \
	vulkan-loader \
	wxwidgets \
	zlib \
	zstd

CEMU_LATTE_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

CEMU_LATTE_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DENABLE_VCPKG=OFF \
	-DALLOW_PORTABLE=OFF \
	-DENABLE_AX_SDK=ON \
	-DAX_SDK_DIR=$(STAGING_DIR)/usr \
	-DENABLE_WAYLAND=OFF \
	-DENABLE_DISCORD_RPC=OFF \
	-DENABLE_CUBEB=ON \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(CEMU_LATTE_AX_AX_FLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(CEMU_LATTE_AX_AX_FLAGS)" \
	-DCMAKE_EXE_LINKER_FLAGS="$(TARGET_LDFLAGS) -flto=thin -Wl,--build-id=sha1"

define CEMU_LATTE_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

$(eval $(cmake-package))
