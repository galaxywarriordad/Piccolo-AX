################################################################################
#
# frontier-ax
#
################################################################################

FRONTIER_AX_VERSION = master
FRONTIER_AX_SITE = https://github.com/watsonmw/fe2-intro.git
FRONTIER_AX_SITE_METHOD = git
FRONTIER_AX_LICENSE = Reverse-Engineered / Non-Commercial
FRONTIER_AX_LICENSE_FILES = README.md

FRONTIER_AX_DEPENDENCIES = \
	ax-sdk \
	sdl2 \
	libgl \
	libglu

define FRONTIER_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		CC="$(TARGET_CC)" \
		CXX="$(TARGET_CXX)" \
		CFLAGS="$(TARGET_CFLAGS) -march=skylake -O3" \
		LDFLAGS="$(TARGET_LDFLAGS) -lSDL2 -lGL -lGLU -lm"
endef

define FRONTIER_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/fe2 $(TARGET_DIR)/usr/bin/frontier-fe2
endef

$(eval $(generic-package))
