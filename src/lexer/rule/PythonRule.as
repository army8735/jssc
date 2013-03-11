package lexer.rule {
	/**
	 * ...
	 * @author army8735
	 */
	import lexer.*;
	import lexer.depth.*;
	import lexer.match.*;
	
	public class PythonRule extends LanguageRule {
		
		public function PythonRule() {
			var keywords:Array = "and assert break class continue def del elif else \
except exec finally for from global if import in is lambda not or pass print raise \
return try yield while __import__ abs all any apply basestring bin bool buffer callable \
chr classmethod cmp coerce compile complex delattr dict dir divmod enumerate eval \
execfile file filter float format frozenset getattr globals hasattr hash help hex id \
input int intern isinstance issubclass iter len list locals long map max min next \
object oct open ord pow print property range raw_input reduce reload repr reversed \
round set setattr slice sorted staticmethod str sum super tuple type type unichr \
unicode vars xrange zip".split(" ");
			super(keywords, true);
			
			addMatch(new LinearSearch(Token.COMMENT, "#", "\n", false));
			addMatch(new LinearSearch(Token.STRING, "'''", "'''", true, LanguageLexer.IS_PERL_REG));
			addMatch(new LinearSearch(Token.STRING, '"""', '"""', true, LanguageLexer.IS_PERL_REG));
			addMatch(new LinearParse(Token.STRING, "'", "'", true, LanguageLexer.IS_PERL_REG));
			addMatch(new LinearParse(Token.STRING, "\"", "\"", true, LanguageLexer.IS_PERL_REG));
			addMatch(new CharacterSet(Token.ID, [
				CharacterSet.LETTER,
				CharacterSet.UNDERLINE
			], [
				CharacterSet.LETTER,
				CharacterSet.UNDERLINE,
				CharacterSet.DIGIT
			], LanguageLexer.NOT_PERL_REG));
		}
		
	}

}