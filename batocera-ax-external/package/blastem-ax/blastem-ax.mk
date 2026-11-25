################################################################################
#
# blastem-ax
#
################################################################################

BLASTEM_AX_VERSION = main
_AX_PROTO = https
_AX_HOST = github.com
BLASTEM_AX_SITE = $(_AX_PROTO)://$(_AX_HOST)/galaxywarriordad/Generation-X-AX.git
BLASTEM_AX_SITE_METHOD = git
BLASTEM_AX_SUBDIR = engines/blastem
BLASTEM_AX_LICENSE = GPL-3.0
BLASTEM_AX_LICENSE_FILES = COPYING

BLASTEM_AX_DEPENDENCIES = \
	ax-sdk \
	sdl2 \
	libgl \
	libglew

BLASTEM_AX_SRC_DIR = $(if $(wildcard $(@D)/engines/blastem),$(@D)/engines/blastem,$(@D))
BLASTEM_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

define BLASTEM_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(BLASTEM_AX_SRC_DIR) \
		CC="$(TARGET_CC)" \
		CXX="$(TARGET_CXX)" \
		CFLAGS="$(TARGET_CFLAGS) $(BLASTEM_AX_AX_FLAGS) -I$(STAGING_DIR)/usr/include" \
		CXXFLAGS="$(TARGET_CXXFLAGS) $(BLASTEM_AX_AX_FLAGS) -I$(STAGING_DIR)/usr/include" \
		LDFLAGS="$(TARGET_LDFLAGS) -flto=thin -Wl,--build-id=sha1 -L$(STAGING_DIR)/usr/lib -lax_core -lSDL2 -lGL -lGLEW -lm -lpthread" \
		blastem
endef

define BLASTEM_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(BLASTEM_AX_SRC_DIR)/blastem $(TARGET_DIR)/usr/bin/blastem
	mkdir -p $(TARGET_DIR)/usr/share/blastem
	cp -r $(BLASTEM_AX_SRC_DIR)/default.cfg $(BLASTEM_AX_SRC_DIR)/rom.db $(BLASTEM_AX_SRC_DIR)/shaders $(TARGET_DIR)/usr/share/blastem/
endef

$(eval $(generic-package))
