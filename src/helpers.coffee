{createHash} = require "crypto"
{assign,  indexBy} = require "lodash"
module.exports = helpers =
	assign: assign
	indexBy: indexBy
	identity: (a) -> a

	md5sum: (value) ->
		md5 = createHash "md5"
		md5.update value
		md5.digest 'hex'
	isNumeric: (v) -> "#{parseFloat v}" is "#{v}"
	trim: (s) -> s.replace /(^\s+|\s+$)/g, ''
	lines: (txt, filter=helpers.identity) ->
		(line for line in ("#{txt}").split(/\r\n?|\n\r?/) when filter line)
	parseinfo: (txt) ->

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
			key = key.replace /\s+/g, '-'
			unless key in ["general-information", "local-options", "global-options"]
				info[key] = getvalue value
		info


