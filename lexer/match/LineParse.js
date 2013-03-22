define(function(require, exports, module) {
	var Match = require('./Match'),
		Lexer = require('../Lexer'),
		character = require('../../util/character');
	var LineParse = Match.extend(function(type, begin, end, setPReg) {
		Match.call(this, type, setPReg);
		this.begin = begin;
		this.end = end;
	}).methods({
		match: function(c, code, index) {
			if(this.begin == code.substr(index - 1, this.begin.length)) {
				var len = code.length,
					lastIndex = index - 1;
				while(index < len) {
					var c = code.charAt(index++);
					//ЧЄТе
					if(c == '\\') {
						index++;
					}
					else if(c == this.end) {
						break;
					}
				}
				this.result = code.slice(lastIndex, index);
				return true;
			}
			return false;
		},
		val: function() {
			return this.content().slice(this.begin.length, -this.end.length);
		}
	});
	module.exports = LineParse;
});