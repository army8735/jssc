define(function(require, exports, module) {
	var Class = require('../util/Class'),
		character = require('../util/character'),
		Token = require('./Token');
	module.exports = Class(function(rule) {
		this.rule = rule; //��ǰ�﷨����
		this.code; //Ҫ�����Ĵ���
		this.peek = ''; //��ǰ���ַ�
		this.index = 0; //��ǰ���ַ��ַ�����
		this.lastIndex = 0; //�ϴ�peek����
		this.isPerlReg = true; //��ǰ/�Ƿ���perl���������ʽ
		this.lanDepth = 0; //�������ս��ʱ��Ҫ��¼�������
		this.tokens = []; //�����token�б�
		this.parentheseState = false; //(��ʼʱ���֮ǰ�ս���Ƿ�Ϊif/for/while�ȹؼ���
		this.parentheseStack = []; //Բ������ȼ�¼��ǰ�Ƿ�Ϊif/for/while������ڲ�
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
				//��Ƕ�����հ�
				if(character.BLANK == this.peek) {
					this.tokens.push(new Token(Token.BLANK, this.peek));
				}
				if(character.TAB == this.peek) {
					this.tokens.push(new Token(Token.TAB, this.peek));
				}
				//��Ƕ��������
				else if(character.LINE == this.peek) {
					this.tokens.push(new Token(Token.LINE, this.peek));
				}
				//���Իس�
				else if(character.ENTER == this.peek) {
				}
				//��Ƕ��������
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
			//��0��ͷ���ж��Ƿ�2��16����
			if(this.peek == '0') {
				this.readch();
				//0������x����XΪ16����
				if(this.peek.toUpperCase() == 'X') {
					do {
						readch();
					} while(character.isDigit16(this.peek) || this.peek == '.');
					if(this.peek.toUpperCase() == 'H') {
						this.readch();
					}
					this.tokens.push(new Token(Token.NUMBER, this.code.slice(this.lastIndex, --this.index)));
				}
				//0������b����B��2����
				else if(this.peek.toUpperCase() == 'B') {
					do {
						readch();
					} while(this.peek == '0' || this.peek == '1' || this.peek == '.');
					this.tokens.push(new Token(Token.NUMBER, this.code.slice(this.lastIndex, --this.index)));
				}
				//����8����
				else {
					do {
						this.readch();
					} while(character.isDigit(this.peek) || this.peek == '.');
					this.tokens.push(new Token(Token.NUMBER, this.code.slice(this.lastIndex, --this.index)));
				}
				return;
			}
			//�ȴ�����������
			do {
				this.readch();
			} while(character.isDigit(this.peek) || this.peek == '_');
			//��������ܸ�������L��ĸ
			if(this.peek.toUpperCase() == 'L') {
				this.tokens.push(new Token(Token.NUMBER, this.code.slice(this.lastIndex, this.index)));
				return;
			}
			//����С������
			if(this.peek == '.') {
				this.dealDecimal();
				return;
			}
			//ָ������
			if(this.peek.toUpperCase() == 'E') {
				this.readch();
				//+-��
				if(this.peek == '+' || this.peek == '-') {
					this.readch();
				}
				//ָ��������λ
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
			//С������ܸ���������ĸD��F
			if(this.peek.toUpperCase() == 'D' || this.peek.toUpperCase() == 'F') {
				this.tokens.push(new Token(Token.NUMBER, this.code.slice(this.lastIndex, this.index)));
				return;
			}
			//ָ������
			if(this.peek.toUpperCase() == 'E') {
				this.readch();
				//+-��
				if(this.peek == '+' || this.peek == '-') {
					this.readch();
				}
				//ָ��������λ
				while(character.isDigit(this.peek)) {
					this.readch();
				}
			}
			this.tokens.push(new Token(Token.NUMBER, this.code.slice(this.lastIndex, --this.index)));
		}
	});
});