package ru.codestage.xfltool.ui.controls.log
{
	import com.bit101.components.Style;
	import flash.system.ApplicationDomain;
	import flash.text.Font;
	import flash.text.StyleSheet;
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class LogStyle extends Object
	{
		
		public static const COLOR_TITLE:uint = 0xFFFFFF;
		public static const COLOR_CONTEXT_HINT:uint = 0xe1e894;
		public static const COLOR_GOOD:uint = 0x71f778;
		public static const COLOR_BAD:uint = 0xF99F9F;
		public static const COLOR_IMPORTANT:uint = 0xe8b874;
		public static const COLOR_VERY_IMPORTANT:uint = 0xFF7777;
		public static const COLOR_COMMENT:uint = 0xABABAB;
		public static const COLOR_SELECT:uint = 0x94E7ED;
		public static const COLOR_COMMON:uint = 0xEECD86;
		public static const COLOR_FONTS:uint = 0x95CAFF;
		public static const COLOR_PERFORMANCE:uint = 0x95FFFF;
		public static const COLOR_ELEGANCY:uint = 0xFFBFEF;
		
		public static const TYPE_CONTEXT_HINT:String = "TYPE_CONTEXT_HINT";
		public static const TYPE_TITLE:String = "TYPE_TITLE";
		public static const TYPE_GOOD:String = "TYPE_GOOD";
		public static const TYPE_BAD:String = "TYPE_BAD";
		public static const TYPE_IMPORTANT:String = "TYPE_IMPORTANT";
		public static const TYPE_VERY_IMPORTANT:String = "TYPE_VERY_IMPORTANT";
		public static const TYPE_COMMENT:String = "TYPE_COMMENT";
		public static const TYPE_SELECT:String = "TYPE_SELECT";
		public static const TYPE_COMMON:String = "TYPE_COMMON";
		public static const TYPE_FONTS:String = "TYPE_FONTS";
		public static const TYPE_PERFORMANCE:String = "TYPE_PERFORMANCE";
		public static const TYPE_ELEGANCY:String = "TYPE_ELEGANCY";
		
		public var styleSheet:StyleSheet;
		
		
		public function LogStyle()
		{
			super();
			
			updateStyleSheet();
		}
		
		public function updateStyleSheet():void 
		{
			styleSheet = new StyleSheet();
			styleSheet.setStyle(".line",{leading:"-5"});
			styleSheet.setStyle(".body",{color:_hesh(Style.LABEL_TEXT)});
			styleSheet.setStyle("." + TYPE_TITLE,{color:_hesh(COLOR_TITLE), fontSize:18, display:'inline', textAlign:'center'});
			styleSheet.setStyle("." + TYPE_CONTEXT_HINT,{color:_hesh(COLOR_CONTEXT_HINT), textAlign:"justify", display:'inline'});
			styleSheet.setStyle("." + TYPE_GOOD,{color:_hesh(COLOR_GOOD), display:'inline'});
			styleSheet.setStyle("." + TYPE_BAD,{color:_hesh(COLOR_BAD), display:'inline'});
			styleSheet.setStyle("." + TYPE_IMPORTANT,{color:_hesh(COLOR_IMPORTANT), display:'inline'});
			styleSheet.setStyle("." + TYPE_VERY_IMPORTANT,{color:_hesh(COLOR_VERY_IMPORTANT), display:'inline'});
			styleSheet.setStyle("." + TYPE_COMMENT,{color:_hesh(COLOR_COMMENT), display:'inline'});
			styleSheet.setStyle("." + TYPE_SELECT,{color:_hesh(COLOR_SELECT), display:'inline'});
			styleSheet.setStyle("." + TYPE_COMMON,{color:_hesh(COLOR_COMMON), display:'inline', marginLeft:"20"});
			styleSheet.setStyle("." + TYPE_FONTS,{color:_hesh(COLOR_FONTS), display:'inline', marginLeft:"20"});
			styleSheet.setStyle("." + TYPE_PERFORMANCE,{color:_hesh(COLOR_PERFORMANCE), display:'inline', marginLeft:"20"});
			styleSheet.setStyle("." + TYPE_ELEGANCY,{color:_hesh(COLOR_ELEGANCY), display:'inline', marginLeft:"20"});
		}
		
		private function _hesh(n:uint):String
		{
			return "#"+n.toString(16);
		}
	}

}