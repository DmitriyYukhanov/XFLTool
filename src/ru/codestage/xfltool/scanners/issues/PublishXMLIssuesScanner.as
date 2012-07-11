package ru.codestage.xfltool.scanners.issues
{
	import flash.filesystem.File;
	import ru.codestage.xfltool.readers.FileReader;
	import ru.codestage.xfltool.scanners.base.ScannerBase;
	import ru.codestage.xfltool.ui.controls.log.LogStyle;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class PublishXMLIssuesScanner extends ScannerBase
	{
		
		public function PublishXMLIssuesScanner(log:Function)
		{
			super(log);
		}
		
		public function scanPublishXML(targetXML:XML, metadataXML:XML):uint
		{
			var issues:uint = 0;
			
			_log(LocaleManager.getString(LocaleManager.PUBLISH_SETTINGS_SCAN_STARTED), LogStyle.TYPE_TITLE);
			if (targetXML..ActionScriptVersion[0] == 3)
			{
				if (targetXML..AS3Coach[0] == 4)
				{
					issues++;
					_log(LocaleManager.getString(LocaleManager.WARNINGS_IN_PUBLISH), LogStyle.TYPE_IMPORTANT);
					_log(LocaleManager.getString(LocaleManager.HINT_WARNINGS_MODE), LogStyle.TYPE_CONTEXT_HINT);
				}
			}
			
			if (targetXML..CompressMovie[0] == 0)
			{
				issues++;
				_log(LocaleManager.getString(LocaleManager.COMPRESS_IN_PUBLISH), LogStyle.TYPE_IMPORTANT);
				_log(LocaleManager.getString(LocaleManager.HINT_COMPRESSION_PUBLISH), LogStyle.TYPE_CONTEXT_HINT);
			}
			
			
			
			if (targetXML..IncludeXMP[0] == 1)
			{
				var metaUsed:Boolean = false;
				
				if (metadataXML != null && String(metadataXML) )
				{
					if (String(metadataXML).indexOf("<dc:title>") > -1)
					{
						metaUsed = true;
					}
				}
				
				if (!metaUsed)
				{
					issues++;
					_log(LocaleManager.getString(LocaleManager.XMP_IN_PUBLISH),LogStyle.TYPE_IMPORTANT);
					_log(LocaleManager.getString(LocaleManager.HINT_XMP_PUBLISH), LogStyle.TYPE_CONTEXT_HINT);
				}
			}
			
			if (issues == 0)
			{
				_log(LocaleManager.getString(LocaleManager.PUBLISH_FOUND,"0"), LogStyle.TYPE_GOOD);
			}
			else
			{
				_log(LocaleManager.getString(LocaleManager.PUBLISH_FOUND,issues), LogStyle.TYPE_BAD);
			}
			_log(LocaleManager.getString(LocaleManager.PUBLISH_FINISHED));
			
			return issues;
		}
	}
}