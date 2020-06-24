#!/bin/bash
# retrieve latest wikidata dump and extract lexemes
# note that we do not overwrite the current dump if it already exists

GZ=latest-lexemes.ttl.gz
SRC=https://dumps.wikimedia.org/wikidatawiki/entities/$GZ

##############
# (0) CONFIG # and preprocessing
##############
# adjust to your system and preferences

# Apache Jena, retrieve from https://jena.apache.org
RIOT=riot
ARQ=arq

# extraction pattern for bilingual dictionary
# (skip inflected forms)
PROPS='wikibase:lemma|ontolex:sense|wdt:P5137|wikibase:lexicalCategory'
# wikibase:lemma: canonical form, ontolex:representation: all forms (incl. features)
PROPS=`echo $PROPS |\
	sed -e s/'ontolex:'/'http:\/\/www.w3.org\/ns\/lemon\/ontolex#'/g \
		-e s/'wikibase:'/'http:\/\/wikiba.se\/ontology#'/g \
		-e s/'wdt:'/'http:\/\/www.wikidata.org\/prop\/direct\/'/g`

############################
# (1) prep lexinfo mapping #
############################

# lexinfo replacement rules for objects of wikibase:lexicalCategory

if [ -e lexCats.sed ] ; then
	if [ lexCats.txt -nt lexCats.sed ] ; then rm lexCats.sed ; fi;
fi;

if [ -e lexCats.sed ] ; then
	echo lexCats.sed found 1>&2;
else
	egrep -v '^#' lexCats.txt | \
	cut -f 2,4 | grep -v '_' | \
	perl -pe '
		s/^([^\s][^\s]*)\t([^\s][^\s]*)$/s\/$1\/$2\/g;/g;
		s/\/wd:/\/http:\\\/\\\/www.wikidata.org\\\/entity\\\//g;
		s/\/lexinfo:/\/http:\\\/\\\/www.lexinfo.net\\\/ontology\\\/2.0\\\/lexinfo\#/g;' \
	> lexCats.sed
fi;

EXTRACT=`echo $GZ | sed -e s/'\.gz$'// -e s/'\.ttl$'//`.extract.ttl
if [ -e $EXTRACT ] ; then 
	echo found $EXTRACT, keeping it 1>&2;
else
	#################
	# (2) retrieval #
	#################
	echo -n $GZ' ' 1>&2;
	if [ -e $GZ ]; then
		echo found 1>&2
	else 
		echo 'retrieval from '$SRC 1>&2;
		wget -nc $SRC
	fi;

	##################
	# (3) extraction #
	##################
	$RIOT --out ntriples $GZ | \
	# restrict to prefiltered properties
	egrep $PROPS | \
	# skip non-standard language tags
	egrep -v '"@[a-z]*\-x\-Q[^"]*' | \
	# lexinfo mapping
	sed -f lexCats.sed > $EXTRACT
fi;

##########################
# (4) TSV transformation #
##########################
TSV=`echo $EXTRACT |sed s/'\.extract\.ttl$'//`.out.tsv;
if [ -e $TSV ]; then
	echo found $TSV, keeping it 1>&2;
else
	$ARQ --data=$EXTRACT --query=ontolex2tsv.sparql  --results=TSV | grep -v '^?' > $TSV
fi;

###################################
# (5) split TSV into sublanguages #
###################################
LANGS=`cut -f 1 $TSV | grep '@' | sed s/'.*@'// | sort -u | grep -v 'mis' | grep -i -v '\-x\-q' | sed s/'\-.*'//g | sort -u`
echo $LANGS
OUT=wikidata-tsv-`date +%F`
for src in $LANGS; do
	mkdir -p $OUT/$src;
	for tgt in $LANGS; do
		if [ $src != $tgt ]; then
			echo -n extracting translations from $src to $tgt' ' 1>&2;
			egrep '@'$src'[^a-z].*@'$tgt'[^a-z]' $TSV > $OUT/$src/$src-$tgt.tsv;
			if [ -e $OUT/$src/$src-$tgt.tsv ]; then
				if [ ! -s $OUT/$src/$src-$tgt.tsv ]; then
					echo -n failed': ' 1>&2;
					cat $OUT/$src/$src-$tgt.tsv | wc -l 1>&2;
					rm $OUT/$src/$src-$tgt.tsv;
				else 
					echo -n ok': ' 1>&2;
					cat $OUT/$src/$src-$tgt.tsv | wc -l 1>&2;
				fi;
			fi;
		fi;
	done;
	rmdir $OUT/$src >&/dev/null
done;
rm -rf $OUT/mis*/ $OUT/*/*-mis*tsv; # uncoded language