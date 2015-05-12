{indexBy} = require "lodash"

module.exports = types = [
	{

		name: "function()"
		id: 7
		type:"function"
	}
	{

		name: "node()"
		id: 8
		type:"node"
	}
	{

		name: "text()"
		id: 9
		type:"node"
	}
	{

		name: "processing-instruction()"
		id: 10
		type:"node"
	}
	{

		name: "element()"
		id: 11
		type:"node"
	}
	{

		name: "document-node()"
		id: 12
		type:"node"
	}
	{

		name: "document-node(element())"
		id: 13
		type:"node"
	}
	{

		name: "attribute()"
		id: 14
		type:"node"
	}
	{

		name: "comment()"
		id: 15
		type:"node"
	}
	{

		name: "item()"
		id: 32
		type:"atomic value"
	}
	{

		name: "xs:untyped"
		id: 33
		type:"atomic value"
	}
	{

		name: "xs:anyType"
		id: 34
		type:"atomic value"
	}
	{

		name: "xs:anySimpleType"
		id: 35
		type:"atomic value"
	}
	{

		name: "xs:anyAtomicType"
		id: 36
		type:"atomic value"
	}
	{

		name: "xs:untypedAtomic"
		id: 37
		type:"atomic value"
	}
	{

		name: "xs:string"
		id: 38
		type:"atomic value"
	}
	{

		name: "xs:normalizedString"
		id: 39
		type:"atomic value"
	}
	{

		name: "xs:token"
		id: 40
		type:"atomic value"
	}
	{

		name: "xs:language"
		id: 41
		type:"atomic value"
	}
	{

		name: "xs:NMTOKEN"
		id: 42
		type:"atomic value"
	}
	{

		name: "xs:Name"
		id: 43
		type:"atomic value"
	}
	{

		name: "xs:NCName"
		id: 44
		type:"atomic value"
	}
	{

		name: "xs:ID"
		id: 45
		type:"atomic value"
	}
	{

		name: "xs:IDREF"
		id: 46
		type:"atomic value"
	}
	{

		name: "xs:ENTITY"
		id: 47
		type:"atomic value"
	}
	{

		name: "xs:float"
		id: 48
		type:"atomic value"
	}
	{

		name: "xs:double"
		id: 49
		type:"atomic value"
	}
	{

		name: "xs:decimal"
		id: 50
		type:"atomic value"
	}
	{

		name: "xs:precisionDecimal"
		id: 51
		type:"atomic value"
	}
	{

		name: "xs:integer"
		id: 52
		type:"atomic value"
	}
	{

		name: "xs:nonPositiveInteger"
		id: 53
		type:"atomic value"
	}
	{

		name: "xs:negativeInteger"
		id: 54
		type:"atomic value"
	}
	{

		name: "xs:long"
		id: 55
		type:"atomic value"
	}
	{

		name: "xs:int"
		id: 56
		type:"atomic value"
	}
	{

		name: "xs:short"
		id: 57
		type:"atomic value"
	}
	{

		name: "xs:byte"
		id: 58
		type:"atomic value"
	}
	{

		name: "xs:nonNegativeInteger"
		id: 59
		type:"atomic value"
	}
	{

		name: "xs:unsignedLong"
		id: 60
		type:"atomic value"
	}
	{

		name: "xs:unsignedInt"
		id: 61
		type:"atomic value"
	}
	{

		name: "xs:unsignedShort"
		id: 62
		type:"atomic value"
	}
	{

		name: "xs:unsignedByte"
		id: 63
		type:"atomic value"
	}
	{

		name: "xs:positiveInteger"
		id: 64
		type:"atomic value"
	}
	{

		name: "xs:duration"
		id: 65
		type:"atomic value"
	}
	{

		name: "xs:yearMonthDuration"
		id: 66
		type:"atomic value"
	}
	{

		name: "xs:dayTimeDuration"
		id: 67
		type:"atomic value"
	}
	{

		name: "xs:dateTime"
		id: 68
		type:"atomic value"
	}
	{

		name: "xs:dateTimeStamp"
		id: 69
		type:"atomic value"
	}
	{

		name: "xs:date"
		id: 70
		type:"atomic value"
	}
	{

		name: "xs:time"
		id: 71
		type:"atomic value"
	}
	{

		name: "xs:gYearMonth"
		id: 72
		type:"atomic value"
	}
	{

		name: "xs:gYear"
		id: 73
		type:"atomic value"
	}
	{

		name: "xs:gMonthDay"
		id: 74
		type:"atomic value"
	}
	{

		name: "xs:gDay"
		id: 75
		type:"atomic value"
	}
	{

		name: "xs:gMonth"
		id: 76
		type:"atomic value"
	}
	{

		name: "xs:boolean"
		id: 77
		type:"atomic value"
	}
	{

		name: "basex:binary"
		id: 78
		type:"atomic value"
	}
	{

		name: "xs:base64Binary"
		id: 79
		type:"atomic value"
	}
	{

		name: "xs:hexBinary"
		id: 80
		type:"atomic value"
	}
	{

		name: "xs:anyURI"
		id: 81
		type:"atomic value"
	}
	{

		name: "xs:QName"
		id: 82
		type:"atomic value"
	}
	{

		name: "xs:NOTATION"
		id: 83
		type:"atomic value"
	}
]

types.byId = indexBy types, "id"
types.byName = indexBy types, "name"