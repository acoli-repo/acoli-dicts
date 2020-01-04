# experimental

Individual contributions, not (yet) integrated with project data.

Please create individual subdirectories here.

## current content

### XDXF
 - converter platform for open source dictionaries
 - partially structured content, only
 - unstructured content (no detectable sense information) not parsed, but preserved as rdfs:comment of ontolex:LexicalEntry
 - successfully converted to 
	 - 52 language varieties (51 plus spoken English), 108 language pairs, 147 individual dictionaries
 - quality of source data is unbalanced, extraction errors in original XDXF data not fixed
 
### StarDict converter
 - dictionary ecosystem, providing dictionaries and a tool
 - retrieved dictionaries restricted to those with explicit open license (GPL, CC-BY, etc.), also including "free-to-use" resources, no legal clearance beyond the original listing on the distributor site
 - provides low-level encoding of dictionaries, with index words and definitions. No systematic markup beyond that.
 - manual indication of languages.
 - shallow, lossy extraction (the format semi-formalized only, no systematic encoding of grammatical features, translations, etc.), 
   providing a *selection* of open/free-to-use resources that are sound (reliable translation detection, few encoding errors)
 - no systematic metadata, parts of it seem to be crowd-sourced and moderate quality

### free-dict.de converter
 - six dictionaries with online search interface and HTML serialization, mostly crowd-sourced content.
 - conversion for Zazaki-German dictionary only
 - unter experimental until copyright status is clarified.
 
## suggested project structure

For complex converter suites, we recommend the following subdirectories (non-normative).

### src/
	converter source code

### bin/ (optional)
	compiled converter source code
	
### cmd/ (optional)
	if you use shell scripts to preprocess or postprocess data before applying your converter, deposit them here
	
### lib/ (optional)
	any libraries your project depends on. You can use maven, etc., to fetch them, instead.

### data/raw
	the original data. If copyright-protected or license is unknown, please store it as an encrypted zip archive.
	
### data/rdf
	the final data, if any. If copyright-protected or unknown license, please store it as an encrypted zip archive.
	
### doc/
	Any additional documentation.