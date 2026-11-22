################################################################################
#
# flac-ax
#
################################################################################

FLAC_AX_LOCAL_DIR := $(wildcard $(BR2_EXTERNAL_PICCOLO_AX_PATH)/../../FLAC_AX)
ifneq ($(FLAC_AX_LOCAL_DIR),)
FLAC_AX_SITE = $(FLAC_AX_LOCAL_DIR)
FLAC_AX_SITE_METHOD = local
else
FLAC_AX_VERSION = main
FLAC_AX_SITE = https://github.com
FLAC_AX_SITE_METHOD = git
endif

FLAC_AX_LICENSE = MIT
FLAC_AX_LICENSE_FILES = LICENSE.md
FLAC_AX_SUPPORTS_IN_SOURCE_BUILD = NO

FLAC_AX_DEPENDENCIES = \
	host-pkgconf \
	ax-sdk \
	flac \
	alsa-lib

ifeq ($(BR2_PACKAGE_SDL2)$(BR2_PACKAGE_HAS_LIBGL),yy)
FLAC_AX_DEPENDENCIES += sdl2 libgl
FLAC_AX_CONF_OPTS += \
	-DFLAC_AX_BUILD_AV_STUDIO=ON \
	-DFLAC_AX_ENABLE_SDL2_GL=ON
else ifeq ($(BR2_PACKAGE_SDL2),y)
FLAC_AX_DEPENDENCIES += sdl2
FLAC_AX_CONF_OPTS += \
	-DFLAC_AX_BUILD_AV_STUDIO=ON \
	-DFLAC_AX_ENABLE_SDL2_GL=OFF
else
FLAC_AX_CONF_OPTS += \
	-DFLAC_AX_BUILD_AV_STUDIO=OFF \
	-DFLAC_AX_ENABLE_SDL2_GL=OFF
endif

FLAC_AX_CONF_OPTS += \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) -march=skylake -O3" \
	-DFLAC_AX_USE_AX_SDK=ON \
	-DFETCHCONTENT_SOURCE_DIR_AX_SDK=$(STAGING_DIR)/usr/src/ax-sdk \
	-DFLAC_AX_BUILD_VIDEO_UPSCALER=ON \
	-DFLAC_AX_BUILD_APPLIANCE_TUI=ON \
	-DFLAC_AX_ENABLE_LTO=ON

define FLAC_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/flac_ax $(TARGET_DIR)/usr/bin/flac_ax
	for bin in ax_av_studio ax_video_upscaler ax_appliance_tui; do \
		if [ -x "$(@D)/$$bin" ]; then \
			$(INSTALL) -D -m 0755 "$(@D)/$$bin" "$(TARGET_DIR)/usr/bin/$$bin"; \
		fi; \
	done
	$(INSTALL) -D -m 0644 \
		$(BR2_EXTERNAL_PICCOLO_AX_PATH)/package/flac-ax/99-ax-usb-dacs.rules \
		$(TARGET_DIR)/etc/udev/rules.d/99-ax-usb-dacs.rules
endef

$(eval $(cmake-package))
