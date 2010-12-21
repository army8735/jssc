package lexer {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100124
	 */
	import lexer.*;
	import util.*;
	
	public class AbstractParser implements IParser {
		protected var result:StringBuilder; //存储结果
		protected var words:HashMap; //保留字hash
		
		protected var peek:String; //向前看字符
		protected var code:String; //原始代码
		
		protected var index:int, depth:int, line; //当前读入字符索引、深度、行数
		
		public function AbstractParser(keywords:Array):void {
			peek = "";
			index = depth = line = 0;
			
			words = new HashMap(keywords);
			result = new StringBuilder("<li rel=\"0\">");
		}
		public function parse(code:String):String {
			this.code = code;
			scan();
			return result.toString() + "</li>";
		}
		/*public function isFinish():Boolean {
			return index > code.length;
		}*/
		
		protected function scan():void {
			throw new Error("scan方法必须被子类所实现");
		}
		
		//处理代码中的空格、制表符和换行。参数指定是否需要处理换行
		protected function dealBlank(newline:Boolean = true):void {
			for ( ; ; readch()) {
				//空格和制表符编码存入
				if (Character.isBlank(peek)) {
					result.append(HtmlEncode.encodeChar(peek));
				}
				//不需要处理换行符则跳出
				else if (!newline) {
					return;
				}
				//换行则存入新的<li>
				else if (peek == Character.LINE) {
					genNewLine();
				}
				else {
					return;
				}
			}
		}
		//处理符号
		protected function dealSign():void {
			result.append(HtmlEncode.encodeChar(peek));
			readch();
		}
		//处理数字
		protected function dealNumber():void {
			var start:int = index - 1;
			var res:String;
			//以0开头需判断是否2、16进制
			if (peek == Character.ZERO) {
				readch();
				//0后面是x或者X为16进制
				if (Character.isX(peek)) {
					readch();
					//寻找第一个非16进制字符
					while (index < code.length) {
						if (!Character.isDigit16(peek)) {
							break;
						}
						readch();
					}
					//小数点继续，其它退出
					if (peek != Character.DECIMAL) {
						result.append(HighLighter.number(code.slice(start, index - 1)));
						return;
					}
				}
				//0后面是b或者B为2进制
				else if (Character.isB(peek)) {
					readch();
					//直到不是数字为止
					while (index < code.length) {
						if (!Character.isDigit(peek)) {
							break;
						}
						readch();
					}
					//小数点继续，其它退出
					if (peek != Character.DECIMAL) {
						result.append(HighLighter.number(code.slice(start, index - 1)));
						return;
					}
				}
				//不是小数点跳出
				else if (peek != Character.DECIMAL) {
					result.append(HighLighter.number(Character.ZERO));
					return;
				}
			}
			//先处理整数部分
			else {
				do {
					readch();
				}
				while (Character.isDigit(peek) || peek == Character.UNDER_LINE);
			}
			//整数后可能跟的类型L字母
			if (Character.isLong(peek)) {
				//防止.l的出现
				if (index == start + 2 && code.charAt(start) == Character.DECIMAL) {
					result.append(code.slice(start, index));
				}
				else {
					result.append(HighLighter.number(code.slice(start, index)));
				}
				readch();
				return;
			}
			//也可能是小数部分
			else if (peek == Character.DECIMAL) {
				do {
					readch();
				}
				while (Character.isDigit(peek));
				//小数后可能跟的类型字母D、F
				if (Character.isFloat(peek) || Character.isDouble(peek)) {
					readch();
					res = code.slice(start, index - 1);
					//防止.f出现
					if (res.length > 2) {
						res = HighLighter.number(res);
					}
					result.append(res);
					return;
				}
			}
			//指数E
			if (Character.isExponent(peek)) {
				readch();
				//+-号
				if (peek == Character.ADD || peek == Character.MINUS) {
					readch();
				}
				//指数后面的数字
				while (Character.isDigit(peek)) {
					readch();
				}
			}
			//高亮
			res = code.slice(start, index - 1);
			//防止.e之类的出现，即第一个字符是小数点的情况下判断第二个字符是否非数字
			if (res.charAt(0) != Character.DECIMAL && !Character.isLetter(res.charAt(1))) {
				res = HighLighter.number(res);
			}
			result.append(res);
		}
		//读入下一个字符
		protected function readch():void {
			peek = code.charAt(index++);
		}
		//换行新<li/>节点并分析深度
		protected function genNewLine():void {
			result.append(getNewLine());
			line++;
		}
		protected function getNewLine():String {
			return "&nbsp;</li><li rel=\"" + depth + "\">";
		}
		//是否为关键字
		protected function isKeyword(s:String):Boolean {
			return words.hasKey(s);
		}
	}
}