package ru.codestage.xfltool.map.items.elements.attributes 
{
	
	/**
	 * ...
	 * @author focus | http://blog.codestage.ru
	 */
	public final class ElementGlowFilter extends ElementBlurFilter 
	{
		public var color:uint = 0xFF0000;
		public var alpha:Number = 1;
		public var strength:Number = 1;
		public var inner:Boolean = false;
		public var knockout:Boolean = false;
		
		public function ElementGlowFilter() 
		{
			super();
		}
		
	}

}