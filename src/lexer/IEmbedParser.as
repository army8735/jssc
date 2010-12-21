package lexer {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100122
	 */
	
	public interface IEmbedParser extends IParser {
		function embedParse(code:String, depth:int):String;
	}
}