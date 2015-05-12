{RawBuffer, NUL} = require "./stream"
{join} = require "bluebird"
class Query
	module.exports = @

	EMPTY = new RawBuffer []
	CLOSE = new RawBuffer [2]
	BIND = new RawBuffer [3]
	RESULTS = new RawBuffer [4]
	EXECUTE = new RawBuffer [5]
	INFO = new RawBuffer [6]
	OPTIONS = new RawBuffer [7]
	CONTEXT = new RawBuffer [14]
	UPDATING = new RawBuffer [30]
	FULL = new RawBuffer [31]
	
	constructor: (@session, @id) ->
		return

	bind: (name, value, type) ->
		@session.parser.then (parser) =>
			{_out} = @session
			_out.write BIND
			_out.write @id
			_out.write NUL
			_out.write name
			_out.write NUL
			_out.write value
			_out.write NUL
			if type?
				_out.write type
			_out.write NUL
			parser.info()

	_command: (cmd, output) ->
		@session.parser.then (parser) =>
			{_out} = @session
			_out.write cmd
			_out.write @id
			_out.write NUL
			parser.info output
		
	options: (output) -> @_command OPTIONS, output
	info: (output) ->
		@_command INFO, output
		.then (info) ->
			# Remove newline at start of info
			info?.slice 1

	updating: (output) -> @_command UPDATING, output
	execute: (output) ->
		# Return both query and info in single result
		join (@_command EXECUTE, output), @_command INFO

	close: -> @_command CLOSE

	context: (value, type) ->
		@session.parser.then (parser) =>
			{_out} = @session
			_out.write CONTEXT
			_out.write @id
			_out.write NUL
			@session.transmit value
			parser.info()

	results: (callback) ->

		@session.parser.then (parser) =>
			{_out} = @session
			_out.write RESULTS
			_out.write @id
			_out.write NUL
			# Return both result count and info in single result
			join (parser.results callback), @info()