
# Dictionaries of MUSE: Multilingual Unsupervised and Supervised Embeddings

Conversion of bilingual wordlists used for the supervised induction of multilingual word embeddings (https://github.com/facebookresearch/MUSE).

Note that this data seems to be automatically created but that it is still relatively noisy
* language classification sometimes seems have to failed (maybe for source language expressions in the target language)
* lowercasing
* sometimes, inflected forms are included (e.g., English has)

However, random sampling did not reveal massive errors in the semantic accurracy of the translations, so this seems to be a
high-precision extract from a translation table as created during machine translation, possibly with manual post-correction. 
This is a valuable resource, but it does not meet lexicographic standards.

Note that it does not provide lexical entries, but only form relations. We postulate one lexical entry per form per language.
When used as a lexicographic resource, this *MUST* be combined with other lexical data, at least to verify whether a word 
actually belongs to that language and to restore true casing.

## Acknowledgements and Licensing

Source data distributed unter CC-BY-NC 4.0 International license
- https://github.com/facebookresearch/MUSE

The RDF and TIAD-TSV editions preserve this license. To meet the attribution requirement of the license, please acknowledge **both**
- https://github.com/facebookresearch/MUSE and https://github.com/acoli-repo/acoli-dicts

RDF and TIAD-TSV editions created within the Horizon 2020 Research and Innovation Action "Pret-a-LLOD. Ready-to-use Multilingual Linked Language Data for Knowledge Services across Sectors" Grant agreement 825182 (2019-2021).

In scientific publications, please give attribution to Chiarcos et al. (2020) [for the RDF and TIAD-TSV edition] **and** to Conneau et al. (2017) [for the source data].

	@article{conneau2017word,
	  title={Word Translation Without Parallel Data},
	  author={Conneau, Alexis and Lample, Guillaume and Ranzato, Marc'Aurelio and Denoyer, Ludovic and J{\'e}gou, Herv{\'e}},
	  journal={arXiv preprint arXiv:1710.04087},
	  year={2017}
	}

	@inproceedings{chiarcos2020acoli,
	  title={The ACoLi Dictionary Graph},
	  author={Chiarcos, Christian and F{\"a}th, Christian and Ionov, Maxim},
	  booktitle={Proceedings of The 12th Language Resources and Evaluation Conference},
	  pages={3281--3290},
	  year={2020}
	}

### History
- 2020-06-23 TIAD-TSV conversion (CC)
- 2020-06-12 RDF conversion (CC)
- 2017 publication of source data (C&al)

### Contributors
- C&al -- original creators of the MUSE data set, cf. Conneau et al. (2017)
- CC -- Christian Chiarcos, chiarcos@informatik.uni-frankfurt.de
