{Transform} = require "stream"
{NUL} = require "./stream"
class Events extends Transform

	module.exports = @
	constructor: (options={}) ->
		options.readableObjectMode = yes
		super options
		@nul = null
		@event = {}
		@socket = null
		@on "pipe", (socket) =>
			if @socket?
				throw new Error "Multiple pipes not supported"
			@socket = socket

		@on "unpipe", => @socket = null

	_transform: (chunk, encoding, callback) ->
		unless @nul?
			@nul = 0
			[err] = chunk
			if err
				throw new Error "Failed to monitor events."
			else
				console.log "Monitor up"
			callback()
			return

		if chunk is NUL
			@nul++
		else
			switch @nul % 2
				when 0
					@event.name = "#{chunk}"
				when 1
					@event.data = chunk
					@push @event
		callback()
		return