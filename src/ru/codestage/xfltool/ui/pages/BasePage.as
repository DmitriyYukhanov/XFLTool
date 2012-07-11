package ru.codestage.xfltool.ui.pages
{
	import com.bit101.components.Component;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public class BasePage extends Component
	{
		
		public function BasePage(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			super(parent, xpos, ypos);
		}
		
		public function initialize(buildedElements:Vector.<Component>):void
		{
			onResize(null);
		}
		
		public function show():void
		{
			this.visible = true;
			onResize(null);
		}
		
		public function hide():void
		{
			this.visible = false;
		}
		
		public function onResize(e:Event):void
		{
			
		}
		
		public function update():void
		{
			
		}
	}

}