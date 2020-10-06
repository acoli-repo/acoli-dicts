DBnary TIAD export

DBnary (http://kaiko.getalp.org/about-dbnary/) is an OntoLex-lemon and LMF edition of selected Wiktionary data sets and is distributed under Creative Commons Attribution-ShareAlike 3.0 developed by Gilles Sérasset.

Sérasset Gilles (2014). DBnary: Wiktionary as a Lemon-Based Multilingual Lexical Resource in RDF. to appear in Semantic Web Journal (special issue on Multilingual Linked Open Data). [pdf]

The OntoLex edition deviates from the 2016 final report in that translations are modelled in a resource-specific way. Here, our contribution is not the RDF edition, but the TIAD export, and only this data is provided.

dbnary-tiad-2019-02-16/
	contains the TIAD edition of the data, divided into language pairs as *tsv.gz files
	Dictionaries with less than 10000 entries are provided in small-pairs_less-than-10000-entries-each.zip. These are not shown in the diagram.

build.sh
	build script for the TIAD export, requires Apache Jena to be installed

dbnary2tsv.sparql
	helper script for build.sh, defines the actual TIAD extraction
	
build.log
	log of the last build, contains the number of source language entries for all language pairs

Note that DBnary data is automatically extracted from a community-maintained resource. In comparison to many other dictionaries, its data is less reliable because (a) the original data is created and maintained by a community of amateurs, not lexicographers, and (b) the extraction is done automatically, and extraction errors do occur. These have not been corrected in this edition.

Acknowledgements:
The conversion to TIAD-TSV bidictionaries has been conducted in the context of the Horizon 2020 Research and Innovation Action "Pret-a-LLOD" (2019-2021)

history:
2019-02-16 TIAD export (CC)

contributors:
CC - Christian Chiarcos (TIAD export)
GS - Gilles Sérasset (DBnary developer, incl. OntoLex) 
WN - Wiktionary contributors
