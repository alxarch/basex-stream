Parser
======

The parser handles server responses.

	module.exports = (stream) ->

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
			# console.log "shifting"
			# console.dir head, tail

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
				# console.log "registrering data handler"
				stream.on "data", (chunk) ->
					# console.log "parse data handler"
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

Use `parse.info()` to parse the output of most [protocol commands][pc].
It returns a `Promise` of a `Buffer` of command's output.
(*note* if the `promise.out` stream is consumed then `out` will be `null`)

The returned promise also has an `out` property that is an instance of
 `Readable` stream of the output.

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

Use `parse.command()` to parse the output of an executed command.
It returns a `Promise` of an `object` with keys `out` and `info`.
- `out` holds a `Buffer` of command's output.
  (*note* if the `promise.out` stream is consumed then `out` will be `null`)
- `info` may hold a string with info about the execution of the command.

The returned promise also has an `out` property that is an instance of
`Readable` stream of the output.

		command: () ->
			# console.log "parse.command called"
			out = new PassThrough
			p = new Promise (resolve, reject) ->
				nul = 0
				inf = null
				# console.log "appending data handler"
				append (chunk) ->
					# console.log "parse.command data handler process chunk"
					if nul >= 2
						# console.log "parse.command done"
						shift()
						# console.log "parse.command shifted"
						[err] = chunk
						out.end()
						# console.log "parse.command out ended"
						if err
							# console.log "parse.command error"
							reject new Error inf
						else
							# console.log "parse.command ok"
							resolve [out.read(), inf or null]
					else if chunk is NUL
						nul++
					else if nul is 0
						out.write chunk
					else if nul is 1
						inf ?= "#{chunk}"
					return
			p.out = out
			p


Results
-------

Use `query.results()` to parse the `RESULTS` query command output.
This data handler accepts a `callback` that will be triggered for every result
 with two arguments `type` - the type of the result as string - and
`data` - the data of the result as `Buffer`. If `callback` is not a `function`
then all results are appended to an `Array` as an `object` holding two keys:
`type` - the type of data as `string` and
`data` - a `Buffer` with the result.

It returns a `Promise` of an `object` with two keys:
`count` - the number of results and
`rows` - the results as an `Array`.

If a `callback` is provided the `rows` array will be empty but `count` will
still hold the total number of results returned.

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

Use `parse.watch()` to parse the output of the first ever `WATCH` command for
each session. It returns a `Promise` of an object with keys `port` and `id`.


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

[pc]: http://docs.basex.org/wiki/Server_Protocol#Command_Protocol
