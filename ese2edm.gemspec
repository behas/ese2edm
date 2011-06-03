Gem::Specification.new do |s| 
  s.name	= "ese2edm" 
  s.summary	= "A Ruby API for producing Linked Data from Europeana Metadata" 
  s.description = File.read(File.join(File.dirname(__FILE__), 'README.md')) 
  s.requirements = [ 'libxml2 and raptor must be insatlled' ]
  s.version = "1.0"
  s.author = "Bernhard Haslhofer"
  s.email = "bernhard.haslhofer@cornell.edu"
  s.homepage = "http://data.europeana.eu"
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=1.9' 
  s.files	= Dir['**/**'] 
  s.executables = [ 'ese2edm', 'ese2edmdoc', 'esedownload' ] 
  s.has_rdoc	= false
end
