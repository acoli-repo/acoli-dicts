# Open Multilingual WordNet

OntoLex and TIAD-TSV editions.

Note that this data is generated from the OMW TSV format, using lemma information only. OMW WordNet dumps do contain more information. Also note that TIAD-TSV data is compiled from the mapping to synset IDs and it should only be used if bilingual translation is required: if k WordNets provide a mapping to one synset x (and back), we generate k*(k-1) translation pairs, the generated bilingual dictionaries are thus more verbose than the original data.

Note that we assume that the synset identifiers in OMW are those of Princeton WordNet 3.0, and we generate URIs accordingly. If OMW migrates to ILI (or a more recent PWN edition), the URI schema needs to be updated.

## Terms of use and attribution

All OMW data is open source, but provided under different licenses, see individual WordNets.

## Acknowledgments

OntoLex-Lemon conversion and generation of TIAD-TSV files have been conducted in the context of the H2020 Research and Innovation Action "Pret-a-LLOD" (2019-2021).

## Known issues

- Failures in OntoLex generation for about 32% of OMW WordNets (11/34: dan, eng, eus, fas, fin, glg, spa, nno, nob, por, tha). This may be due to variations in the TSV formats (they are not fully consistent) that have not been anticipated by the converter.
- Before publishing TIAD-TSV data, license compatibility for the source licenses must be confirmed and terms of use/acknowledgments are yet to be aggregated.
