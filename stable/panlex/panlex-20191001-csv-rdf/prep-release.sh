#!/bin/bash

# prepare data release via Zenono, i.e.
# - decompress all rdf.gz files
# - prepare batches of 1000 files each (batch 0: 1..999, batch 1: 1000...1999, etc.)
# - replace uris by http://purl.org/acoli/dicts/panlex/<batch>/<file>

# note that as we use Purl URIs, these need to be maintained
# each new version will get a new DOI and thus, a new URI

MYHOME=`dirname $0`
RDF=$MYHOME/rdf
TGT=$MYHOME/zenodo

for dir in $RDF/*; do \
	if [ -d $dir ]; then \
		for file in `find $dir | grep 'rdf.gz$'`; do \
			nr=`basename $file | sed -e s/'[^0-9]'//g`;\
			batch=`echo $nr  | sed -e s/'^'/00000/ -e s/'.*\(...\)...$'/'\1'/`; \
			if [ ! -e $TGT/$batch ]; then \
				mkdir -p $TGT/$batch;\
			fi;
			if gunzip -c $file | egrep -l 'http.*panlex.org.snapshot.panlex'; then
			   (gunzip -c $file | \
				rapper - 'http://purl.org/acoli/dicts/panlex/'$batch'/'$nr'.ttl' -o turtle 2>/dev/null | \
				sed s/'https:..panlex.org.snapshot.panlex-[0-9]*-csv.'$nr/'http:\/\/purl.org\/acoli\/dicts\/panlex\/'$batch'\/'$nr'.ttl'/g;
				echo -n '<http://purl.org/acoli/dicts/panlex/'$batch'/'$nr'.ttl> <http://purl.org/dc/terms/source> ';
				gunzip -c $file | \
				egrep -m 1 'http.*panlex.org.snapshot.panlex' | \
				sed s/'"'/'\n'/g | \
				egrep -m 1 '^http.*panlex.org.snapshot.panlex' | \
				sed -e s/'^'/'<'/ -e s/'$'/'> .'/ ) > $TGT/$batch/$nr.ttl;
				echo $TGT/$batch/$nr.ttl 1>&2;\
			fi;
		done;\
	fi; \
done

# prune: delete files with less than 500 lexical entries
for dir in $TGT/[0-9]*/; do
	for file in $dir/*.ttl; do
		MIN=500;
		if [ ` egrep -m $MIN 'LexicalEntry' $file | wc -l ` != 500 ]; then rm $file; echo skipping $file 1>&2; fi;
	done;
done;

if [ ! -e $TGT/langs ]; then mkdir -p $TGT/langs; fi
for dir in $TGT/[0-9]*; do 	 
	for file in $dir/*ttl; do
		if [ -e $file ]; then
			echo $file 1>&2;
			rapper -i turtle $file | grep 'writtenRep' | \
			sed -e s/'> '/'>\t'/g -e s/'@'/'\t'/g | \
			cut -f 1,3,4 | sed s/'\s*\.\s*$'// | \
			perl -e '
				use strict;
				use warnings;
				use URI::Escape;
				while(<>) {
					my $url=$_;
					$url=~s/\t.*//s;
					my $tok=$_;
					$tok=~s/.*"([^"]+)".*/$1/s;
					my $lang=$_;
					$lang=~s/.*\t//;
					$lang=~s/\s*$//;
					my $filename = "'$TGT'/langs/$lang.ttl";
					open(my $fh, ">>", $filename) or warn "Could not open log file; discarding input";
					$tok=uri_escape($tok);
					print $fh "<http://purl.org/acoli/dicts/panlex/langs/".$lang.".ttl#".$tok."> <http://www.w3.org/2002/07/owl#sameAs> ".$url." .\n";
					close $fh;
				}
			'
		fi;
	done;
done 

# delete invalid language IDs
find zenodo/langs -type f -print0 | egrep -a -v '\/[a-z][a-z][a-z]?\.ttl$' -z -Z | xargs -0 rm

# link Princeton WordNet # note that OMW doesn't seem to be in the LLOD cloud
if [ ! -e wordnet.nt.gz ]; then
	cd $MYHOME;
	wget http://wordnet-rdf.princeton.edu/static/wordnet.nt.gz;
	cd -;
fi;

echo >> $TGT/langs/en.ttl
arq --data $MYHOME/wordnet.nt.gz --query $MYHOME/link-wn.sparql >> $TGT/langs/en.ttl

python3 $MYHOME/make-stats.py $TGT > $TGT/langs/meta.ttl
# | \
# 	rapper -i turtle - "http://purl.org/acoli/dicts/panlex/" 2>/dev/null | \
# 	sort -u | \
# 	rapper -i turtle - "http://purl.org/acoli/dicts/panlex/" -o turtle# 2>/dev/null 
