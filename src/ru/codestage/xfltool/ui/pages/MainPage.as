package ru.codestage.xfltool.ui.pages
{
	import air.update.ApplicationUpdaterUI;
	import com.bit101.components.ComboBox;
	import com.bit101.components.Component;
	import com.bit101.components.IndicatorLight;
	import com.bit101.components.InputText;
	import com.bit101.components.List;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import deng.fzip.FZip;
	import deng.fzip.FZipErrorEvent;
	import deng.fzip.FZipFile;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.desktop.Updater;
	import flash.events.IOErrorEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import com.junkbyte.console.Cc;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filesystem.File;
	import ru.codestage.utils.string.StrUtil;
	import ru.codestage.xfltool.settings.Settings;
	import ru.codestage.xfltool.settings.SettingsData;
	import ru.codestage.xfltool.ui.builder.UIBuilder;
	import ru.codestage.xfltool.ui.controls.alert.Alert;
	import ru.codestage.xfltool.ui.controls.log.LogStyle;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	import ru.codestage.xfltool.ui.pages.constants.PageTypes;
	import ru.codestage.xfltool.utils.FileUtil;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class MainPage extends Panel
	{
		public var currentPage:BasePage;
		public var xflDirectoryPath:File = new File();
		public var xflPath:File = new File();
		public var subPages:Vector.<BasePage>;
		public var currentSubpage:BasePage = null;
		public var alert:Alert;
		
		private var _xflPathEdit:InputText;
		private var _browseBtn:PushButton;
		private var _xflFoundStatus:IndicatorLight;
		private var _pageSelector:ComboBox;
		private var _pagesPanel:Panel;
		private var _recentXFLPaths:List;
		private var _showRecentBtn:PushButton;
		private var _XFLUnpacked:Boolean = false;
		private var _onAskForFlaUncompressAnswer:Function;
		private var _onReadyForJob:Function;
		
		public function MainPage()
		{
			
		}
		
		public function initialize(buildedElements:Vector.<Component>):void
		{
			subPages = new Vector.<BasePage>(PageTypes.PAGES_COUNT, true);
			
			_xflPathEdit = (buildedElements[0] as InputText);
			_browseBtn = (buildedElements[1] as PushButton);
			_xflFoundStatus = (buildedElements[2] as IndicatorLight);
			_pageSelector = (buildedElements[3] as ComboBox);
			_pagesPanel = (buildedElements[4] as Panel);
			alert = (buildedElements[5] as Alert);
			_recentXFLPaths = (buildedElements[6] as List);
			_showRecentBtn = (buildedElements[7] as PushButton);
			
			_xflPathEdit.addEventListener(Event.CHANGE, _onXFLPathChange);
			_showRecentBtn.addEventListener(MouseEvent.CLICK, _onShowRecentClick);
			_browseBtn.addEventListener(MouseEvent.CLICK, _onXFLBrowse);
			
			var len:uint = PageTypes.PAGES_COUNT;
			var i:uint = 0;
			
			for (i; i < len; i++ )
			{
				_pageSelector.addItem( { label:PageTypes.PAGES_NAMES[i], data:i } );
			}
			
			if (Settings.instance.data.lastXFLPath != null)
			{
				_xflPathEdit.text = Settings.instance.data.lastXFLPath;
			}
			
			i = 0;
			len = 5;
			_recentXFLPaths.removeAll();
			for (i; i < len; i++ )
			{
				if (Settings.instance.data.recentPaths[i])
				{
					_recentXFLPaths.addItem( { label: Settings.instance.data.recentPaths[i], data:""} );
				}
			}
			
			_pageSelector.addEventListener(Event.SELECT, _onPageSelectorChange);
			_pageSelector.selectedIndex = 0;
			
			if (Settings.instance.data.firstRun)
			{
				alert.showMessage(LocaleManager.getString(LocaleManager.GUI_WELCOME_TEXT) + "<br><br>" + LocaleManager.getString(LocaleManager.GUI_DISCLAIMER),LocaleManager.getString(LocaleManager.GUI_WELCOME_TITLE));
				Settings.instance.data.firstRun = false;
			}
			
			addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, _onDragIn);
			addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, _onDragDrop);
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
					if (droppedFile.isDirectory)
					{
						if (FileUtil.searchForFilesByExt("xfl", droppedFile,false).length > 0)
						{
							allow = true
						}
					}
					else if (droppedFile.extension == "xfl" || droppedFile.extension == "fla")
					{
						allow = true;
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
			
			_xflPathEdit.text = droppedFile.nativePath;
			_onXFLPathChange(null);
		}
		
		private function _onShowRecentClick(e:MouseEvent):void 
		{
			_recentXFLPaths.visible = true;
			_recentXFLPaths.addEventListener(Event.SELECT, _onRecentXFLPathSelect);
			stage.addEventListener(MouseEvent.CLICK, _onStageMouseDown);
		}
		
		private function _onStageMouseDown(e:MouseEvent):void 
		{
			if (e.target != _showRecentBtn)
			{
				stage.removeEventListener(MouseEvent.CLICK, _onStageMouseDown);
				_hideRecentPaths();
			}
		}
		
		private function _onRecentXFLPathSelect(e:Event):void 
		{
			_xflPathEdit.text = _recentXFLPaths.selectedItem.label;
			_hideRecentPaths();
			_onXFLPathChange(null);
		}
		
		private function _hideRecentPaths():void 
		{
			_recentXFLPaths.visible = false;
			_recentXFLPaths.removeEventListener(Event.SELECT, _onRecentXFLPathSelect);
		}
		
		private function _onXFLPathChange(e:Event):void
		{
			var _XFLExists:Boolean = false;
			
			xflDirectoryPath = new File();
			xflPath = new File();
			
			try
			{
				xflPath.nativePath = _xflPathEdit.text;
				if (xflPath.isDirectory)
				{
					var xflFiles:Vector.<File> = FileUtil.searchForFilesByExt("xfl", xflPath, false);
					if (xflFiles.length > 0)
					{
						_XFLExists = true;
						xflDirectoryPath = xflPath;
						xflPath = xflFiles[0];
						_xflPathEdit.text = xflPath.nativePath;
					}
				}
				else if (xflPath.extension == "xfl")
				{
					_XFLExists = true;
					xflDirectoryPath = xflPath.resolvePath("..");
				}
				else if (xflPath.extension == "fla")
				{
					var fileReader:FileStream = new FileStream();
					var readedData:ByteArray = new ByteArray();
					
					fileReader.open(xflPath, FileMode.READ);
					fileReader.readBytes(readedData);
					fileReader.close();
					
					if (readedData[0] == 0x50 && readedData[1] == 0x4B &&
						readedData[2] == 0x03 && readedData[3] == 0x04 && readedData[4] == 0x14)
					{
						_XFLExists = true;
						xflDirectoryPath = xflPath;
					}
					else
					{
						alert.showMessage(LocaleManager.getString(LocaleManager.GUI_WRONG_FLA_FORMAT_WARNING, xflPath.nativePath));
					}
				}
			}
			catch (e:Error)
			{
				_XFLExists = false;
			}
			
			if (!_XFLExists)
			{
				_xflFoundStatus.color = 0xFF0000;
				if (currentPage != subPages[PageTypes.PAGE_ABOUT] && currentPage != subPages[PageTypes.PAGE_HISTORY] && currentPage != subPages[PageTypes.PAGE_OPTIONS])
				{
					_pagesPanel.enabled = false;
				}
				else
				{
					_pagesPanel.enabled = true;
				}
			}
			else
			{
				Settings.instance.data.lastXFLPath = xflPath.nativePath;
				
				_xflFoundStatus.color = 0x00FF00;
				_pagesPanel.enabled = true;
				
				if (currentPage is PageBitmapsCompression)
				{
					currentPage.update();
				}
				
				if (Settings.instance.data.recentPaths.indexOf(_xflPathEdit.text) == -1)
				{
					var len:uint;
					var i:uint;
					var settingsData:SettingsData = Settings.instance.data;
					
					for (i = 4; i > 0; i--)
					{
						settingsData.recentPaths[i] = settingsData.recentPaths[i - 1];
					}
					settingsData.recentPaths[0] = _xflPathEdit.text;
					i = 0;
					_recentXFLPaths.removeAll();
					for (i; i < 5; i++ )
					{
						if (settingsData.recentPaths[i])
						{
							_recentXFLPaths.addItem( { label: settingsData.recentPaths[i], data:""} );
						}
					}
					Settings.instance.data = settingsData;
				}
			}
		}
		
		private function _onXFLBrowse(e:MouseEvent):void
		{
			xflDirectoryPath.addEventListener(Event.SELECT, _onXflDirectorySelected);
			xflDirectoryPath.browseForOpen(LocaleManager.getString(LocaleManager.GUI_BROWSE_XFL_TITLE),
										   [
											new FileFilter(LocaleManager.getString(LocaleManager.GUI_SUPPORTED_PROJECT_TYPES), "*.xfl;*.fla"),
											new FileFilter(LocaleManager.getString(LocaleManager.GUI_XFL_PROJECT), "*.xfl"),
											new FileFilter(LocaleManager.getString(LocaleManager.GUI_FLA_PROJECT), "*.fla")
										   ]);
		}
		
		private function _onXflDirectorySelected(e:Event):void
		{
			xflDirectoryPath.removeEventListener(Event.SELECT, _onXflDirectorySelected);
			_xflPathEdit.text = xflDirectoryPath.nativePath;
			_onXFLPathChange(null);
		}
		
		private function _onPageSelectorChange(e:Event):void
		{
			if (currentPage)
			{
				currentPage.hide();
			}
			
			if (!subPages[_pageSelector.selectedItem.data])
			{
				UIBuilder.instance.buildPage(_pagesPanel, _pageSelector.selectedItem.data);
			}
			else
			{
				currentPage = subPages[_pageSelector.selectedItem.data];
				currentPage.show();
			}
			
			_onXFLPathChange(null);
			onResize(null);
		}
		
		public function setJobRunningMode(isRunning:Boolean):void
		{
			_xflPathEdit.enabled = !isRunning;
			_browseBtn.enabled = !isRunning;
			_pageSelector.enabled = !isRunning;
		}
		
		public function onResize(e:Event):void
		{
			this.width = stage.stageWidth;
			this.height = stage.stageHeight;
			
			_browseBtn.x = stage.stageWidth - _browseBtn.width - 5;
			_xflPathEdit.width = _browseBtn.x - _xflPathEdit.x - 3;
			_showRecentBtn.x = _xflPathEdit.width;
			_xflFoundStatus.x = _xflPathEdit.width - 35;
			
			_recentXFLPaths.width = _xflPathEdit.width;
			
			_pageSelector.width = stage.stageWidth - _pageSelector.x - 5;
			
			_pagesPanel.width = stage.stageWidth - _pagesPanel.x - 5;
			_pagesPanel.height = stage.stageHeight - _pagesPanel.y - 5;
			
			alert.x = stage.stageWidth / 2 - alert.width / 2;
			alert.y = stage.stageHeight / 2 - alert.height / 2;
			
			_pageSelector.draw();
			_xflPathEdit.draw();
			_recentXFLPaths.draw();
			_pagesPanel.draw();
			this.draw();
		}
		
		private function unzipFla(unzipTo:FZip):FZip
		{
			var fileReader:FileStream = new FileStream();
			var readedData:ByteArray = new ByteArray();
			fileReader.open(xflPath, FileMode.READ);
			fileReader.readBytes(readedData);
			fileReader.close();
			try
			{
				unzipTo.loadBytes(readedData);
			}
			catch (e:Error)
			{
				unzipTo = null;
				alert.showMessage(String(e));
			}
			fileReader = null;
			readedData.clear();
			readedData = null;
			
			return unzipTo;
		}
		
		public function isReadyForJob(onReadyForJob:Function,_log:Function, filesExt:String = "xml"):void 
		{
			this._onReadyForJob = onReadyForJob;
			
			if (xflPath.extension == "fla")
			{
				_log(LocaleManager.getString(LocaleManager.LOG_UNPACKING_COMPRESSED_XFL));
				
				var zip:FZip = new FZip();
				zip.addEventListener(IOErrorEvent.IO_ERROR, _onFlaLoadAndUnzipIOError);
				zip.addEventListener(FZipErrorEvent.PARSE_ERROR, _onFlaLoadAndUnzipParseError);
				zip = unzipFla(zip);
				
				if (zip)
				{
					var zippedFile:FZipFile;
					var totalUncompressedSize:uint = 0;
					var len:uint = zip.getFileCount();
					var fileToWrite:File;
					var i:uint = 0;
					
					var xflTempDir:File = File.createTempDirectory();
					for (i; i < len; i++) 
					{
						zippedFile = zip.getFileAt(i);
						if (StrUtil.getFileExtension(zippedFile.filename) == filesExt)
						{
							totalUncompressedSize += zippedFile.sizeUncompressed;
						}
					}
					totalUncompressedSize += 1000; // +1 KB for stability
					
					if (totalUncompressedSize > xflTempDir.spaceAvailable)
					{
						_log(LocaleManager.getString(LocaleManager.COMPRESS_NEED_SPACE, 
								 xflTempDir.nativePath, totalUncompressedSize - xflTempDir.spaceAvailable),LogStyle.TYPE_VERY_IMPORTANT);
						_XFLUnpacked = false;
						xflTempDir.deleteDirectory(true);
						_onReadyForJob(false);
						_onReadyForJob = null;
					}
					else
					{
						var fileWriter:FileStream = new FileStream();
						i = 0;
						for (i; i < len; i++) 
						{
							zippedFile = zip.getFileAt(i);
							fileToWrite = xflTempDir.resolvePath(zippedFile.filename);
							if (zippedFile.filename.charAt(zippedFile.filename.length-1) == "/" && zippedFile.sizeUncompressed == 0)
							{
								fileToWrite.createDirectory();
							}
							else
							{
								if (fileToWrite.extension == filesExt)
								{
									var dataToWrite:ByteArray = zippedFile.content;
									fileWriter.open(fileToWrite, FileMode.WRITE);
									fileWriter.writeBytes(dataToWrite);
									fileWriter.close();
								}
							}
						}
						fileWriter = null;
						xflDirectoryPath = xflTempDir;
						_XFLUnpacked = true;
						_onReadyForJob(true);
						_onReadyForJob = null;
					}
					zip.close();
					zip = null;
					zippedFile = null;
					xflTempDir = null;
					fileToWrite = null;
				}
				else
				{
					_XFLUnpacked = false;
					_onReadyForJob(false);
					_onReadyForJob = null;
				}
			}
			else
			{
				_XFLUnpacked = false;
				_onReadyForJob(true);
				_onReadyForJob = null;
			}
		}
		
		private function _onFlaLoadAndUnzipParseError(e:FZipErrorEvent):void 
		{
			alert.showMessage(e.toString());
			if (_onReadyForJob != null)
			{
				_XFLUnpacked = false;
				_onReadyForJob(false);
				_onReadyForJob = null;
			}
			
			if (_onAskForFlaUncompressAnswer != null)
			{
				_onAskForFlaUncompressAnswer(0);
				_onAskForFlaUncompressAnswer = null;
			}
		}
		
		private function _onFlaLoadAndUnzipIOError(e:IOErrorEvent):void 
		{
			alert.showMessage(e.toString());
			if (_onReadyForJob != null)
			{
				_XFLUnpacked = false;
				_onReadyForJob(false);
				_onReadyForJob = null;
			}
			
			if (_onAskForFlaUncompressAnswer != null)
			{
				_onAskForFlaUncompressAnswer(0);
				_onAskForFlaUncompressAnswer = null;
			}
		}
		
		public function jobFinished(_log:Function):void 
		{
			if (_XFLUnpacked)
			{	
				_log(LocaleManager.getString(LocaleManager.LOG_DELETING_UNPACKED_XFL));
				xflDirectoryPath.deleteDirectory(true);
				xflDirectoryPath = xflPath;
				_XFLUnpacked = false;
			}
		}
		
		public function askForFlaUncompress(onAskForFlaUncompressAnswer:Function):void 
		{
			this._onAskForFlaUncompressAnswer = onAskForFlaUncompressAnswer;
			alert.showMessage(LocaleManager.getString(LocaleManager.GUI_COMPRESSED_XFL_WARNING), null,
							  Alert.MESSAGE_TYPE_YES_NO, _onCompressedWarningAnswer);
		}
		
		private function _onCompressedWarningAnswer(answer:uint):void 
		{
			if (answer == Alert.ANSWER_YES)
			{
				var uncompressedXFLPath:File = new File();
				uncompressedXFLPath.nativePath = xflPath.nativePath.substring(0,xflPath.nativePath.length-4);
				uncompressedXFLPath.addEventListener(Event.SELECT, _onUncompressedXflPathSelected);
				uncompressedXFLPath.browseForSave("Select path");
			}
			else
			{
				_onAskForFlaUncompressAnswer(0);
				_onAskForFlaUncompressAnswer = null;
			}
		}
		
		private function _onUncompressedXflPathSelected(e:Event):void 
		{
			e.target.removeEventListener(Event.SELECT, _onUncompressedXflPathSelected);
			
			var selectedPath:File = (e.target as File);
			selectedPath.createDirectory();
			if (selectedPath.exists)
			{
				var zip:FZip = new FZip();
				zip.addEventListener(IOErrorEvent.IO_ERROR, _onFlaLoadAndUnzipIOError);
				zip.addEventListener(FZipErrorEvent.PARSE_ERROR, _onFlaLoadAndUnzipParseError);
				zip = unzipFla(zip);
				
				if (zip)
				{
					var zippedFile:FZipFile;
					var totalUncompressedSize:uint = 0;
					var len:uint = zip.getFileCount();
					var fileToWrite:File;
					var i:uint = 0;
					
					for (i; i < len; i++) 
					{
						zippedFile = zip.getFileAt(i);
						if (StrUtil.getFileExtension(zippedFile.filename) == "xml")
						{
							totalUncompressedSize += zippedFile.sizeUncompressed;
						}
					}
					totalUncompressedSize += 1000; // +1 KB for stability
					
					if (totalUncompressedSize > selectedPath.spaceAvailable)
					{
						alert.showMessage(LocaleManager.getString(LocaleManager.COMPRESS_NEED_SPACE, 
								 selectedPath.nativePath, totalUncompressedSize - selectedPath.spaceAvailable));
						_onAskForFlaUncompressAnswer(0);
						_onAskForFlaUncompressAnswer = null;
					}
					else
					{
						var fileWriter:FileStream = new FileStream();
						i = 0;
						for (i; i < len; i++) 
						{
							zippedFile = zip.getFileAt(i);
							fileToWrite = selectedPath.resolvePath(zippedFile.filename);
							if (zippedFile.filename.charAt(zippedFile.filename.length-1) == "/" && zippedFile.sizeUncompressed == 0)
							{
								fileToWrite.createDirectory();
							}
							else
							{
								var dataToWrite:ByteArray = zippedFile.content;
								fileWriter.open(fileToWrite, FileMode.WRITE);
								fileWriter.writeBytes(dataToWrite);
								fileWriter.close();
							}
						}
						fileWriter = null;
						_xflPathEdit.text = selectedPath.nativePath;
						_onXFLPathChange(null);
						_onAskForFlaUncompressAnswer(1);
						_onAskForFlaUncompressAnswer = null;
					}
					zip.close();
					zip = null;
					zippedFile = null;
					selectedPath = null;
					fileToWrite = null;
				}
				else
				{
					_onAskForFlaUncompressAnswer(0);
					_onAskForFlaUncompressAnswer = null;
				}
			}
			else
			{
				_onAskForFlaUncompressAnswer(0);
				_onAskForFlaUncompressAnswer = null;
			}
		}
		
		public function getFileFromFla(fileName:String):ByteArray
		{
			var result:ByteArray = null;
			
			var zip:FZip = new FZip();
			zip.addEventListener(IOErrorEvent.IO_ERROR, _onFlaLoadAndUnzipIOError);
			zip.addEventListener(FZipErrorEvent.PARSE_ERROR, _onFlaLoadAndUnzipParseError);
			zip = unzipFla(zip);
			
			if (zip)
			{
				var i:uint = 0;
				var len:uint = zip.getFileCount();
				var zippedFile:FZipFile;
				
				fileName = fileName.toLowerCase();
				for (i; i < len; i++) 
				{
					zippedFile = zip.getFileAt(i);
					if (zippedFile.filename.toLowerCase() == fileName)
					{
						result = zippedFile.content;
						break;
					}
				}
				
				zippedFile = null;
				zip.close();
				zip = null;
			}
			
			return result;
		}
		
	}

}