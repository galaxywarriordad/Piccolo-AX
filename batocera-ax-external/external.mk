include $(sort $(wildcard $(BR2_EXTERNAL_PICCOLO_AX_PATH)/package/*/*.mk))

ifeq ($(BR2_PACKAGE_PICCOLO_AX_DESKTOP),y)
ifneq ($(BR2_EXTERNAL_PICCOLO_AX_DESKTOP_PATH),)
include $(BR2_EXTERNAL_PICCOLO_AX_DESKTOP_PATH)/profiles/desktop-core.mk
include $(BR2_EXTERNAL_PICCOLO_AX_DESKTOP_PATH)/profiles/desktop-heavy.mk
include $(sort $(wildcard $(BR2_EXTERNAL_PICCOLO_AX_DESKTOP_PATH)/buildroot/package/*/*.mk))
else
$(warning BR2_PACKAGE_PICCOLO_AX_DESKTOP=y is set, but BR2_EXTERNAL_PICCOLO_AX_DESKTOP_PATH is empty)
endif
endif
```[cite: 16]

### 2. `ax-sdk.mk`
```makefile
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
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

$(eval $(cmake-package))
```[cite: 21]

### 3. `ax-configs.mk`
```makefile
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
```[cite: 20]

### 4. `blastem-ax.mk`
```makefile
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
```[cite: 22]

### 5. `cannonball-ax.mk`
```makefile
################################################################################
#
# cannonball-ax
#
################################################################################

CANNONBALL_AX_VERSION = main
_AX_PROTO = https
_AX_HOST = github.com
CANNONBALL_AX_SITE = $(_AX_PROTO)://$(_AX_HOST)/galaxywarriordad/Generation-X-AX.git
CANNONBALL_AX_SITE_METHOD = git
CANNONBALL_AX_SUBDIR = engines/cannonball/cmake
CANNONBALL_AX_LICENSE = GPL-3.0
CANNONBALL_AX_LICENSE_FILES = docs/license.txt

CANNONBALL_AX_DEPENDENCIES = \
	ax-sdk \
	boost \
	sdl2 \
	libgl

CANNONBALL_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

CANNONBALL_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DTARGET=linux.cmake \
	-DAX_SDK_DIR=$(STAGING_DIR)/usr \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(CANNONBALL_AX_AX_FLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(CANNONBALL_AX_AX_FLAGS)" \
	-DCMAKE_EXE_LINKER_FLAGS="$(TARGET_LDFLAGS) -flto=thin -Wl,--build-id=sha1"

define CANNONBALL_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

define CANNONBALL_AX_INSTALL_TARGET_CMDS
	if [ -x "$(@D)/build/cannonball" ]; then \
		$(INSTALL) -D -m 0755 $(@D)/build/cannonball $(TARGET_DIR)/usr/bin/cannonball; \
	elif [ -x "$(@D)/cmake/cannonball" ]; then \
		$(INSTALL) -D -m 0755 $(@D)/cmake/cannonball $(TARGET_DIR)/usr/bin/cannonball; \
	else \
		$(INSTALL) -D -m 0755 $(@D)/cannonball $(TARGET_DIR)/usr/bin/cannonball; \
	fi
	mkdir -p $(TARGET_DIR)/usr/share/cannonball
	if [ -d "$(@D)/../res" ]; then \
		cp -r $(@D)/../res $(TARGET_DIR)/usr/share/cannonball/; \
	elif [ -d "$(@D)/res" ]; then \
		cp -r $(@D)/res $(TARGET_DIR)/usr/share/cannonball/; \
	fi
endef

$(eval $(cmake-package))
```[cite: 23]

### 6. `genx-snes-ax.mk`
```makefile
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
```[cite: 27]

### 7. `flycast-ax.mk`
```makefile
################################################################################
#
# flycast-ax
#
################################################################################

FLYCAST_AX_VERSION = main
_AX_PROTO = https
_AX_HOST = github.com
FLYCAST_AX_SITE = $(_AX_PROTO)://$(_AX_HOST)/galaxywarriordad/Generation-X-AX.git
FLYCAST_AX_SITE_METHOD = git
FLYCAST_AX_LICENSE = GPL-2.0
FLYCAST_AX_LICENSE_FILES = engines/flycast/LICENSE
FLYCAST_AX_SUPPORTS_IN_SOURCE_BUILD = NO

FLYCAST_AX_DEPENDENCIES = \
	host-pkgconf \
	ax-sdk \
	sdl2 \
	alsa-lib \
	libcurl \
	vulkan-headers \
	vulkan-loader \
	libzip \
	zlib

FLYCAST_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

FLYCAST_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(FLYCAST_AX_AX_FLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(FLYCAST_AX_AX_FLAGS)" \
	-DCMAKE_EXE_LINKER_FLAGS="$(TARGET_LDFLAGS) -flto=thin -Wl,--build-id=sha1" \
	-DAX_FETCH_SDK=OFF \
	-DAX_SDK_DIR=$(STAGING_DIR)/usr \
	-DAX_BUILD_RMG=OFF \
	-DAX_BUILD_BLASTEM=OFF \
	-DAX_BUILD_CANNONBALL=OFF \
	-DAX_BUILD_EDUKE32=OFF \
	-DAX_BUILD_FRONTIER=OFF \
	-DAX_BUILD_HATARI=OFF \
	-DAX_BUILD_FLYCAST=ON \
	-DUSE_VULKAN=ON \
	-DUSE_ALSA=ON \
	-DUSE_OPENMP=OFF \
	-DUSE_PULSEAUDIO=OFF \
	-DUSE_LIBAO=OFF \
	-DUSE_DISCORD=OFF \
	-DUSE_BREAKPAD=OFF \
	-DUSE_HOST_SDL=ON \
	-DENABLE_CTEST=OFF

define FLYCAST_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

define FLYCAST_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/engines/flycast/flycast $(TARGET_DIR)/usr/bin/flycast
endef

$(eval $(cmake-package))
```[cite: 25]

### 8. `hatari-ax.mk`
```makefile
################################################################################
#
# hatari-ax
#
################################################################################

HATARI_AX_VERSION = main
_AX_PROTO = https
_AX_HOST = github.com
HATARI_AX_SITE = $(_AX_PROTO)://$(_AX_HOST)/galaxywarriordad/Generation-X-AX.git
HATARI_AX_SITE_METHOD = git
HATARI_AX_LICENSE = GPL-2.0
HATARI_AX_LICENSE_FILES = engines/hatari/gpl.txt
HATARI_AX_SUPPORTS_IN_SOURCE_BUILD = NO

HATARI_AX_DEPENDENCIES = \
	host-pkgconf \
	ax-sdk \
	sdl2 \
	alsa-lib \
	libpng \
	zlib

HATARI_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

HATARI_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(HATARI_AX_AX_FLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(HATARI_AX_AX_FLAGS)" \
	-DCMAKE_EXE_LINKER_FLAGS="$(TARGET_LDFLAGS) -flto=thin -Wl,--build-id=sha1" \
	-DAX_FETCH_SDK=OFF \
	-DAX_SDK_DIR=$(STAGING_DIR)/usr \
	-DAX_BUILD_RMG=OFF \
	-DAX_BUILD_BLASTEM=OFF \
	-DAX_BUILD_CANNONBALL=OFF \
	-DAX_BUILD_EDUKE32=OFF \
	-DAX_BUILD_FRONTIER=OFF \
	-DAX_BUILD_FLYCAST=OFF \
	-DAX_BUILD_HATARI=ON \
	-DENABLE_HATARI=ON \
	-DENABLE_DSP_EMU=ON \
	-DENABLE_LIBRETRO=OFF \
	-DENABLE_TOOLS=OFF \
	-DENABLE_MAN_PAGES=OFF \
	-DENABLE_SDL3=OFF

define HATARI_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

define HATARI_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/engines/hatari/src/hatari $(TARGET_DIR)/usr/bin/hatari
	mkdir -p $(TARGET_DIR)/usr/share/hatari
	cp -r $(@D)/engines/hatari/share/* $(TARGET_DIR)/usr/share/hatari/ 2>/dev/null || true
endef

$(eval $(cmake-package))
```[cite: 28]

### 9. `rmg-ax.mk`
```makefile
################################################################################
#
# rmg-ax
#
################################################################################

RMG_AX_VERSION = main
_AX_PROTO = https
_AX_HOST = github.com
RMG_AX_SITE = $(_AX_PROTO)://$(_AX_HOST)/galaxywarriordad/Generation-X-AX.git
RMG_AX_SITE_METHOD = git
RMG_AX_SUBDIR = engines/rmg
RMG_AX_GIT_SUBMODULES = YES
RMG_AX_LICENSE = GPL-3.0
RMG_AX_LICENSE_FILES = LICENSE

RMG_AX_DEPENDENCIES = \
	ax-sdk \
	host-pkgconf \
	host-nasm \
	qt6base \
	qt6svg \
	qt6websockets \
	sdl3 \
	libsamplerate \
	speexdsp \
	libusb \
	hidapi \
	minizip \
	freetype \
	zlib \
	vulkan-headers

RMG_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

RMG_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DPORTABLE_INSTALL=OFF \
	-DUSE_SYSTEM_LIBS=ON \
	-DAX_FETCH_SDK=OFF \
	-DAX_SDK_DIR=$(STAGING_DIR)/usr \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(RMG_AX_AX_FLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(RMG_AX_AX_FLAGS)" \
	-DCMAKE_EXE_LINKER_FLAGS="$(TARGET_LDFLAGS) -flto=thin -Wl,--build-id=sha1"

define RMG_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

$(eval $(cmake-package))
```[cite: 30]

### 10. `frontier-ax.mk`
```makefile
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
```[cite: 26]

### 11. `flac-ax.mk`
```makefile
################################################################################
#
# flac-ax
#
################################################################################

FLAC_AX_LOCAL_DIR := $(wildcard $(BR2_EXTERNAL_PICCOLO_AX_PATH)/../../FLAC_AX)
ifneq ($(FLAC_AX_LOCAL_DIR),)
FLAC_AX_SITE = $(FLAC_AX_LOCAL_DIR)
FLAC_AX_SITE_METHOD = local
else
FLAC_AX_VERSION = main
FLAC_AX_SITE = https://github.com/galaxywarriordad/FLAC_AX.git
FLAC_AX_SITE_METHOD = git
endif

FLAC_AX_LICENSE = MIT
FLAC_AX_LICENSE_FILES = LICENSE.md
FLAC_AX_SUPPORTS_IN_SOURCE_BUILD = NO

FLAC_AX_DEPENDENCIES = \
	host-pkgconf \
	ax-sdk \
	flac \
	alsa-lib

ifeq ($(BR2_PACKAGE_FLAC_AX_AV_STUDIO),y)
FLAC_AX_DEPENDENCIES += sdl2
FLAC_AX_CONF_OPTS += -DFLAC_AX_BUILD_AV_STUDIO=ON
else
FLAC_AX_CONF_OPTS += -DFLAC_AX_BUILD_AV_STUDIO=OFF
endif

ifeq ($(BR2_PACKAGE_SDL2)$(BR2_PACKAGE_HAS_LIBGL),yy)
FLAC_AX_DEPENDENCIES += sdl2 libgl
FLAC_AX_CONF_OPTS += -DFLAC_AX_ENABLE_SDL2_GL=ON
else
FLAC_AX_CONF_OPTS += -DFLAC_AX_ENABLE_SDL2_GL=OFF
endif

ifeq ($(BR2_PACKAGE_LIBOPENMPT),y)
FLAC_AX_DEPENDENCIES += libopenmpt
FLAC_AX_CONF_OPTS += -DFLAC_AX_ENABLE_OPENMPT=ON
else
FLAC_AX_CONF_OPTS += -DFLAC_AX_ENABLE_OPENMPT=OFF
endif

FLAC_AX_DEPENDENCIES := $(sort $(FLAC_AX_DEPENDENCIES))
FLAC_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

FLAC_AX_CONF_OPTS += \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(FLAC_AX_AX_FLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(FLAC_AX_AX_FLAGS)" \
	-DCMAKE_EXE_LINKER_FLAGS="$(TARGET_LDFLAGS) -flto=thin -Wl,--build-id=sha1" \
	-DFLAC_AX_USE_AX_SDK=ON \
	-DFETCHCONTENT_SOURCE_DIR_AX_SDK=$(STAGING_DIR)/usr/src/ax-sdk \
	-DFLAC_AX_BUILD_VIDEO_UPSCALER=$(if $(BR2_PACKAGE_FLAC_AX_VIDEO_UPSCALER),ON,OFF) \
	-DFLAC_AX_BUILD_APPLIANCE_TUI=$(if $(BR2_PACKAGE_FLAC_AX_APPLIANCE_TUI),ON,OFF) \
	-DFLAC_AX_ENABLE_LTO=ON

ifeq ($(BR2_PACKAGE_FLAC_AX_USB_DAC_RULES),y)
define FLAC_AX_INSTALL_UDEV_RULES
	$(INSTALL) -D -m 0644 \
		$(BR2_EXTERNAL_PICCOLO_AX_PATH)/package/flac-ax/99-ax-usb-dacs.rules \
		$(TARGET_DIR)/etc/udev/rules.d/99-ax-usb-dacs.rules
endef
endif

define FLAC_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

define FLAC_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/flac_ax $(TARGET_DIR)/usr/bin/flac_ax
	for bin in ax_av_studio ax_video_upscaler ax_appliance_tui; do \
		if [ -x "$(@D)/$$bin" ]; then \
			$(INSTALL) -D -m 0755 "$(@D)/$$bin" "$(TARGET_DIR)/usr/bin/$$bin"; \
		fi; \
	done
	$(FLAC_AX_INSTALL_UDEV_RULES)
endef

$(eval $(cmake-package))
```[cite: 24]

### 12. `amiberry-ax.mk`
```makefile
################################################################################
#
# amiberry-ax
#
################################################################################

AMIBERRY_AX_VERSION = master
AMIBERRY_AX_SITE = https://github.com/galaxywarriordad/Amiberry-AX.git
AMIBERRY_AX_SITE_METHOD = git
AMIBERRY_AX_LICENSE = GPL-3.0
AMIBERRY_AX_LICENSE_FILES = LICENSE
AMIBERRY_AX_SUPPORTS_IN_SOURCE_BUILD = NO

AMIBERRY_AX_DEPENDENCIES = \
	host-clang-ax \
	ax-sdk \
	sdl3 \
	flac \
	libmpg123 \
	libpng \
	libxml2 \
	zlib

AMIBERRY_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

AMIBERRY_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_COMPILER=$(HOST_DIR)/bin/clang \
	-DCMAKE_CXX_COMPILER=$(HOST_DIR)/bin/clang++ \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(AMIBERRY_AX_AX_FLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(AMIBERRY_AX_AX_FLAGS)" \
	-DCMAKE_EXE_LINKER_FLAGS="$(TARGET_LDFLAGS) -flto=thin -Wl,--build-id=sha1" \
	-DUSE_AX_SDK=ON \
	-DAX_SKYLAKE_ARCH=ON \
	-DFETCHCONTENT_SOURCE_DIR_AX_SDK=$(STAGING_DIR)/usr/src/ax-sdk \
	-DUSE_86BOX=OFF \
	-DUSE_PPC=OFF \
	-DUSE_FFMPEG=OFF \
	-DUSE_WEBP=OFF \
	-DWITH_LTO=ON

define AMIBERRY_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

define AMIBERRY_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/amiberry $(TARGET_DIR)/usr/bin/amiberry
	if [ -d $(@D)/data ]; then \
		mkdir -p $(TARGET_DIR)/usr/share/amiberry; \
		cp -r $(@D)/data $(TARGET_DIR)/usr/share/amiberry/; \
	fi
endef

$(eval $(cmake-package))
```[cite: 19]

### 13. `cemu-latte-ax.mk`
```makefile
################################################################################
#
# cemu-latte-ax
#
################################################################################

CEMU_LATTE_AX_VERSION = main
CEMU_LATTE_AX_SITE = https://github.com/galaxywarriordad/Cemu-Latte-AX.git
CEMU_LATTE_AX_SITE_METHOD = git
CEMU_LATTE_AX_GIT_SUBMODULES = YES
CEMU_LATTE_AX_LICENSE = MPL-2.0
CEMU_LATTE_AX_LICENSE_FILES = LICENSE.txt

CEMU_LATTE_AX_DEPENDENCIES = \
	ax-sdk \
	boost \
	curl \
	fmt \
	glm \
	libpng \
	libzip \
	openssl \
	pugixml \
	sdl3 \
	vulkan-headers \
	vulkan-loader \
	wxwidgets \
	zlib \
	zstd

CEMU_LATTE_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

CEMU_LATTE_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DENABLE_VCPKG=OFF \
	-DALLOW_PORTABLE=OFF \
	-DENABLE_AX_SDK=ON \
	-DAX_SDK_DIR=$(STAGING_DIR)/usr \
	-DENABLE_WAYLAND=OFF \
	-DENABLE_DISCORD_RPC=OFF \
	-DENABLE_CUBEB=ON \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(CEMU_LATTE_AX_AX_FLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(CEMU_LATTE_AX_AX_FLAGS)" \
	-DCMAKE_EXE_LINKER_FLAGS="$(TARGET_LDFLAGS) -flto=thin -Wl,--build-id=sha1"

define CEMU_LATTE_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

$(eval $(cmake-package))
```[cite: 17]

### 14. `eden-ax.mk`
```makefile
################################################################################
#
# eden-ax
#
################################################################################

EDEN_AX_VERSION = master
EDEN_AX_SITE = https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX.git
EDEN_AX_SITE_METHOD = git
EDEN_AX_GIT_SUBMODULES = YES
EDEN_AX_LICENSE = GPL-3.0-or-later
EDEN_AX_LICENSE_FILES = LICENSE.txt
EDEN_AX_DEPENDENCIES = ax-sdk sdl3 vulkan-headers vulkan-loader ffmpeg zlib zstd

EDEN_AX_AX_FLAGS = -march=skylake -mbmi -mbmi2 -O3 -flto=thin -ffile-prefix-map=$(@D)=. -ffile-prefix-map=$(BR2_EXTERNAL_PICCOLO_AX_PATH)=.

EDEN_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DENABLE_AX_SDK=ON \
	-DAX_SDK_DIR=$(STAGING_DIR)/usr \
	-DENABLE_QT=OFF \
	-DYUZU_USE_BUNDLED_SDL3=OFF \
	-DENABLE_WEB_SERVICE=OFF \
	-DYUZU_USE_BUNDLED_VCPKG=OFF \
	-DYUZU_TESTS=OFF \
	-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(EDEN_AX_AX_FLAGS)" \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(EDEN_AX_AX_FLAGS)" \
	-DCMAKE_EXE_LINKER_FLAGS="$(TARGET_LDFLAGS) -flto=thin -Wl,--build-id=sha1"

define EDEN_AX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -j4 -C $(@D)/build
endef

$(eval $(cmake-package))
```[cite: 18]

### 15. `limine.mk`
```makefile
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
```[cite: 29]

---

### Quick Verification Checklist
* **Buildroot parse check:** Run `make BR2_EXTERNAL=... piccolo_x86_64_defconfig` and `make -n` (or `make V=1`) to confirm all 15 `.mk` files parse cleanly without path or syntax warnings.
* **Out-of-tree build directories:** In `cmake-package` recipes (`cannonball-ax.mk`, `genx-snes-ax.mk`, `flycast-ax.mk`, `hatari-ax.mk`, `rmg-ax.mk`, `flac-ax.mk`, `amiberry-ax.mk`, `cemu-latte-ax.mk`, `eden-ax.mk`), verify your Buildroot out-of-tree build directory matches `$(@D)/build` (or adjust to `$(<PKG>_BUILDDIR)` if Buildroot places out-of-tree builds outside `$(@D)`).

Would you like to check `GNUmakefile` or `sdlayer.cpp` next?
