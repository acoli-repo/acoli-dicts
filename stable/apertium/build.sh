#!/bin/bash
# builds OntoLex-lemon dictionaries from Apertium Bidix

# (c) 2019-02-03 Christian Chiarcos, christian.chiarcos@web.de
# 2020-03-\d{2} Max Ionov, max.ionov@gmail.com
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
# my configuration
# Jena:       VERSION: 3.9.0
# Jena:       BUILD_DATE: 2018-09-28T17:15:32+0000
# ARQ:        VERSION: 3.9.0
# ARQ:        BUILD_DATE: 2018-09-28T17:15:32+0000
# RIOT:       VERSION: 3.9.0
# RIOT:       BUILD_DATE: 2018-09-28T17:15:32+0000

#################
# DO NOT CHANGE #
#################
# (unless you know what you do)

SRC=https://github.com/apertium/apertium-trunk.git;

##########################################
# (1) clone the language pairs into src/ #
##########################################

mkdir -p src;
cd src;

# This works for me, it's better to replace svn checkout with this line (MI 2020-02-23)
git clone --recurse-submodules --shallow-submodules --depth 1 git@github.com:apertium/apertium-trunk.git
DIXPATH='/apertium-trunk/apertium-[^/]+/apertium-(.+)-(.+).\1-\2.dix$';
## (defined under https://github.com/apertium/apertium-trunk) FAILED
# git clone --recurse-submodules --shallow-submodules --depth 1 https://github.com/apertium/apertium-trunk.git
## recursion FAILED

# --- uncomment this if you comment `git clone ... git@github...` line`
# svn checkout $SRC;
# for url in `cat apertium-trunk.git/trunk/.gitmodules | grep url | sed s/'.*='//g; `; do
# 	#echo $url;
# 	url=`echo $url | sed s/'.*:'/'https:\/\/github.com\/'/g;`;
# 	echo $url 1>&2;
# 	svn checkout $url;
# done;
# DIXPATH='/trunk/apertium-(.+)-(.+).\1-\2.dix$';
# --- end uncomment ---

cd ..;

###########################################
# (2) copy all language pairs into langs/ #
###########################################
# cf. naming conventions in http://wiki.apertium.org/wiki/Bidix

mkdir -p langs/;
cd langs/;
for pair in `find ../src/ | egrep $DIXPATH;`; do
	ln -s $pair . &
done;
sleep 1;
cd ..

###################################
# (3) bootstrap apertium ontology #
###################################

./bootstrap-apertium-ontology.py langs/*.dix

#################################
# (4) get language code mapping #
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
sed s/'\(...\)[[:blank:]]\(...*\)'/"s\/\\\\(\[\\-\\.\]\\\\)\2\\\\(\[\\-\\.\]\\\\)\/\\\\1\1\\\\2\/g"/ > lang2iso-3.sed;

cat lang2iso-3.tsv | egrep '\s..$' | \
sed s/'\(...\)[[:blank:]]\(..\)$'/"s\/\\\\(\[\\-\\.\]\\\\)\1\\\\(\[\\-\\.\]\\\\)\/\\\\1\2\\\\2\/g"/ > iso-3-to-bcp47.sed;
cd ..

###################################
# (5) apply language code mapping #
###################################

# map to bcp-47 (iso-1 where applicable, iso-3 otherwise) 
for file in langs/*; do
	tgt=`echo $file | sed -f sed/lang2iso-3.sed | sed -f sed/iso-3-to-bcp47.sed`;
	if [ $file != $tgt ]; then mv $file $tgt; fi;
done;

######################
# (6) RDF conversion # and TSV extraction
######################
RELEASE=apertium-rdf-`date +%F`;
mkdir -p $RELEASE;

for file in langs/*; do
	srclang=`echo $file | sed s/'.*\/apertium-\([^\-\.]*\)-.*'/'\1'/g;`;
	tgtlang=`echo $file | sed s/'.*\/apertium-[^\-\.]*-\([^\-\.]*\)\..*'/'\1'/g;`;
	SRCLANG=`echo $srclang | tr [a-z] [A-Z]`; # sed s/'.*'/'\U&'/g;`; # OS X compatibility
	TGTLANG=`echo $tgtlang | tr [a-z] [A-Z]`; # sed s/'.*'/'\U&'/g;`;
	DIR=$RELEASE/apertium-$srclang-$tgtlang-rdf;
	echo creating $DIR 1>&2;
	mkdir -p $DIR;
	origfile=`ls -l $file | sed s/'.*\-> *\.\.\/'//g;`;
	if [ $OSTYPE = cygwin ]; then
		origfile=`cygpath -w $origfile;`;
		origfile=`echo $origfile | sed s/'\\'/'\\\/'/g;`
	fi;
	$SAXON -s:$origfile -xsl:dix2src-ttl.xsl LANG=$SRCLANG dc_source=$SRC | sed s/$'\r'//g > $DIR/Apertium-$srclang-${tgtlang}_Lexicon$SRCLANG.ttl
	$SAXON -s:$origfile -xsl:dix2tgt-ttl.xsl LANG=$TGTLANG dc_source=$SRC | sed s/$'\r'//g > $DIR/Apertium-$srclang-${tgtlang}_Lexicon$TGTLANG.ttl;
	$SAXON -s:$origfile -xsl:dix2trans-ttl.xsl SRC_LANG=$SRCLANG TGT_LANG=$TGTLANG dc_source=$SRC | sed s/$'\r'//g > $DIR/Apertium-$srclang-${tgtlang}_TranslationSet$SRCLANG-$TGTLANG.ttl
	
	## I had some broken pipes on cygwin with larger files
	# cat $file | saxon -s:- -xsl:dix2src-ttl.xsl LANG=$SRCLANG dc_source=$SRC > $DIR/Apertium-$srclang-${tgtlang}_Lexicon$SRCLANG.ttl
	# cat $file | saxon -s:- -xsl:dix2tgt-ttl.xsl LANG=$TGTLANG dc_source=$SRC > $DIR/Apertium-$srclang-${tgtlang}_Lexicon$TGTLANG.ttl;
	# cat $file | saxon -s:- -xsl:dix2trans-ttl.xsl SRC_LANG=$SRCLANG TGT_LANG=$TGTLANG dc_source=$SRC > $DIR/Apertium-$srclang-${tgtlang}_TranslationSet$SRCLANG-$TGTLANG.ttl;

	$ARQ --data=$DIR/Apertium-$srclang-${tgtlang}_Lexicon$SRCLANG.ttl \
		--data=$DIR/Apertium-$srclang-${tgtlang}_Lexicon$TGTLANG.ttl \
		--data=$DIR/Apertium-$srclang-${tgtlang}_TranslationSet$SRCLANG-$TGTLANG.ttl \
		--query=ontolex2tsv.sparql --results=TSV | grep -v '^?' > $RELEASE/trans_$SRCLANG-$TGTLANG.tsv;
	gzip $RELEASE/trans_$SRCLANG-$TGTLANG.tsv
	# rm $DIR.tmp.ttl;
	cd $DIR;
	zip -m ../../$DIR.zip *;
	cd - >&/dev/null;
	rmdir $DIR;
done;

################
# (7) metadata #
################

cd src;
(date +%F;
echo "OntoLex-lemon conversion of Apertium Bidix";
echo "by Christian Chiarcos, christian.chiarcos@web.de and Maxim Ionov, max.ionov@gmail.com";
echo "Applied Computational Linguistics (ACoLi) lab, Goethe-Universität Frankfurt am Main, Germany";
echo
# both options: for SVN and for Git checkout
for dir in *; do if [ -e $dir/trunk/AUTHORS ]; then echo $dir; cat $dir/trunk/AUTHORS; echo; fi; done) > ../AUTHORS
for dir in apertium-trunk/*; do if [ -e $dir/AUTHORS ]; then echo ${dir/apertium-trunk\//}; cat $dir/AUTHORS; echo; fi; done >> ../AUTHORS
cd ..;

cp LICENSE_DATA $RELEASE/COPYING;
cp AUTHORS $RELEASE;

