OntoLex-lemon conversion of *all* Apertium languages from https://github.com/apertium/apertium-trunk

Data structure and URI schema follows the earlier conversion used at TIAD-2019 (http://tiad2019.unizar.es/, see there for details).

We deviate in the following aspects:
- Conversion from native data rather than via historical LMF editions.
- Conversion of all language pairs instead of only Romance + English + Basque
- Monnet-lemon updated to OntoLex-lemon.
- Indirect mapping to lexinfo (not yet: to be provided as separate owl:sameAs statements).
- Use BCP47 language codes for identifying languages (rather than original/ISO-693-3 language codes).

content
-------
apertium-rdf-2019-02-03/
	RDF and TSV editions of the data
apertium.ttl
	morphosyntactic specifications	
build.sh
	build script, run only to update
*xsl, *sparql
	aux files for build script
sed/
	ISO-639-3 standard with mappings to ISO-639-2 and ISO-639-1, used for normalizing language identifiers during building
LICENSE_CODE
	license for build script
LICENSE_DATA
	Original license of Apertium data sets, GNU GPL 3.0
	We maintain the license for generated data.
	
copyright
---------
The provided scripts are under the Apache license 2.0, see LICENSE_CODE.
The included data maintains its original copyright, i.e., GNU GPL 3.0, see LICENSE_DATA.
The individual AUTHORS files (where provided) have been merged in AUTHORS.

howto (rebuild/refresh)
-----------------------
- Make sure you have internet access, java, svn, wget, and a Un*x shell (tested under Cygwin)
- Make sure you have Apache Jena's arq (or another SPARQL engine) installed, set its path in ./build.sh
- Make sure you have Saxon (or another XSLT 2.0+ processor) installed, set its path in ./build.sh
- Run ./build.sh on a Un*x shell.
- For every language pair, this produces a TSV file conformant with TIAD-2019 specs, and a zip file with the underlying TTL data.
- The script also creates apertium.ttl which holds all morphosyntactic features and their labels (merged from all files).
- The script compiles AUTHORS from the individual source directories.

todos & known issues
--------------------
- No proper metadata, yet.
- Later re-builds should check Apertium COPYING files and update the corresponding files here.
- We do not provide a mapping to lexinfo categories, yet. This should be provided by an external file comprising owl:sameAs statements.
- arq 3.9.0 didn't load the generated Apertium-eu-es_LexiconEU.ttl. However, this is not a TTL error: The TSV file included was generated from TTL using BlazeGraph (Build Version=1.5.3) and curl:
	$> curl -X POST http://localhost:9999/bigdata/sparql --data-urlencode 'query=# return TSV file as used for TIAD-2019

	PREFIX apertium: <http://wiki.apertium.org/wiki/Bidix#>
	PREFIX dc: <http://purl.org/dc/elements/1.1/>
	PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
	PREFIX foaf: <http://xmlns.com/foaf/0.1/>
	PREFIX lexinfo: <http://www.lexinfo.net/ontology/2.0/lexinfo#>
	PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
	PREFIX owl: <http://www.w3.org/2002/07/owl#>
	PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
	PREFIX ontolex: <http://www.w3.org/ns/lemon/ontolex#>
	PREFIX lime: <http://www.w3.org/ns/lemon/lime#>
	PREFIX vartrans: <http://www.w3.org/ns/lemon/vartrans#>

	SELECT ?srep ?slex ?ssense ?trans ?tsense ?tlex ?turi ?trep ?pos
	WHERE {
	?trans vartrans:source ?ssense; vartrans:target ?tsense.
	?ssense ontolex:isSenseOf ?slex.
	?slex ontolex:lexicalForm/ontolex:writtenRep ?srep.
	?tsense ontolex:isSenseOf ?tlex.
	?tlex ontolex:lexicalForm/ontolex:writtenRep ?trep.
	OPTIONAL {
	?slex ontolex:morphosyntacticProperty ?pos.
	}
	}' -H 'Accept:text/tab-separated-values' > trans_EU-ES.tsv



history
-------
- 2019-02-03 initial release (CC)

contributors
------------
CC - Christian Chiarcos, christian.chiarcos@web.de
AP - Apertium authors (of the source data), see AUTHORS