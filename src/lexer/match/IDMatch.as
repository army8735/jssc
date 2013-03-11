package lexer.match {
	/**
	 * ...
	 * @author army8735
	 */
	import lexer.*;
	
	public class IDMatch extends AbstractMatch {
		private var begin:String;
		private var body:RegExp;
		
		public function IDMatch(tokenTag:int, begin:String, body:RegExp, setPerlReg:int = LanguageLexer.IGNORE) {
			super(tokenTag, setPerlReg);
			this.begin = begin;
			this.body = body;
		}
		
		public override function start(char:String):Boolean {
			return begin.charAt(0) == char;
		}
		public override function match(code:String, index:int):Boolean {
			var res:Boolean = code.substr(--index, begin.length) == begin,
				i:int;
			//必须开头整个相符时才做查找
			if (res) {
				var arr:Array = body.exec(code.slice(index));
				if (arr) {
					result = arr[0];
				}
				else {
					return false;
				}
			}
			return res;
		}
		
	}

}