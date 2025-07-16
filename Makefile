.PHONY: test greet
test:
	nvim --headless -c "PlenaryBustedDirectory tests/spec"

greet:
	echo "Hello world"
