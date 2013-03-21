define(function(require, exports) {
	var factory = require('./lexer/factory'),
		cacheLine = 0,
		find;

	function getText(node) {
		return node.textContent || node.innerText ||  node.firstChild.nodeValue;
	}
	function parse(nodes) {
		if(!nodes.length) {
			return;
		}
		var node = nodes.shift();
		if(node.className.indexOf(find) == -1) {
			return parse(nodes);
		}
		var code = getText(node),
			array,
			syntax = (array = new RegExp(find + '\\s*?\:\\s*?(\\w+)', 'i').exec(node.className)) == null ? null : array[1],
			start = (array = /start\s*?\:\s*?(\w+)/i.exec(node.className)) == null ? 0 : parseInt(array[1]),
			height = (array = /max-height\s*?\:\s*?(\d+)/i.exec(node.className)) == null ? 0 : parseInt(array[1]),
			newClass = (array = /class-name\s*?\:\s*?(\w+)/i.exec(node.className)) == null ? null : array[1];
		//¼æÈÝshµÄfirst-line
		if(start < 1) {
			start = (array = /first-line\s*?\:\s*?(\w+)/i.exec(node.className)) == null ? 0 : parseInt(array[1]);
		}
		start = Math.max(1, start);
		var lexer = factory.lexer(syntax),
			res = lexer.parse(code);
		var arr = [];
		res.forEach(function(o) {
			arr.push({
				type: o.type(),
				tag: o.tag(),
				val: o.val()
			});
		});
		console.table(arr);
	}

	exports.exec = function(tagName, className) {
		tagName = tagName || 'pre';
		find = className || 'brush';
		nodes = Array.prototype.slice.call(document.getElementsByTagName(tagName), 0);
		parse(nodes);
		return exports;
	};
	exports.cache = function(n) {
		cacheLine = n;
		return exports;
	};
});