package com.debasishalder.epub
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.events.EventDispatcher;
	import flash.events.Event;

	public class EpubTableManager extends EventDispatcher
	{	private var tableXML:XML;
		private var TblObject:Object;
		private var TableObjectsArray:Array;
		private var TotalCol:int = 0;
		private var tablewidth:Number;
		private var tableHeight:Number;
		private var maxCellWIDTH:Number = -1;
		private var CellSpace:Number;
		private var TableBorder:Number;
		private var TotalCellWidth:Number = 0;
		private var cellWidthArray:Array = new Array  ;
		private var RowHeightArr:Array = new Array  ;
		private var TableSprite:Sprite;
		private var MaxWIDTH:Number;
		private var isTableResize:Boolean = false;
		private var TableSpriteArray:Vector.<Sprite > ;
		public function EpubTableManager()
		{
			// constructor code
		}

		public function PrepareTable(xml:String,MAXWidth:Number)
		{
			try
			{
				tableXML = new XML(xml);
			}
			catch (e:Error)
			{
				TableSpriteArray = new Vector.<Sprite >()   ;
				dispatchEvent(new Event(Event.COMPLETE));
			}
			MaxWIDTH = MAXWidth;
			TableSprite = new Sprite  ;
			TblObject = new Object  ;
			for (var i:int = 0; i < tableXML.attributes().length(); i++)
			{
				TblObject[String(tableXML.attributes()[i].name()).toUpperCase()] = tableXML.attributes()[i];

			}

			CellSpace = TblObject.CELLSPACING;
			TableBorder = TblObject.BORDER;
			tablewidth = TblObject.WIDTH;
			tableHeight = TblObject.HEIGHT;
			if ((isNaN(tablewidth) || tablewidth > MaxWIDTH))
			{
				tablewidth = MaxWIDTH;
				isTableResize = true;
			}
			MakeTblObjectArr();
		}

		private function MakeTblObjectArr()
		{
			TableObjectsArray = new Array  ;
			for (var i:int = 0; i < tableXML.tr.length() && tableXML.tr.length() > 0; i++)
			{

				var TD:Array = new Array  ;
				for (var j:int = 0; j < tableXML.tr[i].td.length() && tableXML.tr[i].td.length() > 0; j++)
				{
					TotalCol = Math.max(TotalCol,tableXML.tr[i].td.length());
					var TDOBJ:Object = new Object  ;
					TDOBJ.strings = tableXML.tr[i].td[j];
					TDOBJ.TYPE = 'active';
					var CW:Number = 0;
					if (tableXML.tr[i].td[j].attributes().length() > 0)
					{
						for (var k:int = 0; k < tableXML.tr[i].td[j].attributes().length() && tableXML.tr[i].td[j].attributes().length() > 0; k++)
						{
							TDOBJ[String(tableXML.tr[i].td[j].attributes()[k].name()).toUpperCase()] = tableXML.tr[i].td[j].attributes()[k];
							var NN:Number = TDOBJ.WIDTH;
							trace(('NN =' + NN));
							if (isNaN(NN))
							{
								NN = 0;
							}



							cellWidthArray[j] = Math.max(CW,NN);

							CW = NN;
						}
					}
					else
					{
						if (cellWidthArray[j] == undefined)
						{
							cellWidthArray[j] = 0;
						}

					}
					TD.push(TDOBJ);
				}

				TableObjectsArray.push(TD);
			}
			var zeroCellCount:int = 0;
			for (var p:int = 0; p < cellWidthArray.length; p++)
			{
				TotalCellWidth +=  cellWidthArray[p];
				if (cellWidthArray[p] == 0)
				{

					zeroCellCount++;
				}
			}
			if (isNaN(TotalCellWidth))
			{
				TotalCellWidth = 0;
			}
			for (var q:int = 0; q < cellWidthArray.length; q++)
			{
				if (cellWidthArray[q] == 0)
				{
					cellWidthArray[q] = (tablewidth - TotalCellWidth) / zeroCellCount;
				}
			}
			maketbl();
		}
		private function MakeTxt(X:Number,Y:Number,tx:String,W:Number,BG,Align,BORDER:Number)
		{
			var TF:TextFormat = new TextFormat  ;
			TF.font = 'Arial';
			TF.size = 20;
			var Txt:TextField = new TextField  ;
			Txt.wordWrap = true;
			Txt.multiline = true;
			Txt.condenseWhite = true;
			Txt.selectable = false;
			Txt.autoSize = TextFieldAutoSize.LEFT;
			Txt.width = W;
			Txt.x = X;
			Txt.y = Y;
			if ((Align != undefined))
			{

				TF.align = String(Align).toLowerCase();

			}
			Txt.defaultTextFormat = TF;
			Txt.htmlText = tx;
			Txt.border = true;
			Txt.thickness = 25;
			if ((BG != undefined))
			{
				if (BG.indexOf('#') == -1)
				{

				}
				else
				{
					BG = BG.split('#').join('0x');
				}
				Txt.background = true;
				Txt.backgroundColor = uint(BG);
			}

			return Txt;
		}
		private function GetX(II:int)
		{
			var DD:Number = 0;
			if (isNaN(CellSpace))
			{
				CellSpace = 0;
			}
			for (var j:int = 0; j < II; j++)
			{
				DD +=  Number(cellWidthArray[j] + CellSpace);
			}
			return DD;
		}
		private function getWidthAcordingColspan(index:int,ColSpan:int):Number
		{

			var W:Number = 0;
			if ((ColSpan <= 1))
			{
				W = cellWidthArray[index];
			}
			else
			{
				for (var k:int = index; k < index + ColSpan; k++)
				{
					W +=  cellWidthArray[k];
					if ((k < (index + ColSpan) - 1))
					{
						W +=  CellSpace;
					}
				}
			}
			return W;

		}

		private function maketbl()
		{

			var YY:Number = 0;

			for (var j:int = 0; j < TableObjectsArray.length; j++)
			{
				var H:Number = 0;
				for (var k:int = 0; k < TableObjectsArray[j].length; k++)
				{

					var RN:int = TableObjectsArray[j][k].ROWSPAN;
					if ((RN > 1))
					{
						for (var r:int = 1; r < RN; r++)
						{
							var OO:Object = new Object  ;
							OO.TYPE = 'blank';
							OO.strings = 'NONE';
							TableObjectsArray[Number((j + r))].splice(k,0,OO);

						}
					}

					if (TableObjectsArray[j][k].TYPE != 'blank')
					{
						TableObjectsArray[j][k].CELL = MakeTxt(GetX(k),YY,TableObjectsArray[j][k].strings,getWidthAcordingColspan(k,TableObjectsArray[j][k].COLSPAN),TableObjectsArray[j][k].BGCOLOR,TableObjectsArray[j][k].ALIGN,TableBorder);
						TableSprite.addChild(TableObjectsArray[j][k].CELL);
						H = Math.max(H,TableObjectsArray[j][k].CELL.height);
					}

				}
				RowHeightArr.push(H);
				YY +=  H + CellSpace;
			}

			FinalizeTable();
		}
		private function GetHeight(index:int,RowSpan:int):Number
		{

			var W:Number = 0;
			if ((RowSpan <= 1))
			{
				W = RowHeightArr[index];
			}
			else
			{
				for (var k:int = index; k < index + RowSpan; k++)
				{
					W +=  RowHeightArr[k];
					if ((k < (index + RowSpan) - 1))
					{
						W +=  CellSpace;
					}
				}
			}
			return W;
		}
		public function getTable():Sprite
		{
			return TableSprite;
		}
		public function getTableSprite():Vector.<Sprite > 
		{
			return TableSpriteArray;
		}
		private function FinalizeTable()
		{
			TableSpriteArray = new Vector.<Sprite >()   ;
			for (var j:int = 0; j < TableObjectsArray.length; j++)
			{
				var hldrSprt:Sprite = new Sprite  ;
				TableSpriteArray.push(hldrSprt);
				for (var k:int = 0; k < TableObjectsArray[j].length; k++)
				{
					if (TableObjectsArray[j][k].TYPE != 'blank')
					{
						TableObjectsArray[j][k].CELL.autoSize = TextFieldAutoSize.NONE;
						TableObjectsArray[j][k].CELL.height = GetHeight(j,TableObjectsArray[j][k].ROWSPAN);
						hldrSprt.addChild(TableObjectsArray[j][k].CELL);
					}
				}
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}

	}

}