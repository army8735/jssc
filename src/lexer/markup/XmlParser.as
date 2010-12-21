package lexer.markup {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100121
	 */
	import lexer.*;
	import util.*;
	
	public class XmlParser extends MarkupParser	{
		private var auto:Boolean; //当前html节点是否为自闭合标签
		
		public function XmlParser():void {
			super([]);
			auto = false;
		}
		
		protected override function scan():void {
			var start:int = 0;
			readch();
			while (index <= code.length) {
				//处理空白
				dealBlank();
				//根据不同状态来分析代码
				switch(state) {
					case TEXT:
						start = index - 1;
						index = code.indexOf("<", start);
						//处理<之前的文本部分
						if (index == -1) {
							result.append(HtmlEncode.encodeWithLine(code.slice(start), getNewLine()));
							return;
						}
						else if (index > start) {
							result.append(HtmlEncode.encodeWithLine(code.slice(start, index), getNewLine()));
						}
						readch();
						//分析xml标签
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
				}
			}
		}
		
		private function dealLeftAngleBracket():void {
			readch();
			//<!
			if (peek == Character.EXCLAMATION) {
				//<!--
				if (code.substr(index, 2) == "--") {
					index -= 2;
					dealComment();
				}
				//<!DOCTYPE
				else if (code.substr(index, 7).toLowerCase() == "doctype") {
					result.append(HighLighter.keyword(HtmlEncode.encode(code.substr(index - 2, 9))));
					index += 7;
					state = MARK;
					auto = true;
					readch();
				}
				//cdata
				else if (code.substr(index, 7).toLowerCase() == "[cdata[") {
					dealCdata();
				}
				else {
					result.append(HtmlEncode.LESS + "!");
					readch();
				}
			}
			//<?
			else if (peek == Character.QUESTION) {
				dealQuestion();
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
			//直到非数字字母-为止
			do {
				readch();
			}
			while (Character.isLetterOrDigit(peek) || peek == Character.MINUS || peek == Character.COLON);
			var res:String = code.slice(start, index - 1);
			//高亮
			res = HighLighter.keyword(HtmlEncode.LESS + res);
			state = MARK;
			depth++;
			result.append(res);
		}
		private function dealEndWord():void {
			var start:int = index;
			//直到非数字字母为止
			do {
				readch();
			}
			while (Character.isLetterOrDigit(peek) || peek == Character.MINUS || peek == Character.COLON);
			var res:String = code.slice(start, index - 1);
			//高亮
			if (peek == Character.RIGHT_ANGLE_BRACE) {
				res = HighLighter.keyword(HtmlEncode.LESS + "/" + res + ">");
				readch();
				state = TEXT;
				depth--;
			}
			else {
				res = HtmlEncode.LESS + "/" + res;
			}
			result.append(res);
		}
		private function dealAttr():void {
			var start:int = index - 1;
			//直到非字母横线为止
			do {
				readch();
			}
			while (Character.isLetterOrDigit(peek) || peek == Character.MINUS);
			//高亮
			var res:String;
			if (peek == Character.COLON) {
				res = HighLighter.ns(code.slice(start, index - 1));
			}
			else {
				res = HighLighter.attr(code.slice(start, index - 1));
			}
			result.append(res);
		}
		private function dealQuestion() {
			var i:int = code.indexOf("?>", index);
			index -= 2;
			if (i == -1) {
				i = code.length;
			}
			else {
				i += 2;
			}
			result.append(HighLighter.head(HtmlEncode.encodeWithLine(code.slice(index, i), getNewLine() + HighLighter.headStart())));
			index = i;
			readch();
		}
		private function dealCdata() {
			depth++;
			var i:int = code.indexOf("]]>", index + 7);
			index -= 2;
			if (i == -1) {
				i = code.length;
			}
			else {
				i += 3;
			}
			result.append(HighLighter.cdata(HtmlEncode.encodeWithLine(code.slice(index, i), getNewLine() + HighLighter.cdataStart())));
			index = i;
			depth--;
			readch();
		}
	}
}