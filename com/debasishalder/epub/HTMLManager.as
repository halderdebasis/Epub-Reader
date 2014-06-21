package com.debasishalder.epub
{
	import flash.system.System;
	public class HTMLManager
	{
		private var s:int;
		private var HTMLSTRING:String;
		private var TableStringArray:Vector.<String > ;
		private var FormulaStringArray:Vector.<String > ;
		private var VideoStringArray:Vector.<String > ;
		private var VideoSourceStringArray:Vector.<String > ;
		private var AudioSourceStringArray:Vector.<String > ;
		private var AudioStringArray:Vector.<String > ;
		private var ImageStringArray:Vector.<String > ;
		private var ObjectStringArray:Vector.<String > ;
		public var MEDIAPATH:String;
		public var PageTitle:String;
		public function HTMLManager()
		{

		}
		public function manageHTML(S:String,MEDIA_PATH:String='')
		{
			MEDIAPATH = MEDIA_PATH;
			PageTitle = ExtractTitle(S);
			TableStringArray = new Vector.<String >   ;
			FormulaStringArray = new Vector.<String >   ;
			VideoStringArray = new Vector.<String >   ;
			AudioStringArray = new Vector.<String >   ;
			ImageStringArray = new Vector.<String >   ;
			ObjectStringArray = new Vector.<String >   ;
			VideoSourceStringArray = new Vector.<String >   ;
			AudioSourceStringArray = new Vector.<String >   ;
			S = S.split('id=').join('styleName=');
			S = S.split('class=').join('id=');
			var arr:Array;
			var TAGRegExp:RegExp = /\<body(.*?)<\/body>/igs;
			arr = S.match(TAGRegExp);
			S = arr[0];
			TAGRegExp = null;
			TAGRegExp = /\<[^\/]*?(h1|h2|h3|h4|h5|h6)(.*?)>/ig;
			S = S.replace(TAGRegExp,'$&<span class="$1">');
			TAGRegExp = null;
			TAGRegExp = /\<\s*?\/\s*?(h1|h2|h3|h4|h5|h6)\s*?>/ig;
			S = S.replace(TAGRegExp,'</span>$&');
			TAGRegExp = null;
			TAGRegExp = /\<[^"\/]*?(h1|h2|h3|h4|h5|h6)/ig;
			S = S.replace(TAGRegExp,'<p');
			TAGRegExp = null;
			TAGRegExp = /\<\s*?\/\s*?(h1|h2|h3|h4|h5|h6)\s*?>/ig;
			S = S.replace(TAGRegExp,'</p>');
			TAGRegExp = null;
			S = S.replace(/\<\s*?Sub\s*?>/ig,'<FONT FACE="GG Subscript">');
			S = S.replace(/<\s*?\/\s*?Sub\s*?>/ig,'</FONT>');
			S = S.replace(/\<\s*?Sup\s*?>/ig,'<FONT FACE="GG Superscript">');
			S = S.replace(/<\s*?\/\s*?Sup\s*?>/ig,'</FONT>');
			TAGRegExp = /\<table(.*?)<\/table>/igs;
			arr = S.match(TAGRegExp);
			TAGRegExp = null;
			for (s = 0; s < arr.length; s++)
			{
				var TABLE:String = arr[s];
				S = S.split(TABLE).join((((('<p id="table' + s) + '" ><a href="event:table') + s) + '" id ="table"> </a></p>'));
				TABLE = TABLE.replace(/\<\s*?br\s*?>/ig,'<br />');
				TABLE = TABLE.replace(/<col\n*?(.*?)\n*?(.*?)\n*?>/ig,'');
				TABLE = TABLE.replace(/<tbody\n*?(.*?)\n*?(.*?)\n*?>/ig,'');
				TABLE = TABLE.replace(/<\s*?\/tbody\n*?(.*?)\n*?(.*?)\n*?>/ig,'');
				TableStringArray.push(TABLE);
				TABLE = null;

			}
			arr = null;
			TAGRegExp = null;
			TAGRegExp = /\<math(.*?)<\/math>/igs;
			arr = S.match(TAGRegExp);
			TAGRegExp = null;
			for (s = 0; s < arr.length; s++)
			{
				var MATH:String = arr[s];
				S = S.split(MATH).join((((('<p id="formula' + s) + '"><a href="event:formula') + s) + '" id ="formula"> </a></p>'));
				FormulaStringArray.push(MATH);
				MATH = null;
			}
			arr = null;
			TAGRegExp = null;
			TAGRegExp = /\<video(.*?)<\/video>/igs;
			HTMLSTRING = manageVideo(S,TAGRegExp,'video',VideoStringArray);
			S = null;
			TAGRegExp = null;
			TAGRegExp = /\<audio(.*?)<\/audio>/igs;
			HTMLSTRING = manageVideo(HTMLSTRING,TAGRegExp,'audio',AudioStringArray);
			TAGRegExp = null;
			HTMLSTRING = manageObjectTag(HTMLSTRING);
			HTMLSTRING = manageImgTag(HTMLSTRING);
			System.gc();
			System.gc();
			System.gc();
			System.gc();
			System.gc();

		}
		private function ExtractTitle(SS:String):String
		{
			var ttlr:RegExp = /\<\s*?title\s*?>(.*?)<\s*?\/\s*?title\s*?>/ig;
			var O:Object = SS.match(ttlr);
			var TTltag:String = O[0];
			O = null;
			ttlr = null;
			ttlr = /\<(.*?)>/ig;
			TTltag = TTltag.replace(ttlr,'');
			return TTltag;
		}
		private function manageVideo(S:String,TAGRegExp:RegExp,type:String,MediaARR:Vector.<String > ):String
		{
			var arr:Array = S.match(TAGRegExp);
			for (s = 0; s < arr.length; s++)
			{
				var VIDEO:String = arr[s];
				var VideoXML:XML = new XML(VIDEO);
				var SRC:String = VideoXML.children()[0].attribute("src");
				MediaARR.push(SRC);
				System.disposeXML(VideoXML);
				VideoXML = null;
				System.gc();
				System.gc();
				System.gc();
				if (SRC.indexOf('/') != -1)
				{
					SRC = SRC.substring(SRC.lastIndexOf('/') + 1,SRC.length);
				}
				SRC = MEDIAPATH + SRC;
				if ((type == 'video'))
				{
					S = S.split(VIDEO).join((('<p id="video' + s) + '"><a id="video" href="event:video">click here to play video </a></p>'));
					VideoSourceStringArray.push(SRC);
				}
				else if ((type == 'audio'))
				{
					S = S.split(VIDEO).join((('<p id="audio' + s) + '"><a id="audio" href="event:audio">click here to play audio </a></p>'));
					AudioSourceStringArray.push(SRC);
				}
				SRC = null;
				VIDEO = null;
			}
			arr = null;
			TAGRegExp = null;
			System.gc();
			System.gc();
			System.gc();
			System.gc();
			System.gc();
			return S;
		}
		private function manageObjectTag(S:String):String
		{
			var TAGRegExp:RegExp = /\<object(.*?)<\/object>/igs;
			var arr:Array = S.match(TAGRegExp);
			for (s = 0; s < arr.length; s++)
			{
				var OBJSTRING = arr[s];
				var IMGS:XML = new XML(OBJSTRING);
				var SRC:String = IMGS.children()[0].attribute('data');
				ObjectStringArray.push(SRC);
				var W:String = IMGS.children()[0].attribute('width');
				var H:String = IMGS.children()[0].attribute('height');
				System.disposeXML(IMGS);
				IMGS = null;
				System.gc();
				System.gc();
				System.gc();
				System.gc();
				System.gc();
				if (SRC.indexOf('/') != -1)
				{
					SRC = SRC.substring(SRC.lastIndexOf('/') + 1,SRC.length);
				}
				SRC = MEDIAPATH + SRC;
				var wdth:String;
				var Hght:String;
				if (! isNaN(Number(W)))
				{
					wdth = ' width="' + W + '"';
				}
				else
				{
					wdth = ' width="100"';
				}
				if (! isNaN(Number(H)))
				{
					Hght = ' height="' + H + '"';
				}
				else
				{
					Hght = ' height="100"';
				}

				S = S.split(OBJSTRING).join((((((('<img ' + ' src="') + SRC) + '"') + wdth) + Hght) + '/>'));
				wdth = null;
				Hght = null;
				SRC = null;
				OBJSTRING = null;
				TAGRegExp = null;
				arr = null;
			}
			System.gc();
			System.gc();
			System.gc();
			System.gc();
			System.gc();
			return S;
		}
		private function manageImgTag(S:String):String
		{
			var TAGRegExp:RegExp = /\<img[^>]*?>/igs;
			var arr:Array = S.match(TAGRegExp);
			for (s = 0; s < arr.length; s++)
			{
				var OBJSTRING = arr[s];
				var IMGS:XML = new XML((('<test>' + OBJSTRING) + '</test>'));

				var SRC:String = IMGS.children()[0].attribute('src');
				ImageStringArray.push(SRC);
				var W:String = IMGS.children()[0].attribute('width');
				var H:String = IMGS.children()[0].attribute('height');
				System.disposeXML(IMGS);
				IMGS = null;
				System.gc();
				System.gc();
				System.gc();
				System.gc();
				System.gc();
				if (SRC.indexOf('/') != -1)
				{
					SRC = SRC.substring(SRC.lastIndexOf('/') + 1,SRC.length);
				}
				SRC = MEDIAPATH + SRC;
				var wdth:String;
				var Hght:String;
				if (! isNaN(Number(W)) && W != '')
				{
					wdth = ' width="' + W + '"';
				}
				else
				{
					wdth = ' width="100"';
				}
				if (! isNaN(Number(H)) && H != '')
				{
					Hght = ' height="' + H + '"';
				}
				else
				{
					Hght = ' height="100"';
				}

				S = S.split(OBJSTRING).join((((((('<img ' + ' src="') + SRC) + '"') + wdth) + Hght) + '/>'));
				wdth = null;
				Hght = null;
				SRC = null;
				OBJSTRING = null;
				TAGRegExp = null;
				//arr = null;
			}
			arr = null;
			System.gc();
			System.gc();
			System.gc();
			System.gc();
			System.gc();
			return S;
		}
		public function getHTML():String
		{
			return HTMLSTRING;
		}
		public function getFormula():Vector.<String > 
		{
			return FormulaStringArray;
		}
		public function getTable():Vector.<String > 
		{
			return TableStringArray;
		}
		public function getImageSource():Vector.<String > 
		{
			return ImageStringArray;
		}
		public function getAudioSource():Vector.<String > 
		{
			return AudioStringArray;
		}
		public function getVideoSource():Vector.<String > 
		{
			return VideoStringArray;
		}
		public function getObjectSource():Vector.<String > 
		{
			return ObjectStringArray;
		}
		public function getAudioPath():Vector.<String > 
		{
			return AudioSourceStringArray;
		}
		public function getVideoPath():Vector.<String > 
		{
			return VideoSourceStringArray;
		}
		public function dispose()
		{
			HTMLSTRING = null;
			TableStringArray = null;
			FormulaStringArray = null;
			VideoStringArray = null;
			AudioStringArray = null;
			ImageStringArray = null;
			ObjectStringArray = null;
			MEDIAPATH = null;
			System.gc();
			System.gc();
			System.gc();
			System.gc();
			System.gc();
		}
	}

}