basex = Session = require "../src/session"
{assert} = require "chai"

describe "BaseX queries", ->
	session = new Session()
	db = "test_#{Date.now()}"
	before -> session.create db
	it "returns query options", (done) ->
		xql = """
		declare option output:method "json";
		declare option output:json "lax";
		<json type="object"/>
		"""
		session.query xql
		.then (q) ->
			q.options()
			.then (options) ->
				assert.isObject options
				done()
		.catch done


	it "returns updating", (done) ->
		xql = """
			delete node db:open("#{db}")/test
		"""
		session.query "1 to 10"
		.then (q) ->
			q.updating()
			.then (upd) ->
				assert.isFalse upd
			.then ->
				q.close()
		.then ->
			session.query xql
		.then (q) ->
			q.updating()
			.then (upd) ->
				assert.isTrue upd
			.then ->
				q.close()
		.then -> done()
		.catch done


	it "handles errors gracefully", (done) ->
		session.command "foo"
		.catch (err) ->
			assert.notEqual err.message.indexOf("Unknown command: foo."), -1
			null
		.then ->

			session.query "1 to 10"
		.then (q) ->
			q.execute()
			.then (output) ->
				assert.equal output.toString(), ([1..10]).join "\n"
				q.close()
			.then ->
				done()
		.catch done

	it "returns query info", (done) ->
		session.query "1 to 10"
		.then (q) ->
			q.execute yes
			.spread (output, info) ->
				assert.isNotNull info
				q.close()
			.then ->
				done()
		.catch done

	it "binds variables", (done) ->
		xql = """
		declare variable $test external := 0;
		$test
		"""

		session.query xql
		.then (q) ->
			q.bind "test", 1
			.then () ->
				q.execute()
			.then (result) ->
				assert.equal "#{result}", "1"
				q.close()
		.then -> done()
		.catch done

	it "Fetches RESULTS", (done) ->
		session.query "1 to 10"
		.then (q) ->
			n = 1
			q.results (type, number) ->
				assert.equal type, "xs:integer"
				assert.equal (parseInt "#{number}"), n++
			.then (results) ->
				assert.property results, "count"
				assert.equal results.count, 10
				assert.property results, "rows"
				assert.isNull results.rows
				q.close()
			.then -> done()
		.catch done
