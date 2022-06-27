# RDF export

Contains both a raw RDF export (`rdf/`) and an export prepared for ingestion to Zenodo (`zenodo/`).

The Zenodo export is a TTL conversion of the original RDF export, normalized to a Zenodo-resolvable URI.

Note that Zenodo does not support RDF media types, so this is exposed as text/plain (etc.). Clients have to guess the proper format from the file name. For this reason, we need to include the file extension into all URIs.

Also note that this heuristic is known to work for *some* clients only and that it requires to drop the default flags appended by Zenodo to the files it stores. For the moment, it is without alternatives. If your client does not detect the data as TTL, try to download and load it locally, instead.

In addition to the RDF export, we also create a form index for every language (`zenodo/langs`), using `owl:sameAs` statements between forms. This is purely lexical linking, but will suffice to establish the data as Linked Data. In the longer term, links between lexical entries or even lexical senses should be inferred, instead.

However, as PWN 3.1 forms are blank nodes, we link lexical entries by ontolex:canonicalForm with the PanLex URIs. By OWL semantics (and the cardinality axiom of ontolex:canonicalForm), we can then infer identity of forms.

## Update procedure

- update/build `rdf/` (see parent directory)
- remove `zenodo/`

		rm -rf zenodo/

- re-build `zenodo/`

		bash -e ./prep-release.sh

  (This takes a while, it will convert the data, produce the linking with the word index, download PWN 3.1 and link `zenodo/langs/en.ttl` with PWN 3.1)

  Note that this requires Apache Jena command line tools (`update`, `arq`)

- prep-release.sh includes a routine for metadata extraction and linking (`make-stats.py`)

- create/update Zenodo data, one `zenodo/` subdirectory at a time.
  Note that this will create new versions and these versions will have *different URIs*, so you need to update Purl redirects

  So far, we published:
  - [PanLex Language Metadata](https://zenodo.org/record/6757924) (for `zenodo/langs/`)
  - [PanLex Batch 1](https://zenodo.org/record/6757353) (for `zenodo/000/`)

  Publishing additional Batches via Zenodo takes several hours, these will come in the next days.

- create/update Purl URIs under https://purl.archive.org/domain/acoli_dicts_panlex to the new Zenodo URIs (partial redirects).
  If you do not have the credentials to update this Purl domain, register your own (or use another redirection service), but make sure you adjust the `prep-release.sh` script beforehand to use your new (P)URL scheme rather than the current one

  Note: You may need to wait several minutes for a redirect to work.

- test Zenodo retrieval via Purl

		update --update test-update.sparql --dump

  If that doesn't spell out a lot of Turtle on command line, something is broken.