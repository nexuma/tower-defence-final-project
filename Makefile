# Builds the project documentation.
#
#   make                 build PDFs and wiki pages into build/
#   make pdfs            build only the PDFs   (build/pdf/)
#   make wiki            build only the wiki pages (build/wiki/)
#   make publish-wiki    build the wiki pages and push them to the GitHub wiki
#   make clean           delete everything in build/ except committed PDFs
#
# Sources live in docs/. Never edit anything in build/ or in the wiki clone:
# those files are overwritten on every build.

BUILD_DIR := build
PDF_DIR   := $(BUILD_DIR)/pdf
WIKI_DIR  := $(BUILD_DIR)/wiki

MEETINGS      := $(wildcard docs/meetings/meeting_[0-9][0-9]_minutes.tex)
LATEX_SOURCES := $(wildcard docs/requirements/*.tex) $(MEETINGS) \
	docs/meetings/meeting_minutes_template.tex
PDFS := $(patsubst docs/%.tex,$(PDF_DIR)/%.pdf,$(LATEX_SOURCES))

WIKI_PAGES := $(WIKI_DIR)/Home.md \
	$(WIKI_DIR)/Project-Plan.md \
	$(WIKI_DIR)/Architecture.md \
	$(WIKI_DIR)/Decision-Log.md \
	$(WIKI_DIR)/Project-Direction.md \
	$(WIKI_DIR)/Time-Log.md \
	$(WIKI_DIR)/Functional-Requirements.md \
	$(patsubst docs/meetings/meeting_%_minutes.tex,$(WIKI_DIR)/Meeting-%.md,$(MEETINGS))

# Rewrites links between source files into links between wiki pages.
WIKI_LINKS := \
	-e 's|](plan\.md|](Project-Plan|g' \
	-e 's|](architecture\.md|](Architecture|g' \
	-e 's|](decision-log\.md|](Decision-Log|g' \
	-e 's|](project-direction\.md|](Project-Direction|g' \
	-e 's|](timelog\.md|](Time-Log|g'

# First line of every generated page (an HTML comment, hidden on GitHub).
GENERATED_NOTE = printf '<!-- GENERATED from %s by make. Do not edit this copy: edit the source and run make publish-wiki. -->\n\n' '$<' > $@

.PHONY: all pdfs wiki publish-wiki clean

all: pdfs wiki

pdfs: $(PDFS)

wiki: $(WIKI_PAGES)

publish-wiki:
	./scripts/publish-wiki.sh "$(COMMIT_MESSAGE)"

# --- PDFs -------------------------------------------------------------------

$(PDF_DIR)/%.pdf: docs/%.tex
	@mkdir -p $(@D)
	latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir=$(@D) $<

# --- Wiki pages: Markdown sources ---------------------------------------------

$(WIKI_DIR)/Home.md: docs/wiki-home.md
	@mkdir -p $(@D)
	@$(GENERATED_NOTE)
	sed $(WIKI_LINKS) $< >> $@

$(WIKI_DIR)/Project-Plan.md: docs/plan.md
	@mkdir -p $(@D)
	@$(GENERATED_NOTE)
	sed $(WIKI_LINKS) $< >> $@

$(WIKI_DIR)/Architecture.md: docs/architecture.md
	@mkdir -p $(@D)
	@$(GENERATED_NOTE)
	sed $(WIKI_LINKS) $< >> $@

$(WIKI_DIR)/Decision-Log.md: docs/decision-log.md
	@mkdir -p $(@D)
	@$(GENERATED_NOTE)
	sed $(WIKI_LINKS) $< >> $@

$(WIKI_DIR)/Project-Direction.md: docs/project-direction.md
	@mkdir -p $(@D)
	@$(GENERATED_NOTE)
	sed $(WIKI_LINKS) $< >> $@

$(WIKI_DIR)/Time-Log.md: docs/timelog.md
	@mkdir -p $(@D)
	@$(GENERATED_NOTE)
	sed $(WIKI_LINKS) $< >> $@

# --- Wiki pages: LaTeX sources (converted with pandoc) ------------------------

$(WIKI_DIR)/Functional-Requirements.md: docs/requirements/functional_requirements.tex
	@mkdir -p $(@D)
	@$(GENERATED_NOTE)
	pandoc -f latex -t gfm --wrap=none $< >> $@

$(WIKI_DIR)/Meeting-%.md: docs/meetings/meeting_%_minutes.tex
	@mkdir -p $(@D)
	@$(GENERATED_NOTE)
	pandoc -f latex -t gfm --wrap=none $< >> $@

# --- Cleanup -----------------------------------------------------------------

# Keeps the committed PDFs; removes generated wiki pages and LaTeX leftovers.
clean:
	rm -rf $(WIKI_DIR)
	find $(PDF_DIR) -type f ! -name '*.pdf' -delete 2>/dev/null || true
