test:
	@node_modules/mocha/bin/mocha --reporter spec --ui bdd --require test/test_helper test/*.coffee

.PHONY: test
