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
					if (tag == "style") {
						css = true;
					}
					else if (tag == "script") {
						js = true;
					}
				}
				else {
					if (code.charAt(lastIndex + 1) != Character.SLASH) {
						if (tag == "style") {
							state = CSS;
						}
						else if (tag == "script") {
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
			var tag:String;
			while (index <= length) {
				if (peek == Character.SLASH) {
					readch();
					//多行注释
					if (peek == Character.STAR) {
						index = code.indexOf("*/", index);
						if (index == -1) {
							index = code.length;
						}
						else {
							index += 2;
						}
					}
					//单行注释
					else if (peek == Character.SLASH) {
						index = code.indexOf("\n", index);
						if (index == -1) {
							index = code.length;
						}
					}
				}
				else if (Character.isQuote(peek)) {
					tag = peek;
					while (index <= code.length) {
						readch();
						//转义
						if (peek == Character.BACK_SLASH) {
							readch();
						}
						else if (peek == tag) {
							break;
						}
					}
				}
				else if (peek == Character.LEFT_ANGLE_BRACE) {
					if (code.substr(index, 6).toLowerCase() == "/style") {
						index--;
						break;
					}
				}
				readch();
			}
			tokens.push(new Token(Token.EMBED_CSS, code.slice(lastIndex, index)));
			lastIndex = index;
			state = TEXT;
			css = false;
		}
		protected function dealJs(length:int):void {
			parentheseState = false;
			parentheseStack = new Vector.<Boolean>();
			var isPerlReg:Boolean = true,
				tag:String;
			//找到第一个</script>，注意注释、字符串、正则等要忽略掉
			while (index <= length) {
				if (peek == Character.SLASH) {
					readch();
					//多行注释
					if (peek == Character.STAR) {
						index = code.indexOf("*/", index);
						if (index == -1) {
							index = code.length;
						}
						else {
							index += 2;
						}
					}
					//单行注释
					else if (peek == Character.SLASH) {
						index = code.indexOf("\n", index);
						if (index == -1) {
							index = code.length;
						}
					}
					//正则
					else if (isPerlReg) {
						while (index <= length) {
							if (peek == Character.BACK_SLASH) {
								readch();
							}
							else if (peek == Character.SLASH) {
								break;
							}
							else if (peek == Character.LEFT_BRACKET) {
								while (index <= length) {
									readch();
									if (peek == Character.BACK_SLASH) {
										readch();
									}
									else if (peek == Character.RIGHT_BRACKET) {
										break;
									}
								}
							}
							readch();
						}
						isPerlReg = false;
					}
					//除号
					else {
						isPerlReg = false;
					}
				}
				else if (Character.isQuote(peek)) {
					tag = peek;
					while (index <= code.length) {
						readch();
						//转义
						if (peek == Character.BACK_SLASH) {
							readch();
						}
						else if (peek == tag) {
							break;
						}
					}
					isPerlReg = true;
				}
				else if (peek == Character.LEFT_ANGLE_BRACE) {
					tag = code.substr(index, 8).toLowerCase();
					if (tag == "/script>") {
						index--;
						break;
					}
				}
				else if (peek == Character.LEFT_PARENTHESE) {
					parentheseStack.push(parentheseState);
					parentheseState = false;
				}
				else if (peek == Character.RIGHT_PARENTHESE) {
					isPerlReg = parentheseStack.pop();
					parentheseState = false;
				}
				else if (Character.isIdentifiers(peek) || peek == Character.DOLLAR) {
					var start:int = index - 1;
					while (index < length) {
						readch();
						if (!Character.isIdentifiers(peek) && peek != Character.DOLLAR && !Character.isDigit(peek)) {
							break;
						}
					}
					var ids:String = code.slice(start, --index);
					parentheseState = EcmascriptRule.KEYWORDS.indexOf(ids) != -1;
					isPerlReg = EcmascriptRule.KEYWORDS.indexOf(ids) != -1;
				}
				else if(!Character.isBlank(peek) && Character.LINE != peek) {
					isPerlReg = true;
				}
				readch();
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