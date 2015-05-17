Queries
=======

Query instances are used to execute XQUERY on the server.

	module.exports = class Query

		{RawBuffer, NUL} = require "./stream"

Each query instance is a pre-parsed XQUERY expression residing on the server.
Each query is assigned an id by the server.
There are 9 commands associated with query instances:

		CLOSE = new RawBuffer [2]
		BIND = new RawBuffer [3]
		RESULTS = new RawBuffer [4]
		EXECUTE = new RawBuffer [5]
		INFO = new RawBuffer [6]
		OPTIONS = new RawBuffer [7]
		CONTEXT = new RawBuffer [14]
		UPDATING = new RawBuffer [30]
		FULL = new RawBuffer [31]

		constructor: (@id, @read, @write) ->
			return

		_command: (cmd, output) ->
			@write cmd, @id, NUL
			@read.info()

Query information commands
--------------------------

To receive information on the options declared in a query's prolog,
use `query.options()`.

		options: () ->
			@_command OPTIONS
			.then (opt) -> "#{opt}"

To receive information on a query's last excution time, use `query.info`.
This method returns `null` until the first query execution. By default both
`query.execute()` and `query.results()` queue up a `query.info()` after
they finish.

		info: () ->

			@_command INFO
			.then (info) -> "#{info?.slice 1}"

To find out if a query contains updating expressions use `query.updating()`.

		updating: () ->
			@_command UPDATING
			.then (upd) -> "#{upd}" is "true"


Query bindings
--------------

Use `query.bind(name, value, type)` to bind *exterrnal variables* to a query.

		bind: (name, value, type) ->
			@write BIND, @id, NUL, name, NUL, value, NUL, type, NUL
			@read.info()

Use `query.context(name, value, type)` to assign a different context
for the query to execute agaist.

		context: (value, type) ->
			@write CONTEXT, @id, NUL, value, NUL
			read.info()

Query results
-------------

There are two possible ways in which query results can be retrieved.
Either as a single response [buffer][buffer]
using `query.execute()`

		execute: (info) ->
			@_command EXECUTE
			.then (output) =>
				if info
					@info().then (info) -> [output, info]
				else
					output

or by parsing results as-they-come with `query.results(callback)`.
The callback's signature is `callback(type, data)`
where `type` is the name of the [result type](types.html)
and `data` is a [buffer][buffer] containing the result output.

		results: (callback, info) ->
			@write RESULTS, @id, NUL
			@read.results callback
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

[buffer]: https://nodejs.org/api/buffer.html
