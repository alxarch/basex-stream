Stream
======


	{Transform} = require "stream"
	Promise = require "bluebird"
	FF = new Buffer [255]

	class RawBuffer extends Buffer

	NUL = new RawBuffer [0]

	class Smudge extends Transform
		_transform: (chunk, encoding, callback) ->
			if chunk instanceof RawBuffer
				@push chunk
				callback()
				return
			offset = 0
			for c, i in chunk
				if c in [0xFF, 0x00]
					if i > offset
						@push chunk.slice offset, i
					@push FF
					offset = i
			if offset < i
				@push chunk.slice offset
			callback()
			return

	class Clean extends Transform
		constructor: ->
			super
			@ff = no

		_transform: (chunk, encoding, callback) ->
			offset = 0
			for c, i in chunk
				if @ff
					@ff = no
				else if c is 0xFF
					@ff = yes
					@push chunk.slice offset, i
					offset = i + 1
				else if c is 0x00
					# console.log "IS NUL"
					@push chunk.slice offset, i
					@push NUL
					offset = i + 1

			if offset < i
				# console.log "LEFTOVER"
				@push chunk.slice offset
			callback()
			return

	module.exports = {
		Clean
		Smudge
		NUL
		RawBuffer
	}