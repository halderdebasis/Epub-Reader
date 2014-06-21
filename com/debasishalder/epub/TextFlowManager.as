package com.debasishalder.epub
{
	import com.debasishalder.book.page;	
	import com.debasishalder.epub.EpubTableManager;
	import learnmath.mathml.formula.MathML;
	import learnmath.mathml.formula.Style;
	import com.debasishalder.ui.LinkIcon;
	import com.debasishalder.event.EpubEvent;
	import com.adobe.CSSFormatResolver;
	import flash.text.StyleSheet;
	import flashx.textLayout.elements.TextFlow;
	import flash.display.Sprite;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.formats.WhiteSpaceCollapse;
	import flashx.textLayout.edit.IEditManager;
	import flashx.textLayout.elements.LinkElement;
	import flash.events.Event;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.conversion.ITextExporter;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.geom.Rectangle;
	import flash.events.EventDispatcher;
	import flash.text.TextField;
	import flashx.textLayout.elements.ParagraphElement;
	import flash.system.System;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.edit.SelectionState;
	import fl.text.TLFTextField;
	import flashx.textLayout.formats.TextDecoration;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.formats.TextLayoutFormat;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import flashx.textLayout.elements.FlowLeafElement;
	import flash.text.engine.TextLine;
	import flashx.textLayout.compose.TextFlowLine;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	public class TextFlowManager extends EventDispatcher
	{
		private var tblmngr:EpubTableManager;
		private var SelectedTLF:TextFlow;
		private var HighLightArray:Vector.<Sprite > ;
		public var selectionState:SelectionState;
		private var SelectedStartIndex:int;
		private var SelectedEndIndex:int;
		private var SelectedFlowIndex:int;
		private var TBLSprite:Vector.<Sprite > ;
		public var TextFlowHolder:Vector.<TextFlow> = new Vector.<TextFlow>();
		private var mathML:MathML;
		private var bookspriteCounter:int = 1;
		private var InLineGraphic:InlineGraphicElement;
		private var LINKTOModify:LinkElement;
		public var PageHolder:Array = new Array();
		public var FormulaArray:Vector.<String > ;
		public var TbaleArray:Vector.<String > ;
		private var GraphicEliment:Array;
		public var CSSSTYLE:StyleSheet;
		public var TEXTFLOW:TextFlow;
		private var WIDTH:Number;
		private var HEIGHT:Number;
		private var LOADERINFO:String;
		private var itemCounter:int;
		private var MATHFORMULAHOLDER:Sprite;
		private var ControllerSprite:Sprite;
		private var TMPTXT:TextField = new TextField();
		private var controllerOne:ContainerController;
		private var StageHeights:Number;
		private var LINKGRAPHIC:LinkIcon;
		private var audiopath:Vector.<String > ;
		private var videopath:Vector.<String > ;
		private var TimeoutID:uint;
		public var ClosingStatus:Boolean = false;
		public function TextFlowManager()
		{
			// constructor code
		}
		public function prepareStyle(css:String)
		{
			if (ClosingStatus)
			{
				return;
			}
			CSSSTYLE = new StyleSheet();
			CSSSTYLE.parseCSS(css);
			css = null;
		}
		public function makeFlow(S:String,W:Number,H:Number,formula:Vector.<String> = null,table:Vector.<String> = null,ldrnfo:String = null,audio:Vector.<String> = null,video:Vector.<String> = null,tlfMode:Boolean = true)
		{
			if (ClosingStatus)
			{
				return;
			}
			WIDTH = W;
			HEIGHT = H;
			TMPTXT.multiline = true;
			if (CSSSTYLE != null)
			{
				TMPTXT.styleSheet = CSSSTYLE;
			}
			TMPTXT.htmlText = S;
			FormulaArray = formula;
			TbaleArray = table;
			LOADERINFO = ldrnfo;
			audiopath = audio;
			videopath = video;
			ControllerSprite = new Sprite();
			PageHolder.push(ControllerSprite);
			controllerOne = new ContainerController(ControllerSprite,WIDTH,HEIGHT);
			if (! tlfMode)
			{
				TEXTFLOW = TextConverter.importToFlow(TMPTXT.htmlText,TextConverter.TEXT_FIELD_HTML_FORMAT);
			}
			else
			{
				TEXTFLOW = TextConverter.importToFlow(TMPTXT.htmlText,TextConverter.TEXT_LAYOUT_FORMAT);
			}
			TEXTFLOW.addEventListener(FlowElementMouseEvent.CLICK,checkLink);
			TextFlowHolder.push(TEXTFLOW);
			if (CSSSTYLE != null)
			{

				TEXTFLOW.formatResolver = new CSSFormatResolver(CSSSTYLE);
			}
			TEXTFLOW.whiteSpaceCollapse = WhiteSpaceCollapse.COLLAPSE;
			TEXTFLOW.flowComposer.addController(controllerOne);
			TEXTFLOW.flowComposer.updateAllControllers();

			GraphicEliment = TEXTFLOW.getElementsByTypeName("a");
			if (GraphicEliment.length > 0 && ! ClosingStatus)
			{
				TimeoutID = setTimeout(AddInlineGraphic,10);
			}
			else if (GraphicEliment.length <=0 && !ClosingStatus)
			{
				TimeoutID = setTimeout(updateController,10);
			}
		}
		public function addSelection(index:int)
		{
			if (ClosingStatus)
			{
				return;
			}
			SelectedFlowIndex = index;
			SelectedTLF = TextFlowHolder[index];
			SelectedTLF.interactionManager = new SelectionManager();
		}
		public function selectionChanged():Boolean
		{
			if (ClosingStatus)
			{
				return false;
			}
			SelectedStartIndex = SelectedTLF.interactionManager.absoluteStart;
			SelectedEndIndex = SelectedTLF.interactionManager.absoluteEnd;
			selectionState = SelectedTLF.interactionManager.getSelectionState();
			SelectedTLF.interactionManager = null;
			if (SelectedStartIndex > 0)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		public function ResetSelection()
		{
			SelectedStartIndex = -1;
			SelectedEndIndex = -1;
			selectionState = null;
			SelectedTLF = null;
		}
		public function internalBookMark(path:String,type:String,closer:Function,chapid:int)
		{
			if (ClosingStatus)
			{
				return;
			}
			SelectedTLF.interactionManager = new EditManager();
			SelectedTLF.interactionManager.selectRange(SelectedStartIndex,SelectedEndIndex);
			var editManager:IEditManager = SelectedTLF.interactionManager as IEditManager;
			var HREF:String = 'event:' + type + '**' + path + '**' + SelectedStartIndex + '**' + SelectedEndIndex + '**' + SelectedFlowIndex + '**' + chapid;
			SelectedTLF.linkNormalFormat = {textDecoration:TextDecoration.NONE};
			editManager.applyLink(HREF,null,false,selectionState);
			var charStyle:TextLayoutFormat = new TextLayoutFormat();
			charStyle.backgroundColor = 0xFF9900;
			charStyle.backgroundAlpha = 1;
			editManager.applyLeafFormat( charStyle );
			SelectedTLF.interactionManager = null;
			if (closer != null)
			{
				closer(exportTLF(SelectedTLF));
			}
			SelectedTLF = null;
			HREF = null;
			editManager = null;
			charStyle = null;
			SelectedStartIndex = -1;
			SelectedEndIndex = -1;
			selectionState = null;
		}
		public function removeBookMark(floind:int,startind:int,endind:int,closer:Function)
		{
			if (ClosingStatus)
			{
				return;
			}
			SelectedTLF = TextFlowHolder[floind];
			SelectedTLF.interactionManager = new EditManager();
			SelectedTLF.interactionManager.selectRange(startind,endind);
			var editManager:IEditManager = SelectedTLF.interactionManager as IEditManager;
			var charStyle:TextLayoutFormat = new TextLayoutFormat();
			charStyle.backgroundAlpha = 0;
			editManager.applyLeafFormat( charStyle );
			editManager.applyLink(null,null,true);
			if (closer != null)
			{
				closer(exportTLF(SelectedTLF));
			}
			charStyle = null;
			SelectedTLF = null;
			editManager = null;
		}
		private function checkLink(e:FlowElementMouseEvent)
		{
			if (ClosingStatus)
			{
				return;
			}

			if (e.flowElement is LinkElement)
			{
				var lnkelm:LinkElement = e.flowElement as LinkElement;
				var lnk:String = lnkelm.href;
				lnk = lnk.split('event:').join('');
				var Arr:Array = lnk.split('**');
				if (Arr[0] == 'text' || Arr[0] == 'image')
				{
					var OOO:Object = new Object();
					OOO.links = Arr[1];
					OOO.types = Arr[0];
					OOO.startindex = Arr[2];
					OOO.endindex = Arr[3];
					OOO.flowindex = Arr[4];
					OOO.chapterindx = Arr[5];
					dispatchEvent(new EpubEvent(EpubEvent.ON_BOOKMARK_CLICK,OOO));
					Arr = null;
					OOO = null;
					lnk = null;
					lnkelm = null;
				}
			}
		}
		public function RemoveHighLight()
		{
			if (ClosingStatus)
			{
				return;
			}
			if (HighLightArray != null)
			{
				for (var s:int  = 0; s < HighLightArray.length; s++)
				{
					var hg:Sprite = HighLightArray[s];
					hg.parent.removeChild(hg);
					HighLightArray[s] = null;
				}
			}
		}
		public function checkForMatchingWord(wordToHighlight:String,floind:int):void
		{
			if (ClosingStatus)
			{
				return;
			}
			RemoveHighLight();
			HighLightArray = null;
			HighLightArray = new Vector.<Sprite>();
			SelectedTLF = TextFlowHolder[floind];
			var currentLeaf:FlowLeafElement = SelectedTLF.getFirstLeaf();
			var currentParagraph:ParagraphElement = currentLeaf ? currentLeaf.getParagraph():null;

			while (currentParagraph && !ClosingStatus)
			{
				var paraStart:uint = currentParagraph.getAbsoluteStart();
				var currWordBoundary:int = 0;
				var nextWordBoundary:int = 0;
				var pattern:RegExp = new RegExp(wordToHighlight,"i");

				while (true && !ClosingStatus)
				{
					nextWordBoundary = currentParagraph.findNextWordBoundary(currWordBoundary);
					if (nextWordBoundary == currWordBoundary)
					{
						break;
					}
					var word:String = '';
					var indexInLeaf:int = currWordBoundary + paraStart - currentLeaf.getAbsoluteStart();
					var wordLen:uint = nextWordBoundary - currWordBoundary;
					while (true && !ClosingStatus)
					{
						var consumeCount:uint = indexInLeaf + wordLen <= currentLeaf.textLength ? wordLen:currentLeaf.textLength - indexInLeaf;
						word +=  currentLeaf.text.substr(indexInLeaf,consumeCount);
						wordLen -=  consumeCount;
						if (! wordLen)
						{
							break;
						}
						currentLeaf = currentLeaf.getNextLeaf();
						indexInLeaf = 0;
					}
					if (pattern.test(word))
					{
						highlightWord(currWordBoundary, nextWordBoundary, word, paraStart);
					}
					currWordBoundary = nextWordBoundary;
				}
				currentLeaf = currentLeaf.getNextLeaf();
				currentParagraph = currentLeaf ? currentLeaf.getParagraph():null;
			}
			currentLeaf = null;
			currentParagraph = null;
		}

		private function highlightWord(begin:int, end:int, word:String, paraStart:int):void
		{
			if (ClosingStatus)
			{
				return;
			}
			var absoluteBegin:int = paraStart + begin;
			var absoluteEnd:int = paraStart + end;
			var startTextFlowLineIndex:int = SelectedTLF.flowComposer.findLineIndexAtPosition(absoluteBegin);
			var endTextFlowLineIndex:int = SelectedTLF.flowComposer.findLineIndexAtPosition(absoluteEnd);
			var txtFlowLine:TextFlowLine = SelectedTLF.flowComposer.getLineAt(startTextFlowLineIndex);
			var txtLine:TextLine = txtFlowLine.getTextLine();
			var startbounds:Rectangle = txtLine.getAtomBounds(txtLine.getAtomIndexAtCharIndex(begin));
			var endbounds:Rectangle = txtLine.getAtomBounds(txtLine.getAtomIndexAtCharIndex(end));
			var box:Sprite = new Sprite();
			var g:Graphics = box.graphics;
			g.beginFill(0xFFFF66, 1);
			g.drawRect(startbounds.left, startbounds.top, (endbounds.x - startbounds.x), startbounds.height);
			box.blendMode = BlendMode.DIFFERENCE;
			txtLine.addChild(box);
			HighLightArray.push(box);
			endbounds = null;
			startbounds = null;
			txtLine = null;
			txtFlowLine = null;
		}
		private function MakeSprite(w:Number,H:Number)
		{
			if (ClosingStatus)
			{
				return;
			}
			var sd:Sprite = new Sprite();
			sd.graphics.beginFill(0xff0000);
			sd.graphics.drawRect(0,0,w,H);
			sd.graphics.endFill();
			return sd;
		}
		private function updateController()
		{
			if (ClosingStatus)
			{
				return;
			}
			clearTimeout(TimeoutID);
			ControllerSprite  = new Sprite();
			controllerOne = new ContainerController(ControllerSprite,WIDTH,HEIGHT);
			TEXTFLOW.flowComposer.addController(controllerOne);
			TEXTFLOW.flowComposer.updateAllControllers();
			if (controllerOne.textLength > 1 && ! ClosingStatus)
			{
				bookspriteCounter++;
				PageHolder.push(ControllerSprite);
				TimeoutID = setTimeout(updateController,10);
			}
			else if (controllerOne.textLength <= 1 && !ClosingStatus)
			{
				TEXTFLOW.flowComposer.removeController(controllerOne);
				TEXTFLOW.flowComposer.updateAllControllers();
				tblmngr = null;
				TBLSprite = null;
				mathML = null;
				InLineGraphic = null;
				LINKTOModify = null;
				FormulaArray = null;
				TbaleArray = null;
				LINKGRAPHIC = null;
				audiopath = null;
				videopath = null;
				System.gc();
				System.gc();
				System.gc();
				System.gc();
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		private function AddInlineGraphic()
		{
			if (ClosingStatus)
			{
				return;
			}
			clearTimeout(TimeoutID);
			if (itemCounter >= GraphicEliment.length  && !ClosingStatus)
			{
				TimeoutID = setTimeout(updateController,10);
				return;
			}
			LINKTOModify = GraphicEliment[itemCounter] as LinkElement;
			var GRAPHICTYPE:String = LINKTOModify.id;
			var cntr:String;
			if (GRAPHICTYPE == 'table' || GRAPHICTYPE == 'formula' || GRAPHICTYPE == 'video' || GRAPHICTYPE == 'audio' )
			{
				var Para:ParagraphElement = LINKTOModify.getParagraph();
				cntr = Para.id;
				if (cntr != null)
				{
					cntr = cntr.split('event:table').join('');
					cntr = cntr.split('formula').join('');
					cntr = cntr.split('table').join('');
					cntr = cntr.split('formula').join('');
					cntr = cntr.split('video').join('');
					cntr = cntr.split('audio').join('');
					if (isNaN(Number(cntr)))
					{
						itemCounter++;
						TimeoutID = setTimeout(AddInlineGraphic,10);
						return;
					}
				}
				Para = null;
			}
			else
			{
				itemCounter++;
				TimeoutID = setTimeout(AddInlineGraphic,10);
				return;
			}
			if (GRAPHICTYPE == 'table')
			{
				var tblstring:String = TbaleArray[Number(cntr)];
				tblmngr = new EpubTableManager();
				tblmngr.addEventListener(Event.COMPLETE,addTable);
				tblmngr.PrepareTable(tblstring,WIDTH - 50);
			}
			else if (GRAPHICTYPE == 'formula')
			{
				MATHFORMULAHOLDER = new Sprite();
				mathML = new MathML(new XML(FormulaArray[Number(cntr)]),'app:/');
				var style = new Style();
				style.size = 25;
				style.mathvariant = "normal";
				style.color = "#000000";
				mathML.drawFormula(MATHFORMULAHOLDER, style, callbackFunct);
			}
			else if (GRAPHICTYPE == 'video')
			{
				LINKGRAPHIC = new LinkIcon();
				LINKGRAPHIC.setType('video');
				LINKGRAPHIC.gcmode = false;
				LINKGRAPHIC.MakeIcon(videopath[Number(cntr)],'Click Hare To Play Video');
				InLineGraphic = new InlineGraphicElement();
				InLineGraphic.source = LINKGRAPHIC;
				LINKTOModify.parent.addChild(InLineGraphic);
				LINKTOModify.parent.removeChild(LINKTOModify);
				TEXTFLOW.flowComposer.updateAllControllers();
				itemCounter++;
				AddInlineGraphic();
				return;
			}
			else if (GRAPHICTYPE == 'audio')
			{
				LINKGRAPHIC = new LinkIcon();
				LINKGRAPHIC.MakeIcon(audiopath[Number(cntr)],'Click Hare To Play Audio');
				InLineGraphic = new InlineGraphicElement();
				InLineGraphic.source = LINKGRAPHIC;
				LINKTOModify.parent.addChild(InLineGraphic);
				LINKTOModify.parent.removeChild(LINKTOModify);
				TEXTFLOW.flowComposer.updateAllControllers();
				itemCounter++;
				AddInlineGraphic();
				return;
			}
		}
		private function addTable(e:Event)
		{
			if (ClosingStatus)
			{
				return;
			}
			TBLSprite = tblmngr.getTableSprite();
			for (var s:int = 0; s < TBLSprite.length; s++)
			{
				InLineGraphic = new InlineGraphicElement();
				InLineGraphic.source = TBLSprite[s];
				InLineGraphic.graphic;
				InLineGraphic.paddingTop = -20;
				InLineGraphic.paddingBottom = -20;
				LINKTOModify.parent.addChild(InLineGraphic);
				TEXTFLOW.flowComposer.updateAllControllers();
			}
			LINKTOModify.parent.removeChild(LINKTOModify);
			TEXTFLOW.flowComposer.updateAllControllers();
			itemCounter++;
			AddInlineGraphic();
		}

		private function callbackFunct(r:Rectangle)
		{
			if (ClosingStatus)
			{
				return;
			}
			if (r.top < 0)
			{

				MATHFORMULAHOLDER.y = Math.abs(r.top);
			}
			else if (r.top > 0)
			{
				MATHFORMULAHOLDER.y = 0;
			}
			InLineGraphic = new InlineGraphicElement();
			InLineGraphic.source = MATHFORMULAHOLDER;
			LINKTOModify.parent.addChild(InLineGraphic);
			LINKTOModify.parent.removeChild(LINKTOModify);
			TEXTFLOW.flowComposer.updateAllControllers();
			itemCounter++;
			AddInlineGraphic();
			r = null;
		}
		public function exportTLF(txtlow:TextFlow = null):String
		{
			if (ClosingStatus)
			{
				return null;
			}
			var exporter:ITextExporter = TextConverter.getExporter(TextConverter.TEXT_LAYOUT_FORMAT);
			var str:String = exporter.export(txtlow,ConversionType.STRING_TYPE) as String;
			exporter = null;
			var TAGRegExp:RegExp = /\<[^\/]*?p\s\id="(formula\d+)\"(.*?)>(.*?)<\s*?\/\s*?p\s*?>/ig;
			str = str.replace(TAGRegExp,'<p id="$1"><a href="event:formula" id ="formula"> </a></p>');
			TAGRegExp = null;
			TAGRegExp = /\<[^\/]*?p\s\id="(table\d+)\"(.*?)>(.*?)<\s*?\/\s*?p\s*?>/ig;
			str = str.replace(TAGRegExp,'<p id="$1"><a href="event:table" id ="table"> </a></p>');
			TAGRegExp = null;
			TAGRegExp = /\<[^\/]*?p\s\id="(audio\d+)\"(.*?)>(.*?)<\s*?\/\s*?p\s*?>/ig;
			str = str.replace(TAGRegExp,'<p id="$1"><a href="event:audio" id ="audio"> </a></p>');
			TAGRegExp = null;
			TAGRegExp = /\<[^\/]*?p\s\id="(video\d+)\"(.*?)>(.*?)<\s*?\/\s*?p\s*?>/ig;
			str = str.replace(TAGRegExp,'<p id="$1"><a href="event:video" id ="video"> </a></p>');
			str = str.split('<a href="event:text**').join('<a id="bookmark" href="event:text**');
			str = str.split('<a href="event:image**').join('<a id="bookmark" href="event:image**');
			TAGRegExp = null;
			return str;
		}
		public function dispose()
		{
			clearTimeout(TimeoutID);
			if (tblmngr != null)
			{
				tblmngr.removeEventListener(Event.COMPLETE,addTable);
			}
			for (var d:int =0; d < TextFlowHolder.length; d++)
			{
				TextFlowHolder[d].removeEventListener(FlowElementMouseEvent.CLICK,checkLink);
				TextFlowHolder[d] = null;
			}
			tblmngr = null;
			SelectedTLF = null;
			HighLightArray = null;
			selectionState = null;
			TBLSprite = null;
			TextFlowHolder = null;
			mathML = null;
			InLineGraphic = null;
			LINKTOModify = null;
			PageHolder = null;
			FormulaArray = null;
			TbaleArray = null;
			GraphicEliment = null;
			CSSSTYLE = null;
			TEXTFLOW = null;
			LOADERINFO = null;
			MATHFORMULAHOLDER = null;
			ControllerSprite = null;
			TMPTXT = null;
			controllerOne = null;
			LINKGRAPHIC = null;
			audiopath = null;;
			videopath = null;;
		}
	}

}