package lexer.cseries.compile.java {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100117
	 */
	import lexer.cseries.compile.*;
	import util.*;
	
	public class JavaParser extends CompileParser {
		
		public function JavaParser():void {
			var keywords:Array = "if else for break case continue function \
true false switch default do while int float double long throws transient \
abstract assert boolean byte class const enum instanceof try volatilechar \
extends final finally goto implements import protected return void char \
interface native new package private protected throw short public return \
strictfp super synchronized this static null String".split(" ");
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
				//@号java注释语法
				else if (peek == Character.AT) {
					dealAnnot();
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
		
		//java的注释语法
		private function dealAnnot():void {
			var start:int = index - 1;
			while (index <= code.length) {
				readch();
				//非字母数字跳出
				if (!Character.isLetterOrDigit(peek)) {
					break;
				}
			}
			//高亮
			result.append(HighLighter.annot(HtmlEncode.encode(code.slice(start, index))));
			readch();
		}
	}
}