#!/bin/sh

#  SynxScript.sh
#  ULC
#
#  Created by Alexey on 7/5/16.
#  Copyright © 2016 wezom.com.ua. All rights reserved.

rm -rf "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Data";
cp -Rf "$UNITY_IOS_EXPORT_PATH/Data" "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Data";