package lexer.cseries.compile.candcpp {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100117
	 */
	
	public class CppParser extends CAndCppParser {	
		public function CppParser():void {
			var keywords:Array = "if else for break case continue function \
true false switch default do while int float double long const_cast private \
short char return void static null whcar_t volatile  uuid explicit extern \
class const __finally __exception __try virtual using signed namespace new \
public protected __declspec delete unsigned friend goto inline mutable \
deprecated dllexport dllimport dynamic_cast enum union bool naked typeid \
noinline noreturn nothrow register this reinterpret_cast selectany sizeof \
static_cast struct template thread throw try typedef typename".split(" ");
			super(keywords);
		}
	}
}