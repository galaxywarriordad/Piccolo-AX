################################################################################
#
# blastem-ax
#
################################################################################

BLASTEM_AX_VERSION = master
BLASTEM_AX_SITE = https://github.com/libretro/blastem.git
BLASTEM_AX_SITE_METHOD = git
BLASTEM_AX_LICENSE = GPL-3.0
BLASTEM_AX_LICENSE_FILES = COPYING

BLASTEM_AX_DEPENDENCIES = \
	ax-sdk \
	sdl2 \
	libgl \
	libglew

define BLASTEM_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -march=skylake -O3" \
		LDFLAGS="$(TARGET_LDFLAGS) -lSDL2 -lGL -lGLEW -lm -lpthread" \
		blastem
endef

define BLASTEM_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/blastem $(TARGET_DIR)/usr/bin/blastem
	mkdir -p $(TARGET_DIR)/usr/share/blastem
	cp -r $(@D)/default.cfg $(@D)/rom.db $(@D)/shaders $(TARGET_DIR)/usr/share/blastem/
endef

$(eval $(generic-package))
