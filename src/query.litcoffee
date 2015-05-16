Queries
=======

Query instances are used to execute XQUERY on the server.

	exports = class Query

		{RawBuffer, NUL} = require "./stream"

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

		_command: (cmd, output) ->
			@session.io (read, write) =>
				write cmd, @id, NUL
				read.info()

Query information
-----------------

		options: () ->
			@_command OPTIONS
			.then (opt) -> "#{opt}"

		info: () ->

			@_command INFO
			.then (info) -> "#{info?.slice 1}"

		updating: () ->
			@_command UPDATING
			.then (upd) -> "#{upd}" is "true"


Query bindings
--------------

		bind: (name, value, type) ->
			@session.io (read, write) =>
				write BIND, @id, NUL, name, NUL, value, NUL, type, NUL
				read.info()

		context: (value, type) ->
			@session.io (read, write) =>
				write CONTEXT, @id, NUL, value, NUL
				read.info()

Query results
-------------

There are two possible ways in which query results can be retrieved.
Either as a single response [buffer](https://nodejs.org/api/buffer.html)
using `query.execute()`

		execute: (info) ->
			@_command EXECUTE
			.then (output) =>
				if info
					@info().then (info) ->
						output.info = info
						output
				else
					output

or by parsing results as-they-come with `query.results(callback)`.
The callback's signature is `callback(type, data)`
where `type` is the name of the [result type](types.html)
and `data` is a [buffer](https://nodejs.org/api/buffer.html) containing the result output.

		results: (callback, info) ->
			@session.io (read, write) =>
				write RESULTS, @id, NUL
				read.results callback
				.then (results) =>
					if info
						@info().then (info) ->
							results.info = info
							results
					else
						results


A query can be executed multiple times without the overhead of XQUERY parsing.
After a query is no longer usefull it should be closed by `query.close()` to
free up server resources.

		close: -> @_command CLOSE
