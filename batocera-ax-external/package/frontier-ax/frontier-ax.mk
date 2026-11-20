################################################################################
#
# frontier-ax
#
################################################################################

FRONTIER_AX_VERSION = master
FRONTIER_AX_SITE = https://github.com/pcercuei/glfrontier.git
FRONTIER_AX_SITE_METHOD = git
FRONTIER_AX_LICENSE = Reverse-Engineered / Non-Commercial
FRONTIER_AX_LICENSE_FILES = README.md

FRONTIER_AX_DEPENDENCIES = \
	ax-sdk \
	sdl2 \
	sdl2_image \
	libgl \
	libglu \
	libogg \
	libvorbis \
	iniparser

define FRONTIER_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) -f Makefile-C \
		CC="$(TARGET_CC)" \
		CXX="$(TARGET_CXX)" \
		COMPILER="$(notdir $(TARGET_CC))" \
		SDL_CFLAGS="$$($(STAGING_DIR)/usr/bin/sdl2-config --cflags)" \
		SDL_LIBS="$$($(STAGING_DIR)/usr/bin/sdl2-config --libs)" \
		CFLAGS="$(TARGET_CFLAGS) -march=skylake -O3 -Wno-unused -DOGG_MUSIC -DWITH_GL" \
		LIBS="-lGL -lGLU -lvorbisfile -lvorbis -logg -liniparser -lSDL2_image $$($(STAGING_DIR)/usr/bin/sdl2-config --libs) -lm"
endef

define FRONTIER_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/frontier $(TARGET_DIR)/usr/bin/frontier-fe2
endef

$(eval $(generic-package))
