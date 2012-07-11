package ru.codestage.xfltool.map.items.elements
{
	import ru.codestage.xfltool.map.items.elements.attributes.FilterBase;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	
	/**
	 * ...
	 * @author focus | http://blog.codestage.ru
	 */
	public class TextElement extends Element
	{
		public var name:String;
		public var type:String;
		public var fontName:String;
		public var fontEmbedded:Boolean;
		public var textRuns:String;
		public var text:String;
		public var aliasing:String = "readability";
		public var filters:Vector.<FilterBase>;
		
		public function TextElement()
		{
			super();
		}
		
		public override function getLocation(elementName:String = "Symbol"):String 
		{
			var location:String;
			
			if (name != null)
			{
				location = LocaleManager.getString(LocaleManager.LOCATION_ELEMENT_WITH_INSTANCE, 
												 elementName, name, parentSymbol.name, 
												 parentLayer.name, parentFrame.index + 1);
			}
			else
			{
				location = LocaleManager.getString(LocaleManager.LOCATION_ELEMENT_WITHOUT_INSTANCE, 
												 elementName, parentSymbol.name, parentLayer.name, parentFrame.index + 1);
			}
			
			if (lastLocationToFrame)
			{
				location += LocaleManager.getString(LocaleManager.LOCATION_TO_FRAME, lastLocationToFrame.index + 1);
				lastLocationToFrame = null;
			}
			
			return location;
		}
	
	}

}