package lexer.match {
	/**
	 * ...
	 * @author army8735
	 */
	import lexer.*;
	
	public class AbstractMatch implements IMatch {
		private var tokenTag:int;
		private var setPerlReg:int;
		protected var result:String;
		
		public function AbstractMatch(tokenTag:int, setPerlReg:int) {
			this.tokenTag = tokenTag;
			this.setPerlReg = setPerlReg;
		}
		
		public function get content():String {
			return result;
		}
		public function get tag():int {
			return tokenTag;
		}
		public function start(char:String):Boolean {
			//需被子类覆盖
			return false;
		}
		public function match(code:String, index:int):Boolean {
			//需被子类覆盖
			return false;
		}
		public function get perlReg():int {
			return setPerlReg;
		}
		
	}

}