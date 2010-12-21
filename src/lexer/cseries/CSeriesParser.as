package lexer.cseries {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100117
	 */
	import lexer.*;
	import util.*;
	
	public class CSeriesParser extends AbstractParser {
		
		public function CSeriesParser(keywords:Array):void	{
			super(keywords);
		}
		
		//字符串处理，单引号或多引号、是否允许转义折行
		protected function dealString(char:String = "\"", wrap:Boolean = false):void {
			var start:int = index - 1;
			while (index <= code.length) {
				readch();
				//转义符
				if (peek == Character.BACK_SLASH) {
					readch();
					//不允许转义换行跳出
					if (!wrap && peek == Character.LINE) {
						break;
					}
				}
				//行末尾未转义换行或找到结束跳出
				else if (peek == char || peek == Character.LINE) {
					break;
				}
			}
			//高亮
			result.append(HighLighter.string(HtmlEncode.encodeWithLine(code.slice(start, index), getNewLine() + HighLighter.stringStart())));
			readch();
		}
		//处理单行注释
		protected function dealSingleComment():void {
			var end:int = code.indexOf("\n", index);
			index -= 2;
			//找不到换行符说明是最后一行
			if (end == -1) {
				end = code.length;
			}
			//本行存入
			result.append(HighLighter.comment(HtmlEncode.encode(code.slice(index, end))));
			index = end;
			readch();
		}
		//处理多行注释
		protected function dealMultiComment():void {
			depth++;
			var end:int = code.indexOf("*/", index);
			index -= 2;
			//i为-1时直接注释到结尾
			if (end == -1) {
				end = code.length;
			}
			else {
				end += 2;
			}
			result.append(HighLighter.comment(HtmlEncode.encodeWithLine(code.slice(index, end), getNewLine() + HighLighter.commentStart())));
			//调整索引和深度，并读取当前peek
			index = end;
			depth--;
			readch();
		}
		//处理符号同时要计算深度
		protected override function dealSign():void {
			if (peek == Character.LEFT_BRACE) {
				depth++;
			}
			else if (peek == Character.RIGHT_BRACE) {
				depth--;
			}
			super.dealSign();
		}
	}
}