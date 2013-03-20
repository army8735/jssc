define(function(require, exports, module) {
	var Match = require('./Match'),
		Lexer = require('../Lexer'),
		character = require('../../util/character');
	var CompleteEqual = Match.extend(function(type, result, setPReg) {
		if(setPReg === undefined) {
			setPReg = Lexer.IGNORE;
		}
		Match.call(this, type, setPReg);
		this.result = result;
	}).methods({
		start: function(c) {
			return c == this.result.charAt(0);
		},
		match: function(code, index) {
			return code.substr(--index, this.result.length) == this.result;
		}
	});
	module.exports = CompleteEqual;
});