#!/usr/bin/env ruby
# Name          enrichment_cleanup.rb
# Description   Removes URIs, which are not yet part of the dump, from the enrichment dataset
# Autor         Bernhard Haslhofer
# Date          2011-05-23
# Version       0.1

require 'optparse'

module ESE2EDM
  
  module Util

    # Options
    class Options

        DEFAULT_URI_FILE = "all_eu_proxies.dat"
        DEFAULT_OUTPUT_FILE = "enrichment.nt"

        attr_reader :options

        def initialize(argv)
          @options = {}
          parse(argv)
        end

    private

        def parse(argv)

          optParser = OptionParser.new do |opts|
            opts.banner = "Usage: ruby enrichment_cleanup.rb [options]"
            
            @options[:output_file] = DEFAULT_OUTPUT_FILE
              opts.on("-o", "--output-file [OUTPUT_FILE]", "The output file for the filtered results")  do |output_file|
              @options[:output_file] = output_file
            end        
            
            @options[:uri_file] = DEFAULT_URI_FILE
              opts.on("-u", "--uri-file [URI-file]", "A file defining the supported URIs")  do |uri_file|
              @options[:uri_file] = uri_file
            end        

            opts.on("-h", "--help", "Show this message") do
              puts opts
              exit
            end
          end

          begin
            argv = ["-h"] if argv.empty?
            optParser.parse!(argv)
          rescue Exception => e
            STDERR.puts e.message, "\n"
            exit(-1)
          end

        end #end of parse

    end # end of Options
    
    # This class performs the cleanup
    class EnrichmentCleaner
      
      # Constructor
      def initialize(options, enrichment_file)
        raise ArgumentError.new("Mandatory enrichment file argument missing") if enrichment_file == nil
        @uri_file = options[:uri_file]
        @output_file = options[:output_file]
        @enrichment_file = enrichment_file[0]
      end
      
      # Performs the cleanup
      def cleanup
        
        uris = Array.new
        
        # Reads the URIs defined by the URI file into memory
        File.open(@uri_file, "r") do |file| 
          # each line should point to a file path
          while line = file.gets
            
            # remove leading and trailing whitespaces
            line.strip!
            
            uris << line
          end
        end
        
        p "Loaded #{uris.size} valid URIs into memory"
        
        # Open the output file
        File.open(@output_file, "wb") do |output_file|
          # Read the enrichment_file line by line
          File.open(@enrichment_file, "r") do |file| 
            # each line should point to a file path
            while line = file.gets

              # split the line into subject[0] predicate[1] object[2]
              spo = line.split

              if uris.include?(spo[0])
                output_file.puts line
              end

            end
          end
        end
      
      end # end of cleanup
      
    end # end of class Cleanup

    
  end # end of Util
  
end # end of ESE2EDM


# creating an Option instance to read out CMD line args
options = ESE2EDM::Util::Options.new(ARGV).options

# creating a new Downloader instance
cleaner = ESE2EDM::Util::EnrichmentCleaner.new(options, ARGV)

# start the download
cleaner.cleanup