################################################################################
#
# rmg-ax
#
################################################################################

RMG_AX_VERSION = main
_AX_PROTO = https
_AX_HOST = github.com
RMG_AX_SITE = $(_AX_PROTO)://$(_AX_HOST)/galaxywarriordad/Generation-X-AX.git
RMG_AX_SITE_METHOD = git
RMG_AX_SUBDIR = engines/rmg
RMG_AX_GIT_SUBMODULES = YES
RMG_AX_LICENSE = GPL-3.0
RMG_AX_LICENSE_FILES = LICENSE

RMG_AX_DEPENDENCIES = \
	ax-sdk \
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
	-DUSE_SYSTEM_LIBS=ON \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) -march=skylake"

$(eval $(cmake-package))
