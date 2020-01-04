#!/bin/sh
# retrieve all Starling dictionaries from http://download.huzheng.org/
# we only retrieve resources with explicit open license

##########
# CONFIG #
##########

# one of several mirrors
src=http://download.huzheng.org/ 

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

JAVA_PATH_SEPARATOR=':'; # Un*x
if echo $OSTYPE | grep -i 'cygwin' >&/dev/null; then
	JAVA_PATH_SEPARATOR=";"; # cygwin/windows
fi;

################
# (1) Crawling #
################

mkdir -p src;
cd src;
	if [ -s urllist ] ; then 
		echo using existing src/urllist 1>&2;
	else
		if [ -e `echo $src | sed -e s/'^[^:]*:\/\/'// -e s/'\/.*'//` ] ; then
			echo using existing copy of $src, no crawling 1>&2;
		else
			wget -r -np -c -A html $src;
		fi;
		for file in `find . | grep 'html$'`; do
			path=`echo $file | sed -e s/'^\.\/'// -e s/'\/'/'\\\\\/'/g -e s/'index.html$'//`;
			xmllint --recover $file 2>/dev/null | \
			xmllint --xpath "//tr/td[contains(text(),'GPL') or contains(text(),'EDRDG Licence') or contains(text(),'Public Domain') or contains(text(),'Free to use') or contains(text(),'CEDICT LICENCE')]/.." - | \
			sed s/'\(<a href="\)'/'\1http:\/\/'$path/g | \
			perl -pe 's/\s+/ /g; s/<tr/\n<tr/g;' | # one entry per line
			perl -pe '
				s/<\/td>/\t/g; 
				s/<[^<]*a href="([^"]+)"[^>]*>/\1\t/g;
				s/<[^>]*>//g;
				s/ +/ /g;
				s/ *\t */\t/g;
				s/^ //;
				s/ $//g;
			';
		done > urllist
		rm -rf */*
		rmdir * >&/dev/null
	fi;
	
	for file in `cut -f 2 urllist`; do
		wget -nH -w 1 -x -c $file;
	done;
cd ..;

################
# (2) Decoding #
################

javac -classpath .${JAVA_PATH_SEPARATOR}lib/commons-lang3-3.8.1.jar StarDictParser.java;
mkdir -p txt;
cd src;
for file in `find . | grep 'tar.bz2$'`; do
	dir=`echo $file | sed s/'\/[^\/]*$'//`;
	tgt=`echo $file | sed s/'.tar.bz2$'/'.txt'/`;
	mkdir -p ../txt/$dir;
	mkdir -p ../tmp;
	cd ../tmp;
	pwd;
	tar -xvf ../src/$file;
	dz=`find | egrep -m 1 '.dz$|.dic$|.dict$'`;
	idx=`find | egrep -m 1 '.idx$'`;
	if [ -e ../txt/$tgt ] ; then echo found txt/$tgt, skipping 1>&2; 
	else
		(#echo java -classpath .. StarDictParser $dz $idx 1>&2;
		echo java -classpath ..${JAVA_PATH_SEPARATOR}../lib/commons-lang3-3.8.1.jar StarDictParser $dz $idx -silent 1>&2;
		java -classpath ..${JAVA_PATH_SEPARATOR}../lib/commons-lang3-3.8.1.jar StarDictParser $dz $idx -silent > ../txt/$tgt) 2>&1 | tee ../txt/$tgt.log 1>&2;
	fi;
	cd ../src
	rm -rf ../tmp;
done;
cd ..;

# pruning: eliminate files with massive encoding errors
for file in `grep -l '????' $(find txt | grep '.txt$')`; do
	echo encoding errors in $file, removed 1>&2;
	# head $file;
	# grep -m 1 '????' $file;
	# echo;
	rm $file $file.log;
done;

#########################################
# (3) Language detection and conversion #
#########################################
# we use a manually pre-compiled mapping
# we also filter for successfully convertible files [as resulting rom step (4)] and eliminate some rubbish (this is the \tok\t column)

if [ ! -d grouped ]; then mkdir grouped;
	for file in `cat lang-mapping.tsv | grep -v 'n/a' | grep -v '^#' | egrep -v '^[^	]*	([^	][^	]*)	\1	' | egrep '\sok\s' | cut -f 1`; do
		src=`egrep -m 1 $file lang-mapping.tsv | cut -f 2`;
		tgt=`egrep -m 1 $file lang-mapping.tsv | cut -f 3`;
		if [ ! -d grouped/${src}_${tgt} ]; then mkdir grouped/${src}_${tgt}; fi;
		echo mv $file grouped/${src}_${tgt} 1>&2
		mv $file grouped/${src}_${tgt};
	done;
fi;


##########################
# (4) extract word lists #
##########################

# remove pseudo markup elements (for filtering out xml-annotated files)
for file in `grep -l '^info:.*>' grouped/*/*`; do
	sed -i s/'^info:.*'/''/g $file; # contains markup
done;

# normalize markup
for file in `grep -l -a '&lt;' grouped/*/*`; do
	sed -i s/'&lt;'/'<'/g $file;
done;

# # lowercase and remove markup
for file in `grep -l '>' grouped/*/*`; do
	echo prune $file 1>&2;
	sed -i 	-e s/'\[[^]]*\]'/''/g \
	-e s/'\([<&][^>]*>\)'/'\L&'/g \
			-e s/'<br.*'//g \
			-e s/'<i>[^>]*<\/i>'//g \
			-e s/'<u>\([^>]*\)<\/u>'/'\1'/g\
			-e s/'<[\/]*div[^>]*>'//g \
			-e s/'<[\/]*p[^>]*>'//g \
			-e s/'<img[^>]*>'//g \
			-e s/'<[^\/]*b>'//g \
			-e s/'<sup>[^>]*<\/sup>'//g \
			-e s/'<sub>[^>]*<\/sub>'//g \
			-e s/'<a [^>]*>'//g -e s/'<\/a>'//g \
			-e s/'\t.*<body[^>]*>'/'\t'/g \
			-e s/'<[\/]*span[^>]*>'//g \
			-e s/'<\/body.*'// \
			-e s/'<k>'//g \
			-e s/'<\/k>'//g \
			-e s/'<[ibu]>'//g \
			-e s/'<\/[ibu]>'//g \
			-e s/'<c [^>]*>'//g \
			-e s/'<c>'//g \
			-e s/'<\/c>'//g \
			-e s/'<blockquote>'//g \
			-e s/'<[\/]blockquote>'//g \
			-e s/'<kref>'//g \
			-e s/'<[\/]kref>'//g \
			-e s/'\t[^<]*>'/'\t'/ \
			-e s/'<[^>\t]*$'// \
			-e s/'<su[bp]>'//g \
			-e s/'<\/su[bp]>'//g \
			-e s/'^<\([^>]*\)>\([^a-zA-Z\t]*\)\t'/'\1\2\t'/ \
			-e s/'<ex>.*<\/ex>'/' '/g \
			-e s/'<ex>.*'// \
			-e s/'<\/ex>'//g \
			-e s/'<ex>'//g \
			-e s/'<dtrn>'//g \
			-e s/'<\/dtrn>'//g \
			-e s/'<font color="#[0-9]*">[^<]*<\/font>'//g \
			-e s/'<font[^>]*>'//g \
			-e s/'<\/font>'//g \
			-e s/'<small>[^<]*<\/small>'/' '/g \
			-e s/'<small>'//g \
			-e s/'<\/small>'//g \
			-e s/'<\/td>.*'//g \
			-e s/'<A .*'//g \
			-e s/'<span [^>]*>'//g \
			-e s/'<\/span>'//g \
			-e s/'<span.*'//g \
			-e s/'<\/display>.*'//g \
			-e s/'\t.*<display>'/'\t'/g \
			-e s/'<display>'/' '/g \
			-e s/'<\/display>'/' '/g \
			-e s/'<mbp:nu>'//g \
			-e s/'<\/mbp:nu>'//g \
			-e s/'\t[^<]*>'/'\t'/g \
			-e s/'<[^>\t]*$'//g \
			-e s/'<blockquote.*'//g \
			-e s/'<\([anv]\)>'/'(\1)'/g \
			-e s/'<[anvhrtqe]>'//g \
			-e s/'<np>'/'(np)'/g \
			-e s/'<a[mocp]>'//g \
			-e s/'<degree>'//g \
			-e s/'>>.*'/' '/g \
			-e s/'<<'/' '/g \
			-e s/'<\(garnicht\|gegebenfalls\|bezugnehmen\|vorallem\|anderseits\|wiederspiegeln\)>'/'; \1'/g \
			-e s/'<see[^>]*>'//g \
			-e s/'<used in[^>]*>'//g \
			-e s/'<untranslatable[^>]*>'//g \
			-e s/'<alternate[^>]*>'//g \
			-e s/'<helping[^>]*>'//g \
			-e s/'{[^}]*}'//g \
			-e s/'<see.*'//g \
			-e s/'<\([mfng]\)>'/'(\1)'/g \
			-e s/'<mf>'/'(mf)'/g \
			-e s/'<.*'//g \
			-e s/'\t.*>'/'\t'/g \
		$file;
done

######################
# (5) RDF conversion #
######################
# convert TSV to XML, run XSL
for file in grouped/*/*.txt; do
	tgt=`echo $file | sed s/'.txt$'//`.xml;
	echo $file ">" $tgt 1>&2;
	(echo '<xml>';
	egrep '.\t.' $file | \
	sed -e s/'^\(.*\)\t\(.*\)$'/'<entry><src>\1<\/src><tgt>\2<\/tgt><\/entry>'/ \
		-e s/'&amp;amp;'/'\&amp;'/g \
	| \
	egrep '<' ) | \
	xmllint --recover - 2>$file.log 1>$tgt;
done;

for dir in grouped/*; do
	if [ -d $dir ]; then
		SRC=`echo $dir | sed -e s/'.*\/'//g -e s/'_.*'//`;
		TGT=`echo $dir | sed -e s/'.*\/'//g -e s/'.*_'//`;
		for file in $dir/*xml; do
			tgt=`echo $file | sed s/'.xml$'//`.ttl;
			if [ -e $tgt.gz ]; then gunzip $tgt.gz; fi;
			if [ -e $tgt ]; then echo found $tgt, keeping it 1>&2;
			else 
				echo $file ">" $tgt 1>&2;
				$SAXON -xsl:cols2ontolex.xsl -s:$file lexicon=http://download.huzheng.org/`echo $file | sed -e s/'.*\/'// -e s/'\.xml$'//` SRC_LANG=$SRC TGT_LANG=$TGT > $tgt;
			fi;

###########################
# (6) convert to TIAD-TSV #
###########################
			
			file=$tgt;
			tgt=`echo $file | sed s/'\.ttl$'/'.tsv'/;`
			echo $file': TSV export' 1>&2;
			if [ -e $tgt ] ; then
				echo 'skipping: found '$tgt 1>&2;
			else if [ -e $tgt.gz ] ; then
				echo 'skipping: found '$tgt.gz 1>&2;
			else
				$ARQ --data=$file \
					 --query=ontolex2tsv.sparql --results=TSV | grep -v '^?' > $tgt;
				if [ ! -s $tgt ]; then
					if rapper -i turtle $file > $file.tmp; then
						echo 'try to recover' $file 1>&2;
						$ARQ --data=$file.tmp \
							--query=ontolex2tsv.sparql --results=TSV | grep -v '^?' > $tgt;
						if [ ! -s $tgt ]; then rm $tgt; fi
					fi;
					rm $tgt.tmp >&/dev/null;
				fi;
				if [ -s $tgt ]; then 
					gzip $tgt;
				else 
					rm $tgt $file >&/dev/null; 
				fi;
			fi; fi;
			if [ -e $file ]; then gzip $file; fi;
		done;
	fi;
done;

###########################
# (7) move to release dir #
###########################

RELEASE=stardict-`date +%F`;
if [ -d $RELEASE ]; then
	echo found $RELEASE, keeping it 1>&2;
else
	cp -r grouped $RELEASE
	rm `find $RELEASE | grep -v 'gz$'` 2>/dev/null;
fi;

