package util {
	/**
	 * ...
	 * @author army8735
	 * @version 5.0 build 20100117
	 */

	public class HashMap {
		private var hash:Object;
		private var index:int;
		
		public function HashMap(datas:Array = null):void {
			hash = new Object();
			
			if (datas != null) {
				for (var i:int = 0; i < datas.length; i++) {
					put(datas[i]);
				}
			}
		}
		
		public function put(key:String):void {
			hash[key] = true;
		}
		public function hasKey(key:String):Boolean {
			return hash[key] == true;
		}
	}
}