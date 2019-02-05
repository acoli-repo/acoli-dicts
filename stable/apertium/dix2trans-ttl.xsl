<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

<xsl:output method="text" indent="no"/>
   
    <xsl:param name="SRC_LANG">SET_SRC_LANG</xsl:param>
    <xsl:param name="TGT_LANG">SET_TGT_LANG</xsl:param>
    
    <xsl:variable name="lexicon">
        <xsl:text>http://linguistic.linkeddata.es/id/apertium/tranSet</xsl:text>
        <xsl:value-of select="upper-case($SRC_LANG)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="upper-case($TGT_LANG)"/>
    </xsl:variable>
	
    <xsl:variable name="src">
        <xsl:text>http://linguistic.linkeddata.es/id/apertium/lexicon</xsl:text>
		<xsl:value-of select="upper-case($SRC_LANG)"/>
    </xsl:variable>

    <xsl:variable name="tgt">
        <xsl:text>http://linguistic.linkeddata.es/id/apertium/lexicon</xsl:text>
		<xsl:value-of select="upper-case($TGT_LANG)"/>
    </xsl:variable>

    
    <xsl:param name="dc_source"/>
    
    <xsl:template match="/">
		<xsl:text disable-output-escaping="yes">@prefix apertium: &lt;http://wiki.apertium.org/wiki/Bidix#> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix dc: &lt;http://purl.org/dc/elements/1.1/> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix foaf: &lt;http://xmlns.com/foaf/0.1/> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix lexinfo: &lt;http://www.lexinfo.net/ontology/2.0/lexinfo#> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix xsd: &lt;http://www.w3.org/2001/XMLSchema#> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix owl: &lt;http://www.w3.org/2002/07/owl#> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix rdf: &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix ontolex: &lt;http://www.w3.org/ns/lemon/ontolex#> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix lime: &lt;http://www.w3.org/ns/lemon/lime#> .&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix vartrans: &lt;http://www.w3.org/ns/lemon/vartrans#> .&#10;</xsl:text>
        <xsl:value-of disable-output-escaping="yes" select="concat('@prefix : &lt;',$lexicon,'/> . &#10;&#10;')"/>
        <xsl:value-of disable-output-escaping="yes" select="concat('@prefix src: &lt;',$src,'/> . &#10;&#10;')"/>
        <xsl:value-of disable-output-escaping="yes" select="concat('@prefix tgt: &lt;',$tgt,'/> . &#10;&#10;')"/>
        
        <xsl:value-of select="concat('&lt;',$lexicon,'>')"/>
        <xsl:text> a vartrans:TranslationSet</xsl:text>
        <xsl:text>;&#10; rdfs:label "Apertium </xsl:text>
        <xsl:value-of select="upper-case($SRC_LANG)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="upper-case($TGT_LANG)"/>
        <xsl:text> translation set"@en</xsl:text>
        <xsl:if test="string-length($dc_source)>0">
            <xsl:text>;&#10; dc:source </xsl:text>
            <xsl:value-of select="concat('&lt;',$dc_source,'>')"/>
        </xsl:if>
        <xsl:text>;&#10; rdfs:comment "This is the RDF version of the Apertium bilingual dictionary for the languages </xsl:text>
        <xsl:value-of select="$SRC_LANG"/>
        <xsl:text> and </xsl:text>
        <xsl:value-of select="$TGT_LANG"/>
        <xsl:text> .  It is a direct conversion from the Apertium Bidix into OntoLex-lemon, not mediated by of an LMF version."@en</xsl:text>
        <xsl:text>;&#10; lime:language "</xsl:text>
        <xsl:value-of select="lower-case($SRC_LANG)"/>
        <xsl:text>", "</xsl:text>
        <xsl:value-of select="lower-case($TGT_LANG)"/>
        <xsl:text>".&#10; </xsl:text>
        
        <xsl:for-each select="//e/p">
            <xsl:variable name="l" select="replace(l/text()[1],'&quot;','')"/>
            <xsl:variable name="r" select="replace(r/text()[1],'&quot;','')"/>
            
            <xsl:if test="normalize-space(concat($r,$l))!='' and matches(encode-for-uri($l),'^[_a-zA-Z0-9%].*') and matches(encode-for-uri($r),'^[_a-zA-Z0-9%].*')">
                <xsl:variable name="ls" select="l/s[1]/@n"/>
                <xsl:variable name="rs" select="l/s[1]/@n"/>                
                <xsl:variable name="llexent" select="concat('src:',replace(encode-for-uri(concat($l,'-',$ls,'-',lower-case($SRC_LANG))),'---*','-'))"/>
                <xsl:variable name="rlexent" select="concat('tgt:',replace(encode-for-uri(concat($r,'-',$rs,'-',lower-case($TGT_LANG))),'---*','-'))"/>
                
                <xsl:variable name="lsense" select="concat(':',replace(encode-for-uri(concat($l,'_',$r,'-',$ls,'-',lower-case($SRC_LANG),'-sense')),'---*','-'))"/>
                <xsl:variable name="rsense" select="concat(':',replace(encode-for-uri(concat($r,'_',$l,'-',$rs,'-',lower-case($TGT_LANG),'-sense')),'---*','-'))"/>
                <xsl:variable name="trans" select="concat($lsense,'-',replace($rsense,'^:',''),'-trans')"/>
                
                <xsl:value-of select="concat('&lt;',$lexicon,'>')"/>
                <xsl:text> vartrans:trans </xsl:text>
                <xsl:value-of select="$trans"/>
                <xsl:text> .&#10;</xsl:text>
                
                <xsl:value-of select="$trans"/>
                <xsl:text> a vartrans:Translation</xsl:text>
                <xsl:text>;&#10; vartrans:source </xsl:text>
                <xsl:value-of select="$lsense"/>
                <xsl:text>;&#10; vartrans:target </xsl:text>
                <xsl:value-of select="$rsense"/>
                <xsl:text> .&#10;</xsl:text>

                <xsl:value-of select="$lsense"/>
                <xsl:text> a ontolex:LexicalSense</xsl:text>
                <xsl:text>;&#10; ontolex:isSenseOf </xsl:text>
                <xsl:value-of select="$llexent"/>
                <xsl:text> .&#10;</xsl:text>
                    
                <xsl:value-of select="$rsense"/>
                <xsl:text> a ontolex:LexicalSense</xsl:text>
                <xsl:text>;&#10; ontolex:isSenseOf </xsl:text>
                <xsl:value-of select="$rlexent"/>
                <xsl:text> .&#10;</xsl:text>
                
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
