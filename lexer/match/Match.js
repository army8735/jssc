define(function(require, exports, module) {
	var Class = require('../../util/Class');
	module.exports = Class(function(type, setPReg) {
		this.type = type;
		this.setPReg = setPReg;
		this.result = null;
	}).methods({
		tokeyType: function() {
			return this.type;
		},
		perlReg: function() {
			return this.setPReg;
		},
		content: function() {
			return this.result;
		},
		start: function(c) {
			//需被实现
			return false;
		},
		match: function(c) {
			//需被实现
			return false;
		}
	});
});