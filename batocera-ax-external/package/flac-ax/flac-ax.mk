################################################################################
#
# flac-ax
#
################################################################################

FLAC_AX_VERSION = main
_AX_PROTO = https
_AX_HOST = github.com
FLAC_AX_SITE = $(_AX_PROTO)://$(_AX_HOST)/galaxywarriordad/FLAC_AX.git
FLAC_AX_SITE_METHOD = git
FLAC_AX_LICENSE = MIT
FLAC_AX_LICENSE_FILES = LICENSE
FLAC_AX_SUPPORTS_IN_SOURCE_BUILD = NO

FLAC_AX_DEPENDENCIES = \
	host-pkgconf \
	ax-sdk \
	flac \
	alsa-lib \
	sdl2 \
	libglvnd

FLAC_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) -march=skylake -O3" \
	-DFETCHCONTENT_SOURCE_DIR_AX_SDK=$(STAGING_DIR)/usr/src/ax-sdk \
	-DFLAC_AX_USE_AX_SDK=ON \
	-DFLAC_AX_BUILD_AV_STUDIO=ON \
	-DFLAC_AX_ENABLE_LTO=ON

define FLAC_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/flac_ax $(TARGET_DIR)/usr/bin/flac_ax
	$(INSTALL) -D -m 0755 $(@D)/ax_av_studio $(TARGET_DIR)/usr/bin/ax_av_studio
endef

$(eval $(cmake-package))
