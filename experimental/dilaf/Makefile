all: xml

src:
	mkdir src
	cd src; \
	wget http://pagesperso.ls2n.fr/~enguehard-c/DiLAF/dicos/hau/telecharger_haoussa.zip; \
	wget http://pagesperso.ls2n.fr/~enguehard-c/DiLAF/dicos/bam/telecharger_bambara.zip; \
	wget http://pagesperso.ls2n.fr/~enguehard-c/DiLAF/dicos/kau/telecharger_kanouri.zip; \
	wget http://pagesperso.ls2n.fr/~enguehard-c/DiLAF/dicos/nou/telecharger_nouchi.zip; \
	wget http://pagesperso.ls2n.fr/~enguehard-c/DiLAF/dicos/tmh/telecharger_tamajaq.zip; \
	wget http://pagesperso.ls2n.fr/~enguehard-c/DiLAF/dicos/dje/telecharger_zarma.zip; \
	# wget http://pagesperso.ls2n.fr/~enguehard-c/DiLAF/dicos/wol/telecharger_wolof.zip; \
	# wol not downloadable

xml: src
	mkdir xml
	cd xml;\
	for file in ../src/*zip; do \
		unzip $$file;\
	done; 
	for dir in `find xml/ | egrep '.*\.pdf$$|\.xsl$$' | sed s/'\/[^\/]*$$'// | sort -u`; do \
		mv $$dir/*txt $$dir/*xml xml;\
		rm -rf $$dir;\
	done

