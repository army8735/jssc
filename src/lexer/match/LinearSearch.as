package lexer.match {
	/**
	 * ...
	 * @author army8735
	 */
	import lexer.*;
	
	public class LinearSearch extends AbstractMatch {
		private var begin:String;
		private var end:String;
		private var contain:Boolean;
		
		public function LinearSearch(tokenTag:int, begin:String, end:String, contain:Boolean = false, setPerlReg:int = LanguageLexer.IGNORE) {
			super(tokenTag, setPerlReg);
			this.begin = begin;
			this.end = end;
			this.contain = contain;
		}
		
		public override function start(char:String):Boolean {
			//线性查找模式允许设定start为字符串（非char），比较时以首个字符做检测
			return begin.charAt(0) == char;
		}
		public override function match(code:String, index:int):Boolean {
			var res:Boolean = code.substr(--index, begin.length) == begin,
				i:int;
			//必须开头整个相符时才做查找
			if (res) {
				i = code.indexOf(end, index + start.length);
				//没有找到end直接设为源代码结尾
				if (i == -1) {
					i = code.length;
				}
				//还要检查是否包括end
				else if (contain) {
					i += end.length;
				}
				result = code.slice(index, i);
			}
			return res;
		}
		
	}

}