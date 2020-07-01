#!/bin/bash
# retrieves up-to-date intercontinental dictionary series data
# for refresh, delete the src folder

SRC=https://ids.clld.org/download

##########
# CONFIG #
##########
# adjust to your system

# set to your TARQL installation (and/or install from https://github.com/tarql/tarql/releases)
TARQL=tarql

# Apache Jena installation, set to ARQ executable
ARQ=arq

############
# RETRIEVE #
############

if [ -e src ]; then
	echo found src, skipping retrieval 1>&2
else
	mkdir src;
	cd src;
	wget -O - $SRC > index.html;
	URL=`
		cat index.html | \
		perl -pe 's/\s+/ /g; s/</\n</g; s/>/>\n/g;' | \
		egrep '<a[ \t]'| \
		sed -e s/'\s'/'\n'/g | grep 'href=' | \
		sed -e s/'"'/'\n'/g | egrep 'zip$'`;
	echo retrieve $URL 1>&2;
	wget $URL;
	if echo $URL | grep 'zip$' >&/dev/null; then 
		unzip $URL;
	fi;
	cd ..
fi;

# check also
# https://github.com/concepticon/concepticon-data/archive/v2.3.0.zip for WordNet links

###########
# CSV2RDF #
###########
if [ -e ids-reduced.ttl.gz ]; then
	gunzip -c ids-reduced.ttl.gz
else
	if [ -e ids.ttl.gz ]; then
		gunzip -c ids.ttl.gz;
	else
		(
			# prefixes
			cat header.ttl;

			# lexicon metadata
			echo -n '<'$SRC'> a lime:Lexicon '
			egrep 'dc:|dcat:' src/Wordlist-metadata.json | grep -v 'conformsTo' | \
			perl -pe '
				s/[\r\n]//g;
				s/^\s*"([^"]+)"\s*:\s*/;\n   \1 /g;
				s/,\s*//g;
			';
			echo " .";

			# individual tables
			cd src;
			for file in *csv; do
				sparql=../`echo $file | sed s/'\.csv$'//`.sparql;
				if [ -e $sparql ]; then
					tarql $sparql $file
				fi;
			done;
			cd .. >&/dev/null

			# jq '.tables[]|select(.url=="forms.csv").tableSchema[]|values[].propertyUrl' src/Wordlist-metadata.json
			# jq '.tables[]|select(.url=="forms.csv").tableSchema[]|keys' src/Wordlist-metadata.json
			
			#####################
			# TODO: BCP47 codes # (instead of ISO639-3)
			#####################
			
		) | \
		tee ids.ttl;
		gzip ids.ttl
	fi | \
	\
	###########
	# pruning #
	###########
	\
	# conversion to ntriples
	rapper -i turtle - $SRC'#' | \
	\
	# prune
	egrep 'http://cldf.clld.org/v1.0/terms.rdf#(name|parameterReference|form|alt_form|alt_transcription|languageReference|glottocode|iso639P3code)|http://purl.org/dc/(elements/1.1/|terms/)|http://www.w3.org/ns/lemon/' | tee ids-reduced.ttl;
	gzip ids-reduced.ttl
fi | \
\
#################
# OntoLex-Lemon # (single file)
#################
ARQ --data=- --query=ids2ontolex.sparql > ids.tsv
# fails with out of memory exception under ARQ and BlazeGraph

############
# TIAD-TSV #
############
# TODO