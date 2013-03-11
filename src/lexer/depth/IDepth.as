package lexer.depth {
	/**
	 * ...
	 * @author army8735
	 */
	
	public interface IDepth {
		
		function needCal(tag:int, value:String):Boolean;
		function calDepth(value:String):int;
		
	}

}