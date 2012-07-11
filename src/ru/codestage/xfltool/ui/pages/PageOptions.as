package ru.codestage.xfltool.ui.pages
{
	import com.bit101.components.Component;
	import com.bit101.components.IndicatorLight;
	import com.bit101.components.InputText;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import com.junkbyte.console.Cc;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.system.Capabilities;
	import ru.codestage.xfltool.readers.FileReader;
	import ru.codestage.xfltool.settings.Settings;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	import ru.codestage.xfltool.ui.pages.BasePage;

	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class PageOptions extends BasePage
	{
		public var flashProPath:File;
		
		private var _flashProPathEdit:InputText;
		private var _browseBtn:PushButton;
		private var _flashProFoundStatus:IndicatorLight;
		
		public function PageOptions(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			super(parent, xpos, ypos);
		}
		
		override public function initialize(buildedElements:Vector.<Component>):void
		{
			_flashProPathEdit = (buildedElements[0] as InputText);
			_browseBtn = (buildedElements[1] as PushButton);
			_flashProFoundStatus = (buildedElements[2] as IndicatorLight);
			
			_flashProPathEdit.addEventListener(Event.CHANGE, _onFlashProPathChange);
			_browseBtn.addEventListener(MouseEvent.CLICK, _onBrowse);
			
			if (Settings.instance.data.lastFlashProPath != null)
			{
				_flashProPathEdit.text = Settings.instance.data.lastFlashProPath;
				_onFlashProPathChange(null);
			}
			
			addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, _onDragIn);
			addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, _onDragDrop);
			
			onResize(null);
		}
		
		private function _onDragIn(e:NativeDragEvent):void 
		{
			if(e.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
			{
				var files:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				if(files.length == 1)
				{
					var allow:Boolean = false;
					var droppedFile:File = File(files[0]);
					if (droppedFile.extension == "exe" || droppedFile.extension == "app")
					{
						allow = true;
						//Cc.log(droppedFile.name.substr(0,droppedFile.name.length-4));
					}
					
					if (allow)
					{
						NativeDragManager.acceptDragDrop(this);
					}
				}
			}
		}
		
		private function _onDragDrop(e:NativeDragEvent):void 
		{
			var files:Array = (e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array);
			var droppedFile:File = File(files[0]);
			
			_flashProPathEdit.text = droppedFile.nativePath;
			_onFlashProPathChange(null);
			
			e.stopImmediatePropagation();
		}
		
		private function _onFlashProPathChange(e:Event):void
		{
			var _exists:Boolean = false;
			
			if (!flashProPath) flashProPath = new File();
			
			try
			{
				flashProPath.nativePath = _flashProPathEdit.text;
				
				if ((flashProPath.extension == "exe") || (flashProPath.extension == "app"))
				{
					_exists = true;
				}
			}
			catch (e:Error)
			{
				_exists = false;
			}
			
			if (!_exists)
			{
				Settings.instance.data.lastFlashProPath = null;
				
				_flashProFoundStatus.color = 0xFF0000;
			}
			else
			{
				Settings.instance.data.lastFlashProPath = flashProPath.nativePath;
				
				_flashProFoundStatus.color = 0x00FF00;
				
			}
		}
		
		private function _onBrowse(e:MouseEvent):void
		{
			if (!flashProPath) flashProPath = new File();
			flashProPath.addEventListener(Event.SELECT, _onFlashProSelected);
			
			var filter:Array;
			
			if (Capabilities.os.indexOf("Mac") != -1)
			{
				filter = [new FileFilter(LocaleManager.getString(LocaleManager.GUI_APPLICATION), "*.app")];
			}
			else
			{
				filter = [new FileFilter(LocaleManager.getString(LocaleManager.GUI_EXECUTABLE), "*.exe")];
			}
			
			flashProPath.browseForOpen(LocaleManager.getString(LocaleManager.GUI_BROWSE_FLASH_PRO_TITLE), filter);
		}
		
		private function _onFlashProSelected(e:Event):void
		{
			flashProPath.removeEventListener(Event.SELECT, _onFlashProSelected);
			_flashProPathEdit.text = flashProPath.nativePath;
			_onFlashProPathChange(null);
		}
		
		override public function onResize(e:Event):void
		{
			_browseBtn.x = stage.stageWidth - _browseBtn.width - 20;
			_flashProPathEdit.width = _browseBtn.x - _flashProPathEdit.x - 3;
			_flashProFoundStatus.x = _flashProPathEdit.width -17;
			
			_flashProPathEdit.draw();
		}
	}
}