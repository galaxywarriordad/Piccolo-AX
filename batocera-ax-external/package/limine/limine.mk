################################################################################
#
# limine
#
################################################################################

LIMINE_VERSION = 8.6.0
LIMINE_SITE = https://github.com/limine-bootloader/limine/releases/download/v$(LIMINE_VERSION)
LIMINE_SOURCE = limine-$(LIMINE_VERSION).tar.xz
LIMINE_LICENSE = BSD-2-Clause

define LIMINE_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -j4 -C $(@D) CC="$(HOSTCC)" limine
endef

define LIMINE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/BOOTX64.EFI $(BINARIES_DIR)/EFI/BOOT/BOOTX64.EFI
	$(INSTALL) -D -m 0644 $(@D)/limine-bios.sys $(BINARIES_DIR)/limine-bios.sys
endef

$(eval $(generic-package))
