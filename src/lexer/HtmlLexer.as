package lexer {
	/**
	 * ...
	 * @author army8735
	 */
	import lexer.rule.*;
	import util.*;
	
	public class HtmlLexer extends XmlLexer {
		protected static const CSS:int = 2;
		protected static const JS:int = 3;
		
		protected var keywords:HashMap;
		protected var auto:HashMap;
		
		protected var css:Boolean;
		protected var js:Boolean;
		protected var autoClose:Boolean;
		
		public function HtmlLexer() {
			super();
			css = js = autoClose = false;
			
			keywords = new HashMap("a abbr acronym address applet b bdo big blockquote body \
button caption center cite code dd del dfn dir div dl dt em fieldest font form frameset h1 \
h2 h3 h4 h5 h6 head html i iframe ins kbd label legend li map menu noframes noscript object \
ol optgroup option p pre q s samp script select small span strike strong style sub sup table \
tbody td textarea tfoot th thead title tr tt u embed ul var public br hr col img area base \
link meta frame input param isindex basefont colgroup article aside audio canvas command \
datagrid datalist datatemplate details dialog embed event - source figure footer header m \
meter nav nest output progress rule section source time video".split(" "));
			auto = new HashMap("br hr col img area base link meta frame input param isindex \
basefont colgroup".split(" "));
		}
		
		protected override function scanState(length:int):void {
			switch(state) {
				case CSS:
					dealCss(length);
				break;
				case JS:
					dealJs(length);
				break;
				default:
					super.scanState(length);
				break;
			}
		}
		protected override function dealRightAngleBracket():void {
			super.dealRightAngleBracket();
			if (css) {
				state = CSS;
			}
			else if (js) {
				state = JS;
			}
		}
		protected override function dealTag():void {
			var temp:int = index;
			do {
				readch();
			}
			while (Character.isLetterOrDigit(peek) || peek == Character.UNDER_LINE || peek == Character.MINUS || peek == Character.COLON);
			var tag:String = code.slice(temp, index - 1).toLowerCase();
			if (keywords.hasKey(tag)) {
				if (peek != Character.RIGHT_ANGLE_BRACE) {
					state = MARK;
					if (tag == "style" || tag == "STYLE") {
						css = true;
					}
					else if (tag == "script" || tag == "SCRIPT") {
						js = true;
					}
				}
				else {
					if (code.charAt(lastIndex + 1) != Character.SLASH) {
						if (tag == "style" || tag == "STYLE") {
							state = CSS;
						}
						else if (tag == "script" || tag == "SCRIPT") {
							state = JS;
						}
					}
				}
				tokens.push(new Token(Token.MARK, code.slice(lastIndex, index)));
			}
			else {
				tokens.push(new Token(Token.OTHER, code.slice(lastIndex, index)));
			}
			lastIndex = index;
		}
		protected function dealCss(length:int):void {
			index = code.indexOf("</style>", index);
			if (index == -1) {
				index = code.indexOf("</STYLE>", index);
			}
			if (index == -1) {
				index = code.length;
			}
			tokens.push(new Token(Token.EMBED_CSS, code.slice(lastIndex, index)));
			lastIndex = index;
			state = TEXT;
			css = false;
		}
		protected function dealJs(length:int):void {
			index = code.indexOf("</script>", index);
			if (index == -1) {
				index = code.indexOf("</SCRIPT>", index);
			}
			if (index == -1) {
				index = code.length;
			}
			tokens.push(new Token(Token.EMBED_JS, code.slice(lastIndex, index)));
			lastIndex = index;
			state = TEXT;
			js = false;
		}
		protected override function buildToken(token:Token):String {
			if (token.tag == Token.EMBED_CSS) {
				var cssLexer:CssLexer = new CssLexer(new CssRule());
				cssLexer.depth = lanDepth;
				return cssLexer.parse(token.value).slice(12, -5);
			}
			else if (token.tag == Token.EMBED_JS) {
				var jsLexer:LanguageLexer = new LanguageLexer(new EcmascriptRule());
				jsLexer.depth = lanDepth;
				return jsLexer.parse(token.value).slice(12, -5);
			}
			else {
				return super.buildToken(token);
			}
		}
		protected override function highLight(s:String, cn:String):String {
			if (cn == "keyword") {
				if (Character.isLetter(s.charAt(4))) {
					var tag:String = s.slice(4, -6).toLowerCase();
					if (tag.length && auto.hasKey(tag)) {
						autoClose = true;
					}
					else {
						autoClose = false;
					}
				}
				else if (s == Character.RIGHT_ANGLE_BRACE && autoClose) {
					lanDepth--;
				}
			}
			return super.highLight(s, cn);
		}
		
	}

}