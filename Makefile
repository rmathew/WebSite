# Makefile for the maintenance of my web-site.

# The folder that contains the ".htm4" sources.
SRC_DIR=src

# The folder that contains the generated files.
PUB_DIR=pub

# The folder that contains the helper scripts.
BIN_DIR=$(CURDIR)/bin

PATH:=$(BIN_DIR):$(PATH)

.SUFFIXES:
.SUFFIXES: .htm4 .xm4 .m4 .html .xml

# Ask Make to look for ".htm4", ".xm4" and ".m4" files in the source folder.
vpath %.htm4 $(SRC_DIR)
vpath %.xm4 $(SRC_DIR)
vpath %.m4 $(SRC_DIR)

# M4_DEBUG=-dptae

# Tell Make how to create a ".html" file from the corresponding ".htm4" file.
$(PUB_DIR)/%.html: %.htm4
	m4 --include=$(SRC_DIR) $(M4_DEBUG) --prefix-builtins $< >$@

# Ditto for ".xm4" to ".xml".
$(PUB_DIR)/%.xml: %.xm4
	m4 --include=$(SRC_DIR) $(M4_DEBUG) --prefix-builtins $< >$@
	xmllint --noout $@

.PHONY: all html xml deps clean

# Useful targets
all: html xml

ifneq ($(MAKECMDGOALS),deps)
include deps.mk
endif

html: $(GEN_HTML)

xml: $(GEN_XML)

deps:
	$(BIN_DIR)/crtdeps.sh $(SRC_DIR) $(PUB_DIR)

clean: 
	rm -f $(GEN_HTML) $(GEN_XML) deps.mk
