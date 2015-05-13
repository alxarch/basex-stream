Session = require "../src/session"
assert = require "assert"

describe "BaseX session", ->
	it "Instanciates a session properly", (done) ->
		session = new Session()
		session.parser
		.then (parser) ->
			assert parser isnt null
			done()
		.catch done
	it "Retrieves db info properly", (done) ->
		session = new Session()
		session.info().then (info) ->
			assert info['DBPATH']?
			done()
		.catch done

	



