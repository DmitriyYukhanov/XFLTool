package ru.codestage.xfltool.settings
{
	import com.junkbyte.console.Cc;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class Settings extends Object
	{
		private static var _instance:Settings;
		private var _settingsFileName:String = "settings.dat";
		public var data:SettingsData = new SettingsData();
		
		public function Settings()
		{
			registerClassAlias("userTypeAlias", SettingsData);
		}
		
		public static function get instance():Settings
		{
			if (!_instance) _instance = new Settings();
			return _instance;
		}
		
		public function load():void
		{
			var settingsFilePath:File = File.applicationStorageDirectory.resolvePath(_settingsFileName);
			Cc.log(settingsFilePath.nativePath);
			if (settingsFilePath.exists)
			{
				var settingsFile:FileStream = new FileStream();
				settingsFile.open(settingsFilePath, FileMode.READ);
				data = settingsFile.readObject();
				settingsFile.close();
			}
		}
		
		public function save():void
		{
			var settingsFilePath:File = File.applicationStorageDirectory;
			settingsFilePath = settingsFilePath.resolvePath(_settingsFileName);
			var settingsFile:FileStream = new FileStream();
			settingsFile.open(settingsFilePath, FileMode.WRITE);
			settingsFile.writeObject(data);
			settingsFile.close();
		}
		
		public function moveSettings(from:File):void
		{
			if (from.resolvePath(_settingsFileName).exists)
			{
				from.copyTo(File.applicationStorageDirectory.resolvePath(_settingsFileName),true);
			}
		}
	}

}