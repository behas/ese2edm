require 'rdf'
require 'rdf/raptor'

module ESE2EDM
  
  module Conf
    
    # A wrapper around the void dataset description for convenient access
    class Dataset
      
      DEFAULT_DATASETS_PATH = "datasets"
    
      DEFAULT_LINKS_PATH = "links"
      
      DEFAULT_DOWNLOAD_URI = "http://data.europeana.eu/download"
      
      DEFAULT_VERSION = 1.0
      
      attr_reader :uri

      # takes a pointer to the graph and the subject uri identifying a dataset
      def initialize(args)
        @graph = args[:graph]
        @uri = args[:uri]
        args[:version].nil? ? @version = DEFAULT_VERSION : @version = args[:version]
        args[:downloadURI].nil? ? @downloadURI = DEFAULT_DOWNLOAD_URI : @downloadURI = args[:downloadURI]
      end
      
      # returns the dataset title
      def title
        query_property_values :predicate => DCTERMS.title do |title|
          return title
        end
      end
      
      # returns all XML file URIs associated with a data file
      def xml_files(recursive = false)
        xml_files = []
        query_property_values :predicate => EULOD.xmlfile do |xml_file|
          xml_files << xml_file
        end
        subsets.each {|subset| xml_files << subset.xml_files(recursive)} if recursive
        return xml_files.flatten
      end
      
      # returns the base URI of the dataset download directory
      def dataset_baseURI
        @downloadURI + "/" + @version.to_s + "/" + DEFAULT_DATASETS_PATH
      end

      # returns the base URI of the dataset download directory
      def links_baseURI
        @downloadURI + "/" + @version.to_s + "/" + DEFAULT_LINKS_PATH
      end

      # returns all subsets of this dataset
      def subsets
        subsets = []
        each_subset(false) {|subset| subsets << subset}
        return subsets
      end
      
      # returns whether or not this dataset has subsets
      def subsets?
        not subsets.empty?
      end
      
      # iterates through all subsets of this dataset (recursively if desired)
      def each_subset(recursive = false)
        query_property_values :predicate => VOID.subset do |object|
          subset = Dataset.new :graph => @graph, :uri => object
          yield subset
          subset.each_subset(recursive) {|subset| yield subset} if recursive
        end
      end
      
      # returns whether or not downloadable files are associated with that dataset
      def files?
        not xml_files.empty?
      end
    
      # the returns the NT-file URIs associated with this dataset
      def file_uris(suffix)
        file_uris = []
        xml_files.each do |xml_file|
          basename = File.basename(xml_file, ".xml")
          file_uris << dataset_baseURI + "/#{suffix}/" + basename + ".#{suffix}"
        end
        return file_uris
      end
      
      # the dataset title is the default name 
      def to_s
        title
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
          result = solution[:object].to_s
          yield result
        end
      end
      
    end # dataset
    
    
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
    
  end # Conf
end 