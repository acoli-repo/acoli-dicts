#!/bin/bash
# auxiliary script that creates a list of language pairs from biling-tsv
# TODO: integrate with build.sh
# synopsis: list-language-pairs.sh biling-tsv/
# runs find over the argument directory (here biling-tsv/), retrieves all zip files

for zip in `find $* | grep 'zip$'`; do
	if [ -f $zip ]; then
		for tsv in `unzip -l $zip | grep 'tsv$' | sed s/'.* '//g`; do
			echo -n $zip'	'$tsv'	';
			unzip -c $zip $tsv | egrep '	<' |wc -l;
			#unzip -c $zip $tsv | head;
			#echo;
		done;
	fi;
done