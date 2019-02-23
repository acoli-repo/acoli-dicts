<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0">

    <!-- ontolex conversion of freedict content. note that this dictionary is *not* a bidictionary, so no information about target language glosses is provided.
        The translation is thus represented as a rfds:label attached to the sense. No use of the vartrans model -->
    <xsl:output method="text" indent="no"/>

    <xsl:param name="SRC_LANG">SET_SRC_LANG</xsl:param>
    <xsl:param name="TGT_LANG">SET_TGT_LANG</xsl:param>
    <xsl:param name="DICT">DICT_NAME</xsl:param>
    

    <xsl:variable name="lexicon">
        <xsl:text>http://purl.org/acoli/dicts/xdxf/lexicon-</xsl:text>
        <xsl:value-of select="$SRC_LANG"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$TGT_LANG"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="$DICT"/>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:text disable-output-escaping="yes">@prefix dc: &lt;http://purl.org/dc/elements/1.1/> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix foaf: &lt;http://xmlns.com/foaf/0.1/> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix lexinfo: &lt;http://www.lexinfo.net/ontology/2.0/lexinfo#> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix xsd: &lt;http://www.w3.org/2001/XMLSchema#> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix owl: &lt;http://www.w3.org/2002/07/owl#> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix rdf: &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix ontolex: &lt;http://www.w3.org/ns/lemon/ontolex#> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix lime: &lt;http://www.w3.org/ns/lemon/lime#> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix skos: &lt;http://www.w3.org/2004/02/skos/core#> .&#10;</xsl:text>
        <xsl:value-of disable-output-escaping="yes"
            select="concat('@prefix : &lt;',$lexicon,'/> . &#10;&#10;')"/>

        <xsl:value-of select="concat('&lt;',$lexicon,'>')"/>
        <xsl:text> a lime:Lexicon</xsl:text>
        <xsl:text>;&#10; lime:language "</xsl:text>
        <xsl:value-of select="$SRC_LANG"/>
        <xsl:text>"</xsl:text>
        <xsl:if test="normalize-space(/xdxf/full_name[1]/text()[1])!=''">
            <xsl:text>;&#10; rdfs:label """</xsl:text>
            <xsl:for-each select="/xdxf/full_name/text()">
                <xsl:value-of select="."/>
                <xsl:text> </xsl:text>
            </xsl:for-each>
            <xsl:text>"""</xsl:text>
        </xsl:if>
        <xsl:if test="normalize-space(/xdxf/description[1]/text()[1])!=''">
            <xsl:text>;&#10; rdfs:comment """</xsl:text>
            <xsl:for-each select="/xdxf/description/text()">
                <xsl:value-of select="."/>
                <xsl:text> </xsl:text>
            </xsl:for-each>
            <xsl:text>"""</xsl:text>
        </xsl:if>

        <xsl:text>.&#10; </xsl:text>

        <xsl:for-each select="//ar">
            <xsl:variable name="lexent" select="concat(':ar_',count(./preceding-sibling::ar)+1)"/>
            <xsl:value-of select="concat('&lt;',$lexicon,'>')"/>
            <xsl:text> lime:entry </xsl:text>
            <xsl:value-of select="$lexent"/>
            <xsl:text>.&#10;</xsl:text>

            <xsl:value-of select="$lexent"/>
            <xsl:text> a ontolex:LexicalEntry.&#10;</xsl:text>
            <xsl:for-each select="k">
                <xsl:variable name="lf">
                    <xsl:value-of select="concat($lexent,'_f')"/>
                    <xsl:if test="count(../k)>1">
                        <xsl:value-of select="concat('_',count(./preceding-sibling::k)+1)"/>
                    </xsl:if>
                </xsl:variable>

                <xsl:value-of select="$lexent"/>
                <xsl:text> ontolex:lexicalForm </xsl:text>
                <xsl:value-of select="$lf"/>
                <xsl:text>.&#10;</xsl:text>
                <xsl:value-of select="$lf"/>
                <xsl:text> ontolex:writtenRep "</xsl:text>
                <xsl:call-template name="normalize-entry">
                    <xsl:with-param name="str" select="text()"/>
                </xsl:call-template>
                <xsl:text>"@</xsl:text>
                <xsl:value-of select="$SRC_LANG"/>
                <xsl:text>.&#10;</xsl:text>
            </xsl:for-each>


            <xsl:choose>
                
                <!-- unstructured entry, no empty lines, assume that this is sense information unless it contains sentence-level punctuation -->
                <xsl:when
                    test="count(./text()[matches(.,'.*[()\.].*')][1])=0 and count(*[name()!='k'][1])=0 and count(./text()[string-length(normalize-space(.))=0][1])=0">
                    <xsl:for-each select="tokenize(string-join(text(),'&#10;'),'&#10;(&#10;)+')">
                        <xsl:for-each select="tokenize(.,'(&#10;| *, *| *; *)+')">
                            <xsl:if test="string-length(normalize-space(.))>0">
                                <xsl:variable name="s" select="concat($lexent,'_s_',encode-for-uri(normalize-space(replace(.,'\([^\)]*\) *',''))))"/>
                                <xsl:if test="normalize-space(.)!=''">
                                    <xsl:value-of select="$s"/>
                                    <xsl:text> a ontolex:Sense;&#10; ontolex:isSenseOf </xsl:text>
                                    <xsl:value-of select="$lexent"/>
                                    <xsl:text>;&#10; rdfs:label """</xsl:text>
                                    <xsl:call-template name="normalize-entry">
                                        <xsl:with-param name="str" select="."/>
                                    </xsl:call-template>
                                    <xsl:text>"""@</xsl:text>
                                    <xsl:value-of select="$TGT_LANG"/>
                                    <xsl:text>.&#10;</xsl:text>
                                </xsl:if>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:when>
                
                <!-- unstructured entry, contains sentence-level information: keep as rdfs:comment of the lexical entry -->
                <xsl:when test="count(*[name()!='k'][1])=0 and count(./text()[string-length(normalize-space(.))=0][1])=0">
                    <xsl:value-of select="$lexent"/>
                    <xsl:text> rdfs:comment """</xsl:text>
                    <xsl:call-template name="normalize-entry">
                        <xsl:with-param name="str" select="string-join(text(),'&#10;')"/>
                    </xsl:call-template>
                    <xsl:text>"""@</xsl:text>
                    <xsl:value-of select="$TGT_LANG"/>
                    <xsl:text>.&#10;</xsl:text>
                </xsl:when>
            </xsl:choose>
            
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>

    </xsl:template>

    <!-- eliminate quotes -->
    <xsl:template name="normalize-entry">
        <xsl:param name="str"/>
        <xsl:value-of select="normalize-space(replace($str,'&quot;',''))"/>
    </xsl:template>
</xsl:stylesheet>
