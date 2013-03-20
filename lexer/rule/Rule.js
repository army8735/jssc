define(function(require, exports, module) {
	var Class = require('../../util/Class');
	module.exports = Class(function(words, pReg) {
		this.words = words || [];
		this.pReg = pReg || false;
		this.matchList = [];
	}).methods({
		perlReg: function() {
			return this.pReg;
		},
		addMatch: function(match) {
			this.matchList.push(match);
			return this;
		},
		matches: function() {
			return this.matchList;
		}
	});
});