package util 
{
	/**
	 * ...
	 * @author army8735
	 */
	public class I18n {
		
		static const lang:Object = {
			"chinese": ["代码", "复制", "复制成功", "主页"],
			"english": ["code", "Copy", "Copy Success", "Home"]
		}
		
		public static function getLanguage(type:String):Array {
			type = type.toLowerCase();
			return lang[type] ? lang[type] : lang["english"];
		}
		
	}

}