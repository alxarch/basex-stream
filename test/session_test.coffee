basex = Session = require "../src/session"
assert = require "assert"

describe "BaseX session", ->
	db = "test_#{Date.now()}"
	session = new Session()

	it "Instanciates a session properly", (done) ->
		session.io ->
			done()
		.catch done

	it "Executes commands", (done) ->
		session.command "CHECK #{db}"
		.spread (out, info) ->
			console.log info
			done()
			
		.catch done

	it "Retrieves db info properly", (done) ->
		session.info().then (info) ->
			console.log info
			assert info.dbpath?
			done()
		.catch done

	



