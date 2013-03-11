package lexer.rule {
	/**
	 * ...
	 * @author army8735
	 */
	import lexer.*;
	import lexer.depth.*;
	import lexer.match.*;
	
	public class JavaRule extends LanguageRule {
		
		public function JavaRule() {
			var keywords:Array = "if else for break case continue function \
true false switch default do while int float double long throws transient \
abstract assert boolean byte class const enum instanceof try volatilechar \
extends final finally goto implements import protected return void char \
interface native new package private protected throw short public return \
strictfp super synchronized this static null String".split(" ");
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
			addMatch(new CharacterSet(Token.ANNOT, [
				CharacterSet.AT
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