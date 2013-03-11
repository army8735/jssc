package lexer {
	/**
	 * ...
	 * @author army8735
	 */
	import lexer.match.*;
	import lexer.rule.*;
	import util.*;
	
	public class CssLexer extends LanguageLexer {
		private var myRule:CssRule;
		
		public function CssLexer(rule:CssRule) {
			super(rule);
			myRule = rule;
		}
		
		protected override function dealNumber():void {
			//先处理整数部分
			while (Character.isDigit(peek)) {
				readch();
			}
			//小数部分
			if (peek == Character.DECIMAL) {
				readch();
				while (Character.isDigit(peek)) {
					readch();
				}
			}
			var temp:int = index - 1;
			//单位
			while (Character.isLetter(peek)) {
				readch();
			}
			var unit:String = code.slice(temp, index - 1).toLowerCase();
			//%或者em px pt cm mm ex pc in单位
			if (unit == "%" || (unit.length == 2 && "em px pt cm mm ex pc in".indexOf(unit) > -1)) {
				tokens.push(new Token(Token.NUMBER, code.slice(lastIndex, --index)));
			}
			else {
				tokens.push(new Token(Token.OTHER, code.slice(lastIndex, --index)));
			}
			lastIndex = index;
		}
		protected override function buildToken(token:Token):String {
			//css有特殊的属性名、属性值和html的节点tag，需特殊对待
			if (token.tag == Token.ID) {
				if (myRule.keyWords.hasKey(token.value.toLowerCase())) {
					return highLight(token.value, "keyword");
				}
				else if (myRule.attrs.hasKey(token.value.toLowerCase())) {
					return highLight(token.value, "attr");
				}
				else if (myRule.tags.hasKey(token.value.toUpperCase())) {
					return highLight(token.value, "tags");
				}
			}
			return super.buildToken(token);
		}
		protected override function highLight(s:String, cn:String):String {
			//此token可能包含换行符进行正则替换
			if (s.indexOf(Character.LINE) > -1) {
				s = s.replace(/\n/g, '</span>&nbsp;</li><li rel="' + (lanDepth + 1) + '"><span class="' + cn + '">');
			}
			if (lanDepth == 0 && cn != "depth" && cn != "comment" && cn != "tags") {
				return s;
			}
			return '<span class="' + cn + '">' + s + '</span>';
		}
		
	}

}