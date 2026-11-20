################################################################################
#
# rmg-ax
#
################################################################################

RMG_AX_VERSION = main
RMG_AX_SITE = https://github.com
RMG_AX_SITE_METHOD = git
RMG_AX_GIT_SUBMODULES = YES
RMG_AX_LICENSE = GPL-3.0
RMG_AX_LICENSE_FILES = LICENSE

RMG_AX_DEPENDENCIES = \
	host-pkgconf \
	host-nasm \
	qt6base \
	qt6svg \
	qt6websockets \
	sdl3 \
	libsamplerate \
	speexdsp \
	libusb \
	hidapi \
	minizip \
	freetype \
	zlib \
	vulkan-headers

RMG_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DPORTABLE_INSTALL=OFF \
	-DUSE_SYSTEM_LIBS=ON

$(eval $(cmake-package))
