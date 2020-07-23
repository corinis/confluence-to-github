#!/bin/bash
########################################################################
# Generate github markdown pages from confluence export
########################################################################

if ! command -v xsltproc &> /dev/null
then
    echo "Unable to find xsltproc"
    echo "Install using: "
    echo " sudo apt install -y xsltproc"
    exit 1
fi


SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASEDIR=

if [ ! "$1x" = "x" ]; then
	if [ -d $1 ]; then
		BASEDIR=$1
		cd $BASEDIR
	elif [[ ${1: -4} = ".zip" ]]; then
		BASEDIR="$(dirname $1)"
		cd $BASEDIR
		unzip -u $(basename $1)
	elif [[ ${1: -4} = ".xml" ]]; then
		BASEDIR="$(dirname $1)"
                cd ${BASEDIR}
	fi
	BASEDIR=$BASEDIR/
fi

if [[ ! -f entities.xml ]] ; then
	echo "Error: Unable to find entities.xml"
	echo "Usage: "
	echo "   $0 [path-to-folder-with-entities.xml]"
	echo "   $0 export.zip"
	exit 1
fi

echo "Creating output directories"
mkdir -pv out/page-xml
mkdir -pv out/tmp
mkdir -pv out/wiki/images

echo "Generating page xmls and image mapping"
xsltproc $SCRIPTDIR/entities.xsl entities.xml

echo "Copying images from attachments"
xsltproc $SCRIPTDIR/image-mappings.xsl out/image-mappings.xml | bash


echo "Convert page xmls to github markdown"
for PAGE_PATH in out/page-xml/*.xml; do 
   # clean page
   PAGE_XML=${PAGE_PATH##out/page-xml/}
   PAGE_MD=${PAGE_XML%%.xml}.md
   PAGE_CLEAN=${PAGE_XML%%.xml}-cleaned.xml
   cat $PAGE_PATH | sed "s/&nbsp;/ /g"  | sed "s/&szlig;/ß/g"  | sed "s/&ouml;/ö/g"  | sed "s/&auml;/ä/g" | sed "s/&ldquo;/'/g"| sed "s/&tdquo;/'/g"  | sed "s/&rsquo;/'/g"  | sed "s/&rdquo;/'/g"  | sed "s/&uuml;/ü/g"  | sed "s/&Auml;/Ä/g"  | sed "s/&Ouml;/Ö/g"  | sed "s/&Uuml;/Ü/g"  | sed "s/&hellip;/.../g" | sed "s/&ndash;/-/g" | sed "s/&sect;/§/g" | sed "s/&bdquo;/'/g" | sed "s/&rarr;/-\&gt;/g" | sed -e 's/<!DOCTYPE.*>//g' > out/tmp/$PAGE_CLEAN
   
   xsltproc $SCRIPTDIR/page.xsl "out/tmp/${PAGE_CLEAN}" > "out/wiki/${PAGE_MD}"
done

rm -rf out/tmp
rm -rf out/page-xml

echo "Content generated to ${BASEDIR}out/wiki/"

