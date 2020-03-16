#!/usr/bin/env python3
# bootstraps ontology from Apertium *.dix files

# (c) 2019-02-24 Max Ionov, max.ionov@gmail.com
# Apache License 2.0, see https://www.apache.org/licenses/LICENSE-2.0

import os
import sys
import logging
from xml.etree import ElementTree as ET


# String templates

tmpl_tag = 'apertium:{tag} a apertium:Tag; apertium:hasTag "{tag}" .'
tmpl_label = 'apertium:{tag} rdfs:label "{label}" .'

tmpl_prefixes = """
@prefix apertium: <http://wiki.apertium.org/wiki/Bidix#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix system: <http://purl.org/olia/system.owl#> .

"""

def process_file(filename):
    triples = set()
    
    tree = ET.parse(filename)
    root = tree.getroot()
    
    for elem in root.findall('.//sdef'):
        tag = elem.attrib.get('n', None)
        label = elem.attrib.get('c', None)
        
        if not tag and not label:
            logging.error('Error while processing {}: Found a tag without n or c ({})'.format(filename, ET.tostring(elem).decode('utf-8')))
        
        # tags[fileset].add(tag)
        triples.add(tmpl_tag.format(tag=tag))
        if label:
            triples.add(tmpl_label.format(tag=tag, label=label))
        
    return triples


## ---- Entry point ----

n_dicts_total = len(sys.argv) - 1
print('bootstrap-apertium-ontology.py started, {} {} to go'.format(n_dicts_total, 
                                                                   'dictionaries' if n_dicts_total > 1 else 'dictionary'))

triples = set()
n_dicts = 0

if len(sys.argv) < 2:
    logging.error('No *.dix files found among arguments, finising')
    sys.exit(1)

for filename in sys.argv[1:]:
    logging.debug('Processing file {}'.format(filename))
    try:
        triples.update(process_file(filename))
    except(ET.ParseError, IOError) as e:
        logging.error('Error in file {}: {}, skipping'.format(filename, e))
    n_dicts += 1

print('Finished processing *.dix files, {} {} processed, found {} tags'.format(n_dicts,
                                                                               'files' if n_dicts > 1 else 'files',
                                                                               len(triples)))

with open('apertium.ttl', 'w', encoding='utf-8') as out_file:
    out_file.write(tmpl_prefixes + '\n'.join(sorted(triples)) + '\n')

print('bootstrap-apertium-ontology.py finished, have a nice day!')
