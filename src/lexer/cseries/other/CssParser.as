package lexer.cseries.other {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100217
	 */
	import lexer.*;
	import lexer.cseries.*;
	import util.*;
	
	public class CssParser extends CSeriesParser implements IEmbedParser {
		private var values:HashMap;
		private var defaultDepth:int; //默认初始化深度，单独分析时为0，作为内嵌解析器时用作参考对象
		
		public function CssParser():void {
			var keywords:Array = "ascent azimuth background-attachment background-color background-image background-position \
background-repeat background baseline bbox border-collapse border-color border-spacing border-style border-top \
border-right border-bottom border-left border-top-color border-right-color border-bottom-color border-left-color \
border-top-style border-right-style border-bottom-style border-left-style border-top-width border-right-width \
border-bottom-width border-left-width border-width border bottom cap-height caption-side centerline clear clip color \
content counter-increment counter-reset cue-after cue-before cue cursor definition-src descent direction display \
elevation empty-cells float font-size-adjust font-family font-size font-stretch font-style font-variant font-weight font \
height left letter-spacing line-height list-style-image list-style-position list-style-type list-style margin-top \
margin-right margin-bottom margin-left margin marker-offset marks mathline max-height max-width min-height min-width orphans \
outline-color outline-style outline-width outline overflow padding-top padding-right padding-bottom padding-left padding page \
page-break-after page-break-before page-break-inside pause pause-after pause-before pitch pitch-range play-during position \
quotes right richness size slope src speak-header speak-numeral speak-punctuation speak speech-rate stemh stemv stress \
table-layout text-align top text-decoration text-indent text-shadow text-transform unicode-bidi unicode-range units-per-em \
vertical-align visibility voice-family volume white-space widows width widths word-spacing x-height z-index".split(" ");
			super(keywords);
			
			keywords = "above absolute all always aqua armenian attr aural auto avoid baseline behind below bidi-override black blink block blue bold bolder \
both bottom braille capitalize caption center center-left center-right circle close-quote code collapse compact condensed \
continuous counter counters crop cross crosshair cursive dashed decimal decimal-leading-zero default digits disc dotted double \
embed embossed e-resize expanded extra-condensed extra-expanded fantasy far-left far-right fast faster fixed format fuchsia \
gray green groove handheld hebrew help hidden hide high higher icon inline-table inline inset inside invert italic \
justify landscape large larger left-side left leftwards level lighter lime line-through list-item local loud lower-alpha \
lowercase lower-greek lower-latin lower-roman lower low ltr marker maroon medium message-box middle mix move narrower \
navy ne-resize no-close-quote none no-open-quote no-repeat normal nowrap n-resize nw-resize oblique olive once open-quote outset \
outside overline pointer portrait pre print projection purple red relative repeat repeat-x repeat-y rgb ridge right right-side \
rightwards rtl run-in screen scroll semi-condensed semi-expanded separate se-resize show silent silver slower slow \
small small-caps small-caption smaller soft solid speech spell-out square s-resize static status-bar sub super sw-resize \
table-caption table-cell table-column table-column-group table-footer-group table-header-group table-row table-row-group teal \
text-bottom text-top thick thin top transparent tty tv ultra-condensed ultra-expanded underline upper-alpha uppercase upper-latin \
upper-roman url visible wait white wider w-resize x-fast x-high x-large x-loud x-low x-slow x-small x-soft xx-large xx-small yellow".split(" ");
			values = new HashMap(keywords);
			defaultDepth = 0;
		}
		
		protected override function scan():void {
			readch();
			while (index <= code.length) {
				//处理空白
				dealBlank();
				//除号检查注释
				if (peek == Character.SLASH) {
					readch();
					//单行注释
					if (peek == Character.SLASH) {
						dealSingleComment();
					}
					//多行注释
					else if (peek == Character.STAR) {
						dealMultiComment();
					}
					//除号
					else {
						result.append("/");
					}
				}
				//#颜色，防止和id冲突，需要至少深度为1
				else if (peek == Character.SHARP && depth > 0) {
					dealColor();
				}
				//单双引号字符串
				else if (Character.isQuote(peek)) {
					dealString(peek);
				}
				//处理数字
				else if (Character.isDigitOrDecimal(peek)) {
					dealNum();
				}
				//处理单词，字母开头
				else if (Character.isLetter(peek)) {
					dealWord();
				}
				//其它情况
				else {
					dealSign();
				}
			}
		}
		
		private function dealNum():void {
			var start:int = index - 1, end:int;
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
			end = index - 1;
			//单位
			while (Character.isLetter(peek)) {
				readch();
			}
			var unit:String = code.slice(end, index - 1).toLowerCase();
			//%或者em px pt cm mm ex pc in单位
			if (unit == "%" || (unit.length == 2 && "em px pt cm mm ex pc in".indexOf(unit) > -1)) {
				end = index - 1;
			}
			//高亮
			var res:String = code.slice(start, end);
			if (depth > defaultDepth) {
				res = HighLighter.number(res);
			}
			result.append(res);
			index = end;
			readch();
		}
		private function dealWord():void {
			var start:int = index - 1;
			//找到第一个非字母横线位置
			while (index <= code.length) {
				readch();
				if (!Character.isLetter(peek) && peek != Character.MINUS) {
					break;
				}
			}
			var res:String = code.slice(start, index - 1);
			//高亮
			if (depth > defaultDepth) {
				if (words.hasKey(res.toLowerCase())) {
					res = HighLighter.keyword(res);
				}
				else if (values.hasKey(res.toLowerCase())) {
					res = HighLighter.val(res);
				}
			}
			result.append(res);
		}
		private function dealColor():void {
			var start:int = index - 1;
			while (index <= code.length) {
				readch();
				if (!Character.isDigit16(peek)) {
					break;
				}
			}
			var res:String = code.slice(start, index - 1);
			//必须深度大于默认深度并且长度符合要求时（颜色16进制为#加3位或6位字母）
			if (depth > defaultDepth && (res.length == 4 || res.length == 7)) {
				res = HighLighter.number(res);
			}
			result.append(res);
		}
		
		public function embedParse(code:String, depth:int):String {
			this.depth = defaultDepth = depth;
			var res:String = parse(code);
			return res.slice(12, res.length - 5);
		}
	}
}