package com.debasishalder.ui  {
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	
	public class contextmenuPopup extends Sprite {
var closers:Function
public var path:String
var maxWW:Number = 0
var mc_Holder:Vector.<MovieClip> = new Vector.<MovieClip>()
		public function contextmenuPopup() {
			// constructor code
		}
public function makepopup(bg:Class,itemname:Array,closer:Function = null,maxW:Number = 0,MaxH:Number = 0){
	closers = closer
	if(maxW != 0 && MaxH != 0){
		this.graphics.beginFill(0x0000000,0.4)
		this.graphics.drawRect(0,0,maxW,MaxH)
		this.graphics.endFill()
	}
	var yy:Number = 0
	var oldW:Number = 0
	var mcHolder:Sprite = new Sprite()
	for(var s:int = 0; s < itemname.length; s++){
		var mc:MovieClip = new bg()
		mc.lbl_txt.text = itemname[s]
		mc.lbl_txt.autoSize = TextFieldAutoSize.CENTER
		var WW:Number = mc.lbl_txt.width + 10
		mc.bg_mc.width = WW
		mc.bg_mc.height = mc.lbl_txt.height + 10
		mc.lbl_txt.x = 5
		mc.lbl_txt.y = 5
		mc_Holder.push(mc)
		maxWW = Math.max(oldW,WW)
		oldW = WW
		//var sd:TextFieldAutoSize
		mc.mouseChildren = false
		mc.y = yy
		mcHolder.addChild(mc)
		yy +=mc.height
		
	}
	for(var g:int = 0; g < mc_Holder.length; g++){
		mc_Holder[g].bg_mc.width = maxWW
		mc_Holder[g].lbl_txt.x = (maxWW - mc_Holder[g].lbl_txt.width)/2
		
	}
	mcHolder.x = (maxW - mcHolder.width)/2
	mcHolder.y = (MaxH - mcHolder.height)/2
	addChild(mcHolder)
	itemname =null
	this.addEventListener(MouseEvent.CLICK,fireit)
}
function fireit(e:MouseEvent){
	if(closers != null){
		closers(e.target.lbl_txt.text)
	}
	Object(parent).removeChild(this)
}
	}
	
}
