#!/bin/bash
# retrieve German-Zazaki dictionary and produce OntoLex and TIAD outputs

#!/bin/bash
# retrieve selected free-dict.de dictionaries and provide an Ontolex-lemon edition
# currently limited to Zazaki dictionary, others are tbc. wrt. copyright

# (c) 2020-01-02 Christian Chiarcos, christian.chiarcos@web.de
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

RELEASE=free-dict-de-`date +%F`;

if [ -e $RELEASE/zza-de.tsv ] ; then
	echo found $RELEASE/zza-de.tsv, skipping 1>&2;
else

	for file in $RELEASE/*gz; do
		gunzip $file;
	done;

	#############################
	# (1) retrieve source files #
	#############################
	# cp from build.sh
	# BUT: into separate html dir
	
	if [ ! -d html ]; then mkdir html; fi;

	# download via pager
	for c in {a..z} ; do
		echo  -n html/$c.html .. 1>&2;
		if [ ! -e html/$c.html ]; then
			w3m -dump_source https://zazaki.free-dict.de/perl/zazaki_pager.pl?letter=$c > html/$c.html
			if egrep -v rterbuch html/$c.html >&/dev/null; then 	# gzipped
				mv html/$c.html html/$c.html.gz;
				gunzip html/$c.html.gz;
			fi;
			if [ -s html/$c.html ] ; then
				echo ' 'retrieved 1>&2;
			else
				echo ' 'failed 1>&2;
				rm html/$c.html >&/dev/null;
			fi;		
		fi;
	done

	# download via general search, for umlaut vowels only
	# for other free-dict.de dictionaries, this would be the way to retrieve them, but iteration must be deeper
	for uml in ä ö ü; do
		for c in b c d f g h j k l m n p q r s t u v w x y z ß; do
			c=$uml$c;
			echo -n html/$c.html .. 1>&2;
			if [ ! -e html/$c.html ]; then
				w3m -dump_source 'https://zazaki.free-dict.de/perl/zazaki_translate.pl?word='$c'&submit=%C3%9Cbersetzen&lang=deu2zza' > html/$c.html
				if egrep -v rterbuch html/$c.html >&/dev/null; then 	# gzipped
					mv html/$c.html html/$c.html.gz;
					gunzip html/$c.html.gz;
				fi;
				if [ -s html/$c.html ] ; then
					echo ' 'retrieved 1>&2;
				else
					echo ' 'failed 1>&2;
					rm html/$c.html >&/dev/null;
				fi;
			else
				echo ' 'found, not retrieved 1>&2;
			fi;
		done;
	done

	# no language code fixing, we just do de-zza

	################################
	# (2) convert to ontolex-lemon #
	################################
	TMP=html/tmp.ttl;
	if [ ! -e $RELEASE/zza-de.ttl ]; then
		mkdir $RELEASE >&/dev/null;
		for file in html/*.html; do
			echo $file to ttl 1>&2;
			xmllint --recover --html --xmlout $file 2>/dev/null | \
			grep -v '<!DOCTYPE html ' | \
			sed s/'\(<[\/]?\)html'/'\1xml'/g | \
			SAXON -xsl:html2ontolex.xsl -s:- lexicon=https://zazaki.free-dict.de > $TMP;
			if egrep -m 1 'ontolex:LexicalEntry' $TMP >&/dev/null; then
				echo -n $file contains' ' 1>&2;
				if rapper -i turtle --count $TMP 2>/dev/null; then
					rapper -i turtle --count $TMP 2>&1 | grep triples | sed s/'^[^0-9]*'//g;
					cat $TMP >> $RELEASE/zza-de.ttl;
					rm $TMP
				else
					echo ' ' an error 1>&2;
					rapper -i turtle --count $TMP;
					echo 1>&2;
					echo ttl source 1>&2;
					egrep -n '^' $TMP | sed s/'^'/'   '/g 1>&2;
					echo 1>&2;
				fi;
			else 
				echo $file contains no triples 1>&2;
			fi;
		done;
	fi;

###########################
# (3) convert to TIAD-TSV #
###########################

	for file in $RELEASE/*ttl; do
		tgt=`echo $file | sed s/'\.ttl$'/'.tsv'/;`
        echo $file': TSV export' 1>&2;
		if [ -e $tgt ] ; then
			echo 'skipping: found '$tgt 1>&2;
		else if [ -e $tgt.gz ] ; then
			echo 'skipping: found '$tgt.gz 1>&2;
		else
			$ARQ --data=$file \
				 --query=ontolex2tsv.sparql --results=TSV | grep -v '^?' > $tgt;
		fi; fi;
	done
	
################
# (4) compress #
################

	for file in $RELEASE/*tsv $RELEASE/*ttl; do
		gzip $file;
	done;
	
fi;

echo done 1>&2;