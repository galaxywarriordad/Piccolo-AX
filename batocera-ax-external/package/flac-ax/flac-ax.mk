################################################################################
#
# flac-ax
#
################################################################################

FLAC_AX_VERSION = main
FLAC_AX_SITE = https://github.com/galaxywarriordad/FLAC_AX.git
FLAC_AX_SITE_METHOD = git
FLAC_AX_LICENSE = MIT
FLAC_AX_LICENSE_FILES = LICENSE
FLAC_AX_SUPPORTS_IN_SOURCE_BUILD = NO

FLAC_AX_DEPENDENCIES = \
	host-pkgconf \
	ax-sdk \
	flac \
	alsa-lib

ifeq ($(BR2_PACKAGE_SDL2),y)
FLAC_AX_DEPENDENCIES += sdl2
FLAC_AX_CONF_OPTS += -DFLAC_AX_BUILD_AV_STUDIO=ON
else
FLAC_AX_CONF_OPTS += -DFLAC_AX_BUILD_AV_STUDIO=OFF
endif

FLAC_AX_CONF_OPTS += \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) -march=skylake -O3" \
	-DFLAC_AX_USE_AX_SDK=ON \
	-DFETCHCONTENT_SOURCE_DIR_AX_SDK=$(STAGING_DIR)/usr/src/ax-sdk \
	-DFLAC_AX_BUILD_VIDEO_UPSCALER=ON \
	-DFLAC_AX_ENABLE_LTO=ON

define FLAC_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@@D)/flac_ax $(TARGET_DIR)/usr/bin/flac_ax
	if [ -f $(@@D)/ax_av_studio ]; then \
		$(INSTALL) -D -m 0755 $(@@D)/ax_av_studio $(TARGET_DIR)/usr/bin/ax_av_studio; \
	fi
	if [ -f $(@@D)/ax_video_upscaler ]; then \
		$(INSTALL) -D -m 0755 $(@@D)/ax_video_upscaler $(TARGET_DIR)/usr/bin/ax_video_upscaler; \
	fi
endef

$(eval $(cmake-package))
