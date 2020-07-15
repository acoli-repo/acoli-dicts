# Intercontinental Dictionary Series (IDS)

IDS edited by Key, Mary Ritchie & Comrie, Bernard, version of 2018 (https://cdstar.shh.mpg.de/bitstreams/EAEA0-5F01-8AAF-CDED-0/ids_dataset.cldf.zip)
licensed under a Creative Commons Attribution 4.0 International License. 

## remarks on language identification

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

## remarks on TIAD-TSV export

We provide an export as bilingual dictionary using the TIAD-TSV format. For the sake of compactness, we provide one direction per language pair only, using the lexicographic order of language tags to determine the direction. Note that this does not entail any implications about translation direction. In fact, the bidictionaries are undirected.

## history
- 2020-07-12 code for TSV export
- 2020-07-09 split into individual languages, revised OntoLex conversion, normalize language codes to BCP47 (CC)
- 2020-07-02 initial OntoLex conversion (CC)
- 2018 original publication, CSV format (MRK & BK)

## contributors
- MRK & BK Mary Ritchie Key and Bernard Comrie (editors), for the IDS authors
- CC Christian Chiarcos