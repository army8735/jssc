package lexer.cseries.compile {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100117
	 */
	import lexer.cseries.*;
	import util.*;
	
	public class CompileParser extends CSeriesParser {
		
		public function CompileParser(kewywords:Array):void {
			super(kewywords);
		}
		
		protected function dealChar():void {
			var start:int = index - 1;
			readch();
			//转义符多读入一个字符
			if (peek == Character.BACK_SLASH) {
				readch();
			}
			//字符单引号结尾
			if (peek == Character.SINGLE_QUOTE) {
				readch();
			}
			//高亮
			result.append(HighLighter.string(HtmlEncode.encode(code.slice(start, index))));
			readch();
		}
		protected function dealWord():void {
			var start:int = index - 1;
			//直到不是字母数字下划线为止
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
	}
}