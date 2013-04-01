define(function(require, exports, module) {
	var Class = require('../util/Class'),
		character = require('../util/character'),
		Token = require('./Token'),
		Lexer = Class(function(rule) {
			this.rule = rule; //��ǰ�﷨����
			this.code; //Ҫ�����Ĵ���
			this.peek = ''; //��ǰ���ַ�
			this.index = 0; //��ǰ���ַ��ַ�����
			this.isReg = Lexer.IS_REG; //��ǰ/�Ƿ���perl���������ʽ
			this.lanDepth = 0; //�������ս��ʱ��Ҫ��¼�������
			this.tokenList = []; //�����token�б�
			this.parentheseState = false; //(��ʼʱ���֮ǰ�ս���Ƿ�Ϊif/for/while�ȹؼ���
			this.parentheseStack = []; //Բ������ȼ�¼��ǰ�Ƿ�Ϊif/for/while������ڲ�
			this.cacheLine = 0; //�л���ֵ
			this.totalLine = 1; //������
			this.colNum = 0; //��
			this.colMax = 0;
		}).methods({
			parse: function(code, start) {
				if(!character.isUndefined(code)) {
					this.code = code;
				}
				if(!character.isUndefined(start)) {
					this.totalLine = start;
				}
				var temp = [];
				this.scan(temp);
				return temp;
			},
			tokens: function() {
				return this.tokenList;
			},
			scan: function(temp) {
				var perlReg = this.rule.perlReg(),
					length = this.code.length,
					count = 0;
				outer:
				while(this.index < length) {
					if(this.cacheLine > 0 && count >= this.cacheLine) {
						break;
					}
					this.readch();
					//perl�������
					if(perlReg && this.isReg == Lexer.IS_REG && this.peek == character.SLASH && !{ '/': true, '*': true }[this.code.charAt(this.index)]) {
						this.dealReg(temp, length);
						this.isReg = Lexer.NOT_REG;
					}
					//���α���ƥ��������������
					else {
						for(var i = 0, matches = this.rule.matches(), len = matches.length; i < len; i++) {
							var match = matches[i];
							if(match.match(this.peek, this.code, this.index)) {
								var token = new Token(match.tokenType(), match.content(), match.val()),
									error = match.error(),
									matchLen = match.content().length;
								if(token.type() == Token.ID && this.rule.keyWords().hasOwnProperty(token.content())) {
									token.type(Token.KEYWORD);
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
								//֧��perl�������жϹؼ��֡�Բ���ŶԳ��������Ӱ��
								if(perlReg && match.perlReg() != Lexer.IGNORE) {
									if(match.perlReg() == Lexer.SPECIAL) {
										this.isReg = match.special();
									}
									else {
										this.isReg = match.perlReg();
									}
									if(this.peek == character.LEFT_PARENTHESE) {
										this.parentheseStack.push(this.parentheseState);
										this.parentheseState = false;
									}
									else if(this.peek == character.RIGHT_PARENTHESE) {
										this.isReg = this.parentheseStack.pop() ? Lexer.IS_REG : Lexer.NOT_REG;
									}
									else {
										this.parentheseState = match.parenthese();
									}
								}
								continue outer;
							}
						}
						//�����δƥ��ģ�˵����������������other���Ͳ��׳�����
						this.error('unknow token');
					}
				}
				return this;
			},
			readch: function() {
				this.peek = this.code.charAt(this.index++);
				//this.colNum++;
			},
			dealReg: function(temp, length) {
				var lastIndex = this.index - 1,
					res = false;
				outer:
				do {
					this.readch();
					if(this.peek == character.LINE) {
						break;
					}
					else if(this.peek == character.BACK_SLASH) {
						this.index++;
					}
					else if(this.peek == character.LEFT_BRACKET) {
						do {
							this.readch();
							if(this.peek == character.LINE) {
								break outer;
							}
							else if(this.peek == character.BACK_SLASH) {
								this.index++;
							}
							else if(this.peek == character.RIGHT_BRACKET) {
								continue outer;
							}
						} while(this.index < length);
					}
					else if(this.peek == character.SLASH) {
						res = true;
						var hash = {};
						do {
							this.readch();
							if(character.isLetter(this.peek)) {
								if(hash[this.peek] || (this.peek != 'g' && this.peek != 'i' && this.peek != 'm')) {
									this.error('SyntaxError: invalid regular expression flag ' + this.peek, this.code.slice(lastIndex, this.index));
									break outer;
								}
								hash[this.peek] = true;
							}
							else {
								break outer;
							}
						} while(this.index < length);
					}
				} while(this.index < length);
				if(!res) {
					this.error('SyntaxError: unterminated regular expression literal', this.code.slice(lastIndex, this.index - 1));
				}
				var token = new Token(Token.REG, this.code.slice(lastIndex, --this.index));
				temp.push(token);
				this.tokenList.push(token);
				this.colNum += this.index - lastIndex;
				this.colMax = Math.max(this.colMax, this.colNum);
				return this;
			},
			cache: function(i) {
				if(!character.isUndefined(i) && i !== null) {
					this.cacheLine = i;
				}
				return this.cacheLine;
			},
			finish: function() {
				return this.index >= this.code.length;
			},
			line: function() {
				return this.totalLine;
			},
			col: function() {
				return this.colMax;
			},
			error: function(s, str) {
				if(character.isUndefined(str)) {
					str = this.code.substr(this.index - 1, 20);
				}
				if(Lexer.mode() === Lexer.STRICT) {
					throw new Error(s + ', line ' + this.line() + ' col ' + this.colNum + '\n' + str);
				}
				else if(Lexer.mode() === Lexer.LOOSE && window.console) {
					if(console.warn) {
						console.warn(s + ', line ' + this.line() + ' col ' + this.colNum + '\n' + str);
					}
					else if(console.error) {
						console.error(s + ', line ' + this.line() + ' col ' + this.colNum + '\n' + str);
					}
					else if(console.log) {
						console.log(s + ', line ' + this.line() + ' col ' + this.colNum + '\n' + str);
					}
				}
				return this;
			}
		}).statics({
			IGNORE: 0,
			IS_REG: 1,
			NOT_REG: 2,
			SPECIAL: 3,
			STRICT: 0,
			LOOSE: 1,
			mode: function(i) {
				if(!character.isUndefined(i)) {
					cmode = i;
				}
				return cmode;
			}
		}),
		cmode = Lexer.STRICT;
	module.exports = Lexer;
});