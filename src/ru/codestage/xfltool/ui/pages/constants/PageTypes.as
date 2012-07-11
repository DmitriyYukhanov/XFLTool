package ru.codestage.xfltool.ui.pages.constants
{
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	import ru.codestage.xfltool.ui.pages.PageIssuesScan;
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class PageTypes extends Object
	{
		public static const PAGES_COUNT:uint = 5;
		public static var PAGES_NAMES:Vector.<String>;
		
		public static const PAGE_ISSUES_SCAN:uint = 0;
		public static const PAGE_BITMAPS_COMPRESSION:uint = 1;
		public static const PAGE_OPTIONS:uint = 2;
		public static const PAGE_HISTORY:uint = 3;
		public static const PAGE_ABOUT:uint = 4;
		public static const PAGE_MAIN:uint = 1000;
		
		// call it after LocaleManager inited
		public static function init():void
		{
			PAGES_NAMES = new Vector.<String>(PAGES_COUNT, true);
			PAGES_NAMES[0] = "1: " + LocaleManager.getString(LocaleManager.GUI_PAGE_ISSUES);
			PAGES_NAMES[1] = "2: " + LocaleManager.getString(LocaleManager.GUI_PAGE_BITMAPS);
			PAGES_NAMES[2] = "3: " + LocaleManager.getString(LocaleManager.GUI_PAGE_OPTIONS);
			PAGES_NAMES[3] = "4: " + LocaleManager.getString(LocaleManager.GUI_PAGE_HISTORY);
			PAGES_NAMES[4] = "5: " + LocaleManager.getString(LocaleManager.GUI_PAGE_ABOUT);
		}
	}

}