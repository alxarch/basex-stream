{Clean, Smudge, RawBuffer, NUL} = require "../src/stream"

{assert} = require "chai"

describe "Smudge", ->

	it "Prefixes 0x00 and 0xFF bytes with 0xFF", ->

		sm = new Smudge()

		data = new Buffer [1,2,3,4,5,0,6,7,8,9,255,0,0]
		sm.write data
		expect = new Buffer [1,2,3,4,5,255,0,6,7,8,9,255,255,255,0,255,0]
		assert.equal sm.read().toString(), expect.toString()

	it "Allows RawBuffer buffers to pass through unmodified", ->

		sm = new Smudge()
		data = new RawBuffer [1,2,3,4,5,0,6,7,8,9,255,0,0]
		sm.write data
		assert.equal sm.read(), data

describe "Clean", ->
	it "Strips 0x00 and 0xFF prefix bytes", ->

		sm = new Clean()

		data = new Buffer [1,2,3,4,5,255,0,6,7,8,9,255,255,255,0,255,0]
		sm.write data
		expect = new Buffer [1,2,3,4,5,0,6,7,8,9,255,0,0]
		assert.equal sm.read().toString(), expect.toString()

	it "Injects the 'magic' NUL buffer between chunks", ->
		c = new Clean()

		data = new Buffer [1,2,3,4,5,0,6,7,8,9,0]
		chunks = []
		c.on "data", (chunk) -> chunks.push chunk
		c.write data
		assert.equal chunks.length, 4
		assert.equal chunks[1], NUL
		assert.equal chunks[3], NUL
