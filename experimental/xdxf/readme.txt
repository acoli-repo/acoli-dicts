XDXF is a project to unite all existing open dictionaries and provide both users and developers with universal XML-based format, convertible from and to other popular formats like Mova, PtkDic, StarDict, ABBYY Lingvo etc.

GNU General Public License version 2.0 (GPLv2)

https://sourceforge.net/projects/xdxf/

Data available via "Files"

At the moment, TSV extraction works for 88% of the dictionaries, only, others indicating TTL errors with a "Failed to load data" from Apache Jena's arq.

Notes:

1) We only process XDXF files from this source. Other formats (which represent the main body of dictionaries in here) are left untouched, as their copyright status may be debated. In particular this includes a substantial (partial?) XDXF mirror of StarDict data contained here -- which had been removed from SourceForge due to copyright infringement reports (http://stardict.sourceforge.net/).

2) All XDXF files in this repository follow the "visual" (unstructured) mode, we thus did not implement the "logical" mode (although being recommended for lexical data -- cf. https://github.com/soshial/xdxf_makedict/blob/master/format_standard/xdxf_description.md --, we have no such data). Note that this means that *all* dictionaries that are more than mere word lists contain lengthy, unparsed material as ontolex:LexicalEntry/rdfs:comment

3) Extraction artifacts have not been fixed.

4) Most monolingual "dictionaries" are not actually dictionaries, but lexicons, e.g., containing biographies, etc. Accordingly, these are excluded from the conversion.

5) Heuristic sense (gloss) splitting at [\n,], if no [,()] is contained. If the latter, all is preserved as rdfs:comment of the lexical entry rather than as a sense.

6) XDXF remains in experimental until a converter for the logical format has been developed (if any data can be found) and a data quality check has been performed. 

Acknowledgements:

Project "Linked Open Dictionaries" (LiODi), funded as an independent research group in the eHumanities programme of the German Federal Ministry of Education and Science (BMBF, 2015-2020).
