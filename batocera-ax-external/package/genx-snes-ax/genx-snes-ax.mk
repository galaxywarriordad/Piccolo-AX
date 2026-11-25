################################################################################
#
# genx-snes-ax
#
################################################################################

GENX_SNES_AX_VERSION = v1_36_2
GENX_SNES_AX_SITE_METHOD = local
GENX_SNES_AX_SITE = $(BR2_EXTERNAL_PICCOLO_AX_PATH)/../../Generation-X-AX
GENX_SNES_AX_DEPENDENCIES = ax-sdk

GENX_SNES_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

GENX_SNES_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DGENX_BUILD_SNES=ON \
	-DAX_FETCH_SDK=OFF \
	-DAX_SDK_DIR=$(STAGING_DIR)/usr \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(GENX_SNES_AX_AX_FLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(GENX_SNES_AX_AX_FLAGS)" \
	-DCMAKE_EXE_LINKER_FLAGS="$(TARGET_LDFLAGS) -flto=thin -Wl,--build-id=sha1"

define GENX_SNES_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

define GENX_SNES_AX_INSTALL_TARGET_CMDS
	if [ -x "$(@D)/build/genx-snes-ax" ]; then \
		$(INSTALL) -D -m 0755 $(@D)/build/genx-snes-ax $(TARGET_DIR)/usr/bin/genx-snes-ax; \
	else \
		$(INSTALL) -D -m 0755 $(@D)/genx-snes-ax $(TARGET_DIR)/usr/bin/genx-snes-ax; \
	fi
	$(INSTALL) -D -m 0755 $(@D)/scripts/ax-snes-launch.sh $(TARGET_DIR)/usr/bin/ax-snes-launch.sh
endef

$(eval $(cmake-package))
