package lexer.markup {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100122
	 */
	import lexer.*;
	import lexer.cseries.other.*;
	import lexer.cseries.ecma.*;
	import util.*;
	
	public class HtmlParser extends MarkupParser {
		protected static const CSS:int = 2;
		protected static const JS:int = 3;
		
		private var autoWords:HashMap; //自闭合html节点关键字
		private var attributes:HashMap; //属性关键字
		
		private var auto:Boolean; //当前html节点是否为自闭合标签
		private var css:Boolean; //当前节点是否为style
		private var javascript:Boolean; //当前节点是否为js
		
		public function HtmlParser():void {
			var keywords:Array = "A ABBR ACRONYM ADDRESS APPLET B BDO BIG \
BLOCKQUOTE BODY BUTTON CAPTION CENTER CITE CODE \
DD DEL DFN DIR DIV DL DT EM FIELDEST FONT FORM \
FRAMESET H1 H2 H3 H4 H5 H6 HEAD HTML I IFRAME INS \
KBD LABEL LEGEND LI MAP MENU NOFRAMES NOSCRIPT \
OBJECT OL OPTGROUP OPTION P PRE Q S SAMP SCRIPT \
SELECT SMALL SPAN STRIKE STRONG STYLE SUB SUP TABLE \
TBODY TD TEXTAREA TFOOT TH THEAD TITLE TR TT U EMBED \
UL VAR PUBLIC".split(" ");
			super(keywords);
			
			//无需关门的关键字
			keywords = "BR HR COL IMG AREA BASE LINK META FRAME INPUT PARAM ISINDEX BASEFONT COLGROUP".split(" ");
			autoWords = new HashMap(keywords);
			
			//属性
			keywords = "abbr accept-charset accept accesskey action align \
behavior bgcolor bgproperties border bordercolor bordercolordark alink alt \
bordercolorlight borderstyle buffer caption cellpadding cellspacing archive \
char charoff charset checked cite class classid clear code codebase axis \
codetype color cols colspan compact content contentType coords data vlink \
datetime declare defer dir direction disabled dynsrc encoding enctype \
errorPage extends face file flush for frame frameborder framespacing urn \
gutter headers height href hreflang hspace http-equiv icon id import \
info isErrorPage ismap isThreadSafe label language leftmargin link autoFlush \
longdesc loop lowsrc marginheight marginwidth maximizebutton maxlength \
media method methods minimizebutton multiple name nohref noresize background \
noshade nowrap object onabort onblur onchange onclick ondblclick width \
onerror onfocus onkeydown onkeypress onkeyup onload applicationname rows \
onmousemove onmouseout onmouseover onmouseup onreset onselect onsubmit \
onunload page param profile prompt property readonly rel onmousedown rev \
rowspan rules runat scheme scope scrollamount scrolldelay scrolling vrml \
selected session shape showintaskbar singleinstance size span src standby \
start style summary sysmenu tabindex target text title topmargin type wrap \
usemap valign value valuetype version vspace windowstate".split(" ");
			attributes = new HashMap(keywords);
			
			auto = css = javascript = false;
		}
		
		protected override function scan():void {
			var start:int = 0;
			readch();
			while (index <= code.length) {
				dealBlank();
				//根据不同状态来分析代码
				switch(state) {
					case TEXT:
						start = index - 1;
						index = code.indexOf("<", start);
						//处理<之前的文本部分，找不到<说明到了末尾
						if (index == -1) {
							result.append(HtmlEncode.encodeWithLine(code.slice(start), getNewLine()));
							return;
						}
						else if (index > start) {
							result.append(HtmlEncode.encodeWithLine(code.slice(start, index), getNewLine()));
						}
						readch();
						//分析html标签
						dealLeftAngleBracket();
					break;
					case MARK:
						//单双引号
						if (Character.isQuote(peek)) {
							dealString(peek);
						}
						//结束符/>
						else if (peek == Character.SLASH) {
							readch();
							if (peek == Character.RIGHT_ANGLE_BRACE) {
								result.append(HighLighter.keyword("/>"));
								state = TEXT;
								//非自闭合标签深度--
								if (!auto) {
									depth--;
								}
							}
							else {
								result.append("/");
							}
							auto = false;
							readch();
						}
						//结束符>
						else if (peek == Character.RIGHT_ANGLE_BRACE) {
							result.append(HighLighter.keyword(">"));
							readch();
							state = TEXT;
							auto = false;
							//css和js
							if (css) {
								state = CSS;
							}
							else if (javascript) {
								state = JS;
							}
						}
						//单词
						else if (Character.isLetter(peek)) {
							dealAttr();
						}
						//数字
						else if (Character.isDigit(peek)) {
							dealNumber();
						}
						//其它情况编码此字符直接存入
						else {
							result.append(HtmlEncode.encodeChar(peek));
							readch();
						}
					break;
					case CSS:
						dealCss();
					break;
					case JS:
						dealJs();
					break;
				}
			}
		}
		
		protected function dealLeftAngleBracket():void {
			readch();
			//<!
			if (peek == Character.EXCLAMATION) {
				//<!--
				if (code.substr(index, 2) == "--") {
					index -= 2;
					dealComment();
				}
				//<!DOCTYPE
				else if (code.substr(index, 7).toUpperCase() == "DOCTYPE") {
					result.append(HighLighter.keyword(HtmlEncode.encode(code.substr(index - 2, 9))));
					index += 7;
					state = MARK;
					auto = true;
					readch();
				}
				else {
					result.append("&lt;!");
					readch();
				}
			}
			//闭合html标签</
			else if (peek == Character.SLASH) {
				dealEndWord();
			}
			//跟字母检查开始标签
			else if (Character.isLetter(peek)) {
				dealStartWord();
			}
			else {
				result.append(HtmlEncode.LESS + HtmlEncode.encodeChar(peek));
				readch();
			}
		}
		private function dealStartWord():void {
			var start:int = index - 1;
			//直到非数字字母为止
			do {
				readch();
			}
			while (Character.isLetterOrDigit(peek));
			var res:String = code.slice(start, index - 1);
			//普通html节点
			if(words.hasKey(res.toUpperCase())) {
				//css和js
				if (res.toUpperCase() == "STYLE") {
					css = true;
				}
				else if (res.toUpperCase() == "SCRIPT") {
					javascript = true;
				}
				//高亮
				res = HighLighter.keyword(HtmlEncode.LESS + res);
				state = MARK;
				depth++;
			}
			//自闭合节点
			else if (autoWords.hasKey(res.toUpperCase())) {
				res = HighLighter.keyword(HtmlEncode.LESS + res);
				state = MARK;
				auto = true;
			}
			else {
				res = HtmlEncode.LESS + res;
			}
			result.append(res);
		}
		private function dealEndWord():void {
			var start:int = index;
			//直到非数字字母为止
			do {
				readch();
			}
			while (Character.isLetterOrDigit(peek));
			var res:String = code.slice(start, index - 1);
			//是否为html关键字，并且要直接>闭合
			if (peek == Character.RIGHT_ANGLE_BRACE && words.hasKey(res.toUpperCase())) {
				result.append(HighLighter.keyword(HtmlEncode.LESS + "/" + res + ">"));
				readch();
				state = TEXT;
				depth--;
			}
			else {
				result.append(HtmlEncode.LESS + "/" + res);
			}
		}
		private function dealAttr():void {
			var start:int = index - 1;
			//直到非字母横线为止
			do {
				readch();
			}
			while (Character.isLetter(peek) || peek == Character.MINUS);
			//高亮，是否为属性
			var res:String = code.slice(start, index - 1);
			if (attributes.hasKey(res.toLowerCase())) {
				res = HighLighter.attr(res);
			}
			result.append(res);
		}
		private function dealCss():void {
			var start:int = index - 1, end:int;
			var tag:String;
			//找到第一个非注释中的</style>，忽略大小写，忽略字符串
			while (index <= code.length) {
				if (peek == Character.SLASH) {
					readch();
					//多行注释
					if (peek == Character.STAR) {
						end = code.indexOf("*/", index);
						if (end == -1) {
							end = code.length;
						}
						index = end;
					}
					//单行注释
					else if (peek == Character.SLASH) {
						end = code.indexOf("\n", index);
						if (end == -1) {
							end = code.length;
						}
						index = end;
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
					tag = code.substr(index - 1, 8).toLowerCase();
					if (tag == "</style>") {
						break;
					}
				}
				readch();
			}
			//高亮
			var cssParser:IEmbedParser = new CssParser();
			var res:String = cssParser.embedParse(code.slice(start, index - 1), depth);
			result.append(res);
			css = false;
			state = TEXT;
		}
		private function dealJs():void {
			var start:int = index - 1, end:int;
			var tag:String;
			var isPerlReg:Boolean = true;
			//找到第一个</script>，注意注释/字符串/正则等
			while (index <= code.length) {
				if (peek == Character.SLASH) {
					readch();
					//多行注释
					if (peek == Character.STAR) {
						end = code.indexOf("*/", index);
						if (end == -1) {
							end = code.length;
						}
						index = end + 2;
					}
					//单行注释
					else if (peek == Character.SLASH) {
						end = code.indexOf("\n", index);
						if (end == -1) {
							end = code.length;
						}
						index = end;
					}
					//正则
					else if (isPerlReg) {
						while (index <= code.length) {
							if (peek == Character.BACK_SLASH) {
								readch();
							}
							else if (peek == Character.SLASH) {
								break;
							}
							else if (peek == Character.LEFT_BRACKET) {
								while (index <= code.length) {
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
						isPerlReg = true;
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
						break;
					}
				}
				else if (Character.isIdentifiers(peek) || peek == Character.DOLLAR || peek == Character.RIGHT_PARENTHESE) {
					isPerlReg = false;
				}
				else {
					isPerlReg = true;
				}
				readch();
			}
			//高亮
			var javascriptParser:IEmbedParser = new JavascriptParser();
			var res:String = javascriptParser.embedParse(code.slice(start, index - 1), depth);
			result.append(res);
			javascript = false;
			state = TEXT;
		}
	}
}