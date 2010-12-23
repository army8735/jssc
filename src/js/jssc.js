/**
 * ...
 * @author army8735
 * @version 5.0 build 20101223
 */

function(id, url, css, js, swf, lang) {
	var isIE = (navigator.appName.indexOf("Microsoft") != -1);
	var index = 0;
	var aList = [];
	var oSwf = null;
	var oPre = null;
	var oLast = null;
	var oCursor = null;

	function $(name) {
		return document.createElement(name);
	}
	function getSwf(name) {
		if(isIE) {
			return window[name];
		}
		else {
			return document[name];
		}
	}
	function getText(node) {
		var code = node.textContent || node.innerText;
		if(!code && node.firstChild) {
			code = node.firstChild.nodeValue;
		}
		return code || "";
	}
	function fold(li) {
		var depth = parseInt(li.rel || li.getAttribute("rel"));
		var next = li.nextSibling;
		if(!next) {
			return;
		}
		var hide = (next.className == "hide");
		if(li.className != "fold" && (next.rel || next.getAttribute("rel")) <= depth) {
			return;
		}
		if(hide) {
			removeClass(li, "fold");
		}
		else {
			addClass(li, "fold");
		}
		while(next && parseInt(next.rel || next.getAttribute("rel")) > depth) {
			if(parseInt(next.rel || next.getAttribute("rel")) <= depth) {
				return;
			}
			if(hide) {
				next.className = "";
			}
			else {
				next.className = "hide";
			}
			next = next.nextSibling;
		}
	}
	function copyOk() {
		alert(lang[2]);
	}
	function hasClass(node, name) {
		return node.className.indexOf(name) != -1;
	}
	function addClass(node, name) {
		if(name.length && !hasClass(node, name)) {
			if(node.className.length) {
				node.className += " " + name;
			}
			else {
				node.className = name;
			}
		}
	}
	function removeClass(node, name) {
		if(name.length && hasClass(node, name)) {
			if(node.className == name) {
				node.className = "";
			}
			else if(node.className.indexOf(name) == 0) {
				node.className = node.className.replace(name + " ", "");
			}
			else {
				node.className = node.className.replace(" " + name, "");
			}
		}
	}

	var jssc = {
		exec: function() {
			oSwf = getSwf(swf);
			if(!oSwf) {
				return;
			}
			//取得所有符合规则的pre节点依次解析
			var aPre = document.getElementsByTagName("pre"),
				aTextaera = document.getElementsByTagName("textarea");
			for(var i = 0, length = aPre.length; i < length; i++) {
				if(aPre[i].style.display != "none" && aPre[i].className.indexOf(id) > -1) {
					aList.push(aPre[i]);
				}
			}
			for(var i = 0, length = aTextaera.length; i < length; i++) {
				if(aTextaera[i].style.display != "none" && aTextaera[i].className.indexOf(id) > -1) {
					aList.push(aTextaera[i]);
				}
			}
			this.parseNext();
		},
		parseNext: function() {
			if(index < aList.length) {
				oPre = aList[index++];
				oSwf.parse(getText(oPre), oPre.className);
			}
		},
		genRes: function(syntax, start, height, newClass, res) {
			var oDiv = $("div");
			addClass(oDiv, css);
			addClass(oDiv, newClass);

			var oTitle = $("p");
			oTitle.innerHTML = syntax + " " + lang[0];
			oDiv.appendChild(oTitle);

			var oCopy = $("div");
			oCopy.className = "copy";
			if(window.clipboardData && window.clipboardData.setData) {
				oCopy.innerHTML = lang[1];
				oCopy.onclick = function() {
					if(window.clipboardData.setData("text", getText(oDiv.nextSibling))) {
						copyOk();
					}
				}
			}
			else {
				oCopy.innerHTML = "<object data=\"" + url + "\" type=\"application/x-shockwave-flash\" width=\"100\" height=\"20\"><param name=\"wmode\" values=\"transparent\"/><param name=\"allowScriptAccess\" value=\"always\"/><param name=\"flashvars\" value=\"copy=" + index + "&lang=" + lang[1] + "\"/></object>";
			}
			oDiv.appendChild(oCopy);

			var oOl = $("ol");
			oOl.start = start;
			oOl.className = syntax;
			oOl.innerHTML = res;
			var line = String(oOl.childNodes.length);
			oOl.style.paddingLeft = Math.max((line.length + 2) * 9, 30) + "px";
			oOl.onmouseover = function(event) {
				event = event || window.event;
				var target = event.srcElement || event.target;
				//给总的代码ol添加事件，但获取侦听对象却需要是触发的节点对象li
				while(target.tagName && target.tagName.toLowerCase() != "ol" && target.tagName.toLowerCase() != "li") {
					target = target.parentNode;
				}
				if(target.tagName.toLowerCase() != "li") {
					return;
				}
				if(oCursor) {
					removeClass(oCursor, "actived");
				}
				addClass(target, "actived");
				oCursor = target;
			}
			oOl.onclick = function(event) {
				event = event || window.event;
				var target = event.srcElement || event.target;
				while(target.tagName && target.tagName.toLowerCase() != "ol" && target.tagName.toLowerCase() != "li") {
					target = target.parentNode;
				}
				if(target.tagName.toLowerCase() != "li") {
					return;
				}
				fold(target);
			}
			oDiv.appendChild(oOl);

			oPre.parentNode.insertBefore(oDiv, oPre);
			oPre.style.display = "none";
			oLast = oOl;
			if(height > 20 && oOl.clientHeight > height) {
				oOl.style.height = height + "px";
			}

			setTimeout(function() {
				jssc.parseNext();
			}, 0);
		},
		copy: function(count) {
			setTimeout(copyOk, 100);
			return getText(aList[count-1]);
		}
	};
	window[js] = jssc;
}