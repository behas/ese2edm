# ruby dependencies

require 'logger'
require 'optparse'
require 'find'
require 'fileutils'

# gem dependencies
require 'rdf'
require 'rdf/raptor'
require 'nokogiri'

# library-internal dependencies
require_relative 'ese2edm/converter'

require_relative 'ese2edm/cli/ese2edm'
require_relative 'ese2edm/cli/ese2edmdoc'
require_relative 'ese2edm/cli/esedownload'

require_relative 'ese2edm/conf/datasets'
require_relative 'ese2edm/conf/html_exporter'

require_relative 'ese2edm/util/downloader'

module ESE2EDM
  
  VERSION = "1.1"
  
end