package com.debasishalder.book
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import com.debasishalder.book.page;

	public class bookmanager extends MovieClip
	{
		public var UserDefinePageColour:uint = 0xFCFADC;
		private var Pages_Width:Number;
		public var FARRAY:Vector.<Sprite> = new Vector.<Sprite>();
		public var LastPage:String = 'NONE';
		private var Pages_Hieght:Number = 300;
		private var Book_Center_Xpos:Number;
		private var Book_Center_Ypos:Number;
		private var mmc1:Sprite;
		private var mmc2:Sprite;
		private var mmc2nO:Number;
		private var mmc3nO:Number;
		private var mmc1nO:Number;
		public var CurrentPage:Number = 0;
		public var SelectionStatus:String = 'NONE';
		public var CurrentLeftPage:int = -1;
		public var CurrentRightPage:int = 0;
		private var BooksMC:Sprite = new Sprite();
		public var C_Panel:MovieClip;
		public function nextkFlip(e:MouseEvent = null)
		{
			var pgn:int = CurrentRightPage;
			if (C_Panel == null && e != null)
			{
				C_Panel = e.currentTarget.parent;
			}
			PageStepping(pgn,'NEXT');

		}
		public function backFlip(e:MouseEvent = null)
		{
			var pgn:int = CurrentLeftPage;
			if (C_Panel == null && e != null)
			{
				C_Panel = e.currentTarget.parent;
			}
			if (pgn != (-1))
			{
				PageStepping(pgn,'BACK');
			}
		}
		public function bookmanager(PagesWidth:Number,PagesHieght:Number,BookCenterXpos:Number,BookCenterYpos:Number)
		{
			Pages_Width = PagesWidth;
			Pages_Hieght = PagesHieght;
			Book_Center_Xpos = BookCenterXpos;
			Book_Center_Ypos = BookCenterYpos;
			BooksMC.x = Book_Center_Xpos;
			BooksMC.y = Book_Center_Ypos;
			addChild(BooksMC);
		}


		public function MakeFlip(pages:Vector.<Sprite>):void
		{
			BooksMC = new Sprite();
			BooksMC.x = Book_Center_Xpos;
			BooksMC.y = Book_Center_Ypos;
			addChild(BooksMC);
			FARRAY = pages;
			BooksMC.addChild(FARRAY[CurrentPage]);
		}

		public function PageStepping(PageNum:int,RunMode:String ='NEXT' )
		{
			if ( PageNum < FARRAY.length )
			{
				var Page1:int;
				var Page2:int;
				var Page3:int;
				if (RunMode == 'NEXT'  )
				{

					Page1 = PageNum;
					Page2 = PageNum + 1;
					Page3 = PageNum + 2;
				}
				else if (RunMode != 'NEXT' && PageNum > 0 )
				{
					Page1 = PageNum;
					Page2 = PageNum - 1;
					Page3 = PageNum - 2;
				}
				if (Page2  == FARRAY.length && LastPage == 'NONE')
				{
					var PGCOL:String = Object(parent).UserDefinePageColour;
					PGCOL = PGCOL.split('#').join('0x');
					var sextraPage:page = new page(BooksMC.width / 2,BooksMC.height,uint(PGCOL));
					sextraPage.PageNumber = FARRAY.length;
					FARRAY.push(sextraPage);
					LastPage = 'ADDED';
				}
				if (Page2 % 2 != 0 )
				{
					FARRAY[Page2].x =  -  Pages_Width;
					FARRAY[Page2].y = 0;
					BooksMC.addChild(FARRAY[Page2]);
					if (Page3 < FARRAY.length &&  FARRAY[Page3] != null)
					{
						FARRAY[Page3].x = 0;
						FARRAY[Page3].y = 0;
						BooksMC.addChild(FARRAY[Page3]);
					}
				}
				else
				{
					FARRAY[Page2].x = 0;
					FARRAY[Page2].y = 0;
					BooksMC.addChild(FARRAY[Page2]);
					if (FARRAY[Page3] != null)
					{
						FARRAY[Page3].x =  -  Pages_Width;
						FARRAY[Page3].y = 0;
						BooksMC.addChild(FARRAY[Page3]);
					}
				}
				if (BooksMC.contains(FARRAY[Page1]))
				{
					BooksMC.removeChild(FARRAY[Page1]);
				}
				if (RunMode == 'NEXT')
				{
					CurrentRightPage = CurrentRightPage + 2;
					CurrentLeftPage = CurrentRightPage - 1;
				}
				else
				{
					CurrentRightPage = CurrentLeftPage - 1;
					CurrentLeftPage = CurrentLeftPage - 2;
				}
				CurrentPage = PageNum;
				if (CurrentRightPage >= FARRAY.length)
				{
					C_Panel.NextBtn.mouseEnabled = false;
				}
				else
				{
					C_Panel.NextBtn.mouseEnabled = true;
				}
				if (CurrentLeftPage <= 0)
				{
					C_Panel.BackBtn.mouseEnabled = false;
				}
				else
				{
					C_Panel.BackBtn.mouseEnabled = true;
				}
			}
		}

		public function dispose()
		{

			FARRAY = null;
			LastPage = null;
			mmc1 = null;
			mmc2 = null;
			SelectionStatus = null;
			BooksMC = null;
		}
	}

}