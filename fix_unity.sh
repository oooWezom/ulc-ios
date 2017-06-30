#!/bin/sh

#  FixUnityBuildScript.sh
#  ULC
#
#  Created by Alexey on 9/9/16.
#  Copyright © 2016 wezom.com.ua. All rights reserved.

inputMainDir="Documentation/ChangedFiles/main.mm"
outputMainDir="ulc-ios-games/buildGame/Classes/main.mm"
inputUnityControllerDir="Documentation/ChangedFiles/UnityAppController.h"
outputUnityControllerDir="ulc-ios-games/buildGame/Classes/UnityAppController.h"

testPath="ulc-ios-games/buildGame/Classes/Native/Bulk_Assembly-CSharp_0.cpp"
blanckFilePath="Documentation/ChangedFiles/blank.txt"

if [ -f "$inputMainDir" ] && [ -f "$outputMainDir" ] && [ -f "$inputUnityControllerDir" ] && [ -f "$outputUnityControllerDir" ]
then
    cp -Rfi "$inputMainDir" "$outputMainDir"
    cp -Rfi "$inputUnityControllerDir" "$outputUnityControllerDir"
else
    echo "$outputMainDir OR $inputMainDir not found."
fi