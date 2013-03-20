define(function(require, exports, module) {
	var Match = require('./Match'),
		Lexer = require('../Lexer'),
		character = require('../../util/character');
	var LineSearch = Match.extend(function(type, begin, end, contain, setPReg) {
		if(contain === undefined) {
			contain = false;
		}
		if(setPReg === undefined) {
			setPReg = Lexer.IGNORE;
		}
		Match.call(this, type, setPReg);
		this.begin = begin;
		this.end = end;
	}).methods({
		start: function(c) {
			return c == this.begin.charAt(0);
		},
		match: function(code, index) {
			var res = code.slice(--index, this.begin.length) == this.begin;
			//begin必须完全相等
			if(res) {
				var i = code.indexOf(this.end, index + this.start.length);
				if(i == -1) {
					i = code.length;
				}
				else if(this.contain) {
					i += this.end.length;
				}
				this.result = code.slice(index, i);
			}
			return res;
		}
	});
	module.exports = LineSearch;
});