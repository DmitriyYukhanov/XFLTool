package ru.codestage.xfltool.ui
{
	import flash.display.Stage;
	import flash.events.Event;
	import ru.codestage.xfltool.ui.builder.UIBuilder;
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class ControlsResizer extends Object
	{
		private static var _instance:ControlsResizer;
		private var _stage:Stage;
		
		public function ControlsResizer()
		{
			
		}
		
		public static function get instance():ControlsResizer
		{
			if (!_instance) _instance = new ControlsResizer();
			return _instance;
		}
		
		public function init(stage:Stage):void
		{
			_stage = stage;
			
			_stage.addEventListener(Event.RESIZE, _onResize);
			_onResize(null);
		}
		
		private function _onResize(e:Event):void
		{
			UIBuilder.instance.mainPage.onResize(e);
			if (UIBuilder.instance.mainPage.currentPage)
			{
				UIBuilder.instance.mainPage.currentPage.onResize(e);
			}
			_stage.invalidate();
		}
	}

}