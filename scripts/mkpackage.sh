#!/bin/bash
VERSION=`perl -ne '/CFBundleVersion/ && do { $_ = <> ; /<string>(.+)<\/string>/ && print "$1\n" }' Info.plist`
if [ -z "$VERSION" ]; then
    echo "Cannot determine version number!" >&2
    exit 1
fi 
/Developer/Tools/packagemaker -build -v -ds -p build/CopperExport.pkg -f build/Package_contents -r package/Install_resources -i package/Info.plist -d package/Description.plist
cp package/TokenDefinitions.plist package/IFRequirement.strings build/CopperExport.pkg/Contents/Resources/
rm -rf build/Package_contents
