OntoLex-lemon conversion of FreeDict dictionaries

Note that these dictionaries do not contain grammatical information. Therefore, translations are *implicitly* modeled as rdfs:labels of senses.
We also provide TSV files according to TIAD-2019 specs, with undefined URIs omitted.

content
-------
freedict-rdf-2019-02-05/
	release data
build.sh
	build script
freedict2ontolex.xsl, ontolex2tsv.sparql
	aux. scripts for build.sh
sed
	ISO-639-3 language mappings
	
copyright
---------
The provided scripts are under the Apache license 2.0, see LICENSE.
The included data maintains its original copyright, see LICENSE and AUTHOR files at the individual language pairs.

howto (rebuild/refresh)
-----------------------
- Make sure you have internet access, java, wget, and a Un*x shell (tested under Cygwin)
- Make sure you have Apache Jena's arq (or another SPARQL engine) installed, set its path in ./build.sh
- Make sure you have Saxon (or another XSLT 2.0+ processor) installed, set its path in ./build.sh
- Run ./build.sh on a Un*x shell.
- For every language pair, this produces a TSV file conformant with TIAD-2019 specs, a zip file with RDF data and a zip file with the original TEI data.

todos & known issues
--------------------
- No proper metadata, yet.
- TTL conversion failed for 1% of the data (for 2 language pairs: ar-en and en-pl; but en-ar, pl-en are ok)
- TSV export failed for 5% of the data (8 of 147 language pairs):
	* failed, but reverse is ok
		ar-en, en-pl
	* failed, no reverse
		en-el, es-ast, mk-bg, oc-ca, en-swh, swh-en

history
-------
- 2019-02-05 initial release (CC)

contributors
------------
CC - Christian Chiarcos, christian.chiarcos@web.de
FD - FreeDict authors (of the source data), see AUTHORS and ChangeLogs