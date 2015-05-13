types = require "../src/types"
assert = require "assert"

describe "BaseX result types", ->
	it "Contains proper indices", ->
		assert (types instanceof Array), "Types is array"
		names = (t.name for t in types)
		ids = (t.id for t in types)
		assert.equal typeof types.byId, "object", "Has by id index"
		assert.equal typeof types.byName, "object", "Has by name index"
		for name in Object.keys types.byName
			assert (-1 isnt names.indexOf name), "Contains #{name}"
	



