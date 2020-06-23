#!/bin/bash
# retrieve MUSE dictionaries and provide an Ontolex-lemon edition

# (c) 2020-06-11 Christian Chiarcos, christian.chiarcos@web.de
# Apache License 2.0, see https://www.apache.org/licenses/LICENSE-2.0
# data keeps original license CC-BY-NC 4.0 International

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

URL=https://dl.fbaipublicfiles.com/arrival/dictionaries/

# mkdir -p src;
# cd src;
# DICTS=`wget -O - https://github.com/facebookresearch/MUSE | \
	# sed s/'"'/'\n'/g | \
	# egrep $URL".*[a-z].txt"`;
# for dict in $DICTS; do
	# wget -nc $dict;
# done;
# cd ..;

#################################
# (2) get language code mapping #
#################################
# already iso-639-1, no mapping necessary

#############################################
# (3) convert to ontolex-lemon and TIAD-TSV #
#############################################
# note that MUSE has no lexical entries, but only form-level relations
# we assume all identical forms to constitute a single lexical entry

TMP=$0.tmp;
while [ -e $TMP ] ;	do
	TMP=$0.`ls $0* | wc -l`.tmp;
done
echo > $TMP;

RELEASE=muse-rdf-`date +%F`;

mkdir -p $RELEASE;
for src in src/*-*txt; do
	file=`echo $src|sed -e s/'.*\/'//g`;
	srclang=`echo $file | sed s/'^\([a-z][a-z]*\)-[^\/]*$'/'\1'/g`;
	tgtlang=`echo $file | sed s/'^\([a-z][a-z]*\)-\([a-z][a-z]*\)\.[^\/]*$'/'\2'/g`;
	srcdict=$URL$srclang;
	tgtdict=$URL$tgtlang;
	translationset=$URL$file;
	
	file=$RELEASE/`echo $file | sed s/'\.[^\.]*$'//`.ttl;
	
	if [ -e $file ]; then echo found $file, skipping 1>&2;
	else echo building $file 1>&2;
		(
		
		# resolvable (!) RFC5147 URIs to translations (https://tools.ietf.org/html/rfc5147)
		# Note: that this points to the position at the beginning of the line rather than the full like
		echo "@prefix : <"$URL`echo $src | sed s/'.*\/'//g`"#line=> .";	
		
		# pseudo-URIs for src and tgt, trying to access these will produce an access denied error -- semantically not incorrect ;)
		echo "@prefix src: <"$URL$srclang"/> .";					
		echo "@prefix tgt: <"$URL$tgtlang"/> .";
		
		echo "@prefix iso639_1: <http://id.loc.gov/vocabulary/iso639-1/> .";
		echo "@prefix ontolex: <http://www.w3.org/ns/lemon/ontolex#> .";
		echo "@prefix vartrans: <http://www.w3.org/ns/lemon/vartrans#> .";
		echo "@prefix lime: <http://www.w3.org/ns/lemon/lime#> .";
		echo "@prefix dct: <http://purl.org/dc/terms/>.";
		echo ;
		
		echo "<"$translationset"> a vartrans:TranslationSet .";
		echo "<"$srcdict"> a lime:Lexicon; lime:language \""$srclang"\"; dct:language iso639_1:"$srclang" .";
		echo "<"$tgtdict"> a lime:Lexicon; lime:language \""$tgtlang"\"; dct:language iso639_1:"$tgtlang" .";
		echo ;
		
		# TSV2TTL using perl
		# note: if URI::Escape is missing, then
		# $> perl -MCPAN -e shell
		# $> install URI::Escape
		
		cat $src | \
		perl -e '
			use URI::Escape;
			
			my $line=0;
			while(<>) {
				s/[\r\n]+//g;
				my $src=$_; $src=~s/[\t ]+.+//;
				my $tgt=$_; $tgt=~s/.+[\t ]+//;
				my $src_entry="src:".uri_escape($src);
				my $tgt_entry="tgt:".uri_escape($tgt);
				my $translation=":".$line;
				my $src_form=$src_entry."_form";
				my $tgt_form=$tgt_entry."_form";
				$line=$line+1;
				print "<'$srcdict'> lime:entry ".$src_entry." . ";
				print $src_entry." a ontolex:LexicalEntry; ontolex:lexicalForm ".$src_form." .\n";
				print $src_form." a ontolex:Form; ontolex:writtenRep \"\"\"".$src."\"\"\"\@'$srclang' .\n";
				print "<'$tgtdict'> lime:entry ".$tgt_entry." . ";
				print $tgt_entry." a ontolex:LexicalEntry; ontolex:lexicalForm ".$tgt_form." .\n";
				print $tgt_form." a ontolex:Form; ontolex:writtenRep \"\"\"".$tgt."\"\"\"\@'$tgtlang' .\n";
				print $src_entry." vartrans:translatableAs ".$tgt_entry." .\n";
				print "<'$translationset'> vartrans:trans $translation . ";
				print $translation." a vartrans:LexicalRelation; vartrans:source ".$src_entry."; vartrans:target ".$tgt_entry." .\n\n";
			}
		'
		) | \
		rapper -i turtle - -I $URL | \
		# enable next line for debugging
		# head -n 1000 | \
		tee $TMP | \
		#
		# retrieve translationset
		grep '<'$translationset | \
		sort -u | \
		rapper -i turtle -o turtle - -I $URL \
		-f 'xmlns:ontolex="http://www.w3.org/ns/lemon/ontolex#"' \
		-f 'xmlns:vartrans="http://www.w3.org/ns/lemon/vartrans#"' \
		-f 'xmlns:lime="http://www.w3.org/ns/lemon/lime#"' \
		-f 'xmlns:dct="http://purl.org/dc/terms/"' \
		> $file;
		
		# retrieve dictionaries
		(if [ -e $RELEASE/$srclang.ttl ] ; then
			rapper -i turtle $RELEASE/$srclang.ttl
			#BAK=$RELEASE/$srclang.ttl.`ls $RELEASE/$srclang.ttl* | wc -l`
			#cp $RELEASE/$srclang.ttl $BAK
		fi;
		egrep '^[^\s]*<'$srcdict'[>#/]' $TMP ) | \
		sort -u | \
		rapper -i turtle -o turtle - -I $URL \
		-f 'xmlns:ontolex="http://www.w3.org/ns/lemon/ontolex#"' \
		-f 'xmlns:vartrans="http://www.w3.org/ns/lemon/vartrans#"' \
		-f 'xmlns:lime="http://www.w3.org/ns/lemon/lime#"' \
		-f 'xmlns:dct="http://purl.org/dc/terms/"' \
		> $RELEASE/$srclang.ttl;
		
		(if [ -e $RELEASE/$tgtlang.ttl ] ; then
			rapper -i turtle $RELEASE/$tgtlang.ttl;
			#BAK=$RELEASE/$tgtlang.ttl.`ls $RELEASE/$tgtlang.ttl* | wc -l`
			#cp $RELEASE/$tgtlang.ttl $BAK
		fi;
		egrep '^[^\s]*<'$tgtdict'[>#/]' $TMP ) | \
		sort -u | \
		rapper -i turtle -o turtle - -I $URL \
		-f 'xmlns:ontolex="http://www.w3.org/ns/lemon/ontolex#"' \
		-f 'xmlns:vartrans="http://www.w3.org/ns/lemon/vartrans#"' \
		-f 'xmlns:lime="http://www.w3.org/ns/lemon/lime#"' \
		-f 'xmlns:dct="http://purl.org/dc/terms/"' \
		> $RELEASE/$tgtlang.ttl;
		
		echo > $TMP;
		
		echo 1>&2;
		wc -l $RELEASE/* 1>&2;
		echo 1>&2;
		
		for file in $RELEASE/*; do echo -n $file' '; egrep 'LexicalEntry|LexicalRelation' $file |wc -l ; done 1>&2;
		echo 1>&2;

	fi;
done;
rm $TMP;

TSV=muse-tsv-`echo $RELEASE | sed s/'^[^0-9]*-'//`
mkdir -p $TSV 1>&2;

cd $RELEASE
for file in *-*ttl; do
	SRC=`echo $file | sed s/'\-.*'//`;
	TGT=`echo $file | sed s/'.*\-\([a-z][a-z]*\)\..*'/'\1'/`;
	#echo $file $SRC $TGT 1>&2
	OUT=../$TSV/$SRC-$TGT.tsv
	if [ -s $OUT ]; then
		echo 'skipping: found '$OUT 1>&2;
	else
		echo $RELEASE/$file': TSV export' 1>&2; 
		$ARQ --data=$file --data=$SRC.ttl --data=$TGT.ttl \
				--query=../ontolex2tsv.sparql --results=TSV | grep -v '^?' | sort -u > $OUT
	fi;
done;

cd - >&/dev/null;