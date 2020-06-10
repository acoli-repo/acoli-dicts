
# PanLex database dump: OntoLex-lemon and TIAD-TSV conversion of https://panlex.org/snapshot/

OntoLex-lemon conversion of *all* PanLex sources from https://panlex.org/snapshot/, using the CSV dump as a basis

dataset description 
--
(from https://panlex.org/)
PanLex is building the world’s largest lexical database

- What we do
For over 10 years we have been building the world’s largest lexical translation database, and we keep adding new words and languages all the time. By transforming thousands of translation dictionaries into a single common structure, the PanLex database makes it possible to derive billions of lexical translations that are not found in any single dictionary.
- Why it matters so much
There is a growing divide between the opportunities available to speakers of major languages and to those who speak under-served languages. Making translation dictionaries and technology available in under-served languages helps speakers exercise their rights and access equal opportunities, while supporting their social, cultural, and economic well-being.
- How we are different from Google Translate
Google Translate and other machine translation applications translate whole sentences and texts in up to a hundred major world languages. PanLex translates words in thousands of languages. Our database is **panlingual** (emphasizes coverage of every language) and **lexical** (focuses on words, not sentences). The data is [free and open](https://panlex.org/license/).
- Current database coverage
	- 2,500 dictionaries
	- 5,700 languages
	- 25,000,000 words
	- 1,300,000,000 translations

repository content
-------
- panlex-20191001-csv-rdf/
	OntoLex-Lemon conversion for the dump from 2019-10-01
	RDF/XML, gzipped
	note: due to size limitations, 10 files cannot be uploaded to GitHub
- biling-tsv/
	TIAD-TSV extract provided as bilingual word lists aggegated over all PanLex sources (including those not contained in the RDF dump).
	The original source can be recovered from the URI and the RDF dump.
- doc/
	documentation
- build.sh
	build script, calls the following commands
- PanLex.java
	splits the PanLex CSV dump into one document per source, encoded as XML ("PanLex XML")
	note that some aspects are slightly simplified. in particular, we only use ISO 639 language codes, not the more fine-grained PanLex codes
- xml2rdf.xsl
	convert one PanLex XML file to RDF/XML
- ontolex2tsv.sparql
	converts a PanLex OntoLex RDF file into a TIAD-TSV file, note that this is not filtered for a particular language pair
- TIADSplitter.java
	split series of multilingual TIAD-TSV files into bilingual dictionaries
- LICENSE_CODE
	license for build script
- LICENSE_DATA
	Original license of PanLex data (https://panlex.org/license/; CC0 1.0 Universal License, https://creativecommons.org/publicdomain/zero/1.0/),
	extended with an additional attribution for the generated data.
	
copyright
---------
The provided scripts are under the Apache license 2.0, see LICENSE_CODE.
The included data maintains the PanLex license, i.e. its original copyright, i.e., CC0 1.0 Universal License, https://creativecommons.org/publicdomain/zero/1.0/, see LICENSE_DATA. Like the PanLex providers, we ask for attribution, but this is not a license condition.
The individual PanLex sources may have additional license and/or attribution conditions, see the RDF files. The aggregated TIAD-TSV files follow the PanLex license.

todos & known issues
--------------------
- The build script requires manual download of source data. It is not fully automated.
- No LexInfo mapping of grammatical information, etc.
- For every language pair, TIADSplitter.java creates an output stream and keeps it open. Make sure to increase your system limits accordingly.
- During CSV parsing, we maintain ISO 639 language codes only, the more fine-grained PanLex language codes are lost.

history
-------
2020-01-30 metadata (CC)
2020-01-24 generated TIAD-TSV data (CF)
2020-01-19 generated OntoLex RDF data (CF)
2019-11-18 build scripts (CC)
2019-10-01 database dump taken as input (PL)

contributors
------------
CC - Christian Chiarcos, christian.chiarcos@web.de
CF - Christian Fäth
PL - PanLex contributors and editors (of the source data)

acknowledgments
---------------
Funded by the Horizon 2020 Research and Innovation Action "Pret-a-LLOD" (ERC, 2019-2021).
