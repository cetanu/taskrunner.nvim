test:
	nvim --headless -c "PlenaryBustedDirectory tests/spec"

greet:
	echo "Hello world"

build: greet
lint: greet
deploy: greet

.PHONY: test greet build lint deploy

