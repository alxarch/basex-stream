{assign} = require "lodash"
net = require "net"
Promise = require "bluebird"
Query = require "./query"
{Readable} = require "stream"
{Clean, Smudge, NUL, Monitor, RawBuffer} = require "./stream"
Parser = require "./parser"
{md5sum} = require "./helpers"
Events = require "./events"
class Session
	module.exports = @

	QUERY = new RawBuffer [0]
	CREATE = new RawBuffer [8]
	ADD = new RawBuffer [9]
	WATCH = new RawBuffer [10]
	UNWATCH = new RawBuffer [11]
	REPLACE = new RawBuffer [12]
	STORE = new RawBuffer [13]
	FF = new RawBuffer [255]

	defaults =
		host: "127.0.0.1"
		port: "1984"
		user: "admin"
		pass: "admin"
	
	constructor: (options) ->
		{user, pass, host, port} = @options = assign {}, defaults, options
		@socket = net.createConnection port, host
		@events = new Events()
		@parser = @_authenticate user, pass
			.then =>
				@_in = new Clean
				@_out = new Smudge
				@socket.pipe @_in
				@_out.pipe @socket
				new Parser @_in

	_authenticate: (user, pass) ->
		new Promise (resolve, reject) =>
			@socket.on "connect", =>

				@socket.once 'readable', =>
					data = @socket.read()
					response = "#{data.slice 0, data.length - 1}".split ":"
					if response.length > 1
						[realm, nonce] = response
						hash = md5sum [user, realm, pass].join ':'
					else
						[nonce] = response
						hash = md5sum pass
					hash = md5sum hash + nonce
					@socket.once "readable", =>
						[err] = @socket.read()
						if err
							reject new Error "Authentication error"
						else
							# console.log "Authentication OK"
							resolve()
					@socket.write user
					@socket.write NUL
					@socket.write hash
					@socket.write NUL

	_put: (command, path, input) ->
		@parser.then (parser) =>
			p = parser.info()
			@_out.write command
			@_out.write path
			@_out.write NUL
			@transmit input
			p

	store: (path, input) -> @_put STORE, path, input
	replace: (path, input) -> @_put REPLACE, path, input
	add: (path, input) -> @_put ADD, path, input

	create: (name, input) ->
		@parser.then (parser) =>
			@_out.write CREATE
			@_out.write name
			@_out.write NUL
			@transmit input
			parser.info()

	query: (xql) ->
		@parser.then (parser) =>
			@_out.write QUERY
			@transmit xql
			parser.info().then (id) =>
				new Query @, "#{id}"

	transmit: (input) ->
		{_out} = @

		new Promise (resolve) ->
			unless input?
				_out.write NUL
				return resolve()

			if input instanceof Readable
				input.pipe _out, end: no
				input.on "end", =>
					_out.write NUL
					input.unpipe _out
					resolve()
			else
				_out.write input
				_out.write NUL
				resolve()
			return

	unwatch: (name) ->
		@parser.then (parser) =>
			@_out.write UNWATCH
			@_out.write name
			@_out.write NUL
			parser.info()

	watch: (name) ->
		{host} = @options

		@parser.then (parser) =>

			@_out.write WATCH
			@_out.write name
			@_out.write NUL
			unless @events.socket?
				parser.watch().spread (id, port) =>
					@events.connect id, host, port
			parser.info()

	command: (cmd, output) ->
		@parser.then (parser) =>
			@_out.write cmd
			@_out.write NUL
			p = parser.command()
			if output?
				p.out.pipe output
			p