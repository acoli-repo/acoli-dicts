# ACoLi Dicts
Ontolex-lemon dictionaries provided by the Applied Computational Linguistics (ACoLi) lab at Goethe Universität Frankfurt am Main, Germany, and the associated research group Linked Open Dictionaries (LiODi, 2015-2020, funded by BMBF)

The stable release, provides OntoLex-lemon and TIAD-TSV editions of open source dictionaries for more than 400 language varieties and 2500 language pairs, see statistics below.
Additional data has been converted, but is still awaiting copyright clearance.

![dictionary graph](https://raw.githubusercontent.com/acoli-repo/acoli-dicts/master/stable/dicts-w-legend.gif "Dictionary graph")

## Overview
| &nbsp; | languages |  language pairs | license |  OntoLex/RDF data | TIAD/TSV data| comments |
|--|--|--|--|--|--|--|
|Apertium  | 46 | 55 | GPL | [apertium-rdf-2019-02-03](https://github.com/acoli-repo/acoli-dicts/tree/master/stable/apertium/apertium-rdf-2019-02-03) (*.rdf.zip) | [apertium-rdf-2019-02-03](https://github.com/acoli-repo/acoli-dicts/tree/master/stable/apertium/apertium-rdf-2019-02-03/) (trans*tsv.gz) | modeling based on http://linguistic.linkeddata.es/apertium/, designed for machine translation |
|FreeDict | 45 | 145 | GPL | [freedict-rdf-2019-02-05](https://github.com/acoli-repo/acoli-dicts/tree/master/stable/freedict/freedict-rdf-2019-02-05) (\*/*.ttl.gz) | (freedict-rdf-2019-02-05)[https://github.com/acoli-repo/acoli-dicts/tree/master/stable/freedict/freedict-rdf-2019-02-05] (\*/*.tsv.gz) | plain word lists, user-generated content |
|DBnary | 119* | 275* | CC-BY-SA 3.0 | [external](http://kaiko.getalp.org/) | [dbnary-tiad-2019-02-16](https://github.com/acoli-repo/acoli-dicts/tree/master/stable/dbnary/dbnary-tiad-2019-02-16) (\*.tsv.gz) | * counted only language pairs with >10k translations, user-generated content |
|PanLex | 194*| 1651*| CC0 | [panlex-20191001-csv-rdf](https://github.com/acoli-repo/acoli-dicts/tree/master/stable/panlex/panlex-20191001-csv-rdf) | [panlex/biling-tsv](https://github.com/acoli-repo/acoli-dicts/tree/master/stable/panlex/biling-tsv) | * only language pairs with >10k translations | 
|MUSE   | 45  | 107  | CC-BY-NC 4.0 | [muse-rdf-2020-06-12](muse/muse-rdf-2020-06-12) | [muse-tsv-2020-06-12](muse/muse-tsv-2020-06-12) | machine-generated, high-precision wordlist |
|Wikidata   | *  | *  | CC0 | [external](https://www.wikidata.org) | [wikidata-tsv-2020-06-24](wikidata/wikidata-tsv-2020-06-24) | * >400k translation pairs, > 90k language pairs, but very sparse  |
|OMW   | 34  | 40*  | open source | [external](http://compling.hss.ntu.edu.sg/omw/all+xml.zip) | [omw/tsv](omw/tsv) | * conservative estimate, restricted to combinations of OMW files with identical licenses |
| IDS  | 234* | 792* | CC-BY 4.0 | [ids/ontolex](ids/ontolex) | [ids/tsv](ids/tsv) | * counted only language pairs with >10k translations |
| **total** | **425** | **2546**
<!-- total numbers to be updated -->
