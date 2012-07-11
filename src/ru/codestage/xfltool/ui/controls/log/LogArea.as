package ru.codestage.xfltool.ui.controls.log
{
	import com.bit101.components.Panel;
	import com.bit101.components.ScrollPane;
	import com.bit101.components.Style;
	import com.bit101.components.TextArea;
	import com.junkbyte.console.Cc;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	import ru.codestage.utils.string.StrUtil;
	import ru.codestage.xfltool.Main;
	import ru.codestage.xfltool.ui.controls.customized.ScrollPaneNoHScroll;
	import ru.codestage.xfltool.ui.controls.customized.TextAreaHTML;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	
	/**
	 * ...
	 * @author Dmitriy [focus] Yukhanov
	 */
	public final class LogArea extends TextAreaHTML
	{
		private var _currentLogIndex:uint;
		//private var items:Vector.<LogAreaItem> = new Vector.<LogAreaItem>();
		private var totalHints:Vector.<String> = new Vector.<String>();
		//private var _locked:Boolean = false;
		
		public function LogArea(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, text:String="")
		{
			super(parent, xpos, ypos, text);
			_init();
		}
		
		private function _init():void 
		{
			_currentLogIndex = 0;
			this.addEventListener(MouseEvent.MOUSE_WHEEL, this_mouseWheel);
			
			this.autoHideScrollBar = true;
			this.mouseEnabled = false;
			this.html = true;
			this.editable = false;
			this.selectable = true;
			
			textField.defaultTextFormat = new TextFormat(Style.fontName, 14, Style.LABEL_TEXT);
			textField.styleSheet = Main.instance.logStyle.styleSheet;
		}
		
		private function this_mouseWheel(e:MouseEvent):void 
		{
			_scrollbar.value -= e.delta*10;
		}
		
		public function add(newLogLines:String, type:String = null, hint:String = null):void
		{
			if (type != null)
			{
				text += "<span class='" + type + "'>" + newLogLines + "</span><span class='line'> <br> </span><br>";
			}
			else
			{
				text += "<span class='body'>" + newLogLines + "</span><span class='line'> <br> </span><br>";
			}
			
			_scrollDownRequestsCounter++;
			
			if (hint)
			{
				hint = "<span class='" + type + "'>" + LocaleManager.getString(LocaleManager.LOG_HINT) + "</span><i>" + hint + "</i>";
				if (totalHints.indexOf(hint) == -1)
				{
					totalHints[totalHints.length] = hint;
				}
			}
		}
		
		public function addTotalHints():void
		{
			var len:uint = totalHints.length;
			var i:uint = 0;
			
			for (i; i < len; i++ )
			{
				add(totalHints[i], LogStyle.TYPE_CONTEXT_HINT);
			}
			totalHints.length = 0;
		}
		
		public function clear():void
		{
			_currentLogIndex = 0;
			text = "";
			totalHints.length = 0;
			
			draw();
		}
		
		public function getRawText():String
		{
			/*var result:String = "";
			var len:uint = items.length;
			var i:uint = 0;
			
			for (i; i < len; i++ )
			{
				result += items[i].getRawText() + "\n==========================================================================\n";
			}*/
			
			return _tf.text;
		}
		
		/*public function lock():void
		{
			_locked = true;
		}
		
		public function unlock():void
		{
			setTimeout(_afterUnlock, 500);
		}*/
	}

}