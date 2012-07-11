package ru.codestage.xfltool.ui.controls.antialiased 
{
	import com.bit101.components.InputText;
	import flash.display.DisplayObjectContainer;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class InputTextAntiAliased extends InputText 
	{
		
		public function InputTextAntiAliased(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, text:String="", defaultHandler:Function=null) 
		{
			super(parent, xpos, ypos, text, defaultHandler);
			_tf.antiAliasType = AntiAliasType.ADVANCED;
			_tf.gridFitType = GridFitType.SUBPIXEL;
		}
		
	}

}