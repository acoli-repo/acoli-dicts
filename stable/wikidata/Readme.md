# Wikidata lexemes

Extraction of bilingual lexicalizations of Wikidata concepts, originally from https://www.wikidata.org, CC0-licensed.

The original lexeme data is provided in OntoLex, already, so we only create a TIAD-TSV export.

Data quality seems to be moderate to good (manually created, for the most part, explicit sense and form information, grammatical information), but the data does contain errors, e.g.,

- part of speech
	"age"@en        "Zeitalter"@de  <http://www.lexinfo.net/ontology/2.0/lexinfo#noun>
	"age"@en        "Zeitalter"@de  <http://www.lexinfo.net/ontology/2.0/lexinfo#verb>
	# the sense of "Zeitalter"@de is nominal only, not verbal
	
- language assignment
	"anger"@en      "oida"@de       <http://www.lexinfo.net/ontology/2.0/lexinfo#noun>
	# whatever "oida" is, this is not a Standard German word. It might be dialectal, but then, with different semantics.

- typos
	"ten"@en        "Zehn"@de       <http://www.lexinfo.net/ontology/2.0/lexinfo#numeral>
	# the correct spelling is lowercase "zehn"@de
	
Wikidata currently covers 325 ISO-639 languages plus a number of unclassified languages (not extracted here). However, a major issue in this dataset is its limited coverage with respect to the lexicon. Wikidata currently provides at most 2000 translations per language pair (he/en: 1995, de/en: 1397, en/da: 1145; average 4.3 translations per language pair [419270/98112]), so, it is not included in the overall statistics of the ACoLi Dictionary Graph. Despite these coverage issues, this is an important source in the longer perspective because this data is continuously worked on by an active community and expected to grow.

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
