package lexer.cseries.php {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100122
	 */
	import lexer.cseries.*;
	import lexer.*;
	import util.*;
	
	public class PhpParser extends CSeriesParser implements IEmbedParser {
		private var tag:String; //多行字符串tag
		
		public function PhpParser():void {
			var keywords:Array = "and or xor __FILE__ __LINE__ array as cfunction class \
const declare die elseif empty enddeclare endfor endforeach \
endif endswitch endwhile extends foreach include include_once \
global new old_function use require require_once var __FUNCTION__ \
__CLASS__ __METHOD__ abstract interface public implements extends \
private protected throw echo exit die".split(" ");
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
						result.append("/");
					}
				}
				//单双引号字符串
				else if (Character.isQuote(peek)) {
					dealString(peek);
				}
				//跨行字符串
				else if (peek == Character.LEFT_ANGLE_BRACE) {
					readch();
					if (peek == Character.LEFT_ANGLE_BRACE) {
						readch();
						if (peek == Character.LEFT_ANGLE_BRACE) {
							readch();
							dealMultiString();
						}
						else {
							result.append(HtmlEncode.LESS + HtmlEncode.LESS + peek);
						}
					}
					else {
						result.append(HtmlEncode.LESS + peek);
					}
				}
				//处理数字
				else if (Character.isDigitOrDecimal(peek)) {
					dealNumber();
				}
				//处理变量，美元符号开头
				else if (peek == Character.DOLLAR) {
					dealVal();
				}
				//处理单词，字母下划线开头
				else if (Character.isIdentifiers(peek)) {
					dealWord();
				}
				//其它情况
				else {
					dealSign();
				}
			}
		}
		
		private function dealVal():void {
			var start:int = index - 1;
			//非数字字母下划线跳出
			while (index <= code.length) {
				readch();
				if (!Character.isIdentifiers(peek)) {
					break;
				}
			}
			//高亮
			result.append(HighLighter.val(code.slice(start, index - 1)));
		}
		private function dealWord():void {
			var start:int = index - 1;
			//非数字字母下划线跳出
			while (index <= code.length) {
				readch();
				if (!Character.isIdentifiers(peek)) {
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
		//特殊的跨行字符串处理
		private function dealMultiString():void {
			depth++;
			var start:int = index - 4;
			//记录多行字符串标示符
			while (index <= code.length) {
				if (!Character.isIdentifiers(peek)) {
					break;
				}
				readch();
			}
			//寻找结束
			var tag:String = code.slice(start + 3, index - 1);
			var end:int = code.indexOf("\n" + tag, index);
			//高亮
			if (end == -1) {
				end = code.length;
			}
			else {
				end += tag.length + 1;
			}
			result.append(HighLighter.string(HtmlEncode.encodeWithLine(code.slice(start, end), getNewLine() + HighLighter.stringStart())));
			index = end;
			depth--;
			readch();
		}
		
		public function embedParse(code:String, depth:int):String {
			this.depth = depth;
			var res:String = parse(code);
			return res.slice(12, res.length - 5);
		}
	}
}