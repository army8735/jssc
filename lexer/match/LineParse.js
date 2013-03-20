define(function(require, exports, module) {
	var Match = require('./Match'),
		Lexer = require('../Lexer'),
		character = require('../../util/character');
	var LineParse = Match.extend(function(type, begin, end, setPReg) {
		if(setPReg === undefined) {
			setPReg = Lexer.IGNORE;
		}
		Match.call(this, type, setPReg);
		this.begin = begin;
		this.end = end;
	}).methods({
		start: function(c) {
			return c == this.begin;
		},
		match: function(code, index) {
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
	});
	module.exports = LineParse;
});