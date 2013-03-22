define(function(require, exports, module) {
	var Class = require('../util/Class'),
		types,
		Token = Class(function(type, val) {
			this.t = type;
			this.v = val;
		}).methods({
			type: function(t) {
				if(t !== undefined) {
					this.t = t;
				}
				return this.t;
			},
			val: function() {
				return this.v;
			},
			tag: function() {
				return Token.type(this.t);
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
			SIGN: 8,
			REG: 9,
			KEYWORD: 10,
			type: function(tag) {
				if(types === undefined) {
					types = [];
					Object.keys(Token).forEach(function(o) {
						if(typeof Token[o] == 'number') {
							types[Token[o]] = o;
						}
					});
				}
				return types[tag];
			}
		});
	module.exports = Token;
});