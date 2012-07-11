package ru.codestage.xfltool.update 
{
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	import com.junkbyte.console.Cc;
	import com.riaspace.nativeApplicationUpdater.NativeApplicationUpdater;
	import flash.events.ErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	import flash.system.System;
	import ru.codestage.utils.string.StrUtil;
	import ru.codestage.xfltool.Main;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	/**
	 * ...
	 * @author ...
	 */
	public final class UpdateManager extends Object
	{
		private namespace UPDATE_XMLNS_1_0  = "http://ns.riaspace.com/air/framework/update/description/1.0";
		private namespace UPDATE_XMLNS_1_1  = "http://ns.riaspace.com/air/framework/update/description/1.1";
		use namespace UPDATE_XMLNS_1_0;
		use namespace UPDATE_XMLNS_1_1;
		
		private static var _instance:UpdateManager;
		
		private var _updater:NativeApplicationUpdater;
		private var _updateAlert:UpdateAlert;
		
		public static function get instance():UpdateManager
		{
			if (!_instance) _instance = new UpdateManager();
			return _instance;
		}
		
		public function UpdateManager() 
		{
			
		}
		
		private function _uninit():void 
		{
			_updater.removeEventListener(UpdateEvent.INITIALIZED, _onApplicationUpdaterInitialized);
			_updater.removeEventListener(StatusUpdateEvent.UPDATE_STATUS, _onApplicationUpdaterStatus);
			_updater.removeEventListener(ErrorEvent.ERROR, _onUpdateError);
			
			_updater.removeEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, _onUpdateDownloadError);
			_updater.removeEventListener(UpdateEvent.DOWNLOAD_COMPLETE, _onUpdateDownloadComplete);
			_updater.removeEventListener(ProgressEvent.PROGRESS, _onUpdateDownloadProgress);
			_updater.isNewerVersionFunction = null;
			_updater = null;
		}
		
		public function checkForUpdates():void
		{
			_updater = new NativeApplicationUpdater();
			_updater.updateURL = "http://codestage.ru/files/xfltool/native_update.xml"
			_updater.addEventListener(UpdateEvent.INITIALIZED, _onApplicationUpdaterInitialized);
			_updater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, _onApplicationUpdaterStatus);
			_updater.addEventListener(ErrorEvent.ERROR, _onUpdateError);
			_updater.isNewerVersionFunction = _isNewerFunction;
			_updater.initialize();
		}
		
		private function _onApplicationUpdaterInitialized(e:UpdateEvent):void 
		{
			_updater.checkNow();
		}
		
		private function _onApplicationUpdaterStatus(e:StatusUpdateEvent):void 
		{
			if (!e.available)
			{
				_uninit();
			}
			else
			{
				e.preventDefault();
				
				var desc:String;
				var descXML:XML = new XML(_updater.updateDescriptor);
				
				if (LocaleManager.instance.currentLanguage == "en_US")
				{
					desc = descXML.description.en;
				}
				else
				{
					desc = descXML.description.ru;
				}
				
				System.disposeXML(descXML);
				
				_updateAlert = new UpdateAlert(Main.instance);
				_updateAlert.showMessage(desc, _updater.updateVersion, _onUpdateAlertAnswer)
			}
		}
		
		private function _onUpdateStatusError(e:StatusUpdateErrorEvent):void 
		{
			Cc.stack(e.toString(), 1, 9);
			_uninit();
		}
		
		private function _onUpdateError(e:ErrorEvent):void 
		{
			Cc.stack(e.toString(), 1, 9);
			_uninit();
		}
		
		private function _isNewerFunction(currentVersion:String, updateVersion:String):Boolean
        {
			updateVersion = StrUtil.pad(updateVersion, 5, ".0","r");
			currentVersion = StrUtil.pad(currentVersion, 5, ".0","r");
			
			updateVersion = StrUtil.remove(updateVersion, ".", false);
			currentVersion = StrUtil.remove(currentVersion, ".", false);
			
			
            if (int(updateVersion) > int(currentVersion))
			{
				return true;
			}
			else
			{
				return false;
			}
        }
		
		private function _onUpdateDownloadComplete(e:UpdateEvent):void 
		{
			var so:SharedObject = SharedObject.getLocal("codestage.XFLTool");
			so.data.applicationStorageDirectory = File.applicationStorageDirectory.nativePath;
			so.flush();
			so = null;
			
			_updater.installUpdate();
			_uninit();
		}
		
		private function _onUpdateDownloadError(e:DownloadErrorEvent):void 
		{
			Cc.stack(e.toString(), 1, 9);
			_uninit();
		}
		
		private function _onUpdateDownloadProgress(e:ProgressEvent):void 
		{
			_updateAlert.setProgress(e.bytesLoaded / e.bytesTotal * 100);
		}
		
		private function _onUpdateAlertAnswer(answer:uint):void 
		{
			if (answer == UpdateAlert.ANSWER_YES)
			{
				_updater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, _onUpdateDownloadError);
				_updater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, _onUpdateDownloadComplete);
				_updater.addEventListener(ProgressEvent.PROGRESS, _onUpdateDownloadProgress);
				_updater.downloadUpdate();
			}
		}
		
		
		
	}

}