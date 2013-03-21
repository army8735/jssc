define(function(require, exports) {
	var factory = require('./lexer/factory'),
		Token = require('./lexer/Token'),
		cacheLine = 0,
		cacheTime = 0,
		find;

	function getText(node) {
		return node.textContent || node.innerText ||  node.firstChild.nodeValue;
	}
	function parse(nodes) {
		if(!nodes.length) {
			return;
		}
		var node = nodes.shift();
		if(node.className.indexOf(find) == -1 || node.style.display == 'none') {
			return parse(nodes);
		}
		var code = getText(node),
			array,
			syntax = (array = new RegExp(find + '\\s*?\:\\s*?(\\w+)', 'i').exec(node.className)) == null ? null : array[1],
			start = (array = /start\s*\:\s*(\w+)/i.exec(node.className)) == null ? 0 : parseInt(array[1]),
			height = (array = /max-height\s*\:\s*(\d+)/i.exec(node.className)) == null ? 0 : parseInt(array[1]),
			tab = (array = /tab\s*\:\s*(\d+)/i.exec(node.className)) == null ? 4 : parseInt(array[1]),
			cache = (array = /cache\s*\:\s*(\d+)/i.exec(node.className)) == null ? null : parseInt(array[1]),
			newClass = (array = /class-name\s*?\:\s*?(\w+)/i.exec(node.className)) == null ? null : array[1];
		//兼容sh的first-line
		if(start < 1) {
			start = (array = /first-line\s*?\:\s*?(\w+)/i.exec(node.className)) == null ? 0 : parseInt(array[1]);
		}
		start = Math.max(1, start);
		var lexer = factory.lexer(syntax),
			tabBlank = '';
		for(var i = 0; i < tab; i++) {
			tabBlank += '&nbsp';
		}
		lexer.cache(cache != null ? cache : cacheLine);
		var tokens = lexer.parse(code);
		if(!lexer.finish() && tokens[tokens.length - 1].type() == Token.LINE) {
			tokens.pop();
		}
		var res = render(tokens, tabBlank),
			div = document.createElement('div');
			ol = document.createElement('ol');
		ol.innerHTML = res;
		ol.start = start;
		ol.style.paddingLeft = (String(lexer.line()).length - 1) * 10 + 30 + 'px';
		div.innerHTML = '<p>' + syntax + ' code</p>';
		div.appendChild(ol);
		div.className = 'jssc';
		node.parentNode.insertBefore(div, node);
		node.style.display = 'none';
		//根据完成度选择继续分析还是持续分析缓存
		function parseNext() {
			if(lexer.finish()) {
				setTimeout(function() {
					parse(nodes);
				}, cacheTime);
			}
			else {
				var tokens = lexer.parseCache();
				if(!lexer.finish() && tokens[tokens.length - 1].type() == Token.LINE) {
					tokens.pop();
				}
				var res = render(tokens, tabBlank);
				ol.innerHTML += res;
				ol.style.paddingLeft = (String(lexer.line()).length - 1) * 10 + 30 + 'px';
				setTimeout(parseNext, cacheTime);
			}
		}
		parseNext();
	}
	function render(tokens, tabBlank) {
		var res = ['<li>'];
		tokens.forEach(function(o) {
			if(o.type() == Token.LINE) {
				res.push('</li><li>');
			}
			else if(o.type() == Token.BLANK) {
				res.push('&nbsp;');
			}
			else if(o.type() == Token.TAB) {
				res.push(tabBlank);
			}
			else if(o.type() == Token.SIGN) {
				res.push(o.val());
			}
			else {
				res.push('<span class="' + Token.type(o.type()).toLowerCase() + '">' + o.val().replace(/\t/g, tabBlank).replace(/ /g, '&nbsp;').replace(/\n/g, '</span></li><li><span class="' + Token.type(o.type()).toLowerCase() + '">') + '</span>');
			}
		});
		res.push('</li>');
		return res.join('');
	}

	exports.exec = function(tagName, className) {
		tagName = tagName || 'code';
		find = className || 'brush';
		nodes = Array.prototype.slice.call(document.getElementsByTagName(tagName), 0);
		parse(nodes);
		return exports;
	};
	exports.cache = function(i) {
		cacheLine = i;
		return exports;
	};
	exports.time = function(i) {
		cacheTime = i;
		return exports;
	};
});