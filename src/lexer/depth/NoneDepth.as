package lexer.depth {
	/**
	 * ...
	 * @author army8735
	 */
	
	public class NoneDepth implements IDepth {
		
		public function needCal(tag:int, value:String):Boolean {
			return false;
		}
		public function calDepth(value:String):int {
			return 0;
		}
		
	}

}