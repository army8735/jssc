package lexer {
	/**
	 * ...
	 * @author army8735
	 */
	import lexer.rule.*;
	
	public class PythonLexer extends LanguageLexer {
		private var isLineStart:Boolean;
		
		public function PythonLexer(rule:LanguageRule) {
			super(rule);
			isLineStart = true;
		}
		
		protected override function build():String {
			var res:String = '<li rel="0">';
			for (var i:int = 0, len:int = tokens.length; i < len; i++) {
				if (tokens[i].tag == Token.LINE && tokens[i + 1]) {
					if (tokens[i + 1].tag == Token.BLANK || tokens[i + 1].tag == Token.TAB) {
						lanDepth += tokens[i + 1].value.length;
					}
				}
				else {
					lanDepth = 0;
				}
				res += buildToken(tokens[i]);
			}
			return res + "</li>";
		}
	}

}