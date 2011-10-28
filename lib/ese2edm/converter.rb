# This class performs the actual ESE2EDM conversion.
# It takes the given ESE XML input files, converts each file into ESE RDF/XML by applying an XSLT transformation.
# The resulting files can optionally be combined into a single N-TRIPLES dump file
#
# Requires libxml2 (xsltproc) and raptor to be installed on the system

module ESE2EDM

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
    
      # People might forget the trailing slash
      @options[:output_dir] = @options[:output_dir] + "/" unless @options[:output_dir].end_with?("/")
      
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
      
        create_NT_dump(converted_files, @options[:output_dir], @options[:nt_dump_file])
      
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
          `xsltproc #{stylesheet} #{file} | xmllint --format - > #{output_file}`
        else
          `xsltproc #{stylesheet} #{file} > #{output_file}`
        end
      rescue Exception => e
        $LOG.error(e.message)
      end
    
      return output_file
    
    end #end of transform
  
    # Converts a set of RDF/XML files to N-TRIPLE and dumps them into a single file
    def create_NT_dump(rdf_xml_files, output_dir, dump_file)
    
      rdf_xml_files.each do |rdfxml_file|
      
        basename = File.basename(rdfxml_file, ".rdf")
        nt_file = output_dir + basename + ".nt"
        df = output_dir + dump_file
        
        $LOG.info("Creating N-TRIPLE file #{nt_file} ...")
        `rapper #{rdfxml_file} > #{nt_file}`
      
        $LOG.info("Adding #{nt_file} to #{df} ...")
        `cat #{nt_file} >> #{df}`
              
      end

    end
  
  end # converter

end #ese2edm