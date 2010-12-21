package lexer.cseries.compile.candcpp {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100117
	 */
	
	public class CParser extends CAndCppParser {	
		public function CParser():void {
			var keywords:Array = "if else for break case continue function struct \
true false switch default do while int float double long signed short char return \
void static null assert byte this throw new public return strictfp extends final \
finally goto implements import instanceof unsigned super synchronized boolean enum \
interface native package private protected protected extern abstract const class \
throws transient try volatile typedef bool".split(" ");
			super(keywords);
		}
	}
}