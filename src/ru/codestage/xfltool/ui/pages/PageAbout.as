package ru.codestage.xfltool.ui.pages
{
	import com.bit101.components.Component;
	import com.bit101.components.Text;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import ru.codestage.xfltool.ui.pages.BasePage;

	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class PageAbout extends BasePage
	{
		private var _links:Text;
		
		public function PageAbout(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			super(parent, xpos, ypos);
		}
		
		override public function initialize(buildedElements:Vector.<Component>):void
		{
			_links = (buildedElements[0] as Text);
			
			onResize(null);
		}
		
		override public function onResize(e:Event):void
		{
			_links.width = stage.stageWidth - 20;
			_links.height = stage.stageHeight - _links.y - 73;
			
			_links.draw();
		}
	}
}