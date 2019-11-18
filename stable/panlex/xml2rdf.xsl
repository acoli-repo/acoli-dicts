<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:skos="http://www.w3.org/2004/02/skos#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:ontolex="http://www.w3.org/ns/lemon/ontolex#"
    xmlns:panlex="https://panlex.org/"
    xmlns:synsem="http://www.w3.org/ns/lemon/synsem#"
    xmlns:lexinfo="http://www.lexinfo.net/ontology/2.0/lexinfo#"
    xmlns:decomp="http://www.w3.org/ns/lemon/decomp#"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:vartrans="http://www.w3.org/ns/lemon/vartrans#"
    xmlns:lime="http://www.w3.org/ns/lemon/lime#">

    <xsl:output method="xml" indent="yes"/>
    
    <xsl:param name="base">http://REPLACE-ME-WITH-DOCUMENT-URI</xsl:param>

    <!-- parameter for format disambiguation -->
    <xsl:variable name="format" select="/source/format[1]/label[1]/text()[1]"/>

    <!-- root node -->
    <xsl:variable name="source" select="/source[1]"/>

    <!-- create ontolex-like XML file -->
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="source">
        <rdf:RDF>
            <xsl:text disable-output-escaping="yes">&lt;owl:Ontology xml:base="</xsl:text>
            <xsl:value-of select="$base"/>
            <xsl:text disable-output-escaping="yes">"&gt;</xsl:text>
            <owl:imports rdf:resource="http://www.w3.org/ns/lemon/lime"/>
            <owl:imports rdf:resource="http://www.w3.org/ns/lemon/ontolex"/>
            <owl:imports rdf:resource="http://www.w3.org/ns/lemon/vartrans"/>     
            <xsl:for-each select="distinct-values(//lang_code/text())">
                <xsl:if test=".!='art'">
                    <xsl:variable name="me" select="."/>
                    <xsl:for-each select="$source">
                        <xsl:variable name="id" select="concat('source_',/source/@id,'_',$me)"/>
                        <lime:lexicon>
                            <xsl:attribute name="rdf:about" select="concat('#',$id)"/>
                            <xsl:attribute name="rdfs:label" select="@label"/>
                            <xsl:attribute name="dct:source" select="@url"/>
                            <xsl:attribute name="dc:title" select="@title"/>
                            <xsl:attribute name="dc:publisher" select="@publisher"/>
                            <xsl:attribute name="dct:dateSubmitted" select="@reg_date"/>
                            <xsl:attribute name="dc:date" select="@year"/>
                            <xsl:attribute name="panlex:quality" select="@quality"/>
                            <xsl:attribute name="panlex:grp" select="@grp"/>
                            <xsl:attribute name="rdfs:comment" select="@note"/>
                            <xsl:attribute name="dc:license" select="@license"/>
                            <xsl:attribute name="dct:rights" select="@ip_claim"/>
                            <xsl:attribute name="dc:format" select="format[1]/label[1]/text()"/>
                            <xsl:attribute name="dc:language" select="$me"/>
                            <xsl:call-template name="build-dict">
                                <xsl:with-param name="lang_code" select="$me"/>
                            </xsl:call-template>
                        </lime:lexicon>
                    </xsl:for-each>
                </xsl:if>
            </xsl:for-each>
            <xsl:text disable-output-escaping="yes">&lt;/owl:Ontology></xsl:text>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="build-dict">
        <xsl:param name="lang_code"/>

        <xsl:for-each select="/source/meaning/denotation[expr/langvar/lang_code/text()=$lang_code]">
            <ontolex:LexicalEntry rdf:about="#{@id}">
                <xsl:for-each select="expr/langvar[lang_code/text()=$lang_code][1]">
                    <rdfs:label>
                        <xsl:value-of select="concat('&quot;',txt/text()[1],'&quot;@', lang_code/text()[1])"/>
                    </rdfs:label>
                </xsl:for-each>                    
                <xsl:for-each select="expr[langvar/lang_code/text()=$lang_code]">
                    <ontolex:lexicalForm>
                        <ontolex:Form rdf:about="#{@id}">
                            <ontolex:writtenRep xml:lang="{langvar/lang_code/text()}">
                                <xsl:value-of select="langvar/txt/text()"/>
                            </ontolex:writtenRep>
                        </ontolex:Form>
                    </ontolex:lexicalForm>
                </xsl:for-each>
                <xsl:for-each select="denotation_class">
                    <xsl:for-each select="e1/expr/e2">
                        <panlex:denotation_class
                            e1="{concat(../../expr/langvar/lang_code/text()[1],':',../../expr/langvar/txt/text())}">
                            <xsl:choose>
                                <xsl:when test="expr/langvar/lang_code/text()='art'">
                                    <!-- datatype property -->
                                    <xsl:value-of select="expr/langvar/txt/text()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <ontolex:Form rdf:about="#{@id}">
                                        <xsl:comment>
                                            <xsl:text> "</xsl:text>
                                            <xsl:value-of select="expr/langvar/txt/text()"/>
                                            <xsl:text>"@</xsl:text>
                                            <xsl:value-of select="expr/langvar/lang_code/text()"/>
                                            <xsl:text> </xsl:text>
                                        </xsl:comment>
                                    </ontolex:Form>
                                </xsl:otherwise>
                            </xsl:choose>
                            <!-- xsl:attribute name="xml:lang" select="expr/langvar/lang_code/text()"/-->
                        </panlex:denotation_class>
                    </xsl:for-each>
                </xsl:for-each>
                <xsl:for-each select="denotation_prop">
                    <xsl:for-each select="expr/txt">
                        <panlex:denotation_prop
                            e1="{concat(../langvar/lang_code/text()[1],':',../langvar/txt/text())}">
                            <xsl:value-of select="text()"/>
                        </panlex:denotation_prop>
                    </xsl:for-each>
                </xsl:for-each>
                <ontolex:evokes>
                    <ontolex:LexicalConcept rdf:about="#{../@id}">
                        <xsl:for-each select="expr/langvar[lang_code/text()='eng'][1]">
                            <rdfs:label>
                                <xsl:value-of select="txt/text()[1]"/>
                            </rdfs:label>
                        </xsl:for-each>                    
                        <xsl:for-each select="../langvar/txt"> <!-- definition -->
                            <skos:definition xml:lang="{../lang_code/text()}">
                                <xsl:value-of select="text()"/>
                            </skos:definition>
                        </xsl:for-each>
                        <xsl:for-each select="../meaning_prop/expr/txt">
                            <panlex:meaning_prop
                                expr="{concat(../langvar/lang_code/text()[1],':',../langvar/txt/text())}">
                                <xsl:value-of select="text()"/>
                            </panlex:meaning_prop>
                        </xsl:for-each>
                        <xsl:for-each select="../meaning_class/e1/expr">
                            <panlex:meaning_class
                                expr="{concat(langvar/lang_code/text()[1],':',langvar/txt/text())}">
                                <xsl:for-each select="e2/expr">
                                    <ontolex:Form rdf:about="#{@id}">
                                        <xsl:comment>
                                            <xsl:text> "</xsl:text>
                                            <xsl:value-of select="langvar/txt/text()"/>
                                            <xsl:text>"@</xsl:text>
                                            <xsl:value-of select="langvar/lang_code/text()"/>
                                            <xsl:text> </xsl:text>
                                        </xsl:comment>
                                    </ontolex:Form>
                                </xsl:for-each>
                                <xsl:value-of select="text()"/>
                            </panlex:meaning_class>
                        </xsl:for-each>
                    </ontolex:LexicalConcept>
                    <!-- meaning -->
                </ontolex:evokes>
                <xsl:for-each select="./ancestor::meaning[1]/denotation">
                    <xsl:if test="expr/langvar/lang_code/text()!=$lang_code">
                        <vartrans:translatableAs>
                            <ontolex:LexicalEntry rdf:about="#{@id}">
                                <xsl:comment>
                                    <xsl:text> "</xsl:text>
                                    <xsl:value-of select="expr/langvar/txt/text()"/>
                                    <xsl:text>"@</xsl:text>
                                    <xsl:value-of select="expr/langvar/lang_code/text()"/>
                                    <xsl:text> </xsl:text>
                                </xsl:comment>
                            </ontolex:LexicalEntry>
                        </vartrans:translatableAs>
                    </xsl:if>
                </xsl:for-each>
            </ontolex:LexicalEntry>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
