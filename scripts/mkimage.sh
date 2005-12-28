#!/bin/bash
IMGDIR=build/distimage
MASTERIMG=build/master.dmg
TEMPLATE=../package/template.dmg.bz2
SOURCE_FILES="build/FacesExport.pkg ../package/Install_resources/ReadMe.rtf"

VERSION=`perl -ne '/CFBundleVersion/ && do { $_ = <> ; /<string>(.+)<\/string>/ && print "$1\n" }' Info.plist`
if [ -z "$VERSION" ]; then
    echo "Cannot determine version number!" >&2
    exit 1
fi
FINALIMG=build/FacesExport-${VERSION}.dmg

rm -rf ${IMGDIR} ${FINALIMG}
bunzip2 -c ${TEMPLATE} > ${MASTERIMG}
mkdir -p ${IMGDIR}
hdiutil attach "${MASTERIMG}" -noautoopen -quiet -mountpoint ${IMGDIR}
WC_DEV=`hdiutil info | grep "${IMGDIR}" | grep "Apple_HFS" | awk '{print $1}'`
for i in ${SOURCE_FILES}; do 
	rm -rf "${IMGDIR}/$i"
	ditto -rsrc "$i" "${IMGDIR}/`basename $i`"; \
done
#mv build/FacesExport.pkg ${IMGDIR}
#cp ../package/Install_resources/ReadMe.rtf ${IMGDIR}
hdiutil detach ${WC_DEV} -quiet -force
hdiutil convert "${MASTERIMG}" -quiet -format UDZO -imagekey zlib-level=9 -o "${FINALIMG}"
#hdiutil create -srcfolder ${IMGDIR} -volname FacesExport build/FacesExport.dmg
rm -rf ${IMGDIR} ${MASTERIMG}
