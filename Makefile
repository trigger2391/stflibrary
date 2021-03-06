# Variable declarations
SAXON=/usr/share/java/saxon.jar
RESOLVER=/usr/share/java/resolver.jar
XERCES=/usr/share/java/xercesImpl.jar
DOCBOOKXSL=/usr/share/xml/docbook/stylesheet/nwalsh
DBDTD=/usr/share/sgml/docbook/dtd/xml/4.3/docbookx.dtd
SOURCE=./src

RESOLVED=resolved.xml

all: chunk monolithic

resolve: $(SOURCE)/set.xml
  @echo "Building unified file."
  @xmllint -xinclude $(SOURCE)/set.xml > $(RESOLVED)

valid: resolve
  @echo "Validating Handbook"
  @xmllint \
  --noout \
  --xinclude \
  --postvalid \
  --noent \
  --dtdvalid $(DBDTD) \
  $(RESOLVED)

monolithic: resolve
  @echo "Generating single-file HTML outout."
  @java \
  -cp .:$(SAXON):$(XERCES):$(RESOLVER):$(CLASSPATH) \
  com.icl.saxon.StyleSheet \
  -x org.apache.xml.resolver.tools.ResolvingXMLReader \
  -y org.apache.xml.resolver.tools.ResolvingXMLReader \
  -r org.apache.xml.resolver.tools.CatalogResolver \
  -u \
  $(RESOLVED) \
  html-monolithic.xsl

chunk: resolve
  @echo "Generating chunked HTML outout."
  @java \
  -cp .:$(SAXON):$(XERCES):$(RESOLVER):$(CLASSPATH) \
  com.icl.saxon.StyleSheet \
  -x org.apache.xml.resolver.tools.ResolvingXMLReader \
  -y org.apache.xml.resolver.tools.ResolvingXMLReader \
  -r org.apache.xml.resolver.tools.CatalogResolver \
  -u \
  $(RESOLVED) \
  html-chunked.xsl

clean:
  @echo "Deleting intermediary files"
  @rm -f $(RESOLVED)
  @echo "Deleting output files"
  @find ./output -name '*.html' -exec rm {} \;
  @echo "Deleting redundant backup saves"
  @find . -name '*~' -exec rm {} \;
