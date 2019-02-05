#!/bin/bash
# helper file for build-dict-graph.sh
# read a TSV file from stdin and create a dot file
# format:
# SRC_LABEL<TAB>TGT_LABEL<TAB>STYLE
# for creating a dictionary graph, SRC_LABEL and TGT_LABEL should be BCP-47 language codes, STYLE indicates line style, one per source

echo 'Graph G {';
echo 'overlap=false;';
echo 'splines=true;';
perl -pe '
	s/^([^\t]*)\t([^\t\n]*)\n/   $1 -- $2;\n/gs;
	s/^([^\t]*)\t([^\t]*)\t([^\t\n]*)\n/   $1 -- $2 [$3] ;\n/gs;
';
# sed s/'^\([^\t]*\)\t\([^\t]*\)\(\t\([^\t]*\)\)*'/'   \1 -> \2;'/g;
echo '}'

