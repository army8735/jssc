package lexer.cseries.ecma {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100126
	 */
	import lexer.*;
	
	public class JavascriptParser extends EcmascriptParser implements IEmbedParser {
		public function JavascriptParser():void {
			var keywords:Array = "if else for break case continue function true \
switch default do while int float double long short char null public super in false \
abstract boolean byte class const debugger delete static void synchronized this import \
enum export extends final finally goto implements protected throw throws transient \
instanceof interface native new package private try typeof var volatile with \
document window return Function String Date Array Object RegExp Event Math Number".split(" ");
			super(keywords);
		}
		
		public function embedParse(code:String, depth:int):String {
			this.depth = depth;
			var res:String = parse(code);
			return res.slice(12, res.length - 5);
		}
	}
}