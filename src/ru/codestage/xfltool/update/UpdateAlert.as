package ru.codestage.xfltool.update
{
	import com.bit101.components.HBox;
	import com.bit101.components.ProgressBar;
	import com.bit101.components.PushButton;
	import com.bit101.components.Style;
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
	import ru.codestage.xfltool.ui.controls.customized.TextAreaHTML;
	import ru.codestage.xfltool.ui.locale.LocaleManager;
	
	/**
	 * ...
	 * @author ...
	 */
	public final class UpdateAlert extends Window
	{
		public static const ANSWER_YES:uint = 1;
		public static const ANSWER_NO:uint = 0;
		
		private var _message:TextAreaHTML;
		private var _yesBtn:PushButtonAntiAliased;
		private var _noBtn:PushButtonAntiAliased;
		
		private var _downloadProgress:ProgressBar;
		private var _updateLabel:LabelAntiAliased;
		private var _progressLabel:LabelAntiAliased;
		
		private var _callback:Function;
		
		
		public function UpdateAlert(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, title:String = "")
		{
			super(parent, xpos, ypos, title);
			
			_init();
		}
		
		private function _init():void
		{
			
			draggable = false;
			hasMinimizeButton = false;
			hasCloseButton = false;
			visible = false;
			
			this.width = 800;
			this.height = 400;
			
			this.x = stage.stageWidth / 2 - this.width / 2;
			this.y = stage.stageHeight / 2 - this.height / 2;
			
			_message = new TextAreaHTML(this,1,1);
			_message.width = this.width - 1;
			_message.height = 300;
			_message.autoHideScrollBar = true;
			_message.html = true;
			_message.editable = false;
			_message.selectable = true;
			
			Style.fontSize += 4;
			
			_updateLabel = new LabelAntiAliased(this, 0, _message.y + _message.height + 15, LocaleManager.getString(LocaleManager.GUI_ASK_FOR_UPDATE));
			_updateLabel.x = this.width / 2 - _updateLabel.width / 2;
			
			Style.fontSize -= 4;
			
			_yesBtn = new PushButtonAntiAliased(this, 15, _updateLabel.y + _updateLabel.height + 15, LocaleManager.getString(LocaleManager.GUI_YES), _onYes);
			_yesBtn.width = 80;
			_yesBtn.height = 20;
			
			_noBtn = new PushButtonAntiAliased(this, 0, _updateLabel.y + _updateLabel.height + 15, LocaleManager.getString(LocaleManager.GUI_NO), _onNo);
			_noBtn.x = this.width - _noBtn.width - 15;
			_noBtn.width = 80;
			_noBtn.height = 20;
			
			_progressLabel = new LabelAntiAliased(this, 15, _message.y + _message.height + 30, LocaleManager.getString(LocaleManager.GUI_PROGRESS_LABEL));
			
			_downloadProgress = new ProgressBar(this, _progressLabel.x + _progressLabel.width + 5, _progressLabel.y);
			_downloadProgress.width = this.width - _downloadProgress.x - 15;
			_downloadProgress.height = _progressLabel.height;
			_downloadProgress.maximum = 100;
			
		}
		
		private function _onYes(me:MouseEvent):void 
		{
			_callback(ANSWER_YES);
			
			_downloadProgress.visible = true;
			_progressLabel.visible = true;
			
			_updateLabel.visible = false;
			_yesBtn.visible = false;
			_noBtn.visible = false;
		}
		
		private function _onNo(me:MouseEvent):void 
		{
			hide(ANSWER_NO);
		}
		
		public function showMessage(updateDescription:String, updateToVersion:String, callback:Function):void
		{
			_callback = callback;
			
			this.title = LocaleManager.getString(LocaleManager.GUI_NEW_VERSION, updateToVersion);
			_message.text = updateDescription;
			
			_downloadProgress.visible = false;
			_progressLabel.visible = false;
			
			_updateLabel.visible = true;
			_yesBtn.visible = true;
			_noBtn.visible = true;
			
			this.visible = true;
			
			UIBuilder.instance.mainPage.enabled = false;
		}
		
		public function hide(answer:uint):void
		{
			UIBuilder.instance.mainPage.enabled = true;
			visible = false;
			
			if (this._callback != null) this._callback(answer);
			
		}
		
		public function setProgress(percent:Number):void
		{
			_downloadProgress.value = percent;
		}
	}

}