package lexer.match {
	/**
	 * ...
	 * @author army8735
	 */
	import util.*;
	import lexer.*;
	
	public class LinearParse extends AbstractMatch {
		private var begin:String;
		private var end:String;
		private var needEscape:Boolean;
		
		public function LinearParse(tokeyType:int, begin:String, end:String, needEscape:Boolean = true, setPerlReg:int = LanguageLexer.IGNORE) {
			super(tokeyType, setPerlReg);
			this.begin = begin;
			this.end = end;
			this.needEscape = needEscape;
		}
		
		public override function start(char:String):Boolean {
			return begin == char;
		}
		public override function match(code:String, index:int):Boolean {
			var i:int =  index - 1,
				len:int = code.length,
				c:String;
			while (index < len) {
				c = code.charAt(index++);
				//反斜线需要转义时注意
				if (needEscape && Character.BACK_SLASH == c) {
					c = code.charAt(index++);
					continue;
				}
				if (c == end) {
					break;
				}
			}
			result = code.slice(i, index);
			return true;
		}
		
	}

}