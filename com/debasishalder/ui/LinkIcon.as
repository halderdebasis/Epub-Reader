package com.debasishalder.ui
{
	import com.debasishalder.event.EpubEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import com.debasishalder.ui.TextButton;
	public class LinkIcon extends Sprite
	{
		public var LinkBtn:TextButton;
		public var EVENTNAME:String
		public var mainsource:String
		public var gcmode:Boolean = true
		
		public function LinkIcon()
		{
			
		}
		public function MakeIcon(LinkSource:String,textToDisplay:String)
		{			
			mainsource = LinkSource
			LinkBtn = new TextButton(textToDisplay,0x000000,20,0xff0000);
			LinkBtn.name = 'Link Item'
			LinkBtn.mouseChildren = false
			addChild(LinkBtn);
			if(gcmode){
			addEventListener(Event.REMOVED,clearall);
			}
			LinkBtn.addEventListener(MouseEvent.CLICK,checkS);
		}
		public function setType(S:String)
		{
			this.EVENTNAME = S
		}
		function checkS(e:MouseEvent)
		{	
			stage.dispatchEvent(new EpubEvent(EpubEvent.ON_EPUB_ITEM_CLICK,{types:this.EVENTNAME ,source:mainsource}));
			trace('dispatchEvent::'+EpubEvent.ON_EPUB_ITEM_CLICK+'  EVENTNAME :: '+this.EVENTNAME)			
		}
		public function clearall(e:Event = null)
		{
			removeEventListener(Event.REMOVED,clearall);
			LinkBtn.removeEventListener(MouseEvent.CLICK,checkS);
			mainsource = null;
			EVENTNAME = null;
			LinkBtn = null;
		}
	}

}