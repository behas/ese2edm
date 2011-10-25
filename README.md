# ESE2EDM Converter

ESE2EDM stands for a collection of scripts we use to convert given source files expressed in the XML-based Europeana Semantic Elements (ESE) format into the RDF-based Europeana Data Model (EDM).

## Quickstart

Make sure you have rapper and libxml2 installed on your system. The latter should be available on any Unix-based system (Mac OSX, Linux, etc.). Rapper can easily be installed via _apt-get_ on Debian-based systems or _homebrew_ on a Mac.

Install ese2edm:

    git clone git://github.com/behas/ese2edm.git

Convert a single ESE XML file:
---

    ruby -I lib bin/ese2edm -d examples/00000_europeana_test_ese.xml
	
This takes the given ESE XML file `examples/00000_europeana_test_ese.xml` and produces an RDF/XML file `rdf/00000_europeana_test_ese.rdf`. The option `-d` means "create an N-TRIPLES dump file", which is stored in the base directory.

If you only need the RDF/XML files, simply skip the `-d` option.


Convert multiple ESE XML files:
---

    ruby -I lib bin/ese2edm -d examples/00000_europeana_test_ese.xml examples/00000_another_ese_file.xml
	
or simply

    ruby -I lib bin/ese2edm -d xml/*.xml
	
Does the same as the previous command but for more than one source file.


## The long way and all the options you have

Use the -h option to learn more about all the options you have

    ruby -I lib bin/ese2edm -h

Use the -s option to use a custom stylesheet for the conversion

    ruby -I lib bin/ese2edm -s mystylesheet.xsl examples/00000_europeana_test_ese.xml

Use the -p option to output a pretty-printed RDF/XML document with XML indentations. Don't use this option for large files. It will slow down the conversion process.

    ruby -I lib bin/ese2edm -p samples/00000_europeana_test_ese.xml
	
Use the -o option to define a custom RDF/XML output directory

    ruby -I lib bin/ese2edm -o somedir/rdf


## Using the ese2edm.xsl stylesheet without the script

For converting a single ESE XML files using the ese2edm.xsl stylesheet use

    xsltproc ese2edm.xsl samples/00000_europeana_test_ese.xml | xmllint --format - > samples/00000_europeana_test_ese.rdf
  
for pretty-printed output, or

    xsltproc ese2edm.xsl samples/00000_europeana_test_ese.xml > samples/00000_europeana_test_ese.rdf
  
for compact output.


## Creating links for EDM collection files

After having converted the ESE XML files into a set of RDF/XML files you can use [Silk][silk] to link them with resources in other datasets.

Make sure you have downloaded Silk (_silk.jar_) and created a [linking specification][silk-spec] for the specific collection file, and then start the linking process.

    java -DconfigFile=conf/00000_europeana_test_ese_linkspec.xml -jar silk.jar


## Where to get the ESE files from

The Europeana raw ESE data files are stored in an SVN repository (http://sandbox08.isti.cnr.it/svn/trunk/sourcedata/) that is currently not publicly accessible.

If you have the necessary access privileges you can use the `download_files.rb` script to download these files via HTTP.

    ruby -I lib bin/esedownload -o xml/ -u username -p password conf/edm-datasets.ttl



[silk]: http://www4.wiwiss.fu-berlin.de/bizer/silk/ "The Silk Link Discovery Framework"
[silk-spec]: http://www4.wiwiss.fu-berlin.de/bizer/silk/spec/ "Silk Language Specification 2.0" 
