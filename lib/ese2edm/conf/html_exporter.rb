require 'nokogiri'

require_relative 'datasets.rb'

module ESE2EDM
  
  module Conf
  
    # Exports info about a given dataset to HTML
    class HTMLExporter

      def initialize(args)
        raise ArgumentError:new("No dataaset given") if args[:dataset].nil?
        @dataset = args[:dataset]
      end
    
      # outputs datset info as HTML (recursively, if desired)
      def export(recursive = false)
      
        tree = html_tree
        doc = Nokogiri::HTML tree, "UTF-8"

      end
    
    protected
    
      # Generates HTML information for a given dataset and all its subsets
      def html_tree
      
        list = "<ul><li><p>#{@dataset.title}</p>"
      
        if @dataset.files?
          list << "<p>N-TRIPLE files: "
          @dataset.file_uris("nt").each do |nt_file_uri|
            filename = File.basename(nt_file_uri)
            list << "<a href=\"#{nt_file_uri}\">#{filename}</a> "
          end
          list << "</p>"
          list << "<p>RDF/XML files: "
          @dataset.file_uris("rdf").each do |rdfxml_file_uri|
            filename = File.basename(rdfxml_file_uri)
            list << "<a href=\"#{rdfxml_file_uri}\">#{filename}</a> "
          end
          list << "</p>"
        end
      
        if @dataset.subsets?
          @dataset.subsets.each do |subset|
            subset_exporter = HTMLExporter.new :dataset => subset
            list << subset_exporter.html_tree
          end
        end

        list << "</li>"
        list << "</ul>"

      end
    
    end #HTMLExporter
  
  end # Conf
  
end 