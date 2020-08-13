# Intercontinental Dictionary Series (IDS)

IDS edited by Key, Mary Ritchie & Comrie, Bernard, version of 2018 (https://cdstar.shh.mpg.de/bitstreams/EAEA0-5F01-8AAF-CDED-0/ids_dataset.cldf.zip)
licensed under a Creative Commons Attribution 4.0 International License. 

## Remarks on language identification

We provide a mapping to BCP47 language codes, but note that these are less fine-grained than the Glottocodes used in the original IDS data (along with with additional ISO 693-3 identifiers where applicable). We thus employ the following approach to generate BCP47 language tags:

- If a language does have an ISO 639-3 identifier (e.g., "eng", English) that does have an ISO 639-1 equivalent (e.g., "en"), we provide the ISO 639-1 equivalent.
- If a language does have an ISO 639-3 identifier (e.g., "ang", Old English) that does not have an ISO 639-1 equivalent, we provide the ISO 639-3 tag. Note that BCP47 follows a preference for 639-2 tags over 639-3 tags, but both sets should be compatible, i.e., either the 639-2 tag is identical to the 639-3 tag (e.g., "ang") or the 639-3 tag provides information at a different level of granularity (and should be preserved for its explicitness).
- If a language does not have an ISO-693 identifier, but a Glottocode (e.g., "orkn1236", Orkney Scots), and a broader Glottolog languoid does have an ISO 693-3 identifier (e.g., "scot1243" = "sco", Scots), we obtain the BCP47 code of the broader language language, and append '-x-' to mark following content as private information and the original Glottocode (e.g., "sco-x-orkn1236").
- If a language does not have an ISO-693 identifier, but a Glottocode, for which none of the broader Glottolog languages have an ISO-639-3 code (e.g., "okin1244", Okinawan, not seen as a dialect of Japanese here, but as a cousin within the broader Japonic family), we employ the BCP47 language code "mis" (unclassified), followed by "-x-" and the Glottocode (e.g., "mis-x-okin1244").
- For phonemic forms, we always return "x-fonipa", with the intend to mark them as using a "private encoding that provides *something like* IPA". As many data follow neither IPA nor practices employed by the speakers themselves, these must not be confused with regular lexemes nor with proper fonipa (IPA).

The use of "(-)x-" to mark private additions is sanctioned by BCP47, but none of the language codes were validated against the IANA subtag registry. As the IANA registry may not be fully up to date with ISO 639-3 and/or there may be errors in the ISO 696-3 mapping in the IDS data or in Glottolog, debugging invalid language codes does require a level of expertise in the individual languages that we cannot provide. If you encounter any apparent errors, please consult with IDS and Glottolog maintainers, resp. (if this is the source of errors), the IANA. 

Several datasets provide no language identifiers other than textual descriptions, these include languages 806 ("Mang'an B. (MNN)"), 818 ("Tho Mun (THM)"), 821 ("TUL"), 824 ("Phu Tho M (PHU)"), and 831 ("SAN"). This seems to be merely an encoding error, where ISO-693-3 (?) language code information is provided in an unconventional way, but without confirmation about this, this data is skipped. 

Also, reconstructed (proto-)forms for language families have been excluded (e.g., "aust1307", Austronesian). Originally, this was by error (as we did not anticipate that individual languages are connected by skos:broader, but language families only by skos:broaderTransitive and skos:narrower). We decided not to fix this problem as the treatment of protoforms in the ACoLi Dictionary Graph requires special handling and more advanced means to provide provenance data than currently foreseen.

For the IDS languoid anga1295, the Glottocode appears to have been deleted after Glottolog version 2.7 (hence a redirect from https://glottolog.org/resource/languoid/id/anga1295). We provide no language tag for this variety and omitted it from the release.

## Remarks on TIAD-TSV export and usability as a dictionary

In total, IDS provides information about 243 ISO 639-3 languages with lexicalizations for up to 1310 concepts per language. Lexical coverage is severely limited, and in particular, it is possible for every single lexeme that it comes with other possible senses not covered by the concept inventory. In the TIAD export, we consider lexicalizations in different languages as possibe translation pairs, but it is not guaranteed that these translation pairs also represent the most typical translation into the respective target language. Also note that TIAD export is packaged according to primary BCP47 language tags. Different dialects (or different sources for the same dialect) can thus be found in the same file -- clearly distinguished by their original Glottocodes after the BCP47 primary language. Where two translation pairs these differ only in provenance (i.e., URI of the lexical entry), but provide source and target lemmas that are (including BCP47 identical), they are nevertheless considered to be two translation pairs.

We provide an export as bilingual dictionary using the TIAD-TSV format. For the sake of compactness, we provide one direction per language pair only, using the lexicographic order of language tags to determine the direction. Note that this does not entail any implications about translation direction. In fact, the bidictionaries are undirected.

In total, 58,806 language combinations can be generated (243*242), but we provide one direction per language pair only. Following ACoLi Dictionary conventions for large-scale dictionary collections, we report only bidirectionaries with more than 10,000 translation pairs to the ACoLi Dictionary Graph. However, for IDS data, this number does not entail any information about the coverage of the dictionary, as this does not reflect the size of the vocabulary covered by a dictionary, but the high number of lexicalizations provided (either because a high number of possible lexicalizations is provided or because several dialectal variants of the same language are covered, where each dialect lexicalization counts as a separate possible translation). As a result, Avar (av) bidictionaries tend to produce relatively large TIAD-TSV files, but not because of their extensive coverage, but because of its degree of internal variation: The Avar dictionaries provides lexical data for 9 language varieties (av, av-x-ancu1238, av-x-anda1281, av-x-batl1238, av-x-hidd1238, av-x-kara1473, av-x-kunz1243, av-x-sala1265, av-x-zaka1239), resp. 13 independent IDS data sets (incl. 5 data sets for av, each providing different lexical entry URIs). Similarly, Dargwa (dar) covers 7 language varieties (dar, dar-x-chir1284, dar-x-cuda1238, dar-x-itsa1239, dar-x-kajt1238, dar-x-kuba1248, dar-x-urax1238) and 18 independent IDS data sets (incl. 11 data sets for dar, 2 for dar-x-cuda1238), etc.

Also note that many IDS dictionaries do not provide lemmas, but provide additional semistructured information as part of the form (!). Examples include phonological variation ("'i'šuwa ~ 'i'šuya"@cbi), pronounciation information ("'kenoš < ['kenus]"@teh), morphological traits ("[heresu]-ta"@yvt, "-(e)kumi"@mca), grammatical markup ("-soʔ (m.)"@mca), collocations (?) ("лекха (хила)"@ce), etymology ("noose 'l-iʔi (< no'wasek)"@plg), free-text comments ("tomiˑs (prob. <tom-mis)"@nuk) and any combination of these ("-iftuʔ ~ -eftuʔ (m.)"@mca). As this information is not normalized and the consistency of free text additions can be doubted in general, we did not attempt to decompose them into meaningful units. Because of these normalization issues, and because it cannot be guaranteed for all languages that their form adheres to their conventional orthography (rather than a scientific orthography used only by the authors of a particular data set), IDS data should only be considered as reliable lexical information for lexemes whose written representation can be confirmed by an independent source for the language variety under consideration.

IDS data is nevertheless very valuable as it covers an impressive amount of low-resource languages for which no other electronic dictionary does exist. When used for translation inference across dictionaries, it will, however, introduce a bias as the IDS senses do not necessarily reflect the semantic spectrum a lexeme actually covers.

## TIAD Statistics

In total, we provide 29,192 language pairs for 243 distinct BCP47 languages (corresponding 329 Glottolog languoids). Translation pairs are extrapolated from the lexicalizations of the same IDS concept in different languages. The translations are undirected, but only one direction is provided.

For overall statistics, we report the numbers for language pairs with >10.000 translation pairs, i.e., 792 language pairs for 234 BCP47 languages.

However, note that this does not reflect the lexical coverage for the languages in this case, but rather, the coverage of dialects. The amount of lexical material per language variety is roughly constant, with lexicalizations for about 1300 concepts.

## History
- 2020-08-12 add TIAD-TSV data (CC)
- 2020-07-15 OntoLex data pruned and published, TIAD-TSV export revised (CC)
- 2020-07-12 code for TSV export (CC)
- 2020-07-09 split into individual languages, revised OntoLex conversion, normalize language codes to BCP47 (CC)
- 2020-07-02 initial OntoLex conversion (CC)
- 2018 original publication, CSV format (MRK & BC)

## Contributors and Acknowledgments
- MRK & BK Mary Ritchie Key and Bernard Comrie (editors), for the IDS authors
- CC Christian Chiarcos

The RDF and TIAD conversions of the IDS have been conducted in the independent research group "Linked Open Dictionaries (LiODi)", funded in the eHumanities programme of the German Federal Ministry of Education and Research (BMBF, 2015-2020).||||||| .r1521

- MRK & BC Mary Ritchie Key and Bernard Comrie (editors), for the IDS authors
- CC Christian Chiarcos

## known issues

- GitHub commit for TIAD TSV files av (Avar), dar (Dargwa) and con (Cofán) failed because of timeouts. Build locally with the command `$> ./build.sh` 