define(function(require, exports, module) {
	var Class = require('../util/Class'),
		character = require('../util/character'),
		Token = require('./Token');
	var Lexer = Class(function(rule) {
		this.rule = rule; //当前语法规则
		this.code; //要解析的代码
		this.peek = ''; //向前看字符
		this.index = 0; //向前看字符字符索引
		this.lastIndex = 0; //上次peek索引
		this.isReg = Lexer.IS_REG; //当前/是否是perl风格正则表达式
		this.lanDepth = 0; //生成最终结果时需要记录的行深度
		this.tokens = null; //结果的token列表
		this.parentheseState = false; //(开始时标记之前终结符是否为if/for/while等关键字
		this.parentheseStack = []; //圆括号深度记录当前是否为if/for/while等语句内部
		this.cacheLine = 0; //行缓存值
		this.totalLine = 0; //总行数
	}).methods({
		parse: function(code) {
			this.code = code;
			this.tokens = [];
			this.scan();
			return this.tokens;
		},
		parseCache: function() {
			this.tokens = [];
			this.scan();
			return this.tokens;
		},
		scan: function() {
			var perlReg = this.rule.perlReg(),
				length = this.code.length,
				count = 0;
			outer:
			while(this.index < length) {
				this.readch();
				//内嵌解析空白
				if(character.BLANK == this.peek) {
					this.tokens.push(new Token(Token.BLANK, this.peek));
				}
				else if(character.TAB == this.peek) {
					this.tokens.push(new Token(Token.TAB, this.peek));
				}
				//内嵌解析换行
				else if(character.LINE == this.peek) {
					this.totalLine++;
					this.tokens.push(new Token(Token.LINE, this.peek));
					if(this.cacheLine > 0 && ++count >= this.cacheLine) {
						this.lastIndex = this.index;
						break;
					}
				}
				//忽略回车
				else if(character.ENTER == this.peek) {
				}
				//内嵌解析数字
				else if(character.isDigit(this.peek)) {
					this.dealNumber();
					if(perlReg) {
						this.isReg = Lexer.NOT_REG;
					}
				}
				else if(this.peek == character.DECIMAL && character.isDigit(this.code.charAt(this.index))) {
					this.dealDecimal();
					if(perlReg) {
						this.isReg = Lexer.NOT_REG;
					}
				}
				else if(perlReg && this.isReg == Lexer.IS_REG && this.peek == character.SLASH && !{ '/': true, '*': true }[this.code.charAt(this.index)]) {
					this.dealReg(length);
					this.isReg = Lexer.NOT_REG;
				}
				//依次遍历匹配规则，命中则继续
				else {
					for(var i = 0, matches = this.rule.matches(), len = matches.length; i < len; i++) {
						var match = matches[i];
						if(match.start(this.peek) && match.match(this.code, this.index)) {
							var token = new Token(match.tokenType(), match.content());
							if(token.type() == Token.ID && this.rule.keyWords()[token.val()]) {
								token.type(Token.KEYWORD);
							}
							this.tokens.push(token);
							this.index += match.content().length - 1;
							this.lastIndex = this.index;
							var n = character.count(token.val(), '\n');
							count += n;
							this.totalLine += n;
							//支持perl正则需判断关键字、圆括号对除号语义的影响
							if(perlReg && match.perlReg() != Lexer.IGNORE) {
								if(match.perlReg() == Lexer.SPECIAL) {
									this.isReg = !!this.rule.keyWords()[match.content()];
								}
								else {
									this.isReg = match.perlReg();
								}
								if(match.tokenType() == Token.ID) {
									this.parentheseState = !!this.rule.keyWords()[match.content()];
								}
								else if(this.peek == character.LEFT_PARENTHESE) {
									this.parentheseStack.push(this.parentheseState);
									this.parentheseState = false;
								}
								else if(this.peek == character.RIGHT_PARENTHESE) {
									this.isReg = this.parentheseStack.pop() ? Lexer.IS_REG : Lexer.NOT_REG;
								}
								else {
									this.parentheseState = false;
								}
							}
							continue outer;
						}
					}
					//如果有未匹配的，说明规则不完整，加入other类型并抛出警告
					this.tokens.push(new Token(Token.OTHER, this.peek));
					if(window.console && window.console.warn) {
						console.warn('unknow token at ' + (this.index - 1) + ': ' + this.peek + ', charcode : ' + this.peek.charCodeAt(0));
					}
				}
				this.lastIndex = this.index;
			}
		},
		readch: function() {
			this.peek = this.code.charAt(this.index++);
		},
		dealNumber: function() {
			//以0开头需判断是否2、16进制
			if(this.peek == '0') {
				this.readch();
				//0后面是x或者X为16进制
				if(this.peek.toUpperCase() == 'X') {
					do {
						this.readch();
					} while(character.isDigit16(this.peek) || this.peek == character.DECIMAL);
					if(this.peek.toUpperCase() == 'H') {
						this.readch();
					}
					this.tokens.push(new Token(Token.NUMBER, this.code.slice(this.lastIndex, --this.index)));
				}
				//0后面是b或者B是2进制
				else if(this.peek.toUpperCase() == 'B') {
					do {
						this.readch();
					} while(character.isDigit2(this.peek) || this.peek == character.DECIMAL);
					this.tokens.push(new Token(Token.NUMBER, this.code.slice(this.lastIndex, --this.index)));
				}
				//或者8进制
				else if(character.isDigit8(this.peek)){
					do {
						this.readch();
					} while(character.isDigit8(this.peek) || this.peek == character.DECIMAL);
					this.tokens.push(new Token(Token.NUMBER, this.code.slice(this.lastIndex, --this.index)));
				}
				//小数
				else if(this.peek == character.DECIMAL) {
					this.dealDecimal();
				}
				//就是个0
				else {
					this.tokens.push(new Token(Token.NUMBER, '0'));
					this.index--;
				}
				return;
			}
			//先处理整数部分
			do {
				this.readch();
			} while(character.isDigit(this.peek) || this.peek == '_');
			//整数后可能跟的类型L字母
			if(this.peek.toUpperCase() == 'L') {
				this.tokens.push(new Token(Token.NUMBER, this.code.slice(this.lastIndex, this.index)));
				return;
			}
			//可能小数部分
			if(this.peek == character.DECIMAL) {
				this.dealDecimal();
				return;
			}
			//指数部分
			if(this.peek.toUpperCase() == 'E') {
				this.readch();
				//+-号
				if(this.peek == '+' || this.peek == '-') {
					this.readch();
				}
				//指数后数字位
				while(character.isDigit(this.peek)) {
					this.readch();
				}
			}
			this.tokens.push(new Token(Token.NUMBER, this.code.slice(this.lastIndex, --this.index)));
		},
		dealDecimal: function() {
			do {
				this.readch();
			} while(character.isDigit(this.peek));
			//小数后可能跟的类型字母D、F
			if(this.peek.toUpperCase() == 'D' || this.peek.toUpperCase() == 'F') {
				this.tokens.push(new Token(Token.NUMBER, this.code.slice(this.lastIndex, this.index)));
				return;
			}
			//指数部分
			if(this.peek.toUpperCase() == 'E') {
				this.readch();
				//+-号
				if(this.peek == '+' || this.peek == '-') {
					this.readch();
				}
				//指数后数字位
				while(character.isDigit(this.peek)) {
					this.readch();
				}
			}
			this.tokens.push(new Token(Token.NUMBER, this.code.slice(this.lastIndex, --this.index)));
		},
		dealReg: function(length) {
			var lastIndex = this.index - 1;
			outer:
			do {
				this.readch();
				if(this.peek == character.BACK_SLASH) {
					this.index++;
				}
				else if(this.peek == character.LEFT_BRACKET) {
					do {
						this.readch();
						if(this.peek == character.BACK_SLASH) {
							this.index++;
						}
						else if(this.peek == character.RIGHT_BRACKET) {
							continue outer;
						}
					} while(this.index < length);
				}
				else if(this.peek == character.SLASH) {
					do {
						this.readch();
					} while(this.index < length && character.isLetter(this.peek));
					break;
				}
			} while(this.index < length);
			this.tokens.push(new Token(Token.REG, this.code.slice(lastIndex, --this.index)));
		},
		cache: function(i) {
			if(i !== undefined) {
				this.cacheLine = i;
			}
			return this.cacheLine;
		},
		finish: function() {
			return this.index >= this.code.length;
		},
		line: function() {
			return this.totalLine;
		}
	}).statics({
		IGNORE: 0,
		IS_REG: 1,
		NOT_REG: 2,
		SPECIAL: 3
	});
	module.exports = Lexer;
});