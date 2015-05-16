Promise = require "bluebird"
{EventEmitter} = require "events"

module.exports = class Events extends EventEmitter

	{RawBuffer, NUL} = require "./stream"
	WATCH = new RawBuffer [10]
	UNWATCH = new RawBuffer [11]

	constructor: (@session) ->
		@socket = null
		@on "removeListener", (event) => @_unwatch event
		@on "newListener", (event) =>
			if @socket?
				return @watch event

			{host} = @session.options
			@session.io (input, output, parse) =>
				parse.watch()
				.spread (id, port) =>
					@_connect id, host, port
				.then =>
					@_watch event

	_init: ->
		{Clean} = require "./stream"
		{PassThrough} = require "stream"
		name = new PassThrough
		data = new PassThrough
		nul = 0
		@stream = new Clean()
		@stream.on "data", (chunk) =>
			if chunk is NUL
				if nul++ % 2
					@emit "#{name.read()}", data.read()
			else if nul % 2
				data.write chunk
			else
				name.write chunk
		@socket.pipe @stream

	_unwatch: (name) ->
		@session.io (input, output, parse) ->
			output.write UNWATCH
			output.write name
			output.write NUL
			parse.info()

	_watch: (name) ->
		@session.io (input, output, parse) ->
			output.write WATCH
			output.write name
			output.write NUL
			parse.info()

	_connect: (id, host, port) ->
		new Promise (resolve, reject) =>
			net = require "net"
			@socket = net.createConnection port, host
			@socket.on "connect", =>
				@socket.once "readable", =>
					[err] = @socket.read()
					if err
						reject new Error "Failed to monitor events."
					else
						@_init()
						resolve()

				@socket.write id
				@socket.write NUL
