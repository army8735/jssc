package lexer.cseries.ecma {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100117
	 */
	import lexer.cseries.*;
	import util.*;
	
	public class EcmascriptParser extends CSeriesParser {
		private var isPerlReg:Boolean;
		
		public function EcmascriptParser(keywords:Array):void {
			super(keywords);
			isPerlReg = true;
		}
		
		protected override function scan():void {
			readch();
			while (index <= code.length) {
				//处理空白
				dealBlank();
				//除号检查注释
				if (peek == Character.SLASH) {
					readch();
					//单行注释
					if (peek == Character.SLASH) {
						dealSingleComment();
					}
					//多行注释
					else if (peek == Character.STAR) {
						dealMultiComment();
					}
					//除号或者perl风格正则
					else {
						//正则
						if (isPerlReg) {
							dealPerlReg();
							isPerlReg = true;
						}
						//除号
						else {
							result.append("/");
							isPerlReg = false;
						}
					}
				}
				//单双引号字符串
				else if (Character.isQuote(peek)) {
					dealString(peek, true);
					isPerlReg = true;
				}
				//处理数字
				else if (Character.isDigitOrDecimal(peek)) {
					dealNumber();
					isPerlReg = false;
				}
				//处理单词，美元符号或者字母或者下划线开头
				else if ( Character.isIdentifiers(peek) || peek == Character.DOLLAR) {
					dealWord();
					isPerlReg = false;
				}
				//其它情况
				else {
					if (peek == Character.RIGHT_PARENTHESE) {
						isPerlReg = false;
					}
					else {
						isPerlReg = true;
					}
					dealSign();
				}
			}
		}
		
		protected function dealWord():void {
			var start:int = index - 1;
			//直到不是字母数字下划线美元符号为止
			while (index <= code.length) {
				readch();
				if (!Character.isIdentifiers(peek) && peek != Character.DOLLAR) {
					break;
				}
			}
			//高亮
			var res:String = code.slice(start, index - 1);
			if (words.hasKey(res)) {
				res = HighLighter.keyword(res);
			}
			result.append(res);
		}
		//perl正则
		protected function dealPerlReg():void {
			var start:int = index - 2;
			outer:
			while (index <= code.length) {
				//转义符
				if (peek == Character.BACK_SLASH) {
					readch();
				}
				//[括号
				else if (peek == Character.LEFT_BRACKET) {
					while (index <= code.length) {
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
				}
				//行末尾
				else if (peek == Character.LINE) {
					break;
				}
				//正则表达式/结束
				else if (peek == Character.SLASH) {
					while (index <= code.length) {
						readch();
						//不是字母跳出
						if (!Character.isLetter(peek)) {
							break outer;
						}
					}
				}
				readch();
			}
			//高亮
			result.append(HighLighter.regular(HtmlEncode.encodeWithLine(code.slice(start, index - 1), getNewLine() + HighLighter.regStart())));
		}
	}
}