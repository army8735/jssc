package lexer.match {
	/**
	 * ...
	 * @author army8735
	 */
	import lexer.*;
	 
	public class CompleteEqual extends AbstractMatch {
		
		public function CompleteEqual(tokenTag:int, result:String, setPerlReg:int = LanguageLexer.IGNORE) {
			super(tokenTag, setPerlReg);
			this.result = result;
		}
		
		public override function start(char:String):Boolean {
			return result.charAt(0) == char;
		}
		public override function match(code:String, index:int):Boolean {
			return code.substr(--index, result.length) == result;
		}
		
	}

}