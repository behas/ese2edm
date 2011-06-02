require_relative '../conf/html_exporter.rb'

dataset = ESE2EDM::Conf::Dataset.load("../../../datasets/edm-datasets.ttl", "http://data.europeana.eu/void.ttl#EuropeanaLOD")

p dataset.subsets

dataset.each_subset(true) do |dataset|
  puts dataset.uri
  puts dataset.title
  puts dataset.dataset_baseURI
  dataset.xml_files.each {|xml_file| puts xml_file}
end

html_exporter = ESE2EDM::Conf::HTMLExporter.new :dataset => dataset

html = html_exporter.export

puts html

