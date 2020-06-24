# Wikidata lexemes

Extraction of bilingual lexicalizations of Wikidata concepts, originally from https://www.wikidata.org, CC0-licensed.

The original lexeme data is provided in OntoLex, already, so we only create a TIAD-TSV export.

Data quality seems to be good (manually created, for the most part, explicit sense and form information, grammatical information).
Despite issues wrt. its coverage, this is an important source in the longer perspective because this data is expected to grow.

Also note that much data about inflection is not included in the export, but not extracted for the dictionary graph as it is currently focusing on canonical forms. This should be the basis for another export in the context of, say, UniMorph.

## Documentation
https://www.mediawiki.org/wiki/Wikibase/DataModel
https://www.mediawiki.org/wiki/Extension:WikibaseLexeme/Data_Model

## Acknowledgements and Licensing

Source data provided by Wikidata under a CC0 (Public Domain) license.

TIAD-TSV scripts and initial conversion developed in the Horizon 2020 Research and Innovation Action "Pret-a-LLOD. Ready-to-use Multilingual Linked Language Data for Knowledge Services across Sectors" Grant agreement 825182 (2019-2021).

In scientific publications, please give attribution to Chiarcos et al. (2020).

	@inproceedings{chiarcos2020acoli,
	  title={The ACoLi Dictionary Graph},
	  author={Chiarcos, Christian and F{\"a}th, Christian and Ionov, Maxim},
	  booktitle={Proceedings of The 12th Language Resources and Evaluation Conference},
	  pages={3281--3290},
	  year={2020}
	}

### History
- 2020-06-24 TIAD-TSV conversion (CC)

### Contributors (for the conversion)
- CC -- Christian Chiarcos, chiarcos@informatik.uni-frankfurt.de
