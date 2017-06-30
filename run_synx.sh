#!/bin/sh

#  SynxScript.sh
#  ULC
#
#  Created by Alexey on 7/5/16.
#  Copyright © 2016 wezom.com.ua. All rights reserved.

###### 

#  WARNING: Make sure that your project is backed up through source control before doing anything
#  WARNING: Run this script when all groups is created

synx  -e "ULC/Unity/Data" -e "ULC/Unity/Classes" -e "ULC/Unity/Libraries"  ULC.xcodeproj