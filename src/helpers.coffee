{createHash} = require "crypto"

module.exports =
	md5sum: (value) ->
		md5 = createHash "md5"
		md5.update value
		md5.digest 'hex'
