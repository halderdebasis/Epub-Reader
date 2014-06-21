package com.debasishalder.book
{
	import com.debasishalder.epub.OPFManager;
	import com.debasishalder.epub.CSSManager;
	import com.debasishalder.epub.Unpacker;
	import com.debasishalder.epub.TextFlowManager;
	import com.debasishalder.book.page;
	import flash.utils.setTimeout;
	import com.debasishalder.book.bookmanager;
	import com.debasishalder.epub.HTMLManager;
	import com.debasishalder.epub.TextFlowManager;
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.system.System;
	import flash.events.Event;
	import com.debasishalder.utility.SQLiteDBSearch;
	import com.debasishalder.epub.EpubNotification;
	import flash.events.MouseEvent;
	import com.debasishalder.ui.contextmenuPopup;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import com.debasishalder.event.EpubEvent;
	import flash.net.FileFilter;

	public class bookmaker extends Sprite
	{
		private var tmp:File;
		private var ChapterTitle:String = '';
		private var SelectedChapterIndex:int = -1;
		private var BookmarkPath:String;
		private var Context_Menu:contextmenuPopup;
		private var SQLUTILITY:SQLiteDBSearch;
		public const tblcol:int = 5;
		public const fromcol:int = 4;
		public const audpthcol:int = 6;
		public const vidpthcol:int = 7;
		public const chptrtxtcol:int = 2;
		public const chptridcol:int = 3;
		public const chptrnamecol:int = 1;
		public const csscol:int = 8;
		private var Bookmarktype:String;
		private var Bookmarkpath:String;
		private var BookmarkStartIndex:String;
		private var BookmarkEndIndex:String;
		private var BookmarkFlowIndex:String;
		private var _pages:Vector.<Sprite> = new Vector.<Sprite>();
		public var FLIPHolder:Sprite = new Sprite();
		private var bookspriteCounter:int = 1;
		private var TXTFLO:TextFlowManager;
		private var HTMLMANAGER:HTMLManager;
		private var isTLF:Boolean = false;
		private var PagesCounter:int = 0;
		private var unpacker:Unpacker;
		private var EXTRCTString:String;
		private var isFirstTime:Boolean = true;
		private var CSSSTring = '';
		private var OPFDirectory:String;
		private var OPF:OPFManager;
		private var AllPages:Vector.<String > ;
		private var AllCSS:Vector.<String > ;
		private var sd:System;
		private var CSSMANAGER:CSSManager;
		private var Filename:String;
		private var mediaStorage:String;
		private var MediaCounter:int;
		private var HTMLSTRING:String;
		private var PageWidth:Number;
		private var PageHeight:Number;
		public var ALERTCLASS:Class;
		public var e_book:bookmanager;
		public var UserDefinePageColour:uint = 0xFCFADC;
		public var TableStringArray:Vector.<String > ;
		public var FormulaStringArray:Vector.<String > ;
		private var VideoStringArray:Vector.<String > ;
		private var AudioStringArray:Vector.<String > ;
		private var ImageStringArray:Vector.<String > ;
		private var ObjectStringArray:Vector.<String > ;
		private var VideoSourceStringArray:Vector.<String > ;
		private var AudioSourceStringArray:Vector.<String > ;
		public const newdbString:String = " CREATE TABLE IF NOT EXISTS epub (id INTEGER  PRIMARY KEY AUTOINCREMENT, chaptername TEXT, chaptertext TEXT, chapterid INTEGER UNIQUE, formula TEXT, htmltable TEXT, audiopath TEXT, videopath TEXT, csstext TEXT);";
		private var LastWorkingPage:int = 0;
		private var OuterPageW:Number;
		private var OuterPageH:Number;
		private var padding:Number = 50;
		private var LDRINFO:String;
		private var isTableCreated:Boolean = false;
		private var alert:EpubNotification;
		private var isBookLoaded:Boolean = false;
		private var ToTalPages:int;
		private var FilePath:String;
		private var bookmarkstorePath:String;
		private var ClosingStatus:Boolean = false;
		public function bookmaker()
		{
		}
		private function showalert(titles:String,msg:String)
		{
			if (ALERTCLASS != null)
			{
				alert = new EpubNotification();
				alert.makeNotification(ALERTCLASS,titles,msg,null,null,stage.stageWidth,stage.stageHeight);
				addChild(alert);
			}
		}
		public function init(zipsource:String,loadrinfo:String = null,isLoaded:Boolean = false)
		{
			LDRINFO = loadrinfo;
			OuterPageW = (stage.stageWidth/2);
			OuterPageH = (stage.stageHeight);
			PageWidth = OuterPageW - (padding * 2);
			PageHeight = OuterPageH - (padding * 2);
			FilePath = zipsource;
			e_book = new bookmanager(OuterPageW,OuterPageH,OuterPageW,0);
			addChild(e_book);
			isBookLoaded = isLoaded;
			if (isBookLoaded)
			{
				isTLF = true;
				return;
			}
			tmp = new File(zipsource);
			Filename = tmp.name;
			Filename = Filename.split('.'+tmp.extension).join('');
			var fls:File = File.documentsDirectory;
			mediaStorage = fls.url;
			fls = null;
			mediaStorage +=  '/preference/' + Filename + '/';
			var medfile:File = new File(mediaStorage);
			if (! medfile.exists)
			{
				medfile.createDirectory();
			}
			BookmarkPath = mediaStorage;
			var DBFILE:String = mediaStorage + Filename + '.db';
			SQLUTILITY = new SQLiteDBSearch(DBFILE,showalert)
			;
		}
		public function unpack()
		{
			if (ClosingStatus)
			{
				return;
			}
			if (isBookLoaded)
			{
				playLoadedBook(FilePath);
				return;
			}
			else
			{
				unpacker = new Unpacker(tmp.url,mediaStorage);
				var MetaInfXml:XML = new XML(unpacker.extractString('META-INF/container.xml'));
				var opfFileName:String = MetaInfXml.children()[0].children()[0].attribute("full-path");
				OPFDirectory = opfFileName.substr(0,opfFileName.lastIndexOf('/') + 1);
				System.disposeXML(MetaInfXml);
				MetaInfXml = null;
				var OPFXML:XML = new XML(unpacker.extractString(opfFileName));
				OPF = new OPFManager();
				OPF.setOPF(OPFXML);
				OPF.getOPF();
				AllPages = OPF.getAllPages();
				ToTalPages = AllPages.length;
				AllCSS = OPF.getAllCSS();
				System.disposeXML(OPFXML);
				OPFXML = null;
				setTimeout(extracAllCss,10);
			}
		}
		public function extracAllCss()
		{
			if (ClosingStatus)
			{
				return;
			}
			if (PagesCounter < AllCSS.length)
			{
				CSSSTring += unpacker.extractString(OPFDirectory+AllCSS[PagesCounter]);
				PagesCounter++;
				extracAllCss();
			}
			else
			{
				setTimeout(prepareCSS,10);
			}
		}
		private function prepareCSS()
		{
			if (ClosingStatus)
			{
				return;
			}

			PagesCounter = 0;
			CSSMANAGER = new CSSManager();
			CSSMANAGER.addEventListener(Event.COMPLETE,finilizeCSS);
			CSSMANAGER.ManageCSS(CSSSTring);
		}
		private function finilizeCSS(e:Event)
		{
			if (ClosingStatus)
			{
				return;
			}
			CSSMANAGER.removeEventListener(Event.COMPLETE,finilizeCSS);
			CSSSTring = CSSMANAGER.getCSS();
			CSSMANAGER.dispose();
			CSSMANAGER = null;
			if (! isTableCreated)
			{
				SQLUTILITY.WriteStatement(newdbString,storecss,true,errors);
				isTableCreated = true;
			}
			else
			{
				storecss();
			}
		}
		private function storecss()
		{
			if (ClosingStatus)
			{
				return;
			}
			var sql:String = "INSERT OR REPLACE  INTO epub (csstext,chapterid)VALUES('" + CSSSTring + "','0')";
			SQLUTILITY.WriteStatement(sql,startHTMLextraction,true,errors);
			sql = null;
		}
		private function startHTMLextraction()
		{
			if (ClosingStatus)
			{
				return;
			}
			HTMLMANAGER = new HTMLManager();
			extractpage();
		}
		public function extractpage()
		{
			if (ClosingStatus)
			{
				return;
			}
			if (PagesCounter < ToTalPages)
			{
				EXTRCTString = unpacker.extractString(OPFDirectory+AllPages[PagesCounter]);
				PagesCounter++;
				setTimeout(manageHTML,20);
			}
			else
			{

				trace('epubLoadComplete');
			}

		}
		private function manageHTML()
		{
			if (ClosingStatus)
			{
				return;
			}
			HTMLMANAGER.manageHTML(EXTRCTString,mediaStorage);
			HTMLSTRING = HTMLMANAGER.getHTML();
			TableStringArray = null;
			ImageStringArray = null;
			FormulaStringArray = null;
			VideoStringArray = null;
			AudioStringArray = null;
			ObjectStringArray = null;
			TableStringArray = HTMLMANAGER.getTable();
			ImageStringArray = HTMLMANAGER.getImageSource();
			FormulaStringArray = HTMLMANAGER.getFormula();
			VideoStringArray = HTMLMANAGER.getVideoSource();
			AudioStringArray = HTMLMANAGER.getAudioSource();
			ObjectStringArray = HTMLMANAGER.getObjectSource();
			VideoSourceStringArray = HTMLMANAGER.getVideoPath();
			AudioSourceStringArray = HTMLMANAGER.getAudioPath();
			ChapterTitle = HTMLMANAGER.PageTitle;
			ChapterTitle = ChapterTitle.split("'").join("`");
			setTimeout(extractImg,10);
		}
		private function extractImg()
		{
			if (ClosingStatus)
			{
				return;
			}
			if (MediaCounter< ImageStringArray.length)
			{
				unpacker.addEventListener(Event.COMPLETE,CheckAnotherImg);
				unpacker.extractFiles(OPFDirectory+ImageStringArray[MediaCounter]);
			}
			else
			{

				MediaCounter = 0;
				setTimeout(extractObj,10);
			}
		}
		private function CheckAnotherImg(e:Event)
		{
			if (ClosingStatus)
			{
				return;
			}
			unpacker.removeEventListener(Event.COMPLETE,CheckAnotherImg);
			MediaCounter++;
			if (MediaCounter< ImageStringArray.length)
			{
				setTimeout(extractImg,10);
			}
			else
			{
				MediaCounter = 0;
				setTimeout(extractObj,10);
			}
		}
		private function extractObj()
		{
			if (ClosingStatus)
			{
				return;
			}
			if (MediaCounter< ObjectStringArray.length)
			{
				unpacker.addEventListener(Event.COMPLETE,CheckAnotherObj);
				unpacker.extractFiles(OPFDirectory+ObjectStringArray[MediaCounter]);
			}
			else
			{
				MediaCounter = 0;
				setTimeout(extractAud,10);
			}
		}

		private function CheckAnotherObj(e:Event)
		{
			if (ClosingStatus)
			{
				return;
			}
			unpacker.removeEventListener(Event.COMPLETE,CheckAnotherObj);
			MediaCounter++;
			if (MediaCounter< ObjectStringArray.length)
			{
				setTimeout(extractObj,10);
			}
			else
			{
				MediaCounter = 0;
				setTimeout(extractAud,10);
			}
		}
		private function extractAud()
		{
			if (ClosingStatus)
			{
				return;
			}
			if (MediaCounter< AudioStringArray.length)
			{
				unpacker.addEventListener(Event.COMPLETE,CheckAnotherAud);
				unpacker.extractFiles(OPFDirectory+AudioStringArray[MediaCounter]);
			}
			else
			{
				MediaCounter = 0;
				setTimeout(extractVid,10);
			}
		}
		private function CheckAnotherAud(e:Event)
		{
			if (ClosingStatus)
			{
				return;
			}
			unpacker.removeEventListener(Event.COMPLETE,CheckAnotherAud);
			MediaCounter++;
			if (MediaCounter< AudioStringArray.length)
			{
				setTimeout(extractAud,10);
			}
			else
			{
				MediaCounter = 0;
				setTimeout(extractVid,10);
			}
		}
		private function extractVid()
		{
			if (ClosingStatus)
			{
				return;
			}
			if (MediaCounter< VideoStringArray.length)
			{
				unpacker.addEventListener(Event.COMPLETE,CheckAnotherVid);
				unpacker.extractFiles(OPFDirectory+VideoStringArray[MediaCounter]);
			}
			else
			{
				MediaCounter = 0;
				setTimeout(prepareFlow,10);
			}
		}
		private function CheckAnotherVid(e:Event)
		{
			if (ClosingStatus)
			{
				return;
			}
			unpacker.removeEventListener(Event.COMPLETE,CheckAnotherVid);
			MediaCounter++;
			if (MediaCounter< VideoStringArray.length)
			{
				setTimeout(extractVid,10);
			}
			else
			{
				MediaCounter = 0;
				setTimeout(prepareFlow,10);
			}
		}
		private function prepareFlow()
		{
			if (ClosingStatus)
			{
				return;
			}
			if (TXTFLO == null)
			{
				TXTFLO = new TextFlowManager();
				TXTFLO.addEventListener(EpubEvent.ON_BOOKMARK_CLICK,checkBookMark);
			}
			if (TXTFLO.CSSSTYLE == null)
			{
				TXTFLO.prepareStyle(CSSSTring);
			}
			TXTFLO.addEventListener(Event.COMPLETE,extractAnotherHTML);
			TXTFLO.makeFlow(HTMLSTRING,PageWidth,PageHeight,FormulaStringArray,TableStringArray,loaderInfo.url,AudioSourceStringArray,VideoSourceStringArray,isTLF);
		}
		private function checkBookMark(e:EpubEvent)
		{
			if (ClosingStatus)
			{
				return;
			}
			Bookmarktype = e.ITEM.types;
			Bookmarkpath = e.ITEM.links;
			BookmarkStartIndex = e.ITEM.startindex;
			BookmarkEndIndex = e.ITEM.endindex;
			BookmarkFlowIndex = e.ITEM.flowindex;
			SelectedChapterIndex = e.ITEM.chapterindx;
			Context_Menu = new contextmenuPopup();
			Context_Menu.makepopup(contxbg,['Open Bookmark','Delete Bookmark','Cancel'],afterBookmarkClick,stage.stageWidth,stage.stageHeight);
			addChild(Context_Menu);
		}
		private function afterBookmarkClick(s:String)
		{
			if (ClosingStatus)
			{
				return;
			}
			if (s == 'Open Bookmark')
			{
				if (Bookmarktype == 'text')
				{
					trace('need to add text viewer');
				}
				else if (Bookmarktype == 'image')
				{
					trace('need to add image viewer');
				}
			}
			else if (s == 'Delete Bookmark')
			{
				TXTFLO.removeBookMark(Number(BookmarkFlowIndex),Number(BookmarkStartIndex),Number(BookmarkEndIndex),updateDBAfterBookmark);
			}

		}
		private function extractAnotherHTML(e:Event)
		{
			if (ClosingStatus)
			{
				return;
			}
			var flowindex:int = TXTFLO.TextFlowHolder.length - 1;
			if (LastWorkingPage < TXTFLO.PageHolder.length)
			{
				for (var s:int = LastWorkingPage; s < TXTFLO.PageHolder.length; s++)
				{
					var SP:Sprite = new Sprite();
					var pgBg:page = new page(OuterPageW,OuterPageH,UserDefinePageColour,(LastWorkingPage));
					pgBg.TextFlowIndex = flowindex;
					pgBg.ChapterId = PagesCounter;
					pgBg.ChapterName = ChapterTitle;
					pgBg.name = "PageBg";
					SP.addChild(pgBg);
					var inp:Sprite = TXTFLO.PageHolder[s] as Sprite;
					inp.x = padding;
					inp.y = padding;
					SP.addChild(inp);
					_pages.push(SP);
					LastWorkingPage++;
				}
			}
			if (! isBookLoaded)
			{
				if (! isTableCreated)
				{
					SQLUTILITY.WriteStatement(newdbString,storedata,true,errors);
					isTableCreated = true;
				}
				else
				{
					storedata();
				}
			}
			else
			{
				anotherExtraction();
			}

		}
		private function errors(e:Error = null)
		{
			if (ClosingStatus)
			{
				return;
			}
			var msg:String;
			if (e != null)
			{
				msg = e.message;
			}
			else
			{
				msg = 'An Error on storing data';
			}
			showalert('Error',msg);
		}
		private function storedata()
		{
			if (ClosingStatus)
			{
				return;
			}
			var chptrTxt:String = TXTFLO.exportTLF(TXTFLO.TEXTFLOW);
			chptrTxt = chptrTxt.split("'").join("`");
			var frmlTxt:String = '';
			var tbltext:String = '';
			var vidtext:String = '';
			var audtext:String = '';
			if (FormulaStringArray.length > 0)
			{
				frmlTxt = FormulaStringArray.join('*-*-*');
			}

			if (TableStringArray.length > 0)
			{
				tbltext = TableStringArray.join('*-*-*');
			}
			if (VideoSourceStringArray.length > 0)
			{
				vidtext = VideoSourceStringArray.join('*-*-*');
			}
			if (AudioSourceStringArray.length > 0)
			{
				audtext = AudioSourceStringArray.join('*-*-*');
			}
			var SQL:String = "INSERT OR REPLACE INTO epub (chaptername,chaptertext,chapterid,formula,htmltable,audiopath,videopath) VALUES('" + ChapterTitle + "','" + chptrTxt + "','" + PagesCounter + "','" + frmlTxt + "','" + tbltext + "','" + audtext + "','" + vidtext + "')";
			SQLUTILITY.WriteStatement(SQL,anotherExtraction,true,errors);
			SQL = null;
		}
		private function anotherExtraction()
		{
			CSSSTring = null;
			VideoSourceStringArray = null;
			AudioSourceStringArray = null;
			TableStringArray = null;
			ImageStringArray = null;
			FormulaStringArray = null;
			VideoStringArray = null;
			AudioStringArray = null;
			ObjectStringArray = null;
			System.gc();
			System.gc();
			System.gc();
			System.gc();
			System.gc();
			if (isFirstTime)
			{
				e_book.MakeFlip(_pages);
			}
			if (! isBookLoaded)
			{
				setTimeout(extractpage,10);
			}
			else
			{
				extractStringFromdb();
			}
			isFirstTime = false;
		}
		public function matchWordintoflow(e:MouseEvent)
		{
			var searchstr:String = e.currentTarget.parent.searchinput_txt.text;
			if (searchstr != '')
			{
				var currentPageSprite:Sprite = _pages[e_book.CurrentPage];
				var pg:* = currentPageSprite.getChildByName('PageBg');
				var floindx:int = pg.TextFlowIndex;
				TXTFLO.checkForMatchingWord(searchstr,floindx);
				searchstr = null;
				pg = null;
			}
		}
		public function prepareForSelect(e:MouseEvent)
		{
			var currentPageSprite:Sprite = _pages[e_book.CurrentPage];
			var pg:* = currentPageSprite.getChildByName('PageBg');
			var floindx:int = pg.TextFlowIndex;
			SelectedChapterIndex = pg.ChapterId;
			e_book.SelectionStatus = 'YES';
			stage.addEventListener(MouseEvent.MOUSE_UP,checkSelectionStat);
			TXTFLO.addSelection(floindx);
			currentPageSprite = null;
			pg = null
			 ;
		}
		private function checkSelectionStat(e:MouseEvent)
		{

			stage.removeEventListener(MouseEvent.MOUSE_UP,checkSelectionStat);
			e_book.SelectionStatus = 'NONE';
			TXTFLO.selectionChanged();
			Context_Menu = new contextmenuPopup();
			Context_Menu.makepopup(contxbg,['Bookmark With TextPad','Bookmark With DrawingPad','Cancel'],afterUserChoice,stage.stageWidth,stage.stageHeight);
			addChild(Context_Menu);
		}
		private function afterUserChoice(s:String = null)
		{
			var dt:Date = new Date();
			if (s == 'Bookmark With TextPad')
			{
				trace('need to add a text editor');
				bookmarkstorePath = BookmarkPath + dt.time + '.txt';
			}
			else if (s == 'Bookmark With DrawingPad')
			{
				bookmarkstorePath = BookmarkPath + dt.time + '.jpg';
			}
		}
		private function makeBookmark(type:String)
		{

			if (type == 'text')
			{
				trace('need to add a text viewer');
			}
			TXTFLO.internalBookMark(bookmarkstorePath,type,updateDBAfterBookmark,SelectedChapterIndex);
		}
		private function updateDBAfterBookmark(ss:String)
		{
			ss = ss.split("'").join("`");
			var sql:String = "UPDATE epub SET chaptertext = '" + ss + "' WHERE chapterid = '" + SelectedChapterIndex + "'";
			SQLUTILITY.WriteStatement(sql,null,true);
			sql = null;
		}
		public function playLoadedBook(path:String)
		{
			BookmarkPath = path.substring(0,path.lastIndexOf('/'));
			BookmarkPath +=  '/';
			SQLUTILITY = new SQLiteDBSearch(path,showalert);
			var csssql:String = "id='1'";
			SQLUTILITY.SearchConditionalData('epub','csstext',csssql);
			CSSSTring = SQLUTILITY.getResult();
			SQLUTILITY.SelectMax('epub','chapterid');
			var tt:Array = SQLUTILITY.getResult();
			ToTalPages = (Number(tt[0]) - 1);
			extractStringFromdb();
		}
		private function extractStringFromdb():void
		{
			if (PagesCounter >= ToTalPages)
			{
				trace('Load Complete');
				return;
			}
			var csssql:String = "chapterid='"+String(Number(PagesCounter+1))+"'";
			SQLUTILITY.SearchConditionalData('epub',null,csssql);
			var rslt:Array = SQLUTILITY.getResult();
			HTMLSTRING = rslt[0][chptrtxtcol];
			if (HTMLSTRING == null || HTMLSTRING == '')
			{
				PagesCounter++;
				extractStringFromdb();
				return;
			}
			var tbltxt:String = rslt[0][tblcol];
			var frmltxt:String = rslt[0][fromcol];
			var audtxt:String = rslt[0][audpthcol];
			var vidtxt:String = rslt[0][vidpthcol];
			FormulaStringArray = stringToVector(frmltxt);
			frmltxt = null;
			TableStringArray = stringToVector(tbltxt);
			tbltxt = null;
			VideoSourceStringArray = stringToVector(vidtxt);
			AudioSourceStringArray = stringToVector(audtxt);
			PagesCounter++;
			setTimeout(prepareFlow,10);
		}
		private function stringToVector(SS:String)
		{
			var sfg:Vector.<String> = new Vector.<String>();
			if (SS == null || SS =='')
			{
				return sfg;
			}
			var arr:Array = SS.split('*-*-*');
			for (var g:int = 0; g < arr.length; g++)
			{
				sfg.push(arr[g]);
			}
			arr = null;
			return sfg;
		}
	}
}