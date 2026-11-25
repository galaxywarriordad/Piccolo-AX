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

FRONTIER_AX_EXT_DIR := $(if $(BR2_EXTERNAL_PICCOLO_AX_PATH),$(BR2_EXTERNAL_PICCOLO_AX_PATH),$(TOPDIR)/../batocera-ax-external)
FRONTIER_AX_PKGDIR := $(FRONTIER_AX_EXT_DIR)/package/frontier-ax

FRONTIER_AX_DEPENDENCIES = \
	ax-sdk \
	sdl2 \
	libglu

FRONTIER_AX_BRIDGE_OBJ = $(@D)/ax_frontier_bridge.o
FRONTIER_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

define FRONTIER_AX_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -j4 -C $(@D)/as68k CC="$(HOSTCC)" CXX="$(HOSTCXX)"
	$(TARGET_CXX) $(TARGET_CXXFLAGS) -std=c++20 $(FRONTIER_AX_AX_FLAGS) \
		-I$(FRONTIER_AX_PKGDIR) \
		-I$(STAGING_DIR)/usr/include \
		-c $(FRONTIER_AX_PKGDIR)/ax_frontier_bridge.cpp \
		-o $(FRONTIER_AX_BRIDGE_OBJ)
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D) -f Makefile-C \
		CC="$(TARGET_CC)" \
		CXX="$(TARGET_CXX)" \
		COMPILER="$(notdir $(TARGET_CC))" \
		SDL_CFLAGS="$$($(STAGING_DIR)/usr/bin/sdl2-config --cflags 2>/dev/null || true)" \
		SDL_LIBS="$$($(STAGING_DIR)/usr/bin/sdl2-config --libs 2>/dev/null || echo '-lSDL2')" \
		CFLAGS="$(TARGET_CFLAGS) -I$(FRONTIER_AX_PKGDIR) -I$(STAGING_DIR)/usr/include $(FRONTIER_AX_AX_FLAGS) -Wno-unused -DOGG_MUSIC -DWITH_GL" \
		LIBS="$(FRONTIER_AX_BRIDGE_OBJ) -L$(STAGING_DIR)/usr/lib -lax_core -lstdc++ -lpthread -lGL -lGLU -lvorbisfile -lvorbis -logg -lini -lSDL2_image $$($(STAGING_DIR)/usr/bin/sdl2-config --libs 2>/dev/null || echo '-lSDL2') -lm -Wl,--build-id=sha1"
endef

define FRONTIER_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/frontier $(TARGET_DIR)/usr/bin/frontier-fe2
endef

$(eval $(generic-package))
