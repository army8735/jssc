define(function(require, exports) {
	exports.LINE = '\n';
	exports.ENTER = '\r';
	exports.BLANK = ' ';
	exports.TAB = '\t';
	exports.isDigit = function(s) {
		return s >= '0' && s <= '9';
	};
	exports.isDigit16 = function(s) {
		return exports.isDigit(s) || (s >= "a" && s <= "f") || (s >= "A" && s <= "F");
	};
});