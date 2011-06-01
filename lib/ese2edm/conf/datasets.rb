require 'rdf'
require 'rdf/raptor'

require 'nokogiri'
require 'rexml/document'

module ESE2EDM  
    
    # A wrapper around the void dataset description for convenient access
    class Dataset
      
      DEFAULT_DATASETS_PATH = "dataset"
      DEFAULT_LINKS_PATH = "links"
      
      attr_reader :uri

      # takes a pointer to the graph and the subject uri identifying a dataset
      def initialize(args)
        @graph = args[:graph]
        @uri = args[:uri]
      end
      
      # returns the dataset title
      def title
        query_property_values :predicate => DCTERMS.title do |title|
          return title
        end
      end
      
      # returns all XML file URIs associated with a data file
      def xml_files
        xml_files = []
        query_property_values :predicate => EULOD.xmlfile do |xml_file|
          xml_files << xml_file
        end
        return xml_files
      end
      
      # returns all subsets of this dataset (recursively if desired)
      def each_subset(recursive = false)
        query_property_values :predicate => VOID.subset do |object|
          subset = Dataset.new :graph => @graph, :uri => object
          yield subset
          subset.each_subset(recursive) {|subset| yield subset} if recursive
        end
      end
      
      # generates a html version 
      def to_html
        builder = Nokogiri::HTML::Builder.new do |doc|
          doc.html {
            doc.body {
              doc.ul {
                doc.li "Bla"
                doc.li "Blub"
              }
            }
          }
        end
        html = builder.to_html
        
        doc = REXML::Document.new(html)
        doc.write($stdout, indent_spaces = 4)
        
      end
      
      # loads the void dataset from a given file
      def self.load(file, uri)
        graph = RDF::Graph.load(file)
        Dataset.new :graph => graph, :uri => uri
      end

    private
      
      # yields property values for the URI subject and a given property
      def query_property_values(args)
        predicate = args[:predicate]
        
        # retrieve all matching triples
        solutions = RDF::Query.execute(@graph) do
          pattern [:subject, predicate, :object]
        end
        
        # filter the one having the dataset uri as subject
        solutions.filter(:subject  => RDF::URI(@uri)).each do |solution|
          object = solution[:object].to_s
          yield object
        end
      end
      
    end # end of class dataset
    
    
    # Europeana-LOD specific terms used in void description
    class EULOD < RDF::Vocabulary("http://data.europeana.eu/conf#")
      property :xmlfile
    end
    
    # VOID vocabulary
    class VOID < RDF::Vocabulary("http://rdfs.org/ns/void#")
      property :subset
    end
    
    # DCTerms vocabulary
    class DCTERMS < RDF::Vocabulary("http://purl.org/dc/terms/")
      property :title
    end
    
end 


dataset = ESE2EDM::Dataset.load("../../../datasets/edm-datasets-1.0.ttl", "http://data.europeana.eu/void.ttl#EuropeanaLOD")

dataset.each_subset(true) do |dataset|
  puts dataset.uri
  puts dataset.title
  #puts dataset.xml_files
  dataset.xml_files.each {|xml_file| puts xml_file}
end

#dataset.to_html
