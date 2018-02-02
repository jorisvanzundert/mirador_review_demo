<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0">

<xsl:template match="tei:TEI.2">
  <html>
    <head>
      <meta charset="UTF-8"/>
      <meta name="description" content="A diplomatic rendering of Van den Vos Reynaerde in ms. Cod.poet.et.phil.fol.22 of the Württembergische Landesbibliothek Stuttgart"/>
      <meta name="keywords" content="HTML,CSS,XML,JavaScript"/>
      <meta name="author" content="Joris J. van Zundert"/>
      <title>Van den Vos Reynaerde — critical transcript of a few lines</title>
      <link rel="stylesheet" type="text/css" href="/body.css"/>
      <link rel="stylesheet" type="text/css" href="/folio.css"/>
    </head>
    <body>
      <xsl:apply-templates select="tei:text/tei:body/tei:div[@type='folio']"/>
    </body>
  </html>
</xsl:template>

<xsl:template match="tei:text/tei:body/tei:div[@type='folio']">
  <xsl:element name="div">
    <xsl:attribute name="class">folio</xsl:attribute>
    <xsl:attribute name="folio">
      <xsl:value-of select="@n"/>
    </xsl:attribute>
    <div class="column_text">
      <xsl:apply-templates select="tei:head"/>
      <xsl:apply-templates select="tei:div[@type='part']"/>
    </div>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:head">
  <div class="title">
    <xsl:value-of select="tei:title/tei:choice/tei:reg"/>
  </div>
</xsl:template>

<xsl:template match="tei:div[@type='part']">
  <div class="column_text">
    <xsl:apply-templates select="tei:l"/>
  </div>
</xsl:template>

<xsl:template match="tei:l">
  <div class="verse_line"><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match="tei:subst">
  <xsl:apply-templates select="tei:del"/>
</xsl:template>

<xsl:template match="tei:choice">
  <xsl:apply-templates select="tei:expan|tei:reg"/>
</xsl:template>

<xsl:template match="tei:app">
  <xsl:apply-templates select="tei:lem"/>
</xsl:template>

</xsl:stylesheet>
