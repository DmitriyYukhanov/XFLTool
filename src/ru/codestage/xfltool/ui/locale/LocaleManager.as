package ru.codestage.xfltool.ui.locale 
{
	import com.adobe.utils.LocaleUtil;
	import com.junkbyte.console.Cc;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.system.System;
	import ru.codestage.utils.string.StrUtil;
	import ru.codestage.xfltool.readers.FileReader;
	import ru.codestage.xfltool.settings.Settings;
	import ru.codestage.xfltool.utils.FileUtil;
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class LocaleManager extends Object 
	{
		public static const XML_READ_ERROR:String = "XML_READ_ERROR";
		public static const LOCATION_TO_FRAME:String = "LOCATION_TO_FRAME";
		public static const LOCATION_ELEMENT_WITH_INSTANCE:String = "LOCATION_ELEMENT_WITH_INSTANCE";
		public static const LOCATION_ELEMENT_WITHOUT_INSTANCE:String = "LOCATION_ELEMENT_WITHOUT_INSTANCE";
		public static const LOCATION_NOT_A_SYMBOL:String = "LOCATION_NOT_A_SYMBOL";
		public static const LOCATION_AT_FRAME:String = "LOCATION_AT_FRAME";
		public static const LOCATION_AT_LAYER:String = "LOCATION_AT_LAYER";
		public static const FONT_NO_EMBEDDED_CHARS:String = "FONT_NO_EMBEDDED_CHARS";
		public static const NOT_EMBEDDED_TLF_FONT:String = "NOT_EMBEDDED_TLF_FONT";
		public static const NOT_EMBEDDED_FONT:String = "NOT_EMBEDDED_FONT";
		public static const SYSTEM_FONT:String = "SYSTEM_FONT";
		public static const SYSTEM_TLF_FONT:String = "SYSTEM_TLF_FONT";
		public static const LIBRARY_SCAN_STARTED:String = "LIBRARY_SCAN_STARTED";
		public static const LIBRARY_SCAN_FINISHED:String = "LIBRARY_SCAN_FINISHED";
		public static const FILE_NOT_FOUND:String = "FILE_NOT_FOUND";
		public static const FLASH_PRO_NOT_FOUND:String = "FLASH_PRO_NOT_FOUND";
		public static const NATIVE_NOT_SUPPORTED:String = "NATIVE_NOT_SUPPORTED";
		public static const FONT_EMBED_ISSUES_FOUND:String = "FONT_EMBED_ISSUES_FOUND";
		public static const FONT_EMBED_SCAN_SKIPPED:String = "FONT_EMBED_SCAN_SKIPPED";
		public static const COMMON_ISSUES_FOUND:String = "COMMON_ISSUES_FOUND";
		public static const COMMON_SCAN_SKIPPED:String = "COMMON_SCAN_SKIPPED";
		public static const PERFORMANCE_ISSUES_FOUND:String = "PERFORMANCE_ISSUES_FOUND";
		public static const PERFORMANCE_SCAN_SKIPPED:String = "PERFORMANCE_SCAN_SKIPPED";
		public static const ELEGANCY_ISSUES_FOUND:String = "ELEGANCY_ISSUES_FOUND";
		public static const ELEGANCY_SCAN_SKIPPED:String = "ELEGANCY_SCAN_SKIPPED";
		public static const BLEND_MODE_FOUND:String = "BLEND_MODE_FOUND";
		public static const VISIBLE_OFF_FOUND:String = "VISIBLE_OFF_FOUND";
		public static const CACHED_WITH_TRANSFORM_FOUND:String = "CACHED_WITH_TRANSFORM_FOUND";
		public static const CACHED_WITH_COLOR_EFFECT_FOUND:String = "CACHED_WITH_COLOR_EFFECT_FOUND";
		public static const FILTER_CHANGING_FOUND:String = "FILTER_CHANGING_FOUND";
		public static const CACHE_OR_EXPORT_FOR_BITMAP_FOUND:String = "CACHE_OR_EXPORT_FOR_BITMAP_FOUND";
		public static const CACHED_ANIMATION_FOUND:String = "CACHED_ANIMATION_FOUND";
		public static const EXPORTED_ANIMATION_FOUND:String = "EXPORTED_ANIMATION_FOUND";
		public static const PUBLISH_SETTINGS_SCAN_STARTED:String = "PUBLISH_SETTINGS_SCAN_STARTED";
		public static const WARNINGS_IN_PUBLISH:String = "WARNINGS_IN_PUBLISH";
		public static const COMPRESS_IN_PUBLISH:String = "COMPRESS_IN_PUBLISH";
		public static const XMP_IN_PUBLISH:String = "XMP_IN_PUBLISH";
		public static const PUBLISH_FOUND:String = "PUBLISH_FOUND";
		public static const PUBLISH_FINISHED:String = "PUBLISH_FINISHED";
		public static const PUBLISH_SKIPPED:String = "PUBLISH_SKIPPED";
		public static const COMPRESS_READING:String = "COMPRESS_READING";
		public static const COMPRESS_PREPARING:String = "COMPRESS_PREPARING";
		public static const COMPRESS_CALL_IDE:String = "COMPRESS_CALL_IDE";
		public static const COMPRESS_NEED_SPACE:String = "COMPRESS_NEED_SPACE";
		public static const COMPRESS_SKIP:String = "COMPRESS_SKIP";
		public static const COMPRESS_TERMINATED:String = "COMPRESS_TERMINATED";
		public static const COMPRESS_WAITING:String = "COMPRESS_WAITING";
		public static const COMPRESS_EXPORTED_START:String = "COMPRESS_EXPORTED_START";
		public static const COMPRESS_ERROR:String = "COMPRESS_ERROR";
		public static const COMPRESS_PICK_LOSSLLESS:String = "COMPRESS_PICK_LOSSLLESS";
		public static const COMPRESS_PICK_PHOTO:String = "COMPRESS_PICK_PHOTO";
		public static const COMPRESS_IMPORTED_JPEG_DATA:String = "COMPRESS_IMPORTED_JPEG_DATA";
		public static const COMPRESS_SIZE:String = "COMPRESS_SIZE";
		public static const LOG_HINT:String = "LOG_HINT";
		public static const LOG_COPIED:String = "LOG_COPIED";
		public static const LOG_WAIT:String = "LOG_WAIT";
		public static const LOG_TIME:String = "LOG_TIME";
		public static const LOG_TOTAL_ISSUES:String = "LOG_TOTAL_ISSUES";
		public static const LOG_LIBRARY_SCAN_SKIPPED:String = "LOG_LIBRARY_SCAN_SKIPPED";
		public static const LOG_NOTHING_TO_SCAN:String = "LOG_NOTHING_TO_SCAN";
		public static const LOG_UNPACKING_COMPRESSED_XFL:String = "LOG_UNPACKING_COMPRESSED_XFL";
		public static const LOG_DELETING_UNPACKED_XFL:String = "LOG_DELETING_UNPACKED_XFL";
		public static const LOG_NO_BITMAPS:String = "LOG_NO_BITMAPS";
		public static const LOG_MASKED_BITMAP:String = "LOG_MASKED_BITMAP";
		public static const LOG_TWEENED_KEYFRAME:String = "LOG_TWEENED_KEYFRAME";
		public static const LOG_IMAGES_ANALYSED:String = "LOG_IMAGES_ANALYSED";
		public static const LOG_LAYER_LENGTH:String = "LOG_LAYER_LENGTH";
		public static const LOG_SHAPE_WITH_STROKE:String = "LOG_SHAPE_WITH_STROKE";
		public static const LOG_TOTAL_SYMBOLS:String = "LOG_SHAPE_WITH_STROKE";
		public static const LOG_PROGECT_MAP_CREATED:String = "LOG_PROGECT_MAP_CREATED";
		public static const LOG_RECTANGLE_MASK:String = "LOG_RECTANGLE_MASK";
		public static const LOG_EMPTY_LAYER:String = "LOG_EMPTY_LAYER";
		public static const LOG_UNUSED_MASK:String = "LOG_UNUSED_MASK";
		public static const LOG_UNUSED_AS:String = "LOG_UNUSED_AS";
		public static const LOG_DUP_INSTANCE_NAME:String = "LOG_DUP_INSTANCE_NAME";
		public static const LOG_UNUSED_KEYFRAME:String = "LOG_UNUSED_KEYFRAME";
		public static const LOG_NOT_ONE_SCENE:String = "LOG_NOT_ONE_SCENE";
		public static const LOG_AS_OR_LABEL:String = "LOG_AS_OR_LABEL";
		public static const LOG_UNUSED_TWEEN:String = "LOG_UNUSED_TWEEN";
		public static const LOG_RESERVED_NAME_IN_INSTANCE:String = "LOG_RESERVED_NAME_IN_INSTANCE";
		public static const LOG_DYNAMIC_TEXT_UNUSED:String = "LOG_DYNAMIC_TEXT_UNUSED";
		public static const LOG_TEXT_FIELD_EMPTY:String = "LOG_TEXT_FIELD_EMPTY";
		public static const LOG_GRAPHIC_FOUND:String = "LOG_GRAPHIC_FOUND";
		public static const LOG_BLUR_NOT_POWER_OF2:String = "LOG_BLUR_NOT_POWER_OF2";
		public static const LOG_NESTED_CACHED_WITH_TRANSFORM_FOUND:String = "LOG_NESTED_CACHED_WITH_TRANSFORM_FOUND";
		public static const LOG_NESTED_CACHED_WITH_COLOR_EFFECT_FOUND:String = "LOG_NESTED_CACHED_WITH_COLOR_EFFECT_FOUND";
		
		public static const HINT_BLEND_MODE:String = "HINT_BLEND_MODE";
		public static const HINT_CACHED_WITH_TRANSFORM:String = "HINT_CACHED_WITH_TRANSFORM";
		public static const HINT_CACHED_WITH_COLOR_EFFECT:String = "HINT_CACHED_WITH_COLOR_EFFECT";
		public static const HINT_FILTER_CHANGING:String = "HINT_FILTER_CHANGING";
		public static const HINT_CACHED_ANIMATION:String = "HINT_CACHED_ANIMATION";
		public static const HINT_EXPORTED_ANIMATION:String = "HINT_EXPORTED_ANIMATION";
		public static const HINT_BITMAP_FILLED_SHAPES:String = "HINT_BITMAP_FILLED_SHAPES";
		public static const HINT_WARNINGS_MODE:String = "HINT_WARNINGS_MODE";
		public static const HINT_COMPRESSION_PUBLISH:String = "HINT_COMPRESSION_PUBLISH";
		public static const HINT_XMP_PUBLISH:String = "HINT_XMP_PUBLISH";
		public static const HINT_SYSTEM_FONT:String = "HINT_SYSTEM_FONT";
		public static const HINT_MASKED_BITMAP:String = "HINT_MASKED_BITMAP";
		public static const HINT_SHAPE_WITH_STROKE:String = "HINT_SHAPE_WITH_STROKE";
		public static const HINT_RECTANGLE_MASK:String = "HINT_RECTANGLE_MASK";
		public static const HINT_NOT_ONE_SCENE:String = "HINT_NOT_ONE_SCENE";
		public static const HINT_AS_OR_LABEL:String = "HINT_AS_OR_LABEL";
		public static const HINT_DYNAMIC_TEXT_UNUSED:String = "HINT_DYNAMIC_TEXT_UNUSED";
		public static const HINT_GRAPHIC_FOUND:String = "HINT_GRAPHIC_FOUND";
		public static const HINT_LOG_BLUR_NOT_POWER_OF2:String = "HINT_LOG_BLUR_NOT_POWER_OF2";
		
		public static const GUI_XFL_PATH:String = "GUI_XFL_PATH";
		public static const GUI_FLASH_PRO_PATH:String = "GUI_FLASH_PRO_PATH";
		public static const GUI_BROWSE:String = "GUI_BROWSE";
		public static const GUI_SCAN_OPTIONS:String = "GUI_SCAN_OPTIONS";
		public static const GUI_PUBLISH_SETTINGS:String = "GUI_PUBLISH_SETTINGS";
		public static const GUI_FONTS_EMBED:String = "GUI_FONTS_EMBED";
		public static const GUI_COMMON:String = "GUI_COMMON";
		public static const GUI_PERFORMANCE:String = "GUI_PERFORMANCE";
		public static const GUI_ELEGANCY:String = "GUI_ELEGANCY";
		public static const GUI_START_SCAN:String = "GUI_START_SCAN";
		public static const GUI_LOG_TO_CLIP:String = "GUI_LOG_TO_CLIP";
		public static const GUI_COMP_TYPE:String = "GUI_COMP_TYPE";
		public static const GUI_QUAITY:String = "GUI_QUAITY";
		public static const GUI_CUSTOM:String = "GUI_CUSTOM";
		public static const GUI_CURRENT_QUALITY:String = "GUI_CURRENT_QUALITY";
		public static const GUI_YES:String = "GUI_YES";
		public static const GUI_NO:String = "GUI_NO";
		public static const GUI_SKIP_WITH_CUSTOM_QUAL:String = "GUI_SKIP_WITH_CUSTOM_QUAL";
		public static const GUI_START:String = "GUI_START";
		public static const GUI_STOP:String = "GUI_STOP";
		public static const GUI_THIRD_PARTY:String = "GUI_THIRD_PARTY";
		public static const GUI_DISCLAIMER:String = "GUI_DISCLAIMER";
		public static const GUI_COLORS_LEGEND:String = "GUI_COLORS_LEGEND";
		public static const GUI_COLORS_TITLE:String = "GUI_COLORS_TITLE";
		public static const GUI_COLORS_COMMENT:String = "GUI_COLORS_COMMENT";
		public static const GUI_COLORS_HINT:String = "GUI_COLORS_HINT";
		public static const GUI_COLORS_FONTS:String = "GUI_COLORS_FONTS";
		public static const GUI_COLORS_COMMON:String = "GUI_COLORS_COMMON";
		public static const GUI_COLORS_ELEGANCY:String = "GUI_COLORS_ELEGANCY";
		public static const GUI_COLORS_PERFORMANCE:String = "GUI_COLORS_PERFORMANCE";
		public static const GUI_WARNING:String = "GUI_WARNING";
		public static const GUI_PAGE_ISSUES:String = "GUI_PAGE_ISSUES";
		public static const GUI_PAGE_BITMAPS:String = "GUI_PAGE_BITMAPS";
		public static const GUI_PAGE_OPTIONS:String = "GUI_PAGE_OPTIONS";
		public static const GUI_PAGE_HISTORY:String = "GUI_PAGE_HISTORY";
		public static const GUI_PAGE_ABOUT:String = "GUI_PAGE_ABOUT";
		public static const GUI_WELCOME_TEXT:String = "GUI_WELCOME_TEXT";
		public static const GUI_WELCOME_TITLE:String = "GUI_WELCOME_TITLE";
		public static const GUI_BROWSE_XFL_TITLE:String = "GUI_BROWSE_XFL_TITLE";
		public static const GUI_BROWSE_FLASH_PRO_TITLE:String = "GUI_BROWSE_FLASH_PRO_TITLE";
		public static const GUI_COMPRESSION_WARNING:String = "GUI_COMPRESSION_WARNING";
		public static const GUI_WRONG_FLA_FORMAT_WARNING:String = "GUI_WRONG_FLA_FORMAT_WARNING";
		public static const GUI_SUPPORTED_PROJECT_TYPES:String = "GUI_SUPPORTED_PROJECT_TYPES";
		public static const GUI_XFL_PROJECT:String = "GUI_XFL_PROJECT";
		public static const GUI_FLA_PROJECT:String = "GUI_FLA_PROJECT";
		public static const GUI_EXECUTABLE:String = "GUI_EXECUTABLE";
		public static const GUI_APPLICATION:String = "GUI_APPLICATION";
		public static const GUI_COMPRESSED_XFL_WARNING:String = "GUI_COMPRESSED_XFL_WARNING";
		public static const GUI_NEW_VERSION:String = "GUI_NEW_VERSION";
		public static const GUI_ASK_FOR_UPDATE:String = "GUI_ASK_FOR_UPDATE";
		public static const GUI_PROGRESS_LABEL:String = "GUI_PROGRESS_LABEL";
		public static const GUI_THE_MINER_OFF:String = "GUI_THE_MINER_OFF";
		
		private static var _instance:LocaleManager;
		public var currentLanguage:String;
		private static var _currentLocaleXML:XML;
		
		public function LocaleManager() 
		{
			super();
			
		}
		
		public static function get instance():LocaleManager
		{
			if (!_instance) _instance = new LocaleManager();
			return _instance;
		}
		
		public function init():void
		{
			var availableLocales:Array = [];
			var localeFiles:Vector.<File> = FileUtil.searchForFilesByExt("xml", File.applicationDirectory.resolvePath("lng"));
			var len:uint = localeFiles.length;
			var i:uint = 0;
			var localeXML:XML;
			
			for (i; i < len; i++ )
			{
				localeXML = new FileReader().readFileToXML(localeFiles[i]);
				if (localeXML.@locale != undefined)
				{
					availableLocales.push(String(localeXML.@locale));
				}
				System.disposeXML(localeXML);
			}
			
			
			var sortedLocales:Array = LocaleUtil.sortLanguagesByPreference(availableLocales, Capabilities.languages, "en_US");
			currentLanguage = sortedLocales[0];
			Settings.instance.data.currentLanguage = currentLanguage;
			/*currentLanguage = "en_US";
			Settings.instance.data.currentLanguage = "en_US";*/
			_loadLocFile();
		}
		
		private function _loadLocFile():void 
		{
			var locFile:File = File.applicationDirectory.resolvePath("lng/" + currentLanguage + ".xml");
			if (!locFile.exists)
			{
				currentLanguage = "en_US";
				locFile = File.applicationDirectory.resolvePath("lng/" + currentLanguage + ".xml");
				if (!locFile.exists)
				{
					Cc.fatal("Default localization file is absent!");
					return;
				}
			}
			
			var localeReader:FileReader = new FileReader();
			_currentLocaleXML = localeReader.readFileToXML(locFile);
			localeReader = null;
		}
		
		public static function getString(strID:String, ...rest):String 
		{
			var result:String = _currentLocaleXML[strID][0];
			if (!String(result))
			{
				result = "No translation(";
			}
			else
			{
				if (rest.length)
				{
					var len:uint = rest.length;
					var i:uint = 0;
					
					for (i; i < len; i++ )
					{
						result = result.replace("%" + String(i + 1), rest[i]);
					}
				}
				result = result.split("\\n").join("\n");
			}
			
			return result;
		}
		
	}

}