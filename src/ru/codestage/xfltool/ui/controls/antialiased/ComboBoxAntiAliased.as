package ru.codestage.xfltool.ui.controls.antialiased 
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.List;
	import com.bit101.components.PushButton;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class ComboBoxAntiAliased extends ComboBox 
	{
		
		public function ComboBoxAntiAliased(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, defaultLabel:String="", items:Array=null) 
		{
			super(parent, xpos, ypos, defaultLabel, items);
			
		}
		
		override protected function addChildren():void
		{
			_list = new ListAntiAliased(null, 0, 0, _items);
			_list.autoHideScrollBar = true;
			_list.addEventListener(Event.SELECT, onSelect);

			_labelButton = new PushButtonAntiAliased(this, 0, 0, "", onDropDown);
			_dropDownButton = new PushButtonAntiAliased(this, 0, 0, "+", onDropDown);
		}
	}

}