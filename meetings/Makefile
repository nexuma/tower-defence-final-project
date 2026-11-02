BUILD_DIR := build
SOURCES := $(wildcard meeting_*_minutes.tex)
PDFS := $(patsubst %.tex,$(BUILD_DIR)/%.pdf,$(SOURCES))

.PHONY: all template clean

all: $(PDFS)

template: $(BUILD_DIR)/meeting_minutes_template.pdf

$(BUILD_DIR)/%.pdf: %.tex
	mkdir -p $(BUILD_DIR)
	latexmk -pdf -interaction=nonstopmode -halt-on-error \
		-outdir=$(BUILD_DIR) $<

clean:
	rm -rf $(BUILD_DIR)
