#!/bin/bash
# retrieve Open Multilingual WordNet files in TSV format, generate an OntoLex-Lemon version

##########
# CONFIG #
##########

# original OMW dump in one archive
SRC=http://compling.hss.ntu.edu.sg/omw/all.zip

# set to your TARQL installation (and/or install from https://github.com/tarql/tarql/releases)
TARQL=tarql

# Apache Jena installation, set to ARQ executable
ARQ=arq

# current version of ISO 639-3
ISO639P3=iso-639-3_Latin1_Code_Tables_20200130.zip

########
# Prep #
########

# ISO 639-3 to ISO 639-1 mapping
	if [ ! -e sil2lexvo1.sed ]; then
		if [ ! -e $ISO639P3 ]; then
			wget https://iso639-3.sil.org/sites/iso639-3/files/downloads/$ISO639P3
		fi;
		echo map ISO 639-3 to BCP47 1>&2
			unzip -c $ISO639P3 */*_Latin1*.tab | cut -f 1,4 | egrep '^[a-z].*\s[a-z]' | \
			perl -pe 's/^([a-z]+)\s+([a-z][a-z])\s*$/s\/\@$1\/\@$2\/g\n'/ | grep '@' \
		 > sil2lexvo1.sed;
	fi;

#############
# RETRIEVAL #
#############
if [ -e wns ]; then
	echo use existing OMW dump from wns/, not updated 1>&2;
else
	if [ -e src/all.zip ]; then
		echo use existing src/all.zip 1>&2
	else
		mkdir -p src;
		wget -nc $SRC -O src/all.zip
	fi;
	unzip src/all.zip
fi;

######################
# OntoLex generation #
######################
# only wordnet data, no Wiktionary data (as this is not maintained) nor CLDR data (degree of verification uncertain)
# note that OMW provides a lemon edition that may contain more exhaustive information

for file in wns/*/wn-data*tab; do
#for file in wns/als/wn-data*tab wns/bul/wn-data*tab; do
	lang=`echo $file |sed s/'.*wns\/\([^\/]*\)\/wn-.*'/'\1'/g`;
	tgt=`echo $file |sed s/'\.tab$'//`.ttl;
	echo -n $tgt' ' 1>&2;
	if [ -e $tgt ]; then
		echo found, skipping OntoLex conversion 1>&2
	else
		echo being created 1>&2;
		egrep '[:\s](lemma|exe|def)\s' $file | 
		perl -pe '
			s/[\r\n]+/\n/g;		# normalize line breaks
			s/\t[0-9]+\t/\t/g;	# drop property numbers
			s/\t(lemma|exe|def)\t([^\n"]+)/\t$1\t$2\t'$lang'/g;
			s/\t([a-z]+):(lemma|exe|def)\t([^\n]+)/\t$2\t$3\t$1/g;
		'  | \
		$TARQL -t -H -stdin tab2ontolex.sparql | \
		# fix language codes
		sed -f sil2lexvo1.sed | \
		# remove redundancies and format
		rapper -i turtle - http://compling.hss.ntu.edu.sg/omw/wns/$lang'/' | \
		sort -u | \
		rapper -i ntriples -o turtle - http://compling.hss.ntu.edu.sg/omw/wns/ \
			-f 'xmlns:lexinfo="http://www.lexinfo.net/ontology/2.0/lexinfo#"' \
			-f 'xmlns:lime="http://www.w3.org/ns/lemon/lime#"' \
			-f 'xmlns:ontolex="http://www.w3.org/ns/lemon/ontolex#"' \
			-f 'xmlns:vartrans="http://www.w3.org/ns/lemon/vartrans#"' \
			-f 'xmlns:dct="http://purl.org/dc/terms/"' \
			-f 'xmlns:pwn30="http://wordnet-rdf.princeton.edu/wn30/"' \
			-f 'xmlns:wn="http://globalwordnet.github.io/schemas/wn#"' > $tgt
	fi;
done;

#######################
# TIAD-TSV generation #
#######################
# TODO: track license information

mkdir -p tsv
for file1 in wns/*/*ttl; do
	src=`egrep -m 1 'writtenRep.*"\@' $file1 | sed s/'.*\@\([a-z][a-z]*\).*'/'\1'/`;
	rapper -i turtle $file1 | sed s/'\.[ \t]*$'/' <http:\/\/compling.hss.ntu.edu.sg\/omw\/wns\/SOURCE> .'/ > tsv/tmp.nq;
	for file2 in wns/*/*ttl; do
		tgt=`egrep -m 1 'writtenRep.*"\@' $file2 | sed s/'.*\@\([a-z][a-z]*\).*'/'\1'/`;
		if [ $src != $tgt ]; then
			if [ ! -e tsv/$src/$src-$tgt.tsv ]; then
				echo export to tsv/$src/$src-$tgt.tsv 1>&2
				mkdir -p tsv/$src;
				echo TIAD-TSV export: $src $tgt 1>&2;
				$ARQ --data=$file2 --data=tsv/tmp.nq --query=ontolex2tsv.sparql	--results=TSV | grep -v '^?' > tsv/$src/$src-$tgt.tsv
			else 
				echo found tsv/$src/$src-$tgt.tsv, skipping 1>&2
			fi;
		fi;
	done;
	rm tsv/tmp.nq
done;
