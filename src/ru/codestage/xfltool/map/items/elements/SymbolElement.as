package ru.codestage.xfltool.map.items.elements
{
	import ru.codestage.xfltool.constants.Issues;
	import ru.codestage.xfltool.map.items.elements.attributes.ColorEffect;
	import ru.codestage.xfltool.map.items.elements.attributes.ElementMatrix;
	import ru.codestage.xfltool.map.items.elements.attributes.ElementPoint;
	import ru.codestage.xfltool.map.items.elements.attributes.FilterBase;
	import ru.codestage.xfltool.map.items.elements.Element;
	import ru.codestage.xfltool.map.items.FrameItem;
	import ru.codestage.xfltool.map.items.LayerItem;
	import ru.codestage.xfltool.map.items.TimelineItem;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	
	/**
	 * ...
	 * @author focus | http://blog.codestage.ru
	 */
	public final class SymbolElement extends LibraryElement
	{
		public var type:String;
		public var instanceName:String;
		public var blendMode:String;
		public var cacheAsBitmap:Boolean;
		public var exportAsBitmap:Boolean;
		public var transparentBackground:Boolean = true;
		public var linkaged:Boolean;
		public var matrix3D:String;
		public var colorEffects:Vector.<ColorEffect>;
		public var filters:Vector.<FilterBase>;
		public var isVisible:Boolean = true;
		public var librarySymbol:SymbolElement;
		public var alpha:Number = 1;
		
		public var ownTimeline:TimelineItem;
		public var ownLayers:Vector.<LayerItem>;
		public var ownFrames:Vector.<FrameItem>;
		public var ownChildren:Vector.<Element>;
		public var ownChildrenSymbols:Vector.<SymbolElement>;
		
		public var includedIntoMatrixIssue:Boolean;
		public var includedIntoColorsIssue:Boolean;
		public var includedIntoFiltersIssue:Boolean;
		
		
		public function SymbolElement()
		{
			super();
		}
		
		public override function getLocation(elementName:String = "Symbol"):String 
		{
			var location:String;
			
			if (instanceName != null && instanceName != "")
			{
				location = elementName + " " + LocaleManager.getString(LocaleManager.LOCATION_ELEMENT_WITH_INSTANCE, 
												 name, instanceName, parentSymbol.name, 
												 parentLayer.name, parentFrame.index + 1);
												 
				
			}
			else
			{
				location = elementName + " " + LocaleManager.getString(LocaleManager.LOCATION_ELEMENT_WITHOUT_INSTANCE, 
												 name, parentSymbol.name, 
												 parentLayer.name, parentFrame.index + 1);
			}
			
			if (lastLocationToFrame)
			{
				location += LocaleManager.getString(LocaleManager.LOCATION_TO_FRAME, lastLocationToFrame.index + 1);
				lastLocationToFrame = null;
			}
			
			return location;
		}
		
		public function applyLibrarySymbol(librarySymbol:SymbolElement):void 
		{
			this.librarySymbol = librarySymbol;
			this.ownTimeline = librarySymbol.ownTimeline;
			this.ownLayers = librarySymbol.ownLayers;
			this.ownFrames = librarySymbol.ownFrames;
			this.ownChildren = librarySymbol.ownChildren;
			this.ownChildrenSymbols = librarySymbol.ownChildrenSymbols;
		}
		
	}

}