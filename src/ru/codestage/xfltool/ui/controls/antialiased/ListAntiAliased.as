package ru.codestage.xfltool.ui.controls.antialiased 
{
	import com.bit101.components.List;
	import flash.display.DisplayObjectContainer;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class ListAntiAliased extends List 
	{
		public function ListAntiAliased(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, items:Array=null) 
		{
			super(parent, xpos, ypos, items);
			_listItemClass = ListItemAntiAliased;
		}
		
	}

}