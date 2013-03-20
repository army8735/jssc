define(function(require, exports) {
	exports.LINE = '\n';
	exports.ENTER = '\r';
	exports.BLANK = ' ';
	exports.TAB = '\t';
	exports.UNDERLINE = '_';
	exports.DOLLAR = '$';
	exports.SHARP = '#';
	exports.MINUS = '-';
	exports.AT = '@';
	exports.isDigit = function(c) {
		return c >= '0' && c <= '9';
	};
	exports.isDigit16 = function(c) {
		return exports.isDigit(c) || (c >= "a" && c <= "f") || (c >= "A" && c <= "F");
	};
	exports.isLetter = function(c) {
		return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z");
	};
});