require 'rdf'
require 'rdf/raptor' 

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
      
      # returns all XML file URIs associated with a data file
      def each_xml_file
        
        query_property_values :subject => @uri, :predicate => ESE2EDM::EULOD.xmlfile do |xml_file|
          yield xml_file
        end
        
      end
      
      # returns all subsets of this dataset 
      def each_subset
        
        query_property_values :subject => @uri, :predicate => ESE2EDM::VOID.subset do |object|
          dataset = Dataset.new :graph => @graph, :uri => object
          yield dataset
        end
        
      end
      
      # loads the void dataset from a given file
      def self.load(file, uri)
        graph = RDF::Graph.load(file)
        Dataset.new :graph => graph, :uri => uri
      end

    private
      
      # yields property values for a given subject and predicate
      def query_property_values(args)
        subject = args[:subject]
        predicate = args[:predicate]
        
        # retrieve all matching triples
        solutions = RDF::Query.execute(@graph) do
          pattern [:subject, predicate, :object]
        end
        
        # filter the one having the dataset uri as subject
        solutions.filter(:subject  => RDF::URI(subject)).each do |solution|
          object = solution[:object]
          yield object
        end
      end
      
    end
    
    # Europeana-LOD specific terms used in void description
    class EULOD < RDF::Vocabulary("http://data.europeana.eu/conf#")
      property :xmlfile
    end
    
    class VOID < RDF::Vocabulary("http://rdfs.org/ns/void#")
      property :subset
    end
    
end 


dataset = ESE2EDM::Dataset.load("../../../datasets/edm-datasets-1.0.ttl", "http://data.europeana.eu/void.ttl#TEL")

dataset.each_subset do |dataset|
  puts dataset.uri
  dataset.each_xml_file {|xml_file| puts xml_file}
end
