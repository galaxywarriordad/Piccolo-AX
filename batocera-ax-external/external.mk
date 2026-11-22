include $(sort $(wildcard $(BR2_EXTERNAL_PICCOLO_AX_PATH)/package/*/*.mk))

ifeq ($(BR2_PACKAGE_PICCOLO_AX_DESKTOP),y)
ifneq ($(BR2_EXTERNAL_PICCOLO_AX_DESKTOP_PATH),)
include $(BR2_EXTERNAL_PICCOLO_AX_DESKTOP_PATH)/profiles/desktop-core.mk
include $(BR2_EXTERNAL_PICCOLO_AX_DESKTOP_PATH)/profiles/desktop-heavy.mk
include $(sort $(wildcard $(BR2_EXTERNAL_PICCOLO_AX_DESKTOP_PATH)/buildroot/package/*/*.mk))
endif
endif
