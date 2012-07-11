package ru.codestage.xfltool.map.items.elements 
{
	import ru.codestage.utils.NumUtil;
	import ru.codestage.xfltool.constants.Issues;
	import ru.codestage.xfltool.constants.ReservedWords;
	import ru.codestage.xfltool.map.items.elements.attributes.ElementBlurFilter;
	import ru.codestage.xfltool.map.items.elements.attributes.ElementMatrix;
	import ru.codestage.xfltool.map.items.elements.attributes.FilterBase;
	import ru.codestage.xfltool.map.items.FrameItem;
	import ru.codestage.xfltool.map.items.LayerItem;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	/**
	 * ...
	 * @author focus | http://blog.codestage.ru
	 */
	public class Element extends Object 
	{
		
		public var parentSymbol:SymbolElement;
		public var parentFrame:FrameItem;
		public var parentLayer:LayerItem;
		
		public var matrixes:Vector.<ElementMatrix>;
		
		public var lastLocationToFrame:FrameItem;
		public var includedIntoIssuesTypes:Vector.<String>;
		public var xml:String;
		
		public function Element() 
		{
			super();
		}
		
		public function getLocation(elementName:String = "Symbol"):String 
		{
			var location:String;
			location = LocaleManager.getString(LocaleManager.LOCATION_NOT_A_SYMBOL, 
												 elementName, parentSymbol.name, 
												 parentLayer.name, parentFrame.index + 1);
			if (lastLocationToFrame)
			{
				location += LocaleManager.getString(LocaleManager.LOCATION_TO_FRAME, lastLocationToFrame.index + 1);
				lastLocationToFrame = null;
			}
			return location;
		}
		
		public function checkForIssue(issueType:String, checkLength:Boolean = true, element:Element = null, customParams:Object = null):Boolean 
		{
			var filters:Vector.<FilterBase>;
			var i:uint;
			var len:uint;
			var haveIssue:Boolean = false;
			
			if (element == null) element = this;
			
			if (element.includedIntoIssuesTypes && element.includedIntoIssuesTypes.indexOf(issueType) != -1)
			{
				return false;
			}
			
			if (element is SymbolElement)
			{
				var symbolElement:SymbolElement = (element as SymbolElement);
				
				if (issueType == Issues.BLENDING)
				{
					if (symbolElement.blendMode != null)
					{
						haveIssue = true;
					}
				}
				else if (issueType == Issues.UNUSED)
				{
					if ((!symbolElement.isVisible || symbolElement.alpha == 0) && symbolElement.instanceName == null && !symbolElement.linkaged && !symbolElement.parentFrame.tweenType)
					{
						haveIssue = true;
					}
				}
				else if (issueType == Issues.CACHED_ANIMATION)
				{
					if ((symbolElement.cacheAsBitmap || symbolElement.filters) && symbolElement.ownTimeline.hasAnimation)
					{
						haveIssue = true;
					}
				}
				else if (issueType == Issues.EXPORTED_AS_BITMAP_ANIMATION)
				{
					if (symbolElement.exportAsBitmap && symbolElement.ownTimeline.hasAnimation)
					{
						haveIssue = true;
					}
				}
				else if (issueType == Issues.CACHE_OR_EXPORT_FOR_BITMAPS)
				{
					if ((symbolElement.cacheAsBitmap || symbolElement.exportAsBitmap) && symbolElement.ownTimeline.hasOnlyBitmaps)
					{
						haveIssue = true;
					}
				}				
				else if (issueType == Issues.RESERVED_NAME_IN_INSTANCE)
				{
					if (symbolElement.instanceName)
					{
						if ((ReservedWords.words.indexOf(symbolElement.instanceName) != -1) || (ReservedWords.movieClipProperties.indexOf(symbolElement.instanceName) != -1))
						{
							haveIssue = true;
						}
					}
				}
				else if (issueType == Issues.BLUR_NOT_POWER_OF2)
				{
					if (symbolElement.filters)
					{
						filters = symbolElement.filters;
						len = filters.length;
						
						for (i = 0; i < len; i++ )
						{
							if (filters[i] is ElementBlurFilter)
							{
								if (NumUtil.powerOf((filters[i] as ElementBlurFilter).blurX * (filters[i] as ElementBlurFilter).blurY, 2) <= 0)
								{
									haveIssue = true;
									break;
								}
							}
						}
					}
				}
				
				symbolElement = null;
			}
			else if (element is BitmapElement)
			{
				var bitmapElement:BitmapElement = (element as BitmapElement);
				
				if (issueType == Issues.BITMAP_UNDER_MASK)
				{
					if (bitmapElement.parentLayer.parentLayerIndex == bitmapElement.parentLayer.parentLayerIndex) // checking for NaN
					{
						var parentLayer:LayerItem = bitmapElement.parentSymbol.ownLayers[bitmapElement.parentLayer.parentLayerIndex];
						if (parentLayer.layerType == "mask")
						{
							haveIssue = true;
						}
					}
				}
				
				bitmapElement = null;
			}
			else if (element is ShapeElement)
			{
				var shapeElement:ShapeElement = (element as ShapeElement);
				
				if (issueType == Issues.STROKES)
				{
					if (shapeElement.haveStrokes)
					{
						haveIssue = true;
					}
				}
				shapeElement = null;
			}
			else if (element is TLFTextElement)
			{
				var tlfTextElement:TLFTextElement = (element as TLFTextElement);
				
				if (issueType == Issues.SYSTEM_FONT)
				{
					if (tlfTextElement.hasSystemFont)
					{
						haveIssue = true;
					}
				}
				else if (issueType == Issues.NOT_EMBEDDED_FONT)
				{
					if (!tlfTextElement.allFontsAreEmbedded)
					{
						haveIssue = true;
					}
				}
				else if (issueType == Issues.RESERVED_NAME_IN_INSTANCE)
				{
					if (tlfTextElement.name)
					{
						if ((ReservedWords.words.indexOf(tlfTextElement.name) != -1) || (ReservedWords.movieClipProperties.indexOf(tlfTextElement.name) != -1))
						{
							haveIssue = true;
						}
					}
				}
				else if (issueType == Issues.TEXT_FIELD_EMPTY)
				{
					if ((!tlfTextElement.tlfText || tlfTextElement.tlfText == "") && !tlfTextElement.name)
					{
						haveIssue = true;
					}
				}
				else if (issueType == Issues.BLUR_NOT_POWER_OF2)
				{
					if (tlfTextElement.filters)
					{
						filters = tlfTextElement.filters;
						len = filters.length;
						
						for (i = 0; i < len; i++ )
						{
							if (filters[i] is ElementBlurFilter)
							{
								if (NumUtil.powerOf((filters[i] as ElementBlurFilter).blurX * (filters[i] as ElementBlurFilter).blurY, 2) == -1)
								{
									haveIssue = true;
									break;
								}
							}
						}
					}
				}
				
				tlfTextElement = null;
			}
			else if (element is TextElement)
			{
				var textElement:TextElement = (element as TextElement);
				
				if (issueType == Issues.SYSTEM_FONT)
				{
					if (textElement.fontName == "_sans" || textElement.fontName == "_serif" || textElement.fontName == "_typewriter")
					{
						haveIssue = true;
					}
				}
				else if (issueType == Issues.NOT_EMBEDDED_FONT)
				{
					if (!textElement.fontEmbedded)
					{
						haveIssue = true;
					}
				}
				else if (issueType == Issues.RESERVED_NAME_IN_INSTANCE)
				{
					if (textElement.name)
					{
						if ((ReservedWords.words.indexOf(textElement.name) != -1) || (ReservedWords.movieClipProperties.indexOf(textElement.name) != -1))
						{
							haveIssue = true;
						}
					}
				}
				else if (issueType == Issues.DYNAMIC_TEXT_UNUSED)
				{
					if (textElement.type != "static" && !textElement.name)
					{
						haveIssue = true;
					}
				}
				else if (issueType == Issues.TEXT_FIELD_EMPTY)
				{
					if ((!textElement.text || textElement.text == "") && !textElement.name)
					{
						haveIssue = true;
					}
				}
				else if (issueType == Issues.BLUR_NOT_POWER_OF2)
				{
					if (textElement.filters)
					{
						filters = textElement.filters;
						len = filters.length;
						
						for (i = 0; i < len; i++ )
						{
							if (filters[i] is ElementBlurFilter)
							{
								if (NumUtil.powerOf((filters[i] as ElementBlurFilter).blurX * (filters[i] as ElementBlurFilter).blurY, 2) == -1)
								{
									haveIssue = true;
									break;
								}
							}
						}
					}
				}
				
				textElement = null;
			}
			
			if (checkLength && haveIssue)
			{
				lastLocationToFrame = _getIssueLength(element, issueType);
				if (lastLocationToFrame == element.parentFrame)
				{
					lastLocationToFrame = null;
				}
			}
			
			return haveIssue;
		}
		
		private function _getIssueLength(element:Element, issueType:String):FrameItem 
		{
			var toFrame:FrameItem = element.parentFrame;
			if (element.parentFrame.nextFrame)
			{
				var meOnNextFrame:Element = element.parentFrame.nextFrame.getChildElement(this);
				
				if (meOnNextFrame)
				{
					if (checkForIssue(issueType, false, meOnNextFrame))
					{
						toFrame = _getIssueLength(meOnNextFrame, issueType);
						if (!meOnNextFrame.includedIntoIssuesTypes) meOnNextFrame.includedIntoIssuesTypes = new Vector.<String>();
						meOnNextFrame.includedIntoIssuesTypes[meOnNextFrame.includedIntoIssuesTypes.length] = issueType;
					}
				}
			}
			
			return toFrame;
		}
	}

}