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

RMG_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

RMG_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DPORTABLE_INSTALL=OFF \
	-DUSE_SYSTEM_LIBS=ON \
	-DAX_FETCH_SDK=OFF \
	-DAX_SDK_DIR=$(STAGING_DIR)/usr \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(RMG_AX_AX_FLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(RMG_AX_AX_FLAGS)" \
	-DCMAKE_EXE_LINKER_FLAGS="$(TARGET_LDFLAGS) -flto=thin -Wl,--build-id=sha1"

define RMG_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

$(eval $(cmake-package))
