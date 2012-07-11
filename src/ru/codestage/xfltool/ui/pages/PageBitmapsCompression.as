package ru.codestage.xfltool.ui.pages
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.Component;
	import com.bit101.components.Panel;
	import com.bit101.components.ProgressBar;
	import com.bit101.components.PushButton;
	import com.bit101.components.RadioButton;
	import com.bit101.components.Text;
	import com.junkbyte.console.Cc;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import ru.codestage.xfltool.readers.FileReader;
	import ru.codestage.xfltool.scanners.BitmapsCompressionScanner;
	import ru.codestage.xfltool.settings.Settings;
	import ru.codestage.xfltool.ui.builder.UIBuilder;
	import ru.codestage.xfltool.ui.controls.alert.Alert;
	import ru.codestage.xfltool.ui.controls.log.LogArea;
	import ru.codestage.xfltool.ui.controls.log.LogStyle;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class PageBitmapsCompression extends BasePage
	{
		
		private var _logArea:LogArea;
		private var _optionsPanel:Panel;
		private var _publishJPEGSettings:RadioButton;
		private var _customJPEGSettings:RadioButton;
		private var _JPEGCompressionValue:Text;
		private var _JPEGOptions:Panel;
		private var _startButton:PushButton;
		private var _stopButton:PushButton;
		private var _copyLogButton:PushButton;
		private var _skipCustomFlag:CheckBox;
		private var _operationProgress:ProgressBar;
		
		private var _bitmapsCompressionScanner:BitmapsCompressionScanner;
		private var _scanStartTime:Number;
		
		
		
		public function PageBitmapsCompression(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			super(parent, xpos, ypos);
		}
		
		override public function initialize(buildedElements:Vector.<Component>):void
		{
			_logArea = (buildedElements.shift() as LogArea);
			_optionsPanel = (buildedElements.shift() as Panel);
			_publishJPEGSettings = (buildedElements.shift() as RadioButton);
			_customJPEGSettings = (buildedElements.shift() as RadioButton);
			_JPEGCompressionValue = (buildedElements.shift() as Text);
			_JPEGOptions = (buildedElements.shift() as Panel);
			_startButton = (buildedElements.shift() as PushButton);
			_copyLogButton = (buildedElements.shift() as PushButton);
			_stopButton = (buildedElements.shift() as PushButton);
			_skipCustomFlag = (buildedElements.shift() as CheckBox);
			_operationProgress = (buildedElements.shift() as ProgressBar);
			
			_publishJPEGSettings.addEventListener(MouseEvent.CLICK, _onJPEGSettingsChangeSelection);
			_customJPEGSettings.addEventListener(MouseEvent.CLICK, _onJPEGSettingsChangeSelection);
			
			_copyLogButton.addEventListener(MouseEvent.CLICK, _onCopyLogClick);
			_startButton.addEventListener(MouseEvent.CLICK, _onStartClick);
			_stopButton.addEventListener(MouseEvent.CLICK, _onStopClick);
			
			_bitmapsCompressionScanner = new BitmapsCompressionScanner(_logArea.add);
			
			_operationProgress.visible = false;
			
			//_updateOptions();
			//Cc.addSlashCommand("addLog",_addDebugLine);
			
			onResize(null);
		}
		
		private function _onJPEGSettingsChangeSelection(e:Event):void
		{
			_updateOptions();
		}
		
		override public function show():void
		{
			super.show();
		}
		
		override public function hide():void
		{
			super.hide();
		}
		
		override public function update():void
		{
			super.update();
			_logArea.clear();
			_updateOptions();
		}
		
		private function _onCopyLogClick(e:MouseEvent):void
		{
			var log:String = _logArea.getRawText();
			System.setClipboard(log);
			_logArea.add(LocaleManager.getString(LocaleManager.LOG_COPIED), LogStyle.TYPE_COMMENT);
		}
		
		private function _onStartClick(e:MouseEvent):void
		{
			UIBuilder.instance.mainPage.alert.showMessage(LocaleManager.getString(LocaleManager.GUI_COMPRESSION_WARNING),null,
														  Alert.MESSAGE_TYPE_YES_NO, _onMessageAnswer);
		}
		
		private function _onAskForFlaUncompressAnswer(answer:uint):void 
		{
			if (answer == Alert.ANSWER_YES)
			{
				_onStartClick(null);
			}
		}
		
		private function _onMessageAnswer(answer:uint):void 
		{
			if (answer == Alert.ANSWER_YES)
			{
				_start();
			}
		}
		
		private function _start():void
		{
			_updateOptions();
			_stopButton.visible = true;
			_startButton.visible = false;
			UIBuilder.instance.mainPage.setJobRunningMode(true);
			_logArea.clear();
			_logArea.add(LocaleManager.getString(LocaleManager.LOG_WAIT), LogStyle.TYPE_GOOD);
			
			setTimeout(_onWaitShowed, 500);
		}
		
		private function _onWaitShowed():void
		{
			_logArea.clear();
			
			Settings.instance.data.bitmapsCompressionJPEGCustom = _customJPEGSettings.selected;
			Settings.instance.data.bitmapsCompressionJPEGPublishSettings = _publishJPEGSettings.selected;
			Settings.instance.data.bitmapsCompressionPhotoQuality = _JPEGCompressionValue.text;
			Settings.instance.data.bitmapsCompressionSkipCustomCompression = _skipCustomFlag.selected;
			
			if (UIBuilder.instance.mainPage.xflDirectoryPath.exists)
			{
				//_logArea.add("Processing started...");
				
				_scanStartTime = getTimer();
				
				_operationProgress.value = 0;
				_operationProgress.visible = true;
				
				_bitmapsCompressionScanner.start(_customJPEGSettings.selected, uint(_JPEGCompressionValue.text), _skipCustomFlag.selected, _onProgress, _onComplete);
				
			}
			else
			{
				_logArea.add(LocaleManager.getString(LocaleManager.FILE_NOT_FOUND,UIBuilder.instance.mainPage.xflDirectoryPath.nativePath),LogStyle.TYPE_VERY_IMPORTANT);
			}
		}
		
		
		private function _onStopClick(e:MouseEvent):void
		{
			_bitmapsCompressionScanner.terminate();
			_stopButton.visible = false;
			_startButton.visible = true;
		}
		
		private function _onComplete(totalImages:uint, suggestedImages:uint):void
		{
			//_logArea.lock();
			if (suggestedImages == 0)
			{
				_logArea.add(LocaleManager.getString(LocaleManager.LOG_IMAGES_ANALYSED, totalImages,suggestedImages),LogStyle.TYPE_GOOD);
			}
			else
			{
				_logArea.add(LocaleManager.getString(LocaleManager.LOG_IMAGES_ANALYSED, totalImages,suggestedImages),LogStyle.TYPE_IMPORTANT);
			}
			var scanTime:String = Number((getTimer() - _scanStartTime) / 1000).toFixed(3);
			_logArea.add(LocaleManager.getString(LocaleManager.LOG_TIME, scanTime));
			//_logArea.unlock();
			
			_operationProgress.visible = false;
			_stopButton.visible = false;
			_startButton.visible = true;
			UIBuilder.instance.mainPage.setJobRunningMode(false);
		}
		
		private function _onProgress(total:uint, done:uint):void 
		{
			_operationProgress.maximum = total;
			_operationProgress.value = done;
		}
		
		private function _updateOptions():void
		{
			if (_publishJPEGSettings.selected)
			{
				var publishXML:XML;
				if (UIBuilder.instance.mainPage.xflPath.extension != "fla")
				{
					var publishXMLPath:File = UIBuilder.instance.mainPage.xflDirectoryPath.resolvePath("PublishSettings.xml");
					var publishXMLReader:FileReader = new FileReader();
					publishXML = publishXMLReader.readFileToXML(publishXMLPath);
					publishXMLReader = null;
					publishXMLPath = null;
				}
				else
				{
					var data:ByteArray = UIBuilder.instance.mainPage.getFileFromFla("PublishSettings.xml");
					publishXML = new XML(data.readUTFBytes(data.bytesAvailable));
					data.clear();
					data = null;
				}
				
				if (publishXML)
				{
					var publishJPEGCompression:Number = publishXML..PublishFlashProperties[0].Quality;
					if (!(publishJPEGCompression!=publishJPEGCompression))
					{
						_JPEGCompressionValue.text = String(publishJPEGCompression);
						_JPEGCompressionValue.editable = false;
						_JPEGCompressionValue.enabled = false;
					}
					else
					{
						_JPEGCompressionValue.editable = true;
						_JPEGCompressionValue.enabled = true;
					}
				}
				else
				{
					_JPEGCompressionValue.editable = true;
					_JPEGCompressionValue.enabled = true;
					if (_JPEGCompressionValue.text == "")
					{
						_JPEGCompressionValue.text = Settings.instance.data.bitmapsCompressionPhotoQuality;
					}
					_logArea.add(LocaleManager.getString(LocaleManager.FILE_NOT_FOUND,"PublishSettings.xml"), LogStyle.TYPE_VERY_IMPORTANT);
				}
			}
			else
			{
				_JPEGCompressionValue.editable = true;
				_JPEGCompressionValue.enabled = true;
				if (_JPEGCompressionValue.text == "")
				{
					_JPEGCompressionValue.text = Settings.instance.data.bitmapsCompressionPhotoQuality;
				}
			}
		}
		
		override public function onResize(e:Event):void
		{
			_logArea.width = stage.stageWidth - (_logArea.x + _optionsPanel.width + 18);
			_logArea.height = stage.stageHeight - _logArea.y - 73;
			
			_optionsPanel.x = _logArea.x + _logArea.width + 3;
			_optionsPanel.height = stage.stageHeight - _optionsPanel.y - 73;
			
			_startButton.y = _optionsPanel.height - 20 - 5;
			_stopButton.y = _optionsPanel.height - 20 - 5;
			_copyLogButton.y = _startButton.y - 3 - 20;
			_operationProgress.y = _copyLogButton.y - 3 - 20;
			
			//_logArea.resizeItems();
			_logArea.draw();
			//_logArea.update();
			_optionsPanel.draw();
		}
		
	}

}