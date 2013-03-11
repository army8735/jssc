package lexer.rule {
	/**
	 * ...
	 * @author army8735
	 */
	import lexer.*;
	import lexer.depth.*;
	import lexer.match.*;
	
	public class EcmascriptRule extends LanguageRule {
		public static const KEYWORDS:Array = "if else for break case continue function true use \
switch default do while int float double long short char null public super in false \
abstract boolean Boolean byte class const debugger delete static void synchronized this import \
enum export extends final finally goto implements protected throw throws transient \
instanceof interface native new package private try typeof var volatile Vector with \
document window return Function String Date Array Object RegExp Event Math Number \
decodeURI decodeURIComponent encodeURI encodeURIComponent escape isFinite isNaN namespace \
isXMLName parseFloat parseInt trace uint unescape XML XMLList undefined Infinity NaN".split(" ");
		
		public function EcmascriptRule() {
			super(KEYWORDS, true);
			
			addMatch(new CompleteEqual(Token.DEPTH, "{", LanguageLexer.IS_PERL_REG));
			addMatch(new CompleteEqual(Token.DEPTH, "}", LanguageLexer.IS_PERL_REG));
			addMatch(new CompleteEqual(Token.DEPTH, "[", LanguageLexer.IS_PERL_REG));
			addMatch(new CompleteEqual(Token.DEPTH, "]", LanguageLexer.IS_PERL_REG));
			addMatch(new CompleteEqual(Token.DEPTH, "(", LanguageLexer.IS_PERL_REG));
			addMatch(new CompleteEqual(Token.DEPTH, ")"));
			addMatch(new LinearSearch(Token.COMMENT, "//", "\n", false));
			addMatch(new LinearSearch(Token.COMMENT, "/*", "*/", true));
			addMatch(new LinearParse(Token.STRING, "'", "'", true, LanguageLexer.IS_PERL_REG));
			addMatch(new LinearParse(Token.STRING, "\"", "\"", true, LanguageLexer.IS_PERL_REG));
			addMatch(new CharacterSet(Token.ID, [
				CharacterSet.LETTER,
				CharacterSet.UNDERLINE,
				CharacterSet.DOLLAR
			], [
				CharacterSet.LETTER,
				CharacterSet.UNDERLINE,
				CharacterSet.DOLLAR,
				CharacterSet.DIGIT
			], LanguageLexer.KEYWORD));
			addMatch(new CharacterSet(Token.ATTR, [
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