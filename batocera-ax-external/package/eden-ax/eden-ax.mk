################################################################################
#
# eden-ax
#
################################################################################

EDEN_AX_VERSION = master
EDEN_AX_SITE = https://github.com
EDEN_AX_SITE_METHOD = git
EDEN_AX_LICENSE = GPL-3.0-or-later
EDEN_AX_LICENSE_FILES = LICENSE.txt
EDEN_AX_DEPENDENCIES = ax-sdk alsa-lib vulkan-loader libva zstd sdl2

EDEN_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DENABLE_QT=OFF \
	-DENABLE_SDL2=ON \
	-DUSE_DISCORD_PRESENCE=OFF \
	-DENABLE_WEB_SERVICE=OFF \
	-DCMAKE_CXX_FLAGS="-march=skylake -mavx2 -mfma -mbmi -mbmi2 -O3 -flto=thin"

$(eval $(cmake-package))
