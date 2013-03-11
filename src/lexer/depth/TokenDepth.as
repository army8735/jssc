package lexer.depth {
	/**
	 * ...
	 * @author army8735
	 */
	
	public class TokenDepth implements IDepth {
		private var tag:int;
		private var add:String;
		private var reduce:String;
		
		public function TokenDepth(tag:int, add:String, reduce:String) {
			this.tag = tag;
			this.add = add;
			this.reduce = reduce;
		}
		
		public function needCal(tag:int, value:String):Boolean {
			return this.tag == tag && (value == add || value == reduce);
		}
		public function calDepth(value:String):int {
			if (value == add) {
				return 1;
			}
			else if (value == reduce) {
				return -1;
			}
			return 0;
		}
	}

}