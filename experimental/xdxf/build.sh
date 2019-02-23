#!/bin/sh
# retrieve all XDXF dictionaries from https://sourceforge.net/projects/xdxf/
# note that the dictionaries accessible via the site do not contain any other licensing information than given under https://sourceforge.net/projects/xdxf/, we presume that this content is under GNU General Public License version 2.0 (GPLv2)
# we do, however, record resource provenance in case any individual contributor to the project violated copyright himself before putting this under GPL

##########
# CONFIG #
##########
project=xdxf

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


################
# (1) crawling #
################
mkdir -p src
cd src;
urllist=urllist

echo "building crawling $project structure" 1>&2
# retrieve main site

if [ -d xml ]; then
	echo using existing xml/, no updates 1>&2;
else
	if [ -e $urllist ]; then 
		echo using existing $urllist 1>&2;
	else	
		wget -nd -p -c https://sourceforge.net/projects/$project/

		# download all pages with direct download links
		if [ -e sourceforge.net ] ; then 
			echo using existing sourceforge.net 1>&2;
		else wget -w 1 -np -m -c -A download http://sourceforge.net/projects/$project/files/
		fi;
		
		# filter for target files
		find sourceforge.net/ | egrep '(dtd|tar.bz2/download)$' | grep -v -i converter | sed s/'^'/'http:\/\/'/ > $urllist

		# remove temporary files, unless you want to keep them for some reason
		rm -rf sourceforge.net/
	fi;

	if [ -d bz2 ]; then
		echo found bz2, no download 1>&2
	else
		# follow download links
		mkdir -p bz2;
		cd bz2;
		while read url; do
			wget -nc --content-disposition -x -nd $url 
		done < ../urllist
		cd ..;
	fi;

	# decompress
	mkdir -p xml
	while read url; do
		base=`echo $url | sed -e s/'\/download$'// -e s/'.*\/'//g;`
		if [ -e bz2/$base ]; then
			if echo $base | grep 'dtd$' >&/dev/null; then
				cp bz2/$base xml;
			else
				dir=xml/`echo $base | sed s/'\.tar\.bz2$'//`;
				mkdir -p $dir;
				cd $dir;
				tar -xvf ../../bz2/$base;
				
				# pruning
				for file in `find */ | egrep -v 'dict.xdxf$'`; do
					if [ -f $file ]; then
						rm $file;
					fi;
				done;

				# move up
				for subdir in */; do 
					if find $subdir | grep 'dict.xdxf$' >& /dev/null; then
						mv -f $subdir ..;
						(date +%F;
						echo XDXF file retrieved from $url;
						echo;
						echo "license: GNU General Public License version 2.0 (GPLv2)";
						echo "(as stated under https://sourceforge.net/projects/xdxf/)" ) > ../$subdir/README.txt;
					else 
						echo warning: no xdxf file in $subdir, removing 1>&2;
						rm -rf $subdir;
					fi;
				done;
				cd - >& /dev/null;
				rm -rf $dir;
			fi;
		fi;
	done < urllist
	
	cd ..;
fi;

cd ..

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
sed s/'\(...\)\s\(...*\)'/"s\/^\2$\/\1\/g"/ > lang2iso-3.sed;

cat lang2iso-3.tsv | egrep '\s..$' | \
sed s/'\(...\)\s\(..\)$'/"s\/^\1$\/\2\/g"/ > iso-3-to-bcp47.sed;
cd ..

###########################
# (3) create release data #
###########################

release=xdxf-rdf-`date +%F`;
mkdir -p $release
cd src/xml;
for dir in *; do
	lang_from=`head $dir/dict.xdxf | xmllint -recover -xpath '//@lang_from[1]' - 2>/dev/null | sed s/'.*"\([^"]*\)".*'/'\L\1'/`;
	lang_to=`head $dir/dict.xdxf | xmllint -recover -xpath '//@lang_to[1]' - 2>/dev/null | sed s/'.*"\([^"]*\)".*'/'\L\1'/`;

	lang_from=`echo $lang_from | sed -f ../../sed/lang2iso-3.sed | sed -f ../../sed/iso-3-to-bcp47.sed`;
	lang_to=`echo $lang_to | sed -f ../../sed/lang2iso-3.sed | sed -f ../../sed/iso-3-to-bcp47.sed`;

	# fixing some XDXF language tag errors
	if [ $dir = 'Cornish_English' ]; then lang_from=kw; fi;	
	if [ $dir = 'English_Gothic' ]; then lang_to=got; fi;	
	if [ $dir = 'English_Haitian_creole' ] ; then lang_to=ht; fi;
	if [ $dir = 'English_Indonesian' ]; then lang_to=id; fi;
	if [ $dir = 'English_Kipsigis' ]; then lang_to=sgc; fi;
	if [ $dir = 'English_Latin' ]; then lang_to=la;fi;
	if [ $dir = 'English_Old_English' ]; then lang_to=ang;fi;
	if [ $dir = 'English_Persian' ]; then lang_to=fa; fi;
	if [ $dir = 'eng-transcr_0107' ]; then lang_to=en-fonipa; fi;
	if [ $dir = 'English_Cornish' ]; then lang_to=kw; fi;
	if [ $dir = 'Gothic_English' ]; then lang_from=got; fi
	if [ $dir = 'Indonesian_English' ]; then lang_from=id; fi;
	if [ $dir = 'Kipsigis_English' ]; then lang_from=sgc; fi;
	if [ $dir = 'Latin_English' ]; then lang_from=la; fi;
	if [ $dir = 'ukr-rus_slovnyk' ]; then lang_from=uk; fi
	
	# skip if same language, unless a known synonym or variety dictionary
	if [ $lang_from = $lang_to -a \
		 $dir != 'American_English' -a \
		 $dir != 'eng_eng_syn' -a \
		 $dir != 'bulg_syn' -a \
		 $dir != 'dal' -a \
		 $dir != 'dalf' -a \
		 $dir != 'English_American' -a \
		 $dir != 'ru_synonym_sh' -a \
		 $dir != 'rus-rus_beslov' -a \
		 $dir != 'rus-rus_brok_efr' \
		 ]; then echo $dir: "skipping (monolingual, may be lexicon rather than dictionary)" 1>&2;
	else 

		
		tgt=../../$release/${lang_from}-${lang_to};
		
		# (a) README
		
		echo -n `realpath --relative-base=../.. $tgt`/$dir.'*: ' 1>&2;
		mkdir -p $tgt;
		
		if [ -s $tgt/$dir.README.txt ]; then echo >&/dev/null; 
		else
			(cat $dir/README.txt;
			 echo;
			(echo 'original XDXF header';
			xmllint --recover --format $dir/dict.xdxf | egrep -m 1 -B 50 '<ar' | grep -v '<ar' | \
			sed -e s/'<!DOCTYPE[^>]*>'// \
				-e s/'<?xml[^>]*\?>'// | \
			sed s/'^'/'  '/g ) |\
			egrep -v '^ *$' | egrep -B 2 -A 999999999 '<' ) >  $tgt/$dir.README.txt
			echo -n readme' ' 1>&2;
		fi;

		# (b) TTL
		if [ -s $tgt/$dir.ttl -o -s $tgt/$dir.ttl.gz ]; then
			echo -n $dir.ttl found' ' 1>&2;
		else
			# before processing, drop doctype (won't find DTD)
			sed s/'<!DOCTYPE[^>]*>'// $dir/dict.xdxf | iconv -f utf-8 -t utf-8 -c | xmllint --recover - | \
			$SAXON -xsl:../../xdxf2ontolex.xsl -s:- SRC_LANG=$lang_from TGT_LANG=$lang_to DICT=$dir > $tgt/$dir.ttl
			echo -n $dir.ttl built' ' 1>&2;
		fi;

		# (c) TSV
		if [ -e $tgt/$dir.tsv -o -e $tgt/$dir.tsv.gz ]; then
			echo $dir.tsv found 1>&2;
		else 
			if [ -e $tgt/$dir.ttl.gz ]; then
				if [ ! -e $tgt/dir.ttl ]; then
					gunzip $tgt/$dir.ttl.gz 
				fi;
			fi;
			$ARQ --data=$tgt/$dir.ttl \
				--query=../../ontolex2tsv.sparql --results=TSV | grep -v '^?' | sort -u > $tgt/$dir.tsv;
			
			echo $dir.tsv build 1>&2;
		fi;
		
		# (d) prune and compress, keep files with successful TSV export only
		if [ -s $tgt/$dir.tsv ]; then
			gzip $tgt/$dir.tsv $tgt/$dir.ttl;
		else
			rm $tgt/$dir*
			rmdir $tgt >& /dev/null
		fi;
	fi;		


	
done;
cd ../..;