package ru.codestage.xfltool.map.items.elements.attributes 
{
	/**
	 * ...
	 * @author focus | http://blog.codestage.ru
	 */
	public final class ElementDropShadowFilter extends ElementBlurFilter 
	{
		public var distance:Number = 5;
		public var angle:Number = 45;
		public var color:uint = 0x000000;
		public var strength:Number = 1;
		public var inner:Boolean = false;
		public var knockout:Boolean = false;
		public var hideObject:Boolean = false;
		
		public function ElementDropShadowFilter() 
		{
			super();
		}
		
	}

}