package lexer.cseries.compile.candcpp {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100117
	 */
	import lexer.cseries.compile.*;
	import util.*;
	
	public class CAndCppParser extends CompileParser {
		
		public function CAndCppParser(keywords:Array):void {
			super(keywords);
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
					//除号
					else {
						result.append(Character.SLASH);
					}
				}
				//双引号字符串
				else if (peek == Character.DOUBLE_QUOTE) {
					dealString(peek);
				}
				//单引号字符
				else if (peek == Character.SINGLE_QUOTE) {
					dealChar();
				}
				//处理头文件
				else if (peek == Character.SHARP) {
					dealHead();
				}
				//处理数字
				else if (Character.isDigitOrDecimal(peek)) {
					dealNumber();
				}
				//处理单词，美元符号或者字母或者下划线开头
				else if (Character.isIdentifiers(peek)) {
					dealWord();
				}
				//其它情况
				else {
					dealSign();
				}
			}
		}
		protected function dealHead():void {
			var start:int = index - 1;
			while (index <= code.length) {
				readch();
				//转义符
				if (peek == Character.BACK_SLASH) {
					readch();
				}
				//换行符退出
				else if (peek == Character.LINE) {
					break;
				}
			}
			result.append(HighLighter.head(HtmlEncode.encodeWithLine(code.slice(start, index - 1), getNewLine() + HighLighter.headStart())));
		}
	}
}