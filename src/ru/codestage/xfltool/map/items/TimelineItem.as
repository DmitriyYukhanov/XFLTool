package ru.codestage.xfltool.map.items 
{
	import ru.codestage.xfltool.map.items.LayerItem;
	/**
	 * ...
	 * @author focus | http://blog.codestage.ru
	 */
	public final class TimelineItem extends Object
	{
		public var layers:Vector.<LayerItem>;
		
		public var totalKeyFrames:uint = 0;
		public var hasSymbols:Boolean = false;
		public var hasOnlyBitmaps:Boolean = true;
		public var hasAnimation:Boolean = false;
		
		public function TimelineItem() 
		{
			super();
			
		}
		
	}

}