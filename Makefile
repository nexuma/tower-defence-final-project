BUILD_DIR := build
WIKI_DIR := docs/wiki

LATEX_SOURCES := $(wildcard docs/requirements/*.tex) \
	$(wildcard meetings/meeting_[0-9][0-9]_minutes.tex) \
	meetings/meeting_minutes_template.tex

PDFS := $(patsubst %.tex,$(BUILD_DIR)/%.pdf,$(LATEX_SOURCES))

WIKI_MARKDOWN := $(WIKI_DIR)/Functional-Requirements.md \
	$(patsubst meetings/meeting_%_minutes.tex,$(WIKI_DIR)/Meeting-%.md,$(wildcard meetings/meeting_[0-9][0-9]_minutes.tex))

.PHONY: all pdfs markdown wiki publish-wiki publish-wiki-files clean

all: pdfs markdown

pdfs: $(PDFS)

markdown: $(WIKI_MARKDOWN)

wiki: markdown

publish-wiki:
	./scripts/publish-wiki.sh "$(COMMIT_MESSAGE)"

publish-wiki-files: wiki
	@test -n "$(WIKI_REPO)" || (echo "Usage: make publish-wiki-files WIKI_REPO=/path/to/wiki-clone"; exit 1)
	cp $(WIKI_DIR)/Functional-Requirements.md $(WIKI_DIR)/Meeting-*.md \
		$(WIKI_DIR)/Home.md $(WIKI_REPO)/

$(BUILD_DIR)/%.pdf: %.tex
	mkdir -p $(@D)
	latexmk -pdf -interaction=nonstopmode -halt-on-error \
		-outdir=$(dir $@) $<

$(WIKI_DIR)/Functional-Requirements.md: docs/requirements/functional_requirements.tex
	mkdir -p $(@D)
	pandoc -f latex -t gfm --wrap=none $< -o $@

$(WIKI_DIR)/Meeting-%.md: meetings/meeting_%_minutes.tex
	mkdir -p $(@D)
	pandoc -f latex -t gfm --wrap=none $< -o $@

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(WIKI_MARKDOWN)
