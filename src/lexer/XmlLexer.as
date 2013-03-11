package lexer {
	/**
	 * ...
	 * @author army8735
	 */
	import util.*;
	
	public class XmlLexer extends LanguageLexer {
		protected static const TEXT:int = 0;
		protected static const MARK:int = 1;
		protected var state:int;
		
		public function XmlLexer() {
			super(null);
			state = TEXT;
		}
		
		protected override function scan():void {
			var length:int = code.length;
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
					tokens.push(new Token(Token.BLANK, code.slice(lastIndex, index)));
					lastIndex = index;
				}
				else {
					scanState(length);
				}
			}
		}
		protected function scanState(length:int):void {
			switch(state) {
				case TEXT:
					index = code.indexOf("<", lastIndex);
					//以text结束，虽然一般并不常见
					if (index == -1) {
						tokens.push(new Token(Token.TEXT, code.slice(lastIndex)));
						lastIndex = index = length;
						return;
					}
					//寻找到<号，先缓存前面的text
					else if(index > lastIndex) {
						tokens.push(new Token(Token.TEXT, code.slice(lastIndex, index)));
					}
					//读取<之后的字符进行判断分析
					lastIndex = index;
					readch();
					dealLeftAngleBracket();
				break;
				case MARK:
					//单双引号，无需考虑转义
					if (Character.isQuote(peek)) {
						index = code.indexOf(peek, index);
						if (index == -1) {
							index = code.length;
						}
						else {
							index++;
						}
						tokens.push(new Token(Token.STRING, code.slice(lastIndex, index)));
						lastIndex = index;
					}
					//结束符/>
					else if (peek == Character.SLASH && code.charAt(index) == Character.RIGHT_ANGLE_BRACE) {
						tokens.push(new Token(Token.MARK, "/>"));
						lastIndex = ++index;
						state = TEXT;
					}
					//结束符>
					else if (peek == Character.RIGHT_ANGLE_BRACE) {
						dealRightAngleBracket();
					}
					//单词
					else if (Character.isLetter(peek)) {
						dealAttr();
					}
					//数字
					else if (Character.isDigit(peek)) {
						while (Character.isDigit(peek)) {
							readch();
						}
						tokens.push(new Token(Token.NUMBER, code.slice(lastIndex, index)));
						lastIndex = index;
					}
					//其它情况
					else {
						tokens.push(new Token(Token.OTHER, peek));
						lastIndex = index;
					}
				break;
			}
		}
		protected function dealLeftAngleBracket():void {
			//假如是<!--注释
			if (code.substr(index, 3) == "!--") {
				index = code.indexOf("-->", index + 3);
				if (index == -1) {
					index = code.length;
				}
				else {
					index += 3;
				}
				tokens.push(new Token(Token.COMMENT, code.slice(lastIndex, index)));
				lastIndex = index;
			}
			//特殊的<!DOCTYPE
			else if (code.substr(index, 8).toLowerCase() == "!doctype") {
				index += 8;
				tokens.push(new Token(Token.MARK, code.slice(lastIndex, index)));
				lastIndex = index;
				state = MARK;
			}
			//cdata
			else if (code.substr(index, 8).toLowerCase() == "![cdata[") {
				dealCdata();
			}
			//<?
			else if (code.charAt(index) == Character.QUESTION) {
				readch();
				dealQuestion();
			}
			//</
			else if (code.charAt(index) == Character.SLASH) {
				readch();
				dealTag();
			}
			//跟字母则是tag
			else if (Character.isLetter(code.charAt(index))) {
				dealTag();
			}
			//其它情况，它只是一个忘了转义的<符号
			else {
				tokens.push(new Token(Token.OTHER, "<"));
				lastIndex = index;
			}
		}
		protected function dealRightAngleBracket():void {
			tokens.push(new Token(Token.MARK, peek));
			lastIndex = index;
			state = TEXT;
		}
		protected function dealCdata() {
			index = code.indexOf("]]>", index + 8);
			if (index == -1) {
				index = code.length;
			}
			else {
				index += 3;
			}
			tokens.push(new Token(Token.CDATA, code.slice(lastIndex, index)));
			lastIndex = index;
		}
		protected function dealQuestion():void {
			index = code.indexOf("?>", index);
			if (index == -1) {
				index = code.length;
			}
			else {
				index += 2;
			}
			tokens.push(new Token(Token.DECLARE, code.slice(lastIndex, index)));
			lastIndex = index;
		}
		protected function dealTag():void {
			do {
				readch();
			}
			while (Character.isLetterOrDigit(peek) || peek == Character.UNDER_LINE || peek == Character.MINUS || peek == Character.COLON);
			if (peek != Character.RIGHT_ANGLE_BRACE) {
				state = MARK;
			}
			tokens.push(new Token(Token.MARK, code.slice(lastIndex, index)));
			lastIndex = index;
			
		}
		protected function dealAttr():void {
			do {
				readch();
			}
			while (Character.isLetterOrDigit(peek) || Character.UNDER_LINE == peek || Character.MINUS == peek);
			index--;
			//紧跟:号说明是命名空间
			if (Character.COLON == peek) {
				tokens.push(new Token(Token.NS, code.slice(lastIndex, index)));
			}
			else {
				tokens.push(new Token(Token.ATTR, code.slice(lastIndex, index)));
			}
			lastIndex = index;
		}
		protected override function highLight(s:String, cn:String):String {
			if (cn == "keyword") {
				if (s == "/>") {
					lanDepth--;
				}
				else if (s.indexOf("&lt;/") == 0) {
					lanDepth--;
				}
				else if (Character.isLetter(s.charAt(4))) {
					lanDepth++;
				}
			}
			return super.highLight(s, cn);
		}
		
	}

}