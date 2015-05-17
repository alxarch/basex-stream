Session
=======

Session is the main interface to the BaseX Server

	module.exports = class Session
		_ = require "lodash"
		Promise = require "bluebird"
		{Readable} = require "stream"


		{RawBuffer, NUL} = require "./stream"

		QUERY = new RawBuffer [0]
		CREATE = new RawBuffer [8]
		ADD = new RawBuffer [9]
		REPLACE = new RawBuffer [12]
		STORE = new RawBuffer [13]

		Query = require "./query"

		{md5sum, parseinfo} = require "./helpers"

		constructor: (options) ->

Session can handle both `s = new Session()` and `s = Session()` constructor styles.

			unless @ instanceof Session
				return new Session options

By default a session will try to connect using BaseX server's default settings.

			@options = _.defaults {}, options,
				host: "127.0.0.1"
				port: "1984"
				user: "admin"
				pass: "admin"


The `session.events` property is an `EventEmitter`.
Event listeners can register via `session.events.on("event_name")`.
For more information see [events](events.html).

			events = require "./events"
			@events = events @
			@_init()


		_connect: (host, port) ->
			{createConnection} = require "net"
			c = new Promise (resolve, reject) ->
				socket = createConnection port, host
				socket.on "error", (err) ->
					if c.isPending()
						reject err
					else
						console.err err
				socket.once "connect", -> resolve socket

Streams
-------

		_init: (socket) ->

			{host, port, user, pass} = @options

			io = @_connect host, port
			.then (socket) => @_authenticate socket, user, pass
			.then (socket) =>

				{Clean, Smudge} = require "./stream"

All incoming socket data is piped to the [Clean](stream.litcoffee#Clean) filter
to handle 0x00 and 0xFF bytes and break incoming data into usable chunks.

				input = new Clean
				socket.pipe input

To handle server responses the 'clean' input stream is handed over to the [Parser](parser.litcoffee).

				parse = require "./parser"
				read = parse input

All outgoing socket data goes through a [Smudge](stream.litcoffee#Smudge) filter
prior to sending to handle 0x00 and 0xFF padding.

				output = new Smudge
				output.pipe socket

A `write(data...)` helper is used to send data to the server.
It will write it's arguments in sequence, piping any `Readable` streams
it ecounters.

				write = (args...) ->
					single = (written, item) ->
						new Promise (resolve, reject) ->
							if item instanceof Readable
									item.pipe output, end: no
									item.once "error", reject
									item.on "end", ->
										item.unpipe output
										resolve written.concat yes
							else if item?
								unless typeof item is "string" or item instanceof Buffer
									item = "#{item}"
								output.write item, ->
									resolve written.concat yes

							else
								resolve written.concat no

					Promise.reduce args, single, []


				[read, write]

All uses of the the session's socket and parser should use `session.io(callback)`.
It provides the callback with the `read` and `write` arguments and executes it
only after the connection is established.

			@io = (callback) -> io.spread -> callback arguments...

Authentication
--------------

Session supports both `Basic` and `Digest` authentication methods.

Digest authentication is used in BaseX version greater than 8.x.
When connecting to an older server Basic authentication is used.

		_authenticate: (socket, user, pass) ->
			new Promise (resolve, reject) =>
				socket.once 'readable', =>
					data = socket.read()

					response = "#{data.slice 0, data.length - 1}".split ":"


					if response.length > 1
						[realm, nonce] = response
						hash = md5sum [user, realm, pass].join ':'
					else
						[nonce] = response
						hash = md5sum pass

					hash = md5sum hash + nonce

					socket.once "readable", =>
						[err] = socket.read()
						if err
							reject new Error "Authentication error"
						else
							resolve socket

					socket.write user
					socket.write NUL
					socket.write hash
					socket.write NUL

Session commands
----------------

> If `data` argument is a `Readable` stream then it will be piped directly
  to the session output.

Execute database commands with `session.command(data)`

		command: (data) ->
			@io (read, write) =>
				write data, NUL
				read.command()

Create new databases with `session.create(name, data)`

		create: (name, data) ->
			@io (read, write) =>
				write CREATE, name, NUL, data, NUL
				read.info()

Create [Query](query.html) instances with `session.query(data)`

		query: (data) ->
			@io (read, write) =>
				write QUERY, data, NUL
				read.info().then (id) =>
					new Query "#{id}", read, write

Store a raw resource using `session.store(path, data)`

		store: (path, data) -> @_resource STORE, path, data

Replace a resource using `session.store(path, data)`

		replace: (path, data) -> @_resource REPLACE, path, data

Add a document resource using `session.add(path, data)`

		add: (path, data) -> @_resource ADD, path, data

		_resource: (method, path, data) ->
			@io (read, write) =>
				write method, path, NUL, data, NUL
				read.info()

Helpers
-------

Use `session.info` to get the output of `INFO` command as object

		info: ->
			@command "INFO"
			.spread (output) -> parseinfo output

	{Clean, Smudge} = require "./stream"
