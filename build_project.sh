#!/bin/sh
mkdir -p "ulc-ios-games";
cp -Rp $HOME/Projects/ulc-ios-games/* ./ulc-ios-games/;
rm -rf Podfile.lock;
fastlane beta

