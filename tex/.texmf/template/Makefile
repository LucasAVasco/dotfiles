build: FORCE
	source ./conf.sh && ~/.texmf/scripts/build.sh

setup: FORCE
	~/.texmf/scripts/setup.sh

serve: FORCE
	source ./conf.sh && ls *.tex | ~/.texmf/scripts/serve.sh

sheets: FORCE
	~/.texmf/scripts/export-sheets.sh ./sheet/

FORCE:
.PHONY: FORCE
