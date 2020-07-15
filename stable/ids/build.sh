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

# current version of ISO 639-3
ISO639P3=iso-639-3_Latin1_Code_Tables_20200130.zip

############
# RETRIEVE #
############

# IDS data
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


# glottolog links
if [ ! -e glottolog2bcp47.ttl ] ; then
	if [ ! -e glottolog2iso.ttl ] ; then
		if [ ! -e tree ]; then
			echo retrieve glottolog 1>&2; 
			svn co https://github.com/LinguList/glottolog.git/trunk/languoids/tree
		fi;
		
		echo map glottolog to ISO 639-3 1>&2;
		(
			cd tree;
			echo 'PREFIX skos: <http://www.w3.org/2004/02/skos/core#>';
			echo 'PREFIX owl: <http://www.w3.org/2002/07/owl#>';
			echo 'PREFIX glottolog: <https://glottolog.org/resource/languoid/id/>';
			echo 'PREFIX sil: <https://iso639-3.sil.org/code/>';
			echo 'PREFIX lexvo: <http://lexvo.org/id/iso639-3/>';
			
			(find | grep 'md.ini$' | sed s/'\/md.ini$'// | \
			 perl -pe '
				s/^[^a-z]+//g;
				while(m/.*\/.*/) {
					s/([^\/\s:]+)\/([^\/\s:]+)/glottolog:$2 skos:broader glottolog:$1 .\n$2/;
				};
				s/\n+/\n/g;' | grep 'skos:broader';
			 egrep '^\s*iso639-3\s*=' `find | grep 'md.ini$'` | \
				#tree/atla1278/volt1241/nort3149/came1255/uban1244/sere1265/sere1262/sere1266/sere1263/baiv1238/baii1251/md.ini:iso639-3 = bdj
				perl -pe 's/.*\/([a-z]+[0-9]+)\/md.ini:.*=\s*([a-zA-Z]+)\s*$/glottolog:$1 owl:sameAs sil:$2, lexvo:$2 .\n/;'
			) | sort -u
		) \
		> glottolog2iso.ttl
	fi;

# ISO 639-3 to ISO 639-1 mapping
	if [ ! -e sil2lexvo1.ttl ]; then
		if [ ! -e $ISO639P3 ]; then
			wget https://iso639-3.sil.org/sites/iso639-3/files/downloads/$ISO639P3
		fi;
		echo map ISO 639-3 to BCP47 1>&2
		(
			echo 'PREFIX owl: <http://www.w3.org/2002/07/owl#>';
			echo 'PREFIX sil: <https://iso639-3.sil.org/code/>';
			echo 'PREFIX lexvo1: <http://lexvo.org/id/iso639-1/>';
			unzip -c $ISO639P3 */*_Latin1*.tab | cut -f 1,4 | egrep '^[a-z].*\s[a-z]' | \
			perl -pe 's/^([a-z]+)\s+([a-z][a-z])\s*$/sil:$1 owl:sameAs lexvo1:$2 .\n'/ | grep ':'
		) > sil2lexvo1.ttl;
	fi;
	$ARQ --data=glottolog2iso.ttl --data=sil2lexvo1.ttl --query=glottolog2bcp47.sparql > glottolog2bcp47.ttl
fi;

###########
# CSV2RDF #
###########
if [ ! -e ids-reduced.ttl.gz ]; then
	if [ ! -e ids-reduced.ttl ] ; then
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
		egrep 'http://cldf.clld.org/v1.0/terms.rdf#(name|parameterReference|form|alt_form|alt_transcription|languageReference|glottocode|iso639P3code)|http://purl.org/dc/(elements/1.1/|terms/)|http://www.w3.org/ns/lemon/' > ids-reduced.ttl;
	fi;
	gzip ids-reduced.ttl
fi;

if [ -d ontolex ]; then
	echo found ontolex/, not updating 1>&2;
else
	if [ -d split ]; then

		echo -n found split/ with ' ' 1>&2
		ls split/* | wc -l 1>&2
		echo ' files, not updating' 1>&2;

	else

		#############
		# splitting #
		#############
		# using the URI schema
		# e.g., http://ids.clld.org/values/22-470-194-3:
		# 22-470 => parameter <http://ids.clld.org/parameters/22-470>
		# 194 => language <http://ids.clld.org/languages/194>
		# 3 => number of lexical entry ? (not every number does exist)
		gunzip ids-reduced.ttl.gz;
		mkdir split;
		egrep -v '^<http://ids.clld.org/values/' ids-reduced.ttl > split/header.ttl;
		for lang in {25..999}; do
			if egrep -m 1 '^<http://ids.clld.org/values/[0-9]*-[0-9]*-'$lang'-[0-9]*>' ids-reduced.ttl >&/dev/null; then
				echo split '>' split/$lang.ttl 1>&2;
				cp split/header.ttl split/$lang.ttl;
				egrep '<http://ids.clld.org/values/[0-9]*-[0-9]*-'$lang'-' ids-reduced.ttl >> split/$lang.ttl;
			fi;
		done;
		rm split/header.ttl;
		gzip ids-reduced.ttl;
	fi;

	#################
	# OntoLex-Lemon # (single file, includes creation of language tags)
	#################

	mkdir ontolex;
	for file in split/*.ttl; do
		tgt=ontolex/`echo $file | sed -e s/'.*\/'//g`;
		echo 'OntoLex conversion: ' $file ' > ' $tgt 1>&2;
		$ARQ --data=$file --data=glottolog2bcp47.ttl --query=ids2lemon.sparql > $tgt;
	done;
fi;

if [ ! -d tsv ] ; then
	############
	# TIAD-TSV #
	############
	mkdir tsv;
fi;

# aggregate information per language
if [ -e tmp ]; then
	echo using aggregated dictionaries in tmp, not updating 1>&2;
else
	mkdir tmp;
	for file in `egrep -l -m 1 'writtenRep.*"@' ontolex/*.ttl`; do
		lang=`egrep -m 1 'writtenRep.*"@' $file |sed s/'.*@\([a-z][a-z]*\)[^a-z].*'/'\1'/`; 	# only the primary language code
		if [ $lang != 'mis' ] ;then
			if [ $lang != 'x' ]; then
				echo aggregate information on $lang'  ' 1>&2;
				if [ ! -e tmp/$lang.ttl ]; then 
					cp $file tmp/$lang.ttl;
				else 
					cat $file >> tmp/$lang.ttl
				fi;
			fi;
		fi;
	done;
fi;

for file1 in tmp/*.ttl; do
	lang1=`echo $file1 | sed s/'.*\/\([a-z][a-z]*\)\.ttl'/'\1'/`;
	if [ -e tsv/$lang1.zip ]; then
		echo found tsv/$lang1.zip, skipping 1>&2;
	else
		if [ ! -e tsv/$lang1 ] ; then mkdir tsv/$lang1 ;fi
		rapper -i turtle $file1 | sed s/'\.[ \t]*$'/' <http:\/\/ids.clld.org\/SOURCE> .'/ > tsv/tmp.nq;
		for file2 in tmp/*ttl; do
			lang2=`echo $file2 | sed s/'.*\/\([a-z][a-z]*\)\.ttl'/'\1'/`;
				if [ $lang1 != $lang2 ] ;then
					if [ ! -e tsv/$lang2.zip ]; then
						if [ ! -e tsv/$lang1/$lang1-$lang2.tsv ]; then
							echo TIAD-TSV export: $lang1 $lang2 1>&2;
							$ARQ --data=$file2 --data=tsv/tmp.nq --query=ontolex2tsv.sparql	--results=TSV | grep -v '^?' >> tsv/$lang1/$lang1-$lang2.tsv
							sort -o -u tsv/$lang1/$lang1-$lang2.tsv tsv/$lang1/$lang1-$lang2.tsv
						fi;
					fi;
				fi;
		done;
		rm tsv/tmp.nq;
		for file in tsv/$lang1/*tsv; do	# remove empty files
			if [ ! -s $file ]; then rm $file; fi;
		done;
		zip -rm tsv/$lang1.zip tsv/$lang1
	fi;
done;