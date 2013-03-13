package lexer 
{
	/**
	 * ...
	 * @author army8735
	 */
	import lexer.rule.*;
	
	public class PhpLexer implements ILexer {
		
		public function PhpLexer() {
			
		}
		
		public function parse(code:String):String {
			if (code.replace(/^\s*/, "").charAt(0) == '<') {
				return (new PhpHtmlLexer()).parse(code);
			}
			else {
				return (new LanguageLexer(new PhpRule())).parse(code);
			}
		}
		
	}

}