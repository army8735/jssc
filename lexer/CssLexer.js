define(function(require, exports, module) {
	var Lexer = require('./Lexer'),
		Token = require('./Token'),
		character = require('../util/character'),
		CssLexer = Lexer.extend(function(rule) {
			Lexer.call(this, rule);
			this.depth = 0;
			this.isValue = false;
		}).methods({
			//@override
			scan: function(temp) {
				var length = this.code.length,
					count = 0;
				outer:
				while(this.index < length) {
					if(this.cacheLine > 0 && count >= this.cacheLine) {
						break;
					}
					this.readch();
					for(var i = 0, matches = this.rule.matches(), len = matches.length; i < len; i++) {
						var match = matches[i];
						if(match.match(this.peek, this.code, this.index)) {
							var token = new Token(match.tokenType(), match.content(), match.val()),
								error = match.error(),
								matchLen = match.content().length;
							if(token.type() == Token.ID) {
								//ie hack也算关键字
								if(/[*-_]/.test(token.content().charAt(0))) {
									if(this.rule.keyWords().hasOwnProperty(token.content().slice(1))) {
										token.type(Token.KEYWORD);
									}
								}
								else {
									//分属性和值
									if(this.rule.keyWords().hasOwnProperty(token.content())) {
										token.type(Token.KEYWORD);
									}
									else if(this.rule.values().hasOwnProperty(token.content())) {
										token.type(Token.PROPERTY);
									}
								}
							}
							if(token.type() == Token.HEAD && token.content() == '@import') {
								this.isValue = true;
							}
							else if(token.type() == Token.SIGN) {
								if(token.content() == ':') {
									this.isValue = true;
								}
								else if(token.content() == ';' || token.content == '}') {
									this.isValue = false;
								}
								if(token.content() == '{') {
									this.depth++;
								}
								else if(token.content() == '}') {
									this.depth--;
								}
							}
							if(token.type() == Token.PROPERTY && !this.isValue) {
								break;
							}
							if(token.type() == Token.NUMBER && !this.isValue) {
								token.type(Token.ID);
							}
							temp.push(token);
							this.tokenList.push(token);
							this.index += matchLen - 1;
							var n = character.count(token.val(), character.LINE);
							count += n;
							this.totalLine += n;
							if(n) {
								var i = match.content().indexOf(character.LINE),
									j = match.content().lastIndexOf(character.LINE);
								this.colMax = Math.max(this.colMax, this.colNum + i);
								this.colNum = match.content().length - j;
							}
							else {
								this.colNum += matchLen;
							}
							this.colMax = Math.max(this.colMax, this.colNum);
							if(error) {
								this.error(error, this.code.slice(this.index - matchLen, this.index));
							}
							continue outer;
						}
					}
					//如果有未匹配的，css默认忽略，查找下一个;
					var j = this.code.indexOf(';', this.index);
					if(j == -1) {
						j = this.code.length;
					}
					var s = this.code.slice(this.index - 1, j);
					var token = new Token(Token.VIRTUAL, s);
					temp.push(token);
					this.tokenList.push(token);
					this.index = j;
				}
				return this;
			}
		});
	module.exports = CssLexer;
});