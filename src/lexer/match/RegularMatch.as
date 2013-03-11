package lexer.match {
	/**
	 * ...
	 * @author army8735
	 */
	import lexer.*;
	 
	public class RegularMatch extends AbstractMatch {
		private var begin:RegExp;
		private var body:RegExp;
		
		public function RegularMatch(tokenTag:int, begin:RegExp, body:RegExp, setPerlReg:int = LanguageLexer.IGNORE) {
			super(tokenTag, setPerlReg);
			this.begin = begin;
			this.body = body;
		}
		
		public override function start(char:String):Boolean {
			return begin.test(char);
		}
		public override function match(code:String, index:int):Boolean {
			var res:Object = body.exec(code.slice(--index));
			if (res) {
				result = res[0];
			}
			return res != null;
		}
		
	}

}