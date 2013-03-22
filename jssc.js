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
		ol.appendChild(res);
		ol.start = start;
		ol.style.paddingLeft = (String(lexer.line()).length - 1) * 9 + 30 + 'px';
		div.innerHTML = '<p>' + syntax + ' code</p>';
		div.appendChild(ol);
		div.className = 'jssc';
		if(node.parentNode.tagName.toLowerCase() == 'pre') {
			node = node.parentNode;
		}
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
				var df = render(tokens, tabBlank);
				ol.appendChild(df);
				ol.style.paddingLeft = (String(lexer.line()).length - 1) * 9 + 30 + 'px';
				setTimeout(parseNext, cacheTime);
			}
		}
		parseNext();
	}
	function render(tokens, tabBlank) {
		var df = document.createDocumentFragment(),
			li = document.createElement('li'),
			temp = [];
		tokens.forEach(function(o) {
			if(o.type() == Token.LINE) {
				if(!temp.length) {
					temp.push('&nbsp;');
				}
				li.innerHTML = temp.join('');
				df.appendChild(li);
				li = document.createElement('li');
				temp = [];
			}
			else if(o.type() == Token.BLANK) {
				temp.push('&nbsp;');
			}
			else if(o.type() == Token.TAB) {
				temp.push(tabBlank);
			}
			else if(o.type() == Token.SIGN) {
				temp.push(escapeHtml(o.val()));
			}
			else {
				if(o.val().indexOf('\n') == -1) {
					temp.push('<span class="' + Token.type(o.type()).toLowerCase() + '">' + escapeHtml(o.val()).replace(/\t/g, tabBlank).replace(/ /g, '&nbsp;') + '</span>');
				}
				else {
					var arr = o.val().split('\n'),
						len = arr.length;
					arr.forEach(function(s, i) {
						if(i == 0) {
							temp.push('<span class="' + Token.type(o.type()).toLowerCase() + '">' + escapeHtml(s).replace(/\t/g, tabBlank).replace(/ /g, '&nbsp;') + '</span>');
							li.innerHTML = temp.join('');
							df.appendChild(li);
						}
						else if(i == len - 1) {
							temp = [];
							temp.push('<span class="' + Token.type(o.type()).toLowerCase() + '">' + escapeHtml(s).replace(/\t/g, tabBlank).replace(/ /g, '&nbsp;') + '</span>');
						}
						else {
							li.innerHTML = '<span class="' + Token.type(o.type()).toLowerCase() + '">' + escapeHtml(s).replace(/\t/g, tabBlank).replace(/ /g, '&nbsp;') + '</span>';
							df.appendChild(li);
						}
						li = document.createElement('li');
					});
				}
			}
		});
		if(!temp.length) {
			temp.push('&nbsp;');
		}
		li.innerHTML = temp.join('');
		df.appendChild(li);
		return df;
	}
	function escapeHtml(str) {
		str = str || '';
		var xmlchar = {
			"&": "&amp;",
			"<": "&lt;",
			">": "&gt;"
		};
		return str.replace(/[<>&]/g, function($1){
			return xmlchar[$1];
		})
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