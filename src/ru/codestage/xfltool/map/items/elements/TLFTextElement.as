package ru.codestage.xfltool.map.items.elements
{
	import ru.codestage.xfltool.map.items.elements.attributes.ColorEffect;
	import ru.codestage.xfltool.map.items.elements.attributes.FilterBase;
	
	/**
	 * ...
	 * @author focus | http://blog.codestage.ru
	 */
	public final class TLFTextElement extends TextElement
	{
		public var blendMode:String;
		public var cacheAsBitmap:Boolean;
		public var hasSystemFont:Boolean;
		public var colorEffects:Vector.<ColorEffect>;
		public var fonts:Vector.<String>;
		public var allFontsAreEmbedded:Boolean = true;
		public var markup:String;
		public var tlfText:String;
		
		public function TLFTextElement()
		{
			super();
		}
	
	}

}