package lexer {
	/**
	 * ...
	 * @author army8735
	 */
	import lexer.rule.*;
	import util.*;
	
	public class PhpHtmlLexer extends HtmlLexer {
		protected const PHP:int = 4;
		
		public function PhpHtmlLexer() {
			super();
		}
		
		protected override function scanState(length:int):void {
			switch(state) {
				case PHP:
					dealPhp(length);
				break;
				default:
					super.scanState(length);
				break;
			}
		}
		protected override function dealQuestion():void {
			do {
				readch();
			}
			while (Character.isLetter(peek));
			var tag:String = code.slice(lastIndex, --index);
			if (tag.toLowerCase() == "<?php" || tag == "<?") {
				state = PHP;
				tokens.push(new Token(Token.MARK, tag));
			}
			else {
				tokens.push(new Token(Token.OTHER, tag));
			}
			lastIndex = index;
		}
		protected  function dealPhp(length:int):void {
			var tag:String,
				end:Boolean = false;
			while (index <= length) {
				if (peek == Character.SLASH) {
					readch();
					//多行注释
					if (peek == Character.STAR) {
						index = code.indexOf("*/", index);
						if (index == -1) {
							index = code.length;
						}
						else {
							index += 2;
						}
					}
					//单行注释
					else if (peek == Character.SLASH) {
						index = code.indexOf("\n", index);
						if (index == -1) {
							index = code.length;
						}
					}
				}
				else if (Character.isQuote(peek)) {
					tag = peek;
					while (index <= code.length) {
						readch();
						//转义
						if (peek == Character.BACK_SLASH) {
							readch();
						}
						else if (peek == tag) {
							break;
						}
					}
				}
				else if (peek == Character.QUESTION) {
					readch();
					if (peek == Character.RIGHT_ANGLE_BRACE) {
						index -= 2;
						end = true;
						break;
					}
				}
				readch();
			}
			tokens.push(new Token(Token.EMBED_PHP, code.slice(lastIndex, index)));
			if (end) {
				tokens.push(new Token(Token.MARK, code.substr(index, 2)));
				index += 2;
			}
			lastIndex = index;
			state = TEXT;
		}
		protected override function buildToken(token:Token):String {
			if (token.tag == Token.EMBED_PHP) {
				var phpLexer:LanguageLexer = new LanguageLexer(new PhpRule());
				phpLexer.depth = lanDepth;
				return phpLexer.parse(token.value).slice(12, -5);
			}
			else {
				return super.buildToken(token);
			}
		}
		protected override function highLight(s:String, cn:String):String {
			if (cn == "keyword") {
				if (s.indexOf("&lt;?") == 0) {
					lanDepth++;
				}
				else if (s == "?&gt;") {
					lanDepth--;
				}
			}
			return super.highLight(s, cn);
		}
		
	}

}