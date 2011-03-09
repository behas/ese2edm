#!/usr/bin/env ruby
# Name          download_ESE_files.rb
# Description   Read ESE file URIs from (a) given file and downloads the files into a given directory.
# Autor         Bernhard Haslhofer
# Date          2011-03-01
# Version       0.1

require 'logger'
require 'optparse'
require 'net/http'

module ESE2EDM
  
  module Util

    # This class defines and parses all the options that are available for the ESE2EDM conversion
    class Options

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
    
    # This class performs the download
    class Downloader
      
      # Constructor
      def initialize(options, url_file)
        raise ArgumentError.new("Mandatory URL file argument missing") if url_file == nil
        raise ArgumentError.new("Exactly one URL file must be passed as argument") if url_file.size != 1
        @options = options
        @url_file = url_file[0]
        
        $LOG = Logger.new(STDOUT, 'monthly')
        $LOG.level = Logger::INFO
      end
      
      # Performs the download
      def download
        
        # Make sure that the output directory exits
        if !File.directory? @options[:output_dir] 
          $LOG.info("Creating output directory #{@options[:output_dir]}...")
          Dir.mkdir(@options[:output_dir])
        end
        
        # Reads the URL file and iteratively downloads the files
        File.open(@url_file, "r") do |file| 
          # each line should point to a file path
          while line = file.gets
            
            # remove record separator from the end of the line
            line.chomp!
            
            # remove leading and trailing whitespaces
            line.strip!
                        
            next if line.empty?

            # skip comment lines
            # FIXME: no idea why this 
            next if line[0] == "#" or line[1] == "#"
                        
            # create an URL object
            url = URI.parse(line)
            
            # extracts the filename from the URL path
            filename = File.basename(url.path)
            
            # define the outputfile
            outputfile = @options[:output_dir] + "/" + filename
                        
            # skip file download if option -s is true and file already exists
            if @options[:skip_dl_files] and File.exists?(outputfile)
              $LOG.info("Skipping already downloaded #{outputfile}...")
              next
            end
            
            $LOG.info("Downloading #{url} to #{outputfile}...")
            
            # downloads the file to the output directory
            Net::HTTP.start(url.host) { |http|
              req = Net::HTTP::Get.new(url.path)
              if (@options[:username] != nil) and (@options[:password] != nil)
                req.basic_auth @options[:username], @options[:password]
              end
              response = http.request(req)
              case response
                  when Net::HTTPSuccess, Net::HTTPRedirection
                    File.open(outputfile, "wb") { |file|
                      file.write(response.body)
                     }
                  else
                    $LOG.info("Error when downloading #{url}...")
                    res.error!
                  end
            }
                                    
          end
        end
      
      end # end of download
      
      
    end # end of class downloader

    
  end # end of Util
  
end # end of ESE2EDM


# creating an Option instance to read out CMD line args
options = ESE2EDM::Util::Options.new(ARGV).options

# creating a new Downloader instance
downloader = ESE2EDM::Util::Downloader.new(options, ARGV)

# start the download
downloader.download