# Open Multilingual WordNet

OntoLex and TIAD-TSV editions.

Note that this data is generated from the OMW TSV format, using lemma information only. OMW WordNet dumps do contain more information. Also note that TIAD-TSV data is compiled from the mapping to synset IDs and it should only be used if bilingual translation is required: if k WordNets provide a mapping to one synset x (and back), we generate k*(k-1) translation pairs, the generated bilingual dictionaries are thus more verbose than the original data.

Note that we assume that the synset identifiers in OMW are those of Princeton WordNet 3.0, and we generate URIs accordingly. If OMW moves to ILI (or a more recednt PWN edition), the URI schema needs to be updated.

## Terms of use and attribution

All OMW data is open source, but provided under different licenses, see individual WordNets.


## Known issues

Conversion rate of OMW datasets approx. %

OntoLex generation failed for dan, eng, fas, fin

TODO: check license compatibility.