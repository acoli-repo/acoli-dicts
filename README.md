# ACoLi Dicts
Ontolex-lemon dictionaries provided by the Applied Computational Linguistics (ACoLi) lab at Goethe Universität Frankfurt am Main, Germany, and the associated research group Linked Open Dictionaries (LiODi, 2015-2020)

The project "Linked Open Dictionaries" (LiODi, 2015-2020) is a BMBF-funded research group run by the Applied Computational Linguistics (ACoLi) lab in collaboration with the Institute for Empirical Linguistics at Goethe University Frankfurt. It aims at creating Linked Open Data representations of dictionaries and the development of an infrastructure and methodologies for their practical application in language contact studies, mostly in Eurasia and the Caucasus area. See http://acoli.informatik.uni-frankfurt.de/liodi for details. As a technical basis, we employ lemon/ontolex (https://www.w3.org/2016/05/ontolex/) for data modelling, OLiA (http://purl.org/olia) for representing grammatical information, lexvo (http://lexvo.org) for ISO 639 language identifiers and glottolog (http://glottolog.org) for identifiers of non-ISO-639 language varieties.

At the moment, we provide OntoLex-lemon and TIAD-TSV editions of open source dictionaries for 133 language varieties and 422 language pairs (stable and experimental), see statistics below.
Additional data has been converted, but is still awaiting copyright clearance.

![dictionary graph](https://raw.githubusercontent.com/acoli-repo/acoli-dicts/master/dicts-w-legend.gif "Dictionary graph, stable and experimental (dotted lines)")

## Overview
| &nbsp; | languages |  language pairs | license |  OntoLex/RDF data | TIAD/TSV data| comments |
|--|--|--|--|--|--|--|
|Apertium  | 46 | 55 | GPL | https://github.com/acoli-repo/acoli-dicts/tree/master/stable/apertium/apertium-rdf-2019-02-03 (*.rdf.zip) | https://github.com/acoli-repo/acoli-dicts/tree/master/stable/apertium/apertium-rdf-2019-02-03/ (trans*tsv.gz) | modeling based on http://linguistic.linkeddata.es/apertium/, designed for machine translation |
|FreeDict | 45 | 145 | GPL | https://github.com/acoli-repo/acoli-dicts/tree/master/stable/freedict/freedict-rdf-2019-02-05 (\*/*.ttl.gz) | https://github.com/acoli-repo/acoli-dicts/tree/master/stable/freedict/freedict-rdf-2019-02-05 (\*/*.tsv.gz) | plain word lists, user-generated content |
|DBnary | 119* | 275* | CC-BY-SA 3.0 | http://kaiko.getalp.org/ (external) | https://github.com/acoli-repo/acoli-dicts/tree/master/stable/dbnary/dbnary-tiad-2019-02-16 (\*.tsv.gz) | * counted only language pairs with 10,000 entries, user-generated content |
|XDXF | 51 | 107 | GPL |https://github.com/acoli-repo/acoli-dicts/tree/master/experimental/xdxf/xdxf-rdf-2019-02-22 (\*/\*.ttl.gz) | https://github.com/acoli-repo/acoli-dicts/tree/master/experimental/xdxf/xdxf-rdf-2019-02-22 (\*/\*.tsv.gz) | experimental |
| **total** | **133** | **422**

## subdirectories

stable/
data releases

experimental/ 
work in progress, contains converters, original data and resulting data by several individual contributors, including student projects
@students/contributors: please create your personal subdirectories here

## contributors

t.b.a.

