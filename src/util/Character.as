package util {
	/**
	 * ...
	 * @author army8735
	 */
	
	public class Character {
		public static const UNDER_LINE:String = "_";
		public static const ZERO:String = "0";
		public static const SLASH:String = "/";
		public static const BACK_SLASH:String = "\\";
		public static const SINGLE_QUOTE:String = "'";
		public static const DOUBLE_QUOTE:String = '"';
		public static const SPACE:String = " ";
		public static const TAB:String = "\t";
		public static const ENTER:String = "\r";
		public static const LINE:String = "\n";
		public static const LEFT_PARENTHESE:String = "(";
		public static const RIGHT_PARENTHESE:String = ")";
		public static const LEFT_BRACKET:String = "[";
		public static const RIGHT_BRACKET:String = "]";
		public static const LEFT_BRACE:String = "{";
		public static const RIGHT_BRACE:String = "}";
		public static const LEFT_ANGLE_BRACE:String = "<";
		public static const RIGHT_ANGLE_BRACE:String = ">";
		public static const STAR:String = "*";
		public static const EXCLAMATION:String = "!";
		public static const COLON:String = ":";
		public static const SEMICOLON:String = ";";
		public static const DECIMAL:String = ".";
		public static const DOLLAR:String = "$";
		public static const QUESTION:String = "?";
		public static const SHARP:String = "#";
		public static const AT:String = "@";
		public static const ADD:String = "+";
		public static const MINUS:String = "-";
		public static const PERCENT:String = "%";
		public static const AND:String = "&";
		public static const LESS:String = "<";
		
		public static function isDigit(c:String):Boolean {
			return c >= "0" && c <= "9";
		}
		public static function isDigit16(c:String):Boolean {
			return isDigit(c) || (c >= "a" && c <= "f") || (c >= "A" && c <= "F");
		}
		public static function isDigit2(c:String):Boolean {
			return c >= "0" && c <= "1";
		}
		public static function isDigitOrDecimal(c:String):Boolean {
			return isDigit(c) || c == DECIMAL;
		}
		public static function isLetter(c:String):Boolean {
			return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z");
		}
		public static function isLetterOrDigit(c:String):Boolean {
			return isLetter(c) || isDigit(c);
		}
		public static function isIdentifiers(c:String):Boolean {
			return isLetterOrDigit(c) || c == UNDER_LINE;
		}
		public static function isLong(c:String):Boolean {
			return c == "l" || c == "L";
		}
		public static function isFloat(c:String):Boolean {
			return c == "f" || c == "F";
		}
		public static function isDouble(c:String):Boolean {
			return c == "d" || c == "D";
		}
		public static function isX(c:String):Boolean {
			return c == "x" || c == "X";
		}
		public static function isB(c:String):Boolean {
			return c == "b" || c == "B";
		}
		public static function isBlank(c:String):Boolean {
			return c == SPACE || c == TAB;
		}
		public static function isExponent(c:String):Boolean {
			return c == "e" || c == "E";
		}
		public static function isQuote(c:String):Boolean {
			return c == DOUBLE_QUOTE || c == SINGLE_QUOTE;
		}
	}
}