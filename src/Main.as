package {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20101223
	 * @link http://code.google.com/p/jssc/
	 */
	import flash.display.*;
	import flash.events.*;
	import flash.external.*;
	import flash.system.*;
	import flash.text.*;
	import js.*;
	import util.*;
	import lexer.*;
	import lexer.other.*;
	import lexer.cseries.ecma.*;
	import lexer.cseries.compile.candcpp.*;
	import lexer.cseries.compile.java.*;
	import lexer.cseries.other.*;
	import lexer.markup.*;
	
	public class Main extends Sprite {
		private var find:String;
		private var url:String;
		private var css:String;
		private var jsVar:String;
		private var swf:String;
		private var lang:String;
		
		public function Main():void {
			Security.allowDomain("*");
			var params:Object = root.loaderInfo.parameters;
			jsVar = params.js || "jssc";
			lang = params.lang || "english";
			//作为copy功能
			if (params.copy !== undefined) {
				//舞台不缩放，左上角对齐并禁用右键菜单
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				stage.showDefaultContextMenu = false;
				initCopy(int(params.copy));
			}
			//作为分析器功能
			else if (params.find) {
				find = params.find;
				url = params.url || "jssc5.swf";
				css = params.css || "jssc";
				swf = params.swf || "jssc5";
				initEI();
			}
		}
		
		private function initEI():void {
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("parse", onParseHandler);
				ExternalInterface.call(CallJs.INIT, find, url, css, jsVar, swf, I18n.getLanguage(lang));
				ExternalInterface.call(jsVar + ".exec");
			}
		}
		private function initCopy(id:int):void {
			var tf:TextField = getChildAt(0) as TextField;
			tf.text = lang;
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0);
			sprite.graphics.drawRect(stage.width - tf.textWidth - 5, 0, stage.width, stage.height);
			sprite.graphics.endFill();
			sprite.buttonMode = true;
			sprite.alpha = 0;
			addChild(sprite);
			sprite.addEventListener(MouseEvent.CLICK, function() {
				tf.textColor = 0x0066CC;
				if (ExternalInterface.available) {
					var s:String = ExternalInterface.call(jsVar + ".copy", id);
					System.setClipboard(s);
				}
			});
			sprite.addEventListener(MouseEvent.MOUSE_OVER, function() {
				tf.textColor = 0xFF0000;
			});
			sprite.addEventListener(MouseEvent.MOUSE_OUT, function() {
				tf.textColor = 0x0066CC;
			});
		}
		
		private function onParseHandler(code:String, className:String):void {
			//先清除可能多余的\r
			if (code.indexOf("\r") > -1) {
				code = code.replace(/\r/g, "");
			}
			var array:Array;
			//语法、开始行数、最大高度、新样式类
			var syntax:String = (array = new RegExp(find + "\\s*?\:\\s*?(\\w+)", "i").exec(className)) == null ? null : array[1];
			var start:int = (array = /start\s*?\:\s*?(\w+)/i.exec(className)) == null ? 0 : int(array[1]);
			//兼容sh的first-line
			if (start < 1) {
				start = (array = /first-line\s*?\:\s*?(\w+)/i.exec(className)) == null ? 0 : int(array[1]);
			}
			if (start < 1) {
				start = 1;
			}
			var height:int = (array = /max-height\s*?\:\s*?(\d+)/i.exec(className)) == null ? 0 : int(array[1]);
			var newClass:String = (array = /class-name\s*?\:\s*?(\w+)/i.exec(className)) == null ? "" : array[1];
			//获取分析器进行解析
			var parser:IParser = getParser(syntax);
			var result:String = parser.parse(code);
			//传回高亮好的代码
			if (ExternalInterface.available) {
				ExternalInterface.call(jsVar + ".genRes", syntax, start, height, newClass, result);
			}
		}
		private function getParser(syntax:String):IParser {
			switch(syntax.toLowerCase()) {
				case "js":
				case "javascript":
				case "ecmascript":
				case "jscript":
					return new JavascriptParser();
				case "as":
				case "as2":
				case "as3":
				case "actionscript":
				case "flash":
					return new ActionscriptParser();
				case "c":
					return new CParser();
				case "c++":
				case "cpp":
				case "cplusplus":
					return new CppParser();
				case "java":
					return new JavaParser();
				case "php":
					return new PhpParser();
				case "html":
				case "xhtml":
				case "htm":
					return new HtmlParser();
				case "css":
					return new CssParser();
				case "xml":
					return new XmlParser();
				default:
					return new UnknowParser();
			}
		}
	}
}