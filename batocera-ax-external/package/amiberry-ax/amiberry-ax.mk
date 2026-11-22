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

AMIBERRY_AX_CONF_OPTS = \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_COMPILER=$(HOST_DIR)/bin/clang \
	-DCMAKE_CXX_COMPILER=$(HOST_DIR)/bin/clang++ \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) -march=skylake -O3 -flto=thin" \
	-DUSE_AX_SDK=ON \
	-DAX_SKYLAKE_ARCH=ON \
	-DFETCHCONTENT_SOURCE_DIR_AX_SDK=$(STAGING_DIR)/usr/src/ax-sdk \
	-DUSE_86BOX=OFF \
	-DUSE_PPC=OFF \
	-DUSE_FFMPEG=OFF \
	-DUSE_WEBP=OFF \
	-DWITH_LTO=ON

define AMIBERRY_AX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/amiberry $(TARGET_DIR)/usr/bin/amiberry
	if [ -d $(@D)/data ]; then \
		mkdir -p $(TARGET_DIR)/usr/share/amiberry; \
		cp -r $(@D)/data $(TARGET_DIR)/usr/share/amiberry/; \
	fi
endef

$(eval $(cmake-package))
