require 'logger'
require 'optparse'

require_relative '../converter.rb'

module ESE2EDM
  
  module Cli
  
    # This class defines and parses all the options that are available for the ESE2EDM conversion
    class ESE2EDMOptions

        DEFAULT_OUTPUT_DIR = "rdf/"
        DEFAULT_STYLESHEET = "conf/ese2edm.xsl"
        DEFAULT_NT_DUMP_FILE = DEFAULT_OUTPUT_DIR + "europeana_edm_#{Time.now.localtime.strftime("%Y-%m-%d")}.nt"
        DEFAULT_LOG_FILE = "ese2edm_#{Time.now.localtime.strftime("%Y-%m-%d")}.log"
        DEFAULT_BATCH_FILE = nil
        DEFAULT_PRETTY_PRINT = false
  
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
            opts.on("-o", "--output-dir [OUTPUT_DIRECTORY]", "The file where the converted files are stored")  do |output_dir|
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
          
            @options[:dump] = false
            opts.on("-d", "--dump", "Combine all converted files into a single NT-dump file")  do |dump|
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
  
  
    class ESE2EDMRunner
    
      def initialize(args)
        @options = ESE2EDM::Cli::ESE2EDMOptions.new(args).options
        raise ArgumentError("At least one XML source file must be given") if args.length < 1
        @xml_files = args
      end
    
      def run
        # creating a new Converter instance
        converter = ESE2EDM::Converter.new(@options, @xml_files)
        # execute the conversion
        converter.convert      
      end
    
    end # end of class Runner
  
  end # cli

end #ese2edm