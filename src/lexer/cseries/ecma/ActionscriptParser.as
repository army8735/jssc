package lexer.cseries.ecma {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100126
	 */
	
	public class ActionscriptParser extends EcmascriptParser {
		public function ActionscriptParser():void {
			var keywords:Array = "as class const delete extends finally to true false continue \
in instanceof interface internal is native new null package Boolean uint Infinity return undefined \
private protected public super this throw import include Date Error RegExp NaN void int intrinsic \
try typeof use var with each get set namespace implements function XML Object static break \
dynamic final native override trace String Number Date Event Array XMLLIST if else do while for \
swtich case".split(" ");
			super(keywords);
		}
	}
	
}