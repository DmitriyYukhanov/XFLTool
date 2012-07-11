package ru.codestage.xfltool.ui.controls.antialiased 
{
	import com.bit101.components.TextArea;
	import flash.display.DisplayObjectContainer;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class TextAreaAntiAliased extends TextArea 
	{
		
		public function TextAreaAntiAliased(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, text:String="") 
		{
			super(parent, xpos, ypos, text);
			_tf.antiAliasType = AntiAliasType.ADVANCED;
			_tf.gridFitType = GridFitType.SUBPIXEL;
		}
		
	}

}