package ru.codestage.xfltool.scanners.base
{
	import flash.filesystem.File;
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public class ScannerBase extends Object
	{
		protected var _log:Function /*(newLogLines:String, type:String = null, hint:String = null):void*/;
		
		public function ScannerBase(log:Function)
		{
			this._log = log;
		}
	}

}