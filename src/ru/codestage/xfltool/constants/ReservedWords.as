package ru.codestage.xfltool.constants 
{
	import flash.display.MovieClip;
	import flash.system.System;
	import flash.utils.describeType;
	/**
	 * ...
	 * @author ...
	 */
	public final class ReservedWords extends Object 
	{
		// http://help.adobe.com/en_US/ActionScript/3.0_ProgrammingAS3_Flex/WS5b3ccc516d4fbf351e63e3d118a9b90204-7f9b.html#WS5b3ccc516d4fbf351e63e3d118a9b90204-7f6e
		public static const words:Vector.<String> = new <String>["as", "break", "case", "catch", "class", "const", "continue", "default",
																 "delete", "do", "else", "extends", "false", "finally", "for", "function",
																 "if", "implements", "import", "in", "instanceof", "interface", "internal", "is",
																 "native", "new", "null", "package", "private", "protected", "public", "return",
																 "super", "switch", "this", "throw", "to", "true", "try", "typeof",
																 "use", "var", "void", "while", "with", "each", "get", "set",
																 "namespace", "include", "dynamic", "final", "native", "override", "static", "abstract",
																 "boolean", "byte", "cast", "char", "debugger", "double", "enum", "export",
																 "float", "goto", "intrinsic", "long", "prototype", "short", "synchronized", "throws",
																 "to", "transient", "type", "virtual", "volatile"];
		
		public static const movieClipProperties:Vector.<String> = _getMovieClipProperties();
		
		private static function _getMovieClipProperties():Vector.<String>
		{
			var result:Vector.<String>
			
			var mc:XML = describeType(MovieClip);
			var accessors:XMLList = mc.factory.accessor.@name;
			
			var len:uint = accessors.length();
			var i:uint;
			
			result = new Vector.<String>(len, true);
			
			for (i = 0; i < len; i++ )
			{
				result[i] = accessors[i];
			}
			
			System.disposeXML(mc);
			
			return result;
		}
	}

}