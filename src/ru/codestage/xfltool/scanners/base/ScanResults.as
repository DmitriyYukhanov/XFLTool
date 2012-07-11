package ru.codestage.xfltool.scanners.base 
{
	import ru.codestage.xfltool.scanners.base.ScanResults;
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class ScanResults extends Object 
	{
		public var totalFontIssues:uint = 0;
		public var totalCommonIssues:uint = 0;
		public var totalElegancyIssues:uint = 0;
		public var totalPerformanceIssues:uint = 0;
		
		public function ScanResults() 
		{
			
		}
		
		public function concat(results:ScanResults):void 
		{
			this.totalFontIssues += results.totalFontIssues;
			this.totalCommonIssues += results.totalCommonIssues;
			this.totalElegancyIssues += results.totalElegancyIssues;
			this.totalPerformanceIssues += results.totalPerformanceIssues;
		}
		
		public function get totalIssues():uint 
		{
			return totalFontIssues + totalCommonIssues + totalElegancyIssues + totalPerformanceIssues;
		}
		
	}

}