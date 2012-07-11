package ru.codestage.xfltool.ui.controls.antialiased 
{
	import com.bit101.components.ListItem;
	import flash.display.DisplayObjectContainer;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class ListItemAntiAliased extends ListItem 
	{
		
		public function ListItemAntiAliased(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, data:Object=null) 
		{
			super(parent, xpos, ypos, data);
			_label.textField.antiAliasType = AntiAliasType.ADVANCED;
			_label.textField.gridFitType = GridFitType.SUBPIXEL;
		}
		
	}

}