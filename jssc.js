define(function(require, exports) {
	var factory = require('./lexer/factory'),
		Token = require('./lexer/Token'),
		render = require('./util/render'),
		cacheLine = 0,
		cacheTime = 0,
		find;

	function getText(node) {
		return node.textContent || node.innerText ||  node.firstChild ? node.firstChild.nodeValue : '';
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
			syntax = (array = new RegExp(find + '\\s*?\:\\s*?(\\w+)', 'i').exec(node.className)) === null ? null : array[1],
			start = (array = /start\s*\:\s*(\w+)/i.exec(node.className)) === null ? 0 : parseInt(array[1]),
			height = (array = /max-height\s*\:\s*(\d+)/i.exec(node.className)) === null ? 0 : parseInt(array[1]),
			tab = (array = /tab\s*\:\s*(\d+)/i.exec(node.className)) == null ? 4 : parseInt(array[1]),
			cache = (array = /cache\s*\:\s*(\d+)/i.exec(node.className)) === null ? null : parseInt(array[1]),
			newClass = (array = /class-name\s*?\:\s*?(\w+)/i.exec(node.className)) === null ? null : array[1];
		//����sh��first-line
		if(start < 1) {
			start = (array = /first-line\s*?\:\s*?(\w+)/i.exec(node.className)) === null ? 0 : parseInt(array[1]);
		}
		start = Math.max(1, start);
		var lexer = factory.lexer(syntax),
			tabBlank = '',
			div = document.createElement('div'),
			col = document.createElement('div'),
			lastCol = 0;
			ol = document.createElement('ol');
		ol.start = start;
		for(var i = 0; i < tab; i++) {
			tabBlank += '&nbsp';
		}
		lexer.cache(cache !== null ? cache : cacheLine);
		function join(tokens) {
			//�������¼���
			if(lexer.col() > lastCol) {
				lastCol = lexer.col();
				var s = [],
					i = 1,
					j;
				for(; i < lastCol; i++) {
					if(i > 9) {
						var j = i % 10;
						if(j == 0) {
							s.push('<em>' + j + '<small>' + i + '</small></em>');
						}
						else {
							s.push(j);
						}
					}
					else {
						s.push(i);
					}
				}
				col.innerHTML = s.join('');
			}
			//��Ⱦ�µĴ�����
			if(!lexer.finish() && tokens[tokens.length - 1].type() == Token.LINE) {
				tokens.pop();
			}
			var df = render(tokens, tabBlank);
			ol.appendChild(df);
			//��߾�
			var pLeft = (String(lexer.line()).length - 1) * 9 + 30 + 'px';
			col.style.paddingLeft = pLeft;
			ol.style.paddingLeft = pLeft;
		}
		join(lexer.parse(code, start));
		div.innerHTML = '<p>' + syntax + ' code</p>';
		col.className = 'col';
		div.appendChild(col);
		div.appendChild(ol);
		div.className = 'jssc';
		if(node.parentNode.tagName.toLowerCase() == 'pre') {
			node = node.parentNode;
		}
		node.parentNode.insertBefore(div, node);
		node.style.display = 'none';
		//������ɶ�ѡ������������ǳ�����������
		function parseNext() {
			if(lexer.finish()) {
				setTimeout(function() {
					parse(nodes);
				}, cacheTime);
			}
			else {
				join(lexer.parse());
				setTimeout(parseNext, cacheTime);
			}
		}
		parseNext();
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