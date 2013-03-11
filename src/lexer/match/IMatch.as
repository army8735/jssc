package lexer.match {
	/**
	 * ...
	 * @author army8735
	 */
	public interface IMatch {
		
		function start(char:String):Boolean;
		function match(code:String, index:int):Boolean;
		function get content():String;
		function get tag():int;
		function get perlReg():int;
		
	}

}