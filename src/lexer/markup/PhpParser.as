package lexer.markup {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100122
	 */
	import lexer.*;
	import lexer.cseries.php.*;
	import util.*;
	
	public class PhpParser extends HtmlParser {
		static const PHP:int = 4;
		
		public function PhpParser():void {
			super();
		}
		
		protected override function dealLeftAngleBracket():void {
			readch();
			//发现<?
			if (peek == Character.QUESTION) {
				//<?php
				if (code.substr(index, 3).toLowerCase() == "php") {
					result.append(HighLighter.keyword(HtmlEncode.LESS + code.slice(index - 1, index + 3)));
					index += 3;
					dealPhp();
				}
				//或者短标记
				else if(!Character.isIdentifiers(code.charAt(index))) {
					result.append(HighLighter.keyword(HtmlEncode.LESS + "?"));
					dealPhp();
				}
				else {
					result.append(HtmlEncode.LESS + "?");
					readch();
				}
			}
			else {
				index--;
				super.dealLeftAngleBracket();
			}
		}
		private function dealPhp():void {
			readch();
			depth++;
			var start:int = index - 1, end:int;
			//寻找结束符?>
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
					var tag:String = peek;
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
				else if (peek == Character.QUESTION) {
					readch();
					//找到?>
					if (peek == Character.RIGHT_ANGLE_BRACE) {
						index--;
						break;
					}
				}
				readch();
			}
			var phpParser:IEmbedParser = new lexer.cseries.php.PhpParser();
			var res:String = phpParser.embedParse(code.slice(start, index - 1), depth);
			res += HighLighter.keyword("?>");
			index += 2;
			result.append(res);
			depth--;
		}
	}

}