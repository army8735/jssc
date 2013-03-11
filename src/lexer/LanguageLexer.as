package lexer {
	/**
	 * ...
	 * @author army8735
	 */
	import lexer.match.*;
	import lexer.rule.*;
	import util.*;
	
	public class LanguageLexer implements ILexer {
		public static const IS_PERL_REG:int = 0;
		public static const NOT_PERL_REG:int = 1;
		public static const IGNORE:int = 2;
		public static const KEYWORD:int = 3;
		
		protected var rule:LanguageRule; //当前语法规则
		protected var code:String; //要解析的代码
		protected var peek:String; //向前看字符
		protected var index:int; //向前看字符字符索引
		protected var lastIndex:int; //上次peek索引
		protected var isPerlReg:int; //当前/是否是perl风格正则表达式
		protected var lanDepth:int; //生成最终结果时需要记录的行深度
		protected var tokens:Vector.<Token>; //结果的token列表
		protected var parentheseState:Boolean; //(开始时标记之前终结符是否为if/for/while等关键字
		protected var parentheseStack:Vector.<Boolean>; //圆括号深度记录当前是否为if/for/while等语句内部
		
		public function LanguageLexer(rule:LanguageRule) {
			this.rule = rule;
			peek = "";
			index = lastIndex = lanDepth = 0;
			isPerlReg = IS_PERL_REG;
			tokens = new Vector.<Token>();
			parentheseState = false;
			parentheseStack = new Vector.<Boolean>();
		}
		public static function getLexer(syntax:String):ILexer {
			switch(syntax.toLowerCase()) {
				case "js":
				case "javascript":
				case "ecmascript":
				case "jscript":
				case "as":
				case "as3":
				case "actionscript":
				case "actionscript3":
					return new LanguageLexer(new EcmascriptRule());
				case "java":
					return new LanguageLexer(new JavaRule());
				case "c":
				case "c++":
				case "cpp":
				case "cplusplus":
					return new LanguageLexer(new CRule());
				case "py":
				case "python":
					return new PythonLexer(new PythonRule());
				case "xml":
					return new XmlLexer();
				case "css":
					return new CssLexer(new CssRule());
				case "htm":
				case "html":
					return new HtmlLexer();
				case "php":
					return new PhpLexer();
				default:
					return new LanguageLexer(new UnknowRule());
			}
		}
		public function set depth(lanDepth:int):void {
			this.lanDepth = lanDepth;
		}
		
		public function parse(code:String):String {
			this.code = code;
			scan();
			return build();
		}
		
		protected function scan():void {
			var matchList:Vector.<IMatch> = rule.matchList,
				item:IMatch,
				length:int = code.length,
				perlReg:Boolean = rule.perlRegular;
			outer:
			while (index < length) {
				readch();
				//内嵌解析回车
				if (Character.LINE == peek) {
					tokens.push(new Token(Token.LINE, peek));
					lastIndex = index;
				}
				//内嵌解析空白
				else if (Character.isBlank(peek)) {
					dealBlank();
				}
				//内置解析数字
				else if (Character.isDigit(peek)) {
					dealNumber();
					//数字后/语义为除号
					if (perlReg) {
						isPerlReg = NOT_PERL_REG;
					}
				}
				//小数点开头在某些语言（如js）中也是合法的，表明是浮点数省略了整数部分的前导0
				else if (Character.DECIMAL == peek && Character.isDigit(code.charAt(index + 1))) {
					dealDecimal();
					tokens.push(new Token(Token.NUMBER, code.slice(lastIndex, index)));
					lastIndex = index;
					//数字后/语义为除号
					if (perlReg) {
						isPerlReg = NOT_PERL_REG;
					}
				}
				else {
					//依次遍历匹配规则，命中则继续
					for (var i:int = 0, len:int = matchList.length; i < len; i++) {
						item = matchList[i];
						if (item.start(peek) && item.match(code, index)) {
							tokens.push(new Token(item.tag, item.content));
							lastIndex = index += item.content.length - 1;
							//根据token的tag来确定/含义
							if (perlReg && item.perlReg != IGNORE) {
								if (item.perlReg == KEYWORD) {
									isPerlReg = rule.keyWords.hasKey(item.content) ? IS_PERL_REG : NOT_PERL_REG;
								}
								else {
									isPerlReg = item.perlReg;
								}
							}
							//特殊处理)对正则的影响，比如if(true)/reg/和(vars)/3
							if (perlReg) {
								if (item.tag == Token.ID) {
									//当为if/while/for等关键字时，将此深度下的(标记
									parentheseState = rule.keyWords.hasKey(item.content);
								}
								else if (peek == '(') {
									parentheseStack.push(parentheseState);
									parentheseState = false;
								}
								else if (peek == ')') {
									//if(true)/reg/情况下，)最后出栈查询到(之前是if，所以/号为正则开始
									isPerlReg = parentheseStack.pop() ? IS_PERL_REG : NOT_PERL_REG;
									parentheseState = false;
								}
								else {
									parentheseState = false;
								}
							}
							continue outer;
						}
					}
					//支持perl正则并且/含义是的时候
					if (perlReg && isPerlReg == IS_PERL_REG && peek == Character.SLASH) {
						dealPerlReg();
						tokens.push(new Token(Token.REGULAR, code.slice(lastIndex, index)));
						lastIndex = index;
						isPerlReg = NOT_PERL_REG;
					}
					//全没有匹配命中时，将积累下来的字符算作一种other类型
					else if (index > lastIndex) {
						tokens.push(new Token(Token.OTHER, code.slice(lastIndex, index)));
						lastIndex = index;
						//非单词符号后/都作为reg开头
						if (perlReg) {
							isPerlReg = IS_PERL_REG;
						}
					}
				}
			}
		}
		protected function readch():void {
			peek = code.charAt(index++);
		}
		protected function dealBlank():void {
			do {
				readch();
			}
			while (Character.isBlank(peek));
			tokens.push(new Token(Token.BLANK, code.slice(lastIndex, --index)));
			lastIndex = index;
		}
		protected function dealNumber():void {
			//以0开头需判断是否2、16进制
			if (peek == Character.ZERO) {
				readch();
				//0后面是x或者X为16进制
				if (Character.isX(peek)) {
					//寻找第一个非16进制字符
					do {
						readch();
					}
					while (Character.isDigit16(peek) || peek == Character.DECIMAL);
					tokens.push(new Token(Token.NUMBER, code.slice(lastIndex, --index)));
					lastIndex = index;
					return;
				}
				//0后面是b或者B为2进制
				else if (Character.isB(peek)) {
					//直到不是数字为止
					do {
						readch();
					}
					while (Character.isDigit2(peek));
					tokens.push(new Token(Token.NUMBER, code.slice(lastIndex, --index)));
					lastIndex = index;
					return;
				}
				//不是小数点跳出
				else if (peek != Character.DECIMAL) {
					tokens.push(new Token(Token.NUMBER, code.slice(lastIndex, --index)));
					lastIndex = index;
					return;
				}
			}
			//先处理整数部分
			else {
				do {
					readch();
				}
				while (Character.isDigit(peek) || peek == Character.UNDER_LINE);
				//整数后可能跟的类型L字母
				if (Character.isLong(peek)) {
					tokens.push(new Token(Token.NUMBER, code.slice(lastIndex, index)));
					lastIndex = index;
					return;
				}
			}
			//小数部分
			if (peek == Character.DECIMAL) {
				do {
					readch();
				}
				while (Character.isDigit(peek));
				//小数后可能跟的类型字母D、F
				if (Character.isFloat(peek) || Character.isDouble(peek)) {
					tokens.push(new Token(Token.NUMBER, code.slice(lastIndex, index)));
					lastIndex = index;
					return;
				}
			}
			//指数E
			if (Character.isExponent(peek)) {
				readch();
				//+-号
				if (peek == Character.ADD || peek == Character.MINUS) {
					readch();
				}
				//指数后面的数字
				while (Character.isDigit(peek)) {
					readch();
				}
			}
			tokens.push(new Token(Token.NUMBER, code.slice(lastIndex, --index)));
			lastIndex = index;
		}
		protected function dealDecimal():void {
			do {
				readch();
			}
			while (Character.isDigit(peek));
			//小数后可能跟的类型字母D、F
			if (Character.isFloat(peek) || Character.isDouble(peek)) {
				return;
			}
			//指数E
			if (Character.isExponent(peek)) {
				readch();
				//+-号
				if (peek == Character.ADD || peek == Character.MINUS) {
					readch();
				}
				//指数后面的数字
				while (Character.isDigit(peek)) {
					readch();
				}
			}
			index--;
		}
		protected function dealPerlReg():void {
			outer:
			do {
				readch();
				//转义符
				if (peek == Character.BACK_SLASH) {
					readch();
				}
				//[符号是字符集，里面可以省略\，同时可能出现正则结束标记/，
				else if (peek == Character.LEFT_BRACKET) {
					do {
						readch();
						//转义符
						if (peek == Character.BACK_SLASH) {
							readch();
						}
						//]括号
						else if (peek == Character.RIGHT_BRACKET) {
							continue outer;
						}
					}
					while (index < code.length);
				}
				//行末尾
				else if (peek == Character.LINE) {
					break;
				}
				//正则表达式/结束
				else if (peek == Character.SLASH) {
					//不是字母跳出，正则后的flag如i、g要被支持
					do {
						readch();
					}
					while (Character.isLetter(peek));
					break;
				}
			}
			while (index < code.length);
			index--;
		}
		
		protected function build():String {
			var res:String = '<li rel="0">';
			for (var i:int = 0, len:int = tokens.length; i < len; i++) {
				res += buildToken(tokens[i]);
			}
			return res + "</li>";
		}
		protected function buildToken(token:Token):String {
			if (rule != null && rule.lanDeps.length) {
				for (var i:int = 0, len:int = rule.lanDeps.length; i < len; i++) {
					if (rule.lanDeps[i].needCal(token.tag, token.value)) {
						lanDepth += rule.lanDeps[i].calDepth(token.value);
						break;
					}
				}
			}
			//依据不同类型进行高亮和encode
			switch(token.tag) {
				case Token.LINE:
					return '&nbsp;</li><li rel="' + lanDepth + '">';
				case Token.BLANK:
					return HtmlEncode.encode(token.value);
				case Token.NUMBER:
					return highLight(token.value, "num");
				case Token.COMMENT:
					return highLight(HtmlEncode.encode(token.value), "comment");
				case Token.STRING:
					return highLight(HtmlEncode.encode(token.value), "string");
				case Token.REGULAR:
					return highLight(HtmlEncode.encode(token.value), "reg");
				case Token.DEPTH:
					return highLight(HtmlEncode.encode(token.value), "depth");
				case Token.ID:
					if (rule.keyWords.hasKey(token.value)) {
						return highLight(token.value, "keyword");
					}
					else {
						return token.value;
					}
				case Token.KEY:
					return highLight(token.value, "keyword");
				case Token.ANNOT:
					return highLight(token.value, "annot");
				case Token.HEAD:
					return highLight(token.value, "head");
				case Token.ATTR:
					return highLight(token.value, "attr");
				case Token.CDATA:
					return highLight(HtmlEncode.encode(token.value), "cdata");
				case Token.MARK:
					return highLight(HtmlEncode.encode(token.value), "keyword");
				case Token.NS:
					return highLight(HtmlEncode.encode(token.value), "namespace");
				case Token.LOGICAL:
					return highLight(token.value, "logical");
				case Token.DECLARE:
					return highLight(HtmlEncode.encode(token.value), "declare");
				case Token.TEXT:
					return highLight(HtmlEncode.encode(token.value), "text");
				default:
					return HtmlEncode.encode(token.value);
			}
		}
		protected function highLight(s:String, cn:String):String {
			//此token可能包含换行符进行正则替换
			if (s.indexOf(Character.LINE) > -1) {
				s = s.replace(/\n/g, '</span>&nbsp;</li><li rel="' + (cn == "text" ? lanDepth : lanDepth + 1) + '"><span class="' + cn + '">');
			}
			return '<span class="' + cn + '">' + s + '</span>';
		}
	}

}