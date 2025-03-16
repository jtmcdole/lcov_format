const kDarkPlus = r'''{
	"name": "Dark+",
	"include": "./dark_vs.json",
	"settings": [
		{
			"name": "Function declarations",
			"scope": [
				"entity.name.function",
				"support.function"
			],
			"settings": {
				"foreground": "#DCDCAA"
			}
		},
		{
			"name": "Types declaration and references",
			"scope": [
				"meta.return-type",
				"support.class",
				"support.type",
				"entity.name.type",
				"entity.name.class",

				"storage.type.cs",
				"storage.type.generic.cs",
				"storage.type.modifier.cs",
				"storage.type.variable.cs",

				"storage.type.annotation.java",
				"storage.type.generic.java",
				"storage.type.java",
				"storage.type.object.array.java",
				"storage.type.primitive.array.java",
				"storage.type.primitive.java",
				"storage.type.token.java",

				"storage.type.groovy",
				"storage.type.annotation.groovy",
				"storage.type.parameters.groovy",
				"storage.type.generic.groovy",
				"storage.type.object.array.groovy",
				"storage.type.primitive.array.groovy",
				"storage.type.primitive.groovy"
			],
			"settings": {
				"foreground": "#4EC9B0"
			}
		},
		{
			"name": "Types declaration and references, TS grammar specific",
			"scope": [
				"meta.return.type",
				"meta.type.cast.expr",
				"meta.type.new.expr",
				"support.constant.math",
				"support.constant.dom",
				"support.constant.json"
			],
			"settings": {
				"foreground": "#4EC9B0"
			}
		},
		{
			"name": "Control flow keywords",
			"scope": "keyword.control",
			"settings": {
				"foreground": "#C586C0"
			}
		},
		{
			"name": "Variable and parameter name",
			"scope": [
				"variable",
				"meta.definition.variable.name",
				"support.variable"
			],
			"settings": {
				"foreground": "#9CDCFE"
			}
		},
		{
			"name": "Object keys, TS grammar specific",
			"scope": [
				"meta.object-literal.key",
				"meta.object-literal.key entity.name.function"
			],
			"settings": {
				"foreground": "#9CDCFE"
			}
		},
		{
			"name": "CSS property value",
			"scope": [
				"constant.other.color.rgb-value.css",
				"constant.other.rgb-value.css",
				"meta.property-value.css support.function",
				"meta.property-value.css support",

				"constant.numeric.color.rgb-value.scss",
				"constant.rgb-value.scss",
				"meta.property-value.scss support.function",
				"meta.property-value.scss support"
			],
			"settings": {
				"foreground": "#CE9178"
			}
		}
	]
}''';
