package ru.codestage.xfltool.map.items 
{
	import ru.codestage.xfltool.map.items.elements.Element;
	import ru.codestage.xfltool.map.items.elements.SymbolElement;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	/**
	 * ...
	 * @author focus | http://blog.codestage.ru
	 */
	public final class LayerItem extends Object 
	{
		public var name:String = '';
		public var layerType:String = '';
		public var autoNamed:Boolean = true;
		public var frames:Vector.<FrameItem>;
		public var elements:Vector.<Element>;
		public var children:Vector.<LayerItem>;
		
		/**
		 * Total frames in layer
		 */
		public var length:uint = 0;
		public var parentLayerIndex:uint = NaN;
		public var collectionIndex:uint;
		public var symbol:SymbolElement;
		public var haveServiceFrame:Boolean;
		
		public function LayerItem()
		{
			super();
			
		}
		
		public function getLocation():String 
		{
			return LocaleManager.getString(LocaleManager.LOCATION_AT_LAYER, symbol.name, name);
		}
		
	}

}