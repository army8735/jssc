define(function(require, exports, module) {
	var Class = require('../util/Class');
	return Class(function(type, val) {
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
		BLANK: 0,
		TAB: 1,
		LINE: 2,
		NUMBER: 3
	});
});