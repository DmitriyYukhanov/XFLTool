package ru.codestage.xfltool.scanners.base 
{
	/**
	 * ...
	 * @author focus | http://blog.codestage.ru
	 */
	public final class TweenedIssues extends Object 
	{
		public var matrixTransformed:uint = 0;
		public var colorEffectChanged:uint = 0;
		public var filterChanged:uint = 0;
		
		public var cachedMatrixTransformed:uint = 0;
		public var cachedColorEffectChanged:uint = 0;
		public var cachedFilterChanged:uint = 0;
		
		public function isCachedIssueFound():Boolean
		{
			return ((cachedMatrixTransformed + cachedColorEffectChanged + cachedFilterChanged) > 0);
		}
		
		public function isIssueFound():Boolean
		{
			return ((matrixTransformed + colorEffectChanged + filterChanged) > 0);
		}
	}

}