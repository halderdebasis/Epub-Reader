package com.debasishalder.epub
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	public class EpubNotification extends Sprite
	{
		private var alertbg:MovieClip;
		private var OKFunction:Function;
		private var CancelFunction:Function;
		private var ColseFunction:Function;
		public function EpubNotification()
		{
		}
		public function makeNotification(BG:Class,titles:String,masg:String,okfunc:Function=null,cncl:Function=null,mxWidth:Number=0,mxHeight:Number=0,closefunc:Function=null)
		{
			OKFunction = okfunc;
			CancelFunction = cncl;
			ColseFunction = closefunc;
			if (((mxWidth != 0) && mxHeight != 0))
			{
				this.graphics.beginFill(0x000000,0.3);
				this.graphics.drawRect(0,0,mxWidth,mxHeight);
				this.graphics.endFill();
			}
			alertbg = new BG  ;
			alertbg.x = (mxWidth - alertbg.width) / 2;
			alertbg.y = (mxHeight - alertbg.height) / 2;
			addChild(alertbg);
			alertbg.title_txt.text = titles;
			alertbg.info_txt.text = masg;
			alertbg.cncl_btn.addEventListener(MouseEvent.CLICK,alrt_Cncl);
			alertbg.ok_btn.addEventListener(MouseEvent.CLICK,alrt_Ok);
			alertbg.cls.addEventListener(MouseEvent.CLICK,alrt_close);
		}



		private function alrt_Ok(e:MouseEvent)
		{

			if ((OKFunction != null))
			{
				OKFunction();
			}
			Object(parent).removeChild(this);
			dispose();
		}
		private function alrt_Cncl(e:MouseEvent)
		{

			if ((CancelFunction != null))
			{
				CancelFunction();
			}
			Object(parent).removeChild(this);
			dispose();
		}
		private function alrt_close(e:MouseEvent)
		{
			if ((ColseFunction != null))
			{
				ColseFunction();
			}
			Object(parent).removeChild(this);
			dispose();
		}
		private function dispose()
		{
			alertbg.cncl_btn.removeEventListener(MouseEvent.CLICK,alrt_Cncl);
			alertbg.ok_btn.removeEventListener(MouseEvent.CLICK,alrt_Ok);
			alertbg.cls.removeEventListener(MouseEvent.CLICK,alrt_Cncl);
			alertbg = null;
			OKFunction = null;
			CancelFunction = null;
			ColseFunction = null;
		}

	}

}