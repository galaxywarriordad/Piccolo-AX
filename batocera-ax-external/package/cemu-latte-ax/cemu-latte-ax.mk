################################################################################
#
# cemu-latte-ax
#
################################################################################

CEMU_LATTE_AX_VERSION = main
CEMU_LATTE_AX_SITE = https://github.com
CEMU_LATTE_AX_SITE_METHOD = git
CEMU_LATTE_AX_LICENSE = MPL-2.0
CEMU_LATTE_AX_LICENSE_FILES = LICENSE.txt
CEMU_LATTE_AX_DEPENDENCIES = ax-sdk alsa-lib vulkan-loader libva zstd sdl2

CEMU_LATTE_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DENABLE_WXWIDGETS=OFF \
	-DENABLE_DISCORD_RPC=OFF \
	-DCMAKE_CXX_FLAGS="-march=skylake -mavx2 -mfma -mbmi -mbmi2 -O3 -flto=thin"

$(eval $(cmake-package))
