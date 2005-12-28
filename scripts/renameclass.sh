#!/bin/bash -x

if [[ $# -ne 2 ]]; then
	echo "Usage: $0 [-nomv] oldclass newclass"
fi
DOMV=1
if [[ "$1" = "-nomv" ]]; then
	DOMV=0
	shift
fi
OLD=$1
NEW=$2

if [[ $DOMV -eq 1 ]]; then
	mv "$OLD.h" "$NEW.h" || exit 1
	mv "$OLD.m" "$NEW.m" || exit 1
fi
perl -p -i.bak -e 's/\b'"$OLD"'\b/'"$NEW"'/g' `grep -rl --exclude="keyedobjects.nib*" "$OLD" . | grep -v '\.svn'`
