################################################################################
#
# cemu-latte-ax
#
################################################################################

CEMU_LATTE_AX_VERSION = main
CEMU_LATTE_AX_SITE = https://github.com
CEMU_LATTE_AX_SITE_METHOD = git
CEMU_LATTE_AX_GIT_SUBMODULES = YES
CEMU_LATTE_AX_LICENSE = MPL-2.0
CEMU_LATTE_AX_LICENSE_FILES = LICENSE.txt
CEMU_LATTE_AX_DEPENDENCIES = ax-sdk sdl2 vulkan-headers vulkan-loader boost curl zstd

CEMU_LATTE_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DENABLE_AX_SDK=ON \
	-DENABLE_VULKAN=ON \
	-DENABLE_OPENGL=OFF \
	-DENABLE_WXWIDGETS=OFF \
	-DPORTABLE=OFF \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) -march=skylake -flto=thin"

$(eval $(cmake-package))
