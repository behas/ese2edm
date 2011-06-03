require 'optparse'

require_relative '../conf/html_exporter.rb'

module ESE2EDM
  
  module Conf
    
    # Defines options for dataset exports
    class Options

        DEFAULT_OUTPUT_FORMAT = "HTML"
        
        DEFAULT_OUTPUT_FILE = "dataset.html"
        
        attr_reader :options

        def initialize(argv)
          @options = {}
          parse(argv)
        end

    private

        def parse(argv)

          optParser = OptionParser.new do |opts|
            opts.banner = "Usage: confexport [options] dataset.ttl"

            @options[:output_file] = DEFAULT_OUTPUT_FILE
            opts.on("-o", "--output-file <output_file>", "The output file")  do |output_file|
              @options[:output_file] = output_file
            end        

            @options[:output_format] = DEFAULT_OUTPUT_FORMAT
            opts.on("-f", "--output-format [HTML|VOID]", String, "The output format (HTML or VOID)") do |output_format|
              @options[:output_format] = output_format
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

    end # end of class options
    
    
    class Runner
      
      def initialize(args)
        @options = ESE2EDM::Conf::Options.new(args).options
        raise ArgumentError("No dataset file given") if args.length != 1
        @file = args[0]
      end
      
      def run
        dataset = ESE2EDM::Conf::Dataset.load(@file, "http://data.europeana.eu/void.ttl#EuropeanaLOD")
        
        File.open(@options[:output_file], "w") do |file|
          case @options[:output_format]
          when "HTML"
            html_exporter = ESE2EDM::Conf::HTMLExporter.new :dataset => dataset
            html = html_exporter.export
            file.puts html
          when "VOID"
            raise NotImplementedError("Void export has not been implemented yet.")
          end
        end
        
      end
      
    end # end of class Runner

  end #of module conf
end #of ese2edm