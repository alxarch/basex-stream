basex = Session = require "../src/session"
{assert} = require "chai"

describe "BaseX session", ->
	db = "test_#{Date.now()}"
	session = new Session()

	it "Instanciates a session properly", (done) ->
		session.io (read, write) ->
			done()
		.catch done

	it "Executes commands", (done) ->
		session.command "CHECK #{db}"
		.spread (output, info) ->
			assert.isNull output
			assert.isNotNull info
			done()

		.catch done

	it "Executes a query", (done) ->
		session.query "1 to 10"
		.then (q) ->
			assert.isObject q
			q.execute()
		.then (output) ->
			assert.equal "#{output}", (i for i in [1..10]).join "\n"
			done()

		.catch done



	it "Retrieves db info properly", (done) ->
		session.info().then (info) ->
			assert.isObject info
			assert info.version?.match /^\d+\.\d+\.\d+$/
			done()
		.catch done
