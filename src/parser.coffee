{NUL} = require "./stream"
{PassThrough} = require "stream"
Promise = require "bluebird"
net = require "net"

types = require "./types"

class Parser
	module.exports = @
	

	constructor: (@_stream) ->
		@_head = @_tail = null
		@_registered = no

	_resume: ->
		unless @_registered
			@_stream.on "data", (chunk) =>
				if @_head?
					@_head chunk
				else
					throw new Error "Unhandled data passing trough!!!"
				return
			@_registered = yes
		@_stream.resume()
		return
		
	_append: (callback) ->
		callback.next = null
		if @_tail?
			# console.log "NO TAIL"
			@_tail.next = callback
			@_tail = callback
		else
			@_head = @_tail = callback
		@_resume()
		return

	_shift: ->
		# console.log "_SHIFTING..."
		# console.log "HEAD BEFORE #{@_head?}"
		@_head = @_head?.next
		
		unless @_head?
			@_tail = null
			# console.log "PAUSE"
			@_stream.pause()
		# console.log "HEAD AFTER #{@_head?}"
		return

	watch: (host) ->
		new Promise (resolve, reject) =>
			nul = 0
			port = null
			id = null
			@_append (chunk) =>
				if nul > 1
					@_shift()
					socket = net.createConnection port, host
					socket.on "connect", ->
						socket.write id
						socket.write NUL
						resolve socket

				else if chunk is NUL
					nul++
				else if nul is 0
					port = parseInt "#{chunk}"
				else if nul is 1
					id = "#{chunk}"
				return

	info: (raw) ->
		out = new PassThrough
		p = new Promise (resolve, reject) =>
			nul = 0
			@_append (chunk) =>
				if nul > 0
					@_shift()
					[err] = chunk
					out.end()
					if err
						reject new Error "#{chunk.slice 1}"
					else
						resolve if raw then out.read() else out.read()?.toString() or null
				else if chunk is NUL
					nul++
				else if nul is 0
					out.write chunk
				return
		p.out = out
		p

	command: () ->
		out = new PassThrough
		p = new Promise (resolve, reject) =>
			nul = 0
			info = null
			@_append (chunk) =>
				if nul >= 2
					@_shift()
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

	results: (callback) ->
		unless typeof callback is "function"
			throw new TypeError "Callback argument required"
		new Promise (resolve, reject) =>
			buffer = []
			nul = 0
			n = 0
			@_append (chunk) =>
				if nul > 0
					@_shift()
					[err] = chunk
					if err
						reject new Error "#{chunk.slice 1}"
					else
						resolve n
				else if chunk is NUL
					if nul < 0
						n++
						data = Buffer.concat buffer
						buffer = []
						[type] = data

						callback types.byId[type].name, data.slice 1
					nul++
				else
					nul = -1
					buffer.push chunk
				return