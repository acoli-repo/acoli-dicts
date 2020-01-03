<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <!-- ontolex conversion of free-dict.de content. note that this dictionary is *not* a bidictionary, so no information about target language glosses is provided.
         The translation is thus represented as a rdfs:label attached to the concept. 
         Note that we differ from the FreeDict encoding in chosing the conceptually sparser concept model instead of using word senses -->
    <xsl:output method="text" indent="no"/>
    
    <xsl:param name="SRC_LANG">zza</xsl:param>
    <xsl:param name="TGT_LANG">de</xsl:param>

    <xsl:param name="lexicon">
        <xsl:text>http://purl.org/acoli/dicts/free-dict.de/lexicon-</xsl:text>
        <xsl:value-of select="$SRC_LANG"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$TGT_LANG"/>
    </xsl:param>
    
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
        <xsl:value-of disable-output-escaping="yes" select="concat('@prefix : &lt;',$lexicon,'/> . &#10;&#10;')"/>
        
        <xsl:value-of select="concat('&lt;',$lexicon,'>')"/>
        <xsl:text> a lime:Lexicon</xsl:text>
        <xsl:text>;&#10; lime:language "</xsl:text>
        <xsl:value-of select="$SRC_LANG"/>
        <xsl:text>".&#10; </xsl:text>
        
        <xsl:for-each select="//table[count(tr[1]/th[1])=1]">
            <xsl:for-each select="tr[count(td[1])=1]">
                <xsl:variable name="src">
                    <xsl:variable name="tmp">
                        <xsl:for-each select="td[2]/text()">
                            <xsl:value-of select="."/>
                            <xsl:text> </xsl:text>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="normalize-space(replace($tmp,'&quot;',' '))"/>
                </xsl:variable>
                <xsl:variable name="tgt">
                    <xsl:variable name="tmp">
                        <xsl:for-each select="td[1]/text()">
                            <xsl:value-of select="."/>
                            <xsl:text> </xsl:text>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="normalize-space(replace($tmp,'&quot;',' '))"/>
                </xsl:variable>
                
                <xsl:text>&#10;# </xsl:text>
                <xsl:value-of select="$src"/>
                <xsl:text>&#9;</xsl:text>
                <xsl:value-of select="$tgt"/>
                <xsl:text>&#10;</xsl:text>
                
                <xsl:variable name="entry">
                    <xsl:variable name="tmp">
                        <xsl:call-template name="normalize-entry">
                            <xsl:with-param name="str" select="$src"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="concat(':',encode-for-uri($tmp))"/>
                </xsl:variable>
                <xsl:variable name="writtenRep" select="normalize-space(replace($src,'\([^\)]+\)',''))"/>
                <xsl:variable name="concept">
                    <xsl:variable name="tmp">
                        <xsl:call-template name="normalize-entry">
                            <xsl:with-param name="str" select="$tgt"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="concat(':',encode-for-uri($tmp),'_concept')"/>
                </xsl:variable>             
                <xsl:variable name="conceptLabel" select="normalize-space(replace($tgt,'\([^\)]+\)',''))"/>
                
                <xsl:value-of select="concat('&lt;',$lexicon,'>')"/>
                <xsl:text> lime:entry </xsl:text>
                <xsl:value-of select="$entry"/>
                <xsl:text> .&#10;</xsl:text>
                
                <xsl:value-of select="$entry"/>
                <xsl:text> a ontolex:LexicalEntry </xsl:text>
                <xsl:if test="$writtenRep != $src">
                    <xsl:text>;&#10;&#9; rdfs:label "</xsl:text>
                    <xsl:value-of select="$src"/>
                    <xsl:text>" </xsl:text>
                </xsl:if>
                <xsl:text> ;&#10;&#9; ontolex:lexicalForm </xsl:text>
                        <xsl:for-each select="tokenize($writtenRep,'[,;/]')">
                            <xsl:text>[ ontolex:writtenRep "</xsl:text>
                            <xsl:value-of select="normalize-space(.)"/>
                            <xsl:text>"@</xsl:text>
                            <xsl:value-of select="$SRC_LANG"/>
                            <xsl:text> ] </xsl:text>
                            <xsl:if test="not(position() eq last())"> <xsl:text>,&#10;&#9;&#9;</xsl:text> </xsl:if>
                        </xsl:for-each>
                <xsl:text>;&#10;&#9; ontolex:evokes </xsl:text>
                <xsl:value-of select="$concept"/>
                <xsl:text> .&#10;</xsl:text>
                <xsl:value-of select="$concept"/>
                <xsl:text> a ontolex:LexicalConcept ;&#10;&#9; rdfs:label </xsl:text>
                <xsl:for-each select="tokenize($conceptLabel,'[,;/]')">
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="normalize-space(.)"/>
                    <xsl:text>"@</xsl:text>
                    <xsl:value-of select="$TGT_LANG"/>
                    <xsl:if test="not(position() eq last())"> <xsl:text>,&#10;&#9;&#9;</xsl:text> </xsl:if>
                </xsl:for-each>
                <xsl:if test="$conceptLabel != $tgt">
                    <xsl:text>;&#10;&#9;skos:definition "</xsl:text>
                    <xsl:value-of select="$tgt"/>
                    <xsl:text>"@</xsl:text>
                    <xsl:value-of select="$TGT_LANG"/>
                </xsl:if>
                <xsl:text> .&#10;</xsl:text>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <!-- eliminate quotes, resolve tilde -->
    <xsl:template name="normalize-entry">
        <xsl:param name="str"/>
        <xsl:value-of select="translate(normalize-space(translate($str,'~., ()[]&quot;/#;','            ')),' ','_')"/>
    </xsl:template>
</xsl:stylesheet>