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
			this.tokens = null; //�����token�б�
			this.parentheseState = false; //(��ʼʱ���֮ǰ�ս���Ƿ�Ϊif/for/while�ȹؼ���
			this.parentheseStack = []; //Բ������ȼ�¼��ǰ�Ƿ�Ϊif/for/while������ڲ�
			this.cacheLine = 0; //�л���ֵ
			this.totalLine = 1; //������
			this.col = 0; //��
		}).methods({
			parse: function(code, start) {
				if(code !== undefined) {
					this.code = code;
				}
				if(start !== undefined) {
					this.totalLine = start;
				}
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
					//��Ƕ�����հ�
					if(character.BLANK == this.peek) {
						this.tokens.push(new Token(Token.BLANK, this.peek));
						this.col++;
					}
					else if(character.TAB == this.peek) {
						this.tokens.push(new Token(Token.TAB, this.peek));
						this.col++;
					}
					//��Ƕ��������
					else if(character.LINE == this.peek) {
						this.totalLine++;
						this.col = 0;
						this.tokens.push(new Token(Token.LINE, this.peek));
						if(this.cacheLine > 0 && ++count >= this.cacheLine) {
							break;
						}
					}
					//���Իس�
					else if(character.ENTER == this.peek) {
					}
					//��Ƕ��������
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
					//���α���ƥ��������������
					else {
						for(var i = 0, matches = this.rule.matches(), len = matches.length; i < len; i++) {
							var match = matches[i];
							if(match.match(this.peek, this.code, this.index)) {
								var token = new Token(match.tokenType(), match.content(), match.val()),
									error = match.error(),
									matchLen = match.content().length;
								if(token.type() == Token.ID && this.rule.keyWords()[token.val()]) {
									token.type(Token.KEYWORD);
								}
								this.tokens.push(token);
								this.index += matchLen - 1;
								var n = character.count(token.val(), '\n');
								count += n;
								this.totalLine += n;
								if(n) {
									var i = match.content().lastIndexOf('\n');
									this.col = match.content().length - i;
								}
								else {
									this.col += matchLen;
								}
								if(error) {
									this.error(error, this.code.slice(this.index - matchLen, this.index));
								}
								//֧��perl�������жϹؼ��֡�Բ���ŶԳ��������Ӱ��
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
						//�����δƥ��ģ�˵����������������other���Ͳ��׳�����
						this.error('unknow token');
					}
				}
			},
			readch: function() {
				this.peek = this.code.charAt(this.index++);
				this.col++;
			},
			dealNumber: function() {
				var lastIndex = this.index - 1;
				//��0��ͷ���ж��Ƿ�2��16����
				if(this.peek == '0') {
					this.readch();
					//0������x����XΪ16����
					if(this.peek.toUpperCase() == 'X') {
						do {
							this.readch();
						} while(character.isDigit16(this.peek) || this.peek == character.DECIMAL);
						if(this.peek.toUpperCase() == 'H') {
							this.readch();
						}
						this.tokens.push(new Token(Token.NUMBER, this.code.slice(lastIndex, --this.index)));
					}
					//0������b����B��2����
					else if(this.peek.toUpperCase() == 'B') {
						do {
							this.readch();
						} while(character.isDigit2(this.peek) || this.peek == character.DECIMAL);
						this.tokens.push(new Token(Token.NUMBER, this.code.slice(lastIndex, --this.index)));
					}
					//����8����
					else if(character.isDigit8(this.peek)){
						do {
							this.readch();
						} while(character.isDigit8(this.peek) || this.peek == character.DECIMAL);
						this.tokens.push(new Token(Token.NUMBER, this.code.slice(lastIndex, --this.index)));
					}
					//С��
					else if(this.peek == character.DECIMAL) {
						this.dealDecimal(lastIndex);
					}
					//���Ǹ�0
					else {
						this.tokens.push(new Token(Token.NUMBER, '0'));
						this.index--;
					}
					return;
				}
				//�ȴ�����������
				do {
					this.readch();
				} while(character.isDigit(this.peek) || this.peek == '_');
				//��������ܸ�������L��ĸ
				if(this.peek.toUpperCase() == 'L') {
					this.tokens.push(new Token(Token.NUMBER, this.code.slice(lastIndex, this.index)));
					return;
				}
				//����С������
				if(this.peek == character.DECIMAL) {
					this.dealDecimal(lastIndex);
					return;
				}
				//ָ������
				if(this.peek.toUpperCase() == 'E') {
					this.readch();
					//+-��
					if(this.peek == '+' || this.peek == '-') {
						this.readch();
					}
					if(!character.isDigit(this.peek)) {
						this.error('SyntaxError: missing exponent', this.code.slice(lastIndex, this.index));
					}
					//ָ��������λ
					while(character.isDigit(this.peek)) {
						this.readch();
					}
				}
				this.tokens.push(new Token(Token.NUMBER, this.code.slice(lastIndex, --this.index)));
				this.col += this.index - lastIndex;
			},
			dealDecimal: function(last) {
				var lastIndex = this.index - 1;
				if(last !== undefined) {
					lastIndex = last;
				}
				do {
					this.readch();
				} while(character.isDigit(this.peek));
				//С������ܸ���������ĸD��F
				if(this.peek.toUpperCase() == 'D' || this.peek.toUpperCase() == 'F') {
					this.tokens.push(new Token(Token.NUMBER, this.code.slice(lastIndex, this.index)));
					return;
				}
				//ָ������
				if(this.peek.toUpperCase() == 'E') {
					this.readch();
					//+-��
					if(this.peek == '+' || this.peek == '-') {
						this.readch();
					}
					if(!character.isDigit(this.peek)) {
						this.error('SyntaxError: missing exponent', this.code.slice(lastIndex, this.index));
					}
					//ָ��������λ
					while(character.isDigit(this.peek)) {
						this.readch();
					}
				}
				this.tokens.push(new Token(Token.NUMBER, this.code.slice(lastIndex, --this.index)));
				this.col += this.index - lastIndex;
			},
			dealReg: function(length) {
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
				this.tokens.push(new Token(Token.REG, this.code.slice(lastIndex, --this.index)));
				this.col += this.index - lastIndex;
			},
			cache: function(i) {
				if(i !== undefined && i !== null) {
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
			error: function(s, str) {
				if(str === undefined) {
					str = this.code.substr(this.index - 1, 20);
				}
				if(Lexer.mode() === Lexer.STRICT) {
					throw new Error(s + ', line ' + this.line() + ' col ' + this.col + '\n' + str);
				}
				else if(Lexer.mode() === Lexer.LOOSE && window.console) {
					if(console.warn) {
						console.warn(s + ', line ' + this.line() + ' col ' + this.col + '\n' + str);
					}
					else if(console.error) {
						console.error(s + ', line ' + this.line() + ' col ' + this.col + '\n' + str);
					}
					else if(console.log) {
						console.log(s + ', line ' + this.line() + ' col ' + this.col + '\n' + str);
					}
				}
			}
		}).statics({
			IGNORE: 0,
			IS_REG: 1,
			NOT_REG: 2,
			SPECIAL: 3,
			STRICT: 0,
			LOOSE: 1,
			mode: function(i) {
				if(i !== undefined) {
					cmode = i;
				}
				return cmode;
			}
		}),
		cmode = Lexer.LOOSE;
	module.exports = Lexer;
});