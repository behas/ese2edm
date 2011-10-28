# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "rake"
require "ese2edm"

Gem::Specification.new do |s|
  s.name = "ese2edm"
  s.version = ESE2EDM::VERSION
  s.date = File.mtime("lib/ese2edm.rb").strftime('%Y-%m-%d')
  s.license = "Public Domain"
  s.summary = "A library for generating Europeana EDM data from ESE records"
  s.description = File.read(File.join(File.dirname(__FILE__), 'README.md'))
  s.author = "Bernhard Haslhofer"
  s.email = "bernhard.haslhofer@cornell.edu"
  s.homepage = "http://www.cs.cornell.edu/~bh392"
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=1.9'
  s.files = FileList['lib/**/*.rb', 'bin/*', '[A-Z]*'].to_a
  s.executables = ['ese2edm', 'ese2edm-doc', 'ese2edm-download', 'ese2edm-filter-enrichments']
  s.has_rdoc = false
  s.requirements << 'libxslt installed; xsltproc exectuable from the commandline'
  s.requirements << 'raptor installed; rapper executable from the commandline'
  s.add_dependency("nokogiri", ">=1.4.4")
  s.add_dependency("rdf", "=0.3.3") 
  s.add_dependency("rdf-raptor", "=0.4.1") 
end