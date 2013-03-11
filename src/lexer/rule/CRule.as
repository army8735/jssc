package lexer.rule {
	/**
	 * ...
	 * @author army8735
	 */
	import lexer.*;
	import lexer.depth.*;
	import lexer.match.*;
	
	public class CRule extends LanguageRule {
		
		public function CRule() {
			var keywords:Array = "if else for break case continue function \
true false switch default do while int float double long const_cast private \
short char return void static null whcar_t volatile  uuid explicit extern \
class const __finally __exception __try virtual using signed namespace new \
public protected __declspec delete unsigned friend goto inline mutable \
deprecated dllexport dllimport dynamic_cast enum union bool naked typeid \
noinline noreturn nothrow register this reinterpret_cast selectany sizeof \
static_cast struct template thread throw try typedef typename".split(" ");
			super(keywords);
			
			addMatch(new CompleteEqual(Token.DEPTH, "{"));
			addMatch(new CompleteEqual(Token.DEPTH, "}"));
			addMatch(new CompleteEqual(Token.DEPTH, "["));
			addMatch(new CompleteEqual(Token.DEPTH, "]"));
			addMatch(new CompleteEqual(Token.DEPTH, "("));
			addMatch(new CompleteEqual(Token.DEPTH, ")"));
			addMatch(new LinearSearch(Token.COMMENT, "//", "\n", false));
			addMatch(new LinearSearch(Token.COMMENT, "/*", "*/", true));
			addMatch(new LinearParse(Token.STRING, "'", "'"));
			addMatch(new LinearParse(Token.STRING, "\"", "\""));
			addMatch(new CharacterSet(Token.ID, [
				CharacterSet.LETTER,
				CharacterSet.UNDERLINE
			], [
				CharacterSet.LETTER,
				CharacterSet.UNDERLINE,
				CharacterSet.DIGIT
			]));
			addMatch(new CharacterSet(Token.HEAD, [
				CharacterSet.SHARP
			], [
				CharacterSet.LETTER,
				CharacterSet.DIGIT
			]));
			
			addDep(new TokenDepth(Token.DEPTH, "{", "}"));
			addDep(new TokenDepth(Token.DEPTH, "[", "]"));
			addDep(new TokenDepth(Token.DEPTH, "(", ")"));
		}
		
	}

}