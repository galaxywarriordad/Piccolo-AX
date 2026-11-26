################################################################################
#
# ax-sdk
#
################################################################################

AX_SDK_VERSION = main
AX_SDK_SITE = https://github.com/galaxywarriordad/ax-sdk.git
AX_SDK_SITE_METHOD = git
AX_SDK_LICENSE = MIT
AX_SDK_LICENSE_FILES = LICENSE
AX_SDK_INSTALL_STAGING = YES
AX_SDK_INSTALL_TARGET = NO

AX_SDK_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

AX_SDK_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(AX_SDK_AX_FLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(AX_SDK_AX_FLAGS)" \
	-DCMAKE_EXE_LINKER_FLAGS="$(TARGET_LDFLAGS) -Wl,--build-id=sha1" \
	-DCMAKE_SHARED_LINKER_FLAGS="$(TARGET_LDFLAGS) -Wl,--build-id=sha1"

define AX_SDK_BUILD_CMDS
	cmake -S $(@D) -B $(@D)/build -G "Unix Makefiles" $(AX_SDK_CONF_OPTS)
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

$(eval $(cmake-package))
