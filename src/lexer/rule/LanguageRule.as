package lexer.rule {
	/**
	 * ...
	 * @author army8735
	 */
	import lexer.depth.*;
	import lexer.match.*;
	import util.*;
	
	public class LanguageRule {
		private var words:HashMap;
		private var perlReg:Boolean;
		private var matches:Vector.<IMatch>;
		private var deps:Vector.<IDepth>;
		
		public function LanguageRule(words:Array, perlReg:Boolean = false) {
			this.words = new HashMap(words);
			this.perlReg = perlReg;
			matches = new Vector.<IMatch>();
			deps = new Vector.<IDepth>();
		}
		
		public function get keyWords():HashMap {
			return words;
		}
		public function get perlRegular():Boolean {
			return perlReg;
		}
		public function get matchList():Vector.<IMatch> {
			return matches;
		}
		public function get lanDeps():Vector.<IDepth> {
			return deps;
		}
		
		protected function addMatch(mat:IMatch):void {
			matches.push(mat);
		}
		protected function addDep(dep:IDepth):void {
			deps.push(dep);
		}
		
	}

}