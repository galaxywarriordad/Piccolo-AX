################################################################################
#
# genx-snes-ax
#
################################################################################

GENX_SNES_AX_VERSION = v1_36_2
GENX_SNES_AX_SITE_METHOD = local
GENX_SNES_AX_SITE = $(BR2_EXTERNAL_PICCOLO_AX_PATH)/../../Generation-X-AX
GENX_SNES_AX_DEPENDENCIES = ax-sdk
GENX_SNES_AX_CONF_OPTS = -DGENX_BUILD_SNES=ON

define GENX_SNES_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/genx-snes-ax $(TARGET_DIR)/usr/bin/genx-snes-ax
	$(INSTALL) -D -m 0755 $(@D)/scripts/ax-snes-launch.sh $(TARGET_DIR)/usr/bin/ax-snes-launch.sh
endef

$(eval $(cmake-package))
