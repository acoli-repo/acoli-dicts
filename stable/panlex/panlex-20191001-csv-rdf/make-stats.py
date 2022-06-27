import sys,re,os,rdflib,traceback

root="http://purl.org/acoli/dicts/panlex"

print(f"""
PREFIX dc:	<http://purl.org/dc/elements/1.1/>
PREFIX dcat:	<http://www.w3.org/ns/dcat#>
PREFIX dct:	<http://purl.org/dc/terms/>
PREFIX dctype:	<http://purl.org/dc/dcmitype/>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
PREFIX locn:	<http://www.w3.org/ns/locn#>
PREFIX odrl:	<http://www.w3.org/ns/odrl/2/>
PREFIX owl:	<http://www.w3.org/2002/07/owl#>
PREFIX prov:	<http://www.w3.org/ns/prov#>
PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs:	<http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos:	<http://www.w3.org/2004/02/skos/core#>
PREFIX spdx:	<http://spdx.org/rdf/terms#>
PREFIX time:	<http://www.w3.org/2006/time#>
PREFIX vcard:	<http://www.w3.org/2006/vcard/ns#>
PREFIX xsd:	<http://www.w3.org/2001/XMLSchema#>
PREFIX dicts: <http://purl.org/acoli/dicts#>
PREFIX panlex: <{root}/>
""")


print(f"""<{root}> a dcat:Catalog; 
	dct:source <http://panlex.org>;
	prov:wasGeneratedBy <https://orcid.org/0000-0002-4428-029X>;
	dct:title "PanLex, OntoLex-Lemon edition";
	dct:publisher <https://orcid.org/0000-0002-4428-029X>;
	dct:creator <https://orcid.org/0000-0002-4428-029X>;
	dcat:mediaType "text/turtle";
	foaf:homepage <https://github.com/acoli-repo/acoli-dicts/tree/master/stable/panlex>;
	dct:rights <https://panlex.org/license/>, <https://creativecommons.org/publicdomain/zero/1.0/>.
	""")


files=sys.argv[1:]

ENTRY=rdflib.term.URIRef("http://www.w3.org/ns/lemon/lime#entry")
SAME_AS=rdflib.term.URIRef("http://www.w3.org/2002/07/owl#sameAs")

while(len(files)>0):
	# print(files)
	file=files[0]
	files=files[1:]
	if os.path.isdir(file):
		files+=[os.path.join(file,sub) for sub in os.listdir(file)]
		# print(files)
	elif file.endswith("ttl"):
		sys.stderr.write(file+"\n")
		sys.stderr.flush()
		try:
			g=rdflib.graph.Graph()
			g.parse(file)

			lexicons=list(g.subjects(ENTRY,None))
			if len(lexicons)==0:
				# language file
				forms=set(g.subjects(SAME_AS,None))
				lang=re.sub(r".*\/([a-z]+)[^a-z][^\/]*$",r"\1", file)
				print(f"""<{root}> dicts:entries "{len(forms)}"; 
						dct:language "{lang}";
						dct:creator <https://orcid.org/0000-0002-4428-029X> .""")
			else:
				for lex in set(lexicons):
					l=str(lex)
					dataset=re.sub(r"#[^#]*$","",l)
					print(f"""<{root}> dcat:dataset <{dataset}> .""")
					print(f"""<{dataset}> dct:publisher <http://panlex.org>;
							dicts:entries "{len(lexicons)}" ;
							prov:wasGeneratedBy <https://orcid.org/0000-0002-4428-029X>;
							dct:rights <https://panlex.org/license/>, <https://creativecommons.org/publicdomain/zero/1.0/>;
							dcat:mediaType "text/turtle";
							dcat:downloadURL <{dataset}> .""")
					if l!=dataset:
						print(f"""<{dataset}> dct:hasPart <{l}> .""")
					for prop,val in g.predicate_objects(lex):
						if "/dcat" in str(prop) or "/dc/" in str(prop):
							print(f"""<{dataset}> <{str(prop)}> '{str(val)}' .""")

		except Exception:
			traceback.print_exc()
			sys.stderr.write(f"while processing {file}\n")
			sys.stderr.flush()
