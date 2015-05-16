# basex-stream

BaseX client for nodeJS using streams and promises.


## Usage

```js
var basex = require("basex-stream");
var session = basex({
	host: "127.0.0.1",
	port: 1984,
	user: "admin",
	pass: "admin"
});

var fs = require("fs");

session.create("test")
	.then(function () {
		var input = fs.createReadStream("test.txt");
		return session.store("test.txt", input);
	})
	.then(function () {
		return session.query("1 to 1000")
	})
	.then(function (q) {
		return q.results(function (type, data) {
			console.log(type, data.toString());
		});
	})
	.then(function (count) {
		console.log("Found " + count + " results.");
	})
	.catch(function (error){
		console.error(error);
	});
```
