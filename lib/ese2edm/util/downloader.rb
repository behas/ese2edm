require 'logger'
require 'net/http'

require_relative '../conf/datasets.rb'

module ESE2EDM
  
  module Util
    
    # This class performs the download
    class Downloader
      
      ROOT_DATASET = "http://data.europeana.eu/void.ttl#EuropeanaLOD"
      
      # Constructor
      def initialize(options, dataset_file)
        raise ArgumentError.new("Mandatory dataset file argument missing") if dataset_file == nil
        raise ArgumentError.new("Exactly one URL file must be passed as argument") if dataset_file.size != 1
        @options = options
        @dataset_file = dataset_file[0]
        
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
        
        # Go through the datasets and download each file individually
        dataset = ESE2EDM::Conf::Dataset.load(@dataset_file, ROOT_DATASET)
        
        dataset.xml_files(true).each do |xml_file|
          # create an URL object
          url = URI.parse(xml_file)
                    
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
        end # of xml_files
      
      end # end of download
      
    end # end of class downloader
    
  end # end of Util
  
end # end of ESE2EDM