define(function(require, exports, module) {
	var Class = require('../util/Class');
	module.exports = Class(function(type, val) {
		this.t = type;
		this.v = val;
	}).methods({
		type: function() {
			return this.t;
		},
		val: function() {
			return this.v;
		}
	}).statics({
		OTHER: 0,
		BLANK: 1,
		TAB: 2,
		LINE: 3,
		NUMBER: 4,
		ID: 5,
		COMMENT: 6,
		STRING: 7,
		SIGN: 8
	});
});