package util {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100117
	 */
	
	public class StringBuilder {
		private var s:String;
		
		public function StringBuilder(s:String = ""):void {
			this.s = s;
		}
		
		public function append(s:String):void {
			this.s += s;
		}
		public function has(s:String):Boolean {
			return this.s.indexOf(s) > -1;
		}
		public function clear():void {
			s = "";
		}
		public function toString():String {
			return s;
		}
	}
}