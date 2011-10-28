module ESE2EDM
  
  module Cli

    # This class defines and parses all the options that are available for the ESE2EDM conversion
    class DownloadOptions

        DEFAULT_OUTPUT_DIR = "xml/"
        DEFAULT_USERNAME = nil
        DEFAULT_PASSWORD = nil
        DEFAULT_SKIP_DL_FILES = true 

        attr_reader :options

        def initialize(argv)
          @options = {}
          parse(argv)
        end

    private

        def parse(argv)

          optParser = OptionParser.new do |opts|
            opts.banner = "Usage: ruby download_files.rb [options] url"

            @options[:output_dir] = DEFAULT_OUTPUT_DIR
            opts.on("-o", "--output-dir [OUTPUT_DIRECTORY]", "The file where the downloaded files are stored")  do |output_dir|
              @options[:output_dir] = output_dir
            end        

            @options[:username] = DEFAULT_USERNAME
            opts.on("-u", "--username [USERNAME]", String, "The username for HTTP authentication") do |username|
              @options[:username] = username
            end

            @options[:password] = DEFAULT_PASSWORD
            opts.on("-p", "--password [PASSWORD]", String, "The password for HTTP authentication") do |password|
              @options[:password] = password
            end

            @options[:skip_dl_files] = DEFAULT_SKIP_DL_FILES
            opts.on("-s", "--skip", "Skip already downloaded files") do |skip_dl_files|
              @options[:skip_dl_files] = skip_dl_files
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
    

    class DownloadRunner
      
      # Constructor
      def initialize(args)
        options = ESE2EDM::Cli::DownloadOptions.new(args).options
        @downloader = ESE2EDM::Util::Downloader.new(options, args)
      end
      
      # Performs the download
      def run
        @downloader.download
      end
      
    end

    
  end # end of Cli
  
end # end of ESE2EDM
