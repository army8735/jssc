define(function(require, exports, module) {
	var Class = require('../util/Class'),
		character = require('../util/character'),
		Token = require('./Token');
	module.exports = Class(function(rule) {
		this.rule = rule; //当前语法规则
		this.code; //要解析的代码
		this.peek = ''; //向前看字符
		this.index = 0; //向前看字符字符索引
		this.lastIndex = 0; //上次peek索引
		this.isPerlReg = true; //当前/是否是perl风格正则表达式
		this.lanDepth = 0; //生成最终结果时需要记录的行深度
		this.tokens = []; //结果的token列表
		this.parentheseState = false; //(开始时标记之前终结符是否为if/for/while等关键字
		this.parentheseStack = []; //圆括号深度记录当前是否为if/for/while等语句内部
	}).methods({
		parse: function(code) {
			this.code = code;
			this.scan();
			return this.tokens;
		},
		scan: function() {
			outer:
			while(this.index < this.code.length) {
				this.readch();
				//内嵌解析空白
				if(character.BLANK == this.peek) {
					this.tokens.push(new Token(Token.BLANK, this.peek));
				}
				if(character.TAB == this.peek) {
					this.tokens.push(new Token(Token.TAB, this.peek));
				}
				//内嵌解析换行
				else if(character.LINE == this.peek) {
					this.tokens.push(new Token(Token.LINE, this.peek));
				}
				//忽略回车
				else if(character.ENTER == this.peek) {
				}
				//内嵌解析数字
				else if(character.isDigit(this.peek)) {
					this.dealNumber();
				}
				else if(this.peek == '.') {
					this.dealDecimal();
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
						readch();
					} while(character.isDigit16(this.peek) || this.peek == '.');
					if(this.peek.toUpperCase() == 'H') {
						this.readch();
					}
					this.tokens.push(new Token(Token.NUMBER, this.code.slice(this.lastIndex, --this.index)));
				}
				//0后面是b或者B是2进制
				else if(this.peek.toUpperCase() == 'B') {
					do {
						readch();
					} while(this.peek == '0' || this.peek == '1' || this.peek == '.');
					this.tokens.push(new Token(Token.NUMBER, this.code.slice(this.lastIndex, --this.index)));
				}
				//或者8进制
				else {
					do {
						this.readch();
					} while(character.isDigit(this.peek) || this.peek == '.');
					this.tokens.push(new Token(Token.NUMBER, this.code.slice(this.lastIndex, --this.index)));
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
			if(this.peek == '.') {
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
		}
	});
});