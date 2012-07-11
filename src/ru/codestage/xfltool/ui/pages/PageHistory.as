package ru.codestage.xfltool.ui.pages
{
	import com.bit101.components.Component;
	import com.bit101.components.TextArea;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.filesystem.File;
	import ru.codestage.xfltool.readers.FileReader;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	import ru.codestage.xfltool.ui.pages.BasePage;

	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class PageHistory extends BasePage
	{
		private var _history:TextArea;
		
		public function PageHistory(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			super(parent, xpos, ypos);
		}
		
		override public function initialize(buildedElements:Vector.<Component>):void
		{
			_history = (buildedElements[0] as TextArea);
			
			var historyFile:File = File.applicationDirectory.resolvePath("history/history_" + LocaleManager.instance.currentLanguage + ".txt");
			_history.text = new FileReader().readFileToString(historyFile);
			onResize(null);
		}
		
		override public function onResize(e:Event):void
		{
			_history.width = stage.stageWidth - 20;
			_history.height = stage.stageHeight - _history.y - 73;
			
			_history.draw();
		}
	}
}