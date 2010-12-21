package lexer.other {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100117
	 */
	import lexer.*;
	import util.*;
	
	public class UnknowParser implements IParser {
		
		public function parse(code:String):String {
			return "<li name=\"0\">" + HtmlEncode.encodeWithLine(code, "&nbsp;</li><li name=\"0\"><span>") + "</li>";
		}
		
	}
}