define(function(require, exports, module) {
	var Match = require('./Match'),
		Lexer = require('../Lexer'),
		character = require('../../util/character');
	var LineSearch = Match.extend(function(type, begin, end, contain, setPReg) {
		if(contain === undefined) {
			contain = false;
		}
		Match.call(this, type, setPReg);
		this.begin = begin;
		this.end = end;
		this.contain = contain;
	}).methods({
		match: function(c, code, index) {
			if(this.begin == code.substr(index - 1, this.begin.length)) {
				var res = code.substr(--index, this.begin.length) == this.begin;
				//begin必须完全相等
				if(res) {
					var i = code.indexOf(this.end, index + this.begin.length);
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
			return false;
		}
	});
	module.exports = LineSearch;
});