all: spell img_src_check admonition_check blockquote_header_check
spell:
	@echo "Running aspell on markdown files..."
	@find . -type f -name "*.md"   -not -path "./source/_build/*" -not -path "*/.github/*" -not -path "*kicad*/*" -exec aspell check --mode=markdown --lang=en --personal=./aspell.list  {} \;
	@echo "Running aspell on rst files..."
	@find . -type f -name "*.rst" -not -path "./source/_build/*" -exec aspell check --lang=en --personal=./aspell.list  {} \;

img_src_check:
	@echo "Checking for <img src=...> tags..."
	@rg -tmd "img src="  -g'!_build' || true

admonition_check:
	@echo "Checking for !!! admonitions..."
	@rg -tmd '!!!' -g'!_build' -g'!colophon.md' || true

blockquote_header_check:
	@echo "Checking for ># blockquote headers..."
	@rg -tmd ">#" -g'!_build' -g'!colophon.md' || true

