include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = RotateWall
RotateWall_FILES = SNRootListController.m
RotateWall_INSTALL_PATH = /Library/PreferenceBundles
RotateWall_FRAMEWORKS = UIKit
RotateWall_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/RotateWall.plist$(ECHO_END)
