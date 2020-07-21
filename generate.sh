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

echo "Creating output directories"
mkdir -pv out/page-xml
mkdir -pv out/tmp
mkdir -pv out/wiki/images

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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
   cat $PAGE_PATH | sed "s/&nbsp;/ /g"  | sed "s/&szlig;/ß/g"  | sed "s/&ouml;/ö/g"  | sed "s/&auml;/ä/g"  | sed "s/&uuml;/ü/g"  | sed "s/&Auml;/Ä/g"  | sed "s/&Ouml;/Ö/g"  | sed "s/&Uuml;/Ü/g"  | sed -e 's/<!DOCTYPE.*>//g' > out/tmp/$PAGE_CLEAN
   
   xsltproc $SCRIPTDIR/page.xsl "out/tmp/${PAGE_CLEAN}" > "out/wiki/${PAGE_MD}"
done

echo "Content generated to out/wiki"

