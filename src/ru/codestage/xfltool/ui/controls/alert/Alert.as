package ru.codestage.xfltool.ui.controls.alert
{
	import com.bit101.components.ProgressBar;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import com.bit101.components.Window;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import ru.codestage.xfltool.ui.builder.UIBuilder;
	import ru.codestage.xfltool.ui.controls.antialiased.LabelAntiAliased;
	import ru.codestage.xfltool.ui.controls.antialiased.PushButtonAntiAliased;
	import ru.codestage.xfltool.ui.controls.antialiased.TextAreaAntiAliased;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	
	/**
	 * ...
	 * @author ...
	 */
	public final class Alert extends Window
	{
		public static const MESSAGE_TYPE_OK:uint = 0;
		public static const MESSAGE_TYPE_YES_NO:uint = 1;
		public static const MESSAGE_TYPE_UPDATE:uint = 2;
		
		public static const ANSWER_OK:uint = 0;
		public static const ANSWER_YES:uint = 1;
		public static const ANSWER_NO:uint = 2;
		
		private var _message:TextAreaAntiAliased;
		private var _okBtn:PushButtonAntiAliased;
		private var _yesBtn:PushButtonAntiAliased;
		private var _noBtn:PushButtonAntiAliased;
		
		private var _downloadProgress:ProgressBar;
		private var _updateLabel:LabelAntiAliased;
		
		private var _callback:Function;
		
		private var _currentType:uint;
		
		
		public function Alert(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, title:String = "")
		{
			super(parent, xpos, ypos, title);
			
			_init();
		}
		
		private function _init():void
		{
			draggable = false;
			hasMinimizeButton = false;
			hasCloseButton = true;
			visible = false;
			
			this.width = 300;
			this.height = 250;
			
			this.x = stage.stageWidth / 2 - this.width / 2;
			this.y = stage.stageHeight / 2 - this.height / 2;
			
			_message = new TextAreaAntiAliased(this,1,1);
			_message.width = this.width - 1;
			_message.autoHideScrollBar = true;
			_message.html = true;
			
			_okBtn = new PushButtonAntiAliased(this, 0, 0, "OK", _onOK);
			_okBtn.width = 80;
			_okBtn.height = 20;
			_okBtn.x = this.width / 2 - _okBtn.width / 2;
			_okBtn.y = this.height - this.titleBar.height - _okBtn.height - 10;
			
			_yesBtn = new PushButtonAntiAliased(this, 0, 0, LocaleManager.getString(LocaleManager.GUI_YES), _onYes);
			_yesBtn.width = 80;
			_yesBtn.height = 20;
			_yesBtn.x = this.width / 2 - _yesBtn.width - 5;
			_yesBtn.y = this.height - this.titleBar.height - _yesBtn.height - 10;
			
			_noBtn = new PushButtonAntiAliased(this, 0, 0, LocaleManager.getString(LocaleManager.GUI_NO), _onNo);
			_noBtn.width = 80;
			_noBtn.height = 20;
			_noBtn.x = this.width / 2 + 5;
			_noBtn.y = this.height - this.titleBar.height - _noBtn.height - 10;
			
			_updateLabel = new LabelAntiAliased(this, 0, 0, "Do you wish to update now?");
			
			_downloadProgress = new ProgressBar(this, 0, 0);
			_downloadProgress.width = 100;
			_downloadProgress.height = 10;
			
			_message.height = this.height - this.titleBar.height - _okBtn.height - 21;
			
		}
		
		private function _onOK(me:MouseEvent):void 
		{
			hide(ANSWER_OK);
		}
		
		private function _onYes(me:MouseEvent):void 
		{
			hide(ANSWER_YES);
		}
		
		private function _onNo(me:MouseEvent):void 
		{
			hide(ANSWER_NO);
		}
		
		override protected function onClose(e:MouseEvent):void 
		{
			if (_currentType == MESSAGE_TYPE_OK)
			{
				hide(ANSWER_OK);
			}
			else if (_currentType == MESSAGE_TYPE_YES_NO)
			{
				hide(ANSWER_NO);
			}
		}
		
		public function showMessage(messageText:String, messageTitle:String = null, type:uint = MESSAGE_TYPE_OK, callback:Function = null):void
		{
			this._callback = callback;
			_currentType = type;
			if (messageTitle == null) messageTitle = LocaleManager.getString(LocaleManager.GUI_WARNING);
			this.title = messageTitle;
			_message.text = messageText;
			
			if (type == MESSAGE_TYPE_OK || type == MESSAGE_TYPE_YES_NO)
			{
				this.width = 300;
				this.height = 250;
				
				_message.width = this.width - 1;
				
				_yesBtn.x = this.width / 2 - _yesBtn.width - 5;
				_yesBtn.y = this.height - this.titleBar.height - _yesBtn.height - 10;
				
				_noBtn.x = this.width / 2 + 5;
				_noBtn.y = this.height - this.titleBar.height - _noBtn.height - 10;
				
				_message.height = this.height - this.titleBar.height - _okBtn.height - 21;
				
				
				if (type == MESSAGE_TYPE_OK)
				{
					_okBtn.visible = true;
					_yesBtn.visible = false;
					_noBtn.visible = false;
				}
				else
				{
					_okBtn.visible = false;
					_yesBtn.visible = true;
					_noBtn.visible = true;
				}
				
				_downloadProgress.visible = false;
				_updateLabel.visible = false;
			}
			else if (type == MESSAGE_TYPE_UPDATE)
			{
				this.width = 800;
				this.height = 400;
				
				_message.width = this.width - 1;
				_message.height = 300;
				
				_updateLabel.y = _message.y + _message.height + 15;
				_updateLabel.x = this.width / 2 - _updateLabel.width / 2;
				//_downloadProgress.y = _message.y + _message.height + 5;
				
				_yesBtn.x = 15;
				_yesBtn.y = _updateLabel.y + _updateLabel.height + 15;
				
				_noBtn.x = this.width - _noBtn.width - 15;
				_noBtn.y = _updateLabel.y + _updateLabel.height + 15;
				
				_downloadProgress.visible = false;
				_updateLabel.visible = true;
				_okBtn.visible = false;
				_yesBtn.visible = true;
				_noBtn.visible = true;
			}
			
			this.x = stage.stageWidth / 2 - this.width / 2;
			this.y = stage.stageHeight / 2 - this.height / 2;
			
			this.visible = true;
			
			UIBuilder.instance.mainPage.enabled = false;
		}
		
		public function hide(answer:uint):void
		{
			UIBuilder.instance.mainPage.enabled = true;
			visible = false;
			
			if (this._callback != null) this._callback(answer);
		}
		
	}

}