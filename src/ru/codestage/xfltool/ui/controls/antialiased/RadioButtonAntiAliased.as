package ru.codestage.xfltool.ui.controls.antialiased 
{
	import com.bit101.components.RadioButton;
	import flash.display.DisplayObjectContainer;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class RadioButtonAntiAliased extends RadioButton 
	{
		
		public function RadioButtonAntiAliased(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, label:String="", checked:Boolean=false, defaultHandler:Function=null) 
		{
			super(parent, xpos, ypos, label, checked, defaultHandler);
			_label.textField.antiAliasType = AntiAliasType.ADVANCED;
			_label.textField.gridFitType = GridFitType.SUBPIXEL;
		}
		
	}

}