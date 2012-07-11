package ru.codestage.xfltool
{
	import air.update.ApplicationUpdaterUI;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	import com.bit101.components.Component;
	import com.bit101.components.Style;
	import com.junkbyte.console.Cc;
	import com.riaspace.nativeApplicationUpdater.NativeApplicationUpdater;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	import flash.system.System;
	import flash.text.AntiAliasType;
	import flash.text.FontStyle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import ru.codestage.xfltool.settings.Settings;
	import ru.codestage.xfltool.ui.builder.UIBuilder;
	import ru.codestage.xfltool.ui.controls.alert.Alert;
	import ru.codestage.xfltool.ui.controls.log.LogStyle;
	import ru.codestage.xfltool.ui.ControlsResizer;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	import ru.codestage.xfltool.ui.pages.constants.PageTypes;
	import ru.codestage.xfltool.ui.pages.MainPage;
	import flash.desktop.NativeDragManager; 
	import ru.codestage.xfltool.update.UpdateManager;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class Main extends Sprite
	{
		
		private var _regular:DejaVuSansMonoRegular;
		private var _bold:DejaVuSansMonoBold;
		private var _italic:DejaVuSansMonoItalic;
		private var _boldItalic:DejaVuSansMonoBoldItalic;
		private var _appUpdater:ApplicationUpdaterUI;
		
		public static var instance:Main;
		public var logStyle:LogStyle;
		
		private function _enableCC(parent:DisplayObjectContainer, debug:Boolean = true):void
		{
			if (parent)
			{
				Cc.config.commandLineAllowed = debug;
				Cc.config.commandLineAutoScope = true;
				Cc.config.defaultStackDepth = 10;
				Cc.config.displayRollerEnabled = debug;
				Cc.config.maxRepeats = -1;
				if (debug) Cc.config.objectHardReferenceTimer = 120;
				Cc.config.sharedObjectName = 'com.junkbyte/Console/UserData/focus';
				Cc.config.tracing = false;
				Cc.config.useObjectLinking = debug;
				
				Cc.config.style.backgroundAlpha = 0.8;
				Cc.config.style.backgroundColor = 0x101010;
				Cc.config.style.panelSnapping = 10;
				Cc.config.style.roundBorder = 0;
				
				if (debug)
				{
					Cc.startOnStage(parent);
					if (parent is Stage)
					{
						parent.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
					}
					else if (parent.stage)
					{
						parent.stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown)
					}
					else
					{
						parent.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown)
					}
				}
				else
				{
					Cc.startOnStage(parent, "debugconsole");
				}
				
				Cc.fpsMonitor = debug;
				Cc.memoryMonitor = debug;
				Cc.remoting = false;
				Cc.commandLine = debug;
				Cc.width = 600;
				Cc.height = 100;
				Cc.listenUncaughtErrors(this.loaderInfo);
				Cc.visible = false;
				if (debug) Cc.setRollerCaptureKey('s', true, false, true);
			}
		}
		
		private function _onKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode == 192 || e.keyCode == 167 || e.keyCode == 177)
			{
				Cc.visible = !Cc.visible;
			}
		}
		
		public function Main()
		{
			instance = this;
			this.addEventListener(Event.FRAME_CONSTRUCTED, _onTimelineConsructed);
		}
		
		private function _onTimelineConsructed(e:Event):void
		{
			this.removeEventListener(Event.FRAME_CONSTRUCTED, _onTimelineConsructed);
			_init();
		}
		
		private function _init():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.nativeWindow.addEventListener(Event.CLOSING, _onExiting);
			stage.quality = StageQuality.LOW;
			
			_enableCC(this);
			
			Style.setStyle(Style.DARK);
			Style.embedFonts = true;
			Style.fontName = "DejaVu Sans Mono";
			Style.fontSize = 12;
			Component.initStage(stage);
			
			logStyle = new LogStyle();
			
			var applicationDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = applicationDescriptor.namespace();
			var appCopyright:String = applicationDescriptor.ns::copyright;
			var appVersion:String = applicationDescriptor.ns::versionLabel;
			stage.nativeWindow.title = "XFLTool v." + appVersion;
			
			var so:SharedObject = SharedObject.getLocal("codestage.XFLTool");
			if (so.data.applicationStorageDirectory)
			{
				if (so.data.applicationStorageDirectory != File.applicationStorageDirectory.nativePath)
				{
					Settings.instance.moveSettings(new File(so.data.applicationStorageDirectory));
				}
			}
			so.clear();
			so = null;
			
			Settings.instance.load();
			LocaleManager.instance.init();
			PageTypes.init();
			
			UIBuilder.instance.buildPage(this, PageTypes.PAGE_MAIN);
			ControlsResizer.instance.init(stage);
			
			UpdateManager.instance.checkForUpdates();
		}
		
		private function _onExiting(e:Event):void
		{
			stage.nativeWindow.removeEventListener(Event.CLOSING, _onExiting);
			Settings.instance.save();
		}
	}

}