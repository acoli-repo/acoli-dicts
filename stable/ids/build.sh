#!/bin/bash
# retrieves up-to-date intercontinental dictionary series data
# for refresh, delete the src folder
# NOTE: requires ruby 

# config
if whereis gem | grep '/' >&/dev/null; then 

#	if whereis rdf | grep '/' >& /dev/null; then echo >& /dev/null;
#	else echo install rdf-tabular '(admin mode required)' >&/dev/null;
		gem 'rdf-tabular', '~> 3.1'
		gem install linkeddata 
		gem install rdf-tabular
#	fi;

	# retrieve src
	if [ -e src ]; then
		echo found src, skipping retrieval 1>&2
	else
		mkdir src;
		cd src;
		wget -O - https://ids.clld.org/download > index.html;
		URL=`
			cat index.html | \
			perl -pe 's/\s+/ /g; s/</\n</g; s/>/>\n/g;' | \
			egrep '<a[ \t]'| \
			sed -e s/'\s'/'\n'/g | grep 'href=' | \
			sed -e s/'"'/'\n'/g | egrep 'zip$'`;
		echo retrieve $URL 1>&2;
		wget $URL;
		cd ..
	fi;

	# csv2rdf conversion
	cd src;
	for SRC in `find | egrep 'zip$'`; do
		echo processing $SRC 1>&2;
		mkdir $SRC.files
		cd $SRC.files;
		unzip ../$SRC;
		for file in *.csv; do
			rdf serialize $file --output-format ntriples
			rdf tabular-json --input-format tabular $file;
		done;
		cd ..
	done;
	cd ..

else
	echo please install ruby, gem and ruby-dev 1>&2;
fi;