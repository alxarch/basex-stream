basex = Session = require "../src/session"
{assert} = require "chai"

describe "BaseX events", ->

	db = "test_#{Date.now()}"
	
	session_a = new Session()
	session_b = new Session()

	before -> session_a.command "CREATE EVENT TESTEVENT"
	after -> session_a.command "DROP EVENT TESTEVENT"

	it "Instanciates a session properly", (done) ->
		expect = "#{Date.now()}"

		session_a.query "db:event('TESTEVENT', '#{expect}')"
		.then (q) ->
			session_b.events.on "TESTEVENT", (data) ->
				assert.equal data.toString(), expect
				done()
			q.execute()
		.catch done
			

		

			
