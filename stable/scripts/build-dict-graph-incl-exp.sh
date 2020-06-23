#!/bin/bash
# no arguments, produces a dictionary/language graph for ACoLi dictionaries
# includes experimental content
# requires ImageMagick (convert) and dot/neato (GraphViz)

# color codes for dictionaries
APERTIUM=black;
DBNARY=gray;
FREEDICT=blue;
PANLEX=red;
MUSE=green;
# experimental = dotted
XDXF=red;
FREEDICT_DE=midnightblue;
STARDICT=green;

# build graph of connected dictionaries
(
for dir in ../freedict/*rdf*/*-*; do 
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
if [ -e ../panlex/biling-tsv/langtab.tsv ]; then
	egrep '[0-9][0-9][0-9][0-9][0-9]$' ../panlex/biling-tsv/langtab.tsv | \
	sed -e s/'.*\/\([a-z][a-z]*\)-\([a-z][a-z]*\).tsv.*'/'\1\t\2\tcolor='$PANLEX/g;
fi;
for file in ../muse/*rdf*/*-*.ttl; do
	echo $file | \
	sed -e s/'.*\/'//g -e s/'\..*'// -e s/'\-'/'\t'/g -e s/'$'/'\tcolor='$MUSE/g;
done;

# experimental stuff
for file in ../../experimental/xdxf/*rdf*/*-*; do
	if [ -d $file ]; then
		echo $file | \
		egrep '.*\/[a-z][a-z][a-z]*-[a-z][a-z][a-z]*$' | \
		sed -e s/'.*\/'//g \
			-e s/'^\([a-z]*\)-\([a-z]*\)$'/'\1\t\2\tcolor='$XDXF', style=dotted'/g;
	fi;
done;
for file in ../../experimental/free-dict.de/*/*-*.tsv.gz; do
	echo $file | \
	sed -e s/'^.*\/\([a-z]*\)-\([a-z]*\).tsv.gz$'/'\1\t\2\tcolor='$FREEDICT_DE', style=dotted'/g;
done;
for dir in `ls  ../../experimental/stardict/star*/*/*tsv.gz | sed s/'\/[^\/]*$'// | uniq`; do
	echo $dir | \
	perl -pe 's/^.*\/([a-z]+)(-[^_\/]*)?_([a-z]+)[^a-z\/][^\/]*/$1\t$3\tcolor='$STARDICT', style=dotted\n/g;'
done;
) | \
bash langs2dot.sh | egrep '[a-zA-Z]' > ../../dicts.dot;

# add language coloring (for known languages)
GERMANIC=gray56;
CELTIC=gray65;
ROMANCE=gray79;
ITALIC=gray79;
SLAVIC=gray87;
BALTIC=gray88;
IRANIAN=gray89;
INDIAN=gray90;
OTHER_IE=gray91;
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
echo 'Apertium -- X [color='$APERTIUM'];'
echo 'FreeDict -- X [color='$FREEDICT'];'
echo 'DBnary -- X [color='$DBNARY'];'
echo 'PanLex -- X [color='$PANLEX'];'
echo 'MUSE -- X [color='$MUSE'];'
echo 'X -- XDXF [color='$XDXF', style=dotted];'
echo 'X -- FreeDictDe [color='$FREEDICT_DE', style=dotted];'
echo 'X -- StarDict [color='$STARDICT', style=dotted];'
echo 'Apertium [color=white];'
echo 'FreeDict [color=white];'
echo 'DBnary [color=white];'
echo 'PanLex [color=white];'
echo 'MUSE [color=white];'
echo 'XDXF [color=white];'
echo 'StarDict [color=white];'
echo 'FreeDictDe [label="free-dict.de", color=white];'

echo 'OTHER -- PanLex [style=invis];'
echo 'PanLex -- Apertium [style=invis];'
echo 'Apertium -- FreeDict [style=invis];'
echo 'PanLex -- DBnary [style=invis];'
echo 'DBnary -- MUSE [style=invis];'

echo 'FreeDict -- FreeDictDe [style=invis];'
echo 'MUSE -- XDXF [style=invis];'
echo 'FreeDictDe -- StarDict [style=invis];'
echo 'XDXF -- StarDict [style=invis];'

echo '}'
) | \
#egrep -n '^'
dot -Tgif > ../../legend.gif


cat ../../dicts.dot | grep ' -' | sed s/'\[.*'// | sed s/'\s'/'\n'/g | egrep '[a-z]' | sort -u | \
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
	s/^(yi)$/$1 [style=filled,fillcolor='$GERMANIC'];/g;
	s/^(got)$/$1 [style=filled,fillcolor='$GERMANIC'];/g;
	s/^(frs)$/$1 [style=filled,fillcolor='$GERMANIC'];/g;
	s/^(gsw)$/$1 [style=filled,fillcolor='$GERMANIC'];/g;
	s/^(li)$/$1 [style=filled,fillcolor='$GERMANIC'];/g;
	s/^(pdt)$/$1 [style=filled,fillcolor='$GERMANIC'];/g;
	s/^(stq)$/$1 [style=filled,fillcolor='$GERMANIC'];/g;
	s/^(ydd)$/$1 [style=filled,fillcolor='$GERMANIC'];/g;
		# frs	GERMANIC	Eastern Frisian
		# gsw	GERMANIC	Swiss German
		# li	GERMANIC	Limburgian
		# pdt	GERMANIC	Plautdietsch
		# stq	GERMANIC	Saterfriesisch
		# ydd	GERMANIC	Eastern Yiddish

	# Germanic-based creoles
	s/^(rop)$/$1 [style=filled,fillcolor='$GERMANIC'];/g;
	s/^(tpi)$/$1 [style=filled,fillcolor='$GERMANIC'];/g;
		# rop	none	Kriol
		# tpi	none	Tok Pisin
	
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
	s/^(vec)$/$1 [style=filled,fillcolor='$ROMANCE'];/g;
	s/^(wa)$/$1 [style=filled,fillcolor='$ROMANCE'];/g;
	s/^(fro)$/$1 [style=filled,fillcolor='$ROMANCE'];/g;
	s/^(lld)$/$1 [style=filled,fillcolor='$ROMANCE'];/g;
	s/^(lmo)$/$1 [style=filled,fillcolor='$ROMANCE'];/g;
	s/^(nap)$/$1 [style=filled,fillcolor='$ROMANCE'];/g;
	s/^(pcd)$/$1 [style=filled,fillcolor='$ROMANCE'];/g;
	s/^(tzl)$/$1 [style=filled,fillcolor='$ROMANCE'];/g;
	s/^(xno)$/$1 [style=filled,fillcolor='$ROMANCE'];/g;
	s/^(lij)$/$1 [style=filled,fillcolor='$ROMANCE'];/g;
		# fro	ROMANCE	Old French
		# lld	ROMANCE	Ladin
		# lmo	ROMANCE	Lombard
		# nap	ROMANCE	Napoletano-Calabrese
		# pcd	ROMANCE	Picard
		# tzl	ROMANCE	Talossan
		# xno	ROMANCE	Anglo-Norman
		# lij	ROMANCE	Ligurian

	# Romance-based creols
	s/^pap$/pap [style=filled,fillcolor='$ROMANCE'];/g;
	s/^ht$/ht [style=filled,fillcolor='$ROMANCE'];/g;

	# Italic
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
	s/^scc$/scc [style=filled,fillcolor='$SLAVIC'];/g;  # Serbo-Croatian/Serbian, deprecated
	s/^scr$/scr [style=filled,fillcolor='$SLAVIC'];/g;  # Serbo-Croatian/Croatian, deprecated
	s/^bs$/bs [style=filled,fillcolor='$SLAVIC'];/g;	# Bosnian
	
	# Baltic
	s/^lt$/lt [style=filled,fillcolor='$BALTIC'];/g;
	s/^ltg$/ltg [style=filled,fillcolor='$BALTIC'];/g;
	s/^lv$/lv [style=filled,fillcolor='$BALTIC'];/g;
	s/^lvs$/lvs [style=filled,fillcolor='$BALTIC'];/g;
		# lvs	BALTIC	Standard Latvian
	
	# Celtic
	s/^br$/br [style=filled,fillcolor='$CELTIC'];/g;
	s/^cy$/cy [style=filled,fillcolor='$CELTIC'];/g;
	s/^ga$/ga [style=filled,fillcolor='$CELTIC'];/g;
	s/^gd$/gd [style=filled,fillcolor='$CELTIC'];/g;
	s/^(gv)$/$1 [style=filled,fillcolor='$CELTIC'];/g;
	s/^(kw)$/$1 [style=filled,fillcolor='$CELTIC'];/g;
	s/^(cnx)$/$1 [style=filled,fillcolor='$CELTIC'];/g;
	s/^(oco)$/$1 [style=filled,fillcolor='$CELTIC'];/g;
		# cnx	CELTIC	Middle Cornish
		# oco	CELTIC	Old Cornish

	# Iranian
	s/^fa$/fa [style=filled,fillcolor='$IRANIAN'];/g;
	s/^ku$/ku [style=filled,fillcolor='$IRANIAN'];/g;
	s/^ps$/ps [style=filled,fillcolor='$IRANIAN'];/g;
	s/^rom$/rom [style=filled,fillcolor='$IRANIAN'];/g;
	s/^(tg)$/$1 [style=filled,fillcolor='$IRANIAN'];/g;
	s/^(zza)$/$1 [style=filled,fillcolor='$IRANIAN'];/g;
	s/^(ckb)$/$1 [style=filled,fillcolor='$IRANIAN'];/g;
	s/^(kmr)$/$1 [style=filled,fillcolor='$IRANIAN'];/g;
	s/^(pes)$/$1 [style=filled,fillcolor='$IRANIAN'];/g;
		# ckb	IRANIAN	Central Kurdish
		# kmr	IRANIAN	Northern Kurdish
		# pes	IRANIAN	Western Persian

	# Indian
	s/^as$/as [style=filled,fillcolor='$INDIAN'];/g;
	s/^bn$/bn [style=filled,fillcolor='$INDIAN'];/g;
	s/^hi$/hi [style=filled,fillcolor='$INDIAN'];/g;
	s/^mr$/mr [style=filled,fillcolor='$INDIAN'];/g;
	s/^(sa)$/$1 [style=filled,fillcolor='$INDIAN'];/g;
	s/^(ur)$/$1 [style=filled,fillcolor='$INDIAN'];/g;
	s/^(ks)$/$1 [style=filled,fillcolor='$INDIAN'];/g;
	s/^(ory)$/$1 [style=filled,fillcolor='$INDIAN'];/g;
	s/^(pa)$/$1 [style=filled,fillcolor='$INDIAN'];/g;
	s/^(sd)$/$1 [style=filled,fillcolor='$INDIAN'];/g;
	s/^(thq)$/$1 [style=filled,fillcolor='$INDIAN'];/g;
		# ks	INDIAN	Kashmiri
		# ory	INDIAN	Odia
		# pa	INDIAN	Eastern Punjabi
		# sd	INDIAN	Sindhi
		# thq	INDIAN	

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
	s/^(he)$/$1 [style=filled,fillcolor='$SEMITIC'];/g;
	s/^(mt)$/$1 [style=filled,fillcolor='$SEMITIC'];/g;
	s/^(arb)$/$1 [style=filled,fillcolor='$SEMITIC'];/g;
	s/^(taq)$/$1 [style=filled,fillcolor='$SEMITIC'];/g;
		# arb	SEMITIC	Standard Arabic
		# taq	SEMITIC	Tamasheq proper

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
	s/^(azj)$/$1 [style=filled,fillcolor='$ALTAIC'];/g;
	s/^(khk)$/$1 [style=filled,fillcolor='$ALTAIC'];/g;
	s/^(uzn)$/$1 [style=filled,fillcolor='$ALTAIC'];/g;
	s/^(xal)$/$1 [style=filled,fillcolor='$ALTAIC'];/g;
		# azj	ALTAIC	North Azerbaijani
		# khk	ALTAIC	Halh Mongolian
		# uzn	ALTAIC	Northern Uzbek
		# xal	ALTAIC	Kalmyk-Oirat

	# AMERICA
	s/^(nv)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(qu)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(ayr)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(boa)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(chy)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(ciw)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(crj)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(cv)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(gu)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(iu)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(ktw)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(nci)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(omq)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(quh)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(qus)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(quy)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(quz)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(qve)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(qvi)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(shh)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
	s/^(yua)$/$1 [style=filled,fillcolor='$AMERICA'];/g;
		# ayr	AMERICA	Central Aymara
		# boa	AMERICA	Bora
		# chy	AMERICA	Cheyenne
		# ciw	AMERICA	Chippewa
		# crj	AMERICA	Southern East Cree
		# cv	AMERICA	Chuvash
		# gu	AMERICA	Gujarati
		# iu	AMERICA	Inuktitut
		# ktw	AMERICA	Kato
		# nci	AMERICA	Classical Nahuatl
		# omq	AMERICA	
		# quh	AMERICA	South Bolivian Quechua
		# qus	AMERICA	Santiago del Estero Quichua
		# quy	AMERICA	Ayacucho Quechua
		# quz	AMERICA	Cusco Quechua
		# qve	AMERICA	Eastern Apurímac Quechua
		# qvi	AMERICA	Imbabura Highland Quichua
		# shh	AMERICA	Shoshoni
		# yua	AMERICA	Yucatec Maya
	
	# CAUCASIAN
	# SW CAUC
	s/^ka$/ka [style=filled,fillcolor='$CAUCASIAN'];/g;
	# NW CAUC
	s/^abq$/abq [style=filled,fillcolor='$CAUCASIAN'];/g;
	# NE CAUC
	s/^udi$/udi [style=filled,fillcolor='$CAUCASIAN'];/g;

	# DRAVIDIAN
	s/^ml$/ml [style=filled,fillcolor='$DRAVIDIAN'];/g;
	s/^ta$/ta [style=filled,fillcolor='$DRAVIDIAN'];/g;
	s/^te$/te [style=filled,fillcolor='$DRAVIDIAN'];/g;
	s/^kn$/kn [style=filled,fillcolor='$DRAVIDIAN'];/g;
		# kn	DRAVIDIAN	Kannada

	
	# URALIC
	s/^et$/et [style=filled,fillcolor='$URALIC'];/g;
	s/^fi$/fi [style=filled,fillcolor='$URALIC'];/g;
	s/^(hu)$/$1 [style=filled,fillcolor='$URALIC'];/g;
	s/^(se)$/$1 [style=filled,fillcolor='$URALIC'];/g;
	s/^(ekk)$/$1 [style=filled,fillcolor='$URALIC'];/g;
	s/^(fkv)$/$1 [style=filled,fillcolor='$URALIC'];/g;
	s/^(mdf)$/$1 [style=filled,fillcolor='$URALIC'];/g;
	s/^(mhr)$/$1 [style=filled,fillcolor='$URALIC'];/g;
	s/^(myv)$/$1 [style=filled,fillcolor='$URALIC'];/g;
	s/^(sma)$/$1 [style=filled,fillcolor='$URALIC'];/g;
	s/^(smj)$/$1 [style=filled,fillcolor='$URALIC'];/g;
		# ekk	URALIC	Standard Estonian
		# fkv	URALIC	Kven Finnish
		# mdf	URALIC	Moksha
		# mhr	URALIC	Eastern Mari
		# myv	URALIC	Erzya
		# sma	URALIC	Southern Sami
		# smj	URALIC	Lule Sami
	
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
	s/^(vi)$/$1 [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^(zh)$/$1 [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^(cng)$/$1 [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^(dz)$/$1 [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^(hak)$/$1 [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^(ii)$/$1 [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^(ltc)$/$1 [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^(lus)$/$1 [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^(npi)$/$1 [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^(ryu)$/$1 [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^(txg)$/$1 [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^(xug)$/$1 [style=filled,fillcolor='$EAST_ASIA'];/g;
	s/^(zyg)$/$1 [style=filled,fillcolor='$EAST_ASIA'];/g;
			# cng	EAST_ASIA	Northern Qiang
			# dz	EAST_ASIA	Dzongkha
			# hak	EAST_ASIA	Hakka Chinese
			# ii	EAST_ASIA	Sichuan Yi
			# ltc	EAST_ASIA	Late Middle Chinese
			# lus	EAST_ASIA	Lushai
			# npi	EAST_ASIA	Nepali proper
			# ryu	EAST_ASIA	Central Okinawan
			# txg	EAST_ASIA	Tangut
			# xug	EAST_ASIA	Kunigami
			# zyg	EAST_ASIA	Yang Zhuang

	
	
	# PACIFIC
	s/^id$/id [style=filled,fillcolor='$PACIFIC'];/g;
	s/^mi$/mi [style=filled,fillcolor='$PACIFIC'];/g;
	s/^ms$/ms [style=filled,fillcolor='$PACIFIC'];/g;
	s/^tl$/tl [style=filled,fillcolor='$PACIFIC'];/g;
	s/^(wim)$/$1 [style=filled,fillcolor='$PACIFIC'];/g;
	s/^(zlm)$/$1 [style=filled,fillcolor='$PACIFIC'];/g;
	s/^(bmu)$/$1 [style=filled,fillcolor='$PACIFIC'];/g;
	s/^(dhg)$/$1 [style=filled,fillcolor='$PACIFIC'];/g;
	s/^(ksr)$/$1 [style=filled,fillcolor='$PACIFIC'];/g;
	s/^(mh)$/$1 [style=filled,fillcolor='$PACIFIC'];/g;
	s/^(mpj)$/$1 [style=filled,fillcolor='$PACIFIC'];/g;
	s/^(mrw)$/$1 [style=filled,fillcolor='$PACIFIC'];/g;
	s/^(plt)$/$1 [style=filled,fillcolor='$PACIFIC'];/g;
	s/^(tet)$/$1 [style=filled,fillcolor='$PACIFIC'];/g;
	s/^(zsm)$/$1 [style=filled,fillcolor='$PACIFIC'];/g;
		# bmu	PACIFIC	Somba-Siawari
		# dhg	PACIFIC	Dhangu-Djangu
		# ksr	PACIFIC	Borong
		# mh	PACIFIC	Marshallese
		# mpj	PACIFIC	Martu Wangka
		# mrw	PACIFIC	Maranao
		# plt	PACIFIC	Plateau Malagasy
		# tet	PACIFIC	Tetum
		# zsm	PACIFIC	Standard Malay
	
	# Subsaharic Africa
	s/^gba$/gba [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^sw$/sw [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^swh$/swh [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^wo$/wo [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(zdj)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(sgc)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(bm)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(bnt)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(bxk)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(dbu)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(dbw)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(dje)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(djm)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(dmb)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(dtk)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(dts)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(dtt)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(dym)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(fuf)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(fuh)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(gom)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(ig)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(io)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(koo)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(loz)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(lua)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(luq)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(nuj)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(nzz)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(sn)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
	s/^(yo)$/$1 [style=filled,fillcolor='$SUBSAHARIC'];/g;
			# bm	SUBSAHARIC	Bambara
			# bnt	SUBSAHARIC	Bantu Languages
			# bxk	SUBSAHARIC	Bukusu
			# dbu	SUBSAHARIC	Bondum Dom Dogon
			# dbw	SUBSAHARIC	Bankan Tey Dogon
			# dje	SUBSAHARIC	Zama
			# djm	SUBSAHARIC	Jamsay Dogon
			# dmb	SUBSAHARIC	Mombo Dogon
			# dtk	SUBSAHARIC	Tene Kan Dogon
			# dts	SUBSAHARIC	Toro So Dogon
			# dtt	SUBSAHARIC	Toro Tegu Dogon
			# dym	SUBSAHARIC	Yanda Dom Dogon
			# fuf	SUBSAHARIC	Pular
			# fuh	SUBSAHARIC	Western Niger Fulfulde
			# gom	SUBSAHARIC	Goan Konkani
			# ig	SUBSAHARIC	Igbo
			# io	SUBSAHARIC	Ido
			# koo	SUBSAHARIC	
			# loz	SUBSAHARIC	Loze
			# lua	SUBSAHARIC	Luba-Lulua
			# luq	SUBSAHARIC	Lucumi
			# nuj	SUBSAHARIC	Nyole
			# nzz	SUBSAHARIC	Nanga Dama Dogon
			# sn	SUBSAHARIC	Shona
			# yo	SUBSAHARIC	Yoruba


	# unclassified (isolates and constructed languages
		# eo	none	Esperanto
		# eu	none	Basque
		# ia	none	Interlingua
		# ie	none	Interlingue
		# jbo	none	Lojban
		# lfn	none	Lingua Franca Nova
	
' | grep color >> ../../dicts.dot;

# cluster for language groups (well, colors ;)
COLORS=`cat ../../dicts.dot | egrep 'fillcolor=' | sed -e s/'.*fillcolor='// -e s/'[^a-z0-9A-Z].*'// | sort -u`;

for i in {1..4}; do
	for color in $COLORS; do
		LANGS=`cat ../../dicts.dot | egrep 'fillcolor='$color | sed -e s/'^[^a-z]*'//g -e s/'[^a-z].*'//g`;
		for lang in $LANGS; do
			for lang2 in $LANGS; do
				if [ $lang != $lang2 ]; then
					echo $lang' -- '$lang2' [ style=invis ];';
				fi;
			done;
		done;
	done >> ../../dicts.dot
done;
	
echo '}' >> ../../dicts.dot;

# render graph
cat ../../dicts.dot | neato -Tgif > ../../dicts.gif

# resize and merge with legend
HEIGHT=`convert ../../dicts.gif info: | sed s/'^[^ ]* GIF [0-9]*x\([0-9]*\) .*'/'\1'/`;
convert -resize x$HEIGHT ../../legend.gif ../../legend-shrunk.gif
convert ../../dicts.gif ../../legend-shrunk.gif +append ../../dicts-w-legend.gif