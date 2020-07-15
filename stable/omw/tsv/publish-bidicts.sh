#!/bin/bash
# we can only publish bidictionaries if their licenses are compatible
# we test this by comparing the license files
# execute in the local directory
# we publish only pairs whitelisted by licensed.tsv
# without additional information, this includes only language pairs with *IDENTICAL* license
# legal advice required to decide this for non-identical licenses

for file in `egrep '\s[^\s]' licensed.tsv | cut -f 1`; do
	svn add --parents $file; svn commit $file -m 'OMW TIAD-TSV pair '`echo $file | sed s/'.*\/\([^\/]*\).tsv'/'\1'/`;
done;