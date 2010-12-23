package util 
{
	/**
	 * ...
	 * @author army8735
	 */
	public class I18n {
		
		static const lang:Object = {
			"chinese": ["代码", "复制", "复制成功"],
			"traditional": ["代碼", "複製", "複製成功"],
			"english": ["code", "Copy", "Copy Success"],
			"japanese": ["コード", "コピー", "コピー成功"],
			"russian": ["код", "копировать", "копию успеха"],
			"german": ["code", "Kopie", "Kopie Erfolg"],
			"korean": ["코드", "베끼다", "복사 성공"]
		}
		
		public static function getLanguage(type:String):Array {
			type = type.toLowerCase();
			return lang[type] ? lang[type] : lang["english"];
		}
		
	}

}