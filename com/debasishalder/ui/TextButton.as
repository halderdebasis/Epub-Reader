package com.debasishalder.ui
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;

	public class TextButton extends Sprite
	{
		public var label:TextField;
		public var labelFormat:TextFormat;
		public function TextButton(labelText:String,Colour:uint = 0x000000,fontSize:Number = 16,fntColor:uint =0xffffff,alphas:Number = 0 )
		{
			var w:Number;
			var h:Number = 40;
			labelFormat = new TextFormat("_sans", fontSize,fntColor, true, false,false, null, null, "center");
			label = new TextField();
			label.defaultTextFormat = labelFormat;
			label.text = labelText;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.height = h;
			label.y = (h - label.textHeight) / 2 - 2;
			addChild(label);
			w = label.width + 10;
			label.x = (w - label.width) / 2;
			graphics.beginFill(Colour,alphas);
			graphics.drawRoundRect(0, 0, w, h, 8);
			buttonMode = true;
			mouseChildren = false;
		}
		public function ChangeLabel(S:String)
		{
			label.defaultTextFormat = labelFormat;
			label.text = S;
		}
	}

}