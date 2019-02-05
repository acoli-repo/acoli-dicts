#!/bin/bash
# no arguments, produces a dictionary/language graph for ACoLi dictionaries
# requires ImageMagick (convert) and dot/neato (GraphViz)

# color codes for dictionaries
FREEDICT=blue;
APERTIUM=black;

# build graph of connected dictionaries
(for dir in ../freedict/*rdf*/*-*; do 
	echo $dir | \
	sed -e s/'.*\/'//g -e s/'\-'/'\t'/g -e s/'$'/'\tcolor='$FREEDICT/g; 
done;
for file in ../apertium/*rdf*/apertium-*-rdf.zip; do
	echo $file | sed -e s/'.*\/apertium-'//g -e s/'-rdf.zip'// | \
	sed -e s/'.*\/'//g -e s/'\-'/'\t'/g -e s/'$'/'\tcolor='$APERTIUM/g; 
done;
) | \
bash langs2dot.sh | egrep '[a-zA-Z]' > ../dicts.dot;

# add language coloring (for known languages)
GERMANIC=gray56;
ROMANCE=gray79;
ITALIC=gray79;
SLAVIC=gray88;
BALTIC=gray88;
CELTIC=gray65;
IRANIAN=gray90;
INDIAN=gray91;
OTHER_IE=gray92;
SEMITIC=lightcoral;
TURKIC=lightblue;
UGRIC=khaki;
AUSTRONESIAN=green;
SUBSAHARIC=magenta;


(
echo 'graph G {'
echo 'GERMANIC [shape=box,style=filled,fillcolor='$GERMANIC'];'
echo 'ROMANCE [shape=box,style=filled,fillcolor='$ROMANCE'];'
echo 'ITALIC [shape=box,style=filled,fillcolor='$ITALIC'];'
echo 'SLAVIC [shape=box,style=filled,fillcolor='$SLAVIC'];'
echo 'CELTIC [shape=box,style=filled,fillcolor='$CELTIC'];'
echo 'BALTIC [shape=box,style=filled,fillcolor='$BALTIC'];'
echo 'IRANIAN [shape=box,style=filled,fillcolor='$IRANIAN'];'
echo 'INDIAN [shape=box,style=filled,fillcolor='$INDIAN'];'
echo 'OTHER_IE [shape=box,style=filled,fillcolor='$OTHER_IE'];'
echo 'AFROASIATIC [shape=box,style=filled,fillcolor='$SEMITIC'];'
echo 'TURKIC [shape=box,style=filled,fillcolor='$TURKIC'];'
echo 'UGRIC [shape=box,style=filled,fillcolor='$UGRIC'];'
echo 'AUSTRONESIAN [shape=box,style=filled,fillcolor='$AUSTRONESIAN'];'
echo 'SUBSAHARIC [shape=box,style=filled,fillcolor='$SUBSAHARIC'];'
echo 'OTHER [shape=box];'
echo 'GERMANIC -- CELTIC [style=invis];'
echo 'CELTIC -- ROMANCE [style=invis];'
echo 'ROMANCE -- ITALIC [style=invis];'
echo 'ITALIC -- BALTIC [style=invis];'
echo 'BALTIC -- SLAVIC [style=invis];'
echo 'SLAVIC -- IRANIAN [style=invis];'
echo 'IRANIAN -- INDIAN [style=invis];'
echo 'INDIAN -- OTHER_IE [style=invis];'
echo 'OTHER_IE -- UGRIC [style=invis];'
echo 'UGRIC -- TURKIC [style=invis];'
echo 'TURKIC -- AUSTRONESIAN [style=invis];'
echo 'AUSTRONESIAN -- AFROASIATIC [style=invis];'
echo 'AFROASIATIC -- SUBSAHARIC [style=invis];'
echo 'SUBSAHARIC -- OTHER [style=invis];'

# dictionaries
echo 'X [style=invis];'
echo 'X -- Apertium [color='$APERTIUM'];'
echo 'X -- FreeDict [color='$FREEDICT'];'
echo 'Apertium [color=white];'
echo 'FreeDict [color=white];'
echo 'OTHER -- Apertium [style=invis];'
echo 'Apertium -- FreeDict [style=invis];'

echo '}'
) | dot -Tgif > ../legend.gif


cat ../dicts.dot | grep ' -' | sed s/'\[.*'// | sed s/'\s'/'\n'/g | egrep '[a-z]' | sort -u | \
perl -pe '

	############################# 
	# Indo-European: grey-scale #
	#############################

	# Germanic
	s/^af$/af [style=filled,fillcolor='$GERMANIC'];/g;
	s/^da$/da [style=filled,fillcolor='$GERMANIC'];/g;
	s/^de$/de [style=filled,fillcolor='$GERMANIC'];/g;
	s/^en$/en [style=filled,fillcolor='$GERMANIC'];/g;
	s/^is$/is [style=filled,fillcolor='$GERMANIC'];/g;
	s/^nb$/nb [style=filled,fillcolor='$GERMANIC'];/g;
	s/^nl$/nl [style=filled,fillcolor='$GERMANIC'];/g;
	s/^nn$/nn [style=filled,fillcolor='$GERMANIC'];/g;
	s/^no$/no [style=filled,fillcolor='$GERMANIC'];/g;
		
	# Romance & Italic
	s/^ast$/ast [style=filled,fillcolor='$ROMANCE'];/g;
	s/^es$/es [style=filled,fillcolor='$ROMANCE'];/g;
	s/^ca$/ca [style=filled,fillcolor='$ROMANCE'];/g;
	s/^fr$/fr [style=filled,fillcolor='$ROMANCE'];/g;
	s/^it$/it [style=filled,fillcolor='$ROMANCE'];/g;
	s/^oc$/oc [style=filled,fillcolor='$ROMANCE'];/g;
	s/^pt$/pt [style=filled,fillcolor='$ROMANCE'];/g;
	s/^ro$/ro [style=filled,fillcolor='$ROMANCE'];/g;
	s/^an$/an [style=filled,fillcolor='$ROMANCE'];/g;
	s/^gl$/gl [style=filled,fillcolor='$ROMANCE'];/g;
	s/^la$/la [style=filled,fillcolor='$ITALIC'];/g;
	s/^sc$/sc [style=filled,fillcolor='$ROMANCE'];/g;

	# Slavic and Baltic
	s/^bg$/bg [style=filled,fillcolor='$SLAVIC'];/g;
	s/^cs$/cs [style=filled,fillcolor='$SLAVIC'];/g;
	s/^hr$/hr [style=filled,fillcolor='$SLAVIC'];/g;
	s/^lt$/lt [style=filled,fillcolor='$BALTIC'];/g;
	s/^mk$/mk [style=filled,fillcolor='$SLAVIC'];/g;
	s/^pl$/pl [style=filled,fillcolor='$SLAVIC'];/g;
	s/^ru$/ru [style=filled,fillcolor='$SLAVIC'];/g;
	s/^sl$/sl [style=filled,fillcolor='$SLAVIC'];/g;
	s/^sr$/sr [style=filled,fillcolor='$SLAVIC'];/g;
	s/^sv$/sv [style=filled,fillcolor='$SLAVIC'];/g;
	s/^uk$/uk [style=filled,fillcolor='$SLAVIC'];/g;
	s/^be$/be [style=filled,fillcolor='$SLAVIC'];/g;
	s/^sh$/sh [style=filled,fillcolor='$SLAVIC'];/g;
	s/^sk$/sk [style=filled,fillcolor='$SLAVIC'];/g;
	s/^szl$/szl [style=filled,fillcolor='$SLAVIC'];/g;	# non-ISO code: Silesian (Polish dialect)

	# Celtic
	s/^br$/br [style=filled,fillcolor='$CELTIC'];/g;
	s/^cy$/cy [style=filled,fillcolor='$CELTIC'];/g;
	s/^ga$/ga [style=filled,fillcolor='$CELTIC'];/g;
	s/^gd$/gd [style=filled,fillcolor='$CELTIC'];/g;

	# Iranian
	s/^ku$/ku [style=filled,fillcolor='$IRANIAN'];/g;
	s/^rom$/rom [style=filled,fillcolor='$IRANIAN'];/g;
	
	# Indian
	s/^sa$/sa [style=filled,fillcolor='$INDIAN'];/g;
	s/^hi$/hi [style=filled,fillcolor='$INDIAN'];/g;
	s/^ur$/ur [style=filled,fillcolor='$INDIAN'];/g;
	
	# other Indo-European
	s/^el$/el [style=filled,fillcolor='$OTHER_IE'];/g;
	s/^eo$/eo [style=filled,fillcolor='$OTHER_IE'];/g;

	##########################
	# non-IE: various colors #
	##########################
	
	# Semitic
	s/^ar$/ar [style=filled,fillcolor='$SEMITIC'];/g;
	s/^mt$/mt [style=filled,fillcolor='$SEMITIC'];/g;
	
	# Turkic
	s/^crh$/crh [style=filled,fillcolor='$TURKIC'];/g;
	s/^tr$/tr [style=filled,fillcolor='$TURKIC'];/g;
	s/^tt$/tt [style=filled,fillcolor='$TURKIC'];/g;
	s/^kk$/kk [style=filled,fillcolor='$TURKIC'];/g;

	# Ugric
	s/^fi$/fi [style=filled,fillcolor='$UGRIC'];/g;
	s/^hu$/hu [style=filled,fillcolor='$UGRIC'];/g;
	s/^se$/se [style=filled,fillcolor='$UGRIC'];/g;
	
	
	# Austronesian
	s/^id$/id [style=filled,fillcolor='$AUSTRONESIAN'];/g;
	s/^zlm$/zlm [style=filled,fillcolor='$AUSTRONESIAN'];/g;
	s/^ms$/ms [style=filled,fillcolor='$AUSTRONESIAN'];/g;
	
	# Subsaharic Africa
	s/^swh$/swh [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^wo$/wo [style=filled,fillcolor='$SUBSAHARIC'];/g;
	
	# # other # no color
	# s/^eu$/eu [style=filled,fillcolor=green];/g;
	# s/^ja$/ja [style=filled,fillcolor=green];/g;
	# s/^kha$/kha [style=filled,fillcolor=green];/g;
	
' | grep color >> ../dicts.dot;

# cluster for language groups (well, colors ;)
COLORS=`cat ../dicts.dot | egrep 'fillcolor=' | sed -e s/'.*fillcolor='// -e s/'[^a-z0-9A-Z].*'// | sort -u`;

for color in $COLORS; do
	LANGS=`cat ../dicts.dot | egrep 'fillcolor='$color | sed -e s/'^[^a-z]*'//g -e s/'[^a-z].*'//g`;
	for lang in $LANGS; do
		for lang2 in $LANGS; do
			if [ $lang != $lang2 ]; then
				echo $lang' -- '$lang2' [ style=invis ];';
			fi;
		done;
	done;
done >> ../dicts.dot

echo '}' >> ../dicts.dot;

# render graph
cat ../dicts.dot | neato -Tgif > ../dicts.gif

# resize and merge with legend
HEIGHT=`convert ../dicts.gif info: | sed s/'^[^ ]* GIF [0-9]*x\([0-9]*\) .*'/'\1'/`;
convert -resize x$HEIGHT ../legend.gif ../legend-shrunk.gif
convert ../dicts.gif ../legend-shrunk.gif +append ../dicts-w-legend.gif