#!/bin/bash
# retrieve FreeDict dictionaries and provide an Ontolex-lemon edition

# (c) 2019-02-04 Christian Chiarcos, christian.chiarcos@web.de
# Apache License 2.0, see https://www.apache.org/licenses/LICENSE-2.0

##########
# CONFIG #
##########

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

#############################
# (1) retrieve source files #
#############################

mkdir -p src;
cd src;
DICTS=`wget -O - https://freedict.org/downloads/index.html | \
	sed s/'"'/'\n'/g | grep 'src.tar.xz$'`;
for dict in $DICTS; do
	wget -nc $dict;
done;
for dict in *.tar.xz; do
	tar -xvf $dict;
done;
cd ..;

#################################
# (2) get language code mapping #
#################################
# map to iso-639-3, resp. iso-639-1 (where applicable)

mkdir -p sed;
cd sed;
wget -nc https://iso639-3.sil.org/sites/iso639-3/files/downloads/iso-639-3_Code_Tables_20190125.zip;
unzip -c iso-639-3_Code_Tables_20190125.zip iso-639-3_Code_Tables_20190125/iso-639-3_20190125.tab | \
egrep '^[a-z]' | \
perl -pe 'while(m/^(...)[ \t]+([a-z][a-z]([a-z]?))[ \t][^\n]*/) {
	s/^(...)[ \t]+([a-z][a-z]([a-z]?))([ \t][^\n]*)/$1\t$4\n$1\t$2/;
	};
	s/[ \t]+/\t/g;
	' | \
egrep '^[a-z]..\s[a-z]' | \
egrep -v '^(...)\s\1$' | tee lang2iso-3.tsv | \
sed s/'\(...\)\s\(...*\)'/"s\/\\\\\/\2\\\\-\/\\\\\/\1\\\\-\/g\ns\/\\\\-\2\\\\\/\/\\\\-\1\\\\\/\/g"/ > lang2iso-3.sed;


cat lang2iso-3.tsv | egrep '\s..$' | \
sed s/'\(...\)\s\(..\)'/"s\/\\\\\/\1\\\\-\/\\\\\/\2\\\\-\/g\ns\/\\\\-\1\\\\\/\/\\\\-\2\\\\\/\/g"/ > iso-3-to-bcp47.sed;
cd ..

###################################
# (3) apply language code mapping #
###################################

# map to bcp-47 (iso-1 where applicable, iso-3 otherwise) 
for dir in src/*/; do
	tgt=`echo $dir | sed -f sed/lang2iso-3.sed | sed -f sed/iso-3-to-bcp47.sed`;
	rm -rf $tgt;
	if [ $dir != $tgt ]; then 
		echo $dir' => '$tgt 1>&2;
		mv $dir $tgt; 
	fi;
done;

#############################################
# (4) convert to ontolex-lemon and TIAD-TSV #
#############################################

RELEASE=freedict-rdf-`date +%F`;
mkdir -p $RELEASE;
for dir in src/*/; do
	echo $dir ' => ' $RELEASE 1>&2;
	cp -r -f $dir $RELEASE/;
done;

cd $RELEASE;
for dir in *-*/; do
	echo $dir': OntoLex generation' 1>&2; 
	srclang=`echo $dir | sed -e s/'-.*'//g;`
	tgtlang=`echo $dir | sed -e s/'.*-'//g -e s/'\/$'//;`
	cd $dir;
	
	mkdir -p tei;
	mv -f *.tei *css *dtd *rng *xml Makefile INSTALL tei;
	for file in *; do
		if [ -f $file ]; then cp -f $file tei; fi;
	done;
	if [ -e lexicon-$srclang-$tgtlang.ttl ]; then
		echo found lexicon-$srclang-$tgtlang.ttl, skipping 1>&2;
	else if [ -e lexicon-$srclang-$tgtlang.ttl.gz ]; then
		echo found lexicon-$srclang-$tgtlang.ttl.gz, skipping 1>&2;
	else 
		rm -f *.ttl *.ttl.gz;
		for file in tei/*.tei; do
			if [ ! -e tei/*dtd ] ; then
				for dtd in `find .. | egrep -m 1 '\.dtd$'`; do	# missing for wo-fr
					echo restore original DTD 1>&2;
					cp -f $dtd tei/;
				done;
			fi;
			$SAXON -warnings:recover -s:$file -xsl:../../freedict2ontolex.xsl SRC_LANG=$srclang TGT_LANG=$tgtlang >> lexicon-$srclang-$tgtlang.ttl;
		done;
		
		(echo 'Christian Chiarcos <christian.chiarcos@web.de>:'
		echo '  converted to OntoLex-lemon') >> AUTHORS
		
		(
		echo `date +%F` 'Christian Chiarcos <christian.chiarcos@web.de>';
		echo '  * conversion to OntoLex-lemon';
		echo;
		if [ -e tei/ChangeLog ] ; then
			cat tei/ChangeLog;
		fi;
		) > ChangeLog;
	
		zip -rm lexicon-$srclang-$tgtlang.tei.zip tei/; 
	fi;fi;

	# TSV generation
	for file in *ttl; do
		tgt=`echo $file | sed s/'\.ttl$'/'.tsv'/;`
		echo $file': TSV export' 1>&2; 
		if [ -e $tgt ] ; then 
			echo 'skipping: found '$tgt 1>&2;
		else if [ -e $tgt.gz ] ; then
			echo 'skipping: found '$tgt.gz 1>&2;
		else
			$ARQ --data=$file \
				--query=../../ontolex2tsv.sparql --results=TSV | grep -v '^?' | sort -u > $tgt;
		fi;fi;
	done;
	
	cd ..;

done;

gzip -f */*.ttl;
gzip -f */*.tsv;

cd ..;