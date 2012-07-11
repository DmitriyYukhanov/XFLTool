package ru.codestage.xfltool.scanners.issues
{
	import com.junkbyte.console.Cc;
	import ru.codestage.xfltool.constants.Issues;
	import ru.codestage.xfltool.map.items.elements.attributes.ColorEffect;
	import ru.codestage.xfltool.map.items.elements.attributes.ElementMatrix;
	import ru.codestage.xfltool.map.items.elements.attributes.FilterBase;
	import ru.codestage.xfltool.map.items.elements.BitmapElement;
	import ru.codestage.xfltool.map.items.elements.Element;
	import ru.codestage.xfltool.map.items.elements.ShapeElement;
	import ru.codestage.xfltool.map.items.elements.SymbolElement;
	import ru.codestage.xfltool.map.items.elements.TextElement;
	import ru.codestage.xfltool.map.items.elements.TLFTextElement;
	import ru.codestage.xfltool.map.items.FontItem;
	import ru.codestage.xfltool.map.items.FrameItem;
	import ru.codestage.xfltool.map.items.LayerItem;
	import ru.codestage.xfltool.scanners.base.ScannerBase;
	import ru.codestage.xfltool.scanners.base.ScanResults;

	import ru.codestage.xfltool.scanners.base.TweenedIssues;
	import ru.codestage.xfltool.ui.controls.log.LogStyle;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class LibraryIssuesScanner extends ScannerBase
	{
		private var _scanFonts:Boolean;
		private var _scanCommon:Boolean;
		private var _scanElegancy:Boolean;
		private var _scanPerformance:Boolean;
		
		private var _projectFonts:Vector.<FontItem>;
		private var _librarySymbols:Vector.<SymbolElement>;
		
		public function LibraryIssuesScanner(scanFonts:Boolean, scanCommon:Boolean, scanPerformance:Boolean, scanElegancy:Boolean, log:Function)
		{
			super(log);
			this._scanCommon = scanCommon;
			this._scanFonts = scanFonts;
			this._scanPerformance = scanPerformance;
			this._scanElegancy = scanElegancy;
		}

		
		public function uninit():void 
		{
		
		}
		
		public function scanSymbolsForIssues(projectFonts:Vector.<FontItem>, librarySymbols:Vector.<SymbolElement>):ScanResults 
		{
			var i:uint;
			var len:uint;
			var scanResults:ScanResults = new ScanResults();
			
			this._projectFonts = projectFonts;
			this._librarySymbols = librarySymbols;
			
			scanResults.totalFontIssues += _scanFontItems();
			
			var librarySymbolsCount:uint = _librarySymbols.length;
			var currentLibrarySymbolIndex:uint;
			var librarySymbol:SymbolElement;
			
			for (currentLibrarySymbolIndex = 0; currentLibrarySymbolIndex < librarySymbolsCount; currentLibrarySymbolIndex++ )
			{
				librarySymbol = _librarySymbols[currentLibrarySymbolIndex];
				
				if (_scanElegancy)
				{
					if (librarySymbol.type == "graphic")
					{
						scanResults.totalElegancyIssues++;
						_log(LocaleManager.getString(LocaleManager.LOG_GRAPHIC_FOUND, librarySymbol.name), LogStyle.TYPE_ELEGANCY, LocaleManager.getString(LocaleManager.HINT_GRAPHIC_FOUND));
					}
				}
				
				// FRAMES
				var framesCount:uint = librarySymbol.ownFrames.length;
				var currentFrameIndex:uint;
				var frame:FrameItem;
				
				for (currentFrameIndex = 0; currentFrameIndex < framesCount; currentFrameIndex++ )
				{
					frame = librarySymbol.ownFrames[currentFrameIndex];
					
					if (_scanElegancy)
					{
						// single tweened frame issue
						if ((frame.tweenType != null) && (frame.duration == 1))
						{
							scanResults.totalElegancyIssues++;
							_log(LocaleManager.getString(LocaleManager.LOG_TWEENED_KEYFRAME, frame.getLocation()), LogStyle.TYPE_ELEGANCY);
						}
						
						if (frame.actionScript || frame.labelType != null)
						{
							if (frame.layer.elements)
							{
								scanResults.totalElegancyIssues++;
								_log(LocaleManager.getString(LocaleManager.LOG_AS_OR_LABEL, frame.getLocation()), LogStyle.TYPE_ELEGANCY, LocaleManager.getString(LocaleManager.HINT_AS_OR_LABEL));
							}
						}
					}
					
					if (_scanCommon)
					{
						if (frame.previousFrame)
						{
							if (!frame.contentDiffersFrom(frame.previousFrame))
							{
								if (frame.nextFrame)
								{
									if (!frame.contentDiffersFrom(frame.nextFrame))
									{
										scanResults.totalCommonIssues++;
										_log(LocaleManager.getString(LocaleManager.LOG_UNUSED_KEYFRAME, frame.getLocation()), LogStyle.TYPE_COMMON);
									}
								}
								else
								{
									scanResults.totalCommonIssues++;
									_log(LocaleManager.getString(LocaleManager.LOG_UNUSED_KEYFRAME, frame.getLocation()), LogStyle.TYPE_COMMON);
								}
								
								if (frame.tweenType && frame.previousFrame.tweenType)
								{
									scanResults.totalCommonIssues++;
									_log(LocaleManager.getString(LocaleManager.LOG_UNUSED_TWEEN, frame.previousFrame.getLocation()), LogStyle.TYPE_COMMON);
								}
							}
						}
					}
				}
				
				frame = null;
				
				// LAYERS
				var layersCount:uint = librarySymbol.ownLayers.length;
				var currentLayerIndex:uint;
				var layer:LayerItem;
				var previousLength:int = 0;
				
				for (currentLayerIndex = 0; currentLayerIndex < layersCount; currentLayerIndex++ )
				{
					layer = librarySymbol.ownLayers[currentLayerIndex];
					
					if (_scanElegancy)
					{
						// layers Length Issue
						if (previousLength > 0 && previousLength != -1)
						{
							if (layer.length != previousLength)
							{
								scanResults.totalElegancyIssues++;
								_log(LocaleManager.getString(LocaleManager.LOG_LAYER_LENGTH, librarySymbol.name), LogStyle.TYPE_ELEGANCY);
								previousLength = -1; // disabling this issue detection for this symbol
							}
						}
						if (previousLength != -1) previousLength = layer.length;
						
						// empty layer Issue
						if (layer.length == 0 || (!layer.elements&&!layer.haveServiceFrame))
						{
							scanResults.totalElegancyIssues++;
							_log(LocaleManager.getString(LocaleManager.LOG_EMPTY_LAYER, layer.getLocation()), LogStyle.TYPE_ELEGANCY);
						}
					}
					
					if (_scanPerformance)
					{
						if (layer.layerType == "mask")
						{
							if (layer.frames && layer.frames.length == 1)
							{
								if (layer.frames[0].elements && layer.frames[0].elements.length == 1)
								{
									var frameElement:Element = layer.frames[0].elements[0];
									
									if (frameElement is ShapeElement)
									{
										if ((frameElement as ShapeElement).isTrueRectangle)
										{
											scanResults.totalPerformanceIssues++;
											_log(LocaleManager.getString(LocaleManager.LOG_RECTANGLE_MASK, frameElement.getLocation("Shape")), LogStyle.TYPE_PERFORMANCE, LocaleManager.getString(LocaleManager.HINT_RECTANGLE_MASK));
											
										}
									}
								}
							}
						}
					}
					
					if (_scanCommon)
					{
						if (layer.layerType == "mask")
						{
							if (!layer.children)
							{
								scanResults.totalCommonIssues++;
								_log(LocaleManager.getString(LocaleManager.LOG_UNUSED_MASK, layer.getLocation()), LogStyle.TYPE_COMMON);
							}
							
							if (layer.frames)
							{
								len = layer.frames.length;
								
								for (i = 0; i < len; i++ )
								{
									if (layer.frames[i].actionScript != null)
									{
										scanResults.totalCommonIssues++;
										_log(LocaleManager.getString(LocaleManager.LOG_UNUSED_AS, layer.frames[i].getLocation()), LogStyle.TYPE_COMMON);
										break;
									}
								}
							}
						}
					}
				}
				
				layer = null;
				
				// CHILDREN SYMBOLS
				if (librarySymbol.ownChildren)
				{
					var childrenCount:uint = librarySymbol.ownChildren.length;
					var childIndex:uint;
					var childElement:Element;
					
					for (childIndex = 0; childIndex < childrenCount; childIndex++ )
					{
						childElement = librarySymbol.ownChildren[childIndex];
						
						if (childElement is SymbolElement)
						{
							
							var symbolElement:SymbolElement = (childElement as SymbolElement);
							
							if (_scanPerformance)
							{
								if (symbolElement.cacheAsBitmap || symbolElement.filters)
								{
									if (symbolElement.parentFrame.tweenType != null)
									{
										var issuesTweenedTo:TweenedIssues = new TweenedIssues();
										_searchForTweenedIssues(symbolElement, issuesTweenedTo, !symbolElement.includedIntoMatrixIssue, !symbolElement.includedIntoColorsIssue, !symbolElement.includedIntoFiltersIssue);
										
										if (issuesTweenedTo.isIssueFound())
										{
											if (issuesTweenedTo.matrixTransformed > 0)
											{
												scanResults.totalPerformanceIssues ++;
												_log(LocaleManager.getString(LocaleManager.CACHED_WITH_TRANSFORM_FOUND, symbolElement.getLocation()) +  LocaleManager.getString(LocaleManager.LOCATION_TO_FRAME, issuesTweenedTo.matrixTransformed + 1), LogStyle.TYPE_PERFORMANCE, LocaleManager.getString(LocaleManager.HINT_CACHED_WITH_TRANSFORM));
											}
											
											if (issuesTweenedTo.colorEffectChanged > 0)
											{
												scanResults.totalPerformanceIssues ++;
												_log(LocaleManager.getString(LocaleManager.CACHED_WITH_COLOR_EFFECT_FOUND, symbolElement.getLocation()) +  LocaleManager.getString(LocaleManager.LOCATION_TO_FRAME, issuesTweenedTo.colorEffectChanged + 1), LogStyle.TYPE_PERFORMANCE, LocaleManager.getString(LocaleManager.HINT_CACHED_WITH_COLOR_EFFECT));
											}
											
											if (issuesTweenedTo.filterChanged > 0)
											{
												scanResults.totalPerformanceIssues ++;
												_log(LocaleManager.getString(LocaleManager.FILTER_CHANGING_FOUND, symbolElement.getLocation()) +  LocaleManager.getString(LocaleManager.LOCATION_TO_FRAME, issuesTweenedTo.filterChanged + 1), LogStyle.TYPE_PERFORMANCE, LocaleManager.getString(LocaleManager.HINT_FILTER_CHANGING));
											}
										}
										
										issuesTweenedTo = null;
									}
								}
								
								if (symbolElement.checkForIssue(Issues.CACHED_ANIMATION))
								{
									scanResults.totalPerformanceIssues++;
									_log(LocaleManager.getString(LocaleManager.CACHED_ANIMATION_FOUND, symbolElement.getLocation()), LogStyle.TYPE_PERFORMANCE, LocaleManager.getString(LocaleManager.HINT_CACHED_ANIMATION));
								}
								
								if (symbolElement.checkForIssue(Issues.BLENDING))
								{
									scanResults.totalPerformanceIssues++;
									_log(LocaleManager.getString(LocaleManager.BLEND_MODE_FOUND, symbolElement.getLocation()), LogStyle.TYPE_PERFORMANCE, LocaleManager.getString(LocaleManager.HINT_BLEND_MODE));
								}
								
								if (symbolElement.checkForIssue(Issues.BLUR_NOT_POWER_OF2))
								{
									scanResults.totalPerformanceIssues++;
									_log(LocaleManager.getString(LocaleManager.LOG_BLUR_NOT_POWER_OF2, symbolElement.getLocation()), LogStyle.TYPE_PERFORMANCE, LocaleManager.getString(LocaleManager.HINT_LOG_BLUR_NOT_POWER_OF2));
								}
							}
							
							if (_scanCommon)
							{
								if (symbolElement.checkForIssue(Issues.EXPORTED_AS_BITMAP_ANIMATION))
								{
									scanResults.totalCommonIssues++;
									_log(LocaleManager.getString(LocaleManager.EXPORTED_ANIMATION_FOUND, symbolElement.getLocation()), LogStyle.TYPE_COMMON, LocaleManager.getString(LocaleManager.HINT_EXPORTED_ANIMATION));
								}
								
								if (symbolElement.checkForIssue(Issues.CACHE_OR_EXPORT_FOR_BITMAPS))
								{
									scanResults.totalCommonIssues++;
									_log(LocaleManager.getString(LocaleManager.CACHE_OR_EXPORT_FOR_BITMAP_FOUND,symbolElement.getLocation()), LogStyle.TYPE_COMMON);
								}
								
								if (symbolElement.checkForIssue(Issues.RESERVED_NAME_IN_INSTANCE))
								{
									scanResults.totalCommonIssues++;
									_log(LocaleManager.getString(LocaleManager.LOG_RESERVED_NAME_IN_INSTANCE,symbolElement.getLocation()), LogStyle.TYPE_COMMON);
								}
								
								// unused issue scan
								if (symbolElement.checkForIssue(Issues.UNUSED))
								{
									scanResults.totalCommonIssues++;
									_log(LocaleManager.getString(LocaleManager.VISIBLE_OFF_FOUND, symbolElement.getLocation()), LogStyle.TYPE_COMMON);
								}
							}
							
							symbolElement = null;
						}
						else if (childElement is BitmapElement)
						{
							var bitmapElement:BitmapElement = (childElement as BitmapElement);
							
							if (_scanCommon)
							{
								if (bitmapElement.checkForIssue(Issues.BITMAP_UNDER_MASK))
								{
									scanResults.totalCommonIssues ++;
									_log(LocaleManager.getString(LocaleManager.LOG_MASKED_BITMAP, bitmapElement.getLocation("Bitmap")), LogStyle.TYPE_COMMON, LocaleManager.getString(LocaleManager.HINT_MASKED_BITMAP));
								}
							}
							
							bitmapElement = null;
						}
						else if (childElement is ShapeElement)
						{
							var shapeElement:ShapeElement = (childElement as ShapeElement);
							
							if (_scanPerformance)
							{
								if (shapeElement.checkForIssue(Issues.STROKES))
								{
									scanResults.totalPerformanceIssues ++;
									_log(LocaleManager.getString(LocaleManager.LOG_SHAPE_WITH_STROKE, shapeElement.getLocation("Shape")), LogStyle.TYPE_PERFORMANCE, LocaleManager.getString(LocaleManager.HINT_SHAPE_WITH_STROKE));
								}
							}
							
							shapeElement = null;
						}
						else if (childElement is TLFTextElement)
						{
							var tlfTextElement:TLFTextElement = (childElement as TLFTextElement);
							
							if (_scanFonts)
							{
								if (tlfTextElement.checkForIssue(Issues.SYSTEM_FONT))
								{
									scanResults.totalFontIssues++;
									_log(LocaleManager.getString(LocaleManager.SYSTEM_TLF_FONT, tlfTextElement.getLocation("TLFTextField")),LogStyle.TYPE_FONTS, LocaleManager.getString(LocaleManager.HINT_SYSTEM_FONT));
								}
								else if (tlfTextElement.checkForIssue(Issues.NOT_EMBEDDED_FONT))
								{
									scanResults.totalFontIssues++;
									_log(LocaleManager.getString(LocaleManager.NOT_EMBEDDED_TLF_FONT, tlfTextElement.getLocation("TLFTextField")),LogStyle.TYPE_FONTS);
								}
							}
							
							if (_scanCommon)
							{
								if (tlfTextElement.checkForIssue(Issues.RESERVED_NAME_IN_INSTANCE))
								{
									scanResults.totalCommonIssues++;
									_log(LocaleManager.getString(LocaleManager.LOG_RESERVED_NAME_IN_INSTANCE,tlfTextElement.getLocation("TLFTextField")), LogStyle.TYPE_COMMON);
								}
								
								if (tlfTextElement.checkForIssue(Issues.TEXT_FIELD_EMPTY))
								{
									scanResults.totalCommonIssues++;
									_log(LocaleManager.getString(LocaleManager.LOG_TEXT_FIELD_EMPTY,tlfTextElement.getLocation("TLFTextField")), LogStyle.TYPE_COMMON);
								}
							}
							
							if (_scanPerformance)
							{
								if (tlfTextElement.checkForIssue(Issues.BLUR_NOT_POWER_OF2))
								{
									scanResults.totalPerformanceIssues++;
									_log(LocaleManager.getString(LocaleManager.LOG_BLUR_NOT_POWER_OF2, tlfTextElement.getLocation("TLFTextField")), LogStyle.TYPE_PERFORMANCE, LocaleManager.getString(LocaleManager.HINT_LOG_BLUR_NOT_POWER_OF2));
								}
							}
							
							tlfTextElement = null;
						}
						else if (childElement is TextElement)
						{
							var textElement:TextElement = (childElement as TextElement);
							
							if (_scanFonts)
							{
								if (textElement.type != "static")
								{
									if (textElement.checkForIssue(Issues.SYSTEM_FONT))
									{
										scanResults.totalFontIssues++;
										_log(LocaleManager.getString(LocaleManager.SYSTEM_FONT, textElement.fontName, textElement.getLocation("TextField")),LogStyle.TYPE_FONTS, LocaleManager.getString(LocaleManager.HINT_SYSTEM_FONT));
									}
									else if (textElement.checkForIssue(Issues.NOT_EMBEDDED_FONT))
									{
										scanResults.totalFontIssues++;
										_log(LocaleManager.getString(LocaleManager.NOT_EMBEDDED_FONT, textElement.fontName, textElement.getLocation("TextField")),LogStyle.TYPE_FONTS);
									}
								}
							}
							
							if (_scanCommon)
							{
								if (textElement.checkForIssue(Issues.RESERVED_NAME_IN_INSTANCE))
								{
									scanResults.totalCommonIssues++;
									_log(LocaleManager.getString(LocaleManager.LOG_RESERVED_NAME_IN_INSTANCE, textElement.getLocation("TextField")), LogStyle.TYPE_COMMON);
								}
								
								if (textElement.checkForIssue(Issues.TEXT_FIELD_EMPTY))
								{
									scanResults.totalCommonIssues++;
									_log(LocaleManager.getString(LocaleManager.LOG_TEXT_FIELD_EMPTY,textElement.getLocation("TextField")), LogStyle.TYPE_COMMON);
								}
								else if (textElement.checkForIssue(Issues.DYNAMIC_TEXT_UNUSED))
								{
									scanResults.totalCommonIssues++;
									_log(LocaleManager.getString(LocaleManager.LOG_DYNAMIC_TEXT_UNUSED,textElement.getLocation("TextField")), LogStyle.TYPE_COMMON, LocaleManager.getString(LocaleManager.HINT_DYNAMIC_TEXT_UNUSED));
								}
								
							}
							
							if (_scanPerformance)
							{
								if (textElement.checkForIssue(Issues.BLUR_NOT_POWER_OF2))
								{
									scanResults.totalPerformanceIssues++;
									_log(LocaleManager.getString(LocaleManager.LOG_BLUR_NOT_POWER_OF2, textElement.getLocation("TextField")), LogStyle.TYPE_PERFORMANCE, LocaleManager.getString(LocaleManager.HINT_LOG_BLUR_NOT_POWER_OF2));
								}
							}
							
							textElement = null;
						}
					}
					childElement = null;
				}
			}
			
			librarySymbol = null;
			
			this._librarySymbols = null;
			this._projectFonts = null;
			
			return scanResults;
		}
		
		private function _scanFontItems():uint
		{
			var issues:uint = 0;
			
			if (_scanFonts)
			{
				var len:uint = _projectFonts.length;
				var i:uint;
				var font:FontItem;
				
				for (i = 0; i < len; i++ )
				{
					font = _projectFonts[i];
					if ( (!font.embedRanges) && (!font.embeddedChars))
					{
						issues++;
						_log(LocaleManager.getString(LocaleManager.FONT_NO_EMBEDDED_CHARS, font.font), LogStyle.TYPE_FONTS);
					}
				}
				
				font = null;
			}
			
			return issues;
		}
		
		private function _searchForTweenedIssues(symbol:SymbolElement, tweenedTo: TweenedIssues, suspectMatrix:Boolean, suspectColors:Boolean, suspectFilters:Boolean):void
		{
			if (symbol.parentFrame.nextFrame)
			{
				var sameSymbolAtNextFrame:SymbolElement = (symbol.parentFrame.nextFrame.getChildElement(symbol) as SymbolElement);
				if (sameSymbolAtNextFrame)
				{
					if (suspectMatrix)
					{
						if (_matrixTransformed(symbol.matrixes, sameSymbolAtNextFrame.matrixes) && (symbol.cacheAsBitmap || symbol.filters))
						{
							tweenedTo.matrixTransformed = sameSymbolAtNextFrame.parentFrame.index;
							symbol.includedIntoMatrixIssue = true;
						}
						else
						{
							suspectMatrix = false;
						}
					}
					
					if (suspectColors)
					{
						if (_colorEffectsChanged(symbol.colorEffects, sameSymbolAtNextFrame.colorEffects) && (symbol.cacheAsBitmap || symbol.filters))
						{
							tweenedTo.colorEffectChanged = sameSymbolAtNextFrame.parentFrame.index;
							symbol.includedIntoColorsIssue = true;
						}
						else
						{
							suspectColors = false;
						}
					}
					
					if (suspectFilters)
					{
						if (_filtersChanged(symbol.filters, sameSymbolAtNextFrame.filters) && (symbol.cacheAsBitmap || symbol.filters))
						{
							tweenedTo.filterChanged = sameSymbolAtNextFrame.parentFrame.index;
							symbol.includedIntoFiltersIssue = true;
						}
						else
						{
							suspectFilters = false;
						}
					}
					
					if (suspectMatrix || suspectColors || suspectFilters)
					{
						if (sameSymbolAtNextFrame.parentFrame.tweenType != null)
						{
							_searchForTweenedIssues(sameSymbolAtNextFrame, tweenedTo, suspectMatrix, suspectColors, suspectFilters);
						}
					}
					
				}
			}
		}
		
		private function _matrixTransformed(matrixes1:Vector.<ElementMatrix>, matrixes2:Vector.<ElementMatrix>):Boolean 
		{
			var matrix1:ElementMatrix;
			var matrix2:ElementMatrix;
			
			if (matrixes1)
			{
				matrix1 = matrixes1[0];
			}
			else
			{
				matrix1 = new ElementMatrix();
			}
			
			if (matrixes2)
			{
				matrix2 = matrixes2[0];
			}
			else
			{
				matrix2 = new ElementMatrix();
			}
			
			if ((matrix1.a != matrix2.a) ||
				(matrix1.b != matrix2.b) ||
				(matrix1.c != matrix2.c) ||
				(matrix1.d != matrix2.d))
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		private function _colorEffectsChanged(colorEffects1:Vector.<ColorEffect>, colorEffects2:Vector.<ColorEffect>):Boolean 
		{
			var color1:ColorEffect;
			var color2:ColorEffect;
			
			if (colorEffects1)
			{
				color1 = colorEffects1[0];
			}
			else
			{
				color1 = new ColorEffect();
			}
			
			if (colorEffects2)
			{
				color2 = colorEffects2[0];
			}
			else
			{
				color2 = new ColorEffect();
			}
			
			if ((color1.alphaMultiplier != color2.alphaMultiplier) ||
				(color1.redMultiplier != color2.redMultiplier) ||
				(color1.blueMultiplier != color2.blueMultiplier) ||
				(color1.greenMultiplier != color2.greenMultiplier) ||
				(color1.alphaOffset != color2.alphaOffset) ||
				(color1.redOffset != color2.redOffset) ||
				(color1.blueOffset != color2.blueOffset) ||
				(color1.greenOffset != color2.greenOffset) ||
				(color1.brightness != color2.brightness) ||
				(color1.tintMultiplier != color2.tintMultiplier) ||
				(color1.tintColor != color2.tintColor))
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		private function _filtersChanged(filters1:Vector.<FilterBase>, filters2:Vector.<FilterBase>):Boolean 
		{
			var result:Boolean = false;
			
			var filter1:FilterBase;
			var filter2:FilterBase;
			
			if (!filters1 && !filters2) return false;
			if (!filters1 && filters2) return true;
			if (filters1 && !filters2) return true;
			
			var len:uint = filters1.length;
			var i:uint;
			
			
			for (i = 0; i < len; i++ )
			{
				filter1 = filters1[i];
				filter2 = filters2[i];
				
				if (filter1.isEnabled && filter2.isEnabled)
				{
					if (filter1.rawAttributes != filter2.rawAttributes)
					{
						result = true;
						break;
					}
				}
			}
			
			return result;
		}
	}
}