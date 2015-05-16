Parser
======

The parser handles server responses.

	module.exports = parse: (stream) ->

Parser queue
------------

It manages the flow of data out of the input stream using
a FIFO queue of data handlers. A linked list is used to handle
the queue.

		head = tail = null

Each of the parsing methods adds a stream chunk handler as a
node at the tail of the linked list.
Besides resolving or rejecting it's response `Promise`, each parse method
is responsible for calling `append()` to link it's data handler at the tail 
of the queue and `shift()` when it finishes in order for the
parser to advance to the next data handler.

		append = (handler) ->
			handler.next = null
			if tail?
				tail.next = handler
				tail = handler
			else
				head = tail = handler
			resume()
			return

When there are no more handlers left in the queue the stream is paused
waiting for new handlers to be added.

		shift = ->
			head = head?.next
			
			unless head?
				tail = null
				stream.pause()
			return

		registered = no

As soon as a handler is queued, the stream resumes 'flow' mode
by attaching the queue's `data` event handler.

		resume = ->
			unless registered
				stream.on "data", (chunk) ->
					if head?
						head chunk
					else
						throw new Error "Unhandled data passing through!!!"
					return
				registered = yes
			stream.resume()
			return

Response handlers
--------------

Info
----

		info: () ->
			out = new PassThrough
			p = new Promise (resolve, reject) ->
				nul = 0
				append (chunk) =>
					if nul > 0
						shift()
						[err] = chunk
						out.end()
						if err
							reject new Error "#{chunk.slice 1}"
						else
							resolve out.read()
					else if chunk is NUL
						nul++
					else if nul is 0
						out.write chunk
					return
			p.out = out
			p

Command
-------

		command: () ->
			out = new PassThrough
			p = new Promise (resolve, reject) ->
				nul = 0
				info = null
				append (chunk) ->
					if nul >= 2
						shift()
						[err] = chunk
						out.end()
						if err
							reject new Error info
						else
							resolve [out.read(), info or null]
					else if chunk is NUL
						nul++
					else if nul is 0
						out.write chunk
					else if nul is 1
						info ?= "#{chunk}"
					return
			p.out = out
			p


Results
-------

		results: (callback) ->
			unless typeof callback is "function"
				rows = []
				callback = (type, data) -> rows.push {type, data}

			new Promise (resolve, reject) ->
				buffer = []
				nul = 0
				count = 0
				append (chunk) ->
					if nul > 0
						shift()
						[err] = chunk
						if err
							reject new Error "#{chunk.slice 1}"
						else
							resolve {count, rows}
					else if chunk is NUL
						if nul < 0
							count++
							data = Buffer.concat buffer
							buffer = []
							[type] = data

							callback TYPES.byId[type].name, data.slice 1
						nul++
					else
						nul = -1
						buffer.push chunk
					return

Watch
-----

		watch: ->
			new Promise (resolve, reject) ->
				nul = 0
				port = null
				id = null
				append (chunk) ->
					if nul > 1
						@_shift()
						resolve {id, port}

					else if chunk is NUL
						nul++
					else if nul is 0
						port = parseInt "#{chunk}"
					else if nul is 1
						id = "#{chunk}"
					return


	TYPES = require "./types"
	{NUL} = require "./stream"
	{PassThrough} = require "stream"
	Promise = require "bluebird"
