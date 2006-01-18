#!/bin/bash
IMGDIR=build/distimage
SOURCE_FILES="build/CopperExport.pkg build/CopperExport.pkg/Contents/Resources/ReadMe.rtf ChangeLog cpg-patches"

FINALIMG=`echo 'build/CopperExport-[[version]].dmg' | ./scripts/subst_keywords.pl`

rm -rf ${IMGDIR} ${FINALIMG}
mkdir -p ${IMGDIR}
for i in ${SOURCE_FILES}; do 
	rm -rf "${IMGDIR}/$i"
	ditto -rsrc "$i" "${IMGDIR}/`basename $i`"; \
done
hdiutil create -srcfolder ${IMGDIR} -format UDZO -imagekey zlib-level=9 -volname CopperExport ${FINALIMG}
rm -rf ${IMGDIR}
open build/