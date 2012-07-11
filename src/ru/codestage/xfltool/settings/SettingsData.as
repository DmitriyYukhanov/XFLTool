package ru.codestage.xfltool.settings
{
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class SettingsData extends Object
	{
		public var lastApplicationStorageDirectory:String;
		
		public var currentLanguage:String;
		public var lastXFLPath:String;
		public var lastFlashProPath:String;
		public var recentPaths:Vector.<Object> = new Vector.<Object>(5, true);
		
		public var issuesScanPublishCheck:Boolean = true;
		public var issuesScanFontsCheck:Boolean = true;
		public var issuesScanCommonCheck:Boolean = true;
		public var issuesScanPerformanceCheck:Boolean = true;
		public var issuesScanElegancyCheck:Boolean = true;
		
		public var bitmapsCompressionAuto:Boolean = true;
		public var bitmapsCompressionAutoWrite:Boolean;
		public var bitmapsCompressionLossless:Boolean;
		public var bitmapsCompressionPhoto:Boolean;
		
		public var bitmapsCompressionJPEGPublishSettings:Boolean = true;
		public var bitmapsCompressionJPEGCustom:Boolean;
		public var bitmapsCompressionPhotoQuality:String = "90";
		
		public var bitmapsCompressionAllowSmoothing:Boolean;
		public var bitmapsCompressionAllowSmoothingYes:Boolean = true;
		public var bitmapsCompressionAllowSmoothingNo:Boolean;
		
		public var bitmapsCompressionSkipCustomCompression:Boolean = true;
		
		public var firstRun:Boolean = true;
		
		public function SettingsData()
		{
			
		}
		
	}

}