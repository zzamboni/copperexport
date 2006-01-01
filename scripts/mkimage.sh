#!/bin/bash
IMGDIR=build/distimage
SOURCE_FILES="build/CopperExport.pkg package/Install_resources/ReadMe.rtf"

VERSION=`perl -ne '/CFBundleVersion/ && do { $_ = <> ; /<string>(.+)<\/string>/ && print "$1\n" }' Info.plist`
if [ -z "$VERSION" ]; then
    echo "Cannot determine version number!" >&2
    exit 1
fi
FINALIMG=build/CopperExport-${VERSION}.dmg

rm -rf ${IMGDIR} ${FINALIMG}
mkdir -p ${IMGDIR}
for i in ${SOURCE_FILES}; do 
	rm -rf "${IMGDIR}/$i"
	ditto -rsrc "$i" "${IMGDIR}/`basename $i`"; \
done
hdiutil create -srcfolder ${IMGDIR} -format UDZO -imagekey zlib-level=9 -volname CopperExport ${FINALIMG}
rm -rf ${IMGDIR}
