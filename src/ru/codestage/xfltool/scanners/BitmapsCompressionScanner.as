package ru.codestage.xfltool.scanners
{
	import by.blooddy.crypto.image.PNG24Encoder;
	import by.blooddy.crypto.MD5;
	import cmodule.aircall.CLibInit;
	import com.junkbyte.console.Cc;
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import ru.codestage.xfltool.Main;
	import ru.codestage.xfltool.readers.FileReader;
	import ru.codestage.xfltool.scanners.base.ScannerBase;
	import ru.codestage.xfltool.settings.Settings;
	import ru.codestage.xfltool.ui.builder.UIBuilder;
	import ru.codestage.xfltool.ui.controls.log.LogStyle;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	import ru.codestage.xfltool.writers.XMLWriter;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class BitmapsCompressionScanner extends ScannerBase
	{
		private var _customJPEGQuality:Boolean;
		private var _JPEGQuality:uint;
		private var _mediaXML:XML;
		private var _DOMBitmapItems:XMLList;
		private var _tempDir:File;
		private var _onComplete:Function;
		private var _imageFiles:Vector.<File>;
		private var _currentProcessingImageIndex:uint;
		private var _mainDomString:String;
		private var _mediaXMLOrig:String;
		private var _mainDomPath:File;
		private var _flashIDEPath:File;
		private var _checkJSFLJobDoneTimer:Timer;
		
		private var _active:Boolean = true;
		private var alchemyInit:CLibInit;
		private var alchemyLib:Object;
		private var _skipCustom:Boolean;
		private var _onProgress:Function;
		private var jpegImagebyteArray:ByteArray;
		private var jpegImagebyteArrayOut:ByteArray;
		
		private var _totalSuggestedImages:uint = 0;
		
		public function BitmapsCompressionScanner(log:Function)
		{
			super(log);
		}
		
		public function start(customJPEGQuality:Boolean, JPEGQuality:uint, skipCustom:Boolean, onProgress:Function = null, onComplete:Function = null):void
		{
			_active = true;
			_customJPEGQuality = customJPEGQuality;
			_JPEGQuality = JPEGQuality;
			_skipCustom = skipCustom;
			_onProgress = onProgress;
			_onComplete = onComplete;
			
			_mainDomPath = UIBuilder.instance.mainPage.xflDirectoryPath.resolvePath("DOMDocument.xml");
			
			if(NativeProcess.isSupported)
			{
				var flashProFile:File = new File(Settings.instance.data.lastFlashProPath);
				if ((Settings.instance.data.lastFlashProPath != null) && flashProFile.exists)
				{
					if (_mainDomPath.exists || (UIBuilder.instance.mainPage.xflPath.extension == "fla"))
					{
						var imagesProcessed:uint = 0;
						_log(LocaleManager.getString(LocaleManager.COMPRESS_READING));
						
						if (UIBuilder.instance.mainPage.xflPath.extension != "fla")
						{
							var mainDomReader:FileReader = new FileReader();
							_mainDomString = mainDomReader.readFileToString(_mainDomPath);
							mainDomReader = null;
						}
						else
						{
							var data:ByteArray = UIBuilder.instance.mainPage.getFileFromFla("DOMDocument.xml");
							_mainDomString = data.readUTFBytes(data.bytesAvailable);
							data.clear();
							data = null;
						}
						
						if (_mainDomString.indexOf("<media>") != -1)
						{
							_mediaXMLOrig = _mainDomString.substring(_mainDomString.indexOf("<media>"), _mainDomString.lastIndexOf("</media>") + 8);
							_mediaXML = XML(_mediaXMLOrig);
							
							_DOMBitmapItems = _mediaXML.DOMBitmapItem;
							
							if (_DOMBitmapItems && _DOMBitmapItems.length() > 0)
							{
								_log(LocaleManager.getString(LocaleManager.COMPRESS_PREPARING));
								_tempDir = File.createTempDirectory();
								
								// TODO: fix free space calculation to make it more accurate (calculate only files in BIN folder)
								if (_tempDir.spaceAvailable >= UIBuilder.instance.mainPage.xflDirectoryPath.size)
								{
									var jsfl:String = new FileReader().readFileToString(File.applicationDirectory.resolvePath("magic.jsfl"));
									jsfl = jsfl.replace("${TEMP_URL}", _tempDir.url + "/");
									jsfl = jsfl.replace("${XFL_NAME}", UIBuilder.instance.mainPage.xflPath.name);
									jsfl = jsfl.replace("${XFL_URL}", UIBuilder.instance.mainPage.xflPath.url);
									jsfl = jsfl.replace("${SKIP_CUSTOM}", _skipCustom);
									
									var jsflWriter:XMLWriter = new XMLWriter();
									jsflWriter.writeStringToFile(_tempDir.resolvePath("magic.jsfl"), jsfl);
									jsflWriter = null;
									
									_log(LocaleManager.getString(LocaleManager.COMPRESS_CALL_IDE));
									
									var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
									var file:File = new File(Settings.instance.data.lastFlashProPath);
									var processArgs:Vector.<String>;
									
									if (file.extension == "app")
									{
										processArgs = new Vector.<String>(2, true);
										
										nativeProcessStartupInfo.executable = File.applicationDirectory.resolvePath('/usr/bin/open');
										processArgs[0] = file.nativePath;
										processArgs[1] = _tempDir.resolvePath("magic.jsfl").nativePath;
									}
									else
									{
										processArgs = new Vector.<String>(1, true);
										nativeProcessStartupInfo.executable = file;
										processArgs[0] = _tempDir.resolvePath("magic.jsfl").nativePath;
									}
									
									nativeProcessStartupInfo.arguments = processArgs;
									
									var process:NativeProcess = new NativeProcess();
									process.start(nativeProcessStartupInfo);
									
									if (!_active) return;
									
									_checkJSFLJobDoneTimer = new Timer(500);
									_checkJSFLJobDoneTimer.addEventListener(TimerEvent.TIMER, _onCheckJSFLJobDone);
									_checkJSFLJobDoneTimer.start();
								}
								else
								{
									_log(LocaleManager.getString(LocaleManager.COMPRESS_NEED_SPACE, 
										 _tempDir.nativePath, UIBuilder.instance.mainPage.xflDirectoryPath.size - _tempDir.spaceAvailable), 
										 LogStyle.TYPE_VERY_IMPORTANT);
									_finish();
								}
							}
							else
							{
								_log(LocaleManager.getString(LocaleManager.LOG_NO_BITMAPS,_mainDomPath.nativePath), LogStyle.TYPE_VERY_IMPORTANT);
								_finish();
							}
						}
						else
						{
							_log(LocaleManager.getString(LocaleManager.LOG_NO_BITMAPS,_mainDomPath.nativePath), LogStyle.TYPE_VERY_IMPORTANT);
							_finish();
						}
					}
					else
					{
						_log(LocaleManager.getString(LocaleManager.FILE_NOT_FOUND,_mainDomPath.nativePath), LogStyle.TYPE_VERY_IMPORTANT);
						_finish();
					}
				}
				else
				{
					_log(LocaleManager.getString(LocaleManager.FLASH_PRO_NOT_FOUND), LogStyle.TYPE_VERY_IMPORTANT);
					_finish();
				}
			}
			else
			{
				_log(LocaleManager.getString(LocaleManager.NATIVE_NOT_SUPPORTED), LogStyle.TYPE_VERY_IMPORTANT);
				_finish();
			}
		}
		
		private function _finish():void
		{
			if (_mediaXML) System.disposeXML(_mediaXML);
			if (_DOMBitmapItems) _DOMBitmapItems = null;
			if (_tempDir)
			{
				_tempDir.deleteDirectory(true);
				_tempDir = null;
			}
			
			var totalImages:uint = 0;
			
			if (_imageFiles)
			{
				
				var len:uint = _imageFiles.length;
				totalImages = len;
				var i:uint = 0;
				var file:File;
				
				for (i; i < len; i++ )
				{
					file = _imageFiles[i];
					if (file)
					{
						file.cancel();
						file = null;
					}
				}
				
				_imageFiles = null;
			}
			
			_mainDomString = null;
			_mediaXMLOrig = null;
			
			if (_mainDomPath)
			{
				_mainDomPath.cancel();
				_mainDomPath = null;
			}
			
			if (_flashIDEPath)
			{
				_flashIDEPath.cancel();
				_flashIDEPath = null;
			}
			
			if (_checkJSFLJobDoneTimer)
			{
				_checkJSFLJobDoneTimer.removeEventListener(TimerEvent.TIMER, _onCheckJSFLJobDone);
				_checkJSFLJobDoneTimer.reset();
				_checkJSFLJobDoneTimer = null;
			}
			
			if (_onComplete != null)
			{
				_onComplete(totalImages,_totalSuggestedImages);
				_onComplete = null;
			}
			
			if (jpegImagebyteArray)
			{
				jpegImagebyteArray.clear();
				jpegImagebyteArray = null;
			}
			
			if (jpegImagebyteArrayOut)
			{
				jpegImagebyteArrayOut.clear();
				jpegImagebyteArrayOut = null;
			}
			
			/*if (alchemyInit)
			{
				alchemyInit = null;
				alchemyLib = null;
			}*/
			_totalSuggestedImages = 0;
		}
		
		public function terminate():void
		{
			_active = false;
			if (!_checkJSFLJobDoneTimer)
			{
				_log(LocaleManager.getString(LocaleManager.COMPRESS_TERMINATED), LogStyle.TYPE_VERY_IMPORTANT);
				_finish();
			}
			else
			{
				_log(LocaleManager.getString(LocaleManager.COMPRESS_WAITING), LogStyle.TYPE_VERY_IMPORTANT);
			}
		}
		
		private function _onCheckJSFLJobDone(e:TimerEvent):void
		{
			if (_tempDir.resolvePath("export.txt").exists)
			{
				//FramerateThrottler.enabled = false;
				Main.instance.stage.nativeWindow.alwaysInFront = true;
				Main.instance.stage.nativeWindow.alwaysInFront = false;
				
				_checkJSFLJobDoneTimer.removeEventListener(TimerEvent.TIMER, _onCheckJSFLJobDone);
				_checkJSFLJobDoneTimer.reset();
				_checkJSFLJobDoneTimer = null;
				if (!_active) 
				{
					_finish();
				}
				else
				{
					_processExportedImages();
				}
			}
		}
		
		private function _processExportedImages():void
		{
			_log(LocaleManager.getString(LocaleManager.COMPRESS_EXPORTED_START));
			
			var len:uint = _DOMBitmapItems.length();
			var i:uint = 0;
			
			_imageFiles = new Vector.<File>();
			_currentProcessingImageIndex = 0;
			
			Cc.log("_skipCustom = " + _skipCustom);
			
			for (i; i < len; i++ )
			{
				if (!(_skipCustom && _DOMBitmapItems[i].@compressionType==undefined && _DOMBitmapItems[i].@useImportedJPEGData=="false"))
				{
					_imageFiles[_imageFiles.length] = _tempDir.resolvePath(MD5.hash(_DOMBitmapItems[i].@name) + ".png");
				}
				else
				{
					Cc.log("Skipping " + _DOMBitmapItems[i].@name);
				}
			}
			
			if (!alchemyInit)
			{
				alchemyInit = new CLibInit();
				alchemyLib = alchemyInit.init();
			}
			
			//jpegImagebyteArray = new ByteArray();
			jpegImagebyteArrayOut = new ByteArray();
			
			_processNextImage();
		}
		
		private function _processNextImage():void
		{
			if (!_active) return;
			if (_currentProcessingImageIndex < _imageFiles.length)
			{
				var currentImagePath:File = _imageFiles[_currentProcessingImageIndex];
				//_log("Loading " + currentImagePath.nativePath);
				//_log(currentImagePath.exists);
				
				var _loader:Loader = new Loader();
				var loaderContext:LoaderContext = new LoaderContext();
				loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
				
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _loader_complete);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _loader_ioError);
				_loader.load(new URLRequest(currentImagePath.url), loaderContext);
				//Cc.log(_loader);
			}
			else
			{
				_imagesProcessingFinish();
			}
		}
		
		private function _loader_ioError(e:IOErrorEvent):void
		{
			e.target.removeEventListener(Event.COMPLETE, _loader_complete);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, _loader_ioError);
			_log(LocaleManager.getString(LocaleManager.COMPRESS_ERROR,
										(e.currentTarget as LoaderInfo).url,
										 e.text), LogStyle.TYPE_VERY_IMPORTANT);
			//Cc.log(e);
			_currentProcessingImageIndex ++;
			_processNextImage();
		}
		
		private function encode(bitmapData:BitmapData, quality:uint):void
		{
			jpegImagebyteArray = bitmapData.getPixels(bitmapData.rect);
			jpegImagebyteArray.position = 0;
			alchemyLib.encode(jpegImagebyteArray, jpegImagebyteArrayOut, bitmapData.width, bitmapData.height, quality);
		}
		
		private function _loader_complete(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE, _loader_complete);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, _loader_ioError);
			
			if (!_active) return;
			
			if ((_DOMBitmapItems[_currentProcessingImageIndex].@useImportedJPEGData != "false") && (_DOMBitmapItems[_currentProcessingImageIndex].@isJPEG == "true") && (!isImageProgressive((e.target as LoaderInfo).bytes)))
			{
				_totalSuggestedImages++;
				_log(LocaleManager.getString(LocaleManager.COMPRESS_IMPORTED_JPEG_DATA,
													 _DOMBitmapItems[_currentProcessingImageIndex].@name), LogStyle.TYPE_COMMENT);
			}
			else
			{
				var pngSize:uint = 0;
				var pngTime:uint = 0;
				var jpegSize:uint = 0;
				var jpegTime:uint = 0;
				var encodingStartTime:int = 0;
				var encodedBytes:ByteArray;
				
				var loadedImageBitmapData:BitmapData = ((e.target as LoaderInfo).content as Bitmap).bitmapData;
				
				encodingStartTime = getTimer();
				encodedBytes = PNG24Encoder.encode(loadedImageBitmapData);
				pngSize = encodedBytes.length;
				pngTime = getTimer() - encodingStartTime;
				
				encodingStartTime = getTimer();
				//encodedBytes = JPEGEncoder.encode(loadedImageBitmapData, _JPEGQuality);
				//var enc:JPEGEncoder = new JPEGEncoder(_JPEGQuality);
				//encodedBytes = enc.encode(loadedImageBitmapData);
				encode(loadedImageBitmapData, _JPEGQuality);
				jpegSize = jpegImagebyteArrayOut.length;
				jpegTime = getTimer() - encodingStartTime;
				
				if (pngSize < jpegSize-500)
				{
					if (_DOMBitmapItems[_currentProcessingImageIndex].@useImportedJPEGData != "false" || _DOMBitmapItems[_currentProcessingImageIndex].@compressionType != "lossless")
					{
						_totalSuggestedImages++;
						_log(LocaleManager.getString(LocaleManager.COMPRESS_PICK_LOSSLLESS,
													 _formatBytes(pngSize),
													 _formatBytes(jpegSize),
													 _DOMBitmapItems[_currentProcessingImageIndex].@name), LogStyle.TYPE_GOOD);
					}
				}
				else if (pngSize > jpegSize+500)
				{
					if (!_customJPEGQuality)
					{
						if ((_DOMBitmapItems[_currentProcessingImageIndex].@useImportedJPEGData == "false") || (_DOMBitmapItems[_currentProcessingImageIndex].@compressionType != undefined))
						{
							_totalSuggestedImages++;
							_log(LocaleManager.getString(LocaleManager.COMPRESS_PICK_PHOTO,
													 _formatBytes(pngSize),
													 _formatBytes(jpegSize),
													 _DOMBitmapItems[_currentProcessingImageIndex].@name), LogStyle.TYPE_GOOD);
						}
					}
					else
					{
						if (_DOMBitmapItems[_currentProcessingImageIndex].@useImportedJPEGData != "false" || String(_DOMBitmapItems[_currentProcessingImageIndex].@compressionType) || _DOMBitmapItems[_currentProcessingImageIndex].@quality != _JPEGQuality)
						{
							_totalSuggestedImages++;
							_log(LocaleManager.getString(LocaleManager.COMPRESS_PICK_PHOTO,
													 _formatBytes(pngSize),
													 _formatBytes(jpegSize),
													 _DOMBitmapItems[_currentProcessingImageIndex].@name), LogStyle.TYPE_GOOD);
							
						}
					}
				}
				
				jpegImagebyteArray.clear();
				jpegImagebyteArrayOut.clear();
				
				encodedBytes.clear();
				encodedBytes = null;
				
				loadedImageBitmapData.dispose();
				loadedImageBitmapData = null;
			}
			
			_imageFiles[_currentProcessingImageIndex].deleteFile();
			
			_currentProcessingImageIndex++;
			if (_onProgress != null)
			{
				_onProgress(_imageFiles.length, _currentProcessingImageIndex);
			}
			_processNextImage();
		}
		
		private function _imagesProcessingFinish():void
		{
			//UIBuilder.instance.mainPage.xflPath.openWithDefaultApplication();
			
			//alchemyInit = null;
			//alchemyLib = null;
			/*if (jpegImagebyteArray)
			{
				jpegImagebyteArray.clear();
				jpegImagebyteArray = null;
			}
			
			if (jpegImagebyteArrayOut)
			{
				jpegImagebyteArrayOut.clear();
				jpegImagebyteArrayOut = null;
			}*/
			
			_finish();
		}
		
		private function _formatBytes(bytes:uint):String
		{
			return (bytes / 1000).toFixed(2) + LocaleManager.getString(LocaleManager.COMPRESS_SIZE);
		}
		
		private function jumpBytes(address:int, count:uint, bytes:ByteArray):int 
		{
			var newAddress:int = address;
			for ( var i : uint = 0; i < count; i++ ) 
			{
				bytes.readByte();
				newAddress++;
			}	
			return newAddress;
		}
		
		private function isImageProgressive(bytes:ByteArray):Boolean 
		{
			var SOF0: Array = [ 0xFF, 0xC0 , 0x00 , 0x11 , 0x08 ];
			var SOF2: Array = [ 0xFF, 0xC2 , 0x00 , 0x11 , 0x08 ];
			var APPSections: Array;
			
			var address: int = 0;
			var jumpLength: uint = 0;
			var index: uint = 0;
			var byte: int = 0;
			var imageIsProgressive:Boolean = false;
			
			bytes.position = 0;
			
			APPSections = [];
			for ( var i : int = 1; i < 16; i++ ) 
			{
				APPSections[ i ] = [ 0xFF, 0xE0 + i ];
			}
			
			while (bytes.bytesAvailable >= SOF2.length + 4) 
			{
				var match: Boolean = false;
				// Only look for new APP table if no jump is in queue
				if ( jumpLength == 0 ) 
				{
					byte = bytes.readUnsignedByte();
					address++;
					// Check for APP table
					for each ( var APP : Array in APPSections ) 
					{
						//if ( address > 0x3200 && address < 0x3300 ) trace( byte + " @" + index + " == " + APP[ index ] + " -> " + ( byte == APP[ index ] ) );
						if ( byte == APP[ index ] ) 
						{
							match = true;
							if ( index + 1 >= APP.length ) 
							{
								//if ( traceDebugInfo ) trace( "APP" + Number( byte - 0xE0 ).toString( 16 ).toUpperCase( ) +  " found at 0x" + ( address - 2 ).toString( 16 ).toUpperCase( ) );
								// APP table found, skip it as it may contain thumbnails in JPG (we don't want their SOF's)
								jumpLength = bytes.readUnsignedShort( ) - 2; // -2 for the short we just read
								address += 2;
								break;
							}
						}
					}
				}
				// Jump here, so that data has always loaded
				if ( jumpLength > 0 ) 
				{
					//if ( traceDebugInfo ) trace( "Trying to jump " + jumpLength + " bytes (available " + Math.round( Math.min( bytesAvailable / jumpLength, 1 ) * 100 ) + "%)" );
					if ( bytes.bytesAvailable >= jumpLength ) 
					{
						//if ( traceDebugInfo ) trace( "Jumping " + jumpLength + " bytes to 0x" + Number( address + jumpLength ).toString( 16 ).toUpperCase( ) );
						address = jumpBytes(address, jumpLength, bytes);
						match = false;
						jumpLength = 0;
						index = 0;
					} 
					else break; // Load more data and continue
				} 
				else 
				{
					// Check for SOF2
					if ( byte == SOF2[ index ] ) 
					{
						match = true;
						if ( index + 1 >= SOF2.length ) 
						{
							// Matched SOF2
							imageIsProgressive = true;
							/*if ( traceDebugInfo ) trace( "SOF2 found at 0x" + address.toString( 16 ).toUpperCase( ) );
							jpgHeight = readUnsignedShort( );
							address += 2;
							jpgWidth = readUnsignedShort( );
							address += 2;
							if ( traceDebugInfo ) trace( "Dimensions: " + jpgWidth + " x " + jpgHeight );
							removeEventListener( ProgressEvent.PROGRESS, progressHandler ); // No need to look for dimensions anymore
							if ( stopWhenParseComplete && connected ) close( );
							dispatchEvent( new Event( PARSE_COMPLETE ) );*/
							break;
						}
					}
					if ( match ) 
					{
						index++;
					} 
					else 
					{
						index = 0;
					}
				}
			}
			return imageIsProgressive;
		}
	}

}