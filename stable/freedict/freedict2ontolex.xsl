<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

    <!-- ontolex conversion of freedict content. note that this dictionary is *not* a bidictionary, so no information about target language glosses is provided.
         The translation is thus represented as a rfds:label attached to the sense. No use of the vartrans model -->
    <xsl:output method="text" indent="no"/>
    
    <xsl:param name="SRC_LANG">SET_SRC_LANG</xsl:param>
    <xsl:param name="TGT_LANG">SET_TGT_LANG</xsl:param>

    <xsl:variable name="lexicon">
        <xsl:text>http://purl.org/acoli/dicts/freedict/lexicon-</xsl:text>
        <xsl:value-of select="$SRC_LANG"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$TGT_LANG"/>
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
        <xsl:value-of disable-output-escaping="yes" select="concat('@prefix : &lt;',$lexicon,'/> . &#10;&#10;')"/>
        
        <xsl:value-of select="concat('&lt;',$lexicon,'>')"/>
        <xsl:text> a lime:Lexicon</xsl:text>
        <xsl:text>;&#10; lime:language "</xsl:text>
        <xsl:value-of select="$SRC_LANG"/>
        <xsl:text>".&#10; </xsl:text>
        
        <xsl:for-each select="//tei:entry">
            <xsl:variable name="l">
                <xsl:call-template name="normalize-entry">
                    <xsl:with-param name="str" select="tei:form[1]/tei:orth[1]/text()[1]"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="normalize-space($l)!='' and matches(encode-for-uri($l),'^[_a-zA-Z0-9%].*')">
                <xsl:variable name="lexent" select="concat(':',replace(replace(encode-for-uri(concat($l,'-',lower-case($SRC_LANG))),'~',''),'---*','-'))"/>
                
                <xsl:value-of select="concat('&lt;',$lexicon,'>')"/>
                <xsl:text> lime:entry </xsl:text>
                <xsl:value-of select="$lexent"/>
                <xsl:text> . &#10;</xsl:text>
                
                <xsl:value-of select="$lexent"/>
                <xsl:text> a ontolex:LexicalEntry .&#10;</xsl:text>
                
                <xsl:for-each select="tei:form/tei:orth">
                    <xsl:variable name="f">
                        <xsl:call-template name="normalize-entry">
                            <xsl:with-param name="str" select="text()[1]"/>
                        </xsl:call-template>
                    </xsl:variable>                        
                    <xsl:if test="normalize-space($f)!='' and matches(encode-for-uri($f),'^[_a-zA-Z0-9%].*') and not(contains($f,'\'))">
                        <xsl:variable name="form" select="concat($lexent,'-',replace(encode-for-uri($f),'~',''),'-form')"/>
                
                        <xsl:value-of select="$lexent"/>
                        <xsl:text> ontolex:lexicalForm </xsl:text>
                        <xsl:value-of select="$form"/>
                        <xsl:text> . &#10;</xsl:text>
                        
                        <xsl:value-of select="$form"/>
                        <xsl:text> a ontolex:Form</xsl:text>
                        <xsl:text>; &#10; ontolex:writtenRep """</xsl:text>
                        <xsl:value-of select="$f"/>
                        <xsl:text>"""@</xsl:text>
                        <xsl:value-of select="$SRC_LANG"/>
                        <xsl:text> . &#10;</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                
                <xsl:for-each select="tei:sense/tei:cit[@type='trans']/tei:quote">
                    <xsl:variable name="s">
                        <xsl:call-template name="normalize-entry">
                            <xsl:with-param name="str" select="text()[1]"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:if test="normalize-space($s)!='' and matches(encode-for-uri($s),'^[_a-zA-Z0-9%].*') and not(contains($s,'\'))">
                        <xsl:variable name="sense" select="concat($lexent,'-',replace(encode-for-uri($s),'~',''),'-sense')"/>
                        
                        <xsl:value-of select="$sense"/>
                        <xsl:text> a ontolex:Sense</xsl:text>
                        <xsl:text>; &#10; ontolex:isSenseOf </xsl:text>
                        <xsl:value-of select="$lexent"/>
                        <xsl:text>; &#10; rdfs:label """</xsl:text>
                        <xsl:value-of select="$s"/>
                        <xsl:text>"""@</xsl:text>
                        <xsl:value-of select="$TGT_LANG"/>
                        <xsl:text> . &#10;</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:text> &#10;</xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- eliminate quotes, resolve tilde -->
    <xsl:template name="normalize-entry">
        <xsl:param name="str"/>
        <xsl:choose>
            <!-- Latin comma -->
            <xsl:when test="matches($str,'.*,.*~.*')">
                <xsl:variable name="headword" select="normalize-space(substring-before($str,','))"/>
                <xsl:call-template name="normalize-entry">
                    <xsl:with-param name="str">
                        <xsl:value-of select="substring-before($str,'~')"/>
                        <xsl:value-of select="$headword"/>
                        <xsl:value-of select="substring-after($str,'~')"/>
                    </xsl:with-param>
                </xsl:call-template>                
            </xsl:when>
            <!-- Arabic comma -->
            <xsl:when test="matches($str,'.*،.*~.*')">
                <xsl:variable name="headword" select="normalize-space(substring-before($str,'،'))"/>
                <xsl:call-template name="normalize-entry">
                    <xsl:with-param name="str">
                        <xsl:value-of select="substring-before($str,'~')"/>
                        <xsl:value-of select="$headword"/>
                        <xsl:value-of select="substring-after($str,'~')"/>
                    </xsl:with-param>
                </xsl:call-template>                
            </xsl:when>
            <!-- parentheses -->
            <xsl:when test="matches($str,'.*\(.*~.*')">
                <xsl:variable name="headword" select="normalize-space(substring-before($str,'\('))"/>
                <xsl:call-template name="normalize-entry">
                    <xsl:with-param name="str">
                        <xsl:value-of select="substring-before($str,'~')"/>
                        <xsl:value-of select="$headword"/>
                        <xsl:value-of select="substring-after($str,'~')"/>
                    </xsl:with-param>
                </xsl:call-template>                
            </xsl:when>
            <!-- used in (German glosses of) German-Kurdish dictionary instead of a comma, probably by mistake -->
            <xsl:when test="matches($str,'.*¸.*~.*')">
                <xsl:variable name="headword" select="normalize-space(substring-before($str,'¸'))"/>
                <xsl:call-template name="normalize-entry">
                    <xsl:with-param name="str">
                        <xsl:value-of select="substring-before($str,'~')"/>
                        <xsl:value-of select="$headword"/>
                        <xsl:value-of select="substring-after($str,'~')"/>
                    </xsl:with-param>
                </xsl:call-template>                
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="replace($str,'&quot;','')"/>
            </xsl:otherwise>                
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>