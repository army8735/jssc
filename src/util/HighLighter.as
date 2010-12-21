package util {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100117
	 */
	
	public class HighLighter {
		static const COMMENT:String = "comment";
		static const STRING:String = "string";
		static const HEAD:String = "head";
		static const CDATA:String = "cdata";
		static const REG:String = "reg";
		
		public static function number(s:String):String {
			return hightLighter("num", s);
		}
		public static function keyword(s:String):String {
			return hightLighter("keyword", s);
		}
		public static function string(s:String):String {
			return hightLighter(STRING, s);
		}
		public static function comment(s:String):String {
			return hightLighter(COMMENT, s);
		}
		public static function variable(s:String):String {
			return hightLighter("variable", s);
		}
		public static function regular(s:String):String {
			return hightLighter(REG, s);
		}
		public static function annot(s:String):String {
			return hightLighter("annot", s);
		}
		public static function head(s:String):String {
			return hightLighter(HEAD, s);
		}
		public static function attr(s:String):String {
			return hightLighter("attr", s);
		}
		public static function val(s:String):String {
			return hightLighter("val", s);
		}
		public static function cdata(s:String):String {
			return hightLighter(CDATA, s);
		}
		public static function ns(s:String):String {
			return hightLighter("namespace", s);
		}
		static function hightLighter(type:String, s:String):String {
			return "<span class=\"" + type + "\">" + s + "</span>";
		}
		
		public static function commentStart():String {
			return start(COMMENT);
		}
		public static function stringStart():String {
			return start(STRING);
		}
		public static function regStart():String {
			return start(REG);
		}
		public static function headStart():String {
			return start(HEAD);
		}
		public static function cdataStart():String {
			return start(CDATA);
		}
		static function start(type:String):String {
			return "<span class=\"" + type + "\">";
		}
	}
}