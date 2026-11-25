################################################################################
#
# blastem-ax
#
################################################################################

BLASTEM_AX_VERSION = v1_36_2
BLASTEM_AX_SITE_METHOD = local
BLASTEM_AX_SITE = $(BR2_EXTERNAL_PICCOLO_AX_PATH)/../../Generation-X-AX/engines/blastem
BLASTEM_AX_LICENSE = GPL-3.0
BLASTEM_AX_LICENSE_FILES = COPYING

BLASTEM_AX_DEPENDENCIES = \
	ax-sdk \
	sdl2 \
	libgl \
	libglew

BLASTEM_AX_EXTRA_CFLAGS = -O3 -march=skylake -mbmi -mbmi2 -ffile-prefix-map=$(@D)=.
BLASTEM_AX_EXTRA_LDFLAGS = -Wl,--build-id=sha1

define BLASTEM_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(BLASTEM_AX_EXTRA_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) $(BLASTEM_AX_EXTRA_LDFLAGS) -lSDL2 -lGL -lGLEW -lm -lpthread" \
		AX_SKYLAKELOCK=1 \
		AX_DETERMINISTIC=1 \
		blastem
endef

define BLASTEM_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/blastem $(TARGET_DIR)/usr/bin/blastem
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/usr/share/blastem
	if [ -f "$(@D)/default.cfg" ]; then \
		$(INSTALL) -m 0644 "$(@D)/default.cfg" "$(TARGET_DIR)/usr/share/blastem/"; \
	fi
	if [ -f "$(@D)/rom.db" ]; then \
		$(INSTALL) -m 0644 "$(@D)/rom.db" "$(TARGET_DIR)/usr/share/blastem/"; \
	fi
	if [ -d "$(@D)/shaders" ]; then \
		cp -r "$(@D)/shaders" "$(TARGET_DIR)/usr/share/blastem/"; \
	fi
endef

$(eval $(generic-package))
