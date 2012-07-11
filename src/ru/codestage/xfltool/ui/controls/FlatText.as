package ru.codestage.xfltool.ui.controls 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import ru.codestage.xfltool.ui.controls.antialiased.TextAntiAliased;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class FlatText extends TextAntiAliased 
	{
		private var _autoSize:Boolean = true;
		
		public function FlatText(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, text:String="") 
		{
			super(parent, xpos, ypos, text);
			_panel.visible = false;
		}
	}

}