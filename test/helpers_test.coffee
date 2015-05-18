{parseoptions} = require "../src/helpers"

{assert} = require "chai"

describe "parseoptions", ->

	it "parses options string", ->
		opt = "csv=header=yes,json=lax=yes,,merge=no"
		options = parseoptions opt
		assert.property options, "csv"
		assert.property options, "json"
		assert.isObject options.csv
		assert.isObject options.json
		assert.property options.json, "lax"
		assert.property options.json, "merge"
		assert.isFalse options.json.merge
		assert.isTrue options.json.lax

		assert.property options.csv, "header"
		assert.isTrue options.csv.header
