require 'rdf'
require 'rdf/raptor'

require 'nokogiri'
require 'rexml/document'

module ESE2EDM  
    
    # A wrapper around the void dataset description for convenient access
    class Dataset
      
      DEFAULT_DOWLNLOAD_BASE_DIR = "http://data.europeana.eu/download"
      
      DEFAULT_VERSION = 1.0
      
      DEFAULT_DATASETS_PATH = "datasets"
      
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
      
      # returns whether or not downloadable files are associated with that dataset
      def files?
        not xml_files.empty?
      end
      
      # the returns the NT-file URIs associated with this dataset
      def nt_files
        nt_files = []
        xml_files.each do |xml_file|
          basename = File.basename(xml_file, ".xml")
          nt_files << dataset_baseURI + "/nt/" + basename + ".nt"
        end
        return nt_files
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
      
      # returns the base URI of the dataset download directory
      def dataset_baseURI
        DEFAULT_DOWLNLOAD_BASE_DIR + "/" + DEFAULT_VERSION.to_s + "/" + DEFAULT_DATASETS_PATH
      end

      # returns the base URI of the dataset download directory
      def links_baseURI
        DEFAULT_DOWLNLOAD_BASE_DIR + "/" + DEFAULT_VERSION + "/" + DEFAULT_LINKS_PATH
      end
      
      # outputs datset info as HTML (recursively, if desired)
      def to_html(recursive = false)
        
        tree = html_tree
        doc = Nokogiri::HTML tree

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

    protected
      
      # outputs information on this dataset as HTML list
      def html_tree
        
        list = <<-EOHTML
        <ul>
          <li>
            <p>#{title}</p>
        EOHTML
        
        if files?
          list << "<p>"
          nt_files.each do |nt_file|
            list << <<-EOHTML 
              <a href="#{nt_file}">nt</a>
          EOHTML
          end
          list << "</p>"
        end
        
        if subsets?
          subsets.each do |subset|
            list << subset.html_tree
          end
        end

        list << "</li>"
        list << "</ul>"

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

p dataset.subsets

# dataset.each_subset(true) do |dataset|
#   puts dataset.uri
#   puts dataset.title
#   dataset.xml_files.each {|xml_file| puts xml_file}
# end

File.open("test.html", "w") {|file| file.puts dataset.to_html}
