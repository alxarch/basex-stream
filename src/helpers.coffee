{createHash} = require "crypto"
{assign, indexBy} = require "lodash"

module.exports = helpers =
	assign: assign
	indexBy: indexBy
	identity: (a) -> a

	md5sum: (value) ->
		'''
		Compute the md5sum of a value in hex
		'''

		md5 = createHash "md5"
		md5.write value
		md5.end()
		md5.read().toString 'hex'

	isNumeric: (v) -> "#{parseFloat v}" is "#{v}"
	trim: (s) -> s.replace /(^\s+|\s+$)/g, ''
	lines: (txt, filter=helpers.identity) ->
		'''
		Split a string to lines.
		'''

		(line for line in ("#{txt}").split(/\r\n?|\n\r?/) when filter line)

	valueOf: (value) ->
		if value in ["true", "yes", "TRUE", "YES"]
			yes
		else if value  in ["false", "no", "FALSE", "NO"]
			no
		else if helpers.isNumeric value
			parseFloat value
		else
			"#{value}"

	parseoptions: (opt) ->
		options = {}
		pairs = []
		comma = no
		for part in opt.split ","
			if part is ""
				comma = yes
			else if comma
				comma = no
				pairs[pairs.length - 1] += ",#{part}"
			else
				pairs.push part

		for pair in pairs

			pos = pair.indexOf "="
			key = pair[0..pos - 1]
			value = pair[pos+1..]
			if -1 is value.indexOf "="
				options[key] = helpers.valueOf value
			else
				options[key] = helpers.parseoptions value
		console.log options
		options

	parseinfo: (txt) ->
		'''
		Parse INFO command output into js object.
		'''

		info = {}

		for line in helpers.lines txt
			[key, value] = line.split(":").map helpers.trim
			key = key.toLowerCase().replace /\s+/g, '_'
			unless key in ["general_information", "local_options", "global_options"]
				info[key] = helpers.valueOf value
		info
