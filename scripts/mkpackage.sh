#!/bin/bash
INSTRES=build/Install_resources
rm -rf $INSTRES
mkdir -p $INSTRES

for i in package/Install_resources/*; do
	./scripts/subst_keywords.pl $i ${INSTRES}/`basename $i`
done
./scripts/subst_keywords.pl package/Info.plist build/Info.plist
/Developer/Tools/packagemaker -build -v -ds -p build/CopperExport.pkg -f build/Package_contents -r ${INSTRES} -i build/Info.plist -d package/Description.plist
cp package/TokenDefinitions.plist package/IFRequirement.strings build/CopperExport.pkg/Contents/Resources/
rm -rf build/Package_contents ${INSTRES} build/Info.plist
