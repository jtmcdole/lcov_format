const kLightVs = r'''{
	"name": "Light Visual Studio",
	"settings": [
		{
			"scope": "emphasis",
			"settings": {
				"fontStyle": "italic"
			}
		},
		{
			"scope": "strong",
			"settings": {
				"fontStyle": "bold"
			}
		},
		{
			"scope": "meta.diff.header",
			"settings": {
				"foreground": "#000080"
			}
		},

		{
			"scope": "comment",
			"settings": {
				"foreground": "#008000"
			}
		},

		{
			"scope": "constant.language",
			"settings": {
				"foreground": "#0000ff"
			}
		},
		{
			"scope": "constant.numeric",
			"settings": {
				"foreground": "#09885a"
			}
		},
		{
			"scope": "constant.regexp",
			"settings": {
				"foreground": "#811f3f"
			}
		},
		{
			"scope": [
				"constant.other.color.rgb-value.css",
				"constant.numeric.color.rgb-value.scss",
				"constant.other.rgb-value.css"
			],
			"settings": {
				"foreground": "#0451a5"
			}
		},
		{
			"name": "css tags in selectors, xml tags",
			"scope": "entity.name.tag",
			"settings": {
				"foreground": "#800000"
			}
		},
		{
			"scope": "entity.name.selector",
			"settings": {
				"foreground": "#800000"
			}
		},
		{
			"scope": "entity.other.attribute-name",
			"settings": {
				"foreground": "#ff0000"
			}
		},
		{
			"scope": [
				"entity.other.attribute-name.class.css",
				"entity.other.attribute-name.class.mixin.css",
				"entity.other.attribute-name.id.css",
				"entity.other.attribute-name.parent-selector.css",
				"entity.other.attribute-name.pseudo-class.css",
				"entity.other.attribute-name.pseudo-element.css",

				"source.css.less entity.other.attribute-name.id",

				"entity.other.attribute-name.attribute.scss",
				"entity.other.attribute-name.scss"
			],
			"settings": {
				"foreground": "#800000"
			}
		},
		{
			"scope": "invalid",
			"settings": {
				"foreground": "#cd3131"
			}
		},
		{
			"scope": "markup.underline",
			"settings": {
				"fontStyle": "underline"
			}
		},
		{
			"scope": "markup.bold",
			"settings": {
				"fontStyle": "bold",
				"foreground": "#000080"

			}
		},
		{
			"scope": "markup.heading",
			"settings": {
				"fontStyle": "bold",
				"foreground": "#800000"
			}
		},
		{
			"scope": "markup.italic",
			"settings": {
				"fontStyle": "italic"
			}
		},
		{
			"scope": "markup.inserted",
			"settings": {
				"foreground": "#09885a"
			}
		},
		{
			"scope": "markup.deleted",
			"settings": {
				"foreground": "#a31515"
			}
		},
		{
			"scope": "markup.changed",
			"settings": {
				"foreground": "#0451a5"
			}
		},
		{
			"scope": [
				"beginning.punctuation.definition.quote.markdown",
				"beginning.punctuation.definition.list.markdown"
			],
			"settings": {
				"foreground": "#0451a5"
			}
		},
		{
			"scope": "markup.inline.raw",
			"settings": {
				"foreground": "#800000"
			}
		},
		{
			"scope": "meta.selector",
			"settings": {
				"foreground": "#800000"
			}
		},
		{
			"name": "brackets of XML/HTML tags",
			"scope": "punctuation.definition.tag",
			"settings": {
				"foreground": "#800000"
			}
		},
		{
			"scope": "meta.preprocessor",
			"settings": {
				"foreground": "#0000ff"
			}
		},
		{
			"scope": "meta.preprocessor.string",
			"settings": {
				"foreground": "#a31515"
			}
		},
		{
			"scope": "meta.preprocessor.numeric",
			"settings": {
				"foreground": "#09885a"
			}
		},
		{
			"scope": "meta.structure.dictionary.key.python",
			"settings": {
				"foreground": "#0451a5"
			}
		},
		{
			"scope": "storage",
			"settings": {
				"foreground": "#0000ff"
			}
		},
		{
			"scope": "storage.type",
			"settings": {
				"foreground": "#0000ff"
			}
		},
		{
			"scope": "storage.modifier",
			"settings": {
				"foreground": "#0000ff"
			}
		},
		{
			"scope": "string",
			"settings": {
				"foreground": "#a31515"
			}
		},
		{
			"scope": [

				"string.comment.buffered.block.jade",
				"string.quoted.jade",
				"string.interpolated.jade",

				"string.unquoted.plain.in.yaml",
				"string.unquoted.plain.out.yaml",
				"string.unquoted.block.yaml",
				"string.quoted.single.yaml",

				"string.quoted.double.xml",
				"string.quoted.single.xml",
				"string.unquoted.cdata.xml",

				"string.quoted.double.html",
				"string.quoted.single.html",
				"string.unquoted.html",

				"string.quoted.single.handlebars",
				"string.quoted.double.handlebars"
			],
			"settings": {
				"foreground": "#0000ff"
			}
		},
		{
			"scope": "string.regexp",
			"settings": {
				"foreground": "#811f3f"
			}
		},
		{
			"name": "JavaScript string interpolation ${}",
			"scope": [
				"punctuation.definition.template-expression.begin.ts",
				"punctuation.definition.template-expression.end.ts"
			],
			"settings": {
				"foreground": "#0000ff"
			}
		},
		{
			"scope": [
				"support.property-value",
				"meta.property-value.css support",
				"meta.property-value.scss support"
			],
			"settings": {
				"foreground": "#0451a5"
			}
		},
		{
			"scope": [
				"support.type.property-name.css",
				"support.type.property-name.variable.css",
				"support.type.property-name.media.css",
				"support.type.property-name.less",
				"support.type.property-name.scss"
			],
			"settings": {
				"foreground": "#ff0000"
			}
		},
		{
			"scope": "support.type.property-name",
			"settings": {
				"foreground": "#0451a5"
			}
		},
		{
			"scope": "keyword",
			"settings": {
				"foreground": "#0000ff"
			}
		},
		{
			"scope": "keyword.control",
			"settings": {
				"foreground": "#0000ff"
			}
		},
		{
			"scope": "keyword.operator",
			"settings": {
				"foreground": "#000000"
			}
		},
		{
			"scope": ["keyword.operator.new", "keyword.operator.expression"],
			"settings": {
				"foreground": "#0000ff"
			}
		},
		{
			"scope": "keyword.other.unit",
			"settings": {
				"foreground": "#09885a"
			}
		},
		{
			"scope": [
				"punctuation.section.embedded.metatag.begin.php",
				"punctuation.section.embedded.metatag.end.php"
			],
			"settings": {
				"foreground": "#800000"
			}
		},
		{
			"scope": "support.function.git-rebase",
			"settings": {
				"foreground": "#0451a5"
			}
		},
		{
			"scope": "constant.sha.git-rebase",
			"settings": {
				"foreground": "#09885a"
			}
		},
		{
			"name": "coloring of the Java import and package identifiers",
			"scope": ["storage.modifier.import.java", "storage.modifier.package.java"],
			"settings": {
				"foreground": "#000000"
			}
		},
		{
			"name": "this.self",
			"scope": "variable.language",
			"settings": {
				"foreground": "#0000ff"
			}
		}
	]
}''';
