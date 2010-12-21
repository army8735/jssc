package lexer.markup {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100117
	 */
	import lexer.*;
	import util.*;
	
	public class MarkupParser extends AbstractParser {
		protected static const TEXT:int = 0;
		protected static const MARK:int = 1;
		protected var state:int;
		
		public function MarkupParser(keywords:Array):void {
			super(keywords);
			state = TEXT;
		}
		
		protected function dealString(char:String = "\""):void {
			var start:int = index - 1;
			//寻找接下来的引号，无需考虑转义问题
			index = code.indexOf(char, index);
			if (index == -1) {
				index = code.length - 1;
			}
			index++;
			result.append(HighLighter.string(HtmlEncode.encodeWithLine(code.slice(start, index), getNewLine() + HighLighter.stringStart())));
			readch();
		}
		protected function dealComment():void {
			depth++;
			var end:int = code.indexOf("-->", index + 4);
			if (end == -1) {
				end = code.length - 3;
			}
			end += 3;
			result.append(HighLighter.comment(HtmlEncode.encodeWithLine(code.slice(index, end), getNewLine() + HighLighter.commentStart())));
			index = end;
			depth--;
			readch();
		}
	}
}