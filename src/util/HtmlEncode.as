package util {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100117
	 */
	
	public class HtmlEncode	{
		public static const AND:String = "&amp;";
		public static const LESS:String = "&lt;";
		public static const BLANK:String = "&nbsp;";
		public static const TAB:String = "&nbsp;&nbsp;&nbsp;&nbsp;";
		public static const ESCAPE:String = "\\\\";
		
		static const CHARS:Array = [Character.AND, Character.TAB, Character.SPACE, Character.LESS];
		static const ESCAPES:Array = [AND, TAB, BLANK, LESS];
		
		public static function encodeChar(char:String):String {
			switch(char) {
				case Character.SPACE: return BLANK;
				case Character.TAB: return TAB;
				case Character.BACK_SLASH: return ESCAPE;
				case Character.AND: return AND;
				case Character.LESS: return LESS;
			}
			return char;
		}
		public static function encode(s:String):String {
			//遍历替换需encode的特殊html编码字符
			for (var i:int = 0; i < CHARS.length; i++) {
				if (s.indexOf(CHARS[i]) > -1) {
					s = s.replace(new RegExp(CHARS[i], "g"), ESCAPES[i]);
				}
			}
			//反斜线因产生正则表达式的原因特殊对待
			if (s.indexOf("\\") > -1) {
				s = s.replace(/\\/g, ESCAPE);
			}
			return s;
		}
		public static function encodeWithLine(s:String, newLine:String):String {
			s = encode(s);
			//若有换行则替换
			if (s.indexOf("\n") > -1) {
				s = s.replace(/\n/g, "</span>" + newLine);
			}
			return s;
		}
	}
}