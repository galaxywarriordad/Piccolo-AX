################################################################################
#
# ax-configs
#
################################################################################

AX_CONFIGS_VERSION = 1.0
AX_CONFIGS_SITE = $(BR2_EXTERNAL_PICCOLO_AX_PATH)/board/piccolo-ax/rootfs-overlay
AX_CONFIGS_SITE_METHOD = local
AX_CONFIGS_LICENSE = GPL-3.0

define AX_CONFIGS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/etc/emulationstation/es_systems_cannonball.cfg \
		$(TARGET_DIR)/etc/emulationstation/es_systems_cannonball.cfg
	$(INSTALL) -D -m 0644 $(@D)/etc/emulationstation/es_systems_frontier.cfg \
		$(TARGET_DIR)/etc/emulationstation/es_systems_frontier.cfg
	$(INSTALL) -D -m 0644 $(@D)/etc/emulationstation/es_systems_megadrive.cfg \
		$(TARGET_DIR)/etc/emulationstation/es_systems_megadrive.cfg
	$(INSTALL) -D -m 0644 $(@D)/etc/emulationstation/es_systems_fbneo.cfg \
		$(TARGET_DIR)/etc/emulationstation/es_systems_fbneo.cfg
endef

$(eval $(generic-package))
