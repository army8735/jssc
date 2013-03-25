define(function(require, exports, module) {
	var Match = require('./Match'),
		Lexer = require('../Lexer');
	var RegMatch = Match.extend(function(type, reg, setPReg) {
		Match.call(this, type, setPReg);
		this.reg = reg;
	}).methods({
		match: function(c, code, index) {
			var res = this.reg.exec(code.slice(index - 1));
			if(res) {
				this.result = res[0];
				return true;
			}
			return false;
		}
	});
	module.exports = RegMatch;
});