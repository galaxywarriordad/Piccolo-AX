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

CEMU_LATTE_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DENABLE_VCPKG=OFF \
	-DALLOW_PORTABLE=OFF \
	-DENABLE_AX_SDK=ON \
	-DENABLE_WAYLAND=OFF \
	-DENABLE_DISCORD_RPC=OFF \
	-DENABLE_CUBEB=ON

$(eval $(cmake-package))
