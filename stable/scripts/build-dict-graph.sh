#!/bin/bash
# no arguments, produces a dictionary/language graph for ACoLi dictionaries
# requires ImageMagick (convert) and dot/neato (GraphViz)

# color codes for dictionaries
FREEDICT=blue;
APERTIUM=black;
DBNARY=gray;

# build graph of connected dictionaries
(for dir in ../freedict/*rdf*/*-*; do 
	echo $dir | \
	sed -e s/'.*\/'//g -e s/'\-'/'\t'/g -e s/'$'/'\tcolor='$FREEDICT/g; 
done;
for file in ../apertium/*rdf*/apertium-*-rdf.zip; do
	echo $file | sed -e s/'.*\/apertium-'//g -e s/'-rdf.zip'// | \
	sed -e s/'.*\/'//g -e s/'\-'/'\t'/g -e s/'$'/'\tcolor='$APERTIUM/g; 
done;
for file in ../dbnary/dbnary-tiad*/*tsv.gz; do
	echo $file | sed -e s/'.*\/'//g -e s/'_dbnary.*'// | \
	sed -e s/'^\([a-z]*\)_\([a-z]*\)$'/'\1\t\2\tcolor='$DBNARY/g;
done;
) | \
bash langs2dot.sh | egrep '[a-zA-Z]' > ../dicts.dot;

# add language coloring (for known languages)
GERMANIC=gray56;
CELTIC=gray65;
ROMANCE=gray79;
ITALIC=gray79;
SLAVIC=gray88;
BALTIC=gray88;
IRANIAN=gray90;
INDIAN=gray91;
OTHER_IE=gray92;
SEMITIC=lightcoral;
ALTAIC=lightblue;
URALIC=khaki;
DRAVIDIAN=cyan;
CAUCASIAN=coral;
PACIFIC=green;
SUBSAHARIC=magenta;
EAST_ASIA=bisque;
AMERICA=darkkhaki;

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
echo 'CAUCASIAN [shape=box,style=filled,fillcolor='$CAUCASIAN'];'
echo 'DRAVIDIAN [shape=box,style=filled,fillcolor='$DRAVIDIAN'];'
echo 'AFROASIATIC [shape=box,style=filled,fillcolor='$SEMITIC'];'
echo 'ALTAIC [shape=box,style=filled,fillcolor='$ALTAIC'];'
echo 'URALIC [shape=box,style=filled,fillcolor='$URALIC'];'
echo 'PACIFIC [shape=box,style=filled,fillcolor='$PACIFIC'];'
echo 'EAST_ASIA [shape=box,style=filled, fillcolor='$EAST_ASIA'];'
echo 'SUBSAHARIC [shape=box,style=filled,fillcolor='$SUBSAHARIC'];'
echo 'AMERICA [shape=box,style=filled,fillcolor='$AMERICA'];'
echo 'OTHER [shape=box];'
echo 'GERMANIC -- CELTIC [style=invis];'
echo 'CELTIC -- ROMANCE [style=invis];'
echo 'ROMANCE -- ITALIC [style=invis];'
echo 'ITALIC -- BALTIC [style=invis];'
echo 'BALTIC -- SLAVIC [style=invis];'
echo 'SLAVIC -- IRANIAN [style=invis];'
echo 'IRANIAN -- INDIAN [style=invis];'
echo 'INDIAN -- OTHER_IE [style=invis];'
echo 'OTHER_IE -- CAUCASIAN [style=invis];'
echo 'CAUCASIAN -- URALIC [style=invis];'
echo 'URALIC -- ALTAIC [style=invis];'
echo 'ALTAIC -- PACIFIC [style=invis];'
echo 'PACIFIC -- EAST_ASIA [style=invis];'
echo 'EAST_ASIA -- DRAVIDIAN [style=invis];'
echo 'DRAVIDIAN -- AFROASIATIC [style=invis];'
echo 'AFROASIATIC -- SUBSAHARIC [style=invis];'
echo 'SUBSAHARIC -- AMERICA [style=invis];'
echo 'AMERICA -- OTHER [style=invis];'

# dictionaries
echo 'X [style=invis];'
echo 'X -- Apertium [color='$APERTIUM'];'
echo 'X -- FreeDict [color='$FREEDICT'];'
echo 'X -- DBnary [color='$DBNARY'];'
echo 'Apertium [color=white];'
echo 'FreeDict [color=white];'
echo 'DBnary [color=white];'
echo 'OTHER -- Apertium [style=invis];'
echo 'Apertium -- FreeDict [style=invis];'
echo 'FreeDict -- DBnary [style=invis];'

echo '}'
) | dot -Tgif > ../legend.gif


cat ../dicts.dot | grep ' -' | sed s/'\[.*'// | sed s/'\s'/'\n'/g | egrep '[a-z]' | sort -u | \
perl -pe '

	############################# 
	# Indo-European: grey-scale #
	#############################

	# Germanic
	s/^af$/af [style=filled,fillcolor='$GERMANIC'];/g;
	s/^ang$/ang [style=filled,fillcolor='$GERMANIC'];/g;
	s/^da$/da [style=filled,fillcolor='$GERMANIC'];/g;
	s/^de$/de [style=filled,fillcolor='$GERMANIC'];/g;
	s/^en$/en [style=filled,fillcolor='$GERMANIC'];/g;
	s/^fo$/fo [style=filled,fillcolor='$GERMANIC'];/g;
	s/^fy$/fy [style=filled,fillcolor='$GERMANIC'];/g;
	s/^is$/is [style=filled,fillcolor='$GERMANIC'];/g;
	s/^lb$/lb [style=filled,fillcolor='$GERMANIC'];/g;
	s/^nb$/nb [style=filled,fillcolor='$GERMANIC'];/g;
	s/^nl$/nl [style=filled,fillcolor='$GERMANIC'];/g;
	s/^nn$/nn [style=filled,fillcolor='$GERMANIC'];/g;
	s/^no$/no [style=filled,fillcolor='$GERMANIC'];/g;
	s/^sco$/sco [style=filled,fillcolor='$GERMANIC'];/g;
	s/^sv$/sv [style=filled,fillcolor='$GERMANIC'];/g;
	s/^yi/yi [style=filled,fillcolor='$GERMANIC'];/g;
		
	# Romance
	s/^an$/an [style=filled,fillcolor='$ROMANCE'];/g;
	s/^ast$/ast [style=filled,fillcolor='$ROMANCE'];/g;
	s/^ca$/ca [style=filled,fillcolor='$ROMANCE'];/g;
	s/^co$/co [style=filled,fillcolor='$ROMANCE'];/g;
	s/^es$/es [style=filled,fillcolor='$ROMANCE'];/g;
	s/^fr$/fr [style=filled,fillcolor='$ROMANCE'];/g;
	s/^fur$/fur [style=filled,fillcolor='$ROMANCE'];/g;
	s/^gl$/gl [style=filled,fillcolor='$ROMANCE'];/g;
	s/^it$/it [style=filled,fillcolor='$ROMANCE'];/g;
	s/^nrf$/nrf [style=filled,fillcolor='$ROMANCE'];/g;
	s/^oc$/oc [style=filled,fillcolor='$ROMANCE'];/g;
	s/^pt$/pt [style=filled,fillcolor='$ROMANCE'];/g;
	s/^rm$/rm [style=filled,fillcolor='$ROMANCE'];/g;
	s/^ro$/ro [style=filled,fillcolor='$ROMANCE'];/g;
	s/^rup$/rup [style=filled,fillcolor='$ROMANCE'];/g;
	s/^sc$/sc [style=filled,fillcolor='$ROMANCE'];/g;
	s/^scn$/scn [style=filled,fillcolor='$ROMANCE'];/g;
	s/^vec$/vec [style=filled,fillcolor='$ROMANCE'];/g;
	s/^wa$/wa [style=filled,fillcolor='$ROMANCE'];/g;


	# ITALIC
	s/^la$/la [style=filled,fillcolor='$ITALIC'];/g;

	# Slavic
	s/^be$/be [style=filled,fillcolor='$SLAVIC'];/g;
	s/^bg$/bg [style=filled,fillcolor='$SLAVIC'];/g;
	s/^cs$/cs [style=filled,fillcolor='$SLAVIC'];/g;
	s/^dsb$/dsb [style=filled,fillcolor='$SLAVIC'];/g;
	s/^hr$/hr [style=filled,fillcolor='$SLAVIC'];/g;
	s/^mk$/mk [style=filled,fillcolor='$SLAVIC'];/g;
	s/^pl$/pl [style=filled,fillcolor='$SLAVIC'];/g;
	s/^ru$/ru [style=filled,fillcolor='$SLAVIC'];/g;
	s/^sh$/sh [style=filled,fillcolor='$SLAVIC'];/g;
	s/^sk$/sk [style=filled,fillcolor='$SLAVIC'];/g;
	s/^sl$/sl [style=filled,fillcolor='$SLAVIC'];/g;
	s/^sr$/sr [style=filled,fillcolor='$SLAVIC'];/g;
	s/^sv$/sv [style=filled,fillcolor='$SLAVIC'];/g;
	s/^szl$/szl [style=filled,fillcolor='$SLAVIC'];/g;	# non-ISO code: Silesian (Polish dialect)
	s/^uk$/uk [style=filled,fillcolor='$SLAVIC'];/g;
	
	# Baltic
	s/^lt$/lt [style=filled,fillcolor='$BALTIC'];/g;
	s/^ltg$/ltg [style=filled,fillcolor='$BALTIC'];/g;
	s/^lv$/lv [style=filled,fillcolor='$BALTIC'];/g;

	# Celtic
	s/^br$/br [style=filled,fillcolor='$CELTIC'];/g;
	s/^cy$/cy [style=filled,fillcolor='$CELTIC'];/g;
	s/^ga$/ga [style=filled,fillcolor='$CELTIC'];/g;
	s/^gd$/gd [style=filled,fillcolor='$CELTIC'];/g;
	s/^gv$/gv [style=filled,fillcolor='$CELTIC'];/g;

	# Iranian
	s/^fa$/fa [style=filled,fillcolor='$IRANIAN'];/g;
	s/^ku$/ku [style=filled,fillcolor='$IRANIAN'];/g;
	s/^ps$/ps [style=filled,fillcolor='$IRANIAN'];/g;
	s/^rom$/rom [style=filled,fillcolor='$IRANIAN'];/g;
	s/^tg$/tg [style=filled,fillcolor='$IRANIAN'];/g;
	s/^zza$/zza [style=filled,fillcolor='$IRANIAN'];/g;
	
	# Indian
	s/^as$/as [style=filled,fillcolor='$INDIAN'];/g;
	s/^bn$/bn [style=filled,fillcolor='$INDIAN'];/g;
	s/^hi$/hi [style=filled,fillcolor='$INDIAN'];/g;
	s/^mr$/mr [style=filled,fillcolor='$INDIAN'];/g;
	s/^sa$/sa [style=filled,fillcolor='$INDIAN'];/g;
	s/^ur$/ur [style=filled,fillcolor='$INDIAN'];/g;
	
	# other Indo-European
	s/^el$/el [style=filled,fillcolor='$OTHER_IE'];/g;
	# s/^eo$/eo [style=filled,fillcolor='$OTHER_IE'];/g; # invented languages are other
	s/^grc$/grc [style=filled,fillcolor='$OTHER_IE'];/g;
	s/^hy$/hy [style=filled,fillcolor='$OTHER_IE'];/g;
	s/^sq$/sq [style=filled,fillcolor='$OTHER_IE'];/g;

	##########################
	# non-IE: various colors #
	##########################
	
	# Semitic
	s/^ar$/ar [style=filled,fillcolor='$SEMITIC'];/g;
	s/^arz$/arz [style=filled,fillcolor='$SEMITIC'];/g;
	s/^he$/he [style=filled,fillcolor='$SEMITIC'];/g;
	s/^mt$/mt [style=filled,fillcolor='$SEMITIC'];/g;
	
	# ALTAIC
	s/^az$/az [style=filled,fillcolor='$ALTAIC'];/g;
	s/^ba$/ba [style=filled,fillcolor='$ALTAIC'];/g;
	s/^crh$/crh [style=filled,fillcolor='$ALTAIC'];/g;
	s/^kk$/kk [style=filled,fillcolor='$ALTAIC'];/g;
	s/^ky$/ky [style=filled,fillcolor='$ALTAIC'];/g;
	s/^mn$/mn [style=filled,fillcolor='$ALTAIC'];/g;
	s/^tk$/tk [style=filled,fillcolor='$ALTAIC'];/g;
	s/^tr$/tr [style=filled,fillcolor='$ALTAIC'];/g;
	s/^tt$/tt [style=filled,fillcolor='$ALTAIC'];/g;
	s/^ug$/ug [style=filled,fillcolor='$ALTAIC'];/g;
	s/^uz$/uz [style=filled,fillcolor='$ALTAIC'];/g;

	# AMERICA
	s/^nv$/nv [style=filled,fillcolor='$AMERICA'];/g;
	s/^qu$/qu [style=filled,fillcolor='$AMERICA'];/g;

	# CAUCASIAN
	s/^ka$/ka [style=filled,fillcolor='$CAUCASIAN'];/g;

	# DRAVIDIAN
	s/^ml$/ml [style=filled,fillcolor='$DRAVIDIAN'];/g;
	s/^ta$/ta [style=filled,fillcolor='$DRAVIDIAN'];/g;
	s/^te$/te [style=filled,fillcolor='$DRAVIDIAN'];/g;

	
	# URALIC
	s/^et$/et [style=filled,fillcolor='$URALIC'];/g;
	s/^fi$/fi [style=filled,fillcolor='$URALIC'];/g;
	s/^hu$/hu [style=filled,fillcolor='$URALIC'];/g;
	s/^se$/se [style=filled,fillcolor='$URALIC'];/g;
	
	# EAST_ASIA
	s/^bo$/bo [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^cmn$/cmn [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^ja$/ja [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^kha$/kha [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^km$/km [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^ko$/ko [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^lo$/lo [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^my$/my [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^nan$/nan [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^th$/th [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^yue$/yue [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^vi$/vi [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^zh$/zh [style=filled,fillcolor='$EAST_ASIA'];/g;
	
	
	# PACIFIC
	s/^id$/id [style=filled,fillcolor='$PACIFIC'];/g;
	s/^mi$/mi [style=filled,fillcolor='$PACIFIC'];/g;
	s/^ms$/ms [style=filled,fillcolor='$PACIFIC'];/g;
	s/^tl$/tl [style=filled,fillcolor='$PACIFIC'];/g;
	s/^wim$/wim [style=filled,fillcolor='$PACIFIC'];/g;
	s/^zlm$/zlm [style=filled,fillcolor='$PACIFIC'];/g;
	
	# Subsaharic Africa
	s/^sw$/sw [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^swh$/swh [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^wo$/wo [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^zdj$/zdj [style=filled,fillcolor='$SUBSAHARIC'];/g;

	
	# # other # no color
	# s/^eu$/eu [style=filled,fillcolor=green];/g;
	# s/^ja$/ja [style=filled,fillcolor=green];/g;
	# s/^kha$/kha [style=filled,fillcolor=green];/g;
	
' | grep color >> ../dicts.dot;

# cluster for language groups (well, colors ;)
COLORS=`cat ../dicts.dot | egrep 'fillcolor=' | sed -e s/'.*fillcolor='// -e s/'[^a-z0-9A-Z].*'// | sort -u`;

for i in {1..4}; do
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
done;
	
echo '}' >> ../dicts.dot;

# render graph
cat ../dicts.dot | neato -Tgif > ../dicts.gif

# resize and merge with legend
HEIGHT=`convert ../dicts.gif info: | sed s/'^[^ ]* GIF [0-9]*x\([0-9]*\) .*'/'\1'/`;
convert -resize x$HEIGHT ../legend.gif ../legend-shrunk.gif
convert ../dicts.gif ../legend-shrunk.gif +append ../dicts-w-legend.gif