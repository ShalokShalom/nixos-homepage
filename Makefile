tpage = /nix/var/nix/profiles/per-user/eelco/hydra-deps/bin/tpage
catalog = $(HOME)/.nix-profile/xml/dtd/xhtml1/catalog.xml

HTML = index.html news.html \
  nix/index.html nix/download.html nix/docs.html \
  nixpkgs/index.html nixpkgs/download.html nixpkgs/docs.html \
  nixos/index.html nixos/download.html nixos/docs.html \
  nixos/screenshots.html nixos/support.html \
  patchelf.html hydra/index.html \
  developers/index.html \
  docs/papers.html \
  about-us.html

all: $(HTML)

docs/papers-in.html: docs/papers.xml docs/bib2html.xsl
	xsltproc docs/bib2html.xsl docs/papers.xml > $@ || rm $@

docs/papers.html: docs/papers-in.html

nixos/papers-in.html: docs/papers.xml docs/bib2html.xsl
	xsltproc --stringparam tag nixos docs/bib2html.xsl docs/papers.xml > $@ || rm $@

nix/papers-in.html: docs/papers.xml docs/bib2html.xsl
	xsltproc --stringparam tag nix docs/bib2html.xsl docs/papers.xml > $@ || rm $@

nixos/docs.html: nixos/papers-in.html

nix/docs.html: nix/papers-in.html

%.html: %.tt layout.tt
	$(tpage) --define curUri=$@ --define root=`echo $@ | sed -e 's|[^/]||g' -e 's|/|../|g'` $< > $@ && \
	XML_CATALOG_FILES=$(catalog) xmllint --nonet --noout --valid $@ || \
	(rm -f $@ && exit 1)

news.html: all-news.xhtml

all-news.xhtml: news.xml news.xsl
	xsltproc --param maxItem 10000 news.xsl news.xml > $@ || rm -f $@

index.html: latest-news.xhtml

latest-news.xhtml: news.xml news.xsl
	xsltproc --param maxItem 5 news.xsl news.xml > $@ || rm -f $@

check:
	checklink $(HTML)
