define(function(require, exports, module) {
	var Rule = require('./Rule');
	module.exports = Rule.extend(function() {
		Rule.call(this);
	});
});