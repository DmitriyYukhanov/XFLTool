package ru.codestage.xfltool.ui.controls.antialiased 
{
	import com.bit101.components.CheckBox;
	import flash.display.DisplayObjectContainer;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class CheckBoxAntiAliased extends CheckBox 
	{
		
		public function CheckBoxAntiAliased(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, label:String="", defaultHandler:Function=null) 
		{
			super(parent, xpos, ypos, label, defaultHandler);
			_label.textField.antiAliasType = AntiAliasType.ADVANCED;
			_label.textField.gridFitType = GridFitType.SUBPIXEL;
		}
		
	}

}