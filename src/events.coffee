{PassThrough} = require "stream"
{NUL, Clean} = require "./stream"
{EventEmitter} = require "events"
net = require "net"

class Events extends EventEmitter
	module.exports = @
	constructor: ->
		@socket = null
		ok = no
		nul = 0
		name = new PassThrough
		data = new PassThrough
		@stream = new Clean()
		@stream.on "data", (chunk) =>
			unless ok
				[err] = chunk
				if err
					throw new Error "Failed to monitor events."
				ok = yes
				return

			if chunk is NUL
				if nul++ % 2
					@emit "#{name.read()}", data.read()
			else if nul % 2
				data.write chunk
			else
				name.write chunk

	connect: (id, host, port) ->
		@socket = net.createConnection port, host
		@socket.pipe @stream
		@socket.on "connect", =>
			@socket.write id
			@socket.write NUL
		return