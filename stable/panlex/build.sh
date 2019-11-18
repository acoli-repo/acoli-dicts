#!/bin/bash
# retrieve PanLex dictionaries and provide an Ontolex-lemon edition

# (c) 2019-04-02 Christian Chiarcos, christian.chiarcos@web.de
# Apache License 2.0, see https://www.apache.org/licenses/LICENSE-2.0

##########
# CONFIG #
##########

# PanLex snapshot URL
SRC=https://panlex.org/snapshot/;

# XSLT 2.0+ processor, replace by your own
# SAXON can be obtained from http://saxon.sourceforge.net/
SAXON=saxon;
# my configuration
# Saxon 9.1.0.7J from Saxonica, using a script that includes the call to java

# SPARQL 1.1 engine, replace by your own
# Apache Jena's arq can be obtained from https://jena.apache.org/download/
ARQ=arq;
# development system:
# Jena:       VERSION: 3.9.0
# Jena:       BUILD_DATE: 2018-09-28T17:15:32+0000
# ARQ:        VERSION: 3.9.0
# ARQ:        BUILD_DATE: 2018-09-28T17:15:32+0000
# RIOT:       VERSION: 3.9.0
# RIOT:       BUILD_DATE: 2018-09-28T17:15:32+0000

#####################################################
# (1) create source XML and split into dictionaries #
#####################################################

mkdir -p src;
if find src | egrep 'src/panlex.*xml.zip$' >& /dev/null; then
	echo using existing XML dump 1>&2;
else
	if find src | egrep 'src/panlex-.*-csv.zip$' | head -n 1 | egrep . >/dev/null; then 
		cd src
		file=`ls panlex-*-csv.zip | head -n 1`;
		echo extract src/$file 1>&2;
		unzip -u $file;
		
		# the latest built directory
		dir=`ls -dt */ | grep 'panlex-.*-csv' | head -n 1 | sed s/'\/.*'//`
		echo 1>&2;
		echo reading src/$dir 1>&2;
		
		if [ ! -e $dir-xml.zip ] ; then
			echo 1>&2;
			echo building $dir-xml.zip 1>&2;
			cd $dir;
			
			if javac ../../PanLex.java; then
				java -Xmx3g -Dfile.encoding=UTF-8 -classpath ../.. PanLex . 2>&1 | \
				tee panlex.log;
			fi;
			
			cd ..
			zip -rm $dir-xml.zip $dir/sources
			echo 1>&2;
		else
			echo 1>&2;
			echo using existing $dir-xml.zip 1>&2;
			echo 1>&2;
		fi;
		
		cd ..
	else # failures
		#####################
		# no CSV dump found #
		#####################
		echo "please deposit a current CSV dump from " $SRC " under src/." 1>&2
		echo "we expect a file with naming scheme src/panlex-YYYYMMDD-csv.zip, with YYYYMMDD being the release date" 1>&2;
	fi;
fi;

#################################
# (2) get language code mapping #
#################################
# we expect ISO-639-3 codes, map to ISO-639-1 where applicable
# this is *approximative* BCP47, as we don't map from 639-3 to 639-2

echo 1>&2
if [ -e sed/iso-3-to-bcp47.sed ] ; then
	echo use existing BCP47 mapping 1>&2;
else
	echo retrieve BCP47 mapping 1>&2;
	mkdir -p sed;
	cd sed;
	wget -nc https://iso639-3.sil.org/sites/iso639-3/files/downloads/iso-639-3_Code_Tables_20190125.zip;
	unzip -c iso-639-3_Code_Tables_20190125.zip iso-639-3_Code_Tables_20190125/iso-639-3_20190125.tab | \
	cut -f 1,4 | \
	egrep '^[a-z]+\s+[a-z]+$'  | \
	sed s/'\(...\)\s\(..\)'/"s\/<lang_code>\1<\/<lang_code>\2<\/g"/ > iso-3-to-bcp47.sed;
	cd ..
fi;

##########################################################
# (2) RDF/XML conversion and language code normalization #
##########################################################

echo 1>&2;
mkdir -p rdf;
for file in src/*xml.zip; do
	if [ -e `echo $file | sed -e s/'^src\/'// -e s/'xml'/'rdf'/g` ]; then
		echo $file already processed, skipping 1>&2;
		echo 1>&2;
	else
		echo processing $file 1>&2;
		for xml in `unzip -l src/panlex-20191001-csv-xml.zip | sed s/'.*\s'// | egrep xml`; do
			echo $file:$xml 1>&2;
			target=`echo $xml | sed -e s/'^sources\/'//`;
			mkdir -p rdf/`echo $target| sed -e s/'\/[^\/]*$'//`;
			unzip -c $file $xml | \
			# strip log infos and repair xml
			grep '<' | xmllint --recover - | \
			# normalize language codes
			sed -f sed/iso-3-to-bcp47.sed | \
			# extract RDF/XML
			SAXON -s:- -xsl:xml2rdf.xsl base=$SRC`echo $file | sed -e s/'.*\/'//g -e s/'.xml.zip$'//`/`echo $xml |sed s/'.*[^0-9]\([0-9][0-9]*\)[^0-9\/]*$'/'\1'/` \
			> rdf/`echo $target | sed -e s/'.xml$'//`.rdf;
			if [ ! -s rdf/`echo $target | sed -e s/'.xml$'//`.rdf ]; then echo empty 1>&2; rm rdf/`echo $target | sed -e s/'.xml$'//`.rdf;
			else zip -rm `echo $file |sed s/'xml'/'rdf'/g` rdf/`echo $target | sed -e s/'.xml$'//`.rdf;
			fi;
			echo 1>&2;
		done;
	fi;
done;

rm -rf rdf;
for file in src/*rdf.zip; do
	if [ -e $file ] ; then mv $file .; fi;
done;



		# # TSV generation
		# for file in *ttl; do
			# tgt=`echo $file | sed s/'\.ttl$'/'.tsv'/;`
			# echo $file': TSV export' 1>&2; 
			# if [ -e $tgt ] ; then 
				# echo 'skipping: found '$tgt 1>&2;
			# else if [ -e $tgt.gz ] ; then
				# echo 'skipping: found '$tgt.gz 1>&2;
			# else
				# $ARQ --data=$file \
					# --query=../../ontolex2tsv.sparql --results=TSV | grep -v '^?' | sort -u > $tgt;
			# fi;fi;
		# done;
		
		# cd ..;

	# done;

	# gzip -f */*.ttl;
	# gzip -f */*.tsv;

	# cd ..;

