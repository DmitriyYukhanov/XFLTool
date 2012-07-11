package ru.codestage.xfltool.writers
{
	import com.junkbyte.console.Cc;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class XMLWriter extends Object
	{
		
		public function XMLWriter()
		{
		}
		
		public function writeStringToFile(xmlPath:File, stringToWrite:String):void
		{
			var xmlWriter:FileStream = new FileStream();
			xmlWriter.open(xmlPath, FileMode.WRITE);
			xmlWriter.writeUTFBytes(stringToWrite);
			xmlWriter.close();
			xmlWriter = null;
		}
	}

}