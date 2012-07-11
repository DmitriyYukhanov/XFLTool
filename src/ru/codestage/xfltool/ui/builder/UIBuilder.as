package ru.codestage.xfltool.ui.builder
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.ComboBox;
	import com.bit101.components.Component;
	import com.bit101.components.HBox;
	import com.bit101.components.IndicatorLight;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.List;
	import com.bit101.components.Panel;
	import com.bit101.components.ProgressBar;
	import com.bit101.components.PushButton;
	import com.bit101.components.RadioButton;
	import com.bit101.components.Style;
	import com.bit101.components.Text;
	import com.bit101.components.TextArea;
	import com.bit101.components.Window;
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.TextFieldAutoSize;
	import ru.codestage.xfltool.Main;
	import ru.codestage.xfltool.settings.Settings;
	import ru.codestage.xfltool.ui.controls.alert.Alert;
	import ru.codestage.xfltool.ui.controls.antialiased.CheckBoxAntiAliased;
	import ru.codestage.xfltool.ui.controls.antialiased.ComboBoxAntiAliased;
	import ru.codestage.xfltool.ui.controls.antialiased.InputTextAntiAliased;
	import ru.codestage.xfltool.ui.controls.antialiased.LabelAntiAliased;
	import ru.codestage.xfltool.ui.controls.antialiased.ListAntiAliased;
	import ru.codestage.xfltool.ui.controls.antialiased.PushButtonAntiAliased;
	import ru.codestage.xfltool.ui.controls.antialiased.RadioButtonAntiAliased;
	import ru.codestage.xfltool.ui.controls.antialiased.TextAntiAliased;
	import ru.codestage.xfltool.ui.controls.antialiased.TextAreaAntiAliased;
	import ru.codestage.xfltool.ui.controls.FlatText;
	import ru.codestage.xfltool.ui.controls.log.LogArea;
	import ru.codestage.xfltool.ui.controls.log.LogStyle;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	import ru.codestage.xfltool.ui.pages.constants.PageTypes;
	import ru.codestage.xfltool.ui.pages.MainPage;
	import ru.codestage.xfltool.ui.pages.PageAbout;
	import ru.codestage.xfltool.ui.pages.PageBitmapsCompression;
	import ru.codestage.xfltool.ui.pages.PageHistory;
	import ru.codestage.xfltool.ui.pages.PageIssuesScan;
	import ru.codestage.xfltool.ui.pages.PageOptions;
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class UIBuilder extends Object
	{
		
		private static var _instance:UIBuilder;
		
		public var mainPage:MainPage;
		
		public function UIBuilder()
		{
			
		}
		
		public static function get instance():UIBuilder
		{
			if (!_instance) _instance = new UIBuilder();
			return _instance;
		}
		
		public function buildPage(pageContainer:DisplayObjectContainer, pageType:uint):void
		{
			var browseBtn:PushButtonAntiAliased;
			var buildedElements:Vector.<Component> = new Vector.<Component>();
			var tempColor:uint;
			var logArea:LogArea;
			var optionsPanel:Panel;
			var copyLogButton:PushButtonAntiAliased;
			
			if (pageType == PageTypes.PAGE_MAIN)
			{
				mainPage = new MainPage();
				pageContainer.addChild(mainPage);
				
				var xflLabel:LabelAntiAliased = new LabelAntiAliased(mainPage, 5, 7, LocaleManager.getString(LocaleManager.GUI_XFL_PATH));
				xflLabel.mouseChildren = false;
				xflLabel.mouseEnabled = false;
				
				var xflPathEdit:InputTextAntiAliased = new InputTextAntiAliased(mainPage, xflLabel.width + xflLabel.x + 3, 5);
				xflPathEdit.maxChars = 300;
				xflPathEdit.height = 20;
				
				var selectRecentBtn:PushButtonAntiAliased = new PushButtonAntiAliased(xflPathEdit, xflPathEdit.width, 0, ">");
				selectRecentBtn.width = 20;
				selectRecentBtn.height = 20;
				selectRecentBtn.rotation = 90;
				
				var xflFoundStatus:IndicatorLight = new IndicatorLight(xflPathEdit, xflPathEdit.width - 35, 5, 0xFF0000, "");
				xflFoundStatus.isLit = true;
				xflFoundStatus.mouseChildren = false;
				xflFoundStatus.mouseEnabled = false;
				
				browseBtn = new PushButtonAntiAliased(mainPage, xflPathEdit.x + xflPathEdit.width + 3, 5, LocaleManager.getString(LocaleManager.GUI_BROWSE));
				browseBtn.width = 80;
				browseBtn.height = 20;
				
				Style.fontSize = 14;
				tempColor = Style.LABEL_TEXT;
				Style.LABEL_TEXT = 0xA3F1A0;
				
				var pageSelector:ComboBoxAntiAliased = new ComboBoxAntiAliased(mainPage, 5, 30);
				pageSelector.alternateRows = false;
				pageSelector.height = 30;
				Style.fontSize = 12;
				Style.LABEL_TEXT = tempColor;
				
				var pagesPanel:Panel = new Panel(mainPage, 5, pageSelector.y + pageSelector.height + 3);
				pagesPanel.mouseEnabled = false;
				
				var recentXFLPaths:ListAntiAliased = new ListAntiAliased(mainPage, xflPathEdit.x, xflPathEdit.y + xflPathEdit.height);
				recentXFLPaths.visible = false;
				recentXFLPaths.height = recentXFLPaths.listItemHeight * 5;
				recentXFLPaths.autoHideScrollBar = true;
				
				var messageBox:Alert = new Alert(Main.instance, 0, 0);
				
				buildedElements.push(xflPathEdit, browseBtn, xflFoundStatus, pageSelector, pagesPanel, messageBox, recentXFLPaths, selectRecentBtn);
				mainPage.initialize(buildedElements);
				this.mainPage = mainPage;
			}
			else if (pageType == PageTypes.PAGE_ISSUES_SCAN)
			{
				var issuesPage:PageIssuesScan = new PageIssuesScan(pageContainer);
				
				logArea = new LogArea(issuesPage, 5, 5);
				
				optionsPanel = new Panel(issuesPage, logArea.x + logArea.width + 3, 5);
				optionsPanel.shadow = false;
				optionsPanel.width = 220;
				optionsPanel.mouseEnabled = false;
				
				var legend:Panel = _createLegend(optionsPanel);
				
				var scanOptions:Panel = new Panel(optionsPanel, 5, legend.y + legend.height + 3);
				scanOptions.width = optionsPanel.width - 10;
				scanOptions.shadow = false;
				scanOptions.mouseEnabled = false;
				
				var scanOptionsLabel:LabelAntiAliased = new LabelAntiAliased(scanOptions, 5, 0, LocaleManager.getString(LocaleManager.GUI_SCAN_OPTIONS));
				scanOptionsLabel.mouseChildren = false;
				scanOptionsLabel.mouseEnabled = false;
				
				var scanPublish:CheckBoxAntiAliased = new CheckBoxAntiAliased(scanOptions, 10, scanOptionsLabel.y + scanOptionsLabel.height + 3, LocaleManager.getString(LocaleManager.GUI_PUBLISH_SETTINGS));
				scanPublish.selected = Settings.instance.data.issuesScanPublishCheck;
				
				var scanFonts:CheckBoxAntiAliased = new CheckBoxAntiAliased(scanOptions, 10, scanPublish.y + scanPublish.height + 3, LocaleManager.getString(LocaleManager.GUI_FONTS_EMBED));
				scanFonts.selected = Settings.instance.data.issuesScanFontsCheck;
				
				var scanCommon:CheckBoxAntiAliased = new CheckBoxAntiAliased(scanOptions, 10, scanFonts.y + scanFonts.height + 3, LocaleManager.getString(LocaleManager.GUI_COMMON));
				scanCommon.selected = Settings.instance.data.issuesScanCommonCheck;
				
				var scanPerformance:CheckBoxAntiAliased = new CheckBoxAntiAliased(scanOptions, 10, scanCommon.y + scanCommon.height + 3, LocaleManager.getString(LocaleManager.GUI_PERFORMANCE));
				scanPerformance.selected = Settings.instance.data.issuesScanPerformanceCheck;
				
				var scanElegancy:CheckBoxAntiAliased = new CheckBoxAntiAliased(scanOptions, 10, scanPerformance.y + scanPerformance.height + 3, LocaleManager.getString(LocaleManager.GUI_ELEGANCY));
				scanElegancy.selected = Settings.instance.data.issuesScanElegancyCheck;
				
				scanOptions.height = scanElegancy.y + scanElegancy.height + 8;
				
				tempColor = Style.LABEL_TEXT;
				Style.LABEL_TEXT = 0x59eb60;
				
				var startScanButton:PushButtonAntiAliased = new PushButtonAntiAliased(optionsPanel, 5, optionsPanel.height - 20 - 5, LocaleManager.getString(LocaleManager.GUI_START_SCAN));
				startScanButton.height = 20;
				startScanButton.width = optionsPanel.width - 10;
				startScanButton.draw();
				Style.LABEL_TEXT = tempColor;
				
				copyLogButton = new PushButtonAntiAliased(optionsPanel, 5, startScanButton.y - 3 - 20, LocaleManager.getString(LocaleManager.GUI_LOG_TO_CLIP));
				copyLogButton.height = 20;
				copyLogButton.width = optionsPanel.width - 10;
				
				buildedElements.push(startScanButton, optionsPanel, logArea, copyLogButton, scanPublish, scanFonts, scanCommon, scanPerformance, scanElegancy);
				mainPage.subPages[PageTypes.PAGE_ISSUES_SCAN] = issuesPage;
				mainPage.currentPage = issuesPage;
				issuesPage.initialize(buildedElements);
			}
			else if (pageType == PageTypes.PAGE_BITMAPS_COMPRESSION)
			{
				var bitmapsPage:PageBitmapsCompression = new PageBitmapsCompression(pageContainer);
				
				logArea = new LogArea(bitmapsPage, 5, 5);
				
				optionsPanel = new Panel(bitmapsPage, logArea.x + logArea.width + 3, 5);
				optionsPanel.shadow = false;
				optionsPanel.width = 190;
				optionsPanel.mouseEnabled = false;
				
				var JPEGOptions:Panel = new Panel(optionsPanel, 5, 5);
				JPEGOptions.width = optionsPanel.width - 10;
				JPEGOptions.shadow = false;
				JPEGOptions.mouseEnabled = false;
				
				var JPEGOptionsLabel:LabelAntiAliased = new LabelAntiAliased(JPEGOptions, 5, 5, LocaleManager.getString(LocaleManager.GUI_QUAITY));
				JPEGOptionsLabel.mouseChildren = false;
				JPEGOptionsLabel.mouseEnabled = false;
				
				var publishJPEGSettings:RadioButtonAntiAliased = new RadioButtonAntiAliased(JPEGOptions, 5, JPEGOptionsLabel.y + JPEGOptionsLabel.height + 3, LocaleManager.getString(LocaleManager.GUI_PUBLISH_SETTINGS));
				publishJPEGSettings.groupName = "JPEGcompressionOptions";
				publishJPEGSettings.selected = Settings.instance.data.bitmapsCompressionJPEGPublishSettings;
				
				var customJPEGSettings:RadioButtonAntiAliased = new RadioButtonAntiAliased(JPEGOptions, 5, publishJPEGSettings.y + publishJPEGSettings.height + 3, LocaleManager.getString(LocaleManager.GUI_CUSTOM));
				customJPEGSettings.groupName = "JPEGcompressionOptions";
				customJPEGSettings.selected = Settings.instance.data.bitmapsCompressionJPEGCustom;
				
				var JPEGCompressionValeLabel:LabelAntiAliased = new LabelAntiAliased(JPEGOptions, 5, customJPEGSettings.y + customJPEGSettings.height + 3, LocaleManager.getString(LocaleManager.GUI_CURRENT_QUALITY));
				JPEGCompressionValeLabel.mouseChildren = false;
				JPEGCompressionValeLabel.mouseEnabled = false;
				
				var JPEGCompressionValue:TextAntiAliased = new TextAntiAliased(JPEGOptions, JPEGCompressionValeLabel.x + JPEGCompressionValeLabel.width + 5, JPEGCompressionValeLabel.y);
				JPEGCompressionValue.height = 20;
				JPEGCompressionValue.width = 38;
				JPEGCompressionValue.textField.restrict = "0-9";
				JPEGCompressionValue.textField.maxChars = 3;
				
				JPEGOptions.height = JPEGCompressionValeLabel.y + JPEGCompressionValeLabel.height + 8;
				
				var skipCustomFlag:CheckBoxAntiAliased = new CheckBoxAntiAliased(optionsPanel, 5, JPEGOptions.y + JPEGOptions.height + 5, LocaleManager.getString(LocaleManager.GUI_SKIP_WITH_CUSTOM_QUAL));
				skipCustomFlag.selected = Settings.instance.data.bitmapsCompressionSkipCustomCompression;
				
				tempColor = Style.LABEL_TEXT;
				Style.LABEL_TEXT = 0x59eb60;
				var startButton:PushButtonAntiAliased = new PushButtonAntiAliased(optionsPanel, 5, optionsPanel.height - 20 - 5, LocaleManager.getString(LocaleManager.GUI_START));
				startButton.height = 20;
				startButton.width = optionsPanel.width - 10;
				startButton.draw();
				Style.LABEL_TEXT = tempColor;
				
				tempColor = Style.LABEL_TEXT;
				Style.LABEL_TEXT = 0xeb5959;
				var stopButton:PushButtonAntiAliased = new PushButtonAntiAliased(optionsPanel, 5, optionsPanel.height - 20 - 5, LocaleManager.getString(LocaleManager.GUI_STOP));
				stopButton.height = 20;
				stopButton.width = optionsPanel.width - 10;
				Style.LABEL_TEXT = tempColor;
				stopButton.visible = false;
				
				copyLogButton = new PushButtonAntiAliased(optionsPanel, 5, startButton.y - 3 - 20, LocaleManager.getString(LocaleManager.GUI_LOG_TO_CLIP));
				copyLogButton.height = 20;
				copyLogButton.width = optionsPanel.width - 10;
				
				var operationProgress:ProgressBar = new ProgressBar(optionsPanel, 5, copyLogButton.y - 3 - 20);
				operationProgress.height = 20;
				operationProgress.width = optionsPanel.width - 10;	
				
				buildedElements.push(logArea, optionsPanel, publishJPEGSettings, customJPEGSettings, JPEGCompressionValue, JPEGOptions,
									 startButton, copyLogButton, stopButton, skipCustomFlag, operationProgress);
				mainPage.subPages[PageTypes.PAGE_BITMAPS_COMPRESSION] = bitmapsPage;
				mainPage.currentPage = bitmapsPage;
				bitmapsPage.initialize(buildedElements);
			}
			else if (pageType == PageTypes.PAGE_OPTIONS)
			{
				
				var optionsPage:PageOptions = new PageOptions(pageContainer);
				
				var flashProLabel:LabelAntiAliased = new LabelAntiAliased(optionsPage, 5, 7, LocaleManager.getString(LocaleManager.GUI_FLASH_PRO_PATH));
				flashProLabel.mouseChildren = false;
				flashProLabel.mouseEnabled = false;
				
				var flashProPathEdit:InputTextAntiAliased = new InputTextAntiAliased(optionsPage, 7, flashProLabel.y + flashProLabel.height + 3);
				flashProPathEdit.maxChars = 500;
				flashProPathEdit.height = 20;
				
				var flashProFoundStatus:IndicatorLight = new IndicatorLight(flashProPathEdit, flashProPathEdit.width - 17, 5, 0xFF0000, "");
				flashProFoundStatus.isLit = true;
				flashProFoundStatus.mouseChildren = false;
				flashProFoundStatus.mouseEnabled = false;
				
				browseBtn = new PushButtonAntiAliased(optionsPage, flashProPathEdit.x + flashProPathEdit.width + 5, flashProPathEdit.y, LocaleManager.getString(LocaleManager.GUI_BROWSE));
				browseBtn.width = 80;
				browseBtn.height = 20;
				
				buildedElements.push(flashProPathEdit, browseBtn, flashProFoundStatus);
				
				mainPage.subPages[PageTypes.PAGE_OPTIONS] = optionsPage;
				mainPage.currentPage = optionsPage;
				optionsPage.initialize(buildedElements);
			}
			else if (pageType == PageTypes.PAGE_HISTORY)
			{
				
				var historyPage:PageHistory = new PageHistory(pageContainer);
				
				tempColor = Style.TEXT_BACKGROUND;
				Style.TEXT_BACKGROUND = Style.PANEL;
				
				var history:TextAreaAntiAliased = new TextAreaAntiAliased(historyPage, 5, 5);
				history.html = true;
				history.editable = false;
				history.autoHideScrollBar = true;
							 
				Style.TEXT_BACKGROUND = tempColor;
				
				buildedElements.push(history);
				mainPage.subPages[PageTypes.PAGE_HISTORY] = historyPage;
				mainPage.currentPage = historyPage;
				historyPage.initialize(buildedElements);
			}
			else if (pageType == PageTypes.PAGE_ABOUT)
			{
				
				var aboutPage:PageAbout = new PageAbout(pageContainer);
				
				Style.fontSize = 18;
				tempColor = Style.TEXT_BACKGROUND;
				Style.TEXT_BACKGROUND = Style.PANEL;
				
				/*var appName:LabelHtml = new LabelHtml(aboutPage, 5, 5);
				appName.html = true;*/
				
				var appName:FlatText = new FlatText(aboutPage, 5, 5);
				appName.html = true;
				
				var applicationDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
				var ns:Namespace = applicationDescriptor.namespace();
				//var appCopyright:String = applicationDescriptor.ns::copyright;
				var appVersion:String = applicationDescriptor.ns::versionLabel;
				//appName.selectable = false;
				appName.editable = false;
				if (LocaleManager.instance.currentLanguage == "ru_RU")
				{
					appName.text = "<u><a href=\"http://blog.codestage.ru/ru/xfltool/\">XFLTool</a></u> v." + appVersion;
				}
				else
				{
					appName.text = "<u><a href=\"http://blog.codestage.ru/xfltool/\">XFLTool</a></u> v." + appVersion;
				}
				appName.width = 230;
				appName.height = 20;
				
				Style.fontSize = 12;
				
				var links:TextAreaAntiAliased = new TextAreaAntiAliased(aboutPage, 5, appName.y + appName.height + 10);
				links.html = true;
				links.editable = false;
				links.autoHideScrollBar = true;
				
				links.text = "<p align=\"center\">" +  LocaleManager.getString(LocaleManager.GUI_THIRD_PARTY) +
							 "<p align=\"left\"><br><u><a href=\"http://segfaultlabs.com/devlogs/alchemy-asynchronous-jpeg-encoding-2\">Alchemy JPEG Encoder</a></u> [Mateusz Malczak]<br>" +
							 "<u><a href=\"http://code.google.com/p/as3localelib/\">as3localelib</a></u> [Adobe]<br>" +
							 "<u><a href=\"http://www.blooddy.by/en/crypto/\">blooddy_crypto</a></u> [Nick Ryzhy]<br>" +
							 "<u><a href=\"http://code.google.com/p/flash-console/\">FlashConsole</a></u> [Lu Aye Oo]<br>" +
							 "<u><a href=\"http://codeazur.com.br/lab/fzip/\">FZip</a></u> [Claus Wahlers, Max Herkender]<br>" +
							 "<u><a href=\"http://www.minimalcomps.com\">MinimalComps</a></u> [Keith Peters]<br>" +
							 "<u><a href=\"http://code.google.com/p/nativeapplicationupdater/\">NativeApplicationUpdater</a></u> [Piotr Walczyszyn]<br>" +
							 "<u><a href=\"http://gskinner.com/blog/archives/2009/04/as3_performance.html\">PerformanceTest</a></u> [Grant Skinner]<br>" +
							 "<u><a href=\"https://www.plimus.com/jsp/redirect.jsp?contractId=3042450&referrer=1032766\">TheMiner</a></u> [Jean-Philippe Auclair] (" + LocaleManager.getString(LocaleManager.GUI_THE_MINER_OFF) + ")</p><br><br>" +
							 LocaleManager.getString(LocaleManager.GUI_DISCLAIMER);
				
				if (LocaleManager.instance.currentLanguage == "ru_RU")
				{
					links.text += "<br><br>(C) 2011-2012 <u><a href=\"http://blog.codestage.ru/ru\">Дмитрий [focus] Юханов</a></u></p>";
				}
				else
				{
					links.text += "<br><br>(C) 2011-2012 <u><a href=\"http://blog.codestage.ru\">Dmitriy [focus] Yukhanov</a></u></p>";
				}
				
				Style.TEXT_BACKGROUND = tempColor;
				
				buildedElements.push(links);
				mainPage.subPages[PageTypes.PAGE_ABOUT] = aboutPage;
				mainPage.currentPage = aboutPage;
				aboutPage.initialize(buildedElements);
			}
		}
		
		private function _createLegend(optionsPanel:Panel):Panel
		{
			var legendPanel:Panel = new Panel(optionsPanel, 5, 5);
			legendPanel.shadow = false;
			legendPanel.width = optionsPanel.width - 10;
			legendPanel.mouseChildren = false;
			legendPanel.mouseEnabled = false;
			
			var legendLabel:LabelAntiAliased = new LabelAntiAliased(legendPanel, 5, 0, LocaleManager.getString(LocaleManager.GUI_COLORS_LEGEND));
			
			var lastColorBlock:Panel = new Panel(legendPanel, 10, legendLabel.y + legendLabel.height + 5);
			lastColorBlock.color = LogStyle.COLOR_TITLE;
			lastColorBlock.width = 10;
			lastColorBlock.height = 10;
			lastColorBlock.shadow = false;
			var lastColorLabel:LabelAntiAliased = new LabelAntiAliased(legendPanel, lastColorBlock.x + lastColorBlock.width + 1, lastColorBlock.y - 6, LocaleManager.getString(LocaleManager.GUI_COLORS_TITLE));
			
			lastColorBlock = new Panel(legendPanel, 100, lastColorBlock.y);
			lastColorBlock.color = LogStyle.COLOR_COMMENT;
			lastColorBlock.width = 10;
			lastColorBlock.height = 10;
			lastColorBlock.shadow = false;
			lastColorLabel = new LabelAntiAliased(legendPanel, lastColorBlock.x + lastColorBlock.width + 1, lastColorBlock.y - 6, LocaleManager.getString(LocaleManager.GUI_COLORS_COMMENT));
			
			lastColorBlock = new Panel(legendPanel, 10, lastColorLabel.y + lastColorLabel.height + 5);
			lastColorBlock.color = LogStyle.COLOR_CONTEXT_HINT;
			lastColorBlock.width = 10;
			lastColorBlock.height = 10;
			lastColorBlock.shadow = false;
			lastColorLabel = new LabelAntiAliased(legendPanel, lastColorBlock.x + lastColorBlock.width + 1, lastColorBlock.y - 6, LocaleManager.getString(LocaleManager.GUI_COLORS_HINT));
			
			lastColorBlock = new Panel(legendPanel, 100, lastColorBlock.y);
			lastColorBlock.color = LogStyle.COLOR_FONTS;
			lastColorBlock.width = 10;
			lastColorBlock.height = 10;
			lastColorBlock.shadow = false;
			lastColorLabel = new LabelAntiAliased(legendPanel, lastColorBlock.x + lastColorBlock.width + 1, lastColorBlock.y - 6, LocaleManager.getString(LocaleManager.GUI_COLORS_FONTS));
			
			lastColorBlock = new Panel(legendPanel, 10, lastColorLabel.y + lastColorLabel.height + 5);
			lastColorBlock.color = LogStyle.COLOR_COMMON;
			lastColorBlock.width = 10;
			lastColorBlock.height = 10;
			lastColorBlock.shadow = false;
			lastColorLabel = new LabelAntiAliased(legendPanel, lastColorBlock.x + lastColorBlock.width + 1, lastColorBlock.y - 6, LocaleManager.getString(LocaleManager.GUI_COLORS_COMMON));
			
			lastColorBlock = new Panel(legendPanel, 100, lastColorBlock.y);
			lastColorBlock.color = LogStyle.COLOR_ELEGANCY;
			lastColorBlock.width = 10;
			lastColorBlock.height = 10;
			lastColorBlock.shadow = false;
			lastColorLabel = new LabelAntiAliased(legendPanel, lastColorBlock.x + lastColorBlock.width + 1, lastColorBlock.y - 6, LocaleManager.getString(LocaleManager.GUI_COLORS_ELEGANCY));
			
			lastColorBlock = new Panel(legendPanel, 10, lastColorLabel.y + lastColorLabel.height + 5);
			lastColorBlock.color = LogStyle.COLOR_PERFORMANCE;
			lastColorBlock.width = 10;
			lastColorBlock.height = 10;
			lastColorBlock.shadow = false;
			lastColorLabel = new LabelAntiAliased(legendPanel, lastColorBlock.x + lastColorBlock.width + 1, lastColorBlock.y - 6, LocaleManager.getString(LocaleManager.GUI_COLORS_PERFORMANCE));
			
			legendPanel.height = lastColorLabel.y + lastColorLabel.height + 5;
			
			return legendPanel;
		}
	}

}