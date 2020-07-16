
# ACoLi Dicts
Ontolex-lemon dictionaries provided by the Applied Computational Linguistics (ACoLi) lab at Goethe Universität Frankfurt am Main, Germany, and the associated research group Linked Open Dictionaries (LiODi, 2015-2020)

The project "Linked Open Dictionaries" (LiODi, 2015-2020) is a BMBF-funded research group run by the Applied Computational Linguistics (ACoLi) lab in collaboration with the Institute for Empirical Linguistics at Goethe University Frankfurt. It aims at creating Linked Open Data representations of dictionaries and the development of an infrastructure and methodologies for their practical application in language contact studies, mostly in Eurasia and the Caucasus area. See http://acoli.informatik.uni-frankfurt.de/liodi for details. As a technical basis, we employ lemon/ontolex (https://www.w3.org/2016/05/ontolex/) for data modelling, OLiA (http://purl.org/olia) for representing grammatical information, lexvo (http://lexvo.org) for ISO 639 language identifiers and glottolog (http://glottolog.org) for identifiers of non-ISO-639 language varieties.

At the moment, we provide OntoLex-lemon and TIAD-TSV editions of open source dictionaries for more than 249 language varieties and 1768 language pairs (stable and experimental), with more than 2351 lexical data sets in total, see statistics below. Note that we exclude most smaller data sets (with less than 10,000 translation pairs) in these counts.
Additional data has been converted, but is still awaiting copyright clearance.

![dictionary graph](https://raw.githubusercontent.com/acoli-repo/acoli-dicts/master/dicts-w-legend.gif "Dictionary graph, stable and experimental (dotted lines)")

## Overview
| &nbsp; | languages |  lexical data sets | license |  OntoLex/RDF data | TIAD/TSV data| comments |
|--|--|--|--|--|--|--|
|Apertium  | 46 | 55 | GPL | [apertium/apertium-rdf-2019-02-03](https://github.com/acoli-repo/acoli-dicts/tree/master/stable/apertium/apertium-rdf-2019-02-03) (*.rdf.zip) | [apertium/apertium-rdf-2019-02-03](https://github.com/acoli-repo/acoli-dicts/tree/master/stable/apertium/apertium-rdf-2019-02-03) (trans*tsv.gz) | modeling based on http://linguistic.linkeddata.es/apertium/, designed for machine translation |
|FreeDict | 45 | 145 | GPL |[freedict/freedict-rdf-2019-02-05](https://github.com/acoli-repo/acoli-dicts/tree/master/stable/freedict/freedict-rdf-2019-02-05) (\*/*.ttl.gz) | [freedict/freedict-rdf-2019-02-05](https://github.com/acoli-repo/acoli-dicts/tree/master/stable/freedict/freedict-rdf-2019-02-05) (\*/*.tsv.gz) | plain word lists, user-generated content |
|DBnary | 119* | 275* | CC-BY-SA 3.0 | [external](http://kaiko.getalp.org/) | [dbnary/dbnary-tiad-2019-02-16](https://github.com/acoli-repo/acoli-dicts/tree/master/stable/dbnary/dbnary-tiad-2019-02-16)  | * counted only language pairs with 10,000+ entries, user-generated content |
|PanLex | 194*| 1651**| CC0 | [panlex/panlex-20191001-csv-rdf](https://github.com/acoli-repo/acoli-dicts/tree/master/stable/panlex/panlex-20191001-csv-rdf) | [panlex/biling-tsv](https://github.com/acoli-repo/acoli-dicts/tree/master/stable/panlex/biling-tsv) | * only language pairs with 10.000 entries; ** TIAD-TSV files | 
|MUSE   | 45  | 107  | CC-BY-NC 4.0 | [muse/muse-rdf-2020-06-12](stable/muse/muse-rdf-2020-06-12) | [muse-tsv-2020-06-12](stable/muse/muse-tsv-2020-06-12) | machine-generated, high-precision wordlist |
|Wikidata   | *  | *  | CC0 | https://www.wikidata.org (external) | [wikidata/wikidata-tsv-2020-06-24](stable/wikidata/wikidata-tsv-2020-06-24) | * >400k translation pairs, > 90k language pairs, but very sparse  |
|OMW   | 34  | 40*  | open source | [external](http://compling.hss.ntu.edu.sg/omw/all+xml.zip) | [omw/tsv](stable/omw/tsv) | * conservative estimate, restricted to combinations of OMW files with identical licenses |
|XDXF | 51 | 107 | GPL |[experimental/xdxf/xdxf-rdf-2019-02-22](https://github.com/acoli-repo/acoli-dicts/tree/master/experimental/xdxf/xdxf-rdf-2019-02-22) (\*/\*.ttl.gz) | [experimental/xdxf/xdxf-rdf-2019-02-22](https://github.com/acoli-repo/acoli-dicts/tree/master/experimental/xdxf/xdxf-rdf-2019-02-22) (\*/\*.tsv.gz) | experimental |
|free-dict.de | 2 | 1 | "free" | [experimental/free-dict.de/free-dict-de-2020-01-02](https://github.com/acoli-repo/acoli-dicts/tree/master/experimental/free-dict.de/free-dict-de-2020-01-02) (\*.ttl.gz) | [experimental/free-dict.de/free-dict-de-2020-01-02](https://github.com/acoli-repo/acoli-dicts/tree/master/experimental/free-dict.de/free-dict-de-2020-01-02) (*.tsv.gz) | experimental (partial) |
|StarDict | 32 | 130 | "open"/"free" | [experimental/stardict/stardict-2020-01-04](https://github.com/acoli-repo/acoli-dicts/tree/master/experimental/stardict/stardict-2020-01-04) (\*/\*.ttl.gz) | [experimental/stardict/stardict-2020-01-04](https://github.com/acoli-repo/acoli-dicts/tree/master/experimental/stardict/stardict-2020-01-04) (\*/\*.tsv.gz) | experimental (partial) |
| **total** | **249** | **2351**

## subdirectories

* [stable/](stable/) data releases
* [experimental/](experimental/) work in progress, contains converters/build scripts and resulting data by several individual contributors, including student projects

## acknowledgements, licensing and references

The ACoLi Dictionary Graph has been created and continues to be developed at the Applied Computational Linguistics Lab at Goethe Universität Frankfurt, Germany since 2014 in the context of numerous research projects, including
- Independent Research Group ["Linked Open Dictionaries" (LiODi)](https://acoli-repo.github.io/liodi/), funded in the eHumanities programme of  the German Federal Ministry of Education and Science (BMBF, 2015-2020)
- Horion 2020 Research and Innovation Action [Pret-a-LLOD. Ready-to-use Multilingual Linked Language Data for Knowledge Services across Sectors](https://www.pret-a-llod.eu), funded by the European Research Council (ERC, 2019-2021)

To refer to the dataset as a whole in scientific publications, please refer to Chiarcos et al. (2020):

	@inproceedings{chiarcos2020acoli,
	  title={The ACoLi Dictionary Graph},
	  author={Chiarcos, Christian and F{\"a}th, Christian and Ionov, Maxim},
	  booktitle={Proceedings of The 12th Language Resources and Evaluation Conference},
	  pages={3281--3290},
	  year={2020}
	}
 
All datasets are published under open or non-commercial licenses. We put our RDF and TIAD-TSV editions are put under the same license as the underlying source data. For detailed acknowledgements and licensing of individual datasets see the respective subdirectories. 
