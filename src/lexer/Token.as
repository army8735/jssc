package lexer {
	/**
	 * ...
	 * @author army8735
	 */
	public class Token {
		public static const OTHER:int = 0;
		public static const COMMENT:int = 1;
		public static const STRING:int = 2;
		public static const REGULAR:int = 3;
		public static const NUMBER:int = 4;
		public static const DEPTH:int = 5;
		public static const LINE:int = 6;
		public static const ID:int = 7;
		public static const TAB:int = 8;
		public static const BLANK:int = 9;
		public static const MARK:int = 10;
		public static const HEAD:int = 11;
		public static const NS:int = 12;
		public static const ATTR:int = 13;
		public static const CDATA:int = 14;
		public static const ANNOT:int = 15;
		public static const LOGICAL:int = 16;
		public static const DECLARE:int = 17;
		public static const TEXT:int = 18;
		public static const EMBED_CSS:int = 19;
		public static const EMBED_JS:int = 20;
		public static const EMBED_PHP:int = 21;
		public static const KEY:int = 22;
		
		private var tokenTag:int;
		private var tokenValue:String;
		
		public function Token(tokenTag:int, tokenValue:String) {
			this.tokenTag = tokenTag;
			this.tokenValue = tokenValue;
		}
		
		public function get tag():int {
			return tokenTag;
		}
		public function get value():String {
			return tokenValue;
		}
	}

}