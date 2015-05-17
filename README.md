basex-stream
============

BaseX client for nodeJS using streams and promises.


Usage
-----

```js
var basex = require("basex-stream");
var session = basex({
	host: "127.0.0.1",
	port: 1984,
	user: "admin",
	pass: "admin"
});
```

Create
------

Create new databases with

```js
session.create("test");
```
Commands
--------

Issue a [database command][dbcmd] with

```js
session.command("LIST")
.spread(function (output, info) {
	console.log(output);
});
```
or get a streamable response by using the promise's `out` property

```js
var p = session.command("LIST");
p.out.pipe(process.stdout);
p.then(function (output, info) {
	// Now that the output stream is consumed output is null
	console.log("The string was consumed, thus output is " + output);
});

```

Resources
---------

Add new resources to a database with

```js
session.store("test.txt", "Hello World!");
```

or pipe in a `Readable` stream directly

```js
var fs = require("fs");
var input = fs.createReadStream("test.txt");

session.store("test.txt", input);
```

Queries
-------

```js
session.query("1 to 1000")
.then(function (q) {
	return q.results(function (type, data) {
		console.log(type, data.toString());
	})
	.then(function (results) {
		console.log("Found " + results.count + " results.");
	})
	.then(function () {
		q.close()
	});
})
.catch(function (error){
	console.error(error);
});
```

[dbcmd]: http://docs.basex.org/wiki/Commands
