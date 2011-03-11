# ESE2EDM Converter


These scripts provide the necessary infrastructure to convert a set of given source files expressed in the XML-based Europeana Semantic Elements (ESE) format into the RDF-based Europeana Data Model (EDM).

## Quickstart

Make sure you have rapper and libxml2 installed on your system. The latter should be available on any Unix-based system (Mac OSX, Linux, etc.). Rapper can easily be installed via _apt-get_ on Debian-based systems or _homebrew_ on a Mac.

Convert a single ESE XML file:
---

	ruby ese2edm.rb -d samples/00000_europeana_test_ese.xml
	
This takes the given ESE XML file `samples/00000_europeana_test_ese.xml` and produces an RDF/XML file `rdf/00000_europeana_test_ese.rdf`. The option `-d` means "create an N-TRIPLES dump file", which is stored in the base directory.

If you only need the RDF/XML files, simply skip the `-d` option.


Convert multiple ESE XML files:
---

	ruby ese2edm.rb -d samples/00000_europeana_test_ese.xml samples/00000_another_ese_file.xml
	
or simply

	ruby ese2edm.rb -d samples/*.xml
	
Does the same as the previous command but for more than one source file.


Convert multiple ESE XML files defined in a batch file:
---

Create a file (e.g., esefiles2convert.txt) that points to one ESE XML file per line

	samples/00000_europeana_test_ese.xml
	samples/00000_another_ese_file.xml
	
Call 

	ruby ese2edm.rb -d -b esefiles2convert.txt


## The long way and all the options you have

Use the -h option to learn more about all the options you have

	ruby ese2edm.rb -h

Use the -s option to use a custom stylesheet for the conversion

	ruby ese2edm.rb -s mystylesheet.xsl samples/00000_europeana_test_ese.xml

Use the -p option to output a pretty-printed RDF/XML document with XML indentations. Don't use this option for large files. It will slow down the conversion process.

	ruby ese2edm.rb -p samples/00000_europeana_test_ese.xml
	
Use the -o option to define a custom RDF/XML output directory

	ruby ese2edm.rb -o somedir/ samples/00000_europeana_test_ese.xml	


## Using the ese2edm.xsl stylesheet without the script

For converting a single ESE XML files using the ese2edm.xsl stylesheet use

  xsltproc ese2edm.xsl samples/00000_europeana_test_ese.xml | xmllint --format - > samples/00000_europeana_test_ese.rdf
  
for pretty-printed output, or

  xsltproc ese2edm.xsl samples/00000_europeana_test_ese.xml > samples/00000_europeana_test_ese.rdf
  
for compact output.


## Creating links for EDM collection files

After having converted the ESE XML files into a set of RDF/XML files you can use [Silk][silk] to link them with resources in other datasets.

Make sure you have downloaded Silk (_silk.jar_) and created a [linking specification][silk-spec] for the specific collection file, and then start the linking process.

  java -DconfigFile=links/00000_europeana_test_ese_linkspec.xml -jar silk.jar


## Where to get the ESE files from

The Europeana raw ESE data files are stored in an SVN repository (http://sandbox08.isti.cnr.it/svn/trunk/sourcedata/) that is currently not publicly accessible.

If you have the necessary access privileges you can use the `download_files.rb` script to download these files via HTTP.

	ruby util/download_files.rb -o xml/ -u username -p password datasets/edm-datasets-1.0.txt

# Links & References


[silk]: http://www4.wiwiss.fu-berlin.de/bizer/silk/ "The Silk Link Discovery Framework"
[silk-spec]: http://www4.wiwiss.fu-berlin.de/bizer/silk/spec/ "Silk Language Specification 2.0" 
