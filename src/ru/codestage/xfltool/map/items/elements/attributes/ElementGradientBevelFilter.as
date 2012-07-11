package ru.codestage.xfltool.map.items.elements.attributes 
{
	/**
	 * ...
	 * @author focus | http://blog.codestage.ru
	 */
	public final class ElementGradientBevelFilter extends ElementBlurFilter 
	{
		public var distance:Number = 5;
		public var angle:Number = 45;
		public var strength:Number = 1;
		public var type:String = "inner";
		public var knockout:Boolean = false;
		
		public function ElementGradientBevelFilter() 
		{
			super();
		}
		
	}

}