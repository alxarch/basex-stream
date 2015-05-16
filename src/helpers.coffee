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

	parseinfo: (txt) ->
		'''
		Parse INFO command output into js object.
		'''

		info = {}
		getvalue = (v) ->
			if value is "true"
				yes
			else if value is "false"
				no
			else if helpers.isNumeric value
				parseFloat value
			else
				"#{value}"

		for line in helpers.lines txt 
			[key, value] = line.split(":").map helpers.trim
			key = key.toLowerCase().replace /\s+/g, '_'
			unless key in ["general_information", "local_options", "global_options"]
				info[key] = getvalue value
		info
