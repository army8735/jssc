package lexer.match {
	/**
	 * ...
	 * @author army8735
	 */
	import util.*;
	import lexer.*;
	
	public class CharacterSet extends AbstractMatch {
		public static const LETTER:int = 0;
		public static const UNDERLINE:int = 1;
		public static const DIGIT:int = 2;
		public static const DOLLAR:int = 3;
		public static const AT:int = 4;
		public static const SHARP:int = 5;
		public static const MINUS:int = 6;
		public static const DIGIT16:int = 7;
		
		private var begins:Array
		private var bodies:Array;
		
		public function CharacterSet(tokenType:int, begins:Array, bodies:Array, setPerlReg:int = LanguageLexer.IGNORE) {
			super(tokenType, setPerlReg);
			this.begins = begins;
			this.bodies = bodies;
		}
		
		public override function start(char:String):Boolean {
			var res:Boolean = false;
			for (var i:int = 0, len:int = begins.length; i < len; i++) {
				if (res) {
					break;
				}
				switch(begins[i]) {
					case LETTER:
						res = Character.isLetter(char);
					break;
					case UNDERLINE:
						res = Character.UNDER_LINE == char;
					break;
					case DIGIT:
						res = Character.isDigit(char);
					break;
					case DOLLAR:
						res = Character.DOLLAR == char;
					break;
					case AT:
						res = Character.AT == char;
					break;
					case SHARP:
						res = Character.SHARP == char;
					break;
					case MINUS:
						res = Character.MINUS == char;
					break;
					case DIGIT16:
						res = Character.isDigit16(char);
					break;
				}
			}
			if (res) {
				result = char;
			}
			return res;
		}
		public override function match(code:String, index:int):Boolean {
			var char:String,
				len2:int = code.length;
			while(index < len2) {
				char = code.charAt(index++);
				var res:Boolean = false;
				for (var i:int = 0, len:int = bodies.length; i < len; i++) {
					if (res) {
						break;
					}
					switch(bodies[i]) {
						case LETTER:
							res = Character.isLetter(char);
						break;
						case UNDERLINE:
							res = Character.UNDER_LINE == char;
						break;
						case DIGIT:
							res = Character.isDigit(char);
						break;
						case DOLLAR:
							res = Character.DOLLAR == char;
						break;
						case AT:
							res = Character.AT == char;
						break;
						case SHARP:
							res = Character.SHARP == char;
						break;
						case MINUS:
							res = Character.MINUS == char;
						break;
						case DIGIT16:
							res = Character.isDigit16(char);
						break;
					}
				}
				if (res) {
					result += char;
				}
				else {
					break;
				}
			}
			return true;
		}
		
	}

}