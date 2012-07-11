package ru.codestage.xfltool.readers
{
	import com.junkbyte.console.Cc;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class FileReader extends Object
	{
		
		public function FileReader()
		{
			
		}
		
		public function readFileToXML(xmlPath:File):XML
		{
			return XML(readFileToString(xmlPath));
		}
		
		public function readFileToString(xmlPath:File):String
		{
			var result:String;
			if (xmlPath.exists)
			{
				var xmlLoader:FileStream = new FileStream();
				xmlLoader.open(xmlPath, FileMode.READ);
				result = xmlLoader.readUTFBytes(xmlLoader.bytesAvailable);
				xmlLoader.close();
				xmlLoader = null;
			}
			else
			{
				result = null;
				// TODO: make an Alert!
				Cc.fatal(LocaleManager.getString(LocaleManager.XML_READ_ERROR,xmlPath.nativePath));
			}
			return result;
		}
	}

}