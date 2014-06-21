package com.debasishalder.book
{
	import flash.display.Sprite;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.MovieClip;
	import flash.geom.*;
	import flash.display.*;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class page extends Sprite
	{
		private var Main_mov:Sprite = new Sprite();
		private var page_BG:Sprite = new Sprite();
		private var page_Border:Sprite = new Sprite();
		public var PageNumber:int
		public var TextFlowIndex:int 
		public var ChapterId:int
		public var ChapterName:String
		private var Middle_Fold:Sprite = new Sprite();
		//private var L_page_Number:TextField = new TextField();
		//private var R_page_Number:TextField = new TextField();
		//private var txt_fmt:TextFormat = new TextFormat();
		public function page(W:Number,H:Number,col:uint = 0xFCFADC,pageNum:int = 0)
		{
			page_BG.graphics.beginFill(col,1);
			//#009933;
			PageNumber = pageNum
			page_BG.graphics.drawRect(0,0,W,H);
			page_BG.graphics.endFill();
			Main_mov.addChild(page_BG);
			///////////////////////////////////

			//var font:Font_Arial=new Font_Arial();
			//txt_fmt.font = 'Arial'//font.fontName;
			//txt_fmt.size = 12;

			page_Border.graphics.beginFill(0x648ECE,1);
			page_Border.graphics.drawRect(0,H-20,W,20);
			page_Border.graphics.endFill();
			Main_mov.addChild(page_Border);
			var fillType:String
			var colors:Array
			var alphas:Array 
			var ratios:Array 
			var matr:Matrix = new Matrix();
			 fillType = GradientType.LINEAR;
			 colors = [0x000000, 0xFFFFFF]//[0x432121,0x648ECE];
			 alphas = [0.7,0];
			 ratios = [0x00,0x55];
			matr.createGradientBox(W/5, H, 0,  0);			
			var spreadMethod:String = SpreadMethod.PAD;
			Middle_Fold.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
			Middle_Fold.graphics.drawRect(0,0,W/4,H);
			var lin:Shape = new Shape()
			lin.graphics.lineStyle(2,0x000000,0)
			lin.graphics.moveTo(0,0)
			lin.graphics.lineTo(0,H)
			Middle_Fold.addChild(lin)
			if(PageNumber != 0 ){
			trace('PageNumber == '+PageNumber)
				if(PageNumber % 2 == 0){
			Middle_Fold.x = 0
			
				}else{
					Middle_Fold.scaleX = -1
					Middle_Fold.x = (W );
				}
				Main_mov.addChild(Middle_Fold);
			}
			
			/*L_page_Number.width = 100;
			L_page_Number.height = 20;
			L_page_Number.x = 25;
			L_page_Number.y = H - 18;
			L_page_Number.defaultTextFormat = txt_fmt;
			L_page_Number.embedFonts = true;
			Main_mov.addChild(L_page_Number);*/
			/*L_page_Number.text = PN.toString();
			R_page_Number.width = 100;
			R_page_Number.height = 20;
			R_page_Number.x = W - 30;
			R_page_Number.y = H - 18;
			R_page_Number.defaultTextFormat = txt_fmt;
			R_page_Number.embedFonts = true;
			Main_mov.addChild(R_page_Number);
			R_page_Number.text = (PN + 1).toString();*/
			
			this.addChild(Main_mov);
		}


public function get PageNumbers():int {
 return PageNumber;
}

public function set PageNumbers(value:int):void {
 PageNumber = value;
}
	}

}