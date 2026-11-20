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
FRONTIER_AX_PKGDIR = $(TOPDIR)/../batocera-ax-external/package/frontier-ax

FRONTIER_AX_DEPENDENCIES = \
	ax-sdk \
	sdl2 \
	libglu

FRONTIER_AX_BRIDGE_OBJ = $(@D)/ax_frontier_bridge.o

define FRONTIER_AX_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)/as68k CC="$(HOSTCC)" CXX="$(HOSTCXX)"
	$(TARGET_CXX) $(TARGET_CXXFLAGS) -std=c++20 -O3 \
		-I$(FRONTIER_AX_PKGDIR) \
		-I$(STAGING_DIR)/usr/include \
		-c $(FRONTIER_AX_PKGDIR)/ax_frontier_bridge.cpp \
		-o $(FRONTIER_AX_BRIDGE_OBJ)
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) -f Makefile-C \
		CC="$(TARGET_CC)" \
		CXX="$(TARGET_CXX)" \
		COMPILER="$(notdir $(TARGET_CC))" \
		SDL_CFLAGS="$$($(STAGING_DIR)/usr/bin/sdl2-config --cflags 2>/dev/null || true)" \
		SDL_LIBS="$$($(STAGING_DIR)/usr/bin/sdl2-config --libs 2>/dev/null || echo '-lSDL2')" \
		CFLAGS="$(TARGET_CFLAGS) -I$(FRONTIER_AX_PKGDIR) -I$(STAGING_DIR)/usr/include -march=skylake -O3 -Wno-unused -DOGG_MUSIC -DWITH_GL" \
		LIBS="$(FRONTIER_AX_BRIDGE_OBJ) -L$(STAGING_DIR)/usr/lib -lax_core -lpthread -lGL -lGLU -lvorbisfile -lvorbis -logg -lini -lSDL2_image $$($(STAGING_DIR)/usr/bin/sdl2-config --libs 2>/dev/null || echo '-lSDL2') -lm"
endef

define FRONTIER_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/frontier $(TARGET_DIR)/usr/bin/frontier-fe2
endef

$(eval $(generic-package))
