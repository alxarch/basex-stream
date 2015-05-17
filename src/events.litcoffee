Events
======

This module is a factory for an [EventEmitter][ee] used to monitor BaseX events.
It automatically issues `WATCH` and `UNWATCH` commands when
`events.on(event, listener)` or `events.removeListerner(event, listener)`
is used.

	module.exports = (session) ->
		{EventEmitter} = require "events"

		events = new EventEmitter

		ready = no
		events.on "removeListener", (event) ->
			return unless ready
			session.io (read, write) ->
				unwatch event, read, write

		events.on "newListener", (event) ->
			session.io (read, write) ->
				if ready
					watch event, read, write
				else
					{host} = session.options
					read.watch()
					.spread (id, port) -> connect id, host, port
					.then (socket) ->
						init socket
						ready = yes

					watch event, read, write

		Promise = require "bluebird"
		{RawBuffer, NUL} = require "./stream"

		WATCH = new RawBuffer [10]
		UNWATCH = new RawBuffer [11]

		monitored = {}
		nul = 0
		{PassThrough} = require "stream"
		name = new PassThrough
		data = new PassThrough
		ondata  = (chunk) ->
			if chunk is NUL
				if nul++ % 2
					events.emit "#{name.read()}", data.read()
			else if nul % 2
				data.write chunk
			else
				name.write chunk

		init = (socket) ->
			{Clean} = require "./stream"
			{PassThrough} = require "stream"
			name = new PassThrough
			data = new PassThrough
			nul = 0
			stream = new Clean()
			stream.on "data", ondata
			socket.pipe stream

		unwatch = (name, read, write) ->
			n = monitored[name]
			if n is 1
				delete monitored[name]
				write UNWATCH, name, NUL
				read.info()
			else if n?
				monitored[name]--
			return

		watch = (name, read, write) ->
			n = monitored[name]
			if n?
				monitored[name]++
			else
				write WATCH, name, NUL
				read.info().tap -> monitored[name] = 1
			return

		connect = (id, host, port) ->

			net = require "net"
			new Promise (resolve, reject) ->
				socket = net.createConnection port, host
				socket.on "connect", ->
					socket.once "readable", ->
						[err] = socket.read()
						if err
							reject new Error "Failed to monitor events."
						else
							resolve socket

					socket.write id
					socket.write NUL

		events


[ee]: https://nodejs.org/api/events.html
