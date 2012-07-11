package ru.codestage.xfltool.map
{
	import com.junkbyte.console.Cc;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.system.System;
	import flashx.textLayout.conversion.TextConverter;
	import ru.codestage.utils.string.StrUtil;
	import ru.codestage.xfltool.map.items.elements.attributes.ColorEffect;
	import ru.codestage.xfltool.map.items.elements.attributes.ElementAdjustColorFilter;
	import ru.codestage.xfltool.map.items.elements.attributes.ElementBevelFilter;
	import ru.codestage.xfltool.map.items.elements.attributes.ElementBlurFilter;
	import ru.codestage.xfltool.map.items.elements.attributes.ElementDropShadowFilter;
	import ru.codestage.xfltool.map.items.elements.attributes.ElementGlowFilter;
	import ru.codestage.xfltool.map.items.elements.attributes.ElementGradientBevelFilter;
	import ru.codestage.xfltool.map.items.elements.attributes.ElementGradientGlowFilter;
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
	import ru.codestage.xfltool.map.items.TimelineItem;
	import ru.codestage.xfltool.readers.FileReader;
	import ru.codestage.xfltool.ui.controls.log.LogStyle;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	import ru.codestage.xfltool.utils.FileUtil;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class ProjectMap extends Object
	{
		public var projectFonts:Vector.<FontItem>;
		public var elementSymbols:Vector.<SymbolElement>;
		public var projectLibrarySymbols:Vector.<SymbolElement>;
		
		public var projectHasManyScenes:Boolean = false;
		
		public function ProjectMap()
		{
			super();
		}
		
		public function createProjectMap(xflDirectoryPath:File, _log:Function = null):void
		{
			var len:uint = 0;
			var i:uint = 0;
			
			projectLibrarySymbols = new Vector.<SymbolElement>();
			elementSymbols = new Vector.<SymbolElement>();
			
			var mainDomPath:File = xflDirectoryPath.resolvePath("DOMDocument.xml");
			var airXMLReader:FileReader = new FileReader();
			
			if (mainDomPath.exists)
			{
				var domXMLString:String = airXMLReader.readFileToString(mainDomPath);
				if (domXMLString)
				{
					_getFonts(domXMLString);
					_parse(domXMLString, true);
					domXMLString = null;
				}
			}
			else
			{
				_log(LocaleManager.getString(LocaleManager.FILE_NOT_FOUND, mainDomPath.nativePath), LogStyle.TYPE_VERY_IMPORTANT);
			}
			
			var libraryXMLFiles:Vector.<File> = FileUtil.searchForFilesByExt("xml", xflDirectoryPath.resolvePath("LIBRARY"));
			
			len = libraryXMLFiles.length;
			
			var libXMLString:String;
			for (i = 0; i < len; i++)
			{
				libXMLString = airXMLReader.readFileToString(libraryXMLFiles[i]);
				
				if (libXMLString)
				{
					_parse(libXMLString);
					libXMLString = null;
				}
			}
			
			libraryXMLFiles.length = 0;
			libraryXMLFiles = null;
			
			airXMLReader = null;
			
			len = elementSymbols.length;
			
			for (i = 0; i < len; i++)
			{
				var element:SymbolElement = elementSymbols[i];
				
				var j:uint;
				var libraryLen:uint = projectLibrarySymbols.length;
				
				for (j = 0; j < libraryLen; j++)
				{
					var projectLibrarySymbol:SymbolElement = projectLibrarySymbols[j];
					
					if (element.name == projectLibrarySymbol.name)
					{
						element.applyLibrarySymbol(projectLibrarySymbol);
					}
					projectLibrarySymbol = null;
				}
			}
		}
		
		public function clear():void 
		{
			var leni:uint = elementSymbols.length;
			var i:uint;
			
			var lenj:uint;
			var j:uint;
			
			for (i = 0; i < leni; i++ )
			{
				var symbol:SymbolElement = elementSymbols[i];
				_clearVector(symbol.colorEffects);
				symbol.colorEffects = null;
				_clearVector(symbol.filters);
				symbol.filters = null;
				symbol.lastLocationToFrame = null;
				symbol.librarySymbol = null;
				_clearVector(symbol.matrixes);
				symbol.matrixes = null;
				
				if (symbol.ownChildren)
				{
				
					lenj = symbol.ownChildren.length;
					var child:Element;
					for (j = 0; j < lenj; j++ )
					{
						child = symbol.ownChildren[j];
						_clearVector(child.includedIntoIssuesTypes);
						child.includedIntoIssuesTypes = null;
						child.lastLocationToFrame = null;
						_clearVector(child.matrixes);
						child.matrixes = null;
						child.parentFrame = null;
						child.parentLayer = null;
						child.parentSymbol = null;
						child.xml = null;
						
						if (child is ShapeElement)
						{
							_clearVector((child as ShapeElement).edges);
							(child as ShapeElement).edges = null;
						}
						else if (child is TextElement)
						{
							_clearVector((child as TextElement).filters);
							(child as TextElement).filters = null;
						}
						else if (child is TLFTextElement)
						{
							_clearVector((child as TLFTextElement).colorEffects);
							(child as TLFTextElement).colorEffects = null;
							_clearVector((child as TLFTextElement).fonts);
							(child as TLFTextElement).fonts = null;
						}
						
					}
					child = null;
					_clearVector(symbol.ownChildren);
					symbol.ownChildren = null;
				}
				
				_clearVector(symbol.ownChildrenSymbols);
				symbol.ownChildrenSymbols = null;
				
				if (symbol.ownFrames)
				{
					lenj = symbol.ownFrames.length;
					var frame:FrameItem;
					for (j = 0; j < lenj; j++ )
					{
						frame = symbol.ownFrames[j];
						frame.actionScript = null;
						_clearVector(frame.elements);
						frame.elements = null;
						
						frame.layer = null;
						frame.nextFrame = null;
						frame.previousFrame = null;
						frame.symbol = null;
						frame.tweenedFrom = null;
						frame.tweenedTo = null;
					}
					frame = null;
					_clearVector(symbol.ownFrames);
					symbol.ownFrames = null;
				}
				
				if (symbol.ownLayers)
				{
					lenj = symbol.ownLayers.length;
					var layer:LayerItem;
					for (j = 0; j < lenj; j++ )
					{
						layer = symbol.ownLayers[j];
						_clearVector(layer.children);
						layer.children = null;
						_clearVector(layer.elements);
						layer.elements = null;
						_clearVector(layer.frames);
						layer.frames = null;
						layer.symbol = null;
					}
					layer = null;
					
					_clearVector(symbol.ownLayers);
					symbol.ownLayers = null;
				}
				
				if (symbol.ownTimeline)
				{
					_clearVector(symbol.ownTimeline.layers);
					symbol.ownTimeline.layers = null;
					symbol.ownTimeline = null;
				}
				
				symbol.parentFrame = null;
				symbol.parentLayer = null;
				symbol.parentSymbol = null;
				symbol.xml = null;
			}
			
			_clearVector(elementSymbols);
			elementSymbols = null;
			_clearVector(projectFonts);
			projectFonts = null;
			_clearVector(projectLibrarySymbols);
			projectLibrarySymbols = null;
		}
		
		private function _getFonts(domXMLString:String):void
		{
			var fontsXML:XML;
			
			var openTagIndex:int = domXMLString.indexOf("<fonts>");
			if (openTagIndex > -1)
			{
				fontsXML = XML(domXMLString.substring(openTagIndex, domXMLString.indexOf("</fonts>") + 8));
			}
			
			if (fontsXML)
			{
				var fonts:XMLList = fontsXML.children();
				var len:uint = fonts.length();
				
				projectFonts = new Vector.<FontItem>(len, true);
				
				var i:uint;
				
				var fontItem:FontItem;
				
				var fontXML:XML;
				
				for (i = 0; i < len; i++)
				{
					fontXML = fonts[i];
					fontItem = new FontItem();
					
					if ("@embedRanges" in fontXML)
					{
						fontItem.embedRanges = true;
					}
					
					if ("@embeddedCharacters" in fontXML)
					{
						fontItem.embeddedChars = true;
					}
					
					fontItem.font = fontXML.@font;
					fontItem.id = fontXML.@id;
					fontItem.itemID = fontXML.@itemID;
					fontItem.name = StrUtil.escapeHTML(fontXML.@name);
					
					projectFonts[i] = fontItem;
				}
				fontItem = null;
				fontXML = null;
				System.disposeXML(fontsXML);
				fontsXML = null;
			}
			else
			{
				projectFonts = new Vector.<FontItem>();
			}
		}
		
		private function _parse(domXMLString:String, mainDocument:Boolean = false):void
		{
			var openTagIndex:int;
			
			if (mainDocument)
			{
				var timelinesXML:XML;
				openTagIndex = domXMLString.indexOf("<timelines>");
				if (openTagIndex > -1)
				{
					timelinesXML = XML(domXMLString.substring(openTagIndex, domXMLString.indexOf("</timelines>") + 12));
				}
				
				if (timelinesXML)
				{
					var timelinesList:XMLList = timelinesXML.children();
					
					var len:uint = timelinesList.length();
					var i:uint;
					
					if (len > 1)
					{
						projectHasManyScenes = true;
					}
					
					for (i = 0; i < len; i++)
					{
						_parseTimeline(timelinesList[i]);
					}
					System.disposeXML(timelinesXML);
					timelinesXML = null;
					timelinesList = null;
				}
			}
			else
			{
				var symbol:XML = new XML(domXMLString);
				var symbolType:String;
				var libraryName:String = symbol.@name;
				var linkaged:Boolean = false;
				if ("@linkageExportForAS" in symbol)
				{
					linkaged = true;
				}
				
				if ("@symbolType" in symbol)
				{
					symbolType = symbol.@symbolType;
				}
				
				System.disposeXML(symbol);
				symbol = null;
				
				var symbolTimelineXML:XML;
				openTagIndex = domXMLString.indexOf("<timeline>");
				if (openTagIndex > -1)
				{
					symbolTimelineXML = XML(domXMLString.substring(openTagIndex, domXMLString.indexOf("</timeline>") + 11));
				}
				
				if (symbolTimelineXML)
				{
					
					//Cc.log("symbolTimelineXML = " + symbolTimelineXML);
					//Cc.log("symbolTimelineXML.DOMTimeline.DOMLayer.children().length() = " + symbolTimelineXML.DOMTimeline.layers.DOMLayer.children().length());
					_parseTimeline(symbolTimelineXML.children()[0], libraryName, linkaged, symbolType);
					System.disposeXML(symbolTimelineXML);
					symbolTimelineXML = null;
				}
			}
		}
		
		private function _parseTimeline(timeline:XML, symbolName:String = null, linkaged:Boolean = false, symbolType:String = null):void
		{
			//Cc.log(timeline);
			
			var newSymbol:SymbolElement = new SymbolElement();
			if (symbolName)
			{
				newSymbol.name = StrUtil.escapeHTML(symbolName);
			}
			else // try to get name from the timeline
			{
				newSymbol.name = StrUtil.escapeHTML(timeline.@name);
			}
			
			if (symbolType)
			{
				newSymbol.type = symbolType;
			}
			
			newSymbol.linkaged = linkaged;
			
			var newTimeline:TimelineItem = new TimelineItem();
			
			// parsing layers
			var layers:XMLList = timeline.layers.children();
			var layer:XML;
			var layersCount:uint = layers.length();
			var layerIndex:uint;
			
			if (layersCount > 0)
			{
				newTimeline.layers = new Vector.<LayerItem>(layersCount, true);
				
				for (layerIndex = 0; layerIndex < layersCount; layerIndex++)
				{
					layer = layers[layerIndex];
					
					var newLayer:LayerItem = new LayerItem();
					
					newLayer.collectionIndex = layerIndex;
					
					if ("@autoNamed" in layer)
					{
						newLayer.autoNamed = layer.@autoNamed == "true";
					}
					
					if ("@layerType" in layer)
					{
						newLayer.layerType = layer.@layerType;
					}
					
					if ("@parentLayerIndex" in layer)
					{
						newLayer.parentLayerIndex = layer.@parentLayerIndex;
						
						if (!newTimeline.layers[newLayer.parentLayerIndex].children)
						{
							newTimeline.layers[newLayer.parentLayerIndex].children = new Vector.<LayerItem>();
						}
						newTimeline.layers[newLayer.parentLayerIndex].children[newTimeline.layers[newLayer.parentLayerIndex].children.length] = newLayer;
					}
					
					newLayer.name = StrUtil.escapeHTML(layer.@name);
					newLayer.symbol = newSymbol;
					
					// parsing frames
					var frames:XMLList = layer.frames.children();
					var frame:XML;
					var framesCount:uint = frames.length();
					var frameIndex:uint;
					
					if (framesCount > 0)
					{
						newLayer.frames = new Vector.<FrameItem>(framesCount, true);
						for (frameIndex = 0; frameIndex < framesCount; frameIndex++)
						{
							frame = frames[frameIndex];
							var newFrame:FrameItem = new FrameItem();
							newFrame.symbol = newSymbol;
							newFrame.layer = newLayer;
							newFrame.collectionIndex = frameIndex;
							
							if ("Actionscript" in frame)
							{
								newFrame.actionScript = StrUtil.escapeHTML(frame.Actionscript.script);
								newLayer.haveServiceFrame = true;
							}
							
							if ("@bookmark" in frame)
							{
								newFrame.bookmark = frame.@bookmark == "true";
								newLayer.haveServiceFrame = true;
							}
							
							if ("@duration" in frame)
							{
								newFrame.duration = frame.@duration;
							}
							
							newFrame.index = frame.@index;
							
							if ("@labelType" in frame)
							{
								newFrame.labelType = frame.@labelType;
								newFrame.name = StrUtil.escapeHTML(frame.@name);
								newLayer.haveServiceFrame = true;
							}
							
							// parsing elements
							_extractElements(newTimeline, newSymbol, frame.elements.children(), newFrame, newLayer);
							if (newFrame.elements)
							{
								newTimeline.totalKeyFrames++;
							}
							
							if ("@tweenType" in frame)
							{
								newFrame.tweenType = frame.@tweenType;
								if ((frameIndex > 0) && (newFrame.elements))
								{
									if (newLayer.frames[frameIndex - 1].tweenType == newFrame.tweenType)
									{
										if (newLayer.frames[frameIndex - 1].tweenedFrom)
										{
											newFrame.tweenedFrom = newLayer.frames[frameIndex - 1].tweenedFrom;
											newFrame.tweenedFrom.tweenedTo = newFrame;
										}
										else
										{
											newFrame.tweenedFrom = newLayer.frames[frameIndex - 1];
										}
										newLayer.frames[frameIndex - 1].tweenedTo = newFrame;
									}
								}
							}
							
							newLayer.frames[frameIndex] = newFrame;
							
							if (frameIndex > 0)
							{
								newFrame.previousFrame = newLayer.frames[frameIndex - 1];
								newLayer.frames[frameIndex - 1].nextFrame = newFrame;
							}
							
							if (frameIndex == framesCount - 1)
							{
								newLayer.length = newFrame.index + newFrame.duration;
							}
							
							if (newLayer.length > 1 && !newTimeline.hasAnimation)
							{
								newTimeline.hasAnimation = true;
							}
							
							newFrame = null;
							frame = null;
						}
						
						if (!newSymbol.ownFrames)
							newSymbol.ownFrames = new Vector.<FrameItem>();
						newSymbol.ownFrames = newSymbol.ownFrames.concat(newLayer.frames);
					}
					frames = null;
					layer = null;
					
					newTimeline.layers[layerIndex] = newLayer;
				}
				
				if (!newSymbol.ownLayers)
					newSymbol.ownLayers = new Vector.<LayerItem>();
				newSymbol.ownLayers = newSymbol.ownLayers.concat(newTimeline.layers);
				
				layers = null;
				frame = null;
			}
			
			newSymbol.ownTimeline = newTimeline;
			projectLibrarySymbols[projectLibrarySymbols.length] = newSymbol;
			
			newTimeline = null;
			newSymbol = null;
		}
		
		private function _extractElements(newTimeline:TimelineItem, newSymbol:SymbolElement, elements:XMLList, newFrame:FrameItem, newLayer:LayerItem):void
		{
			var newMatrixes:Vector.<ElementMatrix>;
			
			var element:XML;
			var elementsCount:uint = elements.length();
			var elementIndex:uint;
			
			for (elementIndex = 0; elementIndex < elementsCount; elementIndex++)
			{
				element = elements[elementIndex];
				var newElement:Element;
				
				if ("matrix" in element)
				{
					var matrixes:XMLList = element.matrix.children();
					var matrixesCount:uint = matrixes.length();
					
					newMatrixes = new Vector.<ElementMatrix>(matrixesCount, true);
					var matrixIndex:uint;
					for (matrixIndex = 0; matrixIndex < matrixesCount; matrixIndex++)
					{
						var matrix:XML = matrixes[matrixIndex];
						var newMatrix:ElementMatrix = new ElementMatrix();
						
						if ("@a" in matrix)
						{
							newMatrix.a = matrix.@a;
						}
						
						if ("@b" in matrix)
						{
							newMatrix.b = matrix.@b;
						}
						
						if ("@c" in matrix)
						{
							newMatrix.c = matrix.@c;
						}
						
						if ("@d" in matrix)
						{
							newMatrix.d = matrix.@d;
						}
						
						if ("@tx" in matrix)
						{
							newMatrix.tx = matrix.@tx;
						}
						
						if ("@ty" in matrix)
						{
							newMatrix.ty = matrix.@ty;
						}
						
						newMatrixes[matrixIndex] = newMatrix;
					}
				}
				
				if (element.name() == "DOMSymbolInstance")
				{
					newTimeline.hasOnlyBitmaps = false;
					newTimeline.hasSymbols = true;
					newElement = new SymbolElement();
					
					if (!newSymbol.ownChildrenSymbols)
						newSymbol.ownChildrenSymbols = new Vector.<SymbolElement>();
					newSymbol.ownChildrenSymbols[newSymbol.ownChildrenSymbols.length] = (newElement as SymbolElement);
					
					if ("@blendMode" in element)
					{
						(newElement as SymbolElement).blendMode = element.@blendMode;
					}
					
					if ("@cacheAsBitmap" in element)
					{
						(newElement as SymbolElement).cacheAsBitmap = element.@cacheAsBitmap == "true";
					}
					
					if ("color" in element)
					{
						(newElement as SymbolElement).colorEffects = _parseColorEffects(element.color.children(), (newElement as SymbolElement));
					}
					
					if ("@exportAsBitmap" in element)
					{
						(newElement as SymbolElement).exportAsBitmap = element.@exportAsBitmap == "true";
					}
					
					if ("filters" in element)
					{
						(newElement as SymbolElement).filters = _parseFilters(element.filters.children());
					}
					
					if ("@isVisible" in element)
					{
						(newElement as SymbolElement).isVisible = element.@isVisible == "true";
					}
					
					if ("@matrix3D" in element)
					{
						(newElement as SymbolElement).matrix3D = element.@matrix3D;
					}
					
					if ("@libraryItemName" in element)
					{
						(newElement as SymbolElement).name = StrUtil.escapeHTML(element.@libraryItemName);
					}
					
					if ("@name" in element)
					{
						(newElement as SymbolElement).instanceName = StrUtil.escapeHTML(element.@name);
					}
					
					if ("@transparentBackground" in element)
					{
						(newElement as SymbolElement).transparentBackground = element.@transparentBackground == "true";
					}
					
					elementSymbols[elementSymbols.length] = (newElement as SymbolElement);
					if (newMatrixes) 
					{
						newElement.matrixes = newMatrixes;
					}
				}
				else if (element.name() == "DOMShape" || element.name() == "DOMRectangleObject")
				{
					var trueRect:Boolean = true;
					
					newTimeline.hasOnlyBitmaps = false;
					newElement = new ShapeElement();
					if (("strokes" in element) || ("stroke" in element))
					{
						(newElement as ShapeElement).haveStrokes = true;
					}
					
					if ("edges" in element)
					{
						var edges:XMLList = element.edges.children();
						var edgesCount:uint = edges.length();
						var edgeIndex:uint;
						
						if (edgesCount > 0)
						{
							(newElement as ShapeElement).edges = new Vector.<String>(edgesCount, true);
							for (edgeIndex = 0; edgeIndex < edgesCount; edgeIndex++)
							{
								var attributes:String = String(edges[edgeIndex].attributes());
								var trashPos:int = attributes.lastIndexOf("S");
								if (trashPos != -1)
								{
									if (attributes.charAt(trashPos + 2) == "|")
									{
										attributes = attributes.substring(0, trashPos) + attributes.substring(trashPos + 2, attributes.length);
									}
								}
								
								if (StrUtil.countOf(attributes, "!") != 4)
								{
									trueRect = false;
								}
								else
								{
									var coord:Vector.<String> = new Vector.<String>();
									
									var step1:Array = attributes.split("!");
									var len:uint = step1.length;
									var i:uint;
									
									for (i = 0; i < len; i++ )
									{
										var step2:Array = step1[i].split("|");
										var len2:uint = step2.length;
										var i2:uint;
										
										for (i2 = 0; i2 < len2; i2++ )
										{
											var step3:Array = step2[i2].split(" ");
											if ((step3[0]) && (step3[0] != ""))
											{
												coord[coord.length] = step3[0];
											}
											if ((step3[1]) && (step3[1] != ""))
											{
												coord[coord.length] = step3[1];
											}
										}
									}
									
									var found:Boolean = false;
									
									len = coord.length;
									
									for (i = 0; i < len; i++ )
									{
										if (StrUtil.countOf(attributes, coord[i]) == 4)
										{
											found = true;
											break;
										}
									}
									
									trueRect = found;
								}
								
								
								(newElement as ShapeElement).edges[edgeIndex] = attributes;
							}
						}
					}
					
					if (newMatrixes) 
					{
						newElement.matrixes = newMatrixes;
						
						// TODO: check all matrixes
						var mx:ElementMatrix = newMatrixes[0];
						
						if (mx.b != 0 || mx.c != 0) trueRect = false;
					}
					
					(newElement as ShapeElement).trueRectangle = trueRect;
				}
				else if (element.name() == "DOMDynamicText" || element.name() == "DOMStaticText" || element.name() == "DOMInputText")
				{
					newTimeline.hasOnlyBitmaps = false;
					newElement = new TextElement();
					if ("@name" in element)
					{
						(newElement as TextElement).name = StrUtil.escapeHTML(element.@name);
					}
					
					if ("textRuns" in element)
					{
						(newElement as TextElement).textRuns = String(element.textRuns);
						
						//if (element.name() != "DOMStaticText")
						//{
							(newElement as TextElement).text = element.textRuns.DOMTextRun.characters.text();
						//}
					}
					
					if ("@fontRenderingMode" in element)
					{
						if (element.@fontRenderingMode == "standard")
						{
							(newElement as TextElement).aliasing = "animation";
						}
						else
						{
							(newElement as TextElement).aliasing = element.@fontRenderingMode;
						}
					}
					
					if (element.name() != "DOMStaticText")
					{
						(newElement as TextElement).fontName = StrUtil.escapeHTML(element.textRuns.DOMTextRun.textAttrs.DOMTextAttrs.@face);
						(newElement as TextElement).fontEmbedded = _isEmbedded((newElement as TextElement).fontName);
					}
					
					if ("@filters" in element)
					{
						(newElement as TextElement).filters = _parseFilters(element.filters.children());
					}
					
					if (element.name() == "DOMDynamicText")
						(newElement as TextElement).type = "dynamic";
					if (element.name() == "DOMStaticText")
						(newElement as TextElement).type = "static";
					if (element.name() == "DOMInputText")
						(newElement as TextElement).type = "input";
					
					if (newMatrixes) 
					{
						newElement.matrixes = newMatrixes;
					}
				}
				else if (element.name() == "DOMTLFText")
				{
					newTimeline.hasOnlyBitmaps = false;
					newElement = new TLFTextElement();
					if ("@name" in element)
					{
						(newElement as TLFTextElement).name = StrUtil.escapeHTML(element.@name);
					}
					
					if ("markup" in element)
					{
						(newElement as TLFTextElement).markup = String(element.markup);
						(newElement as TLFTextElement).tlfText = TextConverter.importToFlow(element, TextConverter.TEXT_LAYOUT_FORMAT).getText();
						if (element.markup.tlfTextObject.@antiAliasType == "normal")
						{
							(newElement as TLFTextElement).aliasing = "animation";
						}
						else if (element.markup.tlfTextObject.@antiAliasType == "advanced")
						{
							if (element.markup.tlfTextObject.@embedFonts == "false")
							{
								(newElement as TLFTextElement).aliasing = "device";
							}
						}
					}
					
					if ("@blendMode" in element)
					{
						(newElement as TLFTextElement).blendMode = element.@blendMode;
					}
					
					if ("@cacheAsBitmap" in element)
					{
						(newElement as TLFTextElement).cacheAsBitmap = (element.@cacheAsBitmap == "true");
					}
					
					if ("color" in element)
					{
						(newElement as TLFTextElement).colorEffects = _parseColorEffects(element.color.children());
					}
					
					if ("filters" in element)
					{
						(newElement as TLFTextElement).filters = _parseFilters(element.filters.children());
					}
					
					if ("tlfFonts" in element)
					{
						var fonts:XMLList = element.tlfFonts.children();
						var fontsCount:uint = fonts.length();
						var fontIndex:uint;
						var allFontsAreEmbedded:Boolean = true;
						var hasSystemFont:Boolean = false;
						
						if (fontsCount > 0)
						{
							(newElement as TLFTextElement).fonts = new Vector.<String>(fontsCount, true);
							for (fontIndex = 0; fontIndex < fontsCount; fontIndex++)
							{
								if (allFontsAreEmbedded)
								{
									allFontsAreEmbedded = _isEmbedded(fonts[fontIndex].@psName);
								}
								
								if (!hasSystemFont)
								{
									hasSystemFont = (fonts[fontIndex].@psName == "_sans" || fonts[fontIndex].@psName == "_serif" || fonts[fontIndex].@psName == "_typewriter");
								}
								
								(newElement as TLFTextElement).fonts[fontIndex] = fonts[fontIndex].@psName;
							}
							(newElement as TLFTextElement).allFontsAreEmbedded = allFontsAreEmbedded;
							(newElement as TLFTextElement).hasSystemFont = hasSystemFont;
						}
					}
					
					if (element.markup.tlfTextObject.@editPolicy == "readOnly")
					{
						(newElement as TLFTextElement).type = "static";
					}
					else if (element.markup.tlfTextObject.@editPolicy == "readSelect")
					{
						(newElement as TLFTextElement).type = "dynamic";
					}
					else if (element.markup.tlfTextObject.@editPolicy == "readWrite")
					{
						(newElement as TLFTextElement).type = "input";
					}
					
					if (newMatrixes) 
					{
						newElement.matrixes = newMatrixes;
					}
				}
				else if (element.name() == "DOMGroup")
				{
					_extractElements(newTimeline, newSymbol, element.members.children(), newFrame, newLayer);
				}
				else if (element.name() == "DOMBitmapInstance")
				{
					newElement = new BitmapElement();
					
					if ("@libraryItemName" in element)
					{
						(newElement as BitmapElement).name = StrUtil.escapeHTML(element.@libraryItemName);
					}
					
					if (newMatrixes) 
					{
						newElement.matrixes = newMatrixes;
					}
				}
				else
				{
					newTimeline.hasOnlyBitmaps = false;
					Cc.log("Unknown element: " + element);
					newElement = new Element();
					
					/*if (newMatrixes) 
					{
						newElement.matrixes = newMatrixes;
					}*/
				}
				
				if (newElement)
				{
					newElement.parentSymbol = newSymbol;
					newElement.parentFrame = newFrame;
					newElement.parentLayer = newLayer;
					
					if ("@selected" in element)
					{
						delete element.@selected;
					}
					
					if ("@centerPoint3DX" in element)
					{
						delete element.@centerPoint3DX;
					}
					
					if ("@centerPoint3DY" in element)
					{
						delete element.@centerPoint3DY;
					}
					
					if ("@centerPoint3DZ" in element)
					{
						delete element.@centerPoint3DZ;
					}
					
					newElement.xml = element.toXMLString();
					
					if (!newSymbol.ownChildren) newSymbol.ownChildren = new Vector.<Element>();
					newSymbol.ownChildren[newSymbol.ownChildren.length] = newElement;
					
					if (!newFrame.elements) newFrame.elements = new Vector.<Element>();
					newFrame.elements[newFrame.elements.length] = newElement;
					
					if (!newLayer.elements) newLayer.elements = new Vector.<Element>();
					newLayer.elements[newLayer.elements.length] = newElement;
					
					newElement = null;
				}
			}
			element = null;
		}
		
		private function _parseFilters(filters:XMLList):Vector.<FilterBase>
		{
			var filter:XML;
			var filtersCount:uint = filters.length();
			var filterIndex:uint;
			var elementFilters:Vector.<FilterBase>;
			
			if (filtersCount > 0)
			{
				
				elementFilters = new Vector.<FilterBase>(filtersCount, true);
				for (filterIndex = 0; filterIndex < filtersCount; filterIndex++)
				{
					filter = filters[filterIndex];
					var newFilter:FilterBase;
					
					// we'll get blurX and blurY only at this moment, we don't need anything else
					if (filter.name() == "DropShadowFilter")
					{
						newFilter = new ElementDropShadowFilter();
						_getFilterBlur(ElementBlurFilter(newFilter), filter);
					}
					else if (filter.name() == "BlurFilter")
					{
						newFilter = new ElementBlurFilter();
						_getFilterBlur(ElementBlurFilter(newFilter), filter);
					}
					else if (filter.name() == "GlowFilter")
					{
						newFilter = new ElementGlowFilter();
						_getFilterBlur(ElementBlurFilter(newFilter), filter);
					}
					else if (filter.name() == "BevelFilter")
					{
						newFilter = new ElementBevelFilter();
						_getFilterBlur(ElementBlurFilter(newFilter), filter);
					}
					else if (filter.name() == "GradientGlowFilter")
					{
						newFilter = new ElementGradientGlowFilter();
						_getFilterBlur(ElementBlurFilter(newFilter), filter);
					}
					else if (filter.name() == "GradientBevelFilter")
					{
						newFilter = new ElementGradientBevelFilter();
						_getFilterBlur(ElementBlurFilter(newFilter), filter);
					}
					else if (filter.name() == "AdjustColorFilter")
					{
						newFilter = new ElementAdjustColorFilter();
					}
					else
					{
						newFilter = new FilterBase();
					}
					
					newFilter.rawAttributes = String(filter.attributes());
					
					if ("@isEnabled" in filter)
					{
						newFilter.isEnabled = filter.@isEnabled == "true";
					}
					
					elementFilters[filterIndex] = newFilter;
					newFilter = null;
				}
				filter = null;
			}
			return elementFilters;
		}
		
		private function _getFilterBlur(newFilter:ElementBlurFilter, filter:XML):void
		{
			if ("@blurX" in filter)
			{
				newFilter.blurX = filter.@blurX;
			}
			
			if ("@blurY" in filter)
			{
				newFilter.blurY = filter.@blurY;
			}
			
			if ("@quality" in filter)
			{
				newFilter.quality = filter.@quality;
			}
		}
		
		private function _parseColorEffects(colorEffects:XMLList, element:SymbolElement = null):Vector.<ColorEffect>
		{
			
			var colorEffect:XML;
			var colorEffectsCount:uint = colorEffects.length();
			var colorEffectIndex:uint;
			var elementColorEffects:Vector.<ColorEffect>;
			
			if (colorEffectsCount > 0)
			{
				elementColorEffects = new Vector.<ColorEffect>(colorEffectsCount, true);
				for (colorEffectIndex = 0; colorEffectIndex < colorEffectsCount; colorEffectIndex++)
				{
					colorEffect = colorEffects[colorEffectIndex];
					var newColorEffect:ColorEffect = new ColorEffect();
					
					if ("@alphaMultiplier" in colorEffect)
					{
						newColorEffect.alphaMultiplier = colorEffect.@alphaMultiplier;
						if (element)
						{
							element.alpha = newColorEffect.alphaMultiplier;
						}
					}
					
					if ("@alphaOffset" in colorEffect)
					{
						newColorEffect.alphaOffset = colorEffect.@alphaOffset;
					}
					
					if ("@blueMultiplier" in colorEffect)
					{
						newColorEffect.blueMultiplier = colorEffect.@blueMultiplier;
					}
					
					if ("@blueOffset" in colorEffect)
					{
						newColorEffect.blueOffset = colorEffect.@blueOffset;
					}
					
					if ("@brightness" in colorEffect)
					{
						newColorEffect.brightness = colorEffect.@brightness;
					}
					
					if ("@greenMultiplier" in colorEffect)
					{
						newColorEffect.greenMultiplier = colorEffect.@greenMultiplier;
					}
					
					if ("@greenOffset" in colorEffect)
					{
						newColorEffect.greenOffset = colorEffect.@greenOffset;
					}
					
					if ("@redMultiplier" in colorEffect)
					{
						newColorEffect.redMultiplier = colorEffect.@redMultiplier;
					}
					
					if ("@redOffset" in colorEffect)
					{
						newColorEffect.redOffset = colorEffect.@redOffset;
					}
					
					if ("@tintColor" in colorEffect)
					{
						newColorEffect.tintColor = colorEffect.@tintColor;
					}
					
					if ("@tintMultiplier" in colorEffect)
					{
						newColorEffect.tintMultiplier = colorEffect.@tintMultiplier;
					}
					
					elementColorEffects[colorEffectIndex] = newColorEffect;
					newColorEffect = null;
				}
				colorEffect = null;
			}
			return elementColorEffects;
		}
		
		private function _isEmbedded(fontName:String):Boolean
		{
			var result:Boolean = false;
			
			var len:uint = projectFonts.length;
			var i:uint;
			
			if (fontName.lastIndexOf("*") == fontName.length - 1)
			{
				fontName = fontName.substr(0, fontName.length - 1);
				for (i = 0; i < len; i++)
				{
					if (projectFonts[i].name.indexOf(fontName) != -1)
					{
						result = true;
						break;
					}
				}
			}
			else
			{
				for (i = 0; i < len; i++)
				{
					if (projectFonts[i].font == fontName)
					{
						result = true;
						break;
					}
				}
			}
			
			return result;
		}
		
		private function _clearVector(vector:Object):void 
		{
			if (vector)
			{
				vector.fixed = false;
				vector.length = 0;
			}
		}
	
	}
}