#!/usr/bin/env ruby
# Name          ese2edm.rb
# Description   Converts a set of given the Europeana ESE XML files into RDF EDM (N-Triple-Serialization)
# Autor         Bernhard Haslhofer
# Date          2011-03-01
# Version       0.2

# NOTE: this script requires libxml2 (xsltproc) and raptor to be installed on the system

# gem dependencies - make sure that these gems are installed on your system

require 'logger'
require 'optparse'
require 'find'
require 'fileutils'

module ESE2EDM
  
  # This class defines and parses all the options that are available for the ESE2EDM conversion
  class Options

      DEFAULT_OUTPUT_DIR = "rdf/"
      DEFAULT_STYLESHEET = "ese2edm.xsl"
      DEFAULT_NT_DUMP_FILE = "europeana_edm_#{Time.now.localtime.strftime("%Y-%m-%d")}.nt"
      DEFAULT_LOG_FILE = "ese2edm_#{Time.now.localtime.strftime("%Y-%m-%d")}.log"
      DEFAULT_BATCH_FILE = nil
      DEFAULT_PRETTY_PRINT = false
      DEFAULT_BASE_URI = "http://id.europeana.eu"
  
      attr_reader :options
  
      def initialize(argv)
        @options = {}
        parse(argv)
      end
  
  private
  
      def parse(argv)
    
        optParser = OptionParser.new do |opts|
          opts.banner = "Usage: ruby ese2edm.rb [options] ese_xml_files (e.g., ../xml/sample_dir/esefile.xml)"

          @options[:output_dir] = DEFAULT_OUTPUT_DIR
          opts.on("-o", "--output-dir [OUTPUT_DIRECTORY]", "The file where the generated EDM RDF/XML files are stored")  do |output_dir|
            @options[:output_dir] = output_dir
          end        

          @options[:stylesheet] = DEFAULT_STYLESHEET
          opts.on("-s", "--style-sheet [STYLE_SHEET]", String, "The stylesheet to be applied for the transformation (e.g., #{DEFAULT_STYLESHEET})") do |stylesheet|
            @options[:stylesheet] = stylesheet
          end

          @options[:batch_file] = DEFAULT_BATCH_FILE
          opts.on("-b", "--batch-list-file [BATCH_LIST_FILE]", String, "A pointer to a file containing a list of links to the files that need to be converted") do |batch_file|
            @options[:batch_file] = batch_file
          end

          @options[:base_uri] = DEFAULT_BASE_URI
          opts.on("-u", "--base-URI [BASE_URI]", String, "The base URI to be applied for the EDM records (e.g., http://id.europeana.eu)") do |base_uri|
            @options[:base_uri] = base_uri
          end
          
          @options[:dump] = false
          opts.on("-d", "--dump", "Combine all generated ESE RDF/XML files into a single NT-dump file")  do |dump|
            @options[:dump] = dump
          end        

          @options[:pretty_print] = DEFAULT_PRETTY_PRINT
          opts.on("-p", "--pretty-print", "Outputs the generated ESE RDF/XML with XML intendation")  do |pretty_print|
            @options[:pretty_print] = pretty_print
          end        
          
          @options[:nt_dump_file] = DEFAULT_NT_DUMP_FILE
          opts.on("-n", "--dump-file [DUMP_FILE]", String, "The name of the NT-dump file (e.g., #{DEFAULT_NT_DUMP_FILE})") do |nt_dump_file|
            @options[:nt_dump_file] = nt_dump_file
          end
          
          @options[:log_file] = DEFAULT_LOG_FILE
          opts.on("-l", "--log-file [LOG_FILE]", "The name of the log file")  do |log_file|
            @options[:log_file] = log_file
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
  
  
  # This class performs the actual ESE2EDM conversion.
  # It takes the given ESE XML input files, converts each file into ESE RDF/XML by applying an XSLT transformation.
  # The resulting files can optionally be combined into a single N-TRIPLES dump file
  class Converter
    
    # Constructor
    def initialize(options, files2convert)
      
      @options = options
      @files2convert = files2convert

      $LOG = Logger.new(@options[:log_file], 'monthly')
      $LOG.level = Logger::INFO
      
    end
    
    # Controlls the overall conversion process
    def convert
      
      # Make sure that the output directory exits
      if !File.directory? @options[:output_dir] 
        $LOG.info("Creating output directory #{@options[:output_dir]}...")
        Dir.mkdir(@options[:output_dir])
      end
      
      # Array for storing ESE file pointers
      source_ese_files = []
      
      # If source ESE files are provided in batch mode (in a text file) ...
      unless @options[:batch_file] == nil
        # .. read the file line by line and extract the file location
        File.open(@options[:batch_file], "r") do |batch_file| 
          # each line should point to a file path
          while path = batch_file.gets
            source_ese_files << path.chomp
          end
        end
      else
        # .. just take the source files provided on the command line
        source_ese_files = @files2convert
      end

      $LOG.info("Converting #{source_ese_files.size} ESE XML files to EDM RDF/XML...")
      
      converted_files = []
      # Convert each ESE file individually
      source_ese_files.each do |source_file|
        
        unless File.exists?(source_file)
          $LOG.error("Cannot access source file #{source_file}. Exiting conversion process.")
          return
        end
        
        # convert the file
        converted_file = transform(source_file, @options[:stylesheet], @options[:output_dir], @options[:base_uri], @options[:pretty_print])
        converted_files << converted_file
        
      end
      
      $LOG.info("*** Finished RDF/XML conversion *** Transformed #{source_ese_files.size} ESE XML files to EDM RDF/XML.")
      
      # create an N-Triples dump if requested so
      if @options[:dump]
        
        $LOG.info("Merging created RDF/XML files into N-TRIPLES dump file: #{@options[:nt_dump_file]} ...")
        
        create_NT_dump(converted_files, @options[:nt_dump_file])
        
        $LOG.info("*** Finished N-TRIPLES dumping *** Dumped #{source_ese_files.size} RDF/XML files into #{@options[:nt_dump_file]}")
      
      end
      
    end
    
  private
  
    # Transforms a given XML file using the given stylesheet
    # Returns the name of the produced output file
    def transform(file, stylesheet, output_dir, base_uri, pretty_print = false)
      
      # extract the base name (without xml suffix)
      basename = File.basename(file, ".xml")
      output_file = output_dir + basename + ".rdf"
            
      begin
        $LOG.info("Converting #{file} to EDM. Saving result in #{output_file}...")
        if pretty_print
          `xsltproc --stringparam EDM_BASE_URI #{base_uri} #{stylesheet} #{file} | xmllint --format - > #{output_file}`
        else
          `xsltproc --stringparam EDM_BASE_URI #{base_uri} #{stylesheet} #{file} > #{output_file}`
        end
      rescue Exception => e
        $LOG.error(e.message)
      end
      
      return output_file
      
    end #end of transform
    
    # Combines a given set of RDF/XML files into a single N-Triples dump file
    def create_NT_dump(rdf_xml_files, output_file)
      
      rdf_xml_files.each do |rdfxml_file|
        
        tempNTfile = rdfxml_file + ".nt"

        $LOG.info("Creating temporary NT file #{tempNTfile} ...")
        `rapper #{rdfxml_file} > #{tempNTfile}`
        
        $LOG.info("Adding #{tempNTfile} temporary NT-file to #{output_file} ...")
        `cat #{tempNTfile} >> #{output_file}`
        
        $LOG.info("Deleting temporary NT file #{tempNTfile} ...")
        FileUtils.rm tempNTfile
        
      end

    end
    
  end
  
end


# creating an Option instance to read out CMD line args
options = ESE2EDM::Options.new(ARGV).options

# creating a new Converter instance
converter = ESE2EDM::Converter.new(options, ARGV)

# execute the conversion
converter.convert





# $LOG = Logger.new('ese2edm.log', 'monthly')
# $LOG.level = Logger::INFO
# 
# FILE_LIST = "files2convert.txt"
# 
# OUTPUT_DIR = "rdf/"
# 
# # create the output directory
# if !File.directory? OUTPUT_DIR
#   Dir.mkdir(OUTPUT_DIR)
# end
# 
# # go through each file in the list and call the external conversion command
# 
# 
# File.open(FILE_LIST) do |file| 
#     
#   while line = file.gets
#     
#     # parse the path
#     path = line[line.rindex("\t")+1..line.length]
#     path.strip!
#     
#     # extract the base name (without xml suffix)
#     basename = File.basename(path, ".xml")
#     
#     begin
#       
#       $LOG.info("Converting #{path} to EDM")
#       `xsltproc ese2edm.xsl #{path} > #{OUTPUT_DIR}#{basename}.rdf`
#       
#     rescue Exception => e
#       $LOG.error(e.message)
#     end
# 
#   end
# 
#   $LOG.info("Finished conversion")
# 
# end