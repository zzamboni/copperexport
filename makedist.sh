#!/bin/bash
# Create the zip files for distributing CopperExport

TMPDIR=/tmp
DSTDIR=..

# First the standard distribution

DISTFILES="build/CopperExport.iPhotoExporter ReadMe.rtf ChangeLog cpg-patches"

VERSION=`perl -ne '/CFBundleVersion/ && do { $_ = <> ; /<string>(.+)<\/string>/ && print "$1\n" }' Info.plist`
if [ -z "$VERSION" ]; then
    echo "Cannot determine version number!" >&2
    exit 1
fi

DIR="$TMPDIR/CopperExport-$VERSION"
mkdir -p $DIR || exit 2

cp -Rp $DISTFILES $DIR || exit 3
(cd "$TMPDIR"; zip -r "CopperExport-$VERSION.zip" "CopperExport-$VERSION" || exit 4)
mv "$TMPDIR/CopperExport-$VERSION.zip" "$DSTDIR" || exit 5
rm -rf "$DIR"

# And then the source zip

#DIR="$TMPDIR/CopperExportSrc-$VERSION"
#
#svn export . "$DIR" || exit 6
#(cd "$TMPDIR"; zip -r "CopperExportSrc-$VERSION.zip" "CopperExportSrc-$VERSION" || exit 7)
#mv "$TMPDIR/CopperExportSrc-$VERSION.zip" "$DSTDIR" || exit 8
#rm -rf "$DIR"
