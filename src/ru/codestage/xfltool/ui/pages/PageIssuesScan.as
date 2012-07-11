package ru.codestage.xfltool.ui.pages
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.Component;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.system.System;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import ru.codestage.xfltool.map.ProjectMap;
	import ru.codestage.xfltool.readers.FileReader;
	import ru.codestage.xfltool.scanners.base.ScanResults;
	import ru.codestage.xfltool.scanners.issues.LibraryIssuesScanner;
	import ru.codestage.xfltool.scanners.issues.PublishXMLIssuesScanner;
	import ru.codestage.xfltool.settings.Settings;
	import ru.codestage.xfltool.ui.builder.UIBuilder;
	import ru.codestage.xfltool.ui.controls.log.LogArea;
	import ru.codestage.xfltool.ui.controls.log.LogStyle;
	import ru.codestage.xfltool.ui.locale.LocaleManager;

	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class PageIssuesScan extends BasePage
	{
		private var _publishXMLIssuesScanner:PublishXMLIssuesScanner;
		private var _libraryIssuesScanner:LibraryIssuesScanner;
		//private var _libraryIssuesScannerFileWalker:LibraryIssuesScannerFileWalker;
		
		private var _logArea:LogArea;
		
		private var _optionsPanel:Panel;
		private var _copyLogButton:PushButton;
		private var _startScanButton:PushButton;
		private var _scanPublishCheck:CheckBox;
		private var _scanFontsCheck:CheckBox;
		private var _scanCommonCheck:CheckBox;
		private var _scanPerformanceCheck:CheckBox;
		private var _scanElegancyCheck:CheckBox;
		private var _scanStartTime:Number;
		
		
		public function PageIssuesScan(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			super(parent, xpos, ypos);
		}
		
		override public function initialize(buildedElements:Vector.<Component>):void
		{
			_startScanButton = (buildedElements[0] as PushButton);
			_optionsPanel = (buildedElements[1] as Panel);
			_logArea = (buildedElements[2] as LogArea);
			_copyLogButton = (buildedElements[3] as PushButton);
			_scanPublishCheck = (buildedElements[4] as CheckBox);
			_scanFontsCheck = (buildedElements[5] as CheckBox);
			_scanCommonCheck = (buildedElements[6] as CheckBox);
			_scanPerformanceCheck = (buildedElements[7] as CheckBox);
			_scanElegancyCheck = (buildedElements[8] as CheckBox);
			
			_publishXMLIssuesScanner = new PublishXMLIssuesScanner(_logArea.add);
			//_libraryIssuesScannerFileWalker = new LibraryIssuesScannerFileWalker(_logArea.add);
			
			_copyLogButton.addEventListener(MouseEvent.CLICK, _onCopyLogClick);
			_startScanButton.addEventListener(MouseEvent.CLICK, _onStartScanClick);
			
			onResize(null);
		}
		
		override public function show():void
		{
			super.show();
			_copyLogButton.addEventListener(MouseEvent.CLICK, _onCopyLogClick);
			_startScanButton.addEventListener(MouseEvent.CLICK, _onStartScanClick);
		}
		
		override public function hide():void
		{
			super.hide();
			_copyLogButton.removeEventListener(MouseEvent.CLICK, _onCopyLogClick);
			_startScanButton.removeEventListener(MouseEvent.CLICK, _onStartScanClick);
		}
		
		private function _onCopyLogClick(e:MouseEvent):void
		{
			var log:String = _logArea.getRawText();
			System.setClipboard(log);
			_logArea.add(LocaleManager.getString(LocaleManager.LOG_COPIED), LogStyle.TYPE_COMMENT);
			//_logArea.update();
		}
		
		private function _onStartScanClick(e:MouseEvent):void
		{
			_scanStartTime = getTimer();
			_logArea.clear();
			_logArea.add(LocaleManager.getString(LocaleManager.LOG_WAIT), LogStyle.TYPE_GOOD);
			//_logArea.update();
			//this.waitText.visible = true;
			setTimeout(_onWaitShowed, 500);
		}
		
		private function _onWaitShowed():void
		{
			_logArea.clear();
			//_logArea.lock();
			
			Settings.instance.data.issuesScanPublishCheck = _scanPublishCheck.selected;
			Settings.instance.data.issuesScanFontsCheck = _scanFontsCheck.selected;
			Settings.instance.data.issuesScanCommonCheck = _scanCommonCheck.selected;
			Settings.instance.data.issuesScanPerformanceCheck = _scanPerformanceCheck.selected;
			Settings.instance.data.issuesScanElegancyCheck = _scanElegancyCheck.selected;
			
			if (_scanPublishCheck.selected || _scanFontsCheck.selected || _scanCommonCheck.selected || _scanPerformanceCheck.selected || _scanElegancyCheck.selected)
			{
				if (UIBuilder.instance.mainPage.xflDirectoryPath.exists)
				{
					UIBuilder.instance.mainPage.isReadyForJob(_onReadyForJobChecked, _logArea.add)
				}
				else
				{
					_logArea.add(LocaleManager.getString(LocaleManager.FILE_NOT_FOUND,UIBuilder.instance.mainPage.xflDirectoryPath.nativePath), LogStyle.TYPE_VERY_IMPORTANT);
				}
			}
			else
			{
				_logArea.add(LocaleManager.getString(LocaleManager.LOG_NOTHING_TO_SCAN),LogStyle.TYPE_VERY_IMPORTANT);
			}
			//_logArea.unlock();
		}
		
		private function _onReadyForJobChecked(isReady:Boolean):void 
		{
			if (isReady)
			{
				UIBuilder.instance.mainPage.setJobRunningMode(true);
				
				var totalIssues:uint = 0;
				
				if (_scanPublishCheck.selected)
				{
					totalIssues += _scanPublishXML();
				}
				else
				{
					_logArea.add(LocaleManager.getString(LocaleManager.PUBLISH_SKIPPED),LogStyle.TYPE_COMMENT);
				}
				
				if (_scanFontsCheck.selected || _scanCommonCheck.selected || _scanPerformanceCheck.selected || _scanElegancyCheck.selected)
				{
					totalIssues += _scanLibrary(_scanFontsCheck.selected, _scanCommonCheck.selected, _scanPerformanceCheck.selected, _scanElegancyCheck.selected);
				}
				else
				{
					_logArea.add(LocaleManager.getString(LocaleManager.LOG_LIBRARY_SCAN_SKIPPED),LogStyle.TYPE_COMMENT);
				}
				
				if (totalIssues == 0)
				{
					_logArea.add(LocaleManager.getString(LocaleManager.LOG_TOTAL_ISSUES,totalIssues),LogStyle.TYPE_GOOD);
				}
				else
				{
					_logArea.add(LocaleManager.getString(LocaleManager.LOG_TOTAL_ISSUES,totalIssues),LogStyle.TYPE_VERY_IMPORTANT);
				}
				
				var scanTime:String = Number((getTimer() - _scanStartTime) / 1000).toFixed(3);
				_logArea.add(LocaleManager.getString(LocaleManager.LOG_TIME,scanTime));
				_logArea.addTotalHints();
				
				UIBuilder.instance.mainPage.jobFinished(_logArea.add);
				UIBuilder.instance.mainPage.setJobRunningMode(false);
				//_logArea.update();
			}
		}
		
		private function _scanPublishXML():uint
		{
			var issues:uint = 0;
			var publishXMLPath:File = UIBuilder.instance.mainPage.xflDirectoryPath.resolvePath("PublishSettings.xml");
			var metadataXMLPath:File = UIBuilder.instance.mainPage.xflDirectoryPath.resolvePath("META-INF/metadata.xml");
			
			var publishXMLReader:FileReader = new FileReader();
			var publishXML:XML = publishXMLReader.readFileToXML(publishXMLPath);
			var metadataXML:XML = publishXMLReader.readFileToXML(metadataXMLPath);
			
			if (publishXML)
			{
				if (!metadataXML)
				{
					issues++;
					_logArea.add(LocaleManager.getString(LocaleManager.FILE_NOT_FOUND,metadataXMLPath.nativePath),LogStyle.TYPE_VERY_IMPORTANT);
				}
				issues += _publishXMLIssuesScanner.scanPublishXML(publishXML,metadataXML);
			}
			else
			{
				issues++;
				_logArea.add(LocaleManager.getString(LocaleManager.FILE_NOT_FOUND,publishXMLPath.nativePath),LogStyle.TYPE_VERY_IMPORTANT);
			}
			publishXMLReader = null;
			return issues;
		}
		
		private function _scanLibrary(fonts:Boolean, common:Boolean, performance:Boolean, elegancy:Boolean):uint
		{
		
			var project:ProjectMap = new ProjectMap();
			project.createProjectMap(UIBuilder.instance.mainPage.xflDirectoryPath, _logArea.add);
			
			_logArea.add(LocaleManager.getString(LocaleManager.LOG_PROGECT_MAP_CREATED, project.projectLibrarySymbols.length),LogStyle.TYPE_COMMENT);
			
			var issues:ScanResults;
			
			_libraryIssuesScanner = new LibraryIssuesScanner(fonts, common, performance, elegancy, _logArea.add);
			issues = _libraryIssuesScanner.scanSymbolsForIssues(project.projectFonts, project.projectLibrarySymbols);
			
			if (common)
			{
				if (project.projectHasManyScenes)
				{
					issues.totalCommonIssues++;
					_logArea.add(LocaleManager.getString(LocaleManager.LOG_NOT_ONE_SCENE),LogStyle.TYPE_COMMON, LocaleManager.getString(LocaleManager.HINT_NOT_ONE_SCENE));
				}
			}
			
			if (fonts)
			{
				var fontIssues:uint = issues.totalFontIssues;;
				if (fontIssues == 0)
				{
					_logArea.add(LocaleManager.getString(LocaleManager.FONT_EMBED_ISSUES_FOUND, "0"), LogStyle.TYPE_GOOD);
				}
				else
				{
					_logArea.add(LocaleManager.getString(LocaleManager.FONT_EMBED_ISSUES_FOUND, fontIssues), LogStyle.TYPE_BAD);
				}
			}
			else
			{
				_logArea.add(LocaleManager.getString(LocaleManager.FONT_EMBED_SCAN_SKIPPED),LogStyle.TYPE_COMMENT);
			}
			
			if (common)
			{
				var commonIssues:uint = issues.totalCommonIssues;
				if (commonIssues == 0)
				{
					_logArea.add(LocaleManager.getString(LocaleManager.COMMON_ISSUES_FOUND, "0"), LogStyle.TYPE_GOOD);
				}
				else
				{
					_logArea.add(LocaleManager.getString(LocaleManager.COMMON_ISSUES_FOUND, commonIssues), LogStyle.TYPE_BAD);
				}
			}
			else
			{
				_logArea.add(LocaleManager.getString(LocaleManager.COMMON_SCAN_SKIPPED),LogStyle.TYPE_COMMENT);
			}
			
			if (performance)
			{
				var performanceIssues:uint = issues.totalPerformanceIssues;
				if (performanceIssues == 0)
				{
					_logArea.add(LocaleManager.getString(LocaleManager.PERFORMANCE_ISSUES_FOUND, "0"), LogStyle.TYPE_GOOD);
				}
				else
				{
					_logArea.add(LocaleManager.getString(LocaleManager.PERFORMANCE_ISSUES_FOUND, performanceIssues), LogStyle.TYPE_BAD);
				}
			}
			else
			{
				_logArea.add(LocaleManager.getString(LocaleManager.PERFORMANCE_SCAN_SKIPPED),LogStyle.TYPE_COMMENT);
			}
			
			if (elegancy)
			{
				var elegancyIssues:uint = issues.totalElegancyIssues;
				if (elegancyIssues == 0)
				{
					_logArea.add(LocaleManager.getString(LocaleManager.ELEGANCY_ISSUES_FOUND, "0"), LogStyle.TYPE_GOOD);
				}
				else
				{
					_logArea.add(LocaleManager.getString(LocaleManager.ELEGANCY_ISSUES_FOUND, elegancyIssues), LogStyle.TYPE_BAD);
				}
			}
			else
			{
				_logArea.add(LocaleManager.getString(LocaleManager.ELEGANCY_SCAN_SKIPPED),LogStyle.TYPE_COMMENT);
			}
			
			project.clear();
			project = null;
			
			return issues.totalIssues;
		}
		
		override public function onResize(e:Event):void
		{
			_logArea.width = stage.stageWidth - (_logArea.x + _optionsPanel.width + 18);
			_logArea.height = stage.stageHeight - _logArea.y - 73;
			
			_optionsPanel.x = _logArea.x + _logArea.width + 3;
			_optionsPanel.height = stage.stageHeight - _optionsPanel.y - 73;
			_startScanButton.y = _optionsPanel.height - 20 - 5;
			_copyLogButton.y = _startScanButton.y - 3 - 20;
			
			//_logArea.resizeItems();
			_logArea.draw();
			//_logArea.update();
			
			_optionsPanel.draw();
		}
	}
}