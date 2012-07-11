package ru.codestage.xfltool.map.items 
{
	import avmplus.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	import ru.codestage.xfltool.map.items.elements.Element;
	import ru.codestage.xfltool.map.items.elements.LibraryElement;
	import ru.codestage.xfltool.map.items.elements.ShapeElement;
	import ru.codestage.xfltool.map.items.elements.SymbolElement;
	import ru.codestage.xfltool.map.items.elements.TextElement;
	import ru.codestage.xfltool.map.items.elements.TLFTextElement;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	/**
	 * ...
	 * @author focus | http://blog.codestage.ru
	 */
	public final class FrameItem extends Object 
	{
		public var index:uint = 0;
		public var duration:uint = 1;
		public var name:String; //label
		public var bookmark:Boolean;
		public var labelType:String;
		public var tweenType:String;
		public var tweenedFrom:FrameItem;
		public var tweenedTo:FrameItem;
		public var actionScript:String;
		public var elements:Vector.<Element>;
		public var nextFrame:FrameItem;
		public var previousFrame:FrameItem;
		
		public var layer:LayerItem;
		public var symbol:SymbolElement;
		public var collectionIndex:uint;
		
		public function FrameItem() 
		{
			super();
			
		}
		
		public function getLocation():String 
		{
			return LocaleManager.getString(LocaleManager.LOCATION_AT_FRAME, symbol.name, layer.name, index+1);
		}
		
		public function getChildElement(lookFor:Element):Element 
		{
			var result:Element = null;
			if (elements)
			{
				var len:uint = elements.length;
				var i:uint;
				var element:Element;
				
				for (i = 0; i < len; i++ )
				{
					element = elements[i];
					
					if (element is Object(lookFor).constructor)
					{
						if (element is LibraryElement)
						{
							if ((element as LibraryElement).name == (lookFor as LibraryElement).name)
							{
								result = element;
								break;
							}
						}
						else if (element is ShapeElement)
						{
							/*var match:Boolean = true;
							
							if ((element as ShapeElement).edges != null && (lookFor as ShapeElement).edges != null )
							{
								var edgesCount:uint = (element as ShapeElement).edges.length;
								var edgeIndex:uint;
								
								for (edgeIndex = 0; edgeIndex < edgesCount; edgeIndex++ )
								{
									if ((lookFor as ShapeElement).edges.length > edgeIndex)
									{
										if ((lookFor as ShapeElement).edges[edgeIndex] != (element as ShapeElement).edges[edgeIndex])
										{
											match = false;
											break;
										}
									}
									else
									{
										match = false;
									}
								}
							}
							else if ((element as ShapeElement).edges != null || (lookFor as ShapeElement).edges != null )
							{
								match = false;
							}
							
							if (match)
							{
								result = element;
								break;
							}*/
							result = element;
							break;
						}
						else if (element is TLFTextElement && lookFor is TLFTextElement)
						{
							if ((element as TLFTextElement).name == (lookFor as TLFTextElement).name &&
								(element as TLFTextElement).markup == (lookFor as TLFTextElement).markup)
							{
								result = element;
								break;
							}
						}
						else if (element is TextElement && lookFor is TextElement)
						{
							if ((element as TextElement).name == (lookFor as TextElement).name &&
								(element as TextElement).type == (lookFor as TextElement).type &&
								(element as TextElement).fontName == (lookFor as TextElement).fontName &&
								(element as TextElement).textRuns == (lookFor as TextElement).textRuns)
							{
								result = element;
								break;
							}
						}
					}
				}
			}
			return result;
		}
		
		public function contentDiffersFrom(frame:FrameItem):Boolean 
		{
			var result:Boolean = false;
			
			if (name != frame.name)
			{
				result = true;
			}
			else if (bookmark != frame.bookmark)
			{
				result = true;
			}
			else if (labelType != frame.labelType)
			{
				result = true;
			}
			else if (tweenType != frame.tweenType)
			{
				result = true;
			}
			else if (actionScript != frame.actionScript)
			{
				result = true;
			}
			else if ((elements == null) != (frame.elements == null))
			{
				result = true;
			}
			else if ((elements == null) == (frame.elements == null))
			{
				if (elements)
				{
					if (elements.length != frame.elements.length)
					{
						result = true;
					}
					else
					{
					
						var len:uint = elements.length;
						var i:uint;
						
						for (i = 0; i < len; i++ )
						{
							if (elements[i].xml != frame.elements[i].xml)
							{
								result = true;
								break;
							}
						}
					}
				}
			}
			else
			{
				result = false;
			}
			
			return result;
		}
		
	}

}