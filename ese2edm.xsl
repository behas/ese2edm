<?xml version="1.0" encoding="UTF-8"?>
<!-- 

Europeana ESE to EDM Mapping stylesheet

This specifications reflects the mapping specifications defined at http://europeanalabs.eu/wiki/EDMPrototypingTask15?version=18

WARNING: due to a bug in the ESE XML source data at the time of its creation, this stylesheet uses a wrong ESE namespace abbreviation (http://www.europeana.eu instead of "http://www.europeana.eu/schemas/ese/).

Version: 0.4
Date: 2011-03-02
Authors: Bernhard Haslhofer (University of Vienna), Antoine Isaac (VU Amsterdam)

-->
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
 	xmlns:dct="http://purl.org/dc/terms/"
 	xmlns:ens="http://www.europeana.eu/schemas/edm/"
 	xmlns:ese="http://www.europeana.eu"
 	xmlns:ore="http://www.openarchives.org/ore/terms/"
 	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
 	xmlns:foaf="http://xmlns.com/foaf/0.1/"
 	xmlns:xhtml="http://www.w3.org/1999/xhtml/vocab#"
	version="1.0">
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<!-- define the Europena BASE URI as global variable -->
	<xsl:variable name="EUROPEANA_BASE_URI" select="'http://www.europeana.eu'" />
	<!-- define the EDM base URI as global variable -->
	<xsl:variable name="EDM_BASE_URI" select="'http://data.europeana.eu'" />
	
	<!-- template matching the root node and create the RDF start tag -->
	<xsl:template match="/">

		<rdf:RDF>
		
	  	<xsl:apply-templates/>
		
		</rdf:RDF>

	</xsl:template>
	
		
	<!-- template matching a single ESE XML record -->
	<xsl:template match="metadata/record">
				
		<!-- determine the instituteID and objectIDhash from the European URI of this record -->
		<xsl:variable name="OBJECTID_HASH">
			<xsl:value-of select="substring-after(substring-after(ese:uri,'/record/'),'/')"/>
		</xsl:variable>
		<xsl:variable name="INSTITUTE_ID">
			<xsl:value-of select="substring-before(substring-after(ese:uri,'/record/'),'/')"/>
		</xsl:variable>
		
		<!-- construct the identifiers for object, aggregations, and proxies for this record -->
		<xsl:variable name="record_uri" select="concat($EUROPEANA_BASE_URI, '/', 'resolve/record/', $INSTITUTE_ID, '/', $OBJECTID_HASH)"/>
		<xsl:variable name="landing_page_uri" select="concat($EUROPEANA_BASE_URI, '/', 'portal/record/', $INSTITUTE_ID, '/', $OBJECTID_HASH,'.html')"/>
		
		<xsl:variable name="object_uri" select="concat($EDM_BASE_URI, '/', 'item', '/', $INSTITUTE_ID, '/', $OBJECTID_HASH)"/>
		<xsl:variable name="europeana_resourcemap_uri" select="concat($EDM_BASE_URI, '/', 'rm', '/', 'europeana', '/', $INSTITUTE_ID, '/', $OBJECTID_HASH)"/>
		<xsl:variable name="provider_agg_uri" select="concat($EDM_BASE_URI, '/', 'aggregation', '/', 'provider', '/', $INSTITUTE_ID, '/', $OBJECTID_HASH)"/>
		<xsl:variable name="provider_proxy_uri" select="concat($EDM_BASE_URI, '/', 'proxy', '/', 'provider', '/', $INSTITUTE_ID, '/', $OBJECTID_HASH)"/>
		<xsl:variable name="europeana_agg_uri" select="concat($EDM_BASE_URI, '/', 'aggregation', '/', 'europeana', '/', $INSTITUTE_ID, '/', $OBJECTID_HASH)"/>
		<xsl:variable name="europeana_proxy_uri" select="concat($EDM_BASE_URI, '/', 'proxy', '/', 'europeana', '/', $INSTITUTE_ID, '/', $OBJECTID_HASH)"/>


		<!-- ...and produce a self-contained RDF/XML file out of it -->

		<!-- Step1: OBJECT -->
		<rdf:Description>
			<xsl:attribute name="rdf:about"><xsl:copy-of select="$object_uri"/></xsl:attribute>
			<foaf:isPrimaryTopicOf>
				<xsl:attribute name="rdf:resource"><xsl:copy-of select="$record_uri"/></xsl:attribute>
			</foaf:isPrimaryTopicOf>
			<foaf:isPrimaryTopicOf>
				<xsl:attribute name="rdf:resource"><xsl:copy-of select="$europeana_resourcemap_uri"/></xsl:attribute>
			</foaf:isPrimaryTopicOf>
		</rdf:Description>

		<!-- Step1: PROVIDER AGGREGATION -->
		<ore:Aggregation>
			<xsl:attribute name="rdf:about"><xsl:copy-of select="$provider_agg_uri"/></xsl:attribute>
				
			<!-- Step 3: link provider aggregation with ens:Object/PhysicalThing -->
			<ore:aggregatedCHO>
				<xsl:attribute name="rdf:resource"><xsl:copy-of select="$object_uri"/></xsl:attribute>
			</ore:aggregatedCHO>
			
			<!-- Mapping of original ESE fields -->
			<xsl:for-each select="ese:dataProvider">
				<ens:dataProvider><xsl:value-of select="."/></ens:dataProvider>
			</xsl:for-each>
			<xsl:for-each select="ese:isShownAt">
				<ens:isShownAt>
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="."/>
					</xsl:attribute>
				</ens:isShownAt>
			</xsl:for-each>
			<xsl:for-each select="ese:isShownBy">
				<ens:isShownBy>
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="."/>
					</xsl:attribute>
				</ens:isShownBy>
			</xsl:for-each>
			<xsl:for-each select="ese:object">
				<ens:object>
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="."/>
					</xsl:attribute>
				</ens:object>
			</xsl:for-each>
			<xsl:for-each select="ese:provider">
				<ens:provider><xsl:value-of select="."/></ens:provider>
			</xsl:for-each>
			<xsl:for-each select="dc:rights">
				<dc:rights><xsl:value-of select="."/></dc:rights>
			</xsl:for-each>
			<xsl:for-each select="ese:rights">
				<ens:rights>
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="."/>
					</xsl:attribute>
				</ens:rights>
			</xsl:for-each>
			<xsl:for-each select="ese:unstored">
				<ens:unstored><xsl:value-of select="."/></ens:unstored>
			</xsl:for-each>
				
		</ore:Aggregation>
		  
			
		<!-- Step1: PROVIDER PROXY -->
		<ore:Proxy>
			<xsl:attribute name="rdf:about"><xsl:copy-of select="$provider_proxy_uri"/></xsl:attribute>
				
			<!-- Step 3: link provider provider proxy with ens:Object/PhysicalThing -->
			<ore:proxyFor>
				<xsl:attribute name="rdf:resource"><xsl:copy-of select="$object_uri"/></xsl:attribute>
			</ore:proxyFor>

			<!-- Step 3: link provider provider proxy with provider ore:Aggregation -->
			<ore:proxyIn>
				<xsl:attribute name="rdf:resource"><xsl:copy-of select="$provider_agg_uri"/></xsl:attribute>
			</ore:proxyIn>
				
			<!-- Mapping of original ESE fields -->
			<xsl:for-each select="ese:type">
				<ens:type><xsl:value-of select="."/></ens:type>
			</xsl:for-each>
				
			<!-- deal with "other" corresponding properties -->
			<xsl:call-template name="map_other_properties"/>
				
		</ore:Proxy>	

			
		<!-- Step 2: EUROPEANA AGGREGATION -->
		<ens:EuropeanaAggregation>
			<xsl:attribute name="rdf:about"><xsl:copy-of select="$europeana_agg_uri"/></xsl:attribute>
				
			<!-- Step 3: link europeana aggregation with ens:Object/PhysicalThing -->
			<ore:aggregatedCHO>
				<xsl:attribute name="rdf:resource"><xsl:copy-of select="$object_uri"/></xsl:attribute>
			</ore:aggregatedCHO>

<!-- NEW -->
			<ore:isDescribedBy>
				<xsl:attribute name="rdf:resource"><xsl:copy-of select="$europeana_resourcemap_uri"/></xsl:attribute>
			</ore:isDescribedBy>

			<!-- Step 3: link europeana aggregation with provider's aggregation -->
			<ore:aggregates>
				<xsl:attribute name="rdf:resource"><xsl:copy-of select="$provider_agg_uri"/></xsl:attribute>
			</ore:aggregates>
				
			<!-- Step 4: dc:creator with "Europeana" as object (could be a fully fledged resource in a later mapping) -->
			<dc:creator>Europeana</dc:creator>

			<!-- Step 4: ens:landingPage with the URL of Europeana HTML object page as object -->
			<ens:landingPage>
				<xsl:attribute name="rdf:resource">
					<xsl:value-of select="$landing_page_uri"/>
				</xsl:attribute>
			</ens:landingPage>

			<!-- Step 4: ens:isShownBy with the thumbnail URL as object -->
			<xsl:for-each select="ese:isShownBy">
				<ens:isShownBy>
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="."/>
					</xsl:attribute>
				</ens:isShownBy>
			</xsl:for-each>

<!-- NEW -->
			<xsl:for-each select="ese:object">
			  <xsl:if test='../ese:type'>
			    <xsl:variable name="ese_type"><xsl:value-of select="../ese:type"/></xsl:variable>
			    <xsl:variable name="thumbnail_uri" select="concat('http://europeanastatic.eu/api/image?uri=',.,'&amp;size=FULL_DOC&amp;type=',$ese_type)"/>			 
				<ens:hasView>
					<xsl:attribute name="rdf:resource">
						<xsl:copy-of select="$thumbnail_uri"/>
					</xsl:attribute>
				</ens:hasView>
				<foaf:depiction rdf:parseType="Resource">
					<foaf:thumbnail>
					  <xsl:attribute name="rdf:resource">
						<xsl:copy-of select="$thumbnail_uri"/>
					  </xsl:attribute>
					</foaf:thumbnail>
				</foaf:depiction>
			  </xsl:if>
			</xsl:for-each>
			
			<!-- Mapping of original ESE fields -->
			<xsl:for-each select="ese:country">
				<ens:country><xsl:value-of select="normalize-space(.)"/></ens:country>
			</xsl:for-each>
			<xsl:for-each select="ese:language">
				<ens:language><xsl:value-of select="normalize-space(.)"/></ens:language>
			</xsl:for-each>
				
		</ens:EuropeanaAggregation>
		  

		<!-- Step 2: EUROPEANA PROXY -->
		<ore:Proxy>
			<xsl:attribute name="rdf:about"><xsl:copy-of select="$europeana_proxy_uri"/></xsl:attribute>
				
			<!-- Step 3: link provider provider proxy with ens:Object/PhysicalThing -->
			<ore:proxyFor>
				<xsl:attribute name="rdf:resource"><xsl:copy-of select="$object_uri"/></xsl:attribute>
			</ore:proxyFor>

			<!-- Step 3: link provider provider proxy with provider ore:Aggregation -->
			<ore:proxyIn>
				<xsl:attribute name="rdf:resource"><xsl:copy-of select="$europeana_agg_uri"/></xsl:attribute>
			</ore:proxyIn>
				
			<!-- Mapping of original ESE fields -->
			<xsl:for-each select="ese:type">
				<ens:type><xsl:value-of select="."/></ens:type>
			</xsl:for-each>
			<xsl:for-each select="ese:userTag">
				<ens:userTag><xsl:value-of select="."/></ens:userTag>
			</xsl:for-each>
			<xsl:for-each select="ese:year">
				<ens:year><xsl:value-of select="."/></ens:year>
			</xsl:for-each>
				
		</ore:Proxy>	

<!-- NEW -->
		<!-- Step X: RESOURCE MAP -->
		<ore:ResourceMap>
			<xsl:attribute name="rdf:about"><xsl:copy-of select="$europeana_resourcemap_uri"/></xsl:attribute>
				
			<foaf:primaryTopic>
				<xsl:attribute name="rdf:resource"><xsl:copy-of select="$object_uri"/></xsl:attribute>
			</foaf:primaryTopic>

			<ore:describes>
				<xsl:attribute name="rdf:resource"><xsl:copy-of select="$europeana_agg_uri"/></xsl:attribute>
			</ore:describes>

			<xhtml:license>
				<xsl:attribute name="rdf:resource">http://creativecommons.org/publicdomain/zero/1.0/</xsl:attribute>
			</xhtml:license>

			<dc:publisher>Europeana</dc:publisher>
			<xsl:for-each select="ese:provider">
				<dc:contributor><xsl:value-of select="."/></dc:contributor>
			</xsl:for-each>
			<xsl:for-each select="ese:dataProvider">
				<dc:contributor><xsl:value-of select="."/></dc:contributor>
			</xsl:for-each>
				
		</ore:ResourceMap>

	</xsl:template>

	
	<!-- a named template, which can be called for mapping all other properties 
		TODO:
			- improve this and simply match for previously unmatched nodes
			- this could also be improved with XSLT 2.0 copy-of
	-->
	<xsl:template name="map_other_properties">

		<xsl:for-each select="dc:description">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dc:description</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		
		<xsl:for-each select="dc:title">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dc:title</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		
		<xsl:for-each select="dc:coverage">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dc:coverage</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		
		<xsl:for-each select="dc:format">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dc:format</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		
		<xsl:for-each select="dct:alternative">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:alternative</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		
		<xsl:for-each select="dct:spatial">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:spatial</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		
		<xsl:for-each select="dct:extent">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:extent</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		
		<xsl:for-each select="dc:creator">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dc:creator</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		
		
		<xsl:for-each select="dct:temporal">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:temporal</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		
		
		<xsl:for-each select="dct:medium">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:medium</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		
		
		<xsl:for-each select="dc:contributor">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dc:contributor</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		
		
		<xsl:for-each select="dc:identifier">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dc:identifier</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		
		
		<xsl:for-each select="dc:date">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dc:date</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		
		
		<xsl:for-each select="dct:isPartOf">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:isPartOf</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		
		
		<xsl:for-each select="dct:created">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:created</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		
		
		<xsl:for-each select="dc:language">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dc:language</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		

		<xsl:for-each select="dct:provenance">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:provenance</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		

		<xsl:for-each select="dct:issued">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:issued</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		

		<xsl:for-each select="dc:publisher">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dc:publisher</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		

		<xsl:for-each select="dc:relation">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dc:relation</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		

		<xsl:for-each select="dc:source">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dc:source</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		

		<xsl:for-each select="dct:conformsTo">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:conformsTo</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		

		<xsl:for-each select="dc:subject">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dc:subject</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		

		<xsl:for-each select="dct:hasFormat">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:hasFormat</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		

		<xsl:for-each select="dc:type">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dc:type</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		

		<xsl:for-each select="dct:isFormatOf">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:isFormatOf</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="dct:hasVersion">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:hasVersion</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="dct:isVersionOf">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:isVersionOf</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="dct:hasPart">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:hasPart</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="dct:isReferencedBy">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:isReferencedBy</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="dct:references">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:references</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="dct:isReplacedBy">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:isReplacedBy</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="dct:replaces">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:replaces</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="dct:isRequiredBy">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:isRequiredBy</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		

		<xsl:for-each select="dct:requires">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:requires</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		

		<xsl:for-each select="dct:tableOfContents">
			<xsl:call-template name="create_property">
				<xsl:with-param name="tgt_property">dct:tableOfContents</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>		

	</xsl:template>
	
	
	<!-- this template creates an output property with a given name and copies all attributes from the context node -->
	<xsl:template name="create_property">
		<xsl:param name="tgt_property"/>
		<xsl:element name="{$tgt_property}">
			<xsl:for-each select="@xml:lang">
		  	<xsl:copy/>
			</xsl:for-each>
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>
	

</xsl:stylesheet>


