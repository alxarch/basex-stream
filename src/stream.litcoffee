Stream
======

The server protocol uses the `0x00` (aka [`NUL`](#NUL)) byte as separator.
To be able to transmit raw binary data (that could contain such a byte)
all `0x00` and `0xFF` bytes [should be prefixed][ff00] with an extra `0xFF`.
This creates the need for a [`Clean`](#Clean) and a [`Smudge`](#Smudge) filter
to be applied to all i/o.

RawBuffer
---------

The `RawBuffer` is used in order for the [`Smudge`](#Smudge) filter to be able
to distinguish between single byte binary chunks and 'special' bytes such as
protocol commands and [`NUL`](#NUL) separator that should go through unescaped.

	class RawBuffer extends Buffer

NUL
---

A special instance of a [`RawBuffer`](#RawBuffer) is used for the NUL separator.
This unique instance is included in the module's exports and allows all users
of the [`Clean`](#Clean) filter to identify the separator within
the flow of data (by using an identity check i.e. `data === NUL`).

	NUL = new RawBuffer [0]

Clean
-----

	{Transform} = require "stream"

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
					@push chunk.slice offset, i
					@push NUL
					offset = i + 1

			if offset < i
				@push chunk.slice offset
			callback()
			return

Smudge
------

	class Smudge extends Transform
		FF = new Buffer [255]
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

	module.exports = {
		Clean
		Smudge
		NUL
		RawBuffer
	}

	Promise = require "bluebird"


[ff00]: http://docs.basex.org/wiki/Server_Protocol#Conventions
